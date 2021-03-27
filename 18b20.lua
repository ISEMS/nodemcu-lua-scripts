-- 18b20 Example
-- local owtimer = tmr.create()
pin = 21
ow.setup(pin)
count = 0
repeat
  count = count + 1
  addr = ow.reset_search(pin)
  addr = ow.search(pin)
until (addr ~= nil) or (count > 3)
if addr == nil then
  print("No more addresses.")
else
  print(addr:byte(1,8))
  crc = ow.crc8(string.sub(addr,1,7))
  if crc == addr:byte(8) then
    if (addr:byte(1) == 0x10) or (addr:byte(1) == 0x28) then
      print("Device is a DS18S20 family device.")
--        repeat
          ow.reset(pin)
          ow.select(pin, addr)
          ow.write(pin, 0x44, 1)
          -- tmr.delay(1000000)
          
          --owtimer:register(10, tmr.ALARM_SINGLE, function (t) -- print("expired") end)
          present = ow.reset(pin)
          ow.select(pin, addr)
          ow.write(pin,0xBE,1)
          print("P="..present)
          data = nil
          data = string.char(ow.read(pin))
          for increment = 1, 8 do
            data = data .. string.char(ow.read(pin))
          end
          print(data:byte(1,9))
          crc = ow.crc8(string.sub(data,1,8))
          print("CRC="..crc)
          if crc == data:byte(9) then
             tbits = (data:byte(1) + data:byte(2) * 256) * 625
             ow_temp1 = tbits / 10000
            if ow_temp1 > 200 then ow_temp1 = ow_temp1 - 4095 
          end
             --t2 = t % 10000
             --print("Temperature="..t1.."."..t2.." Centigrade")
             print("Temperature = " ..ow_temp1 .. " Celsius")
         end
 --       until false
            --              end)
            -- owtimer:start()    
    else
      print("Device family is not recognized.")
          end
  else
    print("CRC is not valid!")


end

end
