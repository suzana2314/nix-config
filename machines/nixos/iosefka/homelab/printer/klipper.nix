{
  mcu = {
    serial = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
    restart_method = "command";
  };

  printer = {
    kinematics = "cartesian";
    max_velocity = 200;
    max_accel = 3000;
    max_z_velocity = 15;
    max_z_accel = 45;
    square_corner_velocity = 8.0;
  };

  # steppers
  stepper_x = {
    step_pin = "PC2";
    dir_pin = "!PB9";
    enable_pin = "!PC3";
    microsteps = 16;
    rotation_distance = 40;
    endstop_pin = "tmc2209_stepper_x:virtual_endstop";
    position_endstop = 0;
    position_max = 225;
    position_min = -1;
    homing_speed = 40;
    homing_retract_dist = 0;
  };

  "tmc2209 stepper_x" = {
    uart_pin = "PC1";
    run_current = 0.860;
    stealthchop_threshold = 180;
    interpolate = false;
    sense_resistor = 0.150;
    uart_address = 3;
    driver_SGTHRS = 81;
    diag_pin = "PA5";
  };

  stepper_y = {
    step_pin = "PB8";
    dir_pin = "PB7";
    enable_pin = "!PC3";
    microsteps = 16;
    rotation_distance = 40;
    endstop_pin = "tmc2209_stepper_y:virtual_endstop";
    position_endstop = 0;
    position_max = 225;
    homing_speed = 40;
    homing_retract_dist = 0;
  };

  "tmc2209 stepper_y" = {
    uart_pin = "PC0";
    run_current = 0.900;
    stealthchop_threshold = 180;
    interpolate = false;
    sense_resistor = 0.150;
    uart_address = 3;
    driver_SGTHRS = 82;
    diag_pin = "PA6";
  };

  stepper_z = {
    step_pin = "PB6";
    dir_pin = "!PB5";
    enable_pin = "!PC3";
    microsteps = 16;
    rotation_distance = 4;
    endstop_pin = "probe:z_virtual_endstop";
    position_min = -4;
    position_max = 261;
    homing_speed = 5;
  };

  "tmc2209 stepper_z" = {
    uart_pin = "PA15";
    run_current = 1.000;
    stealthchop_threshold = 40;
    interpolate = false;
    sense_resistor = 0.150;
    uart_address = 3;
    diag_pin = "PA7";
  };

  # hotend
  "thermistor sovol_thermistor" = {
    temperature1 = 25;
    resistance1 = 94162;
    beta = 4160;
  };

  extruder = {
    max_extrude_only_distance = 100.0;
    step_pin = "PB4";
    dir_pin = "!PB3";
    enable_pin = "!PC3";
    microsteps = 16;
    rotation_distance = 4.56;
    nozzle_diameter = 0.400;
    filament_diameter = 1.750;
    heater_pin = "PA1";
    sensor_type = "sovol_thermistor";
    sensor_pin = "PC5";
    min_temp = 0;
    max_temp = 300;
    max_extrude_cross_section = 5;
  };

  "tmc2209 extruder" = {
    uart_pin = "PC14";
    run_current = 0.550;
    stealthchop_threshold = 60;
    interpolate = false;
    sense_resistor = 0.150;
    uart_address = 3;
  };

  # bed
  heater_bed = {
    heater_pin = "PA2";
    sensor_type = "EPCOS 100K B57560G104F";
    sensor_pin = "PC4";
    control = "pid";
    pid_kp = 64.440;
    pid_ki = 0.773;
    pid_kd = 1343.571;
    min_temp = 0;
    max_temp = 130;
  };

  fan.pin = "PA0";

  # probe, homing, mesh
  probe = {
    pin = "PB1";
    x_offset = 28;
    y_offset = -20;
    samples = 3;
    samples_result = "median";
    samples_tolerance = 0.01;
    samples_tolerance_retries = 5;
  };

  safe_z_home = {
    home_xy_position = "85,135";
    speed = 100.0;
    z_hop = 10;
    z_hop_speed = 5;
  };

  bed_mesh = {
    speed = 175;
    # probe as close to origin as possible while remaining fully on the bed
    mesh_min = "27, 6";
    # (x.position_max - 1), (y.position_max - abs(y_offset))
    mesh_max = "222, 203";
    probe_count = "5,5";
    algorithm = "bicubic";
    fade_start = 1;
    fade_end = 10;
    fade_target = 0;
  };

  axis_twist_compensation = {
    calibrate_start_x = 27; # abs(x_offset)
    calibrate_end_x = 195; # x.position_max - abs(x_offset) - 1
    calibrate_y = 115;
  };

  # peripherals
  "output_pin beeper" = {
    pin = "PC6";
    value = 0;
    shutdown_value = 0;
    pwm = true;
    cycle_time = 0.0005; # 2 kHz default tone
  };

  display = {
    lcd_type = "st7920";
    cs_pin = "PB12";
    sclk_pin = "PB13";
    sid_pin = "PB15";
    encoder_pins = "^PB14, ^PB10";
    click_pin = "^!PB2";
  };

  "heater_fan e_sink_fan" = {
    pin = "PA13";
    shutdown_speed = 1.0;
    heater_temp = 50.0;
  };

  "controller_fan mcu_fan" = {
    pin = "PA14";
    shutdown_speed = 1.0;
    idle_timeout = 300;
    idle_speed = 0.5;
    heater = "extruder, heater_bed";
  };
}
