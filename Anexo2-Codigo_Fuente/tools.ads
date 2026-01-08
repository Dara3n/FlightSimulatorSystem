

with Ada.Real_Time; use Ada.Real_Time;
use type Ada.Real_Time.Time_Span;

package tools is

    Big_Bang : constant Ada.Real_Time.Time := Clock;

    procedure Current_Time (Origen : Ada.Real_Time.Time);
    procedure Print_Chrono;  
    procedure Print_an_Integer (x: in integer);
    procedure Print_a_Float (x : in float);
    procedure Print_a_String (s: in string);
    procedure Start_Activity (T: in String);
    procedure Finish_Activity (T: in String); 
    procedure Execution_Time (Time : Ada.Real_Time.Time_Span);

end tools;



