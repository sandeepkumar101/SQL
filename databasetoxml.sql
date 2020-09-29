PROCEDURE create_edi_xml(MSG_REFERENCE_P  IN VARCHAR2(17)) is
declare
   qryCtx dbms_xmlgen.ctxHandle;
   pxml XMLTYPE;
   cxml clob;
-- edi_st_equipment object type
CREATE TYPE edi_st_equipment_try AS OBJECT (
  EDI_ETD_UID           NUMBER(16)              NOT NULL,
  MSG_REFERENCE         VARCHAR2(17 BYTE)       NOT NULL,
  ACTIVITY_CODE         VARCHAR2(10 BYTE),
  FUNCTION_CODE         VARCHAR2(4 BYTE),
  VOYAGE_NUMBER         VARCHAR2(17 BYTE),
  VESSEL_NAME           VARCHAR2(35 BYTE),
  VESSEL_CODE           VARCHAR2(17 BYTE),
  PLACE_OF_ACCEPTANCE   VARCHAR2(10 BYTE),
  PORT_OF_ORIGIN        VARCHAR2(10 BYTE),
  PORT_OF_LOADING       VARCHAR2(10 BYTE),
  PORT_OF_TRANSHIPMENT  VARCHAR2(10 BYTE),
  PORT_OF_DISCHARGE     VARCHAR2(10 BYTE),
  PORT_OF_DESTINATION   VARCHAR2(10 BYTE),
  PLACE_OF_DELIVERY     VARCHAR2(10 BYTE),
  CELL_LOCATION         VARCHAR2(10 BYTE),
  ACTIVITY_PLACE        VARCHAR2(10 BYTE),
  ACTIVITY_LOCATION     VARCHAR2(17 BYTE),
  ACTIVITY_LOC_NAME     VARCHAR2(35 BYTE),
  ACTIVITY_LOC_TYPE     VARCHAR2(4 BYTE),
  ACTIVITY_DATE         DATE,
  SLOT_OWNER            VARCHAR2(17 BYTE),
  CONSIGNEE             VARCHAR2(17 BYTE),
  EQUIPMENT_OPERATOR    VARCHAR2(17 BYTE),
  EQUIPMENT_OWNER       VARCHAR2(17 BYTE),
  OCEAN_CARRIER         VARCHAR2(17 BYTE),
  TRADING_PARTNER       VARCHAR2(17 BYTE),
  BOOKING_REFERENCE     VARCHAR2(17 BYTE),
  BILL_NUMBER           VARCHAR2(17 BYTE),
  JOB_NUMBER            VARCHAR2(17 BYTE),
  RECEIPT_NUMBER        VARCHAR2(17 BYTE),
  EQUIPMENT_TYPE        VARCHAR2(4 BYTE),
  EQUIPMENT_NO          VARCHAR2(17 BYTE),
  EQUIPMENT_SIZE_TYPE   VARCHAR2(4 BYTE),
  EQUIPMENT_STATUS      VARCHAR2(4 BYTE),
  EQUIPMENT_FULL_EMPTY  VARCHAR2(4 BYTE),
  GROSS_WEIGHT          NUMBER(15,2),
  GROSS_WEIGHT_UOM      VARCHAR2(3 BYTE),
  LENGTH_UOM            VARCHAR2(3 BYTE),
  OVERLENGTH_FRONT      NUMBER(14,4),
  OVERLENGTH_BACK       NUMBER(14,4),
  OVERWIDTH_RIGHT       NUMBER(14,4),
  OVERWIDTH_LEFT        NUMBER(14,4),
  OVERHEIGHT            NUMBER(14,4),
  TEMPERATURE           NUMBER(6,2),
  TEMPERATURE_UOM       VARCHAR2(3 BYTE),
  DAMAGE_CODE           VARCHAR2(4 BYTE),
  DAMAGE_DESCRIPTION    VARCHAR2(70 BYTE),
  DAMAGE_AREA           VARCHAR2(35 BYTE),
  HAZ_MAT_CODE          VARCHAR2(17 BYTE),
  HAZ_MAT_CLASS         VARCHAR2(17 BYTE),
  HAZ_MAT_PAGE          VARCHAR2(17 BYTE),
  UNDG_NUMBER           NUMBER(4),
  TRANSPORT_STAGE       VARCHAR2(4 BYTE),
  CONVEYANCE_REFERENCE  VARCHAR2(17 BYTE),
  TRANSPORT_MODE        VARCHAR2(4 BYTE),
  TRANSPORT_MEANS       VARCHAR2(4 BYTE),
  CARRIER_CODE          VARCHAR2(17 BYTE),
  CARRIER_NAME          VARCHAR2(35 BYTE),
  CONVEYANCE_CODE       VARCHAR2(17 BYTE),
  CONVEYANCE_NAME       VARCHAR2(35 BYTE),
  SEAL_NUMBER_CU        VARCHAR2(17 BYTE),
  SEAL_NUMBER_CA        VARCHAR2(17 BYTE),
  SEAL_NUMBER_TO        VARCHAR2(17 BYTE),
  SEAL_NUMBER_SH        VARCHAR2(17 BYTE),
  TEXT_ID               VARCHAR2(4 BYTE),
  TEXT_CODE             VARCHAR2(4 BYTE),
  TEXT_DESCRIPTION      VARCHAR2(70 BYTE),
  ATTACHED_EQPT1        VARCHAR2(17 BYTE),
  EQUIPMENT_TYPE1       VARCHAR2(4 BYTE),
  ATTACHED_EQPT2        VARCHAR2(17 BYTE),
  EQUIPMENT_TYPE2       VARCHAR2(4 BYTE),
  ATTACHED_EQPT3        VARCHAR2(17 BYTE),
  EQUIPMENT_TYPE3       VARCHAR2(4 BYTE),
  ATTACHED_EQPT4        VARCHAR2(17 BYTE),
  EQUIPMENT_TYPE4       VARCHAR2(4 BYTE)
)

-- EDI_TRANSACTION_HEADER object type
CREATE TYPE EDI_TRANSACTION_HEADER_typ AUTHID CURRENT_USER AS OBJECT (
   MESSAGE_CODE 		VARCHAR2(10),
   API_CODE				VARCHAR2(10),
   DIRECTION			VARCHAR2(3),
   SENDER_ID			VARCHAR2(17),
   RECEIVER_ID			VARCHAR2(17),
   ACKNOWLEDGE			VARCHAR2(3),
   TEST_INDICATOR		VARCHAR2(3),
   INTF_CONTROL_NO		VARCHAR2(35),
   FILE_NAME 			VARCHAR2(70),
   EDI_ST_EQUIPMENT_ntab      EDI_ST_EQUIPMENT_ntabtyp
) 
/
-- edi_st_equipment Nested table
CREATE TYPE edi_st_equipment_ntabtyp AS TABLE OF edi_st_equipment_typ 


   			
CREATE OR REPLACE VIEW EDI_TRANSACTION_HEADER_VIEW  WITH OBJECT IDENTIFIER(MSG_REFERENCE)
   AS SELECT t.MESSAGE_CODE,
    t.API_CODE,
    t.DIRECTION,
    t.SENDER_ID,
    t.RECEIVER_ID,
    t.ACKNOWLEDGE,
    t.TEST_INDICATOR,
	t.INTF_CONTROL_NO,
	t.FILE_NAME 
   	 CAST( MULTISET(
                    SELECT EDI_ST_EQUIPMENT_typ( 
                    c.EDI_ETD_UID,
					c.MSG_REFERENCE,
					c.ACTIVITY_CODE,
					c.FUNCTION_CODE,
					C.VOYAGE_NUMBER,
					C.VESSEL_NAME,
					C.VESSEL_CODE,
					C.PLACE_OF_ACCEPTANCE,
					C.PORT_OF_ORIGIN,
					C.PORT_OF_LOADING,
					C.PORT_OF_TRANSHIPMENT,
					C.PORT_OF_DISCHARGE,
					C.PORT_OF_DESTINATION,
					C.PLACE_OF_DELIVERY,
					C.CELL_LOCATION,
					C.ACTIVITY_PLACE,
					C.ACTIVITY_LOCATION,
					C.ACTIVITY_LOC_NAME,
					C.ACTIVITY_LOC_TYPE,
					C.ACTIVITY_DATE,
					C.SLOT_OWNER,
					C.CONSIGNEE,
					C.EQUIPMENT_OPERATOR,
					C.EQUIPMENT_OWNER,
					C.OCEAN_CARRIER,
					C.TRADING_PARTNER,
					C.BOOKING_REFERENCE,
					C.BILL_NUMBER,
					C.JOB_NUMBER,
					C.RECEIPT_NUMBER,
					C.EQUIPMENT_TYPE,
					C.EQUIPMENT_NO,
					C.EQUIPMENT_SIZE_TYPE,
					C.EQUIPMENT_STATUS,
					C.EQUIPMENT_FULL_EMPTY,
					C.GROSS_WEIGHT,
					C.GROSS_WEIGHT_UOM,
					C.LENGTH_UOM,
					C.OVERLENGTH_FRONT,
					C.OVERLENGTH_BACK,
					C.OVERWIDTH_RIGHT,
					C.OVERWIDTH_LEFT,
					C.OVERHEIGHT,
					C.TEMPERATURE,
					C.TEMPERATURE_UOM,
					C.DAMAGE_CODE,
					C.DAMAGE_DESCRIPTION,
					C.DAMAGE_AREA,
					C.HAZ_MAT_CODE,
					C.HAZ_MAT_CLASS,
					C.HAZ_MAT_PAGE,
					C.UNDG_NUMBER,
					C.TRANSPORT_STAGE,
					C.CONVEYANCE_REFERENCE,
					C.TRANSPORT_MODE,
					C.TRANSPORT_MEANS,
					C.CARRIER_CODE,
					C.CARRIER_NAME,
					C.CONVEYANCE_CODE,
					C.CONVEYANCE_NAME,
					C.SEAL_NUMBER_CU,
					C.SEAL_NUMBER_CA,
					C.SEAL_NUMBER_TO,
					C.SEAL_NUMBER_SH,
					C.TEXT_ID,
					C.TEXT_CODE,
					C.TEXT_DESCRIPTION,
					C.ATTACHED_EQPT1,
					C.EQUIPMENT_TYPE1,
					C.ATTACHED_EQPT2,
					C.EQUIPMENT_TYPE2,
					C.ATTACHED_EQPT3,
					C.EQUIPMENT_TYPE3,
					C.ATTACHED_EQPT4,
					C.EQUIPMENT_TYPE4
                     FROM EDI_ST_EQUIPMENT c
                     WHERE t.msg_reference=c.msg_reference )
                 AS edi_st_equipment_ntabtyp)
   	FROM EDI_TRANSACTION_HEADER t
   	where MSG_REFERENCE = SG_REFERENCE_P;

-- create table with XMLType column to store po in XML format
create table po_xml_tab(
  MSG_REFERENCE         VARCHAR2(17),
  poDoc XMLTYPE /* purchase order in XML format */
)


-------------------------------------------------------
-- Use DBMS_XMLGEN Package to generate PO in XML format
-- and store XMLTYPE in po_xml table
-------------------------------------------------------

begin

  -- get the query context;
  qryCtx := dbms_xmlgen.newContext('
                    select MESSAGE_CODE,deref(EDI_ST_EQUIPMENT_ref) EDI_ST_EQUIPMENT
                    from EDI_TRANSACTION_HEADER_VIEW '
             );
  
  -- set the maximum number of rows to be 1,
  dbms_xmlgen.setMaxRows(qryCtx, 1);
  -- set rowset tag to null and row tag to PurchaseOrder
  dbms_xmlgen.setRowSetTag(qryCtx,null);
  dbms_xmlgen.setRowTag(qryCtx,'EDI_TRANSACTION_HEADER');

  loop 
    -- now get the po in xml format
    pxml := dbms_xmlgen.getXMLType(qryCtx);
    
    -- if there were no rows processed, then quit..!
    exit when dbms_xmlgen.getNumRowsProcessed(qryCtx) = 0;

    -- Store XMLTYPE po in po_xml table (get the pono out)
    insert into po_xml_tab (MSG_REFERENCE, poDoc)
       values(
            pxml.extract('//MSG_REFERENCE/text()'),
            pxml);
  end loop;
end;
/