model Avion_solar "Despegue, ascenso y crucero y ciclo día/noche de un avión solar"
  import Modelica.Constants.g_n;
  import SI = Modelica.Units.SI;  
  parameter Real SOC0 = 1.0 "Estado de carga de la batería al despegar (0 a 1)";
  parameter SI.Height h_cruise = 8500 "Altitud de crucero";
  parameter SI.Height h_cruise_night = 1500 "Altitud de crucero nocturna";
  // Acoplamiento de la masa con el tamaño de paneles y batería
  parameter SI.Mass m_ref = 5680 "Masa de referencia con 270 m2 de paneles y 164 kWh";
  parameter SI.Area A_ref = 270 "Área de paneles de referencia";
  parameter Real E_ref_kWh = 164 "Capacidad de batería de referencia";
  parameter Real arealMass(unit = "kg/m2") = 0.8 "Masa añadida por m2 de panel (celdas, encapsulado, estructura)";
  
  Ambiente env;
  Panelsolar panel;
  Baterias battery(SOC_start = SOC0);
  Controladordepotencia pm;
  Propulsion prop;
  Aeronave aircraft(m = m_ref + (battery.E_nom_kWh - E_ref_kWh) * 1000 / battery.e_spec_Wh_kg
                        + (panel.area - A_ref) * arealMass);
  Controldealtitud ctrl(h_day = h_cruise, h_night = h_cruise_night, P_max = prop.P_max, eta = prop.eta);

  Real E_motor_kWh(start = 0, fixed = true) "Energía eléctrica consumida por el motor";
  Real C_rate(unit = "1/h") "Tasa de descarga de la batería (positiva = descarga)";
equation
  assert(panel.area <= aircraft.S, "El área de paneles no puede superar la superficie alar");
  // Ambiente
  aircraft.h = env.h;
  env.G = panel.G;
  env.T_amb = panel.T_amb;
  env.rho = aircraft.rho;
  env.rho = prop.rho;
  
  // Control
  aircraft.h = ctrl.h;
  aircraft.P_level = ctrl.P_level;
  env.sinAlpha = ctrl.sinAlpha;
  
  // Balance de potencia
  panel.P_el = pm.P_solar;
  ctrl.P_cmd = pm.P_motor_req;
  battery.P_chg_max = pm.P_chg_max;
  battery.P_dis_max = pm.P_dis_max;
  pm.P_batt = battery.P_batt;
  
  // Propulsión y dinámica
  pm.P_motor = prop.P_el;
  aircraft.V = prop.V;
  prop.Thrust = aircraft.Thrust;  
  
  der(E_motor_kWh) = pm.P_motor / 3.6e6;
  C_rate = pm.P_batt / (battery.E_nom_kWh * 1000);

  // Despegue y ascenso: 4 h con paso de 1 s. Para el ciclo día/noche usar StopTime = 93600 (26 h) e Interval = 10.
  annotation(experiment(StartTime = 0, StopTime = 250, Interval = 1, Tolerance = 1e-6));
end Avion_solar;
