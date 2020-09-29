
-- Create relational schema and define Object Views
-- Note: DBMS_XMLGEN Package maps UDT attributes names
--       starting with '@' to xml attributes
------------------------------------------------------
-- Purchase Order Object View Model

-- PhoneList Varray object type
CREATE TYPE PhoneList_vartyp AS VARRAY(10) OF VARCHAR2(20)
/

-- Address object type
CREATE TYPE Address_typ AS OBJECT (
  Street         VARCHAR2(200),
  City           VARCHAR2(200),
  State          CHAR(2),
  Zip            VARCHAR2(20)
  ) 
/

-- Customer object type
CREATE TYPE Customer_typ AS OBJECT (
  CustNo           NUMBER,
  CustName         VARCHAR2(200),
  Address          Address_typ,
  PhoneList        PhoneList_vartyp
)
/

-- StockItem object type
CREATE TYPE StockItem_typ AS OBJECT (
  "@StockNo"    NUMBER,
  Price      NUMBER,
  TaxRate    NUMBER
)
/

-- LineItems object type
CREATE TYPE LineItem_typ AS OBJECT (
  "@LineItemNo"   NUMBER,
  Item    StockItem_typ,
  Quantity     NUMBER,
  Discount     NUMBER
  ) 
/
-- LineItems Nested table
CREATE TYPE LineItems_ntabtyp AS TABLE OF LineItem_typ 
/

-- Purchase Order object type
CREATE TYPE PO_typ AUTHID CURRENT_USER AS OBJECT (
  PONO                 NUMBER,
  Cust_ref             REF Customer_typ,
  OrderDate            DATE,
  ShipDate             TIMESTAMP,
  LineItems_ntab       LineItems_ntabtyp,
  ShipToAddr           Address_typ
 ) 
/
 
-- Create Purchase Order Relational Model tables

--Customer table
CREATE TABLE Customer_tab(
  CustNo                NUMBER NOT NULL,
  CustName              VARCHAR2(200) ,
  Street                VARCHAR2(200) ,
  City                  VARCHAR2(200) ,
  State                 CHAR(2) ,
  Zip                   VARCHAR2(20) ,
  Phone1                VARCHAR2(20),
  Phone2                VARCHAR2(20),
  Phone3                VARCHAR2(20),
  constraint cust_pk PRIMARY KEY (CustNo)
) 
ORGANIZATION INDEX OVERFLOW;

-- Purchase Order table
CREATE TABLE po_tab (
   PONo        NUMBER, /* purchase order no */  
   Custno      NUMBER constraint po_cust_fk references Customer_tab, 
                                /*  Foreign KEY referencing customer */
   OrderDate   DATE, /*  date of order */  
   ShipDate    TIMESTAMP, /* date to be shipped */    
   ToStreet    VARCHAR2(200), /* shipto address */    
   ToCity      VARCHAR2(200),    
   ToState     CHAR(2),    
   ToZip       VARCHAR2(20),
   constraint po_pk PRIMARY KEY(PONo)    
); 

--Stock Table
CREATE TABLE Stock_tab (
  StockNo      NUMBER constraint stock_uk UNIQUE,
  Price        NUMBER,
  TaxRate      NUMBER
);

--Line Items Table
CREATE TABLE LineItems_tab(
  LineItemNo           NUMBER,
  PONo                 NUMBER constraint LI_PO_FK REFERENCES po_tab,
  StockNo              NUMBER ,
  Quantity             NUMBER,
  Discount             NUMBER,
  constraint LI_PK PRIMARY KEY (PONo, LineItemNo)
);

-- create Object Views

--Customer Object View
CREATE OR REPLACE VIEW Customer OF Customer_typ
   WITH OBJECT IDENTIFIER(CustNo)
   AS SELECT c.Custno, C.custname,
             Address_typ(C.Street, C.City, C.State, C.Zip),
             PhoneList_vartyp(Phone1, Phone2, Phone3)
        FROM Customer_tab c;

--Purchase order view
CREATE OR REPLACE VIEW PO OF PO_typ
  WITH OBJECT IDENTIFIER (PONO)
   AS SELECT P.PONo,
             MAKE_REF(Customer, P.Custno),
             P.OrderDate,
             P.ShipDate,
             CAST( MULTISET(
                    SELECT LineItem_typ( L.LineItemNo,
                                  StockItem_typ(L.StockNo,S.Price,S.TaxRate),
                                            L.Quantity, L.Discount)
                     FROM LineItems_tab L, Stock_tab S
                     WHERE L.PONo = P.PONo and S.StockNo=L.StockNo )
                 AS LineItems_ntabtyp),
         Address_typ(P.ToStreet,P.ToCity, P.ToState, P.ToZip)
        FROM PO_tab P;

-- create table with XMLType column to store po in XML format
create table po_xml_tab(
  poid number,
  poDoc XMLTYPE /* purchase order in XML format */
)
/

--------------------
-- Populate data
-------------------
-- Establish Inventory

INSERT INTO Stock_tab VALUES(1004, 6750.00, 2) ;
INSERT INTO Stock_tab VALUES(1011, 4500.23, 2) ;
INSERT INTO Stock_tab VALUES(1534, 2234.00, 2) ;
INSERT INTO Stock_tab VALUES(1535, 3456.23, 2) ;

-- Register Customers

INSERT INTO Customer_tab
  VALUES (1, 'Jean Nance', '2 Avocet Drive',
         'Redwood Shores', 'CA', '95054',
         '415-555-1212', NULL, NULL) ;

INSERT INTO Customer_tab
  VALUES (2, 'John Nike', '323 College Drive',
         'Edison', 'NJ', '08820',
         '609-555-1212', '201-555-1212', NULL) ;

-- Place Orders

INSERT INTO PO_tab
  VALUES (1001, 1, '10-APR-1997', '10-MAY-1997',
          NULL, NULL, NULL, NULL) ;

INSERT INTO PO_tab
  VALUES (2001, 2, '20-APR-1997', '20-MAY-1997',
         '55 Madison Ave', 'Madison', 'WI', '53715') ;

-- Detail Line Items

INSERT INTO LineItems_tab VALUES(01, 1001, 1534, 12,  0) ;
INSERT INTO LineItems_tab VALUES(02, 1001, 1535, 10, 10) ;
INSERT INTO LineItems_tab VALUES(01, 2001, 1004,  1,  0) ;
INSERT INTO LineItems_tab VALUES(02, 2001, 1011,  2,  1) ;


-------------------------------------------------------
-- Use DBMS_XMLGEN Package to generate PO in XML format
-- and store XMLTYPE in po_xml table
-------------------------------------------------------

declare
   qryCtx dbms_xmlgen.ctxHandle;
   pxml XMLTYPE;
   cxml clob;
begin

  -- get the query context;
  qryCtx := dbms_xmlgen.newContext('
                    select pono,deref(cust_ref) customer,p.OrderDate,p.shipdate,
                           lineitems_ntab lineitems,shiptoaddr
                    from po p'
             );
  
  -- set the maximum number of rows to be 1,
  dbms_xmlgen.setMaxRows(qryCtx, 1);
  -- set rowset tag to null and row tag to PurchaseOrder
  dbms_xmlgen.setRowSetTag(qryCtx,null);
  dbms_xmlgen.setRowTag(qryCtx,'PurchaseOrder');

  loop 
    -- now get the po in xml format
    pxml := dbms_xmlgen.getXMLType(qryCtx);
    
    -- if there were no rows processed, then quit..!
    exit when dbms_xmlgen.getNumRowsProcessed(qryCtx) = 0;

    -- Store XMLTYPE po in po_xml table (get the pono out)
    insert into po_xml_tab (poid, poDoc)
       values(
            pxml.extract('//PONO/text()').getNumberVal(),
            pxml);
  end loop;
end;
/

---------------------------
-- list xml PurchaseOrders
---------------------------

set long 100000
set pages 100
select x.podoc.getClobVal() xpo
from   po_xml_tab x;
This produces the following purchase order XML documents:

PurchaseOrder 1001:

<?xml version="1.0"?>
 <PurchaseOrder>
  <PONO>1001</PONO>
  <CUSTOMER>
   <CUSTNO>1</CUSTNO>
   <CUSTNAME>Jean Nance</CUSTNAME>
   <ADDRESS>
    <STREET>2 Avocet Drive</STREET>
    <CITY>Redwood Shores</CITY>
    <STATE>CA</STATE>
    <ZIP>95054</ZIP>
   </ADDRESS>
   <PHONELIST>
    <VARCHAR2>415-555-1212</VARCHAR2>
   </PHONELIST>
  </CUSTOMER>
  <ORDERDATE>10-APR-97</ORDERDATE>
  <SHIPDATE>10-MAY-97 12.00.00.000000 AM</SHIPDATE>
  <LINEITEMS>
   <LINEITEM_TYP LineItemNo="1">
    <ITEM StockNo="1534">
     <PRICE>2234</PRICE>
     <TAXRATE>2</TAXRATE>
    </ITEM>
    <QUANTITY>12</QUANTITY>
    <DISCOUNT>0</DISCOUNT>
   </LINEITEM_TYP>
   <LINEITEM_TYP LineItemNo="2">
    <ITEM StockNo="1535">
     <PRICE>3456.23</PRICE>
     <TAXRATE>2</TAXRATE>
    </ITEM>
    <QUANTITY>10</QUANTITY>
    <DISCOUNT>10</DISCOUNT>
   </LINEITEM_TYP>
  </LINEITEMS>
  <SHIPTOADDR/>
 </PurchaseOrder>

PurchaseOrder 2001:

<?xml version="1.0"?>
 <PurchaseOrder>
  <PONO>2001</PONO>
  <CUSTOMER>
   <CUSTNO>2</CUSTNO>
   <CUSTNAME>John Nike</CUSTNAME>
   <ADDRESS>
    <STREET>323 College Drive</STREET>
    <CITY>Edison</CITY>
    <STATE>NJ</STATE>
    <ZIP>08820</ZIP>
   </ADDRESS>
   <PHONELIST>
    <VARCHAR2>609-555-1212</VARCHAR2>
    <VARCHAR2>201-555-1212</VARCHAR2>
   </PHONELIST>
  </CUSTOMER>
  <ORDERDATE>20-APR-97</ORDERDATE>
  <SHIPDATE>20-MAY-97 12.00.00.000000 AM</SHIPDATE>
  <LINEITEMS>
   <LINEITEM_TYP LineItemNo="1">
    <ITEM StockNo="1004">
     <PRICE>6750</PRICE>
     <TAXRATE>2</TAXRATE>
    </ITEM>
    <QUANTITY>1</QUANTITY>
    <DISCOUNT>0</DISCOUNT>
   </LINEITEM_TYP>
   <LINEITEM_TYP LineItemNo="2">
    <ITEM StockNo="1011">
     <PRICE>4500.23</PRICE>
     <TAXRATE>2</TAXRATE>
    </ITEM>
    <QUANTITY>2</QUANTITY>
    <DISCOUNT>1</DISCOUNT>
   </LINEITEM_TYP>
  </LINEITEMS>
  <SHIPTOADDR>
   <STREET>55 Madison Ave</STREET>
   <CITY>Madison</CITY>
   <STATE>WI</STATE>
   <ZIP>53715</ZIP>
  </SHIPTOADDR>
 </PurchaseOrder>

