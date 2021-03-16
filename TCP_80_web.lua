if webkey == nil then webkey = "empty" end

if encrypted_webkey == true then  randomstring,  webkeyhash = cryptokey (webkey) end

if encrypted_webkey == false or encrypted_webkey == nil then webkeyhash = webkey randomstring = "Encryption not enabled." end

local headers
local payload=''
local content=''
local response = {}
local http_preamble = 'HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n'

function send_buffered(...)
    local n=select("#",...)
    local t={...}
    for i=1,n do
	if (t[i] ~= '') then
            table.insert(response,t[i])
	end
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
    end

    function urldecode(str)
        str = string.gsub (str, "+", " ")
        str = string.gsub (str, "%%(%x%x)", function(h) return string.char(tonumber(h,16)) end)
        return str
    end


    function authenticated()
	local user,pass
	local a=headers['authorization']
	if (a) then
	    user,pass=encoder.fromBase64(a:match('^Basic +(.*)')):match('^([^:]*):(.*)')
	end
	local auth=require('auth')
        if (auth.authenticate(user,pass,true)) then
             return true
	end
        local http_auth = 'HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Basic realm="'..auth.challenge()..'"\r\nContent-Type: text/html\r\n\r\nAccess denied'
        send_buffered(http_auth,nil)
        return false
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
    local p=headers['path']
    print("PATH",p)
    if (p:match('^/control/')) then
        p='/control'
    end
    info={headers=headers,postdata=postdata,conn=conn,buffer=buffer,http_preable=http_preamble}
    local f='WEB_'..p:sub(2):gsub('[./]','_')
    if (not file.exists(f..'.lua')) then
        f='WEB_index_html'
    end
    require(f)(info)
    package.loaded[f]=nil
    flush()
end

return function(conn)
	conn:on("receive", receiver)
end
