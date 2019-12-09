led_timer = nil
led_buf = nil
led_bright = 200
led_sat = 250

led_val_angle = 0
led_val_angle_inc = 3.25

gpio.mode(0, gpio.OUTPUT) -- 0=GPIO16=user LED

led_tick = function()
    gpio.write(0, gpio.LOW) -- 0=GPIO16=user LED, LOW=on

    local a, da = led_val_angle, 720.0 / led_buf:size() -- two cycles / led strip

    local sat, bright = led_sat, led_bright
    local r, g, b, i

    for i=1, led_buf:size(), 1 do
        g, r, b = color_utils.hsv2grb(a, sat, bright)

        -- color wheel
        a = a + da
        if a > 360 then
            a = a - 360
        end

        led_buf:set(i, r, g, b)
        gpio.write(0, gpio.HIGH) -- 0=GPIO16=user LED, HIGH=off
    end
    ws2812.write(led_buf)

    led_val_angle = led_val_angle + led_val_angle_inc
    if led_val_angle >= 360 then
        led_val_angle = led_val_angle - 360
    end

    led_timer:start() -- restart
end

ledapp_init = function(nled)
    if led_timer == nil then
        led_timer = tmr.create()
    else
        led_timer:unregister()
    end

    if led_buf == nil then
        ws2812.init()
    end

    if led_buf == nil or led_buf:size() ~= nled then
        led_buf = ws2812.newBuffer(nled, 3)
    end

    led_timer:register(12, tmr.ALARM_SEMI, led_tick)
    led_timer:start()
end


ledapp_init(280);
