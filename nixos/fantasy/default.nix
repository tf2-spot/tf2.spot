{ config, ... }:
{

  virtualisation.oci-containers.containers = {
    mathesar = {
      image = "docker.io/mathesar/mathesar:0.8.0";

      environment = {
        DJANGO_SETTINGS_MODULE = "config.settings.production";
      };
      environmentFiles = [ ];

      ports = [ "127.0.0.1:28000:8000" ];

      volumes = [
        "msar_secrets:/code/.secrets"
        "msar_media:/code/.media"
      ];
    };
  };
}
