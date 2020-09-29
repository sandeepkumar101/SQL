PROCEDURE xml_register is
declare 
 schemaURL varchar2(256);
 schemaPath varchar2(256);
 nested_table_name varchar2(256);
 iot_index_name varchar2(256);
 filelist XMLType;
:schemaURL := 'http://xfiles:8080/home/SCOTT/poSource/xsd/EdiStEquipment.xsd';
:schemaPath := '/public/EdiStEquipment.xsd';
create or replace directory XMLDIR as '/xdb/faq/edi';
res boolean;
xmlSchema xmlType := xmlType(
'<?xml version="1.0"?>
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
	<xsd:element name="EDI_TRANSACTION_HEADER">
		<xsd:complexType>
			<xsd:sequence>
				<xsd:element ref="MESSAGE_CODE"/>
				<xsd:element ref="API_CODE"/>
				<xsd:element ref="DIRECTION"/>
				<xsd:element ref="SENDER_ID"/>
				<xsd:element ref="RECEIVER_ID"/>
				<xsd:element ref="ACKNOWLEDGE"/>
				<xsd:element ref="TEST_INDICATOR"/>
				<xsd:element ref="INTF_CONTROL_NO"/>
				<xsd:element ref="FILE_NAME"/>
				<xsd:element ref="EDI_ST_EQUIPMENT" minOccurs="1" maxOccurs="unbounded"/>
			</xsd:sequence>
		</xsd:complexType>
	</xsd:element>
	<xsd:element name="EDI_ST_EQUIPMENT">
		<xsd:complexType>
			<xsd:sequence>
				<xsd:element ref="EDI_ETD_UID"/>
				<xsd:element ref="MSG_REFERENCE"/>
				<xsd:element ref="ACTIVITY_CODE"/>
				<xsd:element ref="FUNCTION_CODE"/>
				<xsd:element ref="VOYAGE_NUMBER"/>
				<xsd:element ref="VESSEL_NAME"/>
				<xsd:element ref="VESSEL_CODE"/>
				<xsd:element ref="PLACE_OF_ACCEPTANCE"/>
				<xsd:element ref="PORT_OF_ORIGIN"/>
				<xsd:element ref="PORT_OF_LOADING"/>
				<xsd:element ref="PORT_OF_TRANSHIPMENT"/>
				<xsd:element ref="PORT_OF_DISCHARGE"/>
				<xsd:element ref="PORT_OF_DESTINATION"/>
				<xsd:element ref="PLACE_OF_DELIVERY"/>
				<xsd:element ref="CELL_LOCATION"/>
				<xsd:element ref="ACTIVITY_PLACE"/>
				<xsd:element ref="ACTIVITY_LOCATION"/>
				<xsd:element ref="ACTIVITY_LOC_NAME"/>
				<xsd:element ref="ACTIVITY_LOC_TYPE"/>
				<xsd:element ref="ACTIVITY_DATE"/>
				<xsd:element ref="SLOT_OWNER"/>
				<xsd:element ref="CONSIGNEE"/>
				<xsd:element ref="EQUIPMENT_OPERATOR"/>
				<xsd:element ref="EQUIPMENT_OWNER"/>
				<xsd:element ref="OCEAN_CARRIER"/>
				<xsd:element ref="TRADING_PARTNER"/>
				<xsd:element ref="BOOKING_REFERENCE"/>
				<xsd:element ref="BILL_NUMBER"/>
				<xsd:element ref="JOB_NUMBER"/>
				<xsd:element ref="RECEIPT_NUMBER"/>
				<xsd:element ref="EQUIPMENT_TYPE"/>
				<xsd:element ref="EQUIPMENT_NO"/>
				<xsd:element ref="EQUIPMENT_SIZE_TYPE"/>
				<xsd:element ref="EQUIPMENT_STATUS"/>
				<xsd:element ref="EQUIPMENT_FULL_EMPTY"/>
				<xsd:element ref="GROSS_WEIGHT"/>
				<xsd:element ref="GROSS_WEIGHT_UOM"/>
				<xsd:element ref="LENGTH_UOM"/>
				<xsd:element ref="OVERLENGTH_FRONT"/>
				<xsd:element ref="OVERLENGTH_BACK"/>
				<xsd:element ref="OVERWIDTH_RIGHT"/>
				<xsd:element ref="OVERWIDTH_LEFT"/>
				<xsd:element ref="OVERHEIGHT"/>
				<xsd:element ref="TEMPERATURE"/>
				<xsd:element ref="TEMPERATURE_UOM"/>
				<xsd:element ref="DAMAGE_CODE"/>
				<xsd:element ref="DAMAGE_DESCRIPTION"/>
				<xsd:element ref="DAMAGE_AREA"/>
				<xsd:element ref="HAZ_MAT_CODE"/>
				<xsd:element ref="HAZ_MAT_CLASS"/>
				<xsd:element ref="HAZ_MAT_PAGE"/>
				<xsd:element ref="UNDG_NUMBER"/>
				<xsd:element ref="TRANSPORT_STAGE"/>
				<xsd:element ref="CONVEYANCE_REFERENCE"/>
				<xsd:element ref="TRANSPORT_MODE"/>
				<xsd:element ref="TRANSPORT_MEANS"/>
				<xsd:element ref="CARRIER_CODE"/>
				<xsd:element ref="CARRIER_NAME"/>
				<xsd:element ref="CONVEYANCE_CODE"/>
				<xsd:element ref="CONVEYANCE_NAME"/>
				<xsd:element ref="SEAL_NUMBER_CU"/>
				<xsd:element ref="SEAL_NUMBER_CA"/>
				<xsd:element ref="SEAL_NUMBER_TO"/>
				<xsd:element ref="SEAL_NUMBER_SH"/>
				<xsd:element ref="TEXT_ID"/>
				<xsd:element ref="TEXT_CODE"/>
				<xsd:element ref="TEXT_DESCRIPTION"/>
				<xsd:element ref="ATTACHED_EQPT1"/>
				<xsd:element ref="EQUIPMENT_TYPE1"/>
				<xsd:element ref="ATTACHED_EQPT2"/>
				<xsd:element ref="EQUIPMENT_TYPE2"/>
				<xsd:element ref="ATTACHED_EQPT3"/>
				<xsd:element ref="EQUIPMENT_TYPE3"/>
				<xsd:element ref="ATTACHED_EQPT4"/>
				<xsd:element ref="EQUIPMENT_TYPE4"/>
			</xsd:sequence>
		</xsd:complexType>
	</xsd:element>
	<xsd:element name="TEMPERATURE" type="xsd:string"/>
	<xsd:element name="ACTIVITY_CODE" type="xsd:string"/>
	<xsd:element name="TRANSPORT_MEANS" type="xsd:string"/>
	<xsd:element name="EQUIPMENT_OPERATOR" type="xsd:string"/>
	<xsd:element name="ACTIVITY_PLACE" type="xsd:string"/>
	<xsd:element name="PORT_OF_DESTINATION" type="xsd:string"/>
	<xsd:element name="PORT_OF_ORIGIN" type="xsd:string"/>
	<xsd:element name="SEAL_NUMBER_CU" type="xsd:string"/>
	<xsd:element name="TRANSPORT_STAGE" type="xsd:string"/>
	<xsd:element name="OVERHEIGHT" type="xsd:string"/>
	<xsd:element name="EQUIPMENT_STATUS" type="xsd:string"/>
	<xsd:element name="BILL_NUMBER" type="xsd:string"/>
	<xsd:element name="OCEAN_CARRIER" type="xsd:string"/>
	<xsd:element name="RECEIVER_ID" type="xsd:string"/>
	<xsd:element name="HAZ_MAT_PAGE" type="xsd:string"/>
	<xsd:element name="OVERWIDTH_RIGHT" type="xsd:string"/>
	<xsd:element name="ACTIVITY_DATE" type="xsd:string"/>
	<xsd:element name="EQUIPMENT_TYPE1" type="xsd:string"/>
	<xsd:element name="UNDG_NUMBER" type="xsd:string"/>
	<xsd:element name="EQUIPMENT_TYPE2" type="xsd:string"/>
	<xsd:element name="DAMAGE_DESCRIPTION" type="xsd:string"/>
	<xsd:element name="TEMPERATURE_UOM" type="xsd:string"/>
	<xsd:element name="OVERLENGTH_BACK" type="xsd:string"/>
	<xsd:element name="GROSS_WEIGHT_UOM" type="xsd:string"/>
	<xsd:element name="EQUIPMENT_NO" type="xsd:string"/>
	<xsd:element name="FILE_NAME" type="xsd:string"/>
	<xsd:element name="MESSAGE_CODE" type="xsd:string"/>
	<xsd:element name="EQUIPMENT_TYPE3" type="xsd:string"/>
	<xsd:element name="CONVEYANCE_NAME" type="xsd:string"/>
	<xsd:element name="CONVEYANCE_CODE" type="xsd:string"/>
	<xsd:element name="CONVEYANCE_REFERENCE" type="xsd:string"/>
	<xsd:element name="PLACE_OF_DELIVERY" type="xsd:string"/>
	<xsd:element name="PORT_OF_LOADING" type="xsd:string"/>
	<xsd:element name="MSG_REFERENCE" type="xsd:string"/>
	<xsd:element name="EQUIPMENT_TYPE4" type="xsd:string"/>
	<xsd:element name="SEAL_NUMBER_SH" type="xsd:string"/>
	<xsd:element name="OVERWIDTH_LEFT" type="xsd:string"/>
	<xsd:element name="OVERLENGTH_FRONT" type="xsd:string"/>
	<xsd:element name="TRADING_PARTNER" type="xsd:string"/>
	<xsd:element name="ACTIVITY_LOCATION" type="xsd:string"/>
	<xsd:element name="PORT_OF_DISCHARGE" type="xsd:string"/>
	<xsd:element name="INTF_CONTROL_NO" type="xsd:string"/>
	<xsd:element name="ATTACHED_EQPT1" type="xsd:string"/>
	<xsd:element name="EQUIPMENT_TYPE" type="xsd:string"/>
	<xsd:element name="BOOKING_REFERENCE" type="xsd:string"/>
	<xsd:element name="ACTIVITY_LOC_TYPE" type="xsd:string"/>
	<xsd:element name="SENDER_ID" type="xsd:string"/>
	<xsd:element name="ATTACHED_EQPT2" type="xsd:string"/>
	<xsd:element name="TEXT_CODE" type="xsd:string"/>
	<xsd:element name="EQUIPMENT_SIZE_TYPE" type="xsd:string"/>
	<xsd:element name="ACKNOWLEDGE" type="xsd:string"/>
	<xsd:element name="API_CODE" type="xsd:string"/>
	<xsd:element name="ATTACHED_EQPT3" type="xsd:string"/>
	<xsd:element name="CARRIER_NAME" type="xsd:string"/>
	<xsd:element name="CARRIER_CODE" type="xsd:string"/>
	<xsd:element name="LENGTH_UOM" type="xsd:string"/>
	<xsd:element name="EQUIPMENT_FULL_EMPTY" type="xsd:string"/>
	<xsd:element name="JOB_NUMBER" type="xsd:string"/>
	<xsd:element name="CONSIGNEE" type="xsd:string"/>
	<xsd:element name="ACTIVITY_LOC_NAME" type="xsd:string"/>
	<xsd:element name="EDI_ETD_UID" type="xsd:string"/>
	<xsd:element name="ATTACHED_EQPT4" type="xsd:string"/>
	<xsd:element name="TEXT_DESCRIPTION" type="xsd:string"/>
	<xsd:element name="PLACE_OF_ACCEPTANCE" type="xsd:string"/>
	<xsd:element name="TEST_INDICATOR" type="xsd:string"/>
	<xsd:element name="SEAL_NUMBER_TO" type="xsd:string"/>
	<xsd:element name="DAMAGE_AREA" type="xsd:string"/>
	<xsd:element name="DAMAGE_CODE" type="xsd:string"/>
	<xsd:element name="TRANSPORT_MODE" type="xsd:string"/>
	<xsd:element name="HAZ_MAT_CLASS" type="xsd:string"/>
	<xsd:element name="GROSS_WEIGHT" type="xsd:string"/>
	<xsd:element name="CELL_LOCATION" type="xsd:string"/>
	<xsd:element name="VESSEL_CODE" type="xsd:string"/>
	<xsd:element name="VESSEL_NAME" type="xsd:string"/>
	<xsd:element name="FUNCTION_CODE" type="xsd:string"/>
	<xsd:element name="DIRECTION" type="xsd:string"/>
	<xsd:element name="EQUIPMENT_OWNER" type="xsd:string"/>
	<xsd:element name="SLOT_OWNER" type="xsd:string"/>
	<xsd:element name="TEXT_ID" type="xsd:string"/>
	<xsd:element name="SEAL_NUMBER_CA" type="xsd:string"/>
	<xsd:element name="HAZ_MAT_CODE" type="xsd:string"/>
	<xsd:element name="RECEIPT_NUMBER" type="xsd:string"/>
	<xsd:element name="PORT_OF_TRANSHIPMENT" type="xsd:string"/>
	<xsd:element name="VOYAGE_NUMBER" type="xsd:string"/>
</xsd:schema>
');
BEGIN
  	call dbms_xmlSchema.deleteSchema(:schemaURL,4);
  
	if (dbms_xdb.existsResource(:schemaPath)) then
	      dbms_xdb.deleteResource(:schemaPath);
    end if;
	    res := dbms_xdb.createResource(:schemaPath,xmlSchema);
   	
   	dbms_xmlschema.registerSchema
    (
      :schemaURL,
      xdbURIType(:schemaPath).getClob(),
      TRUE,TRUE,FALSE,TRUE
    );
  
  
  select table_name
      into nested_table_name
      from user_nested_tables
     where parent_table_column = '"XMLDATA"."EDI_ST_EQUIPMENT"."EDI_ST_EQUIPMENT"'
       and parent_table_name = 'EDI_TRANSACTION_HEADER';

    execute immediate 'rename "'|| nested_table_name ||'" to EDI_ST_EQUIPMENT_TABLE';

    select index_name
      into iot_index_name
      from user_indexes
     where table_name = 'EDI_ST_EQUIPMENT_TABLE' and index_type = 'IOT - TOP';

    execute immediate 'alter index "'|| iot_index_name ||'" rename to EDI_ST_EQUIPMENT_IOT';

   
  
create or replace view EDI_TRANSACTION_HEADER_VIEW
  as
    select m.*
      from EDI_TRANSACTION_HEADER p,
           xmlTable
           (
              '/EDI_TRANCASTION_HEADER'
              passing object_value
              columns
              MESSAGE_CODE          varchar2(30)   path  'MESSAGE_CODE',
              API_CODE           	varchar2(128)  path  'API_CODE',
              DIRECTION             varchar2(10)   path  'DIRECTION',
              SENDER_ID          	varchar2(4)    path  'SENDER_ID',
              RECIEVER_ID          	varchar2(10)   path  'RECIEVER_ID',
              ACKNOWLEDGE        	timestamp      path  'ACKNOWLEDGE',
              TEST_INDICATOR        varchar2(2048) path  'TEST_INDICATOR',
              INTF_CONTROL_NO       varchar2(20)   path  'INTF_CONTROL_NO',
              FILE_NAME             varchar2(128)  path  'FILE_NAME',
              EDI_ST_EQUIPMENT      varchar2(24)   path  'EDI_ST_EQUIPMENT',
              
           ) m;

create or replace view EDI_ST_EQUIPMENT_VIEW
  as
    select m.MESSAGE_CODE, a.*
      from EDI_TRANSACTION_HEADER p,
           xmlTable
           (
              '/EDI_TRANCASTION_HEADER'
              passing object_value
              columns
              MESSAGE_CODE       varchar2(30)   path  'Reference',
              EDI_ST_EQUIPMENT   xmlType        path  'EDI_ST_EQUIPMENT'
           ) m,
           xmlTable
           (
            '/EDI_ST_EQUIPMENT'
             passing m.EDI_ST_EQUIPMENT
             columns
             EDI_ETD_UID   NUMBER(16) path 'EDI_ETD_UID',
             MSG_REFERENCE VARCHAR2(17)    path 'MSG_REFERENCE',
             ACTIVITY_CODE VARCHAR2(10) path 'ACTIVITY_CODE',
             FUNCTION_CODE VARCHAR2(4) path 'FUNCTION_CODE',
             VOYAGE_NUMBER VARCHAR2(17) path 'VOYAGE_NUMBER',
             VESSEL_NAME   VARCHAR2(35) path 'VESSEL_NAME',
             VESSEL_CODE   VARCHAR2(17) path 'VESSEL_CODE',
             PLACE_OF_ACCEPTANCE   VARCHAR2(10) path 'PLACE_OF_ACCEPTANCE',
             PORT_OF_ORIGIN   VARCHAR2(10) path 'PORT_OF_ORIGIN',
             PORT_OF_LOADING   VARCHAR2(10) path 'PORT_OF_LOADING',
             PORT_OF_TRANSHIPMENT   VARCHAR2(10) path 'PORT_OF_TRANSHIPMENT',
             PORT_OF_DISCHARGE   VARCHAR2(10) path 'PORT_OF_DISCHARGE',
             PORT_OF_DESTINATION   VARCHAR2(10) path 'PORT_OF_DESTINATION',
             PLACE_OF_DELIVERY   VARCHAR2(10) path 'PLACE_OF_DELIVERY',
             CELL_LOCATION   VARCHAR2(10) path 'CELL_LOCATION',
             ACTIVITY_PLACE   VARCHAR2(10) path 'ACTIVITY_PLACE',
             ACTIVITY_LOCATION   VARCHAR2(17) path 'ACTIVITY_LOCATION',
             ACTIVITY_LOC_NAME   VARCHAR2(35) path 'ACTIVITY_LOC_NAME',
             ACTIVITY_LOC_TYPE   VARCHAR2(4) path 'ACTIVITY_LOC_TYPE',
             ACTIVITY_DATE   DATE path 'ACTIVITY_DATE',
             SLOT_OWNER   VARCHAR2(17) path 'SLOT_OWNER',
             CONSIGNEE   VARCHAR2(17) path 'CONSIGNEE',
             EQUIPMENT_OPERATOR   VARCHAR2(17) path 'EQUIPMENT_OPERATOR',
             EQUIPMENT_OWNER   VARCHAR2(17) path 'EQUIPMENT_OWNER',
             OCEAN_CARRIER   VARCHAR2(17) path 'OCEAN_CARRIER',
             TRADING_PARTNER   VARCHAR2(17) path 'TRADING_PARTNER',
             BOOKING_REFERENCE   VARCHAR2(17) path 'BOOKING_REFERENCE',
             BILL_NUMBER   VARCHAR2(17) path 'BILL_NUMBER',
             JOB_NUMBER   VARCHAR2(17) path 'JOB_NUMBER',
             RECEIPT_NUMBER   VARCHAR2(17) path 'RECEIPT_NUMBER',
             EQUIPMENT_TYPE   VARCHAR2(4) path 'EQUIPMENT_TYPE',
             EQUIPMENT_NO   VARCHAR2(17) path 'EQUIPMENT_NO',
             EQUIPMENT_SIZE_TYPE   VARCHAR2(4) path 'EQUIPMENT_SIZE_TYPE',
             EQUIPMENT_STATUS   VARCHAR2(4) path 'EQUIPMENT_STATUS',
             EQUIPMENT_FULL_EMPTY   VARCHAR2(4) path 'EQUIPMENT_FULL_EMPTY',
             GROSS_WEIGHT   NUMBER(15,2) path 'GROSS_WEIGHT',
             GROSS_WEIGHT_UOM   VARCHAR2(3) path 'GROSS_WEIGHT_UOM',
             LENGTH_UOM   VARCHAR2(3) path 'LENGTH_UOM',
             OVERLENGTH_FRONT   NUMBER(14,4) path 'OVERLENGTH_FRONT',
             OVERLENGTH_BACK   NUMBER(14,4) path 'OVERLENGTH_BACK',
             OVERWIDTH_RIGHT   NUMBER(14,4) path 'OVERWIDTH_RIGHT',
             OVERWIDTH_LEFT   NUMBER(14,4) path 'OVERWIDTH_LEFT',
             OVERHEIGHT   NUMBER(14,4) path 'OVERHEIGHT',
             TEMPERATURE   NUMBER(6,2) path 'TEMPERATURE',
             TEMPERATURE_UOM   VARCHAR2(3) path 'TEMPERATURE_UOM',
             DAMAGE_CODE   VARCHAR2(4) path 'DAMAGE_CODE',
             DAMAGE_DESCRIPTION   VARCHAR2(70) path 'DAMAGE_DESCRIPTION',
             DAMAGE_AREA   VARCHAR2(35) path 'DAMAGE_AREA',
             HAZ_MAT_CODE   VARCHAR2(17) path 'HAZ_MAT_CODE',
             HAZ_MAT_CLASS   VARCHAR2(17) path 'HAZ_MAT_CLASS',
             HAZ_MAT_PAGE   VARCHAR2(17) path 'HAZ_MAT_PAGE',
             UNDG_NUMBER   NUMBER(4) path 'UNDG_NUMBER',
             TRANSPORT_STAGE   VARCHAR2(4) path 'TRANSPORT_STAGE',
             CONVEYANCE_REFERENCE   VARCHAR2(17) path 'CONVEYANCE_REFERENCE',
             TRANSPORT_MODE   VARCHAR2(4) path 'TRANSPORT_MODE',
             TRANSPORT_MEANS   VARCHAR2(4) path 'TRANSPORT_MEANS',
             CARRIER_CODE   VARCHAR2(17) path 'CARRIER_CODE',
             CARRIER_NAME   VARCHAR2(35) path 'CARRIER_NAME',
             CONVEYANCE_CODE   VARCHAR2(17) path 'CONVEYANCE_CODE',
             CONVEYANCE_NAME   VARCHAR2(35) path 'CONVEYANCE_NAME',
             SEAL_NUMBER_CU   VARCHAR2(17) path 'SEAL_NUMBER_CU',
             SEAL_NUMBER_CA   VARCHAR2(17) path 'SEAL_NUMBER_CA',
             SEAL_NUMBER_TO   VARCHAR2(17) path 'SEAL_NUMBER_TO',
             SEAL_NUMBER_SH   VARCHAR2(17) path 'SEAL_NUMBER_SH',
             TEXT_ID   VARCHAR2(4) path 'TEXT_ID',
             TEXT_CODE   VARCHAR2(4) path 'TEXT_CODE',
             TEXT_DESCRIPTION   VARCHAR2(70) path 'TEXT_DESCRIPTION',
             ATTACHED_EQPT1   VARCHAR2(17) path 'ATTACHED_EQPT1',
             EQUIPMENT_TYPE1   VARCHAR2(4) path 'EQUIPMENT_TYPE1',
             ATTACHED_EQPT2   VARCHAR2(17) path 'ATTACHED_EQPT2',
             EQUIPMENT_TYPE2   VARCHAR2(4) path 'EQUIPMENT_TYPE2',
             ATTACHED_EQPT3   VARCHAR2(17) path 'ATTACHED_EQPT3',
             EQUIPMENT_TYPE3   VARCHAR2(4) path 'EQUIPMENT_TYPE3',
             ATTACHED_EQPT4   VARCHAR2(17) path 'ATTACHED_EQPT4',
             EQUIPMENT_TYPE4   VARCHAR2(4) path 'EQUIPMENT_TYPE4',
           ) a;
  
  
   select xmltype(bfilename('XMLDIR','filelist.xml'),nls_charset_id('AL32UTF8'));
	from dual;
    cursor xml_file_list (FILELIST XMLTYPE) is
    select *
      from xmltable
           (
             '//file' passing filelist
             Columns
             filename varchar2(128) path '/file'
           );

    filelist := xmltype(bfilename('XMLDIR','filelist.xml'),nls_charset_id('AL32UTF8'));
    for file in xml_file_list(filelist) loop
      insert into EDI_TRANCASTION_HEADER values (xmltype(bfilename('XMLDIR',file.filename),nls_charset_id('AL32UTF8')));
    end loop;
END;
/ 
