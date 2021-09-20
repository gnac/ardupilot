dofile("sg.lua")

-- #include "testSgMessages.h"

--
-- First set of conditions
--
function testEncodeFlightId1()

    -- Test data.
    --    Flight id message data
    local id = sg_flightid_t;
    id.flightId = "00ZZAA99"

    --    Message ID
    -- uint8_t 
    local msgId = 0xAA;

    -- Test function:
    local buffer = {} -- [SG_MSG_LEN_FLIGHT];
    sgEncodeFlightId(buffer, id, msgId);

    -- Test results:
    assert(buffer[1] == SG_MSG_START_BYTE);        -- Start byte
    assert(buffer[2] == SG_MSG_TYPE_HOST_FLIGHT); -- Msg Type
    assert(buffer[3] == msgId);                    -- Msg ID
    assert(buffer[4] == SG_MSG_LEN_FLIGHT - 5);   -- Payload length
    assert(buffer[5] == 0x30);                     -- ID
    assert(buffer[6] == 0x30);                     -- ID
    assert(buffer[7] == 0x5A);                     -- ID
    assert(buffer[8] == 0x5A);                     -- ID
    assert(buffer[9] == 0x41);                     -- ID
    assert(buffer[10] == 0x41);                     -- ID
    assert(buffer[11] == 0x39);                    -- ID
    assert(buffer[12] == 0x39);                    -- ID
    assert(buffer[13] == 0);                       -- Reserved
    assert(buffer[14] == 0);                       -- Reserved
    assert(buffer[15] == 0);                       -- Reserved
    assert(buffer[16] == 0);                       -- Reserved
    assert(buffer[17] == 0x6A);                    -- Checksum

    return 0;
end

--
-- Second set of conditions
--
function testEncodeFlightId2()

    -- Test data.
    --    Flight id message data
    local id = sg_flightid_t;
    id.flightId = "        ";

    --    Message ID
    local msgId = 0x00;

    -- Test function:
    local buffer = {} --[SG_MSG_LEN_FLIGHT];
    sgEncodeFlightId(buffer, id, msgId);

    -- Test results:
    assert(buffer[1] == SG_MSG_START_BYTE);        -- Start byte
    assert(buffer[2] == SG_MSG_TYPE_HOST_FLIGHT); -- Msg Type
    assert(buffer[3] == msgId);                    -- Msg ID
    assert(buffer[4] == SG_MSG_LEN_FLIGHT - 5);   -- Payload length
    assert(buffer[5] == 0x20);                     -- ID
    assert(buffer[6] == 0x20);                     -- ID
    assert(buffer[7] == 0x20);                     -- ID
    assert(buffer[8] == 0x20);                     -- ID
    assert(buffer[9] == 0x20);                     -- ID
    assert(buffer[10]== 0x20);                     -- ID
    assert(buffer[11] == 0x20);                    -- ID
    assert(buffer[12] == 0x20);                    -- ID
    assert(buffer[13] == 0);                       -- Reserved
    assert(buffer[14] == 0);                       -- Reserved
    assert(buffer[15] == 0);                       -- Reserved
    assert(buffer[16] == 0);                       -- Reserved
    assert(buffer[17] == 0xB8);                    -- Checksum

    return 0;
end

--
-- Third set of conditions
--
function testEncodeFlightId3()

    -- Test data.
    --    Flight id message data
    local id = sg_flightid_t;
    id.flightId = "ZA      "

    --    Message ID
    local msgId = 0xFF;

    -- Test function:
    local buffer = {} -- [SG_MSG_LEN_FLIGHT];
    sgEncodeFlightId(buffer, id, msgId);

    -- Test results:
    assert(buffer[1] == SG_MSG_START_BYTE);        -- Start byte
    assert(buffer[2] == SG_MSG_TYPE_HOST_FLIGHT); -- Msg Type
    assert(buffer[3] == msgId);                    -- Msg ID
    assert(buffer[4] == SG_MSG_LEN_FLIGHT - 5);   -- Payload length
    assert(buffer[5] == 0x5A);                     -- ID
    assert(buffer[6] == 0x41);                     -- ID
    assert(buffer[7] == 0x20);                     -- ID
    assert(buffer[8] == 0x20);                     -- ID
    assert(buffer[9] == 0x20);                     -- ID
    assert(buffer[10]== 0x20);                     -- ID
    assert(buffer[11] == 0x20);                    -- ID
    assert(buffer[12] == 0x20);                    -- ID
    assert(buffer[13] == 0);                       -- Reserved
    assert(buffer[14] == 0);                       -- Reserved
    assert(buffer[15] == 0);                       -- Reserved
    assert(buffer[16] == 0);                       -- Reserved
    assert(buffer[17] == 0x12);                    -- Checksum

    return 0;
end

--
-- Documented in the header file.
--
function testEncodeFlightId()

    local res1 = testEncodeFlightId1();
    local res2 = testEncodeFlightId2();
    local res3 = testEncodeFlightId3();

end

testEncodeFlightId()
