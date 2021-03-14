-- Configuration file for ESP-ISEMS-nodeid

-- Lines beginning with two dashes (--) are comments.
-- BEGIN
-- Secret key for triggering commands via HTTP GET
-- Beware: Http is unencrypted, so can be sniffed.

webkey="secret123" -- password

-- Require sha256'ed one-time webkey (strongly recommended in public networks)
-- This will avoid exposing the webkey over the air.

encrypted_webkey = false -- boolean

-- FTP password. Username is "root"
-- Since FTP login and traffic is not encrypted, the password can be sniffed. 
ftppass='pass123' -- password

-- Autoreboot timer in minutes
-- The device will reboot once this timer expires.
-- Set to 0 if you don't want to use this feature.

nextreboot=3600

-- The logic of the local timezone setting in the SDK is reversed.
-- For example: To get UTC+2 you actually need to set UTC-2. Whatever...
-- The default shows central european standard time.

timezone="CEST-1"


-- Latitude of Geolocation
lat = 52.52

-- Longitude of Geolocation
long = 13.4

-- Node-ID
nodeid="ESP32-Meshnode-Unconfigured"

-- Rated capacity of battery in Ampere hours (Ah)
rated_batt_capacity = 7.2

-- Rated power rating of the solar module in Watt. 
solar_module_capacity = 10

-- Average power consumption of the system in Ampere (A)
average_power_consumption = 0.05
---- WIFI
-- Accesspoint IP
ap_ip="192.168.10.10"

-- Accesspoint Netmask
ap_netmask="255.255.255.0"

-- Internet gateway IP
ap_gateway="192.168.10.10"

-- Accesspoint WiFi channel
ap_channel="9"

-- Accesspoint hostname (leave blank for default)
ap_hostname=""

-- WiFi mode 
-- One of: 1 = STATION, 2 = SOFTAP, 3 = STATIONAP, 4 = NULLMODE

wlanmode = 1 -- option 1;2;3;4

-- DNS server IP
ap_dns="8.8.8.8"

-- Accesspoint Password (can not be blank)
ap_pwd="12345678"

-- Accesspoint SSID 
ap_ssid="esp32-isems-ap"

-- Wifi station AP SSID (the existing WiFi-AP that the device should connect to as a WiFi client)
sta_ssid="AP2.freifunk.net"

-- WPA key to connect to the existing AP as WiFi client
sta_pwd=""

-- Station hostname (leave blank for default)
sta_hostname=""

-- Enable (true) or disable (false) nodemcu internal debugging output.
-- Default is (false). (true) might be very verbose and spam the LUA command line
-- via serial port or telnet shell.

enable_osprint=false -- boolean

-- The telemetry channel to send metrics to.
-- See also MQTT configuration below.
telemetry_channel = "/isems/"

-- Telemetry configuration for MQTT
-- Enable MQTT?
mqtt_enabled = true -- boolean
-- Host to connect to
mqtt_broker1_host = "api.isems.de"
-- Port to connect to
mqtt_broker1_port = 1883 
-- Close connection after sending data
mqtt_broker1_close = true -- boolean
-- Use only last (newest) data line
mqtt_broker1_short = false -- boolean
-- Second host to connect to (leave blank to disable it)
mqtt_broker2_host = ""
-- Second Port to connect to
mqtt_broker2_port = 1883 
-- Close connection after sending data
mqtt_broker2_close = false -- boolean
-- Use only last (newest) data line
mqtt_broker2_short = true -- boolean
