local cjson = require 'cjson'


return {
    handle = function()
        ngx.say('================ URI ====================')
        ngx.say(ngx.var.request_uri .. '\n\n')
        ngx.say('================ Headers ================')
        for k, v in pairs(ngx.req.get_headers()) do
            ngx.say(k .. ': ' .. v)
        end
        ngx.say('\n\n')
        ngx.say('================ Body ===================')
        ngx.req.read_body()
        ngx.say(ngx.req.get_body_data())
    end
}
