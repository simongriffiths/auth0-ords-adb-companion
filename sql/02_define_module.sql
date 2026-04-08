prompt Defining the secured ORDS module for the Auth0 + ORDS + ADB demo

-- This script creates one module, one template, and one GET handler.
-- The defaults align with:
--   ORDS_SCHEMA=demo
--   ORDS_PATH=oauth-demo/status

begin
  ords.define_module(
    p_module_name    => 'oauth_demo.secured',
    p_base_path      => 'oauth-demo/',
    p_items_per_page => 0,
    p_status         => 'PUBLISHED',
    p_comments       => 'Secured ORDS module for the Auth0 companion repository.'
  );

  ords.define_template(
    p_module_name => 'oauth_demo.secured',
    p_pattern     => 'status'
  );

  ords.define_handler(
    p_module_name    => 'oauth_demo.secured',
    p_pattern        => 'status',
    p_method         => 'GET',
    p_source_type    => ords.source_type_collection_feed,
    p_items_per_page => 0,
    p_source         => q'[
      select
        id,
        message,
        to_char(
          created_at,
          'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'
        ) as created_at
      from demo_secure_messages
      order by id
    ]'
  );

  commit;
end;
/
