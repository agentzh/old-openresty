drop schema if exists _register;
create schema _register;
create or replace view _register.tables(id, name, "user", description) as select s.oid, s.relname, s.nspname, t.description from (select p.oid, p.relname, q.nspname from pg_class p, pg_namespace q where p.relkind = 'r' and p.relnamespace = q.oid and q.nspname != 'pg_catalog') s left join pg_description t on (s.oid = t.objoid and t.objsubid = 0);

create or replace view _register.columns(id, sid, name, "type", "owner", description) as select s.oid, s.attnum, s.attname, pg_catalog.format_type(s.atttypid, s.atttypmod), s.relname, t.description from (select p.attnum, q.oid, q.relname, p.attname, p.atttypid, p.atttypmod from pg_attribute p, pg_class q where q.relkind = 'r' and p.attrelid = q.oid and p.attnum > 0 order by p.attnum asc) s left join pg_description t on (s.oid = t.objoid and s.attnum = t.objsubid);

-- comment on table
create or replace function public.xcomment(username text, module text, cmt text, out ret boolean)
returns boolean as $$
declare 
  id integer;
  cnt integer;
  sql text;
begin
  sql := 'select id from _register.tables where "user" = '''||username||''' and name = '''||module||'''';
  raise notice 'sql %', sql;
  execute sql into id;
  if id is null then 
    ret := false;
    return;
  end if;

  sql := 'select count(*) from pg_description where objsubid = 0 and objoid = '||id;
  execute sql into cnt;
  if cnt != 0 then 
    sql :=  'update pg_description set description = '''||cmt||''' where objsubid = 0 and objoid = '||id;
  else 
    sql :=  'comment on table '||username||'.'||module||' is '''||cmt||'''';
  end if;
  raise notice 'sql %', sql;
  execute sql;
  ret := true;
  return; 
end;
$$ language plpgsql;

-- comment on columns
create or replace function public.xcomment(username text, module text, col text, cmt text, out ret boolean)
returns boolean as $$
declare 
  id integer;
  sid integer;
  cnt integer;
  sql text;
begin
  sql :=  'select a.id,b.sid from _register.tables a, _register.columns b where b.name = '''||col||''' and a.id = b.id and a.user = '''||username||''' and b.owner = '''||module||'''';
  raise notice 'sql %', sql;
  execute sql into id, sid;
  if id is null or sid is null then 
    ret := false;
    return;
  end if;

  sql := 'select count(*) from pg_description where objoid = '||id||' and objsubid = '||sid;
  raise notice 'sql %', sql;
  execute sql into cnt;
  if cnt != 0 then 
    sql := 'update pg_description set description = '''||cmt||''' where objoid = '||id||' and objsubid = '||sid;
  else 
    sql :=  'comment on column '||username||'.'||module||'.'||col||' is '''||cmt||'''';
  end if;
  raise notice 'sql %', sql;
  execute sql;
  ret := true;
  return; 
end;
$$ language plpgsql;

-- uncomment
create or replace function public.xuncomment(username text, module text, out ret boolean)
returns boolean as $$
declare
  id integer;
  sql text;
begin
  sql := 'select id from _register.tables where "user" = '''||username||''' and name = '''||module||'''';
  raise notice 'sql %', sql;
  execute sql into id;
  if id is null then
    ret := false;
    return;
  end if;
  sql := 'delete from pg_description where objoid = '||id;
  raise notice 'sql %', sql;
  execute sql;
  ret := true;
  return;
end;
$$ language plpgsql;
