local help_page = [[
	<html>
	Commands on this device can be executed remotely by sending HTTP requests + valid user and password
	<br><br>

	Now, you can upload a customized version of <b>config.lua</b> via FTP
	with the default FTP user-password combination <b>root / pass123</b> like
	<pre>lftp -u root,pass123 IP-or-URL-of-FF-ESP32-device -c 'put config.lua'</pre>
	<br><br>

	All passwords are stored in <b>config.lua</b> and should be changed before deploying the system, of course.
	Just reboot the device to apply the new configuration.
	<br><br>

	<h3>Commands</h3>
	<b><a href='/config'/>/config</a></b> Edit configuration<br/>
	<b><a href='/control'/>/control</a></b> Check status,enable or disable servers, the load output and the mpp tracker process<br/>
	<b><a href='/control/reboot'/>/control/reboot</a></b> Reboot the device<br/>

	<h3>Info</h3>
	<b><a href='/random'/>/random</a></b> Random key for encrypted authentication<br/>
	<b><a href='/csv.log'/>/csv.log</a></b> Show log data<br/>

	<h3>Caveats</h3>
	Use your passwords only over a encrypted WiFi and if you trust the network.
	TELNET, FTP and HTTP keys can be sniffed easily, as they are sent unencrypted.
	Links are case sensitive. Remember that this is a tiny device with very limited ressources.
	If all features are enabled, the device might occasionally run out of memory, crash and reboot.

	</html>
]]
return function(conn)
	send_response(help_page)
end
