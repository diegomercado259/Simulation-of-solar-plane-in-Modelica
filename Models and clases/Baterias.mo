class Baterias
  import SI = Modelica.Units.SI;  
  parameter Real E_nom_kWh(unit = "kW.h") = 164 "Energía nominal (633 kg x 260 Wh/kg)";
  parameter Real e_spec_Wh_kg(unit = "W.h/kg") = 260 "Energía específica (para calcular la masa)";
  parameter Real SOC_start = 1.0 "Estado de carga inicial";
  parameter Real SOC_min = 0.05 "Reserva mínima";
  parameter Real eta = 0.95 "Eficiencia de carga y de descarga";
  parameter SI.Power P_max = 100e3 "Potencia máxima de la batería";
  constant Real taper = 0.02 "Zona de SOC donde la potencia permitida baja a cero";
  final parameter SI.Energy E_nom = E_nom_kWh * 3.6e6;
  final parameter SI.Mass mass = E_nom_kWh * 1000 / e_spec_Wh_kg "Masa de la batería";

  input Real P_batt(unit = "W") "Potencia en bornes (+ descarga, - carga)";
  output Real SOC(start = SOC_start, fixed = true) "Estado de carga";
  output Real P_chg_max(unit = "W") "Carga máxima admisible";
  output Real P_dis_max(unit = "W") "Descarga máxima admisible";
  
  Real E_kWh(unit = "kW.h") "Energía almacenada E(t)"; 
protected
  Real P_int(unit = "W") "Potencia interna (incluye pérdidas)";
equation
  P_dis_max = P_max * noEvent(min(1, max(0, (SOC - SOC_min) / taper)));
  P_chg_max = P_max * noEvent(min(1, max(0, (1 - SOC) / taper)));
  P_int = noEvent(if P_batt > 0 then P_batt / eta else P_batt * eta);
  der(SOC) = -P_int / E_nom;
  E_kWh = SOC * E_nom_kWh;
end Baterias;
