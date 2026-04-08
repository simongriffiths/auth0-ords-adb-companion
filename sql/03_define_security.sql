prompt Defining ORDS security for the Auth0 + ORDS + ADB demo

-- This script protects the demo module with a scope-based ORDS privilege.
--
-- The companion Auth0 example issues the scope read:demo, so the ORDS
-- privilege name must also be read:demo when using a scope-based JWT profile.
-- Current ORDS guidance favors a schema-level or pool-level JWT profile for
-- external IdPs, with the JWT scope or scp claim containing ORDS privilege
-- names. This script therefore uses no role restriction.
--
-- If you switch to a role-based JWT profile, you would instead define ORDS
-- roles and map a JWT role claim to those role names.

begin
  ords.define_privilege(
    p_privilege_name => 'read:demo',
    p_roles          => owa.vc_arr(),
    p_patterns       => owa.vc_arr(),
    p_modules        => owa.vc_arr(),
    p_label          => 'Demo Read Privilege',
    p_description    => 'Protects the OAuth demo module for scope-based JWT access.',
    p_comments       => 'Demo privilege for the Auth0 + ORDS + ADB companion repository.'
  );

  ords.set_module_privilege(
    p_module_name    => 'oauth_demo.secured',
    p_privilege_name => 'read:demo'
  );

  commit;
end;
/
