create or replace package XT_SVN_TEST is
  REP_PATH varchar2(30):='/var/svn';
  SVN_PATH varchar2(30):='/usr/bin/svn';
  
  function export(
                  pPath varchar2 default REP_PATH, 
                  pOwner varchar2 default user, 
                  pType varchar2 default '%',
                  pName varchar2 default '%'
    )return number;

  function svn_status(pPath varchar2 default REP_PATH)
    return varchar2_table;

  function svn_statuses(pPath varchar2 default REP_PATH)
    return svn_status_table pipelined;

  function svn_checkout( pUrl varchar2,
                         pPath varchar2 default REP_PATH,
                         pUser varchar2 default null,
                         pPass varchar2 default null
   )return varchar2_table;

  function shell_exec(pCommand varchar2)
    return varchar2_table
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_SVN.SQLshellExec(java.lang.String) return oracle.sql.ARRAY';

/**
 * java functions
 */
  function export_j(
                    pPath varchar2,
                    pOwner varchar2,
                    pType varchar2, 
                    pName varchar2
    )return number
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_SVN.ExportByOwnerTypeName(java.lang.String,java.lang.String,java.lang.String,java.lang.String) return int';


end XT_SVN_TEST;
/
create or replace package body XT_SVN_TEST is
  function export(
                  pPath varchar2 default REP_PATH, 
                  pOwner varchar2 default user, 
                  pType varchar2 default '%',
                  pName varchar2 default '%'
    )return number is
    begin
      return export_j(pPath,pOwner,pType,pName);
    end;

   
  function svn_status(pPath varchar2 default REP_PATH)
    return varchar2_table is
    begin
      return shell_exec(SVN_PATH||' status '||pPath);
    end;

  function svn_statuses(pPath varchar2 default REP_PATH)
    return svn_status_table pipelined is
      r svn_status_type:=svn_status_type(null,null,null);
    begin
      for c in (select column_value cv from table(svn_status(pPath)))
        loop
          r.status:=substr(c.cv,1,1);
          r.path:=regexp_substr(c.cv,'[^ ]+$',2);
          r.message:=c.cv;
          pipe row(r);
        end loop;
    end;
    
  function svn_checkout( pUrl varchar2,
                         pPath varchar2 default REP_PATH,
                         pUser varchar2 default null,
                         pPass varchar2 default null
   )return varchar2_table is
    begin
      return shell_exec( SVN_PATH
                        ||' checkout '
                        ||' '|| pUrl
                        ||' '|| pPath
                        ||' '|| case when pUser is not null then '--username '||pUser end
                        ||' '|| case when pPass is not null then '--password '||pPass end
      );
    end svn_checkout;
end XT_SVN_TEST;
/
