local authorize  = require "authorize"
local BasePlugin = require "kong.plugins.base_plugin"
local cjson_safe = require "cjson.safe"

local kong = kong

local AcpHandler = BasePlugin:extend()

function AcpHandler:new()
   AcpHandler.super.new(self, "acp")

   -- This plugin should be executed after authentication plugins enabled on the Service or Route.
   -- The priority is set to execute this plugin after the response-ratelimiting plugin:
   -- https://docs.konghq.com/gateway-oss/2.4.x/plugin-development/custom-logic/#plugins-execution-order
   AcpHandler.PRIORITY = 880
   AcpHandler.VERSION  = "0.1"
end

function AcpHandler:access(conf)
   kong.log.debug("Executing plugin \"acp\": access")
   AcpHandler.super.access(self)

   -- https://www.lua.org/pil/8.4.html The pcall function calls its first argument in protected mode,
   -- so that it catches any errors while the function is running. If there are no errors, pcall returns true,
   -- plus any values returned by the call. Otherwise, it returns false, plus the error message.
   local ok, status = pcall(authorize, conf)

   -- Return 500 on exceptions
   if not ok then
      kong.log.err("Internal error: ", status)
      return kong.response.exit(500, cjson_safe.encode({ message = status }))
   end

   -- Return 403 unless ACP responded with OK.
   if status ~= 200 then
      kong.log.info("Access forbidden") -- The error.log message will include client, server and request info.
      return kong.response.exit(403, [[{"message":"Access Forbidden"}]])
   end

   -- ACP responded with OK (200)
   kong.log.debug("Access allowed")
end

return AcpHandler
