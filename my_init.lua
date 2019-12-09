
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

tcp_recv_event = function(socket, data)
  print(data)
  socket:send("Received.\r\n")
end

tcp_accept_event = function(conn)
  conn:on("receive", tcp_recv_event)
  conn:send("Hello.\r\n")
end

tcpsv = net.createServer(net.TCP, 5) -- 5s timeout
tcpsv:listen(1234, tcp_accept_event)


-- Register WiFi Station event callbacks
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, wifi_connect_event)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, wifi_got_ip_event)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, wifi_disconnect_event)

print("** Starting WiFi.")
dofile("credentials.lc") -- wifi_ssid, wifi_psk
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=wifi_ssid, pwd=wifi_psk}) -- config will auto-connect
dofile("application.lc")
