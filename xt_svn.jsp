create or replace and compile java source named xt_svn as
package com.xt_r;
/* Imports */
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.InputStreamReader;
import java.io.BufferedReader;

import java.sql.*;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.PreparedStatement;

import oracle.sql.*;
import oracle.jdbc.driver.OracleDriver;

/* Main class */
public class XT_SVN
{
/**
 * function ExportByOwnerTypeName
 */
  public static int ExportByOwnerTypeName(
                                  java.lang.String pPath,
                                  java.lang.String pOwner,
                                  java.lang.String pType,
                                  java.lang.String pName
  ) throws SQLException 
  {
         Connection conn = null;
         String typ="";
         String name="";
         String sTyp,sName,sText;
         FileWriter fwr = null;
         int ret = 0;
         try{
             conn = new OracleDriver().defaultConnection();
             PreparedStatement stmt = conn.prepareStatement
                                ("select s.type,s.name,s.text"
                                 +" from all_source s"
                                 +" where owner like ?"
                                 +" and s.type like ?"
                                 +" and s.name like ?"
                                 +" order by s.type,s.name,s.line");
                                 
             stmt.setString(1,pOwner);
             stmt.setString(2,pType);
             stmt.setString(3,pName);
             ResultSet rset = stmt.executeQuery();

             while (rset.next()) {
                 sTyp  = rset.getString(1);
                 sName = rset.getString(2);
                 sText = rset.getString(3);

                 if (!typ.equals(sTyp) || !name.equals(sName)){
                    typ = sTyp;
                    name = sName;
                    ret++;
                    if(fwr!=null)
                       fwr.close();
                    if (! (new File(pPath+'/'+typ)).exists() )
                       (new File(pPath+'/'+typ)).mkdir();
                    fwr = new FileWriter(new File(pPath+'/'+typ,name+".sql"));
                 }
                 fwr.write(sText);
             }
             rset.close();
             stmt.close();
             if (fwr!=null)
                  fwr.close();
         }catch(Exception e){
              throw new SQLException(e.getMessage());
         }finally{
             conn.close();
         }
         return ret;
  }
}
/
