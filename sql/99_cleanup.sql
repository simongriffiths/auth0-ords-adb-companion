prompt Cleaning up demo artifacts for the Auth0 + ORDS + ADB demo

-- Cleanup removes the schema-level JWT profile, demo privilege, module, and
-- table where possible. The current demo uses a scope-based privilege without
-- ORDS roles.

begin
  begin
    ords_security.delete_jwt_profile;
  exception
    when others then
      null;
  end;

  begin
    ords.delete_privilege(
      p_name => 'read:demo'
    );
  exception
    when others then
      null;
  end;

  begin
    ords.delete_module(
      p_module_name => 'oauth_demo.secured'
    );
  exception
    when others then
      null;
  end;

  commit;
end;
/

begin
  execute immediate 'drop table demo_secure_messages purge';
exception
  when others then
    if sqlcode = -942 then
      null;
    else
      raise;
    end if;
end;
/
