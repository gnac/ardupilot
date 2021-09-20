dofile("sg.lua")
dofile("sg-util.lua")

print("SG_MSG_LEN_INSTALL = " .. SG_MSG_LEN_INSTALL)


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

function testOffsetStatus()
    local gps = sg_gps_t
    local offset = 0
    
    gps.gpsValid = true
    gps.fdeFail  = true
    gps.lngEast  = true
    gps.latNorth = true    
    offset = calcOffsetStatus(gps)
    print(offset)
    
    gps.gpsValid = false
    gps.fdeFail  = false
    gps.lngEast  = false
    gps.latNorth = false
    offset = calcOffsetStatus(gps)
    print(offset)
end      

function main()
    
    local val = 0xFA55
    local buffer = {}
    
    uint162Buf(buffer, 1, val)
    
    print( string.format("0x%x",buffer[1]) )
    print( string.format("0x%x",buffer[2]) )

end

main()