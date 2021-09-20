--
--@copyright Copyright (c) 2021 Sagetech, Inc. All rights reserved.
--
--@file   testEncodeOperating.c
--@author Jacob.Garrison
--
--@date Feb 17, 2021
--     
dofile("sg.lua")


--
--First set of conditions
--
function testEncodeOperating1()

    -- Test data.
    --    Operating message data
    local op = sg_operating_t;
    op.squawk = 0x280 -- 01200;  -- octal!!!
    op.opMode = sg_op_mode_t.modeOn;
    op.savePowerUp = false;
    op.enableSqt = false;
    op.enableXBit = false;
    op.milEmergency = false;
    op.emergcType = sg_emergc_t.emergcNone;
    op.identOn = false;
    op.altUseIntrnl = true;
    op.altitude = -600;
    op.altHostAvlbl = false;
    op.altRes25 = false;
    op.climbValid = false;
    op.climbRate = 256;
    op.heading = 0.0;
    op.headingValid = true;
    op.airspd = 0;
    op.airspdValid = true;

    --    Message ID
    local msgId = 0xFF;

    -- Test function:
    local buffer = {} -- [SG_MSG_LEN_OPMSG];
    sgEncodeOperating(buffer, op, msgId);

    -- Test results:
    assert(buffer[1] == SG_MSG_START_BYTE);      -- Start byte
    assert(buffer[2] == SG_MSG_TYPE_HOST_OPMSG); -- Msg Type
    assert(buffer[3] == msgId);                  -- Msg ID
    assert(buffer[4] == SG_MSG_LEN_OPMSG - 5);   -- Payload length
    assert(buffer[5] == 0x02);                   -- Squawk
    assert(buffer[6] == 0x80);                   -- Squawk
    assert(buffer[7] == 0x01);                   -- Mode/Config
    assert(buffer[8] == 0x00);                   -- Emergc/Ident
    assert(buffer[9] == 0x80);                   -- Altitude
    assert(buffer[10] == 0x00);                   -- Altitude
    assert(buffer[11] == 0x80);                  -- Altitude Rate
    assert(buffer[12] == 0x00);                  -- Altitude Rate
    assert(buffer[13] == 0x80);                  -- Heading
    assert(buffer[14] == 0x00);                  -- Heading
    assert(buffer[15] == 0x80);                  -- Airspeed
    assert(buffer[16] == 0x00);                  -- Airspeed
    assert(buffer[17] == 0x3B);                  -- Checksum
           
    return 0;
end

--
--Second set of conditions
--
function testEncodeOperating2()

    -- Test data.
    --    Operating message data
    op = sg_operating_t ;
    op.squawk = tonumber("07600",8)
    op.opMode = sg_op_mode_t.modeStby;
    op.savePowerUp = false;
    op.enableSqt = true;
    op.enableXBit = true;
    op.milEmergency = false;
    op.emergcType = sg_emergc_t.emergcComm;
    op.identOn = true;
    op.altUseIntrnl = false;
    op.altitude = -1100;
    op.altHostAvlbl = true;
    op.altRes25 = false;
    op.climbValid = true;
    op.climbRate = 256;
    op.heading = 135.0;
    op.headingValid = false;
    op.airspd = 137;
    op.airspdValid = false;

    --    Message ID
    local msgId = 0x2B;

    -- Test function:
    local buffer = {} -- [SG_MSG_LEN_OPMSG];
    sgEncodeOperating(buffer, op, msgId);

    -- Test results:
    assert(buffer[1] == SG_MSG_START_BYTE);      -- Start byte
    assert(buffer[2] == SG_MSG_TYPE_HOST_OPMSG); -- Msg Type
    assert(buffer[3] == msgId);                  -- Msg ID
    assert(buffer[4] == SG_MSG_LEN_OPMSG - 5);   -- Payload length
    assert(buffer[5] == 0x0F);                   -- Squawk
    assert(buffer[6] == 0x80);                   -- Squawk
    assert(buffer[7] == 0x1A);                   -- Mode/Config
    assert(buffer[8] == 0x0C);                   -- Emergc/Ident
    assert(buffer[9] == 0x40);                   -- Altitude
    assert(buffer[10]== 0x01);                   -- Altitude
    assert(buffer[11] == 0x00);                  -- Altitude Rate
    assert(buffer[12] == 0x04);                  -- Altitude Rate
    assert(buffer[13] == 0x30);                  -- Heading
    assert(buffer[14] == 0x00);                  -- Heading
    assert(buffer[15] == 0x00);                  -- Airspeed
    assert(buffer[16] == 0x89);                  -- Airspeed
    assert(buffer[17] == 0x97);                  -- Checksum

    return 0;
end

--
--Third set of conditions
--
function testEncodeOperating3()

   -- Test data.
   --    Operating message data
   op = sg_operating_t ;
   op.squawk = tonumber("03333",8);
   op.opMode = sg_op_mode_t.modeOff;
   op.savePowerUp = true;
   op.enableSqt = false;
   op.enableXBit = false;
   op.milEmergency = true;
   op.emergcType = sg_emergc_t.emergcMed;
   op.identOn = false;
   op.altUseIntrnl = false;
   op.altitude = 25000;
   op.altHostAvlbl = false;
   op.altRes25 = false;
   op.climbValid = true;
   op.climbRate = -6400;
   op.heading = 358.0;
   op.headingValid = true;
   op.airspd = 1024;
   op.airspdValid = true;

   --    Message ID
   local msgId = 0x01;

   -- Test function:
   local buffer = {} -- [SG_MSG_LEN_OPMSG];
   sgEncodeOperating(buffer, op, msgId);

   -- Test results:
    assert(buffer[1]  == SG_MSG_START_BYTE);      -- Start byte
    assert(buffer[2]  == SG_MSG_TYPE_HOST_OPMSG); -- Msg Type
    assert(buffer[3]  == msgId);                  -- Msg ID
    assert(buffer[4]  == SG_MSG_LEN_OPMSG - 5);   -- Payload length
    assert(buffer[5]  == 0x06);                   -- Squawk
    assert(buffer[6]  == 0xDB);                   -- Squawk
    assert(buffer[7]  == 0x24);                   -- Mode/Config
    assert(buffer[8]  == 0x02);                   -- Emergc/Ident
    assert(buffer[9]  == 0x00);                   -- Altitude
    assert(buffer[10] == 0x00);                   -- Altitude
    assert(buffer[11] == 0xFF);                  -- Altitude Rate
    assert(buffer[12] == 0x9C);                  -- Altitude Rate
    assert(buffer[13] == 0xFF);                  -- Heading
    assert(0x49 <= buffer[14] and buffer[14] <= 0x4A);   -- Heading
    assert(buffer[15] == 0x84);                  -- Airspeed
    assert(buffer[16] == 0x00);                  -- Airspeed
    assert(buffer[17] == 0x28);                  -- Checksum

    return 0;
end

--
--Documented in the header file.
--
function testEncodeOperating()  

    local res1 = testEncodeOperating1();
    local res2 = testEncodeOperating2();
    local res3 = testEncodeOperating3();

    -- return res1 || res2 || res3;
end

testEncodeOperating()