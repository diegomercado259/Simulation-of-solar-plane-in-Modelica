class Propulsion
  import SI = Modelica.Units.SI;
  import Modelica.Constants.pi;
  parameter Integer nMotors = 4;
  parameter Real P_motor_cv = 17.5 "Potencia por motor en cv (imagen)";
  parameter SI.Length D_prop = 4 "Diámetro de hélice (imagen)";
  parameter Real eta = 0.80 "Eficiencia motor + hélice";
  final parameter SI.Power P_max = nMotors * P_motor_cv * 735.5 "Potencia total";
  final parameter SI.Area A_disk = nMotors * pi * D_prop ^ 2 / 4 "Área total de discos";

  input Real P_el(unit = "W");
  input Real V(unit = "m/s");
  input Real rho(unit = "kg/m3");
  output Real Thrust(unit = "N") "Empuje";

  SI.Power P_shaft "Potencia útil en las hélices";
  SI.Force T_dyn "Empuje con el avión en movimiento (P/V)";
  SI.Force T_stat "Límite a baja velocidad (teoría del disco actuador)";
equation
  P_shaft = eta * P_el;
  T_dyn = P_shaft / noEvent(max(V, 0.1));
  T_stat = (2 * rho * A_disk * noEvent(max(P_shaft, 1)) ^ 2) ^ (1 / 3);
  Thrust = noEvent(min(T_dyn, T_stat));
end Propulsion;
