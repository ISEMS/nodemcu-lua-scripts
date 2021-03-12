if webkey == nil then webkey = "empty" end

if encrypted_webkey == true then  randomstring,  webkeyhash = cryptokey (webkey) end

if encrypted_webkey == false or encrypted_webkey == nil then webkeyhash = webkey randomstring = "Encryption not enabled." end

return function(conn)
    http_preamble = "HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n"

	conn:on("receive", function(sck, payload)

                -- Send the HTTP response.
                function send_response(response)
                    sck:send(http_preamble .. response)
                end

                -- HTTP method.
                method_post = string.match(payload, "POST")

                -- Authentication key.
                key  = string.match(payload, webkeyhash)

                -- Define resources.
                csv  = string.match(payload, ".log")
                help  = string.match(payload, "help")
                rand = string.match(payload, "random")

                -- Define actions.
                ftp  = string.match(payload, "ftp+")
                rst  = string.match(payload, "reboot+")
                tel  = string.match(payload, "telnet+")
                sh  = string.match(payload, "shell+")
                mppt_start  = string.match(payload, "mpptstart+")
                load_off = string.match(payload, "loadoff+")
                load_on = string.match(payload, "loadon+")

                -- Serve HTML index page.
                if csv == nil and rand == nil and ftp == nil and rst == nil and tel == nil and sh == nil and mppt_start == nil and help == nil and load_off == nil and load_on == nil then
                    print("INDEX")
                    -- "pagestring" contains the main splash screen generated within "mp2.lua".
                    send_response(pagestring)
                    return
                end

                -- Serve "random" page.
                if rand ~= nil then
                    print("RANDOM")
                    send_response(randomstring)
                    return
                end

                -- Serve help page.
                if help ~= nil then
                    print("HELP")
                    help_page = [[
                        <html>
                        Commands on this device can be executed remotely by sending HTTP requests + secret-key.
                        <br><br>

                        Assuming your secret-key is "secret123", if you request <b>http://device/ftp+secret123</b>
                        the system will start a FTP server and stop the main program loop to free up CPU and RAM resources.
                        <br><br>

                        Now, you can upload a customized version of <b>config.lua</b> via FTP
                        with the default FTP user-password combination <b>root / pass123</b> like
                        <pre>lftp -u root,pass123 IP-or-URL-of-FF-ESP32-device -c 'put config.lua'</pre>
                        <br><br>

                        All passwords are stored in <b>config.lua</b> and should be changed before deploying the system, of course.
                        Just reboot the device to apply the new configuration.
                        <br><br>

                        <h3>Commands</h3>
                        <b>/ftp+key</b> (starts ftp server and pauses the main MPPT program)<br>
                        <b>/reboot+key</b><br><b>/telnet+key</b> (starts a password-protected (either webkey or ftppass) telnet LUA/Shell command line interface at port 23). Use root as username for shell and lua for lua interface<br>
                        <b>/mpptstart+key</b> (restarts the main mppt program. It is automatically paused when FTP starts in order to save CPU and RAM.)<br>
                        <b>/loadoff+key</b> Turn load off.<br>
                        <b>/loadon+key</b> Turn load on.<br>

                        <h3>Caveats</h3>
                        Use your passwords only over a encrypted WiFi and if you trust the network.
                        FTP and HTTP keys can be sniffed easily, as they are sent unencrypted.
                        Links are case sensitive. Remember that this is a tiny device with very limited ressources.
                        If all features are enabled, the device might occasionally run out of memory, crash and reboot.

                        </html>
                        ]]
                    send_response(help_page)
                    return
                end

                -- Serve CSV log.
                if csv ~= nil then
                    print("CSV")
                    send_response(csvlog)
                    return
                end


                -- Invoke device commands.

                
                --[[
                -- Protect against invalid HTTP method.
                if method_post == nil then
                    send_response("Will not execute the command. Reason: Invoking commands needs HTTP POST.")
                    return
                end]]

                -- Protect against unauthorized access.
                if key == nil then
                    print("DENIED")
                    send_response("Will not execute the command. Reason: webkey for admin command is incorrect or missing.")
                    return
                end

                
                if ftp ~= nil and ftp_runs == 1 then
                    print("FTP")
                    send_response("<html>FTP server already running.</html>")
                    
                end
           
           
                if ftp ~= nil and ftp_runs == nil then
                    print("FTP")
                    --sck:send("FTP server enabled. MPPT timer stopped. Reboot device when you are finished.")
                    send_response("<html>FTP server enabled. MPPT timer stopped. Reboot device when you are finished.<br>\nISEMS is disabled while FTP is running. See <a href=\"help.html\">Howto</a></html>")
                    require("ftpserver").createServer('root', ftppass)
                    mppttimer:stop()
                    ftp_runs = 1
                    
                end

                

                if rst ~= nil then
                    print("RST")
                    send_response("Rebooting in 2 seconds. Will be back in 8 seconds.")
                    reboottimer = tmr.create()
                    reboottimer:register(2000, tmr.ALARM_SINGLE, function()
                        node.restart()
                    end)
                    reboottimer:start()
                end

                if tel ~= nil and telnet_runs == nil then
                    print("TELNET")
                    send_response("Lua/Shell interface via telnet port 23 enabled.")
                    require"telnet"
                    telnet_runs = 1
                end

                if mppt_start ~= nil then
                    print("MPPT")
                    send_response([[
                        <html>
                        Starting MPPT timer.
                        <br/><br/>
                        ISEMS is enabled. Wait a minute until the status is updated and reload the page.
                        For general help information see <a href=\"help.html\">Howto</a>
                        <html>
                        ]])
                    mppttimer:start()
                end

                if load_off ~= nil then
                    print("LOAD_OFF")
                    send_response("Load disabled.")
                    gpio.wakeup(14, gpio.INTR_LOW)
                    gpio.write(14, 0)
                    load_disabled = true
                end

                if load_on ~= nil then
                    print("LOAD_ON")
                    send_response("Load enabled.")
                    gpio.wakeup(14, gpio.INTR_HIGH)
                    gpio.write(14, 1)
                    load_disabled = false
                end

                -- Crypto magic ;].
                if encrypted_webkey == true then
                    randomstring, webkeyhash = cryptokey(webkey)
                end

	end)
	conn:on("sent", function(sck) sck:close() end)
end
