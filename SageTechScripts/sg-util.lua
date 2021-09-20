-- local pathOfThisFile = ... -- pathOfThisFile is now 'lib.foo.bar'
-- local folderOfThisFile = (...):match("(.-)[^%.]+$") -- returns 'lib.foo.'
-- 
-- require(folderOfThisFile  .. sg-defs.lua)


-- dofile("./sg.lua")

-- https://stackoverflow.com/questions/48230472/boolean-to-number-in-lua
function bool_to_number(value)
  return value and 1 or 0
end


function calcChecksum(buffer) -- returns uint8_t

   local sum = 0x00
    len = #buffer
    --print (len)
   -- Add all bytes excluding checksum
    for i = 1, len, 1 do
        if buffer[i] then            
            sum = sum + buffer[i]
        end
    end  
    -- limit the value to 1 byte.
    if sum > 0xFF then
        sum = sum & 0xFF
     end

    return sum
end

function appendChecksum(buffer, len)
   local crc =  calcChecksum(buffer, len)
   table.insert(buffer, crc)
end

function calcGpsOffsetStatus(gps)
    local offsetStatus = 0
    if not gps.gpsValid then
        offsetStatus = 1 << 7
    end    
    if  gps.fdeFail then
        offsetStatus = offsetStatus | 1 << 6
    end
    
    if  gps.lngEast  then  
        offsetStatus = offsetStatus | 1 << 1
    end
    
    if  gps.latNorth then
        offsetStatus = offsetStatus | 1 
    end 
    
    return offsetStatus
                                   
end

function charArray2Buf(buffer, position, charArray) -- , uint8_t len)
    charArray = charArray:upper()
    len = #charArray
    for i = 1, len, 1 do    
        buffer[position + i - 1] = string.byte(string.sub(charArray,i,i))
    end
end

function uint162Buf(buffer, position, value)
    buffer[position] = (value & 0x0000FF00) >> 8;
    buffer[position+1] = (value & 0x000000FF);
end

--  Converts a uint16_t into its host message buffer format
-- 
--  @param bufferPos The address of the field's first corresponding buffer byte.
--  @param value     The uint16_t to be converted.
--
--  no return value, two buffer bytes are filled by reference
-- void uint322Buf(uint8_t *bufferPos, uint32_t value)
function uint322Buf(buffer, position, value)    
    buffer[position] =   (value & 0xFF000000) >> 24;
    buffer[position+1] = (value & 0x00FF0000) >> 16;
    buffer[position+2] = (value & 0x0000FF00) >> 8;
    buffer[position+3] = (value & 0x000000FF);
end

function float2Buf(buffer, position, value)

    local FLOAT_SIZE = 4
    -- ensure we are dealting with a float
    value =  value + 0.0
   
    -- c implementation
--    union
--    {
--       float val;
--       unsigned char bytes[FLOAT_SIZE];
--    } conversion;
    
    -- pack the string, then get the bytes.                
    b = string.pack('f', value)

    for i = 1, FLOAT_SIZE, 1 do
        buffer[position + i - 1] = string.byte(b, i);        
    end
  
end

--
--  Converts a uint32_t containing an ICAO into its 24-bit host message buffer format
--  
--  @param bufferPos The address of the field's first corresponding buffer byte.
--  @param icao      The uint32_t ICAO to be converted.
--  
--  no return value, three buffer bytes are filled by reference
--  
--  @warning icao parameter must be between 0x000000 and 0xFFFFFF
--
function icao2Buf(buffer, position, icao)

    -- icao is an uint32_t in c
    buffer[position] = (icao & 0x00FF0000) >> 16;
    buffer[position+1] = (icao & 0x0000FF00) >> 8;
    buffer[position+2] = (icao & 0x000000FF);

end
