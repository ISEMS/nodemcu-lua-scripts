-- WiFi mode
-- One of: 1 = STATION, 2 = SOFTAP, 3 = STATIONAP, 4 = NULLMODE

print("WiFi Mode: ", wlanmode)

if wlanmode == 3 then

print("Starting WiFi in STATIONAP mode")

-- run WiFi AP and connect to WiFi access point

wifi.mode(wifi.STATIONAP, true)

wifi.sta.on("connected", function() print("connected") end)
-- wifi.sta.on("got_ip", function(event, info) print("got ip "..info.ip) localstaip = info.ip end)
wifi.sta.on("got_ip", function(event, info)  print("got ip "..info.ip) localstaip = info.ip end)

wifi.ap.on("start")
wifi.ap.on("sta_connected", function(event, info) print("Station connected:  "..info.mac ) end)

-- mandatory to start wifi after reset
wifi.start()

-- wifi.sta.sethostname is broken.
-- wifi.sta.sethostname("FF-ESP32")

cfg={}

cfg.ssid=ap_ssid
cfg.pwd=ap_pwd
wifi.ap.config(cfg)
cfg={}
cfg.ip=ap_ip
cfg.netmask=ap_netmask
cfg.gateway=ap_gateway
-- Possible conflict, if station is on a different channel.
-- cfg.channel=ap_channel
cfg.dns=ap_dns

wifi.ap.setip(cfg)


wifi.sta.config({ssid=sta_ssid, pwd=sta_pwd, auto=true}, true)

end

if wlanmode == 2  then

-- Run as WiFi access point

wifi.mode(wifi.SOFTAP, true)

wifi.ap.on("start")
wifi.ap.on("sta_connected", function(event, info) print("Station connected:  "..info.mac ) end)

-- mandatory to start wifi after reset
wifi.start()
cfg={}

cfg.ssid=ap_ssid
cfg.pwd=ap_pwd
wifi.ap.config(cfg)
cfg={}
cfg.ip=ap_ip
cfg.netmask=ap_netmask
cfg.gateway=ap_gateway
cfg.channel=ap_channel
cfg.dns=ap_dns

wifi.ap.setip(cfg)

end

if wlanmode == 1 then

-- Run as WiFi client
wifi.mode(wifi.STATION, true)

wifi.sta.on("connected", function() print("connected") end)
--wifi.sta.on("got_ip", function(event, info) print("got ip "..info.ip) end)
wifi.sta.on("got_ip", function(event, info) print("got ip "..info.ip) localstaip = info.ip end)

-- wifi.sta.sethostname is broken.
--wifi.sta.sethostname("FF-ESP32")

-- mandatory to start wifi after reset
wifi.start()

wifi.sta.config({ssid=sta_ssid, pwd=sta_pwd, auto=true}, true)

end

uplinktimer = tmr.create()
uplinktimer:register(10000, tmr.ALARM_SINGLE, function() print("Starting NTP service") time.initntp() end)
uplinktimer:start()

