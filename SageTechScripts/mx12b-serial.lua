local file_name = 'rawserialdump.txt'
local file_name_plain = 'serialdump.txt'

-- SCR User parameters SCR_USER1 SCR_USER2 SCR_USER3 SCR_USER4

-- for fast param acess it is better to get a param object,
-- this saves the code searching for the param by name every time

local scr_user1_param = Parameter() -- user1 param 
local scr_user2_param = Parameter() -- user2 param 
local scr_user3_param = Parameter() -- user3 param 
local scr_user4_param = Parameter() -- user4 param 

-- initialise parameters
assert(scr_user1_param:init('SCR_USER1'), 'could not find SCR_USER1 parameter')
assert(scr_user2_param:init('SCR_USER2'), 'could not find SCR_USER2 parameter')
assert(scr_user3_param:init('SCR_USER3'), 'could not find SCR_USER3 parameter')
assert(scr_user4_param:init('SCR_USER4'), 'could not find SCR_USER4 parameter')

local SCR_USER1 = 0
local SCR_USER2 = 0
local SCR_USER3 = 0
local SCR_USER4 = 0
local DEBUG = 1

local baud_rate = 230400

-- find the serial first (0) scripting serial port instance
-- SERIALx_PROTOCOL 28
-- in mavlink: 
--    param set SERIAL5_PROTOCOL 28
--    param show SERIAL5_PROTOCOL
local port = assert(serial:find_serial(0),"Could not find Scripting Serial Port")

-- begin the serial port
port:begin(baud_rate)
port:set_flow_control(0)



-- update the user parameter variables
function update_user_parameters()
    SCR_USER1 = param:get('SCR_USER1')
    SCR_USER2 = param:get('SCR_USER2')
    SCR_USER3 = param:get('SCR_USER3')
    SCR_USER4 = param:get('SCR_USER4')
    
    if DEBUG == 1 then
        gcs:send_text(0, string.format('LUA: scr_user1_param: %i', SCR_USER1))    
        gcs:send_text(0, string.format('LUA: scr_user2_param: %i', SCR_USER2))    
        gcs:send_text(0, string.format('LUA: scr_user3_param: %i', SCR_USER3))
        gcs:send_text(0, string.format('LUA: scr_user4_param: %i', SCR_USER4))
    end    
end

function get_position()
    local current_pos = ahrs:get_position()
    
    -- ahrs:get_position is not available until it can calculate a position. It won't calculate a position without GPS.
    if current_pos then
        gcs:send_text(0, string.format("AHRS pos - Lat:%.5f Long:%.5f ,Alt:%.2f", current_pos:lat()/1e7, current_pos:lng()/1e7, current_pos:alt()/100 ) )
    end
    -- gps:location appears to be "available" even in the absence of a GPS, returns 0,0,0.
    current_pos = gps:location(gps:primary_sensor())
        
    if current_pos then
        -- lat and long are * 1e7, alt is in cm.
        gcs:send_text(0, string.format("GPS _pos - Lat:%.5f Long:%.5f ,Alt:%.2f", current_pos:lat()/1e7, current_pos:lng()/1e7, current_pos:alt()/100 ) )
        gcs:send_named_float('gps_lat', current_pos:lat())
    end
       
    return do_serial , 100
    
end

--              HD DR SQ    TP          CS
-- Status  Msg: AA 05 0C 04 83 00 00 00 nn
-- Install Msg: AA 05 0F 04 81 00 00 00 nn
-- Version Msg: AA 05 10 04 8E 00 00 00 nn
-- Serial  Msg: AA 05 11 04 8F 00 00 00 nn
-- Temp    Msg: AA 05 12 04 8D 00 00 00 nn
-- crypto  Msg: AA 05 16 04 D4 00 00 00 9D
-- Mil Setting: AA 05 17 04 D7 00 00 00 A1

-- binstr = string.char(0x41, 0x42, 0x43, 0x00, 0x02, 0x33, 0x48)

function do_serial()
    read_serial()
    write_serial()
    return update, 1000
end

function read_serial()

	gcs:send_text(0, "read_serial *****") 
	
    -- write a status request to the serial port.
    port:write(0xAA)
    port:write(0x05)
    port:write(0x25)
    port:write(0x04)
    port:write(0x83)
    port:write(0x00)
    port:write(0x00)
    port:write(0x00)
    port:write(0x5B)
	
    return write_serial , 100

end

function table_to_hex()
    
end

function write_serial()

  gcs:send_text(0, "write_serial *****") 
  -- NB: #byte_array will give you the length of byte_array 
  local byte_array = {}
  local n_bytes = port:available()

  -- while n_bytes > 0 do
  if n_bytes > 0 then
        
    --gcs:send_text(0, string.format('Serial %i Bytes Received', bytes_target ) )
	gcs:send_text(0, string.format('Serial %i Bytes Received', n_bytes:tofloat() ) )
	  
    
    local buffer = {} -- table to buffer data
	
    -- only read a max of 512 bytes in a go
    -- this limits memory consumption
	local bytes_target = n_bytes - math.min(n_bytes, 512)
    while n_bytes > bytes_target do
        local serialbyte =  port:read() 
        table.insert(buffer,serialbyte)
        gcs:send_named_float('serialbyte', serialbyte)
        gcs:send_text(1, string.format('Serial Received: 0x%x',serialbyte )) 
        n_bytes = n_bytes - 1
    end
    
    file = io.open(file_name, "a")
    file:write(table.concat(buffer,',') .. '\n')
    file:close()
    
    -- write as plain text
    file = io.open(file_name_plain, "a")
    file:write(string.char(table.unpack(buffer)))    
    file:close()
    
    -- write as plain text    table.concat(buffer,',') 
--     gcs:send_text(1, string.format('Serial Received: %s', string.char(table.unpack(buffer) ) ) )
    gcs:send_text(1, 'Serial Received:' ) 
    gcs:send_text(1, table.concat(buffer,',') )
    
  end
  
  return update, 1000
  
end


function update ()    
    gcs:send_text(6, "update *****") 
    -- make sure we have the latest parameters
    update_user_parameters()   
	
    return get_position , 100
end

return update()

