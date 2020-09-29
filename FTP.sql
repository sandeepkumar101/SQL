declare
v_ftp_conn          UTL_TCP.connection;
v_ftp_conn1         UTL_TCP.connection;
v_error_message     varchar2(1000);
v_Array             pkg_edi_ftp.t_string_table := pkg_edi_ftp.t_string_table();
l_list          pkg_edi_ftp.t_string_table := pkg_edi_ftp.t_string_table();
l_reply_code    VARCHAR2(3) := NULL;    
  
  
 v_remote_dir                  varchar2(1000) :=    '/db4/edi/dev/dtd';
 l_conn        UTL_TCP.connection;
 m_conn        UTL_TCP.connection;
 p_conn        UTL_TCP.connection;
 
Begin

    v_ftp_conn := pkg_edi_ftp.login('10.32.11.170',
                                          '21',
                                          'oracle',
                                          'oracle2008');
                                          
   pkg_edi_ftp.ascii(v_ftp_conn);
              
   pkg_edi_ftp.send_command(v_ftp_conn, 'CWD ' || v_remote_dir, TRUE);
  
   
   begin
     p_conn := pkg_edi_ftp.get_passive(v_ftp_conn);
     pkg_edi_ftp.send_command(v_ftp_conn, 'NLST ', TRUE);

     BEGIN
       LOOP
         l_list.extend;
         l_list(l_list.last) := UTL_TCP.get_line(p_conn, TRUE);
       END LOOP;
       EXCEPTION
         WHEN UTL_TCP.END_OF_INPUT THEN
           NULL;
     END;
    
     l_list.delete(l_list.last);
     v_Array := l_list;
  v_ftp_conn1 := pkg_edi_ftp.login('10.32.11.170',
                                          '21',
                                          'oracle',
                                          'oracle2008');
                                          
     pkg_edi_ftp.ascii(v_ftp_conn1); 
  pkg_edi_ftp.send_command(v_ftp_conn1, 'CWD ' || v_remote_dir, TRUE);        
     
  FOR i IN 1 .. v_Array.COUNT LOOP

       begin
             
       pkg_edi_ftp.get(v_ftp_conn1,v_Array(i)  , 'EQPIN', v_Array(i));  
                           
       end;
                                 
       INSERT INTO EDI_DIRECTORY_LIST
            (API_CODE,
             FILE_NAME,
             RECORD_STATUS,
             RECORD_ADD_USER,
             RECORD_ADD_DATE)
          VALUES
            ('CRS', v_Array(i), 'A', 'EDI', SYSDATE);
        
          COMMIT;
  
       DBMS_OUTPUT.PUT_LINE(v_Array(i));
      
     END LOOP;
  
  pkg_edi_ftp.logout(v_ftp_conn1);  
   end;
      
   pkg_edi_ftp.logout(v_ftp_conn);
   utl_tcp.close_all_connections;  
end;












---------------------------------------------------


declare
		v_from_file                     varchar2(200);
		v_ftp_conn                      UTL_TCP.connection;
		v_ftp_connl                     UTL_TCP.connection;
		v_error_message                 varchar2(1000);
		v_Array                         pkg_edi_ftp.t_string_table := pkg_edi_ftp.t_string_table();
		v_remote_dir                    varchar2(512) := '/db4/edi/dev/eqp_out/';

		Begin
		  v_ftp_conn := pkg_edi_ftp.login('10.32.11.170',
		                                          '21',
		                                          'oracle',
		                                          'oracle2008');
		pkg_edi_ftp.send_command(v_ftp_conn, 'CWD ' || v_remote_dir, TRUE);
        pkg_edi_ftp.nlst(v_ftp_conn,'', v_Array);
		  pkg_edi_ftp.logout(v_ftp_conn);
		  utl_tcp.close_all_connections;
		  DBMS_OUTPUT.PUT_LINE(to_char(v_Array.COUNT));
		     FOR i IN 1 .. v_Array.COUNT LOOP
			  begin
		       v_ftp_connl := pkg_edi_ftp.login('10.32.11.170',
		                                          '21',
		                                          'oracle',
		                                          'oracle2008');
		       pkg_edi_ftp.binary(v_ftp_connl);
			   DBMS_OUTPUT.PUT_LINE(v_Array(i));
		       pkg_edi_ftp.get(v_ftp_connl, v_remote_dir||v_Array(i), 'EQPIN', v_Array(i));
		      end;

		      INSERT INTO EDI_DIRECTORY_LIST
		            (API_CODE,
		             FILE_NAME,
		             RECORD_STATUS,
		             RECORD_ADD_USER,
		             RECORD_ADD_DATE)
		          VALUES
		            ('EQP_IN', v_Array(i), 'A', 'EDI', SYSDATE);

			   COMMIT;

		       pkg_edi_ftp.delete(v_ftp_connl, v_remote_dir||v_Array(i));
		       pkg_edi_ftp.logout(v_ftp_connl);
		    END LOOP;
		  utl_tcp.close_all_connections;
		end;

		
		select * from EDI_DIRECTORY_LIST
		
		delete from EDI_DIRECTORY_LIST
		
		commit;