

with Ada.Real_Time; use Ada.Real_Time;
with System; use System; 

package Button_interrupt is

    ---------------------------------------------------------------------
    ------ declaracion de procedimientos de acceso a DISPOSITIVOS E/S  --
    ---------------------------------------------------------------------

   Interr_1: constant Time_Span := To_Time_Span  (3.0); -- El piloto pulsa el boton de modo a los 3 sg.
   Interr_2: constant Time_Span := To_Time_Span  (3.5); -- Vuelve a pulsar el botón 3,5 sg después
   Interr_3: constant Time_Span := To_Time_Span  (5.0); -- Vuelve a pulsar el botón 5 sg después
   Interr_4: constant Time_Span := To_Time_Span (99.0); -- Ya no pulsa mas el boton dentro del tiempo de la simulacion
   Interr_5: constant Time_Span := To_Time_Span  (1.0);
   Interr_6: constant Time_Span := To_Time_Span  (1.0);
   Interr_7: constant Time_Span := To_Time_Span  (1.0);
   Interr_8: constant Time_Span := To_Time_Span  (1.0);
   Interr_9: constant Time_Span := To_Time_Span  (1.0);
   Interr_10: constant Time_Span := To_Time_Span (1.0);


   --------------------------------------------------------------------------
   -- Tarea que fuerza la interrupcion externa 2 en los instantes indicados --
   --------------------------------------------------------------------------

   Priority_Of_External_Interrupts_2 : constant System.Interrupt_Priority
                                       := System.Interrupt_Priority'First + 9;

   task Interrupt is
      pragma Priority (Priority_Of_External_Interrupts_2);
   end Interrupt;


end Button_interrupt;



