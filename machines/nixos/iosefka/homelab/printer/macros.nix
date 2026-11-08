{ lib, ... }:
let
  inherit (import ./lib.nix { inherit lib; }) mkGcode;

  mkPark =
    name: move:
    mkGcode ''
      {% if "xyz" not in printer.toolhead.homed_axes %}
          G28 ; home if not already homed
      {% endif %}
      SAVE_GCODE_STATE NAME=${name}
      G90 ; absolute positioning
      ${move}
      RESTORE_GCODE_STATE NAME=${name}
    '';
in
{
  "gcode_macro START_PRINT".gcode = mkGcode ''
    {% set bed = params.BED|default(60)|float %}
    {% set extruder = params.EXTRUDER|default(210)|float %}
    M140 S{bed}
    G28
    M190 S{bed}
    BED_MESH_CALIBRATE
    M104 S{extruder}
    M109 S{extruder}
  '';

  "gcode_macro END_PRINT".gcode = mkGcode ''
    M104 S0
    M140 S0
    G91
    G1 E-2 F2700
    G1 Z10 F900
    G90
    G1 X0 Y200 F6000
    M84
  '';

  "gcode_macro PID_TEST_BED".gcode = mkGcode ''
    # Parameters
    {% set TARGETTEMP = params.TEMP|default(70)|int %}

    {% set max_x = printer.configfile.config["stepper_x"]["position_max"]|float %}
    {% set max_y = printer.configfile.config["stepper_y"]["position_max"]|float %}
    G28
    G90
    G1 X{max_x/2} Y{max_y/2} Z40 F6000
    PID_CALIBRATE HEATER=heater_bed TARGET={TARGETTEMP}
  '';

  "gcode_macro PID_TEST_HOTEND".gcode = mkGcode ''
    # Parameters
    {% set TARGETTEMP = params.TEMP|default(245)|int %}

    {% set max_x = printer.configfile.config["stepper_x"]["position_max"]|float %}
    {% set max_y = printer.configfile.config["stepper_y"]["position_max"]|float %}
    G28
    G90
    G1 X{max_x/2} Y{max_y/2} Z10 F6000
    M106 S64
    PID_CALIBRATE HEATER=extruder TARGET={TARGETTEMP}
    M107 ; Turn off print cooling fan
  '';

  "gcode_macro PID_TEST_ALL".gcode = mkGcode ''
    PID_TEST_BED
    PID_TEST_HOTEND
    SAVE_CONFIG
  '';

  "gcode_macro DO_PROBE_CALIBRATE".gcode = mkGcode ''
    SET_HEATER_TEMPERATURE HEATER=heater_bed TARGET=60
    SET_HEATER_TEMPERATURE HEATER=extruder TARGET=180
    TEMPERATURE_WAIT SENSOR=heater_bed MINIMUM=60
    TEMPERATURE_WAIT SENSOR=extruder MINIMUM=180
    G28
    PROBE_CALIBRATE
  '';

  "gcode_macro DO_CREATE_MESH".gcode = mkGcode ''
    SET_HEATER_TEMPERATURE HEATER=heater_bed TARGET=60
    SET_HEATER_TEMPERATURE HEATER=extruder TARGET=180
    TEMPERATURE_WAIT SENSOR=heater_bed MINIMUM=60
    TEMPERATURE_WAIT SENSOR=extruder MINIMUM=180
    G28
    _BED_MESH_CALIBRATE
  '';

  "gcode_macro MECHANICAL_GANTRY_CALIBRATION".gcode = mkGcode ''
    ### SET THIS DEFAULT CARFULLY - start really low
    {% set my_current = params.CURRENT|default(0.20)|float %} ; adjust crash current on the fly :D
    ###
    {% set oldcurrent = printer.configfile.settings["tmc2209 stepper_z"].run_current %}
    {% set oldhold = printer.configfile.settings["tmc2209 stepper_z"].hold_current %}
    {% set x_max = printer.toolhead.axis_maximum.x %}
    {% set y_max = printer.toolhead.axis_maximum.y %}
    {% set z_max = printer.toolhead.axis_maximum.z %}
    {% set fast_move_z = printer.configfile.settings["printer"].max_z_velocity %}
    {% set fast_move = printer.configfile.settings["printer"].max_velocity %}
    M117 {printer.homed_axes}
    {% if printer.homed_axes != 'xyz' %}
        G28 ; Home All Axes
    {% endif %}
    G90 ; absolute
    G0 X{x_max / 2} Y{y_max / 2} F{fast_move * 30 } ;put toolhead in the center of the gantry

    G0 Z{z_max -5} F{fast_move_z * 60 } ; go to the Z-max - 5 at speed max z speed ; CHANGED

    SET_TMC_CURRENT STEPPER=stepper_z CURRENT={my_current} ; drop current on Z stepper

    {% if printer.configfile.settings["stepper_z1"] %} ; test for dual Z
        SET_TMC_CURRENT STEPPER=stepper_z1 CURRENT={my_current} ; drop current
    {% endif %}

    CONDITIONAL_BEEP I=1
    G4 P200 ; Probably not necessary, it is here just for sure

    SET_KINEMATIC_POSITION Z={z_max - 25} ; Trick printer into beleiving the gantry is 25mm lower than it is ; CHANGED

    G1 Z{z_max} F{6 * 60} ; based on above figures, there will be 20mm worth of grinding ; CHANGED
    CONDITIONAL_BEEP I=2
    G4 P10000 ; wait 10 seconds
    G1 Z{z_max -6} F{6 * 60} ; move 4mm down
    CONDITIONAL_BEEP I=3
    G4 P200 ; same as the first one

    SET_TMC_CURRENT STEPPER=stepper_z CURRENT={oldcurrent} HOLDCURRENT={oldhold}

    {% if printer.configfile.settings["stepper_z1"] %} ; test for dual Z
        SET_TMC_CURRENT STEPPER=stepper_z1 CURRENT={oldcurrent} HOLDCURRENT={oldhold} ; reset current
    {% endif %}

    G1 Z{z_max -30} F{6 * 60} ; move to 30mm below z-max to allow homing movement

    G4 P200 ; same as the first one
    G28 Z ; we MUST home again as the ganty is really in the wrong place.
  '';

  "gcode_macro G34".gcode = mkGcode ''
    MECHANICAL_GANTRY_CALIBRATION
  '';

  "menu __main __setup __calib __mech_gantry_calibrate" = {
    type = "command";
    enable = "{not printer.idle_timeout.state == \"Printing\"}";
    name = "G34 Gantry Level";
    gcode = "G34";
  };

  # Park front center
  "gcode_macro PARKFRONT".gcode =
    mkPark "PARKFRONT" "G0 X{printer.toolhead.axis_maximum.x/2} Y{printer.toolhead.axis_minimum.y+5} Z{printer.toolhead.axis_maximum.z/2} F6000";

  # Park front center, but low down
  "gcode_macro PARKFRONTLOW".gcode =
    mkPark "PARKFRONTLOW" "G0 X{printer.toolhead.axis_maximum.x/2} Y{printer.toolhead.axis_minimum.y+5} Z20 F6000";

  # Park top rear left
  "gcode_macro PARKREAR".gcode =
    mkPark "PARKREAR" "G0 X{printer.toolhead.axis_minimum.x+10} Y{printer.toolhead.axis_maximum.y-10} Z{printer.toolhead.axis_maximum.z-50} F6000";

  # Park at center of build volume
  "gcode_macro PARKCENTER".gcode =
    mkPark "PARKCENTER" "G0 X{printer.toolhead.axis_maximum.x/2} Y{printer.toolhead.axis_maximum.y/2} Z{printer.toolhead.axis_maximum.z/2} F6000";

  # Park 15mm above center of bed
  "gcode_macro PARKBED".gcode =
    mkPark "PARKBED" "G0 X{printer.toolhead.axis_maximum.x/2} Y{printer.toolhead.axis_maximum.y/2} Z15 F6000";
}
