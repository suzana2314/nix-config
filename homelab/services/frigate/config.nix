{ inputs, config, ... }:
let
  inherit (config) homelab;
  networkCfg = inputs.nix-secrets.networking;
in
{
  mqtt = {
    enabled = true;
    host = "mqtt.${homelab.baseDomain}";
    port = 1883;
    topic_prefix = "frigate";
    client_id = "frigate";
  };

  go2rtc = {
    streams = {
      cam1 = [
        "rtsp://{FRIGATE_CAM1_USER}:{FRIGATE_CAM1_PASS}@${networkCfg.services.cam1}:554/stream1"
        "ffmpeg:cam1#audio=aac"
        "tapo://{FRIGATE_CAM1_TAPO_PASS}@${networkCfg.services.cam1}"
      ];
      cam1_sub = [
        "rtsp://{FRIGATE_CAM1_USER}:{FRIGATE_CAM1_PASS}@${networkCfg.services.cam1}:554/stream2"
      ];

      cam2 = [
        "rtsp://{FRIGATE_CAM2_USER}:{FRIGATE_CAM2_PASS}@${networkCfg.services.cam2}:554/h264Preview_01_main"
        "ffmpeg:cam2#video=copy#audio=copy#audio=opus"
      ];
      cam2_sub = [
        "rtsp://{FRIGATE_CAM2_USER}:{FRIGATE_CAM2_PASS}@${networkCfg.services.cam2}:554/h264Preview_01_sub"
      ];
    };

    webrtc = {
      candidates = [
        "${networkCfg.byrgenwerth.ip}:8555"
        "stun:8555"
      ];
    };
  };

  cameras = {
    cam1 = {
      ffmpeg = {
        inputs = [
          {
            path = "rtsp://127.0.0.1:8554/cam1";
            input_args = "preset-rtsp-restream";
            roles = [
              "record"
              "audio"
            ];
          }
          {
            path = "rtsp://127.0.0.1:8554/cam1_sub";
            input_args = "preset-rtsp-restream";
            roles = [
              "detect"
            ];
          }
        ];
        output_args = {
          record = "preset-record-generic-audio-aac";
        };
      };
      live = {
        streams = {
          cam1 = "cam1";
        };
      };

      detect = {
        enabled = true;
        width = 640;
        height = 360;
      };

      onvif = {
        host = "${networkCfg.services.cam1}";
        port = 2020;
        user = "{FRIGATE_CAM1_USER}";
        password = "{FRIGATE_CAM1_PASS}";
      };

      motion = {
        threshold = 30;
        contour_area = 16;
        improve_contrast = true;
      };
    };

    cam2 = {
      ffmpeg = {
        output_args = {
          record = "preset-record-generic-audio-copy";
        };
        input_args = "preset-rtsp-restream";
        inputs = [
          {
            path = "rtsp://127.0.0.1:8554/cam2";
            roles = [
              "detect"
            ];
          }
          {
            path = "rtsp://127.0.0.1:8554/cam2";
            roles = [
              "record"
              "audio"
            ];
          }
        ];
      };
      live = {
        streams = {
          cam2 = "cam2";
        };
      };
      detect = {
        width = 640;
        height = 480;
        fps = 10;
      };
      motion = {
        threshold = 43;
        contour_area = 49;
        improve_contrast = true;
      };
      zones = {
        Small_Gate = {
          coordinates = "0.744,0.067,0.748,0.184,0.602,0.232,0.402,0.115,0.4,0.015";
          loitering_time = 0;
        };
      };
    };
  };

  birdseye = {
    enabled = true;
    mode = "continuous";
  };

  review = {
    alerts = {
      labels = [
        "dog"
        "cat"
        "person"
        "bird"
      ];
    };

    detections = {
      labels = [
        "dog"
        "cat"
        "person"
        "bird"
      ];
    };
  };

  objects = {
    track = [
      "dog"
      "cat"
      "person"
      "bird"
    ];
  };

  record = {
    enabled = true;
    sync_recordings = true;
    retain = {
      days = 3;
      mode = "motion";
    };
    alerts = {
      retain = {
        days = 7;
        mode = "active_objects";
      };
    };
    detections = {
      retain = {
        days = 7;
        mode = "active_objects";
      };
    };
  };

  snapshots = {
    enabled = true;
    timestamp = true;
    retain = {
      default = 7;
    };
  };

  detectors = {
    ov = {
      type = "openvino";
      device = "CPU";
    };
  };

  model = {
    width = 300;
    height = 300;
    input_tensor = "nhwc";
    input_pixel_format = "bgr";
    path = "/openvino-model/ssdlite_mobilenet_v2.xml";
    labelmap_path = "/openvino-model/coco_91cl_bkgr.txt";
  };

  tls = {
    enabled = false;
  };

  detect = {
    enabled = true;
  };
}
