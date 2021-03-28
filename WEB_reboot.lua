return function (info)
        if (not authenticated()) then
               return
        end
		send_response("Rebooting in 1 second. Will be back in 7 seconds.")
		reboottimer = tmr.create()
		reboottimer:register(1000, tmr.ALARM_SINGLE, function()
			node.restart()
		end)
                reboottimer:start()
		return
end