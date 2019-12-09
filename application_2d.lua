
M_PI = 3.141592653589793

-- Bhaskara I's sine approximation formula
function sin(a)
    while a > M_PI do
        a = a - 2*M_PI
    end
    while a < -M_PI do
        a = a + 2*M_PI
    end
    -- now -pi <= a <= pi

    if a < 0 then
        a = - a
        t = 4 * a * (M_PI - a)
        return - 4*t/(49.34802-t)
    else
        t = 4 * a * (M_PI - a)
        return 4*t/(49.34802-t)
    end
end

function cos(a)
    return sin(a + M_PI/2.0)
end

function clip(v, a, b)
    if v == nil then
        return a
    elseif v < a then
        return a
    elseif v > b then
        return b
    else
        return v
    end
end

function advance_phase(p, dp)
    p = p + dp
    if p > M_PI then
        return p - 2*M_PI
    else
        return p
    end
end


ws2812.init()
buf = ws2812.newBuffer(64, 3)
led_timer = tmr.create()

max_val = 40.0
hue = 0

phase_x = 0.0
dp_x = 0.01

phase_y = 0.0
dp_y = 0.011

running = true

led_tick = function()
    xctr = sin(phase_x)
    yctr = sin(phase_y)

    for row=0,7,1 do
        x = row*0.28571 - 1
        for col=0,7,1 do
            y = col*0.28571 - 1
            -- 1 - r^2
            rsq = ((x-xctr)*(x-xctr)+(y-yctr)*(y-yctr))
            val = max_val*clip(1-rsq*rsq, 0, 1)

            gr, re, bl = color_utils.hsv2grb(hue, 255, val)

            -- row/col 0..7 to index 1..N
            -- zigzag order for 8x8 LED panel
            if (row % 2) == 1 then
                j = row * 8 + 8 - col
            else
                j = row * 8 + 1 + col
            end
            buf:set(j, re, gr, bl)

        end
    end

    ws2812.write(buf)

    phase_x = advance_phase(phase_x, dp_x)
    phase_y = advance_phase(phase_y, dp_y)

    hue = hue + 1
    if hue > 360 then
        hue = 0
    end

    if running then
        led_timer:start() -- restart
    end
end

led_timer:register(25, tmr.ALARM_SEMI, led_tick)
led_timer:start()

udp_receive_event = function(socket, data, port, ipaddr)
    if running then
        print("UDP from " .. ipaddr .. ":" .. port .. ". Stop animation.")
        running = false
    end

    need_bytes = 3*buf:size()

    if data:len() == need_bytes then
        buf:replace(data)
        ws2812.write(buf)
    else
        print("Wrong UDP size, need " .. need_bytes .. " bytes.")
        running = true
        led_timer:start()
    end
end

udp = net.createUDPSocket()
udp:listen(5000)
udp:on("receive", udp_receive_event)