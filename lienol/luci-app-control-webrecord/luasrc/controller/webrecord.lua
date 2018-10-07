module("luci.controller.webrecord",package.seeall)
function index()
if not nixio.fs.access("/etc/config/webrecord")then
return
end
entry({"admin","control","webrecord"},cbi("webrecord"),_("上网记录"),15).dependent=true
entry({"admin","control","webrecord","status"},call("status")).leaf=true
end
function status()
local e={}
e.webrecord=luci.sys.call("iptables -L FORWARD |grep WEB_MONITOR >/dev/null")==0
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
