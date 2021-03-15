function load(cmd)
	if (cmd == 'disable') then
		gpio.wakeup(14, gpio.INTR_LOW)
		gpio.write(14, 0)
		load_disabled=true
	end
	if (cmd == 'enable' and low_voltage_disconnect_state == 1) then
		gpio.wakeup(14, gpio.INTR_HIGH)
		gpio.write(14, 1)
		load_disabled=false
	end
	return not (load_disabled or low_voltage_disconnect_state ~= 1)
end

local items={
	ftp='TCP_21_ftp.lua',
	telnet='TCP_23_telnet.lua',
	web='TCP_80_web.lua',
	mpptracker=mppttimer,
	load=load
}

local function startstopstatus(cmd,what)
	local item=items[what]
	if (item == nil) then
		return false
	end
	if (cmd == 'status') then
		if (type(item) == 'string') then
			return tcp_servers[item]
		end
		if (type(item) == 'userdata') then
			local running,mode=item:state()
			return running
		end
	end
	if (cmd == 'disable') then
		if (type(item) == 'string') then
			server_deactivate(item)
		end
		if (type(item) == 'userdata') then
			tmr:stop()	
		end
	end
	if (cmd == 'enable') then
		if (type(item) == 'string') then
			server_activate(item)
		end
		if (type(item) == 'userdata') then
			tmr:start()	
		end
	end
	if (type(item) == 'function') then
		return item(cmd)
	end
	return false
end

return function (info)
        if (not authenticated()) then
               return
        end
	local p=info.headers.path
	if (p == '/control/reboot') then
		send_response("Rebooting in 2 seconds. Will be back in 8 seconds.")
		reboottimer = tmr.create()
		reboottimer:register(2000, tmr.ALARM_SINGLE, function()
			node.restart()
		end)
                reboottimer:start()
		return
	end
	if (p:match('^/control/enable/')) then
		startstopstatus('enable',p:sub(17))
	end
	if (p:match('^/control/disable/')) then
		startstopstatus('disable',p:sub(18))
	end
	send_buffered(info.http_preable)
	for k,v in pairs(items) do
		local status='disabled'
		local command='enable'
		if (startstopstatus('status',k)) then
			status='enabled'
			command='disable'
		end
		send_buffered(k..":"..status.."<form method='post' action='/control/"..command..'/'..k.."'><input type='submit' value='"..command.."'/></form></br>\n")
	end
end
