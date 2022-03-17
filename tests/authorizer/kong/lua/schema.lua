local typedefs = require "kong.db.schema.typedefs"

return {
   name = "acp",
   fields = {
      {  -- this plugin will only be applied to Services or Routes
         consumer = typedefs.no_consumer
      },
      {  -- this plugin will only run within Nginx HTTP module
         protocols = typedefs.protocols_http
      },
      {
         config = {
            type = "record",
            fields = {
               {
                  auth_url = typedefs.url { required = true },
               },
               {
                  api_group_id = { type = "string", required = true },
               },
               {
                  ssl_verify = { type = "boolean", default = true },
               },
            },
         },
      },
   },
}
