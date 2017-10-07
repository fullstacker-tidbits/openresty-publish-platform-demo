local cjson = require 'cjson'

ngx.say('================ URI ====================')
ngx.say(ngx.var.request_uri)

ngx.say('================ Headers ================')
ngx.say(cjson.encode(ngx.req.get_headers()))

ngx.say('================ Body ===================')
ngx.req.read_body()
ngx.say(cjson.encode(ngx.req.get_post_args()))
