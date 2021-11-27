
-- Configuration file for ESP-ISEMS-nodeid

-- Lines beginning with two dashes (--) are comments.
-- BEGIN
------ Battery and Solar Module
-- Rated capacity of battery in Ampere hours (Ah)
rated_batt_capacity = 7.2

-- Rated power rating of the solar module in Watt.
solar_module_capacity = 10

-- Average power consumption of the system in Ampere (A)
average_power_consumption = 0.05
------ WIFI
-- WiFi mode
-- One of: 1 = STATION, 2 = SOFTAP, 3 = STATIONAP, 4 = NULLMODE
wlanmode = 3 -- option 1;2;3;4

---- Station
-- Wifi station AP SSID (the existing WiFi-AP that the device should connect to as a WiFi client)
sta_ssid="AP2.freifunk.net"

-- WPA key to connect to the existing AP as WiFi client
sta_pwd="" --password

-- Station hostname (leave blank for default)
sta_hostname=""

---- Accesspoint
-- Accesspoint SSID
ap_ssid="esp32-isems-ap"

-- Accesspoint WPA key (can not be blank)
ap_pwd="12345678" -- password

-- Accesspoint WiFi channel
ap_channel="9"

-- Accesspoint IP
ap_ip="192.168.10.10"

-- Accesspoint Netmask
ap_netmask="255.255.255.0"

-- Internet gateway IP
ap_gateway="192.168.10.10"

-- DNS server IP
ap_dns="8.8.8.8"

-- Accesspoint hostname (leave blank for default)
ap_hostname=""

------ System
-- Password for ftp,telnet and web
-- Beware: Passwords are send unencrypted, so can be sniffed.

webkey="pass123" -- password

-- Require sha256'ed one-time password (strongly recommended in public networks)
-- This will avoid exposing the password over the air.
-- However on the web server you have to authenticate every time a page requires
-- authentication

encrypted_webkey = false -- boolean

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

-- Node-ID (used in telemetry and csv log)
nodeid="ESP32-Meshnode-Unconfigured"

-- Enable (true) or disable (false) nodemcu internal debugging output.
-- Default is (false). (true) might be very verbose and spam the LUA command line
-- via serial port or telnet shell.

enable_osprint=false -- boolean

-- Verbositiy level of Telnet and serial console messages.
-- Valid values are 0 (nothing except critical errors)
-- up to 4 (very verbose for debugging)

verbose=1 -- option 1;2;3;4

-- Additional ds18b20 I2C temperature sensor connected to GPIO21
ow18b20=false  -- boolean

---- MQTT-Telemetry configuration
-- Enable MQTT?
mqtt_enabled = false -- boolean

-- MQTT broker to connect to
mqtt_broker1_host = "api.isems.de"
-- Port to connect to
mqtt_broker1_port = 1883
-- The telemetry channel to send our data to. 
mqtt_broker1_channel = "/isems/"
-- Close connection after sending data?
-- Recommended if setting up two brokers
mqtt_broker1_close = true -- boolean
-- Use only last (newest) csv data line
-- If set to false, the last five csv data lines are send
-- not used if we send json data
mqtt_broker1_short = false -- boolean
-- Send JSON data instead of CSV data
mqtt_broker1_json = false -- boolean

-- Second MQTT broker to connect to (leave blank to disable it)
mqtt_broker2_host = "isems.mqtthub.net"
-- Port to connect to
mqtt_broker2_port = 1883
-- Telemetry channel to send metrics to.
-- Note: This MQTT server doesn't like "/" 
-- at the beginning of the channel 
mqtt_broker2_channel = "isems/testdrive/foobar/"
-- Close connection after sending data
-- Recommended if setting up two brokers
mqtt_broker2_close = true -- boolean
-- Use only last (newest) csv data line
-- not used if we send json data
mqtt_broker2_short = false -- boolean
-- Send JSON data instead of CSV data
mqtt_broker2_json = true -- boolean
