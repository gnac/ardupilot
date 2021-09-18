-- lib/foo/bar.lua
-- local pathOfThisFile = ... -- pathOfThisFile is now 'lib.foo.bar'
-- local folderOfThisFile = (...):match("(.-)[^%.]+$") -- returns 'lib.foo.'
-- 
-- require(folderOfThisFile  .. sg-defs.lua)

--package.path = './?.lua;' .. package.path
-- require("sg-defs.lua")

-- define SG_MSG_LEN_INSTALL             41
-- define SG_MSG_LEN_FLIGHT              17
-- define SG_MSG_LEN_OPMSG               17
-- define SG_MSG_LEN_GPS                 68
-- define SG_MSG_LEN_DATAREQ             9
-- define SG_MSG_LEN_TARGETREQ           12
-- define SG_MSG_LEN_MODE                10


function main()
    doCrcCheck()
end



function doCrcCheck()
    
    local buffer = {0xAA, 0x05 , 0x25 , 0x04 , 0x83 , 0x00 , 0x00 ,0x00 } -- 0x5B
    local crc = calcChecksum(buffer)
    print(string.format("CRC = 0x%x", crc))

    buffer = {0xAA, 0x05, 0x00, 0x04, 0x83 , 0x00 , 0x00 , 0x00 } -- 36
    crc = calcChecksum(buffer, 8)
    print(string.format("CRC = 0x%x", crc))    

    buffer = {0x80, 0x00 , 0x06 , 0x05 , 0x00 , 0x22 , 0x80 , 0x00 , 0x00 , 0xD7 , 0xAA , 0x83 , 0x00 , 0x0A , 0x09 , 0x09 , 0x87 , 0x53 , 0x28 , 0xA0 , 0x9F , 0xFF , 0xF8 , 0xC0} -- 41
    crc = calcChecksum(buffer)
    
    -- Rx AA 80 02 06 05 02 23 80 00 00 DC AA 83 02 0A 09 09 87 53 28 A0 17 FF F8 C0 BB
    buffer = 
        {  0xAA, 0x80, 0x02 , 0x06 , 0x05 , 0x02 , 
            0x23 , 0x80 , 0x00 , 0x00 } -- 0xDC 
    crc = calcChecksum(buffer)
    print(string.format("CRC = 0x%x", crc))    
    
    -- Rx AA 83 02 0A 09 09 87 53 28 A0 17 FF F8 C0 BB
    buffer = 
            {0xAA , 0x83 , 0x02 , 0x0A , 0x09 , 
             0x09 , 0x87 , 0x53 , 0x28 , 0xA0 , 
             0x17 , 0xFF , 0xF8 , 0xC0 } -- BB    
    crc = calcChecksum(buffer)       
    print(string.format("CRC = 0x%x", crc))    
    
    -- 06:57:34.217 Tx AA 03 03 0C 02 80 00 00 80 74 80 00 00 00 00 00 B2
    buffer = 
            {
             0xAA , 0x03 , 0x03 , 0x0C , 0x02, 
             0x80 , 0x00 , 0x00 , 0x80 , 0x74 , 
             0x80 , 0x00 , 0x00 , 0x00 , 0x00 , 
             0x00 } -- B2
    crc = calcChecksum(buffer)    
    print(string.format("CRC = 0x%x", crc))     

        
end


function calcChecksum(buffer) -- returns uint8_t

   local sum = 0x00
    len = #buffer
    print (len)
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

-- do this last so it can load everything above.
main()
