if webkey == nil then webkey = "empty" end

if encrypted_webkey == true then  randomstring,  webkeyhash = cryptokey (webkey) end

if encrypted_webkey == false or encrypted_webkey == nil then webkeyhash = webkey randomstring = "Encryption not enabled." end


return function(conn)

local headers
local payload=''
local content=''
local response = {}
local http_preamble = 'HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n'
local txbytes=0
local sync_limit=0

local function send(localSocket)
    if #response > 0 then
        local str=table.remove(response, 1)
        txbytes=txbytes+str:len()
        localSocket:send(str)
	if (tmr:wdclr()) then
	    tmr:wdclr()
	end
    else
        txbytes=0
        localSocket:close()
    end
end


local function receiver(sck, data)

function send_buffered(...)
    if (conn == nil) then
        print("conn is nil")
    end
    local n=select("#",...)
    local t={...}
    for i=1,n do
	if (t[i] ~= nil and t[i] ~= '') then
	    local s=tostring(t[i])
	    local l=s:len()
            table.insert(response,s)
	    if (txbytes == 0 or txbytes+l < sync_limit) then
	       tmr:wdclr()
	       send(conn)
	    end
	end
    end
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
        local http_auth = 'HTTP/1.0 401 Unauthorized\r\nWWW-Authenticate: Basic realm="'..auth.challenge()..'"\r\nContent-Type: text/html\r\n\r\nAccess denied'
        send_buffered(http_auth,nil)
        return false
    end

    sck:on("sent", send)

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
end
conn:on("receive", receiver)
end
