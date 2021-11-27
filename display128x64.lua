disp:clearBuffer()

disp:drawStr(0, 0, "Battery: ")
disp:drawStr(84, 0, V_out)
disp:drawStr(122, 0, "V")
disp:drawStr(0, 10, "Charge: ")
disp:drawStr(84, 10, charge_state_int)
disp:drawStr(122, 10, "%")
disp:drawStr(0, 20, "V_oC:")
disp:drawStr(84, 20, V_oc)
disp:drawStr(122, 20, "V")           
disp:drawStr(0, 30, "V_in:")
disp:drawStr(84, 30, V_in)
disp:drawStr(122, 30, "V")
disp:drawStr(0, 40, "Temperature: ")
disp:drawStr(84, 40, battery_temperature)
disp:drawStr(122, 40, "C")

if low_voltage_disconnect_state == 1 then
disp:drawStr(0, 50, "Load: on")
else
disp:drawStr(0, 50, "Load: off")
end

--disp:drawStr(56, 55, "Status:0x")
--disp:drawStr(110, 55, statuscode)
disp:drawStr(62, 55, "@elektra_42")

disp:sendBuffer()
