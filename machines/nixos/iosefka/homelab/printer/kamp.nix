{ lib, ... }:
let
  inherit (import ./lib.nix { inherit lib; }) mkGcode;
in
{
  "gcode_macro _KAMP_Settings" = {
    description = "This macro contains all adjustable settings for KAMP";

    # Set to True to enable KAMP information output when running (useful for debugging)
    variable_verbose_enable = "True";

    # Adaptive mesh
    variable_mesh_margin = "0"; # expands the mesh size in mm, 0 disables
    variable_fuzz_amount = "0"; # randomizes mesh points, 0 disables

    # Dockable probe (Klicky, Euclid, ...)
    variable_probe_dock_enable = "False";
    variable_attach_macro = "'Attach_Probe'";
    variable_detach_macro = "'Dock_Probe'";

    # Adaptive purge
    variable_purge_height = "0.8"; # Z position of nozzle during purge
    variable_tip_distance = "0"; # should be similar to PRINT_END final retract amount
    variable_purge_margin = "10"; # distance the purge will be in front of the print area
    variable_purge_amount = "30"; # filament to purge before printing
    variable_flow_rate = "12"; # purge flow rate in mm3/s

    variable_smart_park_height = "10";

    gcode = mkGcode ''
      {action_respond_info(" Running the KAMP_Settings macro does nothing, it is only used for storing KAMP settings. ")}
    '';
  };

  # Adaptive meshing. Renames the stock command to _BED_MESH_CALIBRATE.
  "gcode_macro BED_MESH_CALIBRATE" = {
    rename_existing = "_BED_MESH_CALIBRATE";
    gcode = mkGcode ''
      {% set all_points = printer.exclude_object.objects | map(attribute='polygon') | sum(start=[]) %}
      {% set bed_mesh_min = printer.configfile.settings.bed_mesh.mesh_min %}
      {% set bed_mesh_max = printer.configfile.settings.bed_mesh.mesh_max %}
      {% set probe_count = printer.configfile.settings.bed_mesh.probe_count %}
      {% set kamp_settings = printer["gcode_macro _KAMP_Settings"] %}
      {% set verbose_enable = kamp_settings.verbose_enable | abs %}
      {% set probe_dock_enable = kamp_settings.probe_dock_enable | abs %}
      {% set attach_macro = kamp_settings.attach_macro | string %}
      {% set detach_macro = kamp_settings.detach_macro | string %}
      {% set mesh_margin = kamp_settings.mesh_margin | float %}
      {% set fuzz_amount = kamp_settings.fuzz_amount | float %}
      {% set probe_count = probe_count if probe_count|length > 1 else probe_count * 2 %}
      {% set max_probe_point_distance_x = ( bed_mesh_max[0] - bed_mesh_min[0] ) / (probe_count[0] - 1) %}
      {% set max_probe_point_distance_y = ( bed_mesh_max[1] - bed_mesh_min[1] ) / (probe_count[1] - 1) %}
      {% set x_min = all_points | map(attribute=0) | min | default(bed_mesh_min[0]) %}
      {% set y_min = all_points | map(attribute=1) | min | default(bed_mesh_min[1]) %}
      {% set x_max = all_points | map(attribute=0) | max | default(bed_mesh_max[0]) %}
      {% set y_max = all_points | map(attribute=1) | max | default(bed_mesh_max[1]) %}

      {% set fuzz_range = range((0) | int, (fuzz_amount * 100) | int + 1) %}
      {% set adapted_x_min = x_min - mesh_margin - (fuzz_range | random / 100.0) %}
      {% set adapted_y_min = y_min - mesh_margin - (fuzz_range | random / 100.0) %}
      {% set adapted_x_max = x_max + mesh_margin + (fuzz_range | random / 100.0) %}
      {% set adapted_y_max = y_max + mesh_margin + (fuzz_range | random / 100.0) %}

      {% set adapted_x_min = [adapted_x_min , bed_mesh_min[0]] | max %}
      {% set adapted_y_min = [adapted_y_min , bed_mesh_min[1]] | max %}
      {% set adapted_x_max = [adapted_x_max , bed_mesh_max[0]] | min %}
      {% set adapted_y_max = [adapted_y_max , bed_mesh_max[1]] | min %}

      {% set points_x = (((adapted_x_max - adapted_x_min) / max_probe_point_distance_x) | round(method='ceil') | int) + 1 %}
      {% set points_y = (((adapted_y_max - adapted_y_min) / max_probe_point_distance_y) | round(method='ceil') | int) + 1 %}

      {% if (([points_x, points_y]|max) > 6) %}
          {% set algorithm = "bicubic" %}
          {% set min_points = 4 %}
      {% else %}
          {% set algorithm = "lagrange" %}
          {% set min_points = 3 %}
      {% endif %}

      {% set points_x = [points_x , min_points]|max %}
      {% set points_y = [points_y , min_points]|max %}
      {% set points_x = [points_x , probe_count[0]]|min %}
      {% set points_y = [points_y , probe_count[1]]|min %}

      {% if verbose_enable == True %}
          {% if printer.exclude_object.objects != [] %}
              { action_respond_info("Algorithm: {}.".format(algorithm)) }
              { action_respond_info("Default probe count: {},{}.".format(probe_count[0], probe_count[1])) }
              { action_respond_info("Adapted probe count: {},{}.".format(points_x, points_y)) }
              { action_respond_info("Default mesh bounds: {}, {}.".format((bed_mesh_min[0], bed_mesh_min[1]), (bed_mesh_max[0], bed_mesh_max[1]))) }
              {% if mesh_margin > 0 %}
                  { action_respond_info("Mesh margin is {}, mesh bounds extended by {}mm.".format(mesh_margin, mesh_margin)) }
              {% else %}
                  { action_respond_info("Mesh margin is 0, margin not increased.") }
              {% endif %}
              {% if fuzz_amount > 0 %}
                  { action_respond_info("Mesh point fuzzing enabled, points fuzzed up to {}mm.".format(fuzz_amount)) }
              {% else %}
                  { action_respond_info("Fuzz amount is 0, mesh points not fuzzed.") }
              {% endif %}
              { action_respond_info("Adapted mesh bounds: {}, {}.".format((adapted_x_min, adapted_y_min), (adapted_x_max, adapted_y_max))) }
              { action_respond_info("KAMP adjustments successful. Happy KAMPing!") }
          {% else %}
              { action_respond_info("No objects detected! Check your gcode and make sure that EXCLUDE_OBJECT_DEFINE is happening before BED_MESH_CALIBRATE is called. Defaulting to regular meshing.") }
              G4 P5000
          {% endif %}
      {% endif %}

      {% if probe_dock_enable == True %}
          {attach_macro}
      {% endif %}

      _BED_MESH_CALIBRATE mesh_min={adapted_x_min},{adapted_y_min} mesh_max={adapted_x_max},{adapted_y_max} ALGORITHM={algorithm} PROBE_COUNT={points_x},{points_y}

      {% if probe_dock_enable == True %}
          {detach_macro}
      {% endif %}
    '';
  };

  # Adaptive line purge
  "gcode_macro LINE_PURGE" = {
    description = "A purge macro that adapts to be near your actual printed objects";
    gcode = mkGcode ''
      # Get relevant printer params
      {% set travel_speed = (printer.toolhead.max_velocity) * 60 | float %}
      {% set cross_section = printer.configfile.settings.extruder.max_extrude_cross_section | float %}

      # Use firmware retraction if it is defined
      {% if printer.firmware_retraction is defined %}
          {% set RETRACT = 'G10' | string %}
          {% set UNRETRACT = 'G11' | string %}
      {% else %}
          {% set RETRACT = 'G1 E-.5 F2100' | string %}
          {% set UNRETRACT = 'G1 E.5 F2100' | string %}
      {% endif %}

      # Get purge settings from _KAMP_Settings
      {% set verbose_enable = printer["gcode_macro _KAMP_Settings"].verbose_enable | abs %}
      {% set purge_height = printer["gcode_macro _KAMP_Settings"].purge_height | float %}
      {% set tip_distance = printer["gcode_macro _KAMP_Settings"].tip_distance | float %}
      {% set purge_margin = printer["gcode_macro _KAMP_Settings"].purge_margin | float %}
      {% set purge_amount = printer["gcode_macro _KAMP_Settings"].purge_amount | float %}
      {% set flow_rate = printer["gcode_macro _KAMP_Settings"].flow_rate | float %}

      # Calculate purge origins and centers from objects
      {% set all_points = printer.exclude_object.objects | map(attribute='polygon') | sum(start=[]) %}
      {% set purge_x_min = (all_points | map(attribute=0) | min | default(0)) %}
      {% set purge_x_max = (all_points | map(attribute=0) | max | default(0)) %}
      {% set purge_y_min = (all_points | map(attribute=1) | min | default(0)) %}
      {% set purge_y_max = (all_points | map(attribute=1) | max | default(0)) %}

      {% set purge_x_center = ([((purge_x_max + purge_x_min) / 2) - (purge_amount / 2), 0] | max) %}
      {% set purge_y_center = ([((purge_y_max + purge_y_min) / 2) - (purge_amount / 2), 0] | max) %}

      {% set purge_x_origin = ([purge_x_min - purge_margin, 0] | max) %}
      {% set purge_y_origin = ([purge_y_min - purge_margin, 0] | max) %}

      # Calculate purge speed
      {% set purge_move_speed = (flow_rate / 5.0) * 60 | float %}

      {% if cross_section < 5 %}

          {action_respond_info("[Extruder] max_extrude_cross_section is insufficient for purge, please set it to 5 or greater. Purge skipped.")}

      {% else %}

          {% if verbose_enable == True %}
              {action_respond_info("Moving filament tip {}mms".format(tip_distance))}
          {% endif %}

          {% if printer.firmware_retraction is defined %}
              {action_respond_info("KAMP purge is using firmware retraction.")}
          {% else %}
              {action_respond_info("KAMP purge is not using firmware retraction, it is recommended to configure it.")}
          {% endif %}

          {% if purge_y_origin > 0 %}
              {action_respond_info("KAMP purge starting at {}, {} and purging {}mm of filament, requested flow rate is {}mm3/s.".format(purge_x_center, purge_y_origin, purge_amount, flow_rate))}
          {% else %}
              {action_respond_info("KAMP purge starting at {}, {} and purging {}mm of filament, requested flow rate is {}mm3/s.".format(purge_x_origin, purge_y_center, purge_amount, flow_rate))}
          {% endif %}

          SAVE_GCODE_STATE NAME=Prepurge_State

          {% if purge_y_origin > 0 %}
              ; room on Y: purge along X axis in front of the print area
              G92 E0
              G0 F{travel_speed}
              G90
              G0 X{purge_x_center} Y{purge_y_origin}
              G0 Z{purge_height}
              M83
              G1 E{tip_distance} F{purge_move_speed}
              G1 X{purge_x_center + purge_amount} E{purge_amount} F{purge_move_speed}
              {RETRACT}
              G0 X{purge_x_center + purge_amount + 10} F{travel_speed}
              G92 E0
              M82
              G0 Z{purge_height * 2} F{travel_speed}
          {% else %}
              ; room on X: purge along Y axis to the left of the print area
              G92 E0
              G0 F{travel_speed}
              G90
              G0 X{purge_x_origin} Y{purge_y_center}
              G0 Z{purge_height}
              M83
              G1 E{tip_distance} F{purge_move_speed}
              G1 Y{purge_y_center + purge_amount} E{purge_amount} F{purge_move_speed}
              {RETRACT}
              G0 Y{purge_y_center + purge_amount + 10} F{travel_speed}
              G92 E0
              M82
              G0 Z{purge_height * 2} F{travel_speed}
          {% endif %}

          RESTORE_GCODE_STATE NAME=Prepurge_State

      {% endif %}
    '';
  };

  "gcode_macro SMART_PARK" = {
    description = "Parks your printhead near the print area for pre-print hotend heating.";
    gcode = mkGcode ''
      {% set kamp_settings = printer["gcode_macro _KAMP_Settings"] %}
      {% set z_height = kamp_settings.smart_park_height | float %}
      {% set purge_margin = kamp_settings.purge_margin | float %}
      {% set verbose_enable = kamp_settings.verbose_enable | abs %}
      {% set center_x = printer.toolhead.axis_maximum.x / 2 | float %}
      {% set center_y = printer.toolhead.axis_maximum.y / 2 | float %}
      {% set axis_minimum_x = printer.toolhead.axis_minimum.x | float %}
      {% set axis_minimum_y = printer.toolhead.axis_minimum.y | float %}
      {% set all_points = printer.exclude_object.objects | map(attribute='polygon') | sum(start=[]) %}
      {% set x_min = all_points | map(attribute=0) | min | default(center_x) %}
      {% set y_min = all_points | map(attribute=1) | min | default(center_y) %}
      {% set travel_speed = (printer.toolhead.max_velocity) * 60 | float %}

      # If objects are detected and purge margin > 0, park at purge location + margin
      {% if purge_margin > 0 and x_min != center_x and y_min != center_y %}
          {% set x_min = [ x_min - purge_margin , x_min ] | min %}
          {% set y_min = [ y_min - purge_margin , y_min ] | min %}
          {% set x_min = [ x_min , axis_minimum_x ] | max %}
          {% set y_min = [ y_min , axis_minimum_y ] | max %}
      {% endif %}

      {% if verbose_enable == True %}
          { action_respond_info("Smart Park location: {},{}.".format(x_min, y_min)) }
      {% endif %}

      SAVE_GCODE_STATE NAME=Presmartpark_State

      G90
      # Raise Z first if currently below park height
      {% if printer.toolhead.position.z < z_height %}
          G0 Z{z_height}
      {% endif %}
      G0 X{x_min} Y{y_min} F{travel_speed}
      G0 Z{z_height}

      RESTORE_GCODE_STATE NAME=Presmartpark_State
    '';
  };
}
