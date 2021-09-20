dofile("sg.lua")




function main()
    -- testOffsetStatus()
    testEncodeGPS1()
    testEncodeGPS2()
end

-- typedef struct
sg_gps_t = 
{
-- char         
    longitude,  -- [12]  -- The absolute value of longitude (degree and decimal minute)
-- char         
    latitude,    --[11]   -- The absolute value of latitude (degree and decimal minute)
-- char         
    grdSpeed,    -- [7]    -- The GPS over-ground speed (knots)
-- char         
    grdTrack,    -- [9]    -- The GPS track referenced from True North (degrees, clockwise)
-- bool         
    latNorth,       -- The aircraft is in the northern hemisphere
-- bool         
    lngEast,        -- The aircraft is in the eastern hemisphere
-- bool         
    fdeFail,        -- True = A satellite error has occurred
-- bool         
    gpsValid,       -- True = GPS data is valid
-- char         
    timeOfFix,   --[11]  -- Time, relative to midnight UTC (can optionally be filled spaces)
-- float        
    height,         -- The height above the WGS-84 ellipsoid (meters)
-- float        
    hpl,            -- The Horizontal Protection Limit (meters)
-- float        
    hfom,           -- The Horizontal Figure of Merit (meters)
-- float        
    vfom,           -- The Vertical Figure of Merit (meters)
-- sg_nacv_t    
    nacv,           -- Navigation Accuracy for Velocity (meters/second)
} 




function testEncodeGPS1()

    -- Test data.
    --    Gps message data
    gps = sg_gps_t;
    gps.longitude = "12219.75002";
    gps.latitude  = "4737.22400";
    gps.grdSpeed  = "1126.0";
    gps.grdTrack  = "077.5200";
    gps.latNorth = true;
    gps.lngEast = false;
    gps.fdeFail = true;
    gps.gpsValid = true;
    gps.timeOfFix = "223323.000";
    gps.height = -200.0;
    gps.hpl = 5.0;
    gps.hfom = 12.0;
    gps.vfom = 20.0;
    gps.nacv = 0 -- nacvUnknown;

    --    Message ID
    msgId = 0xAA;

    -- Test function:
    buffer= {}  -- [SG_MSG_LEN_GPS];

    sgEncodeGPS(buffer, gps, msgId);

    -- Test results:
    print ("Check GPS1 Results")
    
    assert(buffer[1]  == SG_MSG_START_BYTE);        -- Start byte
    assert(buffer[2]  == SG_MSG_TYPE_HOST_GPS);     -- Msg Type
    assert(buffer[3]  == msgId);                    -- Msg ID
    assert(buffer[4]  == SG_MSG_LEN_GPS - 5);       -- Payload length
    assert(buffer[5]  == 0x31);                     -- Lng
    assert(buffer[6]  == 0x32);                     -- Lng
    assert(buffer[7]  == 0x32);                     -- Lng
    assert(buffer[8]  == 0x31);                     -- Lng
    assert(buffer[9]  == 0x39);                     -- Lng
    assert(buffer[10] == 0x2E);                     -- Lng
    assert(buffer[11] == 0x37);                    -- Lng
    assert(buffer[12] == 0x35);                    -- Lng
    assert(buffer[13] == 0x30);                    -- Lng
    assert(buffer[14] == 0x30);                    -- Lng
    assert(buffer[15] == 0x32);                    -- Lng
    assert(buffer[16] == 0x34);                    -- Lat
    assert(buffer[17] == 0x37);                    -- Lat
    assert(buffer[18] == 0x33);                    -- Lat
    assert(buffer[19] == 0x37);                    -- Lat
    assert(buffer[20] == 0x2E);                    -- Lat
    assert(buffer[21] == 0x32);                    -- Lat
    assert(buffer[22] == 0x32);                    -- Lat
    assert(buffer[23] == 0x34);                    -- Lat
    assert(buffer[24] == 0x30);                    -- Lat
    assert(buffer[25] == 0x30);                    -- Lat
    assert(buffer[26] == 0x31);                    -- Speed
    assert(buffer[27] == 0x31);                    -- Speed
    assert(buffer[28] == 0x32);                    -- Speed
    assert(buffer[29] == 0x36);                    -- Speed
    assert(buffer[30] == 0x2E);                    -- Speed
    assert(buffer[31] == 0x30);                    -- Speed
    assert(buffer[32] == 0x30);                    -- Track
    assert(buffer[33] == 0x37);                    -- Track
    assert(buffer[34] == 0x37);                    -- Track
    assert(buffer[35] == 0x2E);                    -- Track
    assert(buffer[36] == 0x35);                    -- Track
    assert(buffer[37] == 0x32);                    -- Track
    assert(buffer[38] == 0x30);                    -- Track
    assert(buffer[39] == 0x30);                    -- Track
    assert(buffer[40] == 0x41);                    -- Status
    assert(buffer[41] == 0x32);                    -- Time
    assert(buffer[42] == 0x32);                    -- Time
    assert(buffer[43] == 0x33);                    -- Time
    assert(buffer[44] == 0x33);                    -- Time
    assert(buffer[45] == 0x32);                    -- Time
    assert(buffer[46] == 0x33);                    -- Time
    assert(buffer[47] == 0x2E);                    -- Time
    assert(buffer[48] == 0x30);                    -- Time
    assert(buffer[49] == 0x30);                    -- Time
    assert(buffer[50] == 0x30);                    -- Time
    assert(buffer[51] == 0x00);                    -- Height
    assert(buffer[52] == 0x00);                    -- Height
    assert(buffer[53] == 0x48);                    -- Height
    assert(buffer[54] == 0xC3);                    -- Height
    assert(buffer[55] == 0x00);                    -- HPL
    assert(buffer[56] == 0x00);                    -- HPL
    assert(buffer[57] == 0xA0);                    -- HPL
    assert(buffer[58] == 0x40);                    -- HPL
    assert(buffer[59] == 0x00);                    -- HFOM
    assert(buffer[60] == 0x00);                    -- HFOM
    assert(buffer[61] == 0x40);                    -- HFOM
    assert(buffer[62] == 0x41);                    -- HFOM
    assert(buffer[63] == 0x00);                    -- VFOM
    assert(buffer[64] == 0x00);                    -- VFOM
    assert(buffer[65] == 0xA0);                    -- VFOM
    assert(buffer[66] == 0x41);                    -- VFOM
    assert(buffer[67] == 0x00);                    -- NACv
    assert(buffer[68] == 0xF3);                    -- Checksum
   
    print ("GPS1 Successful!")
end

-- /*
--  * Second set of conditions
--  */
function testEncodeGPS2()

    -- Test data.
    --    Gps message data
    gps = sg_gps_t;


    -- Test data.
    --    Gps message data

    gps.longitude = "05833.91482";
    gps.latitude  = "4917.11266";
    gps.grdSpeed  = "125.80";
    gps.grdTrack  = "185.2000";
    gps.latNorth = false;
    gps.lngEast = true;
    gps.fdeFail = false;
    gps.gpsValid = false;
    gps.timeOfFix = "085601.010";
    gps.height = 15;
    gps.hpl = 60;
    gps.hfom = 176;
    gps.vfom = 75;
    gps.nacv = sg_nacv_t.nacv0dot3 -- 44; -- nacv0dot3

    --    Message ID
    local msgId = 0x02;

    -- Test function:
    buffer = {} 
    sgEncodeGPS(buffer, gps, msgId);
    
    print ("Check GPS2 Results")

   -- Test results:   
    assert(buffer[1] == SG_MSG_START_BYTE);        -- Start byte
    assert(buffer[2] == SG_MSG_TYPE_HOST_GPS);     -- Msg Type
    assert(buffer[3] == msgId);                    -- Msg ID
    assert(buffer[4] == SG_MSG_LEN_GPS - 5);       -- Payload length
    assert(buffer[5] == 0x30);                     -- Lng
    assert(buffer[6] == 0x35);                     -- Lng
    assert(buffer[7] == 0x38);                     -- Lng
    assert(buffer[8] == 0x33);                     -- Lng
    assert(buffer[9] == 0x33);                     -- Lng
    assert(buffer[10]  == 0x2E);                     -- Lng
    assert(buffer[11] == 0x39);                    -- Lng
    assert(buffer[12] == 0x31);                    -- Lng
    assert(buffer[13] == 0x34);                    -- Lng
    assert(buffer[14] == 0x38);                    -- Lng
    assert(buffer[15] == 0x32);                    -- Lng
    assert(buffer[16] == 0x34);                    -- Lat
    assert(buffer[17] == 0x39);                    -- Lat
    assert(buffer[18] == 0x31);                    -- Lat
    assert(buffer[19] == 0x37);                    -- Lat
    assert(buffer[20] == 0x2E);                    -- Lat
    assert(buffer[21] == 0x31);                    -- Lat
    assert(buffer[22] == 0x31);                    -- Lat
    assert(buffer[23] == 0x32);                    -- Lat
    assert(buffer[24] == 0x36);                    -- Lat
    assert(buffer[25] == 0x36);                    -- Lat
    assert(buffer[26] == 0x31);                    -- Speed
    assert(buffer[27] == 0x32);                    -- Speed
    assert(buffer[28] == 0x35);                    -- Speed
    assert(buffer[29] == 0x2E);                    -- Speed
    assert(buffer[30] == 0x38);                    -- Speed
    assert(buffer[31] == 0x30);                    -- Speed
    assert(buffer[32] == 0x31);                    -- Track
    assert(buffer[33] == 0x38);                    -- Track
    assert(buffer[34] == 0x35);                    -- Track
    assert(buffer[35] == 0x2E);                    -- Track
    assert(buffer[36] == 0x32);                    -- Track
    assert(buffer[37] == 0x30);                    -- Track
    assert(buffer[38] == 0x30);                    -- Track
    assert(buffer[39] == 0x30);                    -- Track
    assert(buffer[40] == 0x82);                    -- Status
    assert(buffer[41] == 0x30);                    -- Time
    assert(buffer[42] == 0x38);                    -- Time
    assert(buffer[43] == 0x35);                    -- Time
    assert(buffer[44] == 0x36);                    -- Time
    assert(buffer[45] == 0x30);                    -- Time
    assert(buffer[46] == 0x31);                    -- Time
    assert(buffer[47] == 0x2E);                    -- Time
    assert(buffer[48] == 0x30);                    -- Time
    assert(buffer[49] == 0x31);                    -- Time
    assert(buffer[50] == 0x30);                    -- Time
    assert(buffer[51] == 0x00);                    -- Height
    assert(buffer[52] == 0x00);                    -- Height
    assert(buffer[53] == 0x70);                    -- Height
    assert(buffer[54] == 0x41);                    -- Height
    assert(buffer[55] == 0x00);                    -- HPL
    assert(buffer[56] == 0x00);                    -- HPL
    assert(buffer[57] == 0x70);                    -- HPL
    assert(buffer[58] == 0x42);                    -- HPL
    assert(buffer[59] == 0x00);                    -- HFOM
    assert(buffer[60] == 0x00);                    -- HFOM
    assert(buffer[61] == 0x30);                    -- HFOM
    assert(buffer[62] == 0x43);                    -- HFOM
    assert(buffer[63] == 0x00);                    -- VFOM
    assert(buffer[64] == 0x00);                    -- VFOM
    assert(buffer[65] == 0x96);                    -- VFOM
    assert(buffer[66] == 0x42);                    -- VFOM
    assert(buffer[67] == 0x40);                    -- NACv
    assert(buffer[68] == 0x4A);                    -- ChecksumA

    print ("GPS2 Successful!")
   return 0;
end



-- this needs to go at the end
main()

