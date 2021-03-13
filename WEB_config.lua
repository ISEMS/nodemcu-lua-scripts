local function gen_page(data)
	local s=data.param
	if (data.key) then
		local c=data.type
		if (c == 'boolean') then c='option true;false' end
		if (c:sub(1,7) == 'option ') then
			send_buffered("<select name='"..k.."'>")
			for str in string.gmatch(c:sub(8), "([^;]+)") do
				send_buffered("<option value='"..str.."'"..(v == str and " selected='selected'" or "")..">"..str..'</option>')
			end
			send_buffered("</select></br>")
		else
			send_buffered("<input type='"..(c == 'password' and c or 'text').."' name='"..k.."' value='"..v.."' /><br/>")
		end
		s.sep='<hr/>'
	else
		if (s.output) then
			if (s.sep ~= '') then
				send_buffered(s.sep)
				s.sep=''
			end
			send_buffered(data.line:sub(4) .. '<br/>')
		end
		if (data.line == '-- BEGIN') then
			s.output=true
		end
	end
	return true
end

return function (info)
	if (not authenticated()) then
		return
	end
	send_buffered(info.http_preable)
	if (info.headers.method == 'POST') then
		if (config.update(info.postdata)) then
			send_buffered("Success, <a href='/'>back to main page</a>",nil)
			return
		else
			send_buffered('An error occured</br>')
		end
	end
	send_buffered("<form method='post'>")
	state={output=false,sep=''}
	config.parse('config.lua',gen_page,state)
	send_buffered("</hr><input type='submit' value='Submit'/>")
	send_buffered("</form>")
end
