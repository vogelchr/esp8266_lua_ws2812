-- load credentials, 'SSID' and 'PASSWORD' declared and initialize in there
dofile("credentials.lua")

-- Define WiFi station event callbacks 
wifi_connect_event = function(T)
  print("*** WiFi connected, ssid is " .. T.SSID)
  if disconnect_ct ~= nil then disconnect_ct = nil end  
end

wifi_got_ip_event = function(T) 
  print("*** WiFi IP address is " .. T.IP)
--  tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)
end

wifi_disconnect_event = function(T)
    print("** WiFi disconnected.")
    for key,val in pairs(wifi.eventmon.reason) do
        if val == T.reason then
            print("** Disconnect reason: " .. val .. "(" .. key .. ")")
            break
        end
    end
end

-- Register WiFi Station event callbacks
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, wifi_connect_event)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, wifi_got_ip_event)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, wifi_disconnect_event)

print("** Starting WiFi.")
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=wifi_ssid, pwd=wifi_psk})
-- wifi.sta.connect() not necessary because config() uses auto-connect=true by default

-- will be compiled
dofile("application.lc")