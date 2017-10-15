local cjson = require("cjson")
local dbrun = require("db"):set_conf(nil)


local function refresh()
    local endpoints = ngx.shared.endpoints
    local res = dbrun("SELECT * FROM endpoint")
    for _, ep in ipairs(res) do
        endpoints:set(ep.endpoint, cjson.encode(ep), 60 * 60)
    end
    ngx.say('{"msg": "refreshed"}')
end


local function handle()
    local endpoints = ngx.shared.endpoints
    local endpoint_str = endpoints:get(ngx.var.endpoint)
    if not endpoint_str then ngx.exit(ngx.HTTP_NOT_FOUND) end
    local endpoint = cjson.decode(endpoint_str)
    local resource = '/' .. ngx.var.resource
    ngx.req.set_uri(resource, false)
    ngx.req.set_header('host', endpoint.hostname)
    ngx.var.resip = endpoint.ip
end


return {
    refresh = refresh,
    handle = handle,
}
