--[[
Telemetry implementation for MQTT.
]]

telemetry_channel_node = telemetry_channel .. nodeid

mqtt_topic = telemetry_channel_node .. "/csvlog"

printv(2,"mqtt_topic: ", mqtt_topic)

function mqtt_publish(broker)
    local data
    if (broker.short) then
        data=csvs[#csvs]
    else
        data=csvlog
    end
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

    -- JSON payload
    -- https://nodemcu.readthedocs.io/en/master/modules/sjson/
    -- https://github.com/ISEMS/isems-data-collector/blob/926eb4a3/test_importer.py
    printv(2,"Creating CSV payload.")
    
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


if type(mqtt_brokers) == "table" then
    printv(2,"Sending csv log mqtt data.")
    printv(2,'csvlog',csvlog)
    for i,broker in ipairs(mqtt_brokers) do
        if (broker.m) then
            mqtt_publish(broker)
        else
            mqtt_connect(broker)
        end
    end
end
