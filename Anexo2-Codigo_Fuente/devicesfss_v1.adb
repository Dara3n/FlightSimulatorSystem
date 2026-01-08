
with Kernel.Serial_Output; use Kernel.Serial_Output;
with System; use System;
with tools; use tools;
with testing_1; use testing_1;

package body devicesFSS_V1 is

   --------------------------------------------------------------------------
   -- Procedures to access AIRCRAFT: OBSTACLE DISTANCE
   --------------------------------------------------------------------------

    protected Distance_Sensor is
      procedure Get_Distance (D: out Distance_Samples_Type);
    private
      i: Indice_Secuencia_Distancia := 1;
      Secuencia: tipo_Secuencia_Distancia := Distance_Simulation;
    end Distance_Sensor;

    --procedure Reading_Sensors (L: out Tipo_Registro)
    --    renames Sensores_Electrodos.Reading_Sensors;
    procedure Read_Distance (D: out Distance_Samples_Type) is
      begin
        Distance_Sensor.Get_Distance (D);
      end Read_Distance;

    protected body Distance_Sensor is
      procedure Get_Distance (D: out Distance_Samples_Type)  is
         type Time_index is delta 0.1 range 0.0..100.0;
         t: Time_index;
      begin
         t := Time_index(To_Duration(Clock - Big_Bang));
         i := Indice_Secuencia_Distancia (integer(t * 10.0) mod 200);
         D := Secuencia(i);
         --i := i + 1;
         Execution_Time (WCET_Distance);
      end Get_Distance;
    end Distance_Sensor;   
    
   --------------------------------------------------------------------------
   -- Procedures to access AIRCRAFT: DAYLIGHT INTENSITY
   --------------------------------------------------------------------------

    protected Light_Sensor is
      procedure Get_Light (L: out Light_Samples_Type);
    private
      i: Indice_Secuencia_Light := 1;
      Secuencia: tipo_Secuencia_Light := Light_Intensity_Simulation;
    end Light_Sensor;

    --procedure Reading_Light (L: out Tipo_Registro)
    --    renames Light_Sensor.Get_Light;
    procedure Read_Light_Intensity (L: out Light_Samples_Type) is
      begin
        Light_Sensor.Get_Light (L);
      end Read_Light_Intensity;

    protected body Light_Sensor is
      procedure Get_Light (L: out Light_Samples_Type)  is
         type Time_index is delta 0.1 range 0.0..100.0;
         t: Time_index;
      begin
         t := Time_index(To_Duration(Clock - Big_Bang));
         i := Indice_Secuencia_Light (integer(t * 10.0) mod 200);
         L := Secuencia(i);
         Execution_Time (WCET_Light);
      end Get_Light;
    end Light_Sensor;   
    
    
   ---------------------------------------------------------------------
   -- Procedures to access PILOT: JOYSTICK position  
   ---------------------------------------------------------------------

    protected Joystick is
       procedure Get_Joystick (J: out Joystick_Samples_Type);
    private
      i: Indice_Secuencia_Joystick := 1;
      Secuencia: tipo_Secuencia_Joystick := Joystick_Simulation;
    end Joystick;

    procedure Read_Joystick (J: out Joystick_Samples_Type) is
      begin
        Joystick.Get_Joystick (J);
      end Read_Joystick;

    protected body Joystick is
      procedure Get_Joystick (J: out Joystick_Samples_Type)  is
         type Time_index is delta 0.1 range 0.0..100.0;
         t: Time_index;
      begin
         t := Time_index(To_Duration(Clock - Big_Bang));
         i := Indice_Secuencia_Joystick (integer(t * 10.0) mod 200);
         J := Secuencia(i);
         Execution_Time (WCET_Joystick);
      end Get_Joystick;

    end Joystick;
    
   --------------------------------------------------------------------------
   -- Procedures to access PILOT: ENGINE POWER 
   --------------------------------------------------------------------------

    protected Power_Sensor is
      procedure Get_Power (P: out Power_Samples_Type);
    private
      i: Indice_Secuencia_Power := 1;
      Secuencia: tipo_Secuencia_Power := Power_Simulation;
    end Power_Sensor;

    --procedure Reading_Power (L: out Tipo_Registro)
    --    renames Power_Sensor.Reading_Power;
    procedure Read_Power (P: out Power_Samples_Type) is
      begin
        Power_Sensor.Get_Power (P);
      end Read_Power;

    protected body Power_Sensor is
      procedure Get_Power (P: out Power_Samples_Type)  is
         type Time_index is delta 0.1 range 0.0..100.0;
         t: Time_index;
      begin
         t := Time_index(To_Duration(Clock - Big_Bang));
         i := Indice_Secuencia_Power (integer(t * 10.0) mod 200);
         P := Secuencia(i);
         --i := i + 1;
         Execution_Time (WCET_Power);
      end Get_Power;
    end Power_Sensor;      


   --------------------------------------------------------------------------
   -- Procedures to access PILOT: PRESENCE 
   --------------------------------------------------------------------------

    protected PilotPresence_Sensor is
      function Get_PilotPresence return PilotPresence_Samples_Type;
    private
      -- i: Indice_Secuencia_PilotPresence := 1;
      Secuencia: tipo_Secuencia_PilotPresence := PilotPresence_Simulation;
    end PilotPresence_Sensor;

    function Read_PilotPresence return PilotPresence_Samples_Type is
      begin
        return (PilotPresence_Sensor.Get_PilotPresence); 
      end Read_PilotPresence;

    protected body PilotPresence_Sensor  is
      function Get_PilotPresence return PilotPresence_Samples_Type is
         type Time_index is delta 0.1 range 0.0..100.0;
         t: Time_index;
         i: Indice_Secuencia_PilotPresence := 1;
      begin
         t := Time_index(To_Duration(Clock - Big_Bang));
         i := Indice_Secuencia_PilotPresence (integer(t * 10.0) mod 200);
         Execution_Time (WCET_PilotPresence);
         return (Secuencia(i)); 
      end Get_PilotPresence;
    end PilotPresence_Sensor;    
        
   --------------------------------------------------------------------------
   -- Procedures to access PILOT: BUTTON 
   --------------------------------------------------------------------------

    protected PilotButton_Sensor is
      function Get_PilotButton return PilotButton_Samples_Type;
    private
      -- i: Indice_Secuencia_PilotButton := 1;
      Secuencia: tipo_Secuencia_PilotButton := PilotButton_Simulation;
    end PilotButton_Sensor;

    function Read_PilotButton return PilotButton_Samples_Type is
      begin
        return (PilotButton_Sensor.Get_PilotButton); 
      end Read_PilotButton;

    protected body PilotButton_Sensor  is
      function Get_PilotButton return PilotButton_Samples_Type is
         type Time_index is delta 0.1 range 0.0..100.0;
         t: Time_index;
         i: Indice_Secuencia_PilotButton := 1;
      begin
         t := Time_index(To_Duration(Clock - Big_Bang));
         i := Indice_Secuencia_PilotButton (integer(t * 10.0) mod 200);
         Execution_Time (WCET_PilotButton);
         return (Secuencia(i)); 
      end Get_PilotButton;
    end PilotButton_Sensor;     

   --------------------------------------------------------------------------
   -- Current state of the aircraft
   --------------------------------------------------------------------------
   
   -- SPEED --------------------------------------------------------
   
    protected Aircraft_Speed_State is
      procedure Set_Speed (P: in Speed_Samples_Type);
      function  Get_Speed return Speed_Samples_Type;
      procedure Increment_Speed (D: in Speed_Increment_Type);    
    private
      Current_Speed: Speed_Samples_Type := 0;
    end Aircraft_Speed_State;
    
    --function Read_Speed renames Aircraft_Speed.Get_Speed 
    function Read_Speed return Speed_Samples_Type is
      begin
        return (Aircraft_Speed_State.Get_Speed);
      end Read_Speed;
    --function Set_Speed renames Aircraft_Speed.Set_Speed       
    procedure Set_Speed (P: in Speed_Samples_Type) is 
      begin
       Aircraft_Speed_State.Set_Speed (P);
      end Set_Speed;
    
    -- procedure Increment_Speed (D: in Speed_Increment_Type) is
    -- begin
       -- Aircraft_Speed_State.Increment_Speed (D);
    -- end Increment_Speed;

    protected body Aircraft_Speed_State is
      procedure Set_Speed (P: in Speed_Samples_Type)  is
      begin
         Current_Speed := P;
         Execution_Time (WCET_Speed);
      end Set_Speed;
      function Get_Speed return Speed_Samples_Type is
        begin
          Execution_Time (WCET_Speed);
          return (Current_Speed);
        end Get_Speed;
      procedure Increment_Speed (D: in Speed_Increment_Type) is
      begin
        Execution_Time (WCET_Speed);
        Current_Speed := Current_Speed + Speed_Samples_Type(D);
      end Increment_Speed;
    end Aircraft_Speed_State; 
    
   -- ALTITUDE --------------------------------------------------------

    -- these procedures are not exported, only internal use in package
    procedure Write_Altitude (A: in Altitude_Samples_Type);  
    procedure Increment_Altitude (D: in Altitude_Increment_Type);     
   
    protected Aircraft_Altitude_State is
      procedure Set_Altitude (A: in Altitude_Samples_Type);
      function  Get_Altitude return Altitude_Samples_Type;
      procedure Increment_Altitude (D: in Altitude_Increment_Type);    
    private
      Current_Altitude: Altitude_Samples_Type := Initial_Altitude; 
                        -- Altitud inicial al arrancar el sistema
    end Aircraft_Altitude_State;
    
    --function Read_Altitude renames Aircraft_Altitude.Get_Altitude 
    function Read_Altitude return Altitude_Samples_Type is
      begin
        return (Aircraft_Altitude_State.Get_Altitude);
      end Read_Altitude;
      
    --procedure Write_Altitude renames Aircraft_Altitude.Set_Altitude      
    procedure Write_Altitude (A: in Altitude_Samples_Type) is 
    begin
      Aircraft_Altitude_State.Set_Altitude (A);
    end Write_Altitude;
    
    --function Increment_Altitude renames Aircraft_Altitude.Increment_Altitude    
    procedure Increment_Altitude (D: in Altitude_Increment_Type) is
    begin
       Aircraft_Altitude_State.Increment_Altitude (D);
    end Increment_Altitude;

    protected body Aircraft_Altitude_State is
      procedure Set_Altitude (A: in Altitude_Samples_Type)  is
      begin
         Current_Altitude := A;
         Execution_Time (WCET_Altitude);
      end Set_Altitude;
      function Get_Altitude return Altitude_Samples_Type is
        begin
          Execution_Time (WCET_Altitude);
          return (Current_Altitude);
        end Get_Altitude;
      procedure Increment_Altitude (D: in Altitude_Increment_Type) is
      begin
        Execution_Time (WCET_Altitude);
        if (D < 0) then Current_Altitude := Current_Altitude - Altitude_Samples_Type(abs(D));
                   else Current_Altitude := Current_Altitude + Altitude_Samples_Type(D);
        end if;
      end Increment_Altitude;
    end Aircraft_Altitude_State; 

   -- PITCH --------------------------------------------------------
   
    protected Aircraft_Pitch_State is
      procedure Set_Pitch (P: in Pitch_Samples_Type);
      function  Get_Pitch return Pitch_Samples_Type;
      -- procedure Increment_Pitch (D: in Pitch_Increment_Type);    
    private
      Current_Pitch: Pitch_Samples_Type := 0;
    end Aircraft_Pitch_State;
    
    --function Read_Pitch renames Aircraft_Pitch.Get_Pitch 
    function Read_Pitch return Pitch_Samples_Type is
      begin
        return (Aircraft_Pitch_State.Get_Pitch);
      end Read_Pitch;
    --function Set_Pitch renames Aircraft_Pitch.Set_Pitch      
    procedure Set_Aircraft_Pitch (P: in Pitch_Samples_Type) is 
    begin
      Aircraft_Pitch_State.Set_Pitch (P);
    end Set_Aircraft_Pitch;

    protected body Aircraft_Pitch_State is
      procedure Set_Pitch (P: in Pitch_Samples_Type)  is
      begin
         Current_Pitch := P;
         
         -- ESCALONAR EL INCREMENTO DE LA ALTITUD en funcion de la inclinación
         -- Aplicar fórmula de velocidad vertical
         if (Current_Pitch > (+5)) AND (Current_Pitch < (+15))    
            then Increment_Altitude (20);  -- incrementa 15m cada 100 ms.
         elsif (Current_Pitch >= (+15)) AND (Current_Pitch < (+30))
            then Increment_Altitude (40);  -- incrementa 25m cada 100 ms.
         elsif (Current_Pitch >= (+30))
            then Increment_Altitude (60);
         end if;
         
         if (Current_Pitch < (-5)) AND (Current_Pitch > (-15))
            then Increment_Altitude (-20);
         elsif (Current_Pitch < (-15)) AND (Current_Pitch > (-30))
            then Increment_Altitude (-40);
         elsif (Current_Pitch <= (-30)) 
            then Increment_Altitude (-60);
         end if;
         Execution_Time (WCET_Pitch);
      end Set_Pitch;
      
      function Get_Pitch return Pitch_Samples_Type is
        begin
          Execution_Time (WCET_Pitch);
          return (Current_Pitch);
        end Get_Pitch;

    end Aircraft_Pitch_State;      

   -- ROLL --------------------------------------------------------
   
    protected Aircraft_Roll_State is
      procedure Set_Roll (R: in Roll_Samples_Type);
      function  Get_Roll return Roll_Samples_Type; 
    private
      Current_Roll: Roll_Samples_Type := 0;
    end Aircraft_Roll_State;
    
    --function Read_Roll renames Aircraft_Roll.Get_Roll 
    function Read_Roll return Roll_Samples_Type is
      begin
        return (Aircraft_Roll_State.Get_Roll);
      end Read_Roll;
    --function Set_Aircraft_Roll renames Aircraft_Roll.Get_Roll       
    procedure Set_Aircraft_Roll (R: in Roll_Samples_Type) is 
    begin
      Aircraft_Roll_State.Set_Roll (R);
    end Set_Aircraft_Roll;

    protected body Aircraft_Roll_State is
      procedure Set_Roll (R: in Roll_Samples_Type)  is
      begin
         Current_Roll := R;
         Execution_Time (WCET_Roll);
      end Set_Roll;
      function Get_Roll return Roll_Samples_Type is
        begin
          Execution_Time (WCET_Roll);
          return (Current_Roll);
        end Get_Roll;

    end Aircraft_Roll_State; 
    
    
---------------------------------------------------------------------
--     Cuerpo de los procedmientos y objetos para DISPOSITIVOS E/S 
---------------------------------------------------------------------

-----------------------------------------------------------------------------

procedure Light_1 (E: Light_States) is
begin
   Print_Chrono; 
   case E is
        when On  => Put ("%Light(1): ON");
        when Off => Put ("%L(1): off");
   end case;
   Execution_Time (WCET_Light);
end Light_1;

procedure Light_2 (E: Light_States) is
begin
   Print_Chrono; 
   case E is
        when On  => Put ("%Light(2): ON");
        when Off => Put ("%L(2): off");
   end case;
   Execution_Time (WCET_Light);
end Light_2;

-----------------------------------------------------------------------------
procedure Alarm (v: Volume) is 
    -- emite un sonido durante 0.3 segundos con volumne "v"
begin
  Print_Chrono; 
  
  if (v > 0) then
    Put ("%B");
    for i in 0..v loop
      Put ("EE");
    end loop ;  
    Put ("P");
    Put (Volume'Image(v));
  end if;
  Execution_Time (WCET_Alarm);
end Alarm;

  ---------------------------------------------------------------------
  ------ DISPLAY 
  
  procedure Display_Altitude (A: in Altitude_Samples_Type) is
  begin
   Print_Chrono; 
   Put ("..# ");
   Put ("Altitude: ");
   Print_an_Integer (Integer(A));
   Execution_Time (WCET_Display);
  end Display_Altitude;

  procedure Display_Speed (S: in Speed_Samples_Type) is
  begin
   Print_Chrono; 
   Put ("..# ");
   Put ("Speed: ");
   Print_an_Integer (Integer(S));
   Execution_Time (WCET_Display);
  end Display_Speed;
  
  procedure Display_Distance (D: in Distance_Samples_Type) is
  begin
   Print_Chrono; 
   Put ("..# ");
   Put ("Distance: ");
   Print_an_Integer (Integer(D));
   Execution_Time (WCET_Display);
  end Display_Distance;
      
  procedure Display_Pitch (P: in Pitch_Samples_Type) is
  begin
   Print_Chrono; 
   Put ("..# ");
   Put ("Pitch: ");
   Print_an_Integer (Integer(P));
   Execution_Time (WCET_Display);
  end Display_Pitch;
      
  procedure Display_Roll (R: in Roll_Samples_Type) is
  begin
   Print_Chrono; 
   Put ("..# ");
   Put ("Roll: ");
   Print_an_Integer (Integer(R));
   Execution_Time (WCET_Display);
  end Display_Roll;
      
  procedure Display_Light_Intensity (L: in Light_Samples_Type) is
  begin
   Print_Chrono; 
   Put ("..# ");
   Put ("Light_Intensity: ");
   Print_an_Integer (Integer(L));
   Execution_Time (WCET_Display);
  end Display_Light_Intensity;
    
  procedure Display_Pilot_Power (P: in Power_Samples_Type) is
  begin
   Print_Chrono; 
   Put ("..# ");
   Put ("Pilot_Power: ");
   Print_an_Integer (Integer(P));
   Execution_Time (WCET_Display);
  end Display_Pilot_Power;
      
  procedure Display_Joystick (J: in Joystick_Samples_Type) is
  begin
    Print_Chrono; 
    Put ("..# ");
    Put ("Joystick: ");
    for i in Joystick_Samples_Index loop
       Print_an_Integer (Integer(J(i)));
    end loop;
    Execution_Time (WCET_Display);
  end Display_Joystick;

  Procedure Display_Pilot_Presence (PP: in PilotPresence_Samples_Type) is      
  begin
    Print_Chrono; 
    Put ("..# ");
    Put ("Pilot ");
    if (PP = 1) then Put ("ok");
          else Put ("NOT PRESENT");
    end if;
    Execution_Time (WCET_Display);
  end Display_Pilot_Presence;    
    
  Procedure Display_Pilot_Button (PB: in PilotButton_Samples_Type) is 
  begin
    Print_Chrono;
    Put ("..# ");
    Put ("Button ");
    if (PB = 1) then Put ("ON");
          else Put ("OFF");
    end if;
    Execution_Time (WCET_Display);
  end Display_Pilot_Button; 
  
  Procedure Display_Message (M: in String) is 
  begin
    Print_Chrono;
    Put ("..# ");
    Put ("MSSG: ");
    Put (M);
    Execution_Time (WCET_Display);
  end Display_Message; 
  
  Procedure Display_Clear is 
  begin
    -- Print_Chrono;
    Put ("&");
    Execution_Time (WCET_Display);
  end Display_Clear; 
-----------------------------------------------------------------------------
procedure Display_Cronometro (Origen : Ada.Real_Time.Time; Hora: Ada.Real_Time.Time ) is
  type Crono is delta 0.1 range 0.0..100.0;
begin
  Print_Chrono;
  Put ("%Crono:");
  --Put (Duration'Image(To_Duration(Clock - Origen)));
  Put (Crono'Image(Crono(To_Duration(Hora - Origen))));
end Display_Cronometro;

---------------------------------------------------------------------------------------
begin
   null;
end devicesFSS_V1;


