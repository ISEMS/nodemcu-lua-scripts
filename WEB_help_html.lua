local help_page = [[
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
return function(conn)
	send_buffered(help_page)
end
