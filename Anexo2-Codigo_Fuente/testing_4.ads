with Ada.Real_Time; use Ada.Real_Time;
with devicesFSS_V1; use devicesFSS_V1;

package testing_4 is

   -------------------------------------------------------------------------
   -- Índice común: tu devicesfss_v1.adb usa "mod 200" y convierte a Indice_*
   -- Por tanto el rango debe ser 0..199 (si fuera 1..200, fallaría con 0).
   -------------------------------------------------------------------------
   type Index_200 is range 0 .. 199;

   subtype Indice_Secuencia_Distancia      is Index_200;
   subtype Indice_Secuencia_Light          is Index_200;
   subtype Indice_Secuencia_Joystick       is Index_200;
   subtype Indice_Secuencia_Power          is Index_200;
   subtype Indice_Secuencia_PilotPresence  is Index_200;
   subtype Indice_Secuencia_PilotButton    is Index_200;

   -------------------------------------------------------------------------
   -- Tipos de secuencia (CONSTRAINED) para evitar "unconstrained subtype..."
   -------------------------------------------------------------------------
   type tipo_Secuencia_Distancia is array (Indice_Secuencia_Distancia) of Distance_Samples_Type;
   type tipo_Secuencia_Light     is array (Indice_Secuencia_Light)     of Light_Samples_Type;
   type tipo_Secuencia_Joystick  is array (Indice_Secuencia_Joystick)  of Joystick_Samples_Type;
   type tipo_Secuencia_Power     is array (Indice_Secuencia_Power)     of Power_Samples_Type;

   type tipo_Secuencia_PilotPresence is array (Indice_Secuencia_PilotPresence) of PilotPresence_Samples_Type;
   type tipo_Secuencia_PilotButton   is array (Indice_Secuencia_PilotButton)   of PilotButton_Samples_Type;

   -------------------------------------------------------------------------
   -- WCETs (para Tools.Execution_Time)
   -- Ajusta si tu profesor pide valores concretos; aquí son conservadores.
   -------------------------------------------------------------------------
   WCET_Distance      : constant Time_Span := Milliseconds (1);
   WCET_Light         : constant Time_Span := Milliseconds (1);
   WCET_Joystick      : constant Time_Span := Milliseconds (1);
   WCET_Power         : constant Time_Span := Milliseconds (1);
   WCET_PilotPresence : constant Time_Span := Milliseconds (1);
   WCET_PilotButton   : constant Time_Span := Milliseconds (1);

   WCET_Speed    : constant Time_Span := Milliseconds (1);
   WCET_Altitude : constant Time_Span := Milliseconds (1);
   WCET_Pitch    : constant Time_Span := Milliseconds (1);
   WCET_Roll     : constant Time_Span := Milliseconds (1);

   WCET_Alarm    : constant Time_Span := Milliseconds (1);
   WCET_Display  : constant Time_Span := Milliseconds (2);

   -------------------------------------------------------------------------
   -- Secuencias de simulación (Prueba 4 orientada a VELOCIDAD + DISPLAY)
   --
   -- Distancia > 5000 => "no obstáculo" (para que Collision no moleste)
   -- Luz alta y piloto presente.
   -- Potencia: 90 -> 400 -> 900 (para ver 108, 480, 1000 saturado)
   -- Joystick: neutro casi siempre; en un punto metemos un cambio para
   --           disparar los incrementos de velocidad si lo quieres observar.
   -- Botón: un pulso para pasar a MANUAL (ver "MODE: MANUAL" en Display).
   -------------------------------------------------------------------------
   Distance_Simulation : constant tipo_Secuencia_Distancia :=
     (others => 6000);

   Light_Intensity_Simulation : constant tipo_Secuencia_Light :=
     (others => 1000);

   PilotPresence_Simulation : constant tipo_Secuencia_PilotPresence :=
     (others => 1);

   -- Botón del piloto: pulso en el índice 5 (1 ciclo) para conmutar modo
   PilotButton_Simulation : constant tipo_Secuencia_PilotButton :=
     (5 => 1,
      others => 0);

   -- Potencia del piloto (0..1023):
   --  90*1.2 = 108 (pero tu Speed satura a 300 mínimo)
   --  400*1.2 = 480
   --  900*1.2 = 1080 -> saturado a 1000
   Power_Simulation : constant tipo_Secuencia_Power :=
     (0 =>  90,
      1 => 400,
      2 => 900,
      others => 900);

   -- Joystick: mayormente neutro (0,0).
   -- En un punto forzamos un cambio para que Speed detecte flanco (si aplica)
   Joystick_Simulation : constant tipo_Secuencia_Joystick :=
     (0 => (x => 0,  y => 0),
      1 => (x => 0,  y => 0),
      2 => (x => 0,  y => 0),
      3 => (x => 10, y => -10),  -- cambio puntual
      4 => (x => 0,  y => 0),
      others => (x => 0, y => 0));

end testing_4;

