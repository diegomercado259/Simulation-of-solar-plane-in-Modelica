class Aeronave
  import SI = Modelica.Units.SI;
  import Modelica.Constants.g_n;  
  import Modelica.Constants.pi;
  parameter SI.Mass m = 2300 "Masa total (Referencia solar impulse)";
  parameter SI.Length b = 72.3 "Envergadura (Referencia solar impulse)";
  parameter SI.Area S = 270 "Superficie alar (se asume igual a la de celdas)";
  parameter Real CD0 = 0.012 "Resistencia parásita";
  parameter Real e = 0.9 "Factor de Oswald";
  parameter Real CL_max = 1.5 "CL máximo";
  parameter Real CL_ref = 0.8 "CL de vuelo: define la velocidad de rotación y de ascenso";
  parameter Real CL_ground = 0.3 "CL durante la rodadura";
  parameter Real mu = 0.03 "Coeficiente de rodadura";
  parameter Real Kg(unit = "rad/(m/s)") = 0.1 "Ganancia velocidad -> ángulo de trayectoria";
  parameter Real gamma_max(unit = "rad") = 0.2 "Ángulo de trayectoria máximo";
  final parameter SI.Force W = m * g_n "Peso";
  final parameter Real k = 1 / (pi * e * b ^ 2 / S) "Factor de resistencia inducida";

  input Real Thrust(unit = "N");
  input Real rho(unit = "kg/m3");
  output Real V(start = 0, fixed = true, unit = "m/s") "Velocidad";
  output Real h(start = 0, fixed = true, unit = "m") "Altitud";
  output Real x(start = 0, fixed = true, unit = "m") "Distancia";
  output Real P_level(unit = "W") "Potencia aerodinámica en vuelo nivelado";

  Boolean rolling "Verdadero mientras el avión rueda por la pista";
  Real V_ref(unit = "m/s") "Velocidad de rotación y de ascenso";
  Real q(unit = "Pa") "Presión dinámica";
  Real gamma(unit = "rad") "Ángulo de trayectoria";
  Real CL, CL_level;
  SI.Force L "Sustentación";
  SI.Force D "Resistencia";
  SI.Force F_fric "Fuerza de rodadura";
equation
  q = 0.5 * rho * V ^ 2;
  V_ref = sqrt(2 * W / (rho * S * CL_ref));

  //Fase: rodando hasta alcanzar V_ref; después vuela
  rolling = h < 0.5 and V < V_ref;

  //"Piloto": si la velocidad supera V_ref, sube; si es menor, baja
  gamma = if rolling then 0
          else noEvent(max(-gamma_max, min(gamma_max, Kg * (V - V_ref))));

  //Aerodinámica (en vuelo, sustentación = peso·cos(gamma))
  CL = if rolling then CL_ground
       else noEvent(min(CL_max, W * cos(gamma) / (S * max(q, 1))));
  L = q * S * CL;
  D = q * S * (CD0 + k * CL ^ 2);

  //Rodadura (solo en pista y cuando se mueve hacia adelante)
  F_fric = if rolling then mu * max(0, W - L) * noEvent(max(-1, min(1, V / 0.5))) else 0;

  //Potencia aerodinámica en vuelo nivelado (para el control)
  CL_level = noEvent(min(CL_max, W / (S * max(q, 1))));
  P_level = V * q * S * (CD0 + k * CL_level ^ 2);

  //Ecuaciones de movimiento
  m * der(V) = Thrust - D - F_fric - W * sin(gamma);
  der(h) = if h <= 0 and V * sin(gamma) < 0 then 0 else V * sin(gamma);
  der(x) = V * cos(gamma);
end Aeronave;
