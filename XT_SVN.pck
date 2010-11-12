create or replace package XT_SVN is
  REP_PATH varchar2(30):='/var/svn';
  SVN_PATH varchar2(30):='/usr/bin/svn';
  
  function export(
                  pPath varchar2 default REP_PATH, 
                  pOwner varchar2 default user, 
                  pType varchar2 default '%',
                  pName varchar2 default '%')
   return number;

  function svn_status(pPath varchar2 default REP_PATH)
   return varchar2_table;

  function svn_statuses(pPath varchar2 default REP_PATH)
   return svn_status_table pipelined;

  function svn_checkout( pUrl varchar2,
                         pPath varchar2 default REP_PATH,
                         pUser varchar2 default null,
                         pPass varchar2 default null)
   return varchar2_table;

  function svn_commit(   pPath varchar2 default REP_PATH,
                         pComment varchar2 default '',
                         pUser varchar2 default null,
                         pPass varchar2 default null )
   return varchar2_table;
   
  function svn( command varchar2)
   return varchar2_table;
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


end XT_SVN;
/
create or replace package body XT_SVN is
  function export(
                  pPath varchar2 default REP_PATH, 
                  pOwner varchar2 default user, 
                  pType varchar2 default '%',
                  pName varchar2 default '%')
   return number is
    begin
      return export_j(pPath,pOwner,pType,pName);
    end;

   
  function svn_status(pPath varchar2 default REP_PATH)
    return varchar2_table is
    begin
      return xt_shell.shell_exec(SVN_PATH||' status '||pPath,30000);
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
                         pPass varchar2 default null)
   return varchar2_table is
    begin
      return xt_shell.shell_exec( SVN_PATH
                        ||' checkout '
                        ||' '|| pUrl
                        ||' '|| pPath
                        ||' '|| case when pUser is not null then '--username '||pUser end
                        ||' '|| case when pPass is not null then '--password '||pPass end
                        ,30000
      );
    end svn_checkout;
    
  function svn_commit(   pPath varchar2 default REP_PATH,
                         pComment varchar2 default '',
                         pUser varchar2 default null,
                         pPass varchar2 default null)
   return varchar2_table is
    begin
      return xt_shell.shell_exec( SVN_PATH
                        ||' commit '
                        ||' '|| pPath
                        ||' '|| case when pUser is not null then '--username '||pUser end
                        ||' '|| case when pPass is not null then '--password '||pPass end
                        ||' -m "' || pComment || '"'
                        ,30000
      );
    end svn_commit;
    
  function svn( command varchar2)
   return varchar2_table is
    begin
      return xt_shell.shell_exec( SVN_PATH || command,30000 );
    end svn;
end XT_SVN;
/
