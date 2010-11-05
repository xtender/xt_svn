begin
  dbms_java.grant_permission(user, 'SYS:java.io.FilePermission', '<<ALL FILES>>', 'execute' );
  /* or
  dbms_java.grant_permission( user, 'java.io.FilePermission', '/var/svn/*', 'read,write' );
  
  dbms_java.grant_permission( user, 'java.io.FilePermission', '/var/svn/PROCEDURE/*', 'read,write' );
  dbms_java.grant_permission( user, 'java.io.FilePermission', '/var/svn/PACKAGE/*', 'read,write' );
  dbms_java.grant_permission( user, 'java.io.FilePermission', '/var/svn/PACKAGE BODY/*', 'read,write' );
  dbms_java.grant_permission( user, 'java.io.FilePermission', '/var/svn/TYPE BODY/*', 'read,write' );
  dbms_java.grant_permission( user, 'java.io.FilePermission', '/var/svn/TRIGGER/*', 'read,write' );
  dbms_java.grant_permission( user, 'java.io.FilePermission', '/var/svn/FUNCTION/*', 'read,write' );
  dbms_java.grant_permission( user, 'java.io.FilePermission', '/var/svn/JAVA SOURCE/*', 'read,write' );
  dbms_java.grant_permission( user, 'java.io.FilePermission', '/var/svn/TYPE/*', 'read,write' );
*/
 commit;
end;
/* permissions list:
select * from dba_java_policy p where p.grantee=user
*/

/* Revoke and delete_permission:
dbms_java.revoke_permission(user, 'java.io.FilePermission','/var/svn/JAVA SOURCE/*', 'read,write');
dbms_java.delete_permission(223);
*/
