-- Getting actual permissions list to user:
select * from dba_java_policy p where type_name='java.io.FilePermission' and p.grantee=user;
---------------------------------------------------------
---------------------------------------------------------
begin
-- Granting to executing svn
  dbms_java.grant_permission( 'PUBLIC', 'SYS:java.io.FilePermission', '/usr/bin/svn', 'execute' );

--Granting access to all users to read/write/delete in svn directory
  dbms_java.grant_permission( 'PUBLIC', 'java.io.FilePermission', '/var/svn/-', 'read,write,delete' );
  commit;
end;

--Or you could grant access to all with:
--  dbms_java.grant_permission( user, 'SYS:java.io.FilePermission', '<<ALL FILES>>', 'read,write,execute' );
---------------------------------------------------------
  -- Revoke and delete_permission:
begin
  for c in (select * from dba_java_policy p where p.grantee=user and type_name='java.io.FilePermission') loop
      dbms_java.revoke_permission(c.grantee, 'java.io.FilePermission',c.name, c.action);
      dbms_java.delete_permission(c.seq);
  end loop;
  commit;
end;
---------------------------------------------------------
