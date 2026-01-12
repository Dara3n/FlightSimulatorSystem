-- FSS – Prototipo 5 (Modo Automático/Manual del Piloto)
--
-- Cambios principales:
--  * Se incorpora la selección de modo AUTOMATIC / MANUAL, conmutada por
--    pulsación del botón del piloto (interrupción externa).
--  * Todas las tareas siguen ejecutándose permanentemente, leyendo sensores
--    y analizando datos, pero las órdenes a actuadores de control del avión
--    (velocidad, pitch, roll) solo se emiten en modo AUTOMATIC.
--  * Se añade una tarea Display (1 Hz) que visualiza un “status record”.
--
-- Especificación (FSS v2): sección 6 (Modo Automático/Manual) y 7 (Display).

with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time;        use Ada.Real_Time;
with System;               use System;

with Ada.Interrupts.Names;
with Button_Interrupt;  -- Generador de interrupciones del botón (simulación)

with Tools;         use Tools;
with devicesFSS_V1; use devicesFSS_V1;

package body fss is

   --------------------------------------------------------------------
   -- Tipos auxiliares
   --------------------------------------------------------------------
   type Mode_Type is (Automatic, Manual);

   type Warning_Id is (No_Warning,
                       Warn_Too_Much_Roll,
                       Warn_Diverting);

   --------------------------------------------------------------------
   -- Estado global para Speed (detección de flancos)
   --------------------------------------------------------------------
   Prev_Pitch_For_Speed : Pitch_Samples_Type := 0;
   Prev_Roll_For_Speed  : Roll_Samples_Type  := 0;
   Threshold_Pitch      : constant Pitch_Samples_Type := 1;
   Threshold_Roll       : constant Roll_Samples_Type  := 1;

   --------------------------------------------------------------------
   -- Estado global para Collision (maniobra evasiva)
   --------------------------------------------------------------------
   Diverting  : Boolean := False;
   Divert_End : Time    := Time_First;

   --------------------------------------------------------------------
   -- Modo seleccionado (compartido)
   --------------------------------------------------------------------
   protected Selected_Mode is
      pragma Priority (30);
      procedure Set (M : in Mode_Type);
      procedure Get (M : out Mode_Type);
   private
      Current : Mode_Type := Automatic; -- El sistema arranca en automático
   end Selected_Mode;

   protected body Selected_Mode is
      procedure Set (M : in Mode_Type) is
      begin
         Current := M;
      end Set;

      procedure Get (M : out Mode_Type) is
      begin
         M := Current;
      end Get;
   end Selected_Mode;

   --------------------------------------------------------------------
   -- Interrupción del botón de modo: ISR + evento para tarea esporádica
   -- (Attach_Handler a External_Interrupt_2 con prioridad
   --  System.Interrupt_Priority'First + 9).
   --------------------------------------------------------------------
   protected Mode_Interrupt is
      pragma Interrupt_Priority (System.Interrupt_Priority'First + 9);

      entry Wait_Event;

      procedure ISR;
      pragma Attach_Handler (ISR, Ada.Interrupts.Names.External_Interrupt_2);
   private
      Pending : Boolean := False;
   end Mode_Interrupt;

   protected body Mode_Interrupt is
      entry Wait_Event when Pending is
      begin
         Pending := False;
      end Wait_Event;

      procedure ISR is
      begin
         Pending := True;
      end ISR;
   end Mode_Interrupt;

   --------------------------------------------------------------------
   -- Datos compartidos: velocidad y altitud actuales
   --------------------------------------------------------------------
   protected Protected_Speed_Altitude is
      pragma Priority (30);
      procedure Set_Speed_Current (S : in Speed_Samples_Type);
      procedure Get_Speed_Current (S : out Speed_Samples_Type);

      procedure Set_Altitude (A : in Altitude_Samples_Type);
      procedure Get_Altitude (A : out Altitude_Samples_Type);
   private
      Prot_Speed    : Speed_Samples_Type    := 0;
      Prot_Altitude : Altitude_Samples_Type := 8000;
   end Protected_Speed_Altitude;

   protected body Protected_Speed_Altitude is
      procedure Set_Speed_Current (S : in Speed_Samples_Type) is
      begin
         Prot_Speed := S;
      end Set_Speed_Current;

      procedure Get_Speed_Current (S : out Speed_Samples_Type) is
      begin
         S := Prot_Speed;
      end Get_Speed_Current;

      procedure Set_Altitude (A : in Altitude_Samples_Type) is
      begin
         Prot_Altitude := A;
      end Set_Altitude;

      procedure Get_Altitude (A : out Altitude_Samples_Type) is
      begin
         A := Prot_Altitude;
      end Get_Altitude;
   end Protected_Speed_Altitude;

   --------------------------------------------------------------------
   -- Arbitraje Pitch/Roll: el piloto puede ser bloqueado durante evasión
   --------------------------------------------------------------------
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
   -- Status record (para Display 1Hz)
   --------------------------------------------------------------------
   protected Status_Record is
      pragma Priority (30);

      procedure Set_Mode (M : in Mode_Type);
      procedure Set_Power (P : in Power_Samples_Type);
      procedure Set_Commanded_Speed (S : in Speed_Samples_Type);
      procedure Set_Current_Speed (S : in Speed_Samples_Type);
      procedure Set_Altitude (A : in Altitude_Samples_Type);
      procedure Set_Joystick (J : in Joystick_Samples_Type);
      procedure Set_Attitude (P : in Pitch_Samples_Type; R : in Roll_Samples_Type);
      procedure Set_Warning (W : in Warning_Id);

      procedure Get
        (M          : out Mode_Type;
         A          : out Altitude_Samples_Type;
         Power      : out Power_Samples_Type;
         Cmd_Speed  : out Speed_Samples_Type;
         Cur_Speed  : out Speed_Samples_Type;
         J          : out Joystick_Samples_Type;
         Pitch      : out Pitch_Samples_Type;
         Roll       : out Roll_Samples_Type;
         W          : out Warning_Id);
   private
      Mode_Sel   : Mode_Type := Automatic;
      Pow        : Power_Samples_Type := 0;
      Speed_Cmd  : Speed_Samples_Type := 0;
      Speed_Cur  : Speed_Samples_Type := 0;
      Alt        : Altitude_Samples_Type := 8000;
      Joy        : Joystick_Samples_Type := (x => 0, y => 0);
      Att_Pitch  : Pitch_Samples_Type := 0;
      Att_Roll   : Roll_Samples_Type  := 0;
      Warning    : Warning_Id := No_Warning;
   end Status_Record;

   protected body Status_Record is
      procedure Set_Mode (M : in Mode_Type) is
      begin
         Mode_Sel := M;
      end Set_Mode;

      procedure Set_Power (P : in Power_Samples_Type) is
      begin
         Pow := P;
      end Set_Power;

      procedure Set_Commanded_Speed (S : in Speed_Samples_Type) is
      begin
         Speed_Cmd := S;
      end Set_Commanded_Speed;

      procedure Set_Current_Speed (S : in Speed_Samples_Type) is
      begin
         Speed_Cur := S;
      end Set_Current_Speed;

      procedure Set_Altitude (A : in Altitude_Samples_Type) is
      begin
         Alt := A;
      end Set_Altitude;

      procedure Set_Joystick (J : in Joystick_Samples_Type) is
      begin
         Joy := J;
      end Set_Joystick;

      procedure Set_Attitude (P : in Pitch_Samples_Type; R : in Roll_Samples_Type) is
      begin
         Att_Pitch := P;
         Att_Roll  := R;
      end Set_Attitude;

      procedure Set_Warning (W : in Warning_Id) is
      begin
         -- Prioridad: la maniobra de evasión (collision) no se debe ocultar
         -- por avisos de menor prioridad (p.ej. exceso de roll).
         if W = Warn_Diverting then
            Warning := Warn_Diverting;
         elsif W = Warn_Too_Much_Roll then
            if Warning /= Warn_Diverting then
               Warning := Warn_Too_Much_Roll;
            end if;
         else -- No_Warning
            if Warning /= Warn_Diverting then
               Warning := No_Warning;
            end if;
         end if;
      end Set_Warning;

      procedure Get
        (M          : out Mode_Type;
         A          : out Altitude_Samples_Type;
         Power      : out Power_Samples_Type;
         Cmd_Speed  : out Speed_Samples_Type;
         Cur_Speed  : out Speed_Samples_Type;
         J          : out Joystick_Samples_Type;
         Pitch      : out Pitch_Samples_Type;
         Roll       : out Roll_Samples_Type;
         W          : out Warning_Id) is
      begin
         M         := Mode_Sel;
         A         := Alt;
         Power     := Pow;
         Cmd_Speed := Speed_Cmd;
         Cur_Speed := Speed_Cur;
         J         := Joy;
         Pitch     := Att_Pitch;
         Roll      := Att_Roll;
         W         := Warning;
      end Get;
   end Status_Record;

   --------------------------------------------------------------------
   -- Background: mantiene vivo el sistema
   --------------------------------------------------------------------
   procedure Background is
   begin
      loop
         null;
      end loop;
   end Background;

   --------------------------------------------------------------------
   -- Cabeceras de procesos
   --------------------------------------------------------------------
   procedure Speed;
   procedure Position_Altitude;
   procedure Collision;
   procedure Display;
   procedure Mode_Manager;

   --------------------------------------------------------------------
   -- Tareas (periodicidad según especificación)
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

   task T_Display is
      pragma Priority (5);
   end T_Display;

   task T_Mode is
      pragma Priority (25);
   end T_Mode;

   --------------------------------------------------------------------
   -- Task bodies
   --------------------------------------------------------------------
   task body T_Speed is
      Next : Time := Clock + Milliseconds (300);
   begin
      loop
         Start_Activity ("T_Speed");
         Speed;
         Finish_Activity ("T_Speed");
         delay until Next;
         Next := Next + Milliseconds (300);
      end loop;
   end T_Speed;

   task body T_Position_Altitude is
      Next : Time := Clock + Milliseconds (200);
   begin
      loop
         Start_Activity ("T_Position_Altitude");
         Position_Altitude;
         Finish_Activity ("T_Position_Altitude");
         delay until Next;
         Next := Next + Milliseconds (200);
      end loop;
   end T_Position_Altitude;

   task body T_Collision is
      Next : Time := Clock + Milliseconds (250);
   begin
      loop
         Start_Activity ("T_Collision");
         Collision;
         Finish_Activity ("T_Collision");
         delay until Next;
         Next := Next + Milliseconds (250);
      end loop;
   end T_Collision;

   task body T_Display is
      Next : Time := Clock + Seconds (1);
   begin
      loop
         Start_Activity ("T_Display");
         Display;
         Finish_Activity ("T_Display");
         delay until Next;
         Next := Next + Seconds (1);
      end loop;
   end T_Display;

   task body T_Mode is
   begin
      loop
         Start_Activity ("T_Mode");
         Mode_Manager;
         Finish_Activity ("T_Mode");
      end loop;
   end T_Mode;

   --------------------------------------------------------------------
   -- Implementación de procesos
   --------------------------------------------------------------------

   procedure Speed is
      P         : Power_Samples_Type;
      Cmd_Speed : Speed_Samples_Type;
      Mode      : Mode_Type;

      Cur_Pitch : Pitch_Samples_Type;
      Cur_Roll  : Roll_Samples_Type;

      Cur_Speed : Speed_Samples_Type;

      Pitch_Up  : Boolean := False;
      Roll_Up   : Boolean := False;
   begin
      Read_Power (P);
      Status_Record.Set_Power (P);

      -- Velocidad base (P * 1.2)
      Cmd_Speed := Speed_Samples_Type (Float (P) * 1.2);

      -- Detección de inicio de maniobra por flanco positivo
      Protected_Access_Pitch_Roll.Get_Pitch (Cur_Pitch);
      Protected_Access_Pitch_Roll.Get_Roll  (Cur_Roll);

      Pitch_Up := (Cur_Pitch - Prev_Pitch_For_Speed) > Threshold_Pitch;
      Roll_Up  := (Cur_Roll  - Prev_Roll_For_Speed)  > Threshold_Roll;

      Prev_Pitch_For_Speed := Cur_Pitch;
      Prev_Roll_For_Speed  := Cur_Roll;

      if Pitch_Up and then Roll_Up then
         Cmd_Speed := Cmd_Speed + 200;
      elsif Pitch_Up then
         Cmd_Speed := Cmd_Speed + 150;
      elsif Roll_Up then
         Cmd_Speed := Cmd_Speed + 100;
      end if;

      -- Saturación 300..1000
      if Cmd_Speed > 1000 then
         Cmd_Speed := 1000;
      elsif Cmd_Speed < 300 then
         Cmd_Speed := 300;
      end if;

      Status_Record.Set_Commanded_Speed (Cmd_Speed);

      -- Aviso por límites (siempre, independientemente del modo)
      if (Cmd_Speed = 300) or else (Cmd_Speed = 1000) then
         Light_2 (On);
      else
         Light_2 (Off);
      end if;

      -- Actuación (solo en automático)
      Selected_Mode.Get (Mode);
      Status_Record.Set_Mode (Mode);

      if Mode = Automatic then
         devicesFSS_V1.Set_Speed (Cmd_Speed);
      end if;

      -- Actualiza velocidad actual leída de la aeronave
      Cur_Speed := Read_Speed;
      Protected_Speed_Altitude.Set_Speed_Current (Cur_Speed);
      Status_Record.Set_Current_Speed (Cur_Speed);
   end Speed;

   procedure Position_Altitude is
      J            : Joystick_Samples_Type;
      Target_Pitch : Pitch_Samples_Type;
      Target_Roll  : Roll_Samples_Type;

      Current_Pitch : Pitch_Samples_Type;
      Current_Roll  : Roll_Samples_Type;

      A     : Altitude_Samples_Type;
      Mode  : Mode_Type;
   begin
      Read_Joystick (J);
      Status_Record.Set_Joystick (J);

      -- El joystick devuelve ángulos; invertimos signo como en prototipos previos
      Target_Pitch := -Pitch_Samples_Type (J (x));
      Target_Roll  := -Roll_Samples_Type  (J (y));

      -- Altitud actual
      A := Read_Altitude;
      Protected_Speed_Altitude.Set_Altitude (A);
      Status_Record.Set_Altitude (A);

      -- Estado actual de la aeronave
      Current_Pitch := Read_Pitch;
      Current_Roll  := Read_Roll;
      Status_Record.Set_Attitude (Current_Pitch, Current_Roll);

      -- Luz 1: avisos por altitud
      if (A < 2500) or else (A > 9500) then
         Light_1 (On);
      else
         Light_1 (Off);
      end if;

      -- Zona muerta ±3º
      if Target_Pitch in -3 .. 3 then
         Target_Pitch := 0;
      end if;

      if Target_Roll in -3 .. 3 then
         Target_Roll := 0;
      end if;

      -- Saturación: pitch ±30, roll ±45
      if Target_Pitch > 30 then
         Target_Pitch := 30;
      elsif Target_Pitch < -30 then
         Target_Pitch := -30;
      end if;

      if Target_Roll > 45 then
         Target_Roll := 45;
      elsif Target_Roll < -45 then
         Target_Roll := -45;
      end if;

      -- Nivelado/inhibición por altitud extrema
      if (A <= 2000) or else (A >= 10_000) then
         Target_Pitch := 0;
      end if;

      -- Aviso por exceso de alabeo (Display) -> warning en status
      if abs (Current_Roll) > 35 then
         Status_Record.Set_Warning (Warn_Too_Much_Roll);
      else
         Status_Record.Set_Warning (No_Warning);
      end if;

      -- Actuación (solo en automático)
      Selected_Mode.Get (Mode);
      Status_Record.Set_Mode (Mode);

      if Mode = Automatic then
         Protected_Access_Pitch_Roll.Set_Pitch_Pilot (Target_Pitch);
         Protected_Access_Pitch_Roll.Set_Roll_Pilot  (Target_Roll);
      end if;
   end Position_Altitude;

   procedure Collision is
      D  : Distance_Samples_Type;
      L  : Light_Samples_Type;
      PP : PilotPresence_Samples_Type;

      Cur_Speed : Speed_Samples_Type;
      TTC       : Float;

      Warn_TTC   : Float := 10.0;
      Div_TTC    : Float := 5.0;
      Now_Time   : Time  := Clock;
      Mode       : Mode_Type;

      function Time_To_Collision_Seconds
        (Dist : Distance_Samples_Type;
         Spd  : Speed_Samples_Type) return Float
      is
      begin
         if (Spd = 0) then
            return 1.0E9;
         else
            -- Dist en m, Spd en km/h => factor 3.6
            return Float (Dist) * 3.6 / Float (Spd);
         end if;
      end Time_To_Collision_Seconds;

   begin
      Read_Distance (D);
      Read_Light_Intensity (L);
      PP := Read_PilotPresence;

      Protected_Speed_Altitude.Get_Speed_Current (Cur_Speed);

      -- Umbrales según visibilidad / presencia
      if (L < 500) or else (PP = 0) then
         Warn_TTC := 15.0;
         Div_TTC  := 10.0;
      end if;

      -- Siempre evaluar y avisar (manual o automático)
      if (D > 5000) then
         Alarm (0);

         -- Si no hay obstáculo y estábamos desviando, liberamos el lock al terminar
         if Diverting and then Now_Time >= Divert_End then
            -- En automático estabilizamos el alabeo; en manual evitamos actuar sobre actuadores.
            Selected_Mode.Get (Mode);
            Status_Record.Set_Mode (Mode);

            if Mode = Automatic then
               Protected_Access_Pitch_Roll.Set_Roll_Collision (0);
            end if;

            Protected_Access_Pitch_Roll.Open_Var_Lock;  -- FIX: antes estaba Close_Var_Lock
            Diverting := False;
            Status_Record.Set_Warning (No_Warning);
         end if;

         return;
      end if;

      -- Hay obstáculo: calcula TTC y alarmas
      TTC := Time_To_Collision_Seconds (D, Cur_Speed);

      if TTC < Warn_TTC then
         Alarm (4);
      else
         Alarm (0);
      end if;

      -- Actuación (solo en automático)
      Selected_Mode.Get (Mode);
      Status_Record.Set_Mode (Mode);

      if Mode /= Automatic then
         -- Si se cambia a manual durante una evasión, se libera al piloto.
         if Diverting then
            Protected_Access_Pitch_Roll.Open_Var_Lock;
            Diverting := False;
            Status_Record.Set_Warning (No_Warning);
         end if;
         return;
      end if;

      -- En automático: iniciar o mantener desvío
      if (not Diverting) and then (TTC < Div_TTC) then
         Protected_Access_Pitch_Roll.Close_Var_Lock;
         Protected_Access_Pitch_Roll.Set_Roll_Collision (45);
         Divert_End := Now_Time + Milliseconds (3000);
         Diverting := True;
         Status_Record.Set_Warning (Warn_Diverting);
      elsif Diverting then
         if Now_Time >= Divert_End then
            Protected_Access_Pitch_Roll.Set_Roll_Collision (0);
            Protected_Access_Pitch_Roll.Open_Var_Lock;
            Diverting := False;
            Status_Record.Set_Warning (No_Warning);
         else
            Protected_Access_Pitch_Roll.Set_Roll_Collision (45);
            Status_Record.Set_Warning (Warn_Diverting);
         end if;
      end if;
   end Collision;

   procedure Mode_Manager is
      M : Mode_Type;
   begin
      -- Espera esporádica a pulsación del botón (interrupción externa)
      Mode_Interrupt.Wait_Event;

      Selected_Mode.Get (M);
      if M = Automatic then
         M := Manual;
      else
         M := Automatic;
      end if;

      Selected_Mode.Set (M);
      Status_Record.Set_Mode (M);
   end Mode_Manager;

   procedure Display is
      M         : Mode_Type;
      A         : Altitude_Samples_Type;
      P         : Power_Samples_Type;
      Cmd_S     : Speed_Samples_Type;
      Cur_S     : Speed_Samples_Type;
      J         : Joystick_Samples_Type;
      Pitch     : Pitch_Samples_Type;
      Roll      : Roll_Samples_Type;
      W         : Warning_Id;

      function Mode_To_String (X : Mode_Type) return String is
      begin
         if X = Automatic then
            return "MODE: AUTOMATIC";
         else
            return "MODE: MANUAL";
         end if;
      end Mode_To_String;

      function Warning_To_String (X : Warning_Id) return String is
      begin
         case X is
            when No_Warning =>
               return "";
            when Warn_Too_Much_Roll =>
               return "WARNING: Too much roll";
            when Warn_Diverting =>
               return "WARNING: Collision diverting";
         end case;
      end Warning_To_String;

   begin
      Status_Record.Get (M, A, P, Cmd_S, Cur_S, J, Pitch, Roll, W);

      Display_Clear;

      Display_Message (Mode_To_String (M));

      Display_Altitude (A);
      Display_Pilot_Power (P);
      Display_Speed (Cmd_S);
      Display_Joystick (J);
      Display_Pitch (Pitch);
      Display_Roll (Roll);

      declare
         Msg : constant String := Warning_To_String (W);
      begin
         if Msg'Length > 0 then
            Display_Message (Msg);
         end if;
      end;

      -- (Opcional) velocidad actual de la aeronave (útil para depuración)
      Display_Message ("Aircraft Speed (current): " & Integer'Image (Integer (Cur_S)));
   end Display;

begin
   Start_Activity ("Programa Principal");
   -- Las tareas se activan automáticamente al elaborarse el paquete
   Finish_Activity ("Programa Principal");
end fss;
