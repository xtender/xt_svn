XT_SVN oracle package
=============

Oracle package for work with subversion and git

Installation
-------
1. Install http://github.com/xtender/xt_shell
2. Execute scripts in this order:
* @svn_types.sql
* @xt_svn.jsp
* @XT_SVN.pck
3. Grant read/write/execute access (Examples in grants.sql)

Specifications
-------

Default variables
-------

* REP_PATH varchar2(30):='/var/svn';
* SVN_PATH varchar2(30):='/usr/bin/svn';

Functions
-------

    function export(
                  pPath varchar2 default REP_PATH, 
                  pOwner varchar2 default user, 
                  pType varchar2 default '%',
                  pName varchar2 default '%'
    )return number;

Exports sources to pPath where masks pOwner,pType,pName matched.
Returns number exported files.

    function svn_status(pPath varchar2 default REP_PATH)
        return varchar2_table;
        
Returns pPath-directory svn status as collection of varchar2.

    function svn_statuses(pPath varchar2 default REP_PATH)
      return svn_status_table pipelined;
      
Like previous function, but returns collection of objects.

    function svn_checkout( pUrl varchar2,
                         pPath varchar2 default REP_PATH,
                         pUser varchar2 default null,
                         pPass varchar2 default null)
     return varchar2_table;

Checkout from svn into pPath.

    function svn_commit(   pPath varchar2 default REP_PATH,
                         pComment varchar2 default '',
                         pUser varchar2 default null,
                         pPass varchar2 default null )
     return varchar2_table;

Commit changes into subversion

    function svn( command varchar2)
     return varchar2_table;

Executes "svn "||command


Examples
-------

### DML:

    select * from table(xt_svn.svn_statuses())

### Pl/SQL block:

    --Exporting sources
    declare 
      i number;
    begin
      i:=xt_svn.export(pOwner => 'XTENDER');
      dbms_output.put_line('Exported count = '||i);
    end;

    -- Getting statuses
    declare
      output varchar2_table;
    begin
      output:=xt_svn.svn_status();
      for c in output.first..output.last loop
        dbms_output.put_line(output(c));
      end loop;
    end;
    
