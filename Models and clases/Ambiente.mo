class Ambiente "Atmósfera ISA (troposfera) e irradiancia solar de cielo despejado"
  import SI = Modelica.Units.SI; 
  import Modelica.Constants.pi; 
  parameter Real latitude_deg(unit = "deg") = 24 "Latitud";
  parameter Real dayOfYear = 70 "Día del año (70 = 11 de marzo)";
  parameter Real solarTimeStart_h(unit = "h") = 7 "Hora solar al inicio de la simulación";
  parameter Real tau0 = 0.75 "Transmitancia de cielo despejado (nivel del mar, sol en el cenit)";
  constant Real Gsc(unit = "W/m2") = 1361 "Constante solar";

  input Real h(unit = "m") "Altitud";
  output Real T_amb(unit = "K") "Temperatura ambiente";
  output Real rho(unit = "kg/m3") "Densidad del aire";
  output Real G(unit = "W/m2") "Irradiancia sobre superficie horizontal";

  SI.Height hc "Altitud limitada a [0, 11 km]";
  Real p_ratio "Presión / presión a nivel del mar";
  Real delta(unit = "rad") "Declinación solar";
  Real omega(unit = "rad") "Ángulo horario";
  Real sinAlpha "Seno de la elevación solar";
  Real sunElev_deg(unit = "deg") "Elevación solar (para graficar)";
  Real AM "Masa de aire";
  Real Variable_descartar;

equation
  // ---- Atmósfera: temperatura baja 6.5 K por km hasta 11 km
  hc = noEvent(min(max(h, 0), 11000));
  T_amb = 288.15 - 0.0065 * hc;
  p_ratio = (T_amb / 288.15) ^ 5.2559;
  rho = 101325 * p_ratio / (287.053 * T_amb);

  // ---- Posición del sol
  delta = 23.45 * pi / 180 * sin(2 * pi * (284 + dayOfYear) / 365);
  omega = 2 * pi * (solarTimeStart_h + time / 3600 - 12) / 24;
  sinAlpha = sin(latitude_deg * pi / 180) * sin(delta)
           + cos(latitude_deg * pi / 180) * cos(delta) * cos(omega);
  sunElev_deg = asin(noEvent(max(-1, min(1, sinAlpha)))) * 180 / pi;

  // ---- Irradiancia: se atenúa más con más masa de aire (sol bajo o poca altitud)
  AM = p_ratio / noEvent(max(sinAlpha, 0.05));
  Variable_descartar = tau0 ^ AM;

  G = Gsc * noEvent(max(sinAlpha, 0)) * tau0 ^ AM;
end Ambiente;
