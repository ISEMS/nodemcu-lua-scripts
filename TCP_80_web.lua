if webkey == nil then webkey = "empty" end

if encrypted_webkey == true then  randomstring,  webkeyhash = cryptokey (webkey) end

if encrypted_webkey == false or encrypted_webkey == nil then webkeyhash = webkey randomstring = "Encryption not enabled." end

local headers
local payload=''
local content=''
local response = {}
local http_preamble = 'HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n'
local http_auth = 'HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Basic realm="'..randomstring..'"\r\nContent-Type: text/html\r\n\r\nAccess denied'

function send_buffered(...)
    local n=select("#",...)
    local t={...}
    for i=1,n do
        table.insert(response,t[i])
    end
end


function receiver(sck, data)
    -- triggers the send() function again once the first chunk of data was sent
    function flush()
        sck:on("sent", send2)
        send(sck)
    end

    function send(localSocket)
        -- print("send")
        if #response > 0 then
            localSocket:send(table.remove(response, 1))
        else
            localSocket:close()
            response = nil
        end
    end

    function send2(localSocket)
        -- print("send2")
        send(localSocket)
    end

    function send_response(response)
	send_buffered(http_preamble, response)
        flush()
    end

    function urldecode(str)
        str = string.gsub (str, "+", " ")
        str = string.gsub (str, "%%(%x%x)", function(h) return string.char(tonumber(h,16)) end)
        return str
    end


    function authenticated()
                    local auth='Basic '..encoder.toBase64('root:'..ftppass)
                    local a=headers['authorization']
                    if (not a or a ~= auth) then
                        send_buffered(http_auth,nil)
                        return false
                    end
                    return true
    end

    payload=payload..data
    if (headers == nil) then
        local pos=payload:find('\r\n\r\n')
        -- print('looking for headers')
        if (not pos) then
            return
        end
        -- print('header found',pos)
        local header=payload:sub(1,pos)
        for str in string.gmatch(header, "([^\r\n]+)") do
            if (headers) then
                local k,v=str:match("([^: ]*)%s*:%s*(.*)")
                headers[k:lower()]=v
            else
                local m,pa,pr=str:match("([^ ]*)%s+([^ ]*)%s+([^ ]*)")
                headers={method=m,path=pa,protocol=pr}
            end
        end
        content=payload:sub(pos+4)
        -- print("len",payload:len())
    end
    local cl=headers['content-length']
    if (cl and content:len() < tonumber(cl)) then
        -- print('not enough data',cl,payload:len())
       return
    end
    if (headers.method == 'POST') then
        postdata={}
        for str in string.gmatch(content, "([^&]+)") do
            local k,v=str:match("([^=]*)=(.*)")
            postdata[urldecode(k)]=urldecode(v)
        end
    end
    if (headers['path'] == '/config' or headers['path'] == '/help.html') then
        info={headers=headers,postdata=postdata,conn=conn,buffer=buffer,http_preable=http_preamble}
        local p='WEB_'..headers['path']:sub(2):gsub('[./]','_')
        require(p)(info)
	package.loaded[p]=nil
        flush()
	return
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
end

return function(conn)
	conn:on("receive", receiver)
end
