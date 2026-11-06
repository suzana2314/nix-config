{
  services.upower = {
    enable = true;
    percentageLow = 20;
    percentageCritical = 10;
    percentageAction = 5;
    criticalPowerAction = "Hibernate";
  };

  services.tuned = {
    enable = true;
    ppdSupport = true;

    ppdSettings = {
      main = {
        default = "balanced";
        battery_detection = true;
      };
      profiles = {
        power-saver = "powersave";
        balanced = "laptop-ac";
        performance = "throughput-performance";
      };
      battery.balanced = "laptop-battery";
    };

    profiles = {
      laptop-battery = {
        main.include = "balanced-battery";
        cpu = {
          type = "cpu";
          governor = "powersave";
          energy_performance_preference = "balance_power";
        };
        pcie = {
          type = "sysfs";
          "/sys/module/pcie_aspm/parameters/policy" = "powersave";
        };
        audio = {
          type = "audio";
          timeout = 10;
        };
        sysctls = {
          type = "sysctl";
          "vm.dirty_writeback_centisecs" = 1500;
          "kernel.nmi_watchdog" = 0;
        };
      };

      laptop-ac = {
        main.include = "balanced";
        cpu = {
          type = "cpu";
          governor = "powersave";
          energy_performance_preference = "balance_performance";
        };
      };
    };
  };
}
