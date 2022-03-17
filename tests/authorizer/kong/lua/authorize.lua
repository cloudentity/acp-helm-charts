local cjson_safe = require "cjson.safe"
local http = require "resty.http"

-- transforms { k = v, ... } into { k = [ v, ... ] }
local function transform(map)
   local result = {}
   for k,v in pairs(map) do
      if type(v) == "table" then
         result[k] = v
      else
         result[k] = { v }
      end
   end
   return result
end

local function authorize(conf)

   local body = {
      method       = kong.request.get_method(),
      path         = kong.request.get_path(),
      headers      = transform(kong.request.get_headers()),
      query_params = transform(kong.request.get_query()),
      api_group    = conf.api_group_id,
   }
   local json_body = assert(cjson_safe.encode(body))

   local client = http.new()
   local resp, err = client:request_uri(conf.auth_url, {
        method = "POST",
        headers = {
          ["Content-Type"] = "application/json",
        },
        body = json_body,
        ssl_verify = conf.ssl_verify,
    })
   if err then
      error(err) -- raise an exception
   end

   return resp.status
end

return authorize
