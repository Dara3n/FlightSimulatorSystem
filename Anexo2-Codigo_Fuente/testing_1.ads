
with Ada.Real_Time; use Ada.Real_Time;
with devicesfss_v1; use devicesfss_v1;

package testing_1 is

    ---------------------------------------------------------------------
    ------ Access time for devices
    ---------------------------------------------------------------------
    WCET_Distance: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_Light: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    
    WCET_Joystick: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_PilotPresence: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    WCET_PilotButton: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);
    
    WCET_Power: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(4);
    
    WCET_Speed: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(7);
    WCET_Altitude: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(18);

    WCET_Pitch: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(20);
    WCET_Roll: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(18);

    WCET_Display: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(15);
    WCET_Alarm: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(5);

    ---------------------------------------------------------------------
    ------ SCENARIO ----------------------------------------------------- 
    ---------------------------------------------------------------------
    -- Initial_Altitude: Altitude_Samples_Type := 8000;
    
    ---------------------------------------------------------------------
    ------ DISTANCE OK---------------------------------------------------
    cantidad_datos_Distancia: constant := 200;
    type Indice_Secuencia_Distancia is mod cantidad_datos_Distancia;
    type tipo_Secuencia_Distancia is array (Indice_Secuencia_Distancia) of Distance_Samples_Type;

    Distance_Simulation: tipo_Secuencia_Distancia :=  -- next sample every 100ms.
            ( 5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 1s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 2s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 3s.
              4440,4440,4440,4440,4440, 4440,4440,4440,4440,4440,   -- 4s.  ! objeto detectado
              4440,4440,4440,4440,4440, 4440,4440,4440,4440,4440,   -- 5s.
              3330,3330,3330,3330,3330, 3330,3330,3330,3330,3330,   -- 6s.
              3000,3000,3000,3000,3000, 3000,3000,3000,3000,3000,   -- 7s.
              2400,2400,2400,2400,2400, 2400,2400,2400,2400,2400,   -- 8s.  !!! objeto proximo
              1999,1999,1999,1999,1999, 1999,1999,1999,1999,1999,   -- 9s.
              0990,0990,0990,0990,0990, 0990,0990,0990,0990,0990,   -- 10s.
              0411,0411,0411,0411,0411, 0411,0411,0411,0411,0411,   -- 11s. !!!! peligro colisión
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 12s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 13s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 14s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 15s. 
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 16s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 17s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 18s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555,   -- 19s.
              5555,5555,5555,5555,5555, 5555,5555,5555,5555,5555);  -- 20s.
                   
    ---------------------------------------------------------------------
    ------ LIGHT OK------------------------------------------------------

    cantidad_datos_Light: constant := 200;
    type Indice_Secuencia_Light is mod cantidad_datos_Light;
    type tipo_Secuencia_Light is array (Indice_Secuencia_Light) of Light_Samples_Type;

    Light_Intensity_Simulation: tipo_Secuencia_Light :=  -- 1 muestra cada 100ms.
                 ( 700,700,700,700,700, 700,700,700,700,700,   -- 1s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 2s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 3s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 4s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 5s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 6s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 7s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 8s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 9s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 10s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 11s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 12s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 13s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 14s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 15s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 16s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 17s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 18s.
                   700,700,700,700,700, 700,700,700,700,700,   -- 19s.
                   700,700,700,700,700, 700,700,700,700,700);  -- 20s.
    ---------------------------------------------------------------------
    ------ JOYSTICK OK---------------------------------------------------

    cantidad_datos_Joystick: constant := 200;
    type Indice_Secuencia_Joystick is mod cantidad_datos_Joystick;
    type tipo_Secuencia_Joystick is array (Indice_Secuencia_Joystick) 
                                             of Joystick_Samples_Type;

   Joystick_Simulation: tipo_Secuencia_Joystick := (others => (  0, 10));


    cantidad_datos_Power: constant := 200;
    type Indice_Secuencia_Power is mod cantidad_datos_Power;
    type tipo_Secuencia_Power is array (Indice_Secuencia_Power) of Power_Samples_Type;


      Power_Simulation: tipo_Secuencia_Power := (others => 500);

                 
    ------ PILOT'S PRESENCE ---------------------------------------------

    cantidad_datos_PilotPresence: constant := 200;
    type Indice_Secuencia_PilotPresence is mod cantidad_datos_PilotPresence;
    type tipo_Secuencia_PilotPresence is array (Indice_Secuencia_PilotPresence) of PilotPresence_Samples_Type;

    PilotPresence_Simulation: tipo_Secuencia_PilotPresence :=  -- 1 muestra cada 100ms.
                 ( others => 1 );                
    ---------------------------------------------------------------------
    ------ PILOT'S BUTTON -----------------------------------------------

    cantidad_datos_PilotButton: constant := 200;
    type Indice_Secuencia_PilotButton is mod cantidad_datos_PilotButton;
    type tipo_Secuencia_PilotButton is array (Indice_Secuencia_PilotButton) of PilotButton_Samples_Type;

    PilotButton_Simulation: tipo_Secuencia_PilotButton :=  -- 1 muestra cada 100ms.
                 ( others => 0 );
end testing_1;



