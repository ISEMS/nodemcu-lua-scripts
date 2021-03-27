local help_page = [[
	<html>
	<h3>Commands</h3>
	<b><a href='/config'/>/config</a></b> Edit configuration<br>
	<b><a href='/control'/>/control</a></b> Check status,enable or disable servers, the load output and the mpp tracker process<br>
	<b><a href='/reboot'/>/reboot</a></b> Reboot the device<br>

	<h3>Info</h3>
	<b><a href='/random'/>/random</a></b> Random key for encrypted authentication<br>
	<b><a href='/csv.log'/>/csv.log</a></b> Show log data<br>
	<br>
	Configuration is stored in the file <b>config.lua</b>, which you can edit on your PC <br>
	and upload/download via FTP or via serial port with nodemcu-tool.

	<h3>Caveats</h3>
	Use your passwords only over a encrypted WiFi and if you trust the network.
	TELNET, FTP and HTTP keys can be sniffed easily, as they are sent unencrypted.
	</html>
]]
return function(conn)
	send_response(help_page)
end
