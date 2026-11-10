class Panelsolar
  import SI = Modelica.Units.SI;  
  parameter SI.Area area = 270 "Superficie de celdas (Referencia solarimpulse)";
  parameter Real eta_cell = 0.227 "Eficiencia de celda a 25 °C";
  parameter Real beta(unit = "1/K") = -0.003 "Pérdida de eficiencia por kelvin";
  parameter Real eta_sys = 0.90 "Pérdidas del sistema (MPPT, cableado)";
  parameter Real kT(unit = "K.m2/W") = 0.03 "Calentamiento de la celda por W/m2";

  input Real G(unit = "W/m2");
  input Real T_amb(unit = "K");
  output Real P_el(unit = "W") "Potencia eléctrica";

  SI.Temperature T_cell "Temperatura de celda";
  Real eta "Eficiencia de la celda a T_cell";
equation
  T_cell = T_amb + kT * G;
  eta = noEvent(max(0, eta_cell * (1 + beta * (T_cell - 298.15))));
  P_el = area * G * eta * eta_sys;
end Panelsolar;
