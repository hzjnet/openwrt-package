local e=require"luci.sys"
local a,e,t
a=Map("webrecord",translate("上网记录"),translate("查看客户端浏览的网址和搜索记录。"))
a.template="webrecord/index"
e=a:section(TypedSection,"basic",translate("Running Status"))
e.anonymous=true
t=e:option(DummyValue,"webrecord_status",translate("当前状态"))
t.template="webrecord/webrecord"
t.value=translate("Collecting data...")
e=a:section(TypedSection,"basic",translate("基本设置"))
e.anonymous=true
t=e:option(Flag,"enable",translate("启用Web使用监视"))
t.rmempty=false
t=e:option(Value,"max_domains",translate("保存网址记录的数量"))
t.default="100"
t.rmempty=false
t=e:option(Value,"max_searches",translate("保存搜索操作的数量"))
t.default="100"
t.rmempty=false
e=a:section(TypedSection,"basic")
e.anonymous=true
e:tab("weburllog",translate("网址记录"))
e:tab("searchlog",translate("搜索记录"))
local t="/proc/webmon_recent_domains"
tvlog=e:taboption("weburllog",TextValue,"sylogtext")
tvlog.rows=30
tvlog.readonly="readonly"
tvlog.wrap="off"
function tvlog.cfgvalue(e,e)
sylogtext=""
if t and nixio.fs.access(t)then
sylogtext=luci.sys.exec("tail -n 100 %s"%t)
end
return sylogtext
end
tvlog.write=function(e,e,e)
end
local t="/proc/webmon_recent_searches"
tvlog=e:taboption("searchlog",TextValue,"sylogtext")
tvlog.rows=30
tvlog.readonly="readonly"
tvlog.wrap="off"
function tvlog.cfgvalue(e,e)
sylogtext=""
if t and nixio.fs.access(t)then
sylogtext=luci.sys.exec("tail -n 100 %s"%t)
end
return sylogtext
end
tvlog.write=function(e,e,e)
end
return a
