dofile("sg.lua")


--
-- First set of conditions
--
function testEncodeTargetReq1()

    -- Test data.
    --    Target request message data
    tgt = sg_targetreq_t;
    tgt.reqType = sg_reporttype_t.reportAuto;
    tgt.transmitPort = sg_transmitport_t.transmitSource;
    tgt.maxTargets = 404;
    tgt.icao = 0xF092E4;
    tgt.stateVector = true;
    tgt.modeStatus = false;
    tgt.targetState = true;
    tgt.airRefVel = false;
    tgt.tisb = true;
    tgt.military = false;
    tgt.commA = true;
    tgt.ownship = false;

    --    Message ID
    -- uint8_t 
    msgId = 0xCD;

    -- Test function:
    -- uint8_t 
    local buffer = {} -- [SG_MSG_LEN_TARGETREQ];
    sgEncodeTargetReq(buffer, tgt, msgId);

    -- Test results:
    assert(buffer[1] == SG_MSG_START_BYTE);          -- Start byte
    assert(buffer[2] == SG_MSG_TYPE_HOST_TARGETREQ); -- Msg Type
    assert(buffer[3] == msgId);                      -- Msg ID
    assert(buffer[4] == SG_MSG_LEN_TARGETREQ - 5);   -- Payload length
    assert(buffer[5] == 0x00);                       -- Report type
    assert(buffer[6] == 0x01);                       -- Max targets
    assert(buffer[7] == 0x94);                       -- Max targets
    assert(buffer[8] == 0xF0);                       -- Target ID
    assert(buffer[9] == 0x92);                       -- Target ID
    assert(buffer[10]== 0xE4);                       -- Target ID
    assert(buffer[11] == 0x55);                      -- Requested reports
    assert(buffer[12] == 0xD9);                      -- Checksum

    return 0;
end

--
-- Second set of conditions
--
function testEncodeTargetReq2()

    -- Test data.
    --    Target request message data
    tgt = sg_targetreq_t ;
    tgt.reqType = sg_reporttype_t.reportNone;
    tgt.transmitPort = sg_transmitport_t.transmitCom1;
    tgt.maxTargets = 90;
    tgt.icao = 0x003421;
    tgt.stateVector = false;
    tgt.modeStatus = false;
    tgt.targetState = true;
    tgt.airRefVel = true;
    tgt.tisb = true;
    tgt.military = true;
    tgt.commA = false;
    tgt.ownship = false;

    --    Message ID
    -- uint8_t 
    msgId = 0xA0;

    -- Test function:
    -- uint8_t     
    local buffer = {} -- [SG_MSG_LEN_TARGETREQ];
    sgEncodeTargetReq(buffer, tgt, msgId);

    -- Test results:
    assert(buffer[1] == SG_MSG_START_BYTE);          -- Start byte
    assert(buffer[2] == SG_MSG_TYPE_HOST_TARGETREQ); -- Msg Type
    assert(buffer[3] == msgId);                      -- Msg ID
    assert(buffer[4] == SG_MSG_LEN_TARGETREQ - 5);   -- Payload length
    assert(buffer[5] == 0x83);                       -- Report type
    assert(buffer[6] == 0x00);                       -- Max targets
    assert(buffer[7] == 0x5A);                       -- Max targets
    assert(buffer[8] == 0x00);                       -- Target ID
    assert(buffer[9] == 0x34);                       -- Target ID
    assert(buffer[10]== 0x21);                       -- Target ID
    assert(buffer[11] == 0x3C);                      -- Requested reports
    assert(buffer[12] == 0xCA);                      -- Checksum

    return 0;
end

--
-- Third set of conditions
--
function testEncodeTargetReq3()

    -- Test data.
    --    Target request message data
    tgt = sg_targetreq_t ;
    tgt.reqType = sg_reporttype_t.reportIcao;
    tgt.transmitPort = sg_transmitport_t.transmitEth;
    tgt.maxTargets = 01;
    tgt.icao = 0xABC123;
    tgt.stateVector = true;
    tgt.modeStatus = true;
    tgt.targetState = true;
    tgt.airRefVel = false;
    tgt.tisb = false;
    tgt.military = false;
    tgt.commA = false;
    tgt.ownship = false;

    --    Message ID
    -- uint8_t 
    msgId = 0x01;

    -- Test function:
   
    local buffer = {} -- [SG_MSG_LEN_TARGETREQ];
    sgEncodeTargetReq(buffer, tgt, msgId);

    -- Test results:
    assert(buffer[1] == SG_MSG_START_BYTE);          -- Start byte
    assert(buffer[2] == SG_MSG_TYPE_HOST_TARGETREQ); -- Msg Type
    assert(buffer[3] == msgId);                      -- Msg ID
    assert(buffer[4] == SG_MSG_LEN_TARGETREQ - 5);   -- Payload length
    assert(buffer[5] == 0xC2);                       -- Report type
    assert(buffer[6] == 0x00);                       -- Max targets
    assert(buffer[7] == 0x01);                       -- Max targets
    assert(buffer[8] == 0xAB);                       -- Target ID
    assert(buffer[9] == 0xC1);                       -- Target ID
    assert(buffer[10]== 0x23);                       -- Target ID
    assert(buffer[11] == 0x07);                      -- Requested reports
    assert(buffer[12] == 0x16);                      -- Checksum

    return 0;
end

function testEncodeTargetReq()

    print("testEncodeTargetReq1")
    local res1 = testEncodeTargetReq1();
    print("testEncodeTargetReq2")
    local res2 = testEncodeTargetReq2();
    print("testEncodeTargetReq3")
    local res3 = testEncodeTargetReq3();

    return res1 or res2 or res3;
    
end

testEncodeTargetReq()
