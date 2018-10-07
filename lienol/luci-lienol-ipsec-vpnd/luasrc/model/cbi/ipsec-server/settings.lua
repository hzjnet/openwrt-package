local s=require"luci.sys"
local net = require "luci.model.network".init()
local ifaces = s.net:devices()
local m,s,o
--require("luci.tools.webadmin")

mp = Map("ipsec", translate("IPSec VPN Server"))
mp.description = translate("IPSec VPN connectivity using the native built-in VPN Client on iOS or Andriod (IKEv1 with PSK and Xauth)")
mp.template="ipsec-server/index"

--local pid = luci.util.exec("/usr/bin/pgrep ipsec")
--if pid == "" then
--start = s:option(Button, "_start", translate("Start"),translate("<span style='color:red'>Saving and applying does not execute the script, so start the service yourself</span>"))
--start.inputstyle = "apply"
--function start.write(self, section)
--message=luci.util.exec("/etc/ipsecvpn start")
--luci.util.exec("/etc/init.d/firewall restart >/dev/null 2>&1 &")
--luci.http.redirect(luci.dispatcher.build_url("admin", "vpn", "ipsec-server", "settings"))
--end
--else
--stop = s:option(Button, "_stop", translate("Stop"),translate("<span style='color:red'>Saving and applying does not execute the script, so stop the service yourself</span>"))
--stop.inputstyle = "reset"
--function stop.write(self, section)
--luci.util.exec("/etc/ipsecvpn stop")
--luci.http.redirect(luci.dispatcher.build_url("admin", "vpn", "ipsec-server", "settings"))
--end
--end

s=mp:section(TypedSection,"service")
s.anonymous=true
o=s:option(DummyValue,"ipsec-server_status",translate("Current Condition"))
o.template="ipsec-server/ipsec-server-vpnd"
enabled = s:option(Flag, "enabled", translate("Enable"))
enabled.default = 0
enabled.rmempty = false

clientip = s:option(Value, "clientip", translate("VPN Client IP"))
clientip.datatype = "ip4addr"
clientip.description = translate("VPN Client reserved started IP addresses with the same subnet mask")
clientip.optional = false
clientip.rmempty = false

clientdns = s:option(Value, "clientdns", translate("VPN Client DNS"))
clientdns.datatype = "ip4addr"
clientdns.description = translate("DNS using in VPN tunnel.Set to the router's LAN IP is recommended")
clientdns.optional = false
clientdns.rmempty = false

secret = s:option(Value, "secret", translate("Secret Pre-Shared Key"))
secret.password = true

o=s:option(ListValue,"export_interface",translate("Export Interface"),translate("Specify interface forwarding traffic.<br>Choosing none client will not get online."))
o:value("none","none")
for _, iface in ipairs(ifaces) do
--	if not (iface == "lo" or iface:match("^ifb.*") or iface:match("gre*")) then
--		local nets = net:get_interface(iface)
--		nets = nets and nets:get_networks() or {}
--		for k, v in pairs(nets) do
--			nets[k] = nets[k].sid
--		end
--		nets = table.concat(nets, ",")
--		o:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
--	end
	if (iface:match("^br-*") or iface:match("^eth*") or iface:match("^pppoe.*") or iface:match("wlan*")) then
		local nets = net:get_interface(iface)
		nets = nets and nets:get_networks() or {}
		for k, v in pairs(nets) do
			nets[k] = nets[k].sid
		end
		nets = table.concat(nets, ",")
		o:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
	end
end


function mp.on_save(self)
    require "luci.model.uci"
    require "luci.sys"

	local have_ike_rule = false
	local have_ipsec_rule = false
	local have_ah_rule = false
	local have_esp_rule = false

    luci.model.uci.cursor():foreach('firewall', 'rule',
        function (section)
			if section.name == 'ike' then
				have_ike_rule = true
			end
			if section.name == 'ipsec' then
				have_ipsec_rule = true
			end
			if section.name == 'ah' then
				have_ah_rule = true
			end
			if section.name == 'esp' then
				have_esp_rule = true
			end
        end
    )

	if not have_ike_rule then
		local cursor = luci.model.uci.cursor()
		local ike_rulename = cursor:add('firewall','rule')
		cursor:tset('firewall', ike_rulename, {
			['name'] = 'ike',
			['target'] = 'ACCEPT',
			['src'] = 'wan',
			['proto'] = 'udp',
			['dest_port'] = 500
		})
		cursor:save('firewall')
		cursor:commit('firewall')
	end
  if not have_ipsec_rule then
		local cursor = luci.model.uci.cursor()
		local ipsec_rulename = cursor:add('firewall','rule')
		cursor:tset('firewall', ipsec_rulename, {
			['name'] = 'ipsec',
			['target'] = 'ACCEPT',
			['src'] = 'wan',
			['proto'] = 'udp',
			['dest_port'] = 4500
		})
		cursor:save('firewall')
		cursor:commit('firewall')
	end
	if not have_ah_rule then
		local cursor = luci.model.uci.cursor()
		local ah_rulename = cursor:add('firewall','rule')
		cursor:tset('firewall', ah_rulename, {
			['name'] = 'ah',
			['target'] = 'ACCEPT',
			['src'] = 'wan',
			['proto'] = 'ah'
		})
		cursor:save('firewall')
		cursor:commit('firewall')
	end
  if not have_esp_rule then
		local cursor = luci.model.uci.cursor()
		local esp_rulename = cursor:add('firewall','rule')
		cursor:tset('firewall', esp_rulename, {
			['name'] = 'esp',
			['target'] = 'ACCEPT',
			['src'] = 'wan',
			['proto'] = 'esp'
		})
		cursor:save('firewall')
		cursor:commit('firewall')
	end
	
		
end

return mp