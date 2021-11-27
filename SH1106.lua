-- For generic SH1106 no-name display, using i2c port at 128x64 resolution

-- Available compiled-in fonts: 
-- font_6x10_tf
-- font_unifont_t_symbols          

id = i2c.HW0
-- IO21 on Pin-Header P1
sda = 21
-- IO22 on Pin-Header P1
scl = 22

sla = 0x3C
-- sla = 0x3D

i2c.setup(id, sda, scl, i2c.FAST)

disp = u8g2.sh1106_i2c_128x64_noname(id, sla)
disp:setFont(u8g2.font_6x10_tf)
disp:setFontRefHeightExtendedText()
disp:setDrawColor(1)
disp:setFontPosTop()
disp:setFontDirection(0)

disp:clearBuffer()

disp:drawStr(4, 0, "FF-ESP32-OpenMPPT")
disp:drawStr(4, 14, "Init is waiting now")
disp:drawStr(4, 24, "for 5 seconds.")
disp:drawStr(4, 34, "To interrupt booting")
disp:drawStr(4, 44, "type \"stop()\" in")
disp:drawStr(4, 54, "serial terminal.")

disp:sendBuffer()
