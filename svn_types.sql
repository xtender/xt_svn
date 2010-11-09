create or replace type svn_status_type is object(
       status  varchar2(4000),
       path    varchar2(4000),
       message varchar2(4000)
  );
/
create or replace type svn_status_table is table of svn_status_type;
/