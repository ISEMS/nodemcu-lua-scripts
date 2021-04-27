-- Telemetry implementation for MQTT

function mqtt_publish(broker)
    local data
    if (broker.short) then
        data=csvs[#csvs]
    else
        data=csvlog
    end
    
    if not (broker.json) then
     print("Debug1")
     telemetry_channel_node = (broker.channel) .. nodeid
     mqtt_topic = telemetry_channel_node .. "/csvlog"
     printv(2,"Prepared csv log mqtt data.")
    end

    
    
    if (broker.json) then 
         print("Debug2")
         data = {
        -- nodeId = nodeid,
        -- isemsRevision = packetrev,
        -- timestamp = timestamp,
        timeToShutdown = nextreboot,
        isPowerSaveMode = powersave,
        openCircuitVoltage = V_oc,
        mppVoltage = V_in,
        batteryVoltage = V_out,
        batteryChargeEstimate = charge_state_int,
        batteryHealthEstimate = health_estimate,
        batteryTemperature = battery_temperature,
        lowVoltageDisconnectVoltage = low_voltage_disconnect,
        temperatureCorrectedVoltage = V_out_max_temp,
        rateBatteryCapacity = rated_batt_capacity,
        ratedSolarModuleCapacity = solar_module_capacity,
        latitude = lat,
        longitude = long,
        status = statuscode,
    }
         
    print("Creating JSON payload.")
    sjson.encode(data)
    ok, json = pcall(sjson.encode, data)
    if ok then
        
        data = json
        --print("JSON payload:", data)
    else
        print("ERROR: Encoding to JSON failed!")
        return
    end
    
    telemetry_channel_node = (broker.channel) .. nodeid
    mqtt_topic = telemetry_channel_node .. "/data.json"
    end
    
printv(2,"mqtt_topic: ", mqtt_topic)
print("########## MQTT broker host:", broker.host)
print("Sending this MQTT Data set:", data)

    broker.m:publish(mqtt_topic, data, 1, 0, function(client)
        printv(2,"########## Success: MQTT message sent.")
        if (broker.close) then
            broker.m=nil
        end
    end)
end

function mqtt_connect(broker)
    --[[
    MQTT telemetry

    Encode telemetry data as JSON and publish message to
    MQTT broker at topic configured within "config.lua".
    ]]

    local m
    printv(2,"Submitting telemetry data to MQTT broker.")
    
    printv(2,"########## MQTT broker host:", broker.host)
    
    
    m = mqtt.Client("isems-" .. nodeid, 120)
    broker.m=m
    m:on("connect", function(client) printv(2,"########## Connected to MQTT broker") end)
    m:on("offline", function(client) printv(1,"########## MQTT broker " .. broker.host .. " offline") ; broker.m=nil end)

    -- on publish message receive event
    m:on("message", function(client, topic, message) 
    print("######## Topic", topic .. ":" ) 
    if message ~= nil then
    print("######## The MQTT server has received this message:", message)
    end
end)

   m:connect(broker.host, broker.port, 0,
        function(client)
            -- subscribe topic with qos = 0
            -- client:subscribe(mqtt_topic, 0, function(client) print("subscribe success") end)
	    mqtt_publish(broker)
        end,
        function(client, reason)
            print("########### MQTT connect failed. Reason: " .. reason)
        end
    )
end

local function get_config()
    mqtt_brokers={}
    for i=1,2 do
	local broker={}
	for _,k in ipairs{'host','port','close','short','json','channel' } do
	    broker[k]=_G['mqtt_broker'..i..'_'..k]
	end
	if (broker.host ~= nil and broker.host ~= '') then
	    table.insert(mqtt_brokers,broker)
	end
    end
end

if mqtt_enabled then
    if (mqtt_brokers == nil) then
        get_config()
    end
    for i,broker in ipairs(mqtt_brokers) do
        if (broker.m) then
            mqtt_publish(broker)
        else
            mqtt_connect(broker)
        end
    end
end
