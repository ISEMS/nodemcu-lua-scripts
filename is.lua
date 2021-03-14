--[[
* **********************************************************************
 * ISEMS LUA source code for FF-ESP32-OpenMPPT
 * Copyright (C) 2020  by Corinna 'Elektra' Aichele with contributions
 * by Andreas Motl
 *
 * This file is part of the Open-Hardware and Open-Software project 
 * FF-ESP32-OpenMPPT.
 * 
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This source code is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License
 * along with this source file. If not, see http://www.gnu.org/licenses/. 
 ************************************************************************* ]]


-- Print with verbosity level 0:Critical,1:Error,2:Info,3:Debug,4:Trace
function printv(v,...)
    if (verbose == nil or verbose >= v) then
        print(...)
    end
end

function sh()
    require('shell').run()
end

adc.setwidth(adc.ADC1, 12)

adc.setup(adc.ADC1, 6, adc.ATTEN_0db)
adc.setup(adc.ADC1, 5, adc.ATTEN_0db)
adc.setup(adc.ADC1, 4, adc.ATTEN_11db)

gpio.config( { gpio={14}, dir=gpio.OUT, pull=gpio.PULL_UP })
dac.enable(dac.CHANNEL_1)

dac1value = 0

Voutctrlcounter = 0
health_estimate = 100
health_test_in_progress = false
V_oc = 0

load_disabled = false

    -- Calibration data
    -- MPP range of FF-OpenMPPT-ESP32 v1.2
if not Vmpp_max then Vmpp_max = 27.2 end
if not Vmpp_min then Vmpp_min = 13.25 end
if not Vcc then Vcc = 3.07 end
if not hardware_version then hardware_version = "unknown" end
if not firmware_type then firmware_type = "unknown" end

pagestring = "mp2.lua not started yet."

V_outctrltimer = tmr.create()
V_outctrltimer:register(600, tmr.ALARM_AUTO, function() Voutctrl(1) end)

require"mp2"

function cryptokey (webkey, randomstring, webkeyhash)

    randomstring = encoder.toHex(sodium.random.buf(16))
    randomstringforhash = randomstring .. webkey
    hashobj = crypto.new_hash("SHA256")
    hashobj:update(randomstringforhash)
    digest = hashobj:finalize()
    webkeyhash = encoder.toHex(digest)
    print("Randomstringforhash:", randomstringforhash)
    print("webkey:", webkey)
    print("Randomstring:", randomstring)
    print("Digest Hex:", webkeyhash)
    print("FreeMEM:", node.heap())

return randomstring, webkeyhash

end


autoreboot_disabled = 0

if nextreboot == nil then nextreboot = 99999 end
if nextreboot == 0 then autoreboot_disabled = 1 end

print("Autoreboot_disabled  =", autoreboot_disabled)

packetrev = "1"
counter_serial_loop = 0
health_estimate = 100
powersave = 0
timestamp = 123456789
health_estimate = 100
charge_state = 100

if (ow18b20 == true) then
    ow18b20timer = tmr.create()
    ow18b20timer:register(12000, tmr.ALARM_AUTO, function() dofile"18b20.lua" end)
    ow18b20timer:start()
end


mppttimer = tmr.create()
mppttimer:register(15000, tmr.ALARM_AUTO, function() dofile"mp2.lua" if autoreboot_disabled ~= 1 then nextreboot = nextreboot - 1 end
if autoreboot ~= 1 and nextreboot <= -1 then node.restart() end end)
mppttimer:start()

if mqtt_enabled then
mqtttimer = tmr.create()
mqtttimer:register(65000, tmr.ALARM_AUTO, function() 
                   printv(2,"MQTT telemetry process started")
		   if Voutctrlcounter > 0  then V_outctrltimer:stop() end 
                   dofile"telemetry.lua" 
                   if Voutctrlcounter > 0  then V_outctrltimer:start() end
                  end)
mqtttimer:start()
end
