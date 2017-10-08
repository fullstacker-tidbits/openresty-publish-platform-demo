local cjson = require("cjson")
local dbrun = require("db"):set_conf(nil)
local quote = ngx.quote_sql_str


-- a dirty utility function to backtick quote a column name
local function btquote(val)
    local sqquoted = quote(val)
    return "`" .. sqquoted:sub(2, -2) .. "`"
end


-- endpoint data
local data = {}

function data.get_all()
    return dbrun("SELECT * FROM endpoint")
end

function data.filter(eid)
    return dbrun("SELECT * FROM endpoint WHERE eid = " .. eid)
end

function data.update(eid, fields)
    local sql = "UPDATE endpoint SET "
    local field_sets = {}
    for k, v in pairs(fields) do
        table.insert(field_sets, btquote(k) .. "=" .. quote(v))
    end
    sql = sql .. table.concat(field_sets, ",") .. " WHERE eid = " .. quote(eid)
    return dbrun(sql)
end


function data.create(fields)
    local sql = "INSERT INTO endpoint "
    local keys, vals = {}, {}
    for k, v in pairs(fields) do
        table.insert(keys, btquote(k))
        table.insert(vals, quote(v))
    end
    sql = sql .. "(" .. table.concat(keys, ",") .. ") VALUES (" .. table.concat(vals, ",") .. ")"
    return dbrun(sql)
end


-- endpoint api
local api = {}

function api.get()
    local eid, res = tonumber(ngx.var.eid), nil
    if eid then res = filter_endpoint(eid)
    else res = data.get_all() end
    return cjson.encode(res)
end

function api.post()
    ngx.req.read_body()
    local eid = tonumber(ngx.var.eid)
    local fields = cjson.decode(ngx.req.get_body_data())
    fields.eid = nil  -- eid must be auto increment, and no direct update
    if eid then data.update(eid, fields)
    else data.create(fields) end
end

function api.head()
    return '{"msg": "you don\'t care what\'s returned, do ya?"}'
end


-----

return {
    handle = function()
        local method_name = ngx.req.get_method():lower()
        local method = api[method_name]
        if not method then ngx.exit(ngx.HTTP_NOT_ALLOWED) end
        return ngx.say(method())
    end
}
