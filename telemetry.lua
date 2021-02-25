--[[
Telemetry implementation for MQTT.
]]

telemetry_channel_node = telemetry_channel .. nodeid

mqtt_topic = telemetry_channel_node .. "/csvlog"

print("mqtt_topic: ", mqtt_topic)


function mqtt_publish()
    --[[
    MQTT telemetry

    Encode telemetry data as JSON and publish message to
    MQTT broker at topic configured within "config.lua".
    ]]

    print("Submitting telemetry data to MQTT broker.")

    -- JSON payload
    -- https://nodemcu.readthedocs.io/en/master/modules/sjson/
    -- https://github.com/ISEMS/isems-data-collector/blob/926eb4a3/test_importer.py
    print("Creating CSV payload.")
    
    print("########## MQTT broker host:", mqtt_broker_host)
    
    
    m = mqtt.Client("isems-" .. nodeid, 120)
    m:on("connect", function(client) print ("########## Connected to MQTT broker") end)
    m:on("offline", function(client) print ("########## MQTT broker offline") end)

    -- on publish message receive event
    m:on("message", function(client, topic, message) 
    print("######## Topic", topic .. ":" ) 
    if message ~= nil then
    print("######## The MQTT server has received this message:", message)
    end
end)

   m:connect(mqtt_broker_host, mqtt_broker_port, 0,
        function(client)
            -- subscribe topic with qos = 0
            -- client:subscribe(mqtt_topic, 0, function(client) print("subscribe success") end)
            client:publish(mqtt_topic, csvlog, 1, 0, function(client) print("########## Success: MQTT message sent.") end)
        end,
        function(client, reason)
            print("########### MQTT connect failed. Reason: " .. reason)
        end
    )
    

end


if mqtt_enabled == true then
    print("Sending csv log mqtt data.")
    print(csvlog)
    mqtt_publish()
end
