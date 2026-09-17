[
  {
    name = "disk-space";
    rules = [
      {
        alert = "DiskSpaceLow";
        expr = ''
          (
            node_filesystem_avail_bytes{fstype!~"tmpfs|overlay|squashfs"}
            /
            node_filesystem_size_bytes{fstype!~"tmpfs|overlay|squashfs"}
          ) < 0.05
        '';
        for = "10m";
        labels.severity = "warning";
        annotations = {
          summary = "Low disk space on {{ $labels.instance }}";
          description = "{{ $labels.mountpoint }} on {{ $labels.instance }} has only {{ $value | humanizePercentage }} space free.";
        };
      }
      {
        alert = "DiskSpaceCritical";
        expr = ''
          (
            node_filesystem_avail_bytes{fstype!~"tmpfs|overlay|squashfs"}
            /
            node_filesystem_size_bytes{fstype!~"tmpfs|overlay|squashfs"}
          ) < 0.02
        '';
        for = "5m";
        labels.severity = "critical";
        annotations = {
          summary = "Critical disk space on {{ $labels.instance }}";
          description = "{{ $labels.mountpoint }} on {{ $labels.instance }} has only {{ $value | humanizePercentage }} space free.";
        };
      }
    ];
  }
  {
    name = "cpu";
    rules = [
      {
        alert = "HighCpuUsage";
        expr = ''
          100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 85
        '';
        for = "30m";
        labels.severity = "warning";
        annotations = {
          summary = "High CPU usage on {{ $labels.instance }}";
          description = "CPU usage on {{ $labels.instance }} has been above 85% for over 30 minutes (currently {{ $value | printf \"%.1f\" }}%).";
        };
      }
      {
        alert = "CriticalCpuUsage";
        expr = ''
          100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 95
        '';
        for = "30m";
        labels.severity = "critical";
        annotations = {
          summary = "Critical CPU usage on {{ $labels.instance }}";
          description = "CPU usage on {{ $labels.instance }} has been above 95% for over 30 minutes (currently {{ $value | printf \"%.1f\" }}%).";
        };
      }
    ];
  }
  {
    name = "memory";
    rules = [
      {
        alert = "HighMemoryUsage";
        expr = ''
          (
            1 - (
              node_memory_MemAvailable_bytes
              /
              node_memory_MemTotal_bytes
            )
          ) > 0.85
        '';
        for = "30m";
        labels.severity = "warning";
        annotations = {
          summary = "High memory usage on {{ $labels.instance }}";
          description = "Memory usage on {{ $labels.instance }} has been above 85% for over 30 minutes (currently {{ $value | humanizePercentage }}).";
        };
      }
      {
        alert = "CriticalMemoryUsage";
        expr = ''
          (
            1 - (
              node_memory_MemAvailable_bytes
              /
              node_memory_MemTotal_bytes
            )
          ) > 0.95
        '';
        for = "30m";
        labels.severity = "critical";
        annotations = {
          summary = "Critical memory usage on {{ $labels.instance }}";
          description = "Memory usage on {{ $labels.instance }} has been above 95% for over 30 minutes (currently {{ $value | humanizePercentage }}).";
        };
      }
    ];
  }
]
