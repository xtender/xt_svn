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

//import java.util.concurrent.TimeoutException;
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
/**
 * Function shellExec
 * @param String shell command
 * @return String
 */
  public static java.lang.String shellExec (String command)
    throws SQLException 
  {
      StringBuffer result;
      OutputStream stdin = null;
      InputStream stderr = null;
      InputStream stdout = null;
      String line;
      try{
          result = new StringBuffer();
          Process process = Runtime.getRuntime().exec(command);
          stdin = process.getOutputStream ();
          stderr = process.getErrorStream ();
          stdout = process.getInputStream ();
          
          BufferedReader brCleanUp = 
                         new BufferedReader (
                             new InputStreamReader (stdout,"UTF-8"));
          while ((line = brCleanUp.readLine ()) != null) {
            result.append(line).append("\n");
          }
          brCleanUp.close();
          
          brCleanUp = 
            new BufferedReader (new InputStreamReader (stderr,"UTF-8"));
          while ((line = brCleanUp.readLine ()) != null) {
            result.append("STDERR:\t").append(line).append("\n");
          }
          brCleanUp.close();
          // add timeout 
            Worker worker = new Worker(process);
            worker.start();
            try {
              worker.join(5000);
              if (worker.exit == 0)
                return result.toString();
              else
                throw new InterruptedException("Timeout");
            } catch(InterruptedException ex) {
              worker.interrupt();
              Thread.currentThread().interrupt();
              throw ex;
            } finally {
              process.destroy();
            }
          //end time
      }catch(Exception e){
           throw new SQLException(e.getMessage());
      }
  }
/**
 * Function shellExec
 * @param String shell command
 * @return String
 */
  public static oracle.sql.ARRAY SQLshellExec (String command)
    throws SQLException 
  {
    String shellResult = shellExec(command);
    Connection conn = new OracleDriver().defaultConnection();         
         ArrayDescriptor descriptor =
            ArrayDescriptor.createDescriptor("VARCHAR2_TABLE", conn );
    oracle.sql.ARRAY outArray = new oracle.sql.ARRAY(descriptor,conn,shellResult.split("\n"));
    return outArray;
  }
/**
 * Timer
 */
  private static class Worker extends Thread {
    private final Process process;
    private int exit;
    private Worker(Process process) {
      this.process = process;
    }
    public void run() {
      try { 
        exit = process.waitFor();
      } catch (InterruptedException ignore) {
        return;
      }
    }  
  }
}
/
