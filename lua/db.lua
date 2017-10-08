local mysql = require("resty.mysql")


local DEFAULT_DBCONF = {
    host = os.getenv("MYSQL_PORT_3306_TCP_ADDR"),
    port = 3306,
    user = "root",
    password = "app",
    database = "app",
    pool = "default",
}


local M = {
	SUCCESS = 0,
	CONNECTION_ERROR = 1,
	QUERY_ERROR = 2,
}


--[[
@params dbconf: DB conf table, format:platform_db = {
	host = "---",
	port = ---,
	user = "---",
	password = "---",
	database = "---",
	pool = "---",
},
@params sql: sql used to query
@return (result_table, return_code)
@return return_code: -1: ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE); 0: no result; 1: success
]]
function M:sql(dbconf, sql)
	local db, ok, res, err, errcode, sqlstate
	db, err = mysql:new()
	db:set_timeout(5000)
	ok, err, errcode, sqlstate = db:connect(dbconf)
	if not ok then
		local msg = table.concat({"Failed to connect " .. dbconf.pool, errcode or "-", err or "-", sql}, "|")
		ngx.log(ngx.ERR, msg)
		return {}, self.CONNECTION_ERROR
	end

	res, err, errcode, sqlstate = db:query(sql)
	if not res then
		local msg = table.concat({"Failed to execute", errcode or "-", err, sql}, "|")
		ngx.log(ngx.ERR, msg)
		return {}, self.QUERY_ERROR
    else
        ok, err = db:set_keepalive(10000, 10)  -- pool the connection
        return res, self.SUCCESS
    end
end


function M:set_conf(dbconf)
    local dbconf = dbconf or DEFAULT_DBCONF
    return function(sql)
        return self:sql(dbconf, sql)
    end
end


return M
