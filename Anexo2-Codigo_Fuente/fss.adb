-- Pedro Mario Cea Torralba
-- Iván de Diego Benítez
-- Álvaro Nicolás Díaz Valle
-- Iván García Ventura
--
-- FSS – Prototipo 3 (avanzado)
--
-- En este prototipo hemos implementado:
--   · Las tareas periódicas T_Speed, T_Position_Altitude y T_Collision
--     con periodos 300 ms, 200 ms y 250 ms respectivamente.
--
--   · El objeto protegido Protected_Speed_Altitude, que almacena la
--     velocidad y la altitud actuales de la aeronave para que puedan
--     compartirlas Speed, Position_Altitude y Collision.
--
--   · El objeto protegido Protected_Access_Pitch_Roll, que arbitra el
--     acceso a los mandos de Pitch y Roll, dando prioridad a Collision
--     sobre Position_Altitude cuando se ejecuta una maniobra de evasión.
--
--   · El proceso Speed, que:
--       - Lee la potencia del piloto y la mapea a velocidad.
--       - Aplica los incrementos de velocidad por inicio de maniobra
--         de cabeceo (+150 km/h), alabeo (+100 km/h) o ambos (+200 km/h),
--         sin superar nunca 1000 km/h ni bajar de 300 km/h.
--       - Actualiza la velocidad en los motores y en Protected_Speed_Altitude
--         y gestiona la Luz 2 en los valores límite.
--
--   · El proceso Position_Altitude, que:
--       - Lee el joystick del piloto y regula cabeceo y alabeo con
--         zona muerta ±3º y límites ±30º (pitch) y ±45º (roll).
--       - Controla la altitud, la Luz 1 y los mensajes de aviso por
--         exceso de alabeo, publicando además la altitud en
--         Protected_Speed_Altitude.
--
--   · El proceso Collision, que:
--       - Lee la distancia a obstáculos, la velocidad y la altitud
--         desde Protected_Speed_Altitude, así como la luz ambiental
--         y la presencia del piloto.
--       - Calcula el tiempo hasta la colisión y genera alarmas según
--         los umbrales de tiempo definidos.
--       - Cuando es necesario, ordena una maniobra automática de evasión
--         con 45º de alabeo durante unos segundos, bloqueando las
--         órdenes del piloto sobre Pitch y Roll mediante
--         Protected_Access_Pitch_Roll.

with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time;        use Ada.Real_Time;
with System;               use System;

with Tools;        use Tools;
with devicesFSS_V1; use devicesFSS_V1;

-- NO ACTIVAR ESTE PAQUETE MIENTRAS NO SE TENGA PROGRAMADA LA INTERRUPCION
-- Packages needed to generate button interrupts
-- with Ada.Interrupts.Names;
-- with Button_Interrupt; use Button_Interrupt;

package body fss is

   --------------------------------------------------------------------
   -- Procedimiento exportado de fondo
   --------------------------------------------------------------------
   procedure Background is
   begin
      loop
         null;
      end loop;
   end Background;

   --------------------------------------------------------------------
   -- Cabeceras de procedimientos de tareas
   --------------------------------------------------------------------
   procedure Speed;
   procedure Position_Altitude;
   procedure Collision;

   --------------------------------------------------------------------
   -- Objetos protegidos PROTOTIPO 3
   --------------------------------------------------------------------

   -- 1) Velocidad y altitud compartidas
   protected Protected_Speed_Altitude is
      pragma Priority (30);
      procedure Set_Speed    (S : in Speed_Samples_Type);
      procedure Get_Speed    (S : out Speed_Samples_Type);
      procedure Set_Altitude (A : in Altitude_Samples_Type);
      procedure Get_Altitude (A : out Altitude_Samples_Type);
   private
      Prot_Speed    : Speed_Samples_Type    := 0;
      Prot_Altitude : Altitude_Samples_Type := 8000;
   end Protected_Speed_Altitude;

   protected body Protected_Speed_Altitude is
      procedure Set_Speed (S : in Speed_Samples_Type) is
      begin
         Prot_Speed := S;
      end Set_Speed;

      procedure Get_Speed (S : out Speed_Samples_Type) is
      begin
         S := Prot_Speed;
      end Get_Speed;

      procedure Set_Altitude (A : in Altitude_Samples_Type) is
      begin
         Prot_Altitude := A;
      end Set_Altitude;

      procedure Get_Altitude (A : out Altitude_Samples_Type) is
      begin
         A := Prot_Altitude;
      end Get_Altitude;
   end Protected_Speed_Altitude;

   -- 2) Acceso a Pitch/Roll con prioridad para Collision
   protected Protected_Access_Pitch_Roll is
      pragma Priority (30);
      -- Escrituras del piloto (Position_Altitude)
      procedure Set_Pitch_Pilot (P : in Pitch_Samples_Type);
      procedure Set_Roll_Pilot  (R : in Roll_Samples_Type);

      -- Escrituras de Collision (prioritarias)
      procedure Set_Pitch_Collision (P : in Pitch_Samples_Type);
      procedure Set_Roll_Collision  (R : in Roll_Samples_Type);

      -- Lecturas para Speed / Collision
      procedure Get_Pitch (P : out Pitch_Samples_Type);
      procedure Get_Roll  (R : out Roll_Samples_Type);

      -- Cerrojo para bloquear al piloto mientras dura la evasión
      procedure Open_Var_Lock;
      procedure Close_Var_Lock;
   private
      Prot_Pitch     : Pitch_Samples_Type := 0;
      Prot_Roll      : Roll_Samples_Type  := 0;
      Collision_Lock : Boolean := False;
   end Protected_Access_Pitch_Roll;

   protected body Protected_Access_Pitch_Roll is
      procedure Set_Pitch_Pilot (P : in Pitch_Samples_Type) is
      begin
         if Collision_Lock then
            null;
         else
            Prot_Pitch := P;
            Set_Aircraft_Pitch (P);
         end if;
      end Set_Pitch_Pilot;

      procedure Set_Roll_Pilot (R : in Roll_Samples_Type) is
      begin
         if Collision_Lock then
            null;
         else
            Prot_Roll := R;
            Set_Aircraft_Roll (R);
         end if;
      end Set_Roll_Pilot;

      procedure Set_Pitch_Collision (P : in Pitch_Samples_Type) is
      begin
         Prot_Pitch := P;
         Set_Aircraft_Pitch (P);
      end Set_Pitch_Collision;

      procedure Set_Roll_Collision (R : in Roll_Samples_Type) is
      begin
         Prot_Roll := R;
         Set_Aircraft_Roll (R);
      end Set_Roll_Collision;

      procedure Get_Pitch (P : out Pitch_Samples_Type) is
      begin
         P := Prot_Pitch;
      end Get_Pitch;

      procedure Get_Roll (R : out Roll_Samples_Type) is
      begin
         R := Prot_Roll;
      end Get_Roll;

      procedure Open_Var_Lock is
      begin
         Collision_Lock := False;
      end Open_Var_Lock;

      procedure Close_Var_Lock is
      begin
         Collision_Lock := True;
      end Close_Var_Lock;
   end Protected_Access_Pitch_Roll;

   --------------------------------------------------------------------
   -- Tareas
   --------------------------------------------------------------------
   task T_Speed is
      pragma Priority (10);
   end T_Speed;

   task T_Position_Altitude is
      pragma Priority (30);
   end T_Position_Altitude;

   task T_Collision is
      pragma Priority (20);
   end T_Collision;

   task body T_Speed is
      Next_Release : Time;
      Period       : Time_Span := Milliseconds (300);
   begin
      Next_Release := Tools.Big_Bang + Period;
      loop
         Start_Activity ("T_Speed");
         Speed;
         Finish_Activity ("T_Speed");
         delay until Next_Release;
         Next_Release := Next_Release + Period;
      end loop;
   end T_Speed;

   task body T_Position_Altitude is
      Next_Release : Time;
      Period       : Time_Span := Milliseconds (200);
   begin
      Next_Release := Tools.Big_Bang + Period;
      loop
         Start_Activity ("T_Position_Altitude");
         Position_Altitude;
         Finish_Activity ("T_Position_Altitude");
         delay until Next_Release;
         Next_Release := Next_Release + Period;
      end loop;
   end T_Position_Altitude;

   task body T_Collision is
      Next_Release : Time;
      Period       : Time_Span := Milliseconds (250);
   begin
      Next_Release := Tools.Big_Bang + Period;
      loop
         Start_Activity ("T_Collision");
         Collision;
         Finish_Activity ("T_Collision");
         delay until Next_Release;
         Next_Release := Next_Release + Period;
      end loop;
   end T_Collision;

   --------------------------------------------------------------------
   -- Estado global para Speed (detección de flancos)
   --------------------------------------------------------------------
   Prev_Pitch_For_Speed : Pitch_Samples_Type := 0;
   Prev_Roll_For_Speed  : Roll_Samples_Type  := 0;
   Threshold_Pitch      : constant Pitch_Samples_Type := 1;
   Threshold_Roll       : constant Roll_Samples_Type  := 1;

   --------------------------------------------------------------------
   -- Estado global para maniobra de evasión de Collision
   --------------------------------------------------------------------
   Diverting  : Boolean := False;
   Divert_End : Time    := Time_First;

   --------------------------------------------------------------------
   -- Implementación de Speed
   --------------------------------------------------------------------
   procedure Speed is
      MAX_SPEED : constant Speed_Samples_Type := 1000;
      MIN_SPEED : constant Speed_Samples_Type := 300;

      Current_Pw : Power_Samples_Type := 0;
      Base_S     : Speed_Samples_Type := 0;
      Desired_S  : Speed_Samples_Type := 0;
      Sensed_S   : Speed_Samples_Type := 0;
   begin
      Read_Power (Current_Pw);
      Display_Pilot_Power (Current_Pw);

      Base_S    := Speed_Samples_Type (Float (Current_Pw) * 1.2);
      Desired_S := Base_S;

      declare
         P : Pitch_Samples_Type := 0;
         R : Roll_Samples_Type  := 0;
         Pitch_Started : Boolean := False;
         Roll_Started  : Boolean := False;
      begin
         Protected_Access_Pitch_Roll.Get_Pitch (P);
         Protected_Access_Pitch_Roll.Get_Roll  (R);

         Pitch_Started :=
           Integer (P) - Integer (Prev_Pitch_For_Speed) > Integer (Threshold_Pitch);
         Roll_Started  :=
           Integer (R) - Integer (Prev_Roll_For_Speed)  > Integer (Threshold_Roll);

         if (Pitch_Started and Roll_Started) then
            Desired_S :=
              Speed_Samples_Type (Integer (Desired_S) + 200);
         elsif (Pitch_Started) then
            Desired_S :=
              Speed_Samples_Type (Integer (Desired_S) + 150);
         elsif (Roll_Started) then
            Desired_S :=
              Speed_Samples_Type (Integer (Desired_S) + 100);
         end if;

         if (Desired_S > MAX_SPEED) then
            Desired_S := MAX_SPEED;
         elsif (Desired_S < MIN_SPEED) then
            Desired_S := MIN_SPEED;
         end if;

         Set_Speed (Desired_S);
         Protected_Speed_Altitude.Set_Speed (Desired_S);

         if (Desired_S = MAX_SPEED) or else (Desired_S = MIN_SPEED) then
            Light_2 (On);
         else
            Light_2 (Off);
         end if;

         Sensed_S := Read_Speed;
         Display_Speed (Sensed_S);

         Prev_Pitch_For_Speed := P;
         Prev_Roll_For_Speed  := R;
      end;
   end Speed;

   --------------------------------------------------------------------
   -- Implementación de Position_Altitude
   --------------------------------------------------------------------
   procedure Position_Altitude is
      Current_J      : Joystick_Samples_Type := (0, 0);
      Target_Pitch   : Pitch_Samples_Type := 0;
      Target_Roll    : Roll_Samples_Type  := 0;
      Aircraft_Pitch : Pitch_Samples_Type;
      Aircraft_Roll  : Roll_Samples_Type;

      Current_A          : Altitude_Samples_Type := 8000;
      MAX_PITCH          : constant Pitch_Samples_Type := 30;
      MIN_PITCH          : constant Pitch_Samples_Type := -30;
      MAX_ROLL           : constant Roll_Samples_Type := 45;
      MIN_ROLL           : constant Roll_Samples_Type := -45;
      MAX_ROLL_ALERT     : constant Roll_Samples_Type := 35;
      MIN_ALTITUDE_ALERT : constant Altitude_Samples_Type := 2500;
      MAX_ALTITUDE_ALERT : constant Altitude_Samples_Type := 9500;
      MIN_ALTITUDE       : constant Altitude_Samples_Type := 2000;
      MAX_ALTITUDE       : constant Altitude_Samples_Type := 10000;
   begin
      Read_Joystick (Current_J);

      Target_Pitch := -1 * Pitch_Samples_Type (Current_J (x));
      Target_Roll  := -1 * Roll_Samples_Type  (Current_J (y));

      Aircraft_Pitch := Read_Pitch;
      Aircraft_Roll  := Read_Roll;

      Display_Joystick (Current_J);
      Display_Pitch (Aircraft_Pitch);
      Display_Roll  (Aircraft_Roll);

      Current_A := Read_Altitude;
      Display_Altitude (Current_A);
      Protected_Speed_Altitude.Set_Altitude (Current_A);

      if (Current_A < MIN_ALTITUDE_ALERT) then
         Light_1 (On);
      elsif (Current_A > MAX_ALTITUDE_ALERT) then
         Light_1 (On);
      else
         Light_1 (Off);
      end if;
      
      if (abs (Integer (Target_Pitch)) <= 3) then
         Protected_Access_Pitch_Roll.Set_Pitch_Pilot (0);
      elsif (Target_Pitch > MAX_PITCH) then
         Protected_Access_Pitch_Roll.Set_Pitch_Pilot (MAX_PITCH);
      elsif (Target_Pitch < MIN_PITCH) then
         Protected_Access_Pitch_Roll.Set_Pitch_Pilot (MIN_PITCH);
      else
         if (Current_A > MAX_ALTITUDE) then
            Protected_Access_Pitch_Roll.Set_Pitch_Pilot (0);
         elsif (Current_A < MIN_ALTITUDE) then
            Protected_Access_Pitch_Roll.Set_Pitch_Pilot (0);
         else 
            Protected_Access_Pitch_Roll.Set_Pitch_Pilot (Target_Pitch);
         end if;
      end if;

      if (abs (Integer (Target_Roll)) <= 3) then
         Protected_Access_Pitch_Roll.Set_Roll_Pilot (0);
      elsif (Target_Roll > MAX_ROLL) then
         Protected_Access_Pitch_Roll.Set_Roll_Pilot (MAX_ROLL);
      elsif (Target_Roll < MIN_ROLL) then
         Protected_Access_Pitch_Roll.Set_Roll_Pilot (MIN_ROLL);
      else
         Protected_Access_Pitch_Roll.Set_Roll_Pilot (Target_Roll);
      end if;


      if (abs (Integer (Aircraft_Roll)) > Integer (MAX_ROLL_ALERT)) then
         Display_Message ("Too much roll");
      end if;
   end Position_Altitude;

   --------------------------------------------------------------------
   -- Implementación de Collision
   --------------------------------------------------------------------
   procedure Collision is
      D  : Distance_Samples_Type := 0;
      L  : Light_Samples_Type    := 0;
      PP : PilotPresence_Samples_Type;

      S : Speed_Samples_Type    := 0;
      A : Altitude_Samples_Type := 0;

      TTC_Threshold_Warn   : Float := 10.0;
      TTC_Threshold_Divert : Float := 5.0;

      Now_Time : Time := Clock;

      function Time_To_Collision_Seconds
        (Dist : Distance_Samples_Type;
         Spd  : Speed_Samples_Type) return Float
      is
      begin
         if (Spd = 0) then
            return 1.0E9;
         else
            return Float (Dist) * 3.6 / Float (Spd);
         end if;
      end Time_To_Collision_Seconds;

   begin
      Read_Distance (D);
      Read_Light_Intensity (L);
      PP := Read_PilotPresence;

      Protected_Speed_Altitude.Get_Speed (S);
      Protected_Speed_Altitude.Get_Altitude (A);

      if (L < 500) or else (PP = 0) then
         TTC_Threshold_Warn   := 15.0;
         TTC_Threshold_Divert := 10.0;
      else
         TTC_Threshold_Warn   := 10.0;
         TTC_Threshold_Divert := 5.0;
      end if;

      if (D > 5000) then
         Alarm (0);

         if (Diverting and then Now_Time >= Divert_End) then
            Protected_Access_Pitch_Roll.Set_Roll_Collision (0);
            Protected_Access_Pitch_Roll.Close_Var_Lock;
            Diverting := False;
         end if;

         return;
      end if;

      declare
         TTC : constant Float := Time_To_Collision_Seconds (D, S);
      begin
         if (TTC < TTC_Threshold_Warn) then
            Alarm (4);
         else
            Alarm (0);
         end if;

         if (TTC < TTC_Threshold_Divert) then
            if (not Diverting) then
               Protected_Access_Pitch_Roll.Close_Var_Lock;
               Protected_Access_Pitch_Roll.Set_Roll_Collision (45);
               Divert_End := Now_Time + Milliseconds (3000);
               Diverting  := True;
            end if;
         end if;

         if (Diverting) then
            if (Now_Time >= Divert_End) then
               Protected_Access_Pitch_Roll.Set_Roll_Collision (0);
               Protected_Access_Pitch_Roll.Open_Var_Lock;
               Diverting := False;
            else
               Protected_Access_Pitch_Roll.Set_Roll_Collision (45);
            end if;
         end if;
      end;
   end Collision;

begin
   Start_Activity ("Programa Principal");
   -- Las tareas se activan automáticamente al elaborarse el paquete
   Finish_Activity ("Programa Principal");
end fss;
