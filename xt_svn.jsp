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
         String owner="";
         String typ="";
         String name="";
         String sOwner,sTyp,sName,sText;
         FileWriter fwr = null;
         int ret = 0;
         try{
             conn = new OracleDriver().defaultConnection();
             PreparedStatement stmt = conn.prepareStatement
                                ("select s.owner, s.type,s.name,s.text"
                                 +" from all_source s"
                                 +" where s.owner like ?"
                                 +" and s.type like ?"
                                 +" and s.name like ?"
                                 +" order by s.type,s.name,s.line");
                                 
             stmt.setString(1,pOwner);
             stmt.setString(2,pType);
             stmt.setString(3,pName);
             ResultSet rset = stmt.executeQuery();

             while (rset.next()) {
                 sOwner= rset.getString(1);
                 sTyp  = rset.getString(2);
                 sName = rset.getString(3);
                 sText = rset.getString(4);

                 if (!owner.equals(sOwner) || !typ.equals(sTyp) || !name.equals(sName)){
                    owner = sOwner;
                    typ = sTyp;
                    name = sName;
                    ret++;
                    if(fwr!=null)
                       fwr.close();
                    if (! (new File(pPath+'/'+owner)).exists() )
                       (new File(pPath+'/'+owner)).mkdir();
                    if (! (new File(pPath+'/'+owner+'/'+typ)).exists() )
                       (new File(pPath+'/'+owner+'/'+typ)).mkdir();
                    fwr = new FileWriter(new File(pPath+'/'+owner+'/'+typ,name+".sql"));
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
