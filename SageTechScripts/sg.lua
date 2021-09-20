dofile( "sg-types.lua" )
dofile( "sg-util.lua" )

-- 
-- @copyright Copyright (c) 2021 Sagetech, Inc. All rights reserved.
--
-- @author dwh
--
-- @date   Feb 10, 2021
--
-- Sagetech protocol for host message building and parsing.
--
-- This module performs both the following:
--    1. Parses raw Sagetech host messages defined in the SDIM and
--       returns a populated struct dataset of the message type.
--    2. Receives a populated struct dataset of the desired host message
--       and returns the corresponding raw message data buffer.

--[[
The process and command sequences for the Operational Use Case is outlined in the following steps.
1.  Load Flight ID - Construct and send Flight ID Message.
2.  Receive and decode Acknowledge Message (ACK)
3.  Receive and decode Flight ID Response Message
4.  Construct and send Operating Message (Continue to construct and send Operating Message at 1-5 Hz 34
5.  Receive and decode Acknowledge Message (ACK)
6.  Construct and send GPS Navigation Data Message if sourced by Host, (Continue to construct and send GPS Data Message at 1-5 Hz 35
7.  Receive and decode Acknowledge Message (ACK)
8.  Send Target Request Message
9.  Receive and decode Acknowledge Message (ACK)
10. Receive and decode ADS-B In Report Messages
]]


-- Convert flight identification struct to the raw buffer format.
--
-- @param[out] buffer An empty buffer to contain the raw flight identification message.
-- @param[in]  id     The flight id struct with fields populated.
-- @param[in]  msgId  The sequence number for the message.
--
-- @return true if successful or false on failure.
--
-- @warning data in id parameter must be pre-validated.

--bool sgEncodeFlightId(uint8_t--buffer, sg_flightid_t--id, uint8_t msgId)
function sgEncodeFlightId(buffer, id, msgId)                      

    local OFFSET_ID       = 0    -- the flight id offset in the payload.
    local OFFSET_RSVD     = 8   -- the reserved field offset in the payload.
    local SG_PAYLOAD_LEN_FLIGHT  = (SG_MSG_LEN_FLIGHT - 5) -- the payload length.
    
    -- populate header
    buffer[1]       = SG_MSG_START_BYTE;
    buffer[2]       = SG_MSG_TYPE_HOST_FLIGHT;
    buffer[3]       = msgId;
    buffer[4]       = SG_PAYLOAD_LEN_FLIGHT;

    -- populate flight identification
    charArray2Buf(buffer, (PBASE + OFFSET_ID), id.flightId, ID_LEN);

    -- populate reserved field
    uint322Buf(buffer, (PBASE + OFFSET_RSVD), 0);

    -- populate checksum
    appendChecksum(buffer, SG_MSG_LEN_FLIGHT);

    return true;
    
end

                      
-- Convert operating message struct to the raw buffer format.
-- 
-- @param[out] buffer An empty buffer to contain the raw operating message.
-- @param[in]  op     The operating message struct with fields populated.
-- @param[in]  msgId  The sequence number for the message.
--
-- @return true if successful or false on failure.
--
-- @warning data in op parameter must be pre-validated.
-- @warning op.sqawk must be converted from octal to hex (or decimal) eg op.squawk = 0x280 -- 01200;  
-- @NOTE: you can use tonumber() to convert an octal string to decimal.
--      eg           op.squawk = tonumber("01200", 8);  -- octal!!! 
-- or convert desired octal value to string, then back again.
--     octalS = tostring(1200)    -- converts to "1200"
--     print("Octal string " .. octalS )
--     octalO = tonumber(octalS, 8) -- converss "01200" to 640 in decimal
--     print("Octal value in Decimal " .. octalO )
--
-- bool sgEncodeOperating(uint8_t--buffer, sg_operating_t--op, uint8_t msgId)
function sgEncodeOperating(buffer, op, msgId)

    local SG_PAYLOAD_LEN_OPMSG = SG_MSG_LEN_OPMSG - 5  -- the payload length.

    local OFFSET_SQUAWK        = 0   -- the squawk code offset in the payload.
    local OFFSET_CONFIG        = 2   -- the mode/config offset in the payload.
    local OFFSET_EMRG_ID       = 3   -- the emergency flag offset in the payload.
    local OFFSET_ALT           = 4   -- the altitude offset in the payload.
    local OFFSET_RATE          = 6   -- the climb rate offset in the payload.
    local OFFSET_HEADING       = 8   -- the heading offset in the payload.
    local OFFSET_AIRSPEED      = 10  -- the airspeed offset in the payload.
    
    -- populate header
    buffer[1]       = SG_MSG_START_BYTE;
    buffer[2]       = SG_MSG_TYPE_HOST_OPMSG;
    buffer[3]       = msgId;
    buffer[4]       = SG_PAYLOAD_LEN_OPMSG;

    -- populate Squawk code    
    uint162Buf(buffer, (PBASE + OFFSET_SQUAWK), op.squawk);

    -- populate Mode/Config
    buffer[PBASE + OFFSET_CONFIG] = bool_to_number(op.milEmergency) << 5 |
                                    bool_to_number(op.enableXBit)   << 4 |
                                    bool_to_number(op.enableSqt)    << 3 |
                                    bool_to_number(op.savePowerUp)  << 2 |
                                    op.opMode;


    -- populate Emergency/Ident
    buffer[PBASE + OFFSET_EMRG_ID] = bool_to_number(op.identOn)     << 3 |
                                     op.emergcType;

    -- populate Altitude
    local altCode = 0;
    if (op.altUseIntrnl) then
    
        altCode = 0x8000;    
        
    elseif (op.altHostAvlbl) then
    
        -- 100 foot encoding conversion
        altCode = (op.altitude + 1200) / 100;

        if (op.altRes25 == true) then        
            altCode = altCode * 4;
        end

        -- 'Host altitude available' flag
        altCode = altCode + 0x4000;
        
    end
    
    uint162Buf(buffer, (PBASE + OFFSET_ALT), altCode);

    -- populate Altitude Rate    
    local rate = op.climbRate / 64;
    -- floor heading, rounding is not expected. 
    -- in C, 63/64 as an int casts to zero.
    rate = math.floor(rate)
    
    if (op.climbValid == false) then
        rate = 0x8000;
    end

    uint162Buf(buffer, (PBASE + OFFSET_RATE), rate);

    -- populate Heading
    --    conversion: heading * ( pow(2, 15) / 360 )
    local heading = op.heading * 32768 / 360;
    
    if (op.headingValid == true) then
        heading = heading + 0x8000;
    end
    
    -- floor heading, rounding will generate different resutls that the c test for  testEncodeOperating3
    heading = math.floor(heading)
    
    uint162Buf(buffer, (PBASE + OFFSET_HEADING), heading );

    -- populate Airspeed
    local airspeed = op.airspd;
    
    if op.airspdValid == true then
        airspeed = airspeed + 0x8000;
    end
    
    uint162Buf(buffer, (PBASE + OFFSET_AIRSPEED), airspeed);

    -- populate checksum
    appendChecksum(buffer, SG_MSG_LEN_OPMSG);

    return true;
    
end

                       
-- TODO: Create GPS helper functions to convert other data types --> char buffers
-- Convert GPS message struct to the raw buffer format.
--
-- @param[out] buffer An empty buffer to contain the raw GPS message.
-- @param[in]  gps    The GPS message struct with fields populated.
-- @param[in]  msgId  The sequence number for the message.
--
-- @return true if successful or false on failure.
--
-- @warning data in gps parameter must be pre-validated.
-- bool sgEncodeGPS(uint8_t--buffer, sg_gps_t--gps, uint8_t msgId)
function sgEncodeGPS(buffer, gps, msgId)

    local SG_PAYLOAD_LEN_GPS  = SG_MSG_LEN_GPS - 5  -- the payload length.
    local OFFSET_LONGITUDE    =     0   -- the longitude offset in the payload.
    local OFFSET_LATITUDE     =    11   -- the latitude offset in the payload.
    local OFFSET_SPEED        =    21   -- the ground speed offset in the payload.
    local OFFSET_TRACK        =    27   -- the ground track offset in the payload.
    local OFFSET_STATUS       =    35   -- the hemisphere/data status offset in the payload.
    local OFFSET_TIME         =    36   -- the time of fix offset in the payload.
    local OFFSET_HEIGHT       =    46   -- the GNSS height offset in the payload.
    local OFFSET_HPL          =    50   -- the horizontal protection limit offset in the payload.
    local OFFSET_HFOM         =    54   -- the horizontal figure of merit offset in the payload.
    local OFFSET_VFOM         =    58   -- the vertical figure of merit offset in the payload.
    local OFFSET_NACV         =    62   -- the navigation accuracy for velocity offset in the payload.

    local LEN_LNG             =    11   -- bytes in the longitude field
    local LEN_LAT             =    10   -- bytes in the latitude field
    local LEN_SPD             =     6   -- bytes in the speed over ground field
    local LEN_TRK             =     8   -- bytes in the ground track field
    local LEN_TIME            =    10   -- bytes in the time of fix field

    -- Validate all data inputs (debug mode, only)
    -- checkGPSInputs(gps);

    -- populate header
    buffer[1]       = SG_MSG_START_BYTE;
    buffer[2]       = SG_MSG_TYPE_HOST_GPS;
    buffer[3]       = msgId;
    buffer[4]       = SG_PAYLOAD_LEN_GPS;

    -- populate longitude
    charArray2Buf(buffer, PBASE + OFFSET_LONGITUDE, gps.longitude) --, LEN_LNG);

    -- populate latitude
    charArray2Buf(buffer, PBASE + OFFSET_LATITUDE, gps.latitude) --, LEN_LAT);

    -- populate ground speed
    charArray2Buf(buffer, PBASE + OFFSET_SPEED, gps.grdSpeed) --, LEN_SPD);

    -- populate ground track
    charArray2Buf(buffer, PBASE + OFFSET_TRACK, gps.grdTrack) --, LEN_TRK);

    -- populate hemisphere/data status

    -- buffer[PBASE + OFFSET_STATUS] = !gps->gpsValid  << 7 |
    --                                gps->fdeFail    << 6 |
    --                                gps->lngEast    << 1 |
    --                                gps->latNorth; 
    buffer[PBASE + OFFSET_STATUS] = calcGpsOffsetStatus(gps) 


    -- populate time of fix
    charArray2Buf(buffer, PBASE + OFFSET_TIME, gps.timeOfFix, LEN_TIME);

    -- populate gnss height
    float2Buf(buffer, PBASE + OFFSET_HEIGHT, gps.height);

    -- populate HPL
    float2Buf(buffer, PBASE + OFFSET_HPL, gps.hpl);

    -- populate HFOM
    float2Buf(buffer, PBASE + OFFSET_HFOM, gps.hfom);

    -- populate VFOM
    float2Buf(buffer, PBASE + OFFSET_VFOM, gps.vfom);

    -- populate NACv
    buffer[PBASE + OFFSET_NACV] = gps.nacv << 4;

    -- populate checksum
    appendChecksum(buffer);

    return true;
end

-- Convert target request message struct to the raw buffer format.
--
-- @param[out] buffer An empty buffer to contain the raw target request message.
-- @param[in]  tgt    The target request message struct with fields populated.
-- @param[in]  msgId  The sequence number for the message.
--
-- @return true if successful or false on failure.
--
-- @warning data in tgt parameter must be pre-validated.

-- bool sgEncodeTargetReq(uint8_t buffer, sg_targetreq_t tgt, uint8_t msgId)                 
function sgEncodeTargetReq(buffer, tgt, msgId)

    
    local SG_PAYLOAD_LEN_TARGETREQ   = SG_MSG_LEN_TARGETREQ - 5  --  the payload length.

    local OFFSET_REQ_TYPE       = 0   --  the adsb reporting type and transmit port offset
    local OFFSET_MAX_TARGETS    = 1   --  the maximum number of targets offset
    local OFFSET_ICAO           = 3   --  the requested target icao offset
    local OFFSET_REPORTS        = 6   --  the requested report type offset

    -- Validate all data inputs (debug mode, only)
    -- checkTargetReqInputs(tgt);

    -- populate header
    buffer[1]       = SG_MSG_START_BYTE;
    buffer[2]       = SG_MSG_TYPE_HOST_TARGETREQ;
    buffer[3]       = msgId;
    buffer[4]       = SG_PAYLOAD_LEN_TARGETREQ;

    -- populate Request Type
    buffer[PBASE + OFFSET_REQ_TYPE] = tgt.transmitPort << 6 |
                                      tgt.reqType;

    -- populate Max Targets
    uint162Buf(buffer, (PBASE + OFFSET_MAX_TARGETS), tgt.maxTargets);

    -- populate Requested ICAO
    icao2Buf(buffer, (PBASE + OFFSET_ICAO), tgt.icao);

    -- populated Requested Reports
    buffer[PBASE + OFFSET_REPORTS] = bool_to_number(tgt.ownship)    << 7 |
                                    bool_to_number(tgt.commA)       << 6 |
                                    bool_to_number(tgt.military)    << 5 |
                                    bool_to_number(tgt.tisb)        << 4 |
                                    bool_to_number(tgt.airRefVel)   << 3 |
                                    bool_to_number(tgt.targetState) << 2 |
                                    bool_to_number(tgt.modeStatus)  << 1 |
                                    bool_to_number(tgt.stateVector);

    -- populate checksum
    appendChecksum(buffer, SG_MSG_LEN_TARGETREQ);

    return true;

end
                        
--[[
-- Convert install message struct to the raw buffer format.
-- 
-- @param[out] buffer An empty buffer to contain the raw install message.
-- @param[in]  stl    The install message struct with fields populated.
-- @param[in]  msgId  The sequence number for the message.
--
-- @return true if successful or false on failure.
--
-- @warning data in stl parameter must be pre-validated.

bool sgEncodeInstall(uint8_t--buffer, sg_install_t--stl, uint8_t msgId)



-- Convert data request message struct to the raw buffer format.
--
-- @param[out] buffer An empty buffer to contain the raw target request message.
-- @param[in]  data   The data request message struct with fields populated.
-- @param[in]  msgId  The sequence number for the message.
--
-- @return true if successful or false on failure.
--
-- @warning data in data parameter must be pre-validated.

bool sgEncodeDataReq(uint8_t--buffer, sg_datareq_t--data, uint8_t msgId)





-- Convert mode message struct to the raw buffer format.
--
-- @param[out] buffer An empty buffer to contain the raw mode message.
-- @param[in]  mode   The mode message struct with fields populated.
-- @param[in]  msgId  The sequence number for the message.
--
-- @return true if successful or false on failure.
--
-- @warning data in mode parameter must be pre-validated.

bool sgEncodeMode(uint8_t--buffer, sg_mode_t--mode, uint8_t msgId)


-- Process the ACK message response from the transponder.
--
-- @param[in]  buffer The raw ACK message buffer.
-- @param[out] ack    The parsed message results.
--
-- @return true if successful or false on failure.

bool sgDecodeAck(uint8_t--buffer, sg_ack_t--ack)


-- Process the Install message response from the transponder.
--
-- @param[in]  buffer The raw Install message buffer.
-- @param[out] stl    The parsed message results.
--
-- @return true if successful or false on failure.

bool sgDecodeInstall(uint8_t--buffer, sg_install_t--stl)


-- Process the Flight ID message response from the transponder.
--
-- @param[in]  buffer The raw Flight ID message buffer.
-- @param[out] id     The parsed message results.
--
-- @return true if successful or false on failure.

bool sgDecodeFlightId(uint8_t--buffer, sg_flightid_t--id)


-- Process the status message response from the transponder.
--
-- @param[in]  buffer The raw Status message buffer.
-- @param[out] status The parsed message results.
--
-- @return true if successful or false on failure.

bool sgDecodeStatus(uint8_t--buffer, sg_status_t--status)


-- Process the health monitor message response from the transponder.
--
-- @param[in]  buffer The raw Health Monitor message buffer.
-- @param[out] hlt    The parsed message results.
--
-- @return true if successful or false on failure.

bool sgDecodeHealthMonitor(uint8_t--buffer, sg_healthmonitor_t--hlt)


-- Process the version message response from the transponder.
--
-- @param[in]  buffer The raw Version message buffer.
-- @param[out] vsn    The parsed message results.
--
-- @return true if successful or false on failure.

bool sgDecodeVersion(uint8_t--buffer, sg_version_t--vsn)


-- Process the serial number message response from the transponder.
--
-- @param[in]  buffer The raw Serial Number message buffer.
-- @param[out] sn    The parsed message results.
--
-- @return true if successful or false on failure.

bool sgDecodeSerialNumber(uint8_t--buffer, sg_serialnumber_t--sn)


-- Process the state vector report message.
-- 
-- @param[in]  buffer The raw SVR message buffer.
-- @param[out] svr    The parsed SVR message.
--
-- @return true if successful or false on failure.

bool sgDecodeSVR(uint8_t--buffer, sg_svr_t--svr)


-- Process the mode status report message.
--
-- @param buffer The raw MSR message buffer.
-- @param msr    The parsed MSR message.
--
-- @return true if successful or false on failure.

bool sgDecodeMSR(uint8_t--buffer, sg_msr_t--msr)


]]
