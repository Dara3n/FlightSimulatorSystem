
with Ada.Real_Time; use Ada.Real_Time;

package devicesFSS_V1 is

    ---------------------------------------------------------------------
    ------ AIRCRAFT INPUT devices interface ----------------------------- 
    ---------------------------------------------------------------------
    
    ------ OBSTACLE_DISTANCE
    type Distance_Samples_Type is new natural range 0..9000;
    procedure Read_Distance (D: out Distance_Samples_Type);     -- distancia con objetos

    ------ DAYLIGHT INTENSITY
    type Light_Samples_Type is new natural range 0..1023;
    procedure Read_Light_Intensity (L: out Light_Samples_Type); -- luminosidad exterior
    
    ---------------------------------------------------------------------
    ------ AIRCRAFT CONTROL interface ----------------------------------- 
    ---------------------------------------------------------------------
    
    ------ ALTITUDE
    -- It reads the aircraft altitud: from 0 to 15000 meters.  
    type Altitude_Samples_Type is new natural range 0..15000;
    type Altitude_Increment_Type is new integer range -100..+100;    
    function Read_Altitude return Altitude_Samples_Type;         -- lee altitud de la aeronave
    Initial_Altitude: Altitude_Samples_Type := 8000;
    
    ------ SPEED
    -- It reads the aircraft speed: from 0 to 1100 Km/h.  
    type Speed_Samples_Type is new natural range 0..10230; 
    type Speed_Increment_Type is new integer range -50..+50;
    function Read_Speed return Speed_Samples_Type;             -- lee velocidad actual de la aeronave
    procedure Set_Speed (P: in Speed_Samples_Type);            -- establece velocidad en la aeronave
    -- procedure Increment_Speed (D: in Speed_Increment_Type); -- No se usa
    
    ------ AIRCRAFT_INCLINATION 
    -- Pitch   
    type Pitch_Samples_Type is new integer range -90..+90; 
    type Pitch_Increment_Type is new integer range -5..+5;
    function Read_Pitch return Pitch_Samples_Type;            -- lee el cabeceo actual de la aeronave
    procedure Set_Aircraft_Pitch (P: in Pitch_Samples_Type);  -- establece el cabeceo  de la aeronave

    type Roll_Samples_Type is new integer range -90..+90; 
    type Roll_Increment_Type is new integer range -5..+5;
    function Read_Roll return Roll_Samples_Type;              -- lee el alabeo actual de la aeronave
    procedure Set_Aircraft_Roll (R: in Roll_Samples_Type);    -- establece el alabeo de la aeronave  

    ---------------------------------------------------------------------
    ------ PILOT INPUT devices interface -------------------------------- 
    ---------------------------------------------------------------------
    
    ------ ENGINE_POWER
    type Power_Samples_Type is new natural range 0..1023;
    procedure Read_Power (P: out Power_Samples_Type);         -- lee la potencia indicada por el piloto
    
    ------ JOYSTICK
    type Joystick_Samples_Index is (x,y);
    type Joystick_Samples_Values is new integer range -90..+90;
    type Joystick_Samples_Type is array (Joystick_Samples_Index) 
                                      of Joystick_Samples_Values;
    procedure Read_Joystick (J: out Joystick_Samples_Type);   -- lee la posición del joystick del piloto
    -- It reads the Joystick position in axis x,y and returns 
    -- the angle -90..+90 degrees 
    -- Use J(x) and J(y) to read Pitch and Roll position
    
    ------ PILOT PRESENCE
    type PilotPresence_Samples_Type is new natural range 0..1; 
    function Read_PilotPresence return PilotPresence_Samples_Type;  -- lee sensor de presencia del piloto   
    
    ------ BUTTON TO SELECT MODE
    type PilotButton_Samples_Type is new natural range 0..1; 
    function Read_PilotButton return PilotButton_Samples_Type;   -- lee botón del piloto para cambio de modo
    
    ---------------------------------------------------------------------
    ------ OUTPUT devices interface ------------------------------------- 
    ---------------------------------------------------------------------
    
    ------ Warming lights: It turns ON/OFF the lights 1 and 2
    type Light_States is (On, Off);
    procedure Light_1 (E: Light_States);                      -- enciende/apaga luces de emergencia 
    procedure Light_2 (E: Light_States);   
     
    ----- Warming alarm: It sounds the alarm at a volume "v": 0=NoSound, 5=MaxVolume
    type Volume is new integer range 0..5;                   
    procedure Alarm (v: Volume);                             -- activa alarma sonora 
    
    ---------------------------------------------------------------------
    ------ DISPLAY 
    procedure Display_Altitude (A: in Altitude_Samples_Type);  
    procedure Display_Speed (S: in Speed_Samples_Type);
    procedure Display_Distance (D: in Distance_Samples_Type);  
    procedure Display_Pitch (P: in Pitch_Samples_Type);   
    procedure Display_Roll (R: in Roll_Samples_Type); 
    procedure Display_Light_Intensity (L: in Light_Samples_Type);
    procedure Display_Pilot_Power (P: in Power_Samples_Type);
    procedure Display_Joystick (J: in Joystick_Samples_Type);
    Procedure Display_Pilot_Presence (PP: in PilotPresence_Samples_Type);       
    Procedure Display_Pilot_Button (PB: in PilotButton_Samples_Type); 
    Procedure Display_Message (M: in String);
    Procedure Display_Clear;
    ---------------------------------------------------------------------
    procedure Display_Cronometro (Origen: Ada.Real_Time.Time; Hora: Ada.Real_Time.Time);
    -- It displays a chronometer 
    ---------------------------------------------------------------------

end devicesFSS_V1;



