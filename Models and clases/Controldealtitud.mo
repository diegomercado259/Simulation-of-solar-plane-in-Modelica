class Controldealtitud
  import SI = Modelica.Units.SI; 
  parameter Integer mode = 1 "1 = control de altitud día/noche; 2 = potencia impuesta por tramos";
  // ---- Modo 1: control de altitud
  parameter SI.Height h_day = 8500 "Altitud de crucero diurna";
  parameter SI.Height h_night = 1500 "Altitud de crucero nocturna (si es igual a h_day no hay descenso)";
  parameter Real sinAlpha_switch = 0 "Seno de la elevación solar a partir del cual se usa h_day";
  parameter Real Kp(unit = "W/m") = 20 "Potencia extra por metro de error de altitud";
  // ---- Modo 2: potencia por tramos  (P1 hasta t1, P2 hasta t2, P3 después)
  parameter SI.Power P1 = 51485 "Potencia del tramo 1 (ascenso)";
  parameter SI.Power P2 = 17000 "Potencia del tramo 2 (crucero)";
  parameter SI.Power P3 = 12000 "Potencia del tramo 3 (noche)";
  parameter SI.Time t1 = 7200 "Fin del tramo 1";
  parameter SI.Time t2 = 39000 "Fin del tramo 2";
  // ---- Comunes
  parameter SI.Power P_max = 51485 "Potencia máxima del motor";
  parameter Real eta = 0.80 "Eficiencia motor + hélice";
  
  input Real h(unit = "m");
  input Real P_level(unit = "W");
  input Real sinAlpha "Seno de la elevación solar";
  output Real P_cmd(unit = "W") "Potencia eléctrica pedida";
  
  SI.Height h_ref "Altitud objetivo";
  SI.Power P_prof "Potencia del perfil por tramos";
  
equation
  h_ref = if sinAlpha > sinAlpha_switch then h_day else h_night;
  P_prof = if time < t1 then P1 elseif time < t2 then P2 else P3;
  P_cmd = noEvent(max(0, min(P_max, if mode == 1 then P_level / eta + Kp * (h_ref - h) else P_prof)));
end Controldealtitud;
