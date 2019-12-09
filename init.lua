raw, extended = node.bootreason()
print("** Startup, bootreason is " .. raw .. "/" .. extended)
print("**")
print("** Press flash button to delay running my_init.")
print("**")
gpio.mode(3, gpio.INPUT)
tmr.delay(1000000)

if gpio.read(3) == 1 then
    print("** Executing my_init.")
    dofile("my_init.lc") -- compiled
else
    print('** Skipping execution of my_init.')
end
