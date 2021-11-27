-- Display output for 128x64 pixel

disp:clearBuffer()

if ow_temp1 == nil then ow_temp1 = "no data" end

disp:drawStr(7, 0, "Battery:")
disp:drawStr(84, 0, V_out)
disp:drawStr(122, 0, "V")
disp:drawStr(6, 10, "Charge: ")
disp:drawStr(84, 10, charge_state_int)
disp:drawStr(122, 10, "%")
disp:drawStr(6, 20, "V_oC:")
disp:drawStr(84, 20, V_oc)
disp:drawStr(122, 20, "V")           
disp:drawStr(6, 30, "V_in:")
disp:drawStr(84, 30, V_in)
disp:drawStr(122, 30, "V")
disp:drawStr(6, 40, "Temperature: ")
disp:drawStr(84, 40, battery_temperature)
disp:drawStr(122, 40, "C")

if load_disabled == false or low_voltage_disconnect_state == 0 then
disp:drawStr(6, 52, "Load:          on")
else
disp:drawStr(6, 52, "Load:         off")
end

disp:sendBuffer()