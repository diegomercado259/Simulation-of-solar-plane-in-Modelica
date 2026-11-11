class Controldealtitud
  import SI = Modelica.Units.SI; 
  
  parameter SI.Height h_day = 8500 "Altitud de crucero diurna";
  parameter SI.Height h_night = 1500 "Altitud de crucero nocturna (si es igual a h_day no hay descenso)";
  parameter Real sinAlpha_switch = 0 "Seno de la elevación solar a partir del cual se usa h_day";
  parameter Real Kp(unit = "W/m") = 20 "Potencia extra por metro de error de altitud";
  
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
  P_cmd = noEvent(max(0, min(P_max, if mode == 1 then P_level / eta + Kp * (h_ref - h) else P_prof)));
end Controldealtitud;
