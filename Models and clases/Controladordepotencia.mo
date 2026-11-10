class Controladordepotencia "Balance de potencia: paneles + batería = motor + carga fija"
  import SI = Modelica.Units.SI; 
  parameter SI.Power P_hotel = 500 "Carga fija (aviónica, cabina)"; 
  
  input Real P_solar(unit = "W");
  input Real P_motor_req(unit = "W") "Potencia pedida por el control";
  input Real P_chg_max(unit = "W");
  input Real P_dis_max(unit = "W");
  output Real P_motor(unit = "W") "Potencia que realmente recibe el motor";
  output Real P_batt(unit = "W") "Potencia de la batería (+ descarga)";

  Real P_shed(unit = "W") "Potencia recortada al motor por falta de energía";
equation
  // 1) La batería cubre el déficit o absorbe el excedente, dentro de sus límites
  P_batt = noEvent(max(-P_chg_max, min(P_dis_max, P_motor_req + P_hotel - P_solar)));
  // 2) Si aun así falta energía, se recorta el motor
  P_shed = noEvent(max(0, P_motor_req + P_hotel - P_solar - P_batt));
  P_motor = noEvent(max(0, P_motor_req - P_shed));
end Controladordepotencia;
