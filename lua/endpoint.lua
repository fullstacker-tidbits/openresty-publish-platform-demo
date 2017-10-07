local cjson = require "cjson"
local db = require "db"
local quote = ngx.quote_sql_str


-- endpoint data
local function get_all_endpoints()
    return db:sql(nil, "SELECT * FROM endpoint")
end


local function filter_endpoint(eid)
    return db:sql(nil, "SELECT * FROM endpoint WHERE eid = " .. eid)
end


local function update_endpoint(eid, fields)
    local sql = 'UPDATE TABLE endpoint SET '
    local field_sets = {}
    fields.eid = nil  -- disallow updating eid from request
    for k, v in pairs(fields) do
        table.insert(field_sets, quote(k) .. '=' .. quote(v))
    end
    sql = sql .. table.concat(field_sets, ',') .. ' WHERE eid = ' .. quote(eid)
    return db:sql(nil, sql)
end


local function create_endpoint(fields)
    local sql = 'INSERT INTO endpoint '
    local keys, vals = {}, {}
    fields.eid = nil  -- eid should be auto increment
    for k, v in pairs(fields) do
        table.insert(keys, quote(k))
        table.insert(vals, quote(v))
    end
    sql = sql .. '(' .. table.concat(k, ',') .. ') VALUE (' .. table.concat(v, ',') .. ')'
    return db:sql(nil, sql)
end


-- endpoint api
local endpoint = {}


function endpoint.get()
    local eid, res = tonumber(ngx.var.eid), nil
    if eid then res = filter_endpoint(eid)
    else res = get_all_endpoints() end
    return cjson.encode(res)
end


function endpoint.post()
    ngx.req.read_body()
    local eid = tonumber(ngx.var.eid)
    if eid then update_endpoint(eid, ngx.req.get_post_args())
    else create_endpoint(ngx.req.get_post_args()) end
end


function endpoint.head()
    return '{"msg": "you don\'t care what\'t returned, do ya?"}'
end


return {
    api = function()
        local method_name = ngx.req.get_method():lower()
        local method = endpoint[method_name]
        if not method then ngx.exit(ngx.HTTP_NOT_ALLOWED) end
        return ngx.say(method())
    end
}
