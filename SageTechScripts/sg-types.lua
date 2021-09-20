

-- Host Message Lengths (bytes)
SG_MSG_LEN_INSTALL       =     41
SG_MSG_LEN_FLIGHT        =     17
SG_MSG_LEN_OPMSG         =     17
SG_MSG_LEN_GPS           =     68
SG_MSG_LEN_DATAREQ       =     9
SG_MSG_LEN_TARGETREQ     =     12
SG_MSG_LEN_MODE          =     10

-- FLIGHTID values

        
---------------------------------------------

-- gps definitions

PBASE               =     5   -- was 4 in c  -- the payload offset.



---------------------------------------------



-- require "header"

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

-- Host Message Types
SG_MSG_TYPE_HOST_INSTALL   =   0x01
SG_MSG_TYPE_HOST_FLIGHT    =   0x02
SG_MSG_TYPE_HOST_OPMSG     =   0x03
SG_MSG_TYPE_HOST_GPS       =   0x04
SG_MSG_TYPE_HOST_DATAREQ   =   0x05
SG_MSG_TYPE_HOST_TARGETREQ =   0x0B
SG_MSG_TYPE_HOST_MODE      =   0x0C

-- XPNDR Message Types
SG_MSG_TYPE_XPNDR_ACK       =  0x80
SG_MSG_TYPE_XPNDR_INSTALL   =  0x81
SG_MSG_TYPE_XPNDR_FLIGHT    =  0x82
SG_MSG_TYPE_XPNDR_STATUS    =  0x83
SG_MSG_TYPE_XPNDR_COMMA     =  0x85
SG_MSG_TYPE_XPNDR_MODE      =  0x8C
SG_MSG_TYPE_XPNDR_VERSION   =  0x8E
SG_MSG_TYPE_XPNDR_SERIALNUM =  0x8F

-- ADS-B Message Types
SG_MSG_TYPE_ADSB_TSUMMARY   =   0x90
SG_MSG_TYPE_ADSB_SVR        =   0x91
SG_MSG_TYPE_ADSB_MSR        =   0x92
SG_MSG_TYPE_ADSB_TSTATE     =   0x97
SG_MSG_TYPE_ADSB_ARVR       =   0x98

-- Start byte for all host messages
SG_MSG_START_BYTE           =   0xAA

-- Emitter category set byte values
SG_EMIT_GROUP_A             =   0x00
SG_EMIT_GROUP_B             =   0x01
SG_EMIT_GROUP_C             =   0x02
SG_EMIT_GROUP_D             =   0x03

-- Emitter category enumeration offsets
SG_EMIT_OFFSET_A            =   0x00
SG_EMIT_OFFSET_B            =   0x10
SG_EMIT_OFFSET_C            =   0x20
SG_EMIT_OFFSET_D            =   0x30

-- from https://unendli.ch/posts/2016-07-22-enumerations-in-lua.html
-- assumes the tbl is an array, i.e., all the keys are
-- successive integers - otherwise #tbl will fail
-- example usage:
--
--     Colors = enum {
--     "BLUE",
--     "GREEN",
--     "RED",
--     "VIOLET",
--     "YELLOW",
--     }
-- 
--     finally, get our integer from the enum!
--     color = Colors.RED
--
function enum(tbl)
    length = #tbl
    for i = 1, length do
        v = tbl[i]
        tbl[v] = i
    end

    return tbl
end

-- Available COM port baud rates.
-- typedef enum
sg_baud_t = enum {
   baud38400 = 0,
   baud600,
   baud4800,
   baud9600,
   baud28800,
   baud57600,
   baud115200,
   baud230400,
   baud19200,
   baud460800,
   baud921600
} 


-- Transponder ethernet configuration
-- typedef struct
sg_ethernet_t =
{
    ipAddress,   -- The transponder ip address
    subnetMask,  -- The transponder subnet mask
    portNumber  -- The transponder port number
} 


-- Available GPS integrity SIL values

-- typedef enum
sg_sil_t = enum
{
   silUnknown = 0,
   silLow,
   silMedium,
   silHigh
} 


-- Available GPS integrity SDA values

-- typedef enum
sg_sda_t =
{
   sdaUnknown = 0,
   sdaMinor,
   sdaMajor,
   sdaHazardous
} 


-- Available emitter types

-- typedef enum
sg_emitter_t =
{
   aUnknown       = SG_EMIT_OFFSET_A,
   aLight,
   aSmall,
   aLarge,
   aHighVortex,
   aHeavy,
   aPerformance,
   aRotorCraft,
   bUnknown       = SG_EMIT_OFFSET_B,
   bGlider,
   bAir,
   bParachutist,
   bUltralight,
   bUAV           = SG_EMIT_OFFSET_B + 6,
   bSpace,
   cUnknown       = SG_EMIT_OFFSET_C,
   cEmergency,
   cService,
   cPoint,
   cCluster,
   cLine,
   dUnknown       = SG_EMIT_OFFSET_D
} 


-- Available aircraft sizes in meters

-- typedef enum
sg_size_t = {
   sizeUnknown = 0, -- Dimensions unknown
   sizeL15W23,      -- Length <= 15m & Width <= 23m
   sizeL25W28,      -- Length <= 25m & Width <= 28.5m
   sizeL25W34,      -- Length <= 25m & Width <= 34m
   sizeL35W33,      -- Length <= 35m & Width <= 33m
   sizeL35W38,      -- Length <= 35m & Width <= 38m
   sizeL45W39,      -- Length <= 45m & Width <= 39.5m
   sizeL45W45,      -- Length <= 45m & Width <= 45m
   sizeL55W45,      -- Length <= 55m & Width <= 45m
   sizeL55W52,      -- Length <= 55m & Width <= 52m
   sizeL65W59,      -- Length <= 65m & Width <= 59.5m
   sizeL65W67,      -- Length <= 65m & Width <= 67m
   sizeL75W72,      -- Length <= 75m & Width <= 72.5m
   sizeL75W80,      -- Length <= 75m & Width <= 80m
   sizeL85W80,      -- Length <= 85m & Width <= 80m
   sizeL85W90       -- Length <= 85m & Width <= 90m
} 


-- Available aircraft maximum airspeeds
-- typedef enum
sg_airspeed_t = {
   speedUnknown = 0, -- Max speed unknown
   speed75kt,        -- 0 knots    < Max speed < 75 knots
   speed150kt,       -- 75 knots   < Max speed < 150 knots
   speed300kt,       -- 150 knots  < Max speed < 300 knots
   speed600kt,       -- 300 knots  < Max speed < 600 knots
   speed1200kt,      -- 600 knots  < Max speed < 1200 knots
   speedGreater      -- 1200 knots < Max speed
} 


-- Available antenna configurations
-- typedef enum
sg_antenna_t =
{
   antBottom = 1,    -- bottom antenna only
   antBoth   = 3     -- both top and bottom antennae
} 


-- The XPNDR Installation Message.
-- Host --> XPNDR.
-- XPNDR --> Host.
-- Use 'strcpy(install.reg, "REGVAL1")' to assign the registration.

-- typedef struct
sg_install_t = 
{
    -- uint32_t       
    icao,         -- The aircraft's ICAO address
    --char[8]           
    reg = {},        -- The aircraft's registration (left-justified alphanumeric characters padded with spaces)
    -- sg_baud_t      
    com0 = sg_baud_t,          -- The baud rate for COM Port 0
--     sg_baud_t      
    com1 = sg_baud_t,          -- The baud rate for COM Port 1
--     sg_ethernet_t  
    eth = sg_ethernet_t,           -- The ethernet configuration
--     sg_sil_t       
    sil = sg_sil_t,           -- The gps integrity SIL parameter
--     sg_sda_t       
    sda = sg_sda_t,           -- The gps integrity SDA parameter
--     sg_emitter_t   
    emitter = sg_emitter_t,       -- The platform's emitter type
--     sg_size_t      
    size = sg_airspeed_t,          -- The platform's dimensions
--     sg_airspeed_t  
    maxSpeed = sg_airspeed_t,      -- The platform's maximum airspeed
--     int16_t        
    altOffset,     -- The altitude encoder offset is a legacy field that should always = 0
--     sg_antenna_t   
    antenna,       -- The antenna configuration
--     bool           
    altRes100 = false,     -- Altitude resolution. true = 100 foot, false = 25 foot
--     bool           
    hdgTrueNorth,  -- Heading type. true = true north, false = magnetic north
--     bool      
    airspeedTrue,  -- Airspeed type. true = true speed, false = indicated speed
--     bool      
    heater,        -- true = heater enabled, false = heater disabled
--     bool
    wowConnected  -- Weight on Wheels sensor. true = connected, false = not connected
} 


-- The XPNDR Flight ID Message.
-- Host --> XPNDR.
-- XPNDR --> Host.
---- Use 'strcpy(id.flightID, "FLIGHTNO")' to assign the flight identification.

-- typedef struct
sg_flightid_t =
{
   -- char [9]  -- The flight identification (left-justified alphanumeric characters padded with spaces)
    flightId = ""
} 


-- Available transponder operating modes. The enumerated values are
-- offset from the host message protocol values.

-- typedef enum
sg_op_mode_t = enum {
   modeOff  = 0,     -- 'Off' Mode:     Xpdr will not transmit
   modeOn   = 1,      -- 'On' Mode:      Full functionality with Altitude = Invalid
   modeStby = 2,    -- 'Standby' Mode: Reply to lethal interrogations, only
   modeAlt  = 3      -- 'Alt' Mode:     Full functionality
} 


-- Available emergency status codes.

-- typedef enum
sg_emergc_t = enum {
   emergcNone    = 0,  -- No Emergency
   emergcGeneral = 1,   -- General Emergency
   emergcMed     = 2,       -- Lifeguard/Medical Emergency
   emergcFuel    = 3,      -- Minimum Fuel
   emergcComm    = 4,      -- No Communications
   emergcIntrfrc = 5,   -- Unlawful Interference
   emergcDowned  = 6     -- Downed Aircraft
}

-- The XPNDR Operating Message.
-- Host --> XPNDR.

-- typedef struct
sg_operating_t = 
{
    -- uint16_t     
    squawk = 0,      -- 4-digit octal Mode A code
    -- sg_op_mode_t 
    opMode = sg_op_mode_t.modeOff,       -- Operational mode
    -- bool    
    savePowerUp = true, -- Save power-up state in non-volatile
    -- bool     
    enableSqt   = false, -- Enable extended squitters
    -- bool         
    enableXBit  = false, -- Enable the x-bit
    -- bool         
    milEmergency = false, -- Broadcast a military emergency
    -- sg_emergc_t  
    emergcType   = sg_emergc_t.emergcNone,  -- Enumerated civilian emergency type
    -- bool         
    identOn       = true,-- Set the identification switch = On
    -- bool         
    altUseIntrnl  = false,-- True = Report altitude from internal pressure sensor (will ignore other bits in the field)
    -- bool         
    altHostAvlbl  = false,-- True = Host Altitude is being provided
    -- bool         
    altRes25      = false,-- Host Altitude Resolution from install message, True = 25 ft, False = 100 ft
    -- int32_t      
    altitude     = 0,        -- Sea-level altitude in feet. Field is ignored when internal altitude is selected.
    -- bool         
    climbValid    = false,  -- Climb rate is provided
    -- int16_t      climbRate    -- Climb rate in ft/min. Limits are +/- 16,448 ft/min.
    -- bool         
    headingValid  = false,  -- Heading is valid.
    -- double     
    heading      == 0.0,     -- Heading in degrees
    -- bool         
    airspdValid   = false,   -- Airspeed is valid.
    -- uint16_t     
    airspd        = 0       -- Airspeed in knots.
} 


-- Avaiable NACp values.

-- typedef enum
sg_nacp_t = enum {
    nacpUnknown = 0,   -- >= 18.52  km ( 10  nmile)
    nacp10dot0 = 1,    -- <  18.52  km ( 10  nmile)
    nacp4dot0  = 2,     -- <   7.408 km (  4  nmile)
    nacp2dot0  = 3,     -- <   3.704 km (  2  nmile)
    nacp1dot0  = 4,     -- <   1.852 km (  1  nmile)
    nacp0dot5  = 5,     -- <   0.926 km (0.5  nmile)
    nacp0dot3  = 6,     -- <   0.556 km (0.3  nmile)
    nacp0dot1  = 7,     -- <   0.185 km (0.1  nmile)
    nacp0dot05 = 8,    -- <    92.6 m  (0.05 nmile)
    nacp30     = 9,        -- <    30.0 m
    nacp10     = 10,        -- <    10.0 m
    nacp3      = 11          -- <     3.0 m
} 



-- Available NACv values (m/s)
-- typedef enum
sg_nacv_t = enum {
    nacvUnknown = 0,  -- 10   <= NACv (or NACv is unknown)
    nacv10dot0 = 1,       --  3   <= NACv < 10
    nacv3dot0 = 2,        --  1   <= NACv <  3
    nacv1dot0 = 3,        --  0.3 <= NACv <  1
    nacv0dot3 = 4        --  0.0 <= NACv <  0.3
} 

sg_gps_t = 
{
    -- char         
    longitude = "",  -- [12]  -- The absolute value of longitude (degree and decimal minute)
    -- char         
    latitude = "",    --[11]   -- The absolute value of latitude (degree and decimal minute)
    -- char         
    grdSpeed = "",    -- [7]    -- The GPS over-ground speed (knots)
    -- char         
    grdTrack = "",    -- [9]    -- The GPS track referenced from True North (degrees, clockwise)
    -- bool         
    latNorth = true,       -- The aircraft is in the northern hemisphere
    -- bool         
    lngEast = true,        -- The aircraft is in the eastern hemisphere
    -- bool         
    fdeFail = true,        -- True = A satellite error has occurred
    -- bool         
    gpsValid = false,       -- True = GPS data is valid
    -- char         
    timeOfFix = "",   --[11]  -- Time, relative to midnight UTC (can optionally be filled spaces)
    -- float        
    height = 0.0,         -- The height above the WGS-84 ellipsoid (meters)
    -- float        
    hpl = 0.0,            -- The Horizontal Protection Limit (meters)
    -- float        
    hfom = 0.0,           -- The Horizontal Figure of Merit (meters)
    -- float        
    vfom = 0.0,           -- The Vertical Figure of Merit (meters)
    -- sg_nacv_t    
    nacv = sg_nacv_t.nacvUnknown,           -- Navigation Accuracy for Velocity (meters/second)
} 

--[[

-- Available data request types

-- typedef enum
{
   dataInstall     = 0x81,   -- Installation data
   dataFlightID    = 0x82,   -- Flight Identification data
   dataStatus      = 0x83,   -- Status Response data
   dataMode        = 0x8C,   -- Mode Settings data
   dataHealth      = 0x8D,   -- Health Monitor data
   dataVersion     = 0x8E,   -- Version data
   dataSerialNum   = 0x8F,   -- Serial Number data
   dataTOD         = 0xD2,   -- Time of Day data
   dataMode5       = 0xD3,   -- Mode 5 Indication data
   dataCrypto      = 0xD4,   -- Crypto Status data
   dataMilSettings = 0xD7    -- Military Settings data
} sg_datatype_t


-- The Data Request message.
-- Host --> XPDR.

-- typedef struct
{
   sg_datatype_t  reqType    -- The desired data response
   uint8_t        resv[3]
} sg_datareq_t

]]

-- Available target request types

-- typedef enum
sg_reporttype_t = enum
{
   reportAuto    = 0,   -- Enable auto output of all target reports
   reportSummary = 1,   -- Report list of all tracked targets (disables auto-output)
   reportIcao    = 2,   -- Generate reports for specific target, only (disables auto-output)
   reportNone    = 3    -- Disable all target reports
} 


-- Available target report transmission ports

-- typedef enum
sg_transmitport_t = enum
{
   transmitSource = 0,   -- Transmit reports on channel where target request was received
   transmitCom0   = 1,         -- Transmit reports on Com0
   transmitCom1   = 2,         -- Transmit reports on Com1
   transmitEth    = 3           -- Transmit reports on Ethernet
} 

-- The Target Request message for ADS-B 'in' data.
-- Host --> XPDR.

-- typedef struct
sg_targetreq_t = 
{
    -- sg_reporttype_t   
    reqType      = sg_reporttype_t.reportAuto, -- The desired report mode
    -- sg_transmitport_t 
    transmitPort = sg_transmitport_t.transmitSource, -- The communication port used for report transmission
    -- uint16_t          
    maxTargets   = 0,       -- The maximum number of targets to track (max value: 404)
    -- uint32_t
    icao         = 0,       -- The desired target's ID, if applicable
    -- bool              
    stateVector  = false,   -- Transmit state vector reports
    -- bool              
    modeStatus   = false,   -- Transmit mode status reports
    -- bool              
    targetState  = false,   -- Transmit target state reports
    -- bool              
    airRefVel    = false,   -- Transmit air referenced velocity reports
    -- bool              
    tisb         = false,   -- Transmit raw TIS-B message reports (requires auto-output)
    -- bool              
    military     = false,   -- Enable tracking of military aircraft
    -- bool              
    commA        = false,   -- Transmit Comm-A Reports (requires auto-output)
    -- bool              
    ownship      = false    -- Transmit reports about own aircraft
} 

--[[

-- The Mode message.
-- Host --> XPDR.

-- typedef struct
{
   bool         reboot   -- Reboot the MX
} sg_mode_t


-- The XPNDR Acknowledge Message following all host messages.
-- XPNDR --> Host.

-- typedef struct
{
   uint8_t      ackType     -- Message type being acknowledged
   uint8_t      ackId       -- Message ID being acknowledged
   bool         failXpdr    -- Built-in-test failure
   bool         failSystem  -- Required system input missing
   bool         failCrypto  -- Crypto status failure
   bool         wow         -- Weight-on-wheels indicates aircraft is on-ground
   bool         maint       -- Maintenance mode enabled
   bool         isHostAlt   -- False = Pressure sensor altitude, True = Host provided value
   sg_op_mode_t opMode      -- Operational mode
   int32_t      alt         -- Altitude (feet)
   bool         altValid    -- Altitude is valid
} sg_ack_t


-- The XPNDR Status Response Message following a Data Request for Status.
-- XPNDR --> Host.

-- typedef struct
{
   uint8_t   versionSW       -- SW Version # installed on the XPNDR
   uint8_t   versionFW       -- FW Version # installed on the XPNDR
   uint32_t  crc             -- CRC Checksum for the installed XPNDR SW/FW versions

   bool      powerUp    : 1  -- Integrity of CPU and Non-Volatile data at power-up
   bool      continuous : 1  -- Set by any other B.I.T. failures during operation
   bool      processor  : 1  -- One-time processor instruction set test at power-up
   bool      crcValid   : 1  -- Calculate then verifies the CRC against the stored value
   bool      memory     : 1  -- Processor RAM is functional
   bool      calibrated : 1  -- Transponder is calibrated
   bool      receiver   : 1  -- RF signals travel through hardware correctly
   bool      power53v   : 1  -- Voltage at the 53V power supply is correct
   bool      adc        : 1  -- Analog-to-Digital Converter is functional
   bool      pressure   : 1  -- Internal pressure transducer is functional
   bool      fpga       : 1  -- FPGA I/O operations are functional
   bool      rxLock     : 1  -- Rx oscillator reporting PLL Lock at reference frequency
   bool      txLock     : 1  -- Tx oscillator reporting PLL Lock at reference frequency
   bool      mtSuppress : 1  -- Mutual suppression is operating correctly
   bool      temp       : 1  -- Internal temperature is within range (< 110 C)
   bool      sqMonitor  : 1  -- Squitters are transmitting at their nominal rates
   bool      txRate     : 1  -- Transmission duty cycle is in the safe range
   bool      sysLatency : 1  -- Systems events occurred within expected time limits
   bool      txPower    : 1  -- Transmission power is in-range
   bool      voltageIn  : 1  -- Input voltage is in-range (10V-32V)
   bool      icao       : 1  -- ICAO Address is valid (fail at '000000' or 'FFFFFF')
   bool      gps        : 1  -- Valid GPS data is received at 1Hz, minimum
} sg_status_t


-- The XPNDR Health Monitor Response Message.
-- XPNDR --> Host.

-- typedef struct
{
   int8_t     socTemp       -- System on a Chip temperature
   int8_t     rfTemp        -- RF Board temperature
   int8_t     ptTemp        -- Pressure Transducer temperature
} sg_healthmonitor_t


-- The XPNDR Version Response Message.
-- XPNDR --> Host.

-- typedef struct
{
   uint8_t     swVersion       -- The SW Version major revision number
   uint8_t     fwVersion       -- The FW Version major revision number
   uint16_t    swSvnRevision   -- The SW Repository version number
   uint16_t    fwSvnRevision   -- The FW Repository version number
} sg_version_t


-- The XPNDR Serial Number Response Message.
-- XPNDR --> Host.

-- typedef struct
{
   char         ifSN[33]       -- The Interface Board serial number
   char         rfSN[33]       -- The RF Board serial number
   char         xpndrSN[33]    -- The Transponder serial number
} sg_serialnumber_t

-- The state vector report type.
-- typedef enum
{
   svrAirborne = 1,          -- Airborne state vector report type.
   svrSurface                -- Surface state vector report type.
} sg_svr_type_t

-- The state vector report participant address type.
-- typedef enum
{
   svrAdrIcaoUnknown,       -- ICAO address unknown emitter category.
   svrAdrNonIcaoUnknown,    -- Non-ICAO address unknown emitter category.
   svrAdrIcao,              -- ICAO address aircraft.
   svrAdrNonIcao,           -- Non-ICAO address aircraft.
   svrAdrIcaoSurface,       -- ICAO address surface vehicle, fixed ground, tethered obstruction.
   svrAdrNonIcaoSurface,    -- Non-ICAO address surface vehicle, fixed ground, tethered obstruction.
   svrAdrDup,               -- Duplicate target of another ICAO address.
   svrAdrAdsr               -- ADS-R target.
} sg_addr_type_t

-- The surface part of a state vector report.
-- typedef struct
{
   int16_t   speed           -- Surface speed.
   int16_t   heading         -- Surface heading.
} sg_svr_surface_t

-- The airborne part of a state vector report.
-- typedef struct
{
   int16_t   velNS           -- The NS speed vector component.
   int16_t   velEW           -- The EW speed vector component.
   int16_t   speed           -- Speed from N/S and E/W velocity.
   int16_t   heading         -- Heading from N/S and E/W velocity.
   int32_t   geoAlt          -- Geometric altitude.
   int32_t   baroAlt         -- Barometric altitude.
   int16_t   vrate           -- Vertical rate.
   float     estLat          -- Estimated latitude.
   float     estLon          -- Estimated longitude.
} sg_svr_airborne_t

-- typedef struct
{
   bool baroVRate   : 1      -- Barometric vertical rate valid.
   bool geoVRate    : 1      -- Geometric vertical rate valid.
   bool baroAlt     : 1      -- Barometric altitude valid.
   bool surfHeading : 1      -- Surface heading valid.
   bool surfSpeed   : 1      -- Surface speed valid.
   bool airSpeed    : 1      -- Airborne speed and heading valid.
   bool geoAlt      : 1      -- Geometric altitude valid.
   bool position    : 1      -- Lat and lon data valid.
} sg_svr_validity_t

-- typedef struct
{
   uint8_t reserved    : 6      -- Reserved.
   bool    estSpeed    : 1      -- Estimated N/S and E/W velocity.
   bool    estPosition : 1      -- Estimated lat/lon position.
} sg_svr_est_validity_t


-- The XPDR ADS-B state vector report Message.
-- Host --> XPDR.
--
-- @note The time of applicability values are based on the MX system clock that starts
-- at 0 on power up. The time is the floating point number that is the seconds since
-- power up. The time number rolls over at 512.0.

-- typedef struct
{
   sg_svr_type_t type           -- Report type.
   union
   {
      uint8_t           flags
      sg_svr_validity_t validity-- Field validity flags.
   }
   union
   {
      uint8_t eflags
      sg_svr_est_validity_t evalidity --Estimated field validity flags.
   }
   uint32_t          addr       -- Participant address.
   sg_addr_type_t    addrType   -- Participant address type.
   float             toaEst     -- Report estimated position and speed time of applicability.
   float             toaPosition-- Report position time of applicability.
   float             toaSpeed   -- Report speed time of applicability.
   uint8_t           survStatus -- Surveillance status.
   uint8_t           mode       -- Report mode.
   uint8_t           nic        -- Navigation integrity category.
   float             lat        -- Latitude.
   float             lon        -- Longitude.
   union
   {
      sg_svr_surface_t  surface -- Surface SVR data.
      sg_svr_airborne_t airborne-- Airborne SVR data.
   }
} sg_svr_t

-- typedef enum
{
   msrTypeV0,
   msrTypeV1Airborne,
   msrTypeV1Surface,
   msrTypeV2Airborne,
   msrTypeV2Surface
} sg_msr_type_t

-- typedef struct
{
   uint8_t reserved : 2
   bool    priority : 1
   bool    sil      : 1
   bool    nacv     : 1
   bool    nacp     : 1
   bool    opmode   : 1
   bool    capcodes : 1
} sg_msr_validity_t

-- typedef enum
{
   adsbVerDO260,
   adsbVerDO260A,
   adsbVerDO260B
} sg_adsb_version_t

-- typedef enum
{
   adsbUnknown,
   adsbLight,
   adsbSmall        = 0x3,
   adsbLarge        = 0x5,
   adsbHighVortex,
   adsbHeavy,
   adsbPerformance,
   adsbRotorcraft   = 0x0A,
   adsbGlider,
   adsbAir,
   adsbUnmaned,
   adsbSpace,
   adsbUltralight,
   adsbParachutist,
   adsbVehicle_emg  = 0x14,
   adsbVehicle_serv,
   adsbObsticlePoint,
   adsbObsticleCluster,
   adsbObsticleLinear
} sg_adsb_emitter_t

-- typedef enum
{
   priNone,
   priGeneral,
   priMedical,
   priFuel,
   priComm,
   priUnlawful,
   priDowned
} sg_priority_t

-- typedef enum
{
   tcrNone,
   tcrSingle,
   tcrMultiple
} sg_tcr_t

-- typedef struct
{
   bool     b2low  : 1
   bool     uat    : 1
   bool     arv    : 1
   bool     tsr    : 1
   bool     adsb   : 1
   bool     tcas   : 1
   sg_tcr_t tcr
} sg_capability_t

-- typedef enum
{
   gpsLonNodata,
   gpsLonSensorSupplied,
   gpsLon2m,
   gpsLon4m,
   gpsLon6m,
   gpsLon8m,
   gpsLon10m,
   gpsLon12m,
   gpsLon14m,
   gpsLon16m,
   gpsLon18m,
   gpsLon20m,
   gpsLon22m,
   gpsLon24m,
   gpsLon26m,
   gpsLon28m,
   gpsLon30m,
   gpsLon32m,
   gpsLon34m,
   gpsLon36m,
   gpsLon38m,
   gpsLon40m,
   gpsLon42m,
   gpsLon44m,
   gpsLon46m,
   gpsLon48m,
   gpsLon50m,
   gpsLon52m,
   gpsLon54m,
   gpsLon56m,
   gpsLon58m,
   gpsLon60m
} sg_gps_lonofs_t

-- typedef enum
{
   gpslatNodata,
   gpslatLeft2m,
   gpslatLeft4m,
   gpslatLeft6m,
   gpslatRight0m,
   gpslatRight2m,
   gpslatRight4m,
   gpslatRight6m,
} sg_gps_latofs_t

-- typedef struct
{
   bool            gpsLatFmt
   sg_gps_latofs_t gpsLatOfs          
   bool            gpsLonFmt
   sg_gps_lonofs_t gpsLonOfs
   bool            tcasRA    : 1
   bool            ident     : 1
   bool            singleAnt : 1
} sg_adsb_opmode_t

-- typedef enum
{
   gvaUnknown,
   gvaLT150m,
   gvaLT45m
} sg_gva_t

-- typedef enum
{
   nicGolham,
   nicNonGilham
} sg_nicbaro_t

-- typedef enum
{
   svsilUnknown,
   svsilPow3,
   svsilPow5,
   svsilPow7
} sg_svsil_t

-- typedef struct
{
   sg_nacp_t         nacp
   sg_nacv_t         nacv
   sg_sda_t          sda
   bool              silSupp
   sg_svsil_t        sil
   sg_gva_t          gva
   sg_nicbaro_t      nicBaro
} sg_sv_qual_t

-- typedef enum
{
   trackTrueNorth,
   trackMagNorth,
   headingTrueNorth,
   headingMagNorth
} sg_trackheading_t

-- typedef enum
{
   vrateBaroAlt,
   vrateGeoAlt
} sg_vratetype_t


-- The XPDR ADS-B mode status report Message.
-- Host --> XPDR.
--
-- @note The time of applicability values are based on the MX system clock that starts
-- at 0 on power up. The time is the floating point number that is the seconds since
-- power up. The time number rolls over at 512.0.

-- typedef struct
{
   sg_msr_type_t type           -- Report type.

   union
   {
      uint8_t           flags
      sg_msr_validity_t validity-- Field validity flags.
   }

   uint32_t          addr       -- Participant address.
   sg_addr_type_t    addrType   -- Participant address type.

   float             toa
   sg_adsb_version_t version
   char              callsign[9]
   sg_adsb_emitter_t emitter
   sg_size_t         size
   sg_priority_t     priority
   sg_capability_t   capability
   sg_adsb_opmode_t  opMode
   sg_sv_qual_t      svQuality
   sg_trackheading_t trackHeading
   sg_vratetype_t    vrateType
} sg_msr_t

]]