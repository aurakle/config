{ ... }:

{
  virtualisation = {
    # virtualbox = {
    #   host = {
    #     enable = true;
    #     enableKvm = true;
    #     addNetworkInterface = false;
    #   };
    # };

    podman = {
      enable = true;

      autoPrune = {
        enable = true;
        flags = [ "--all" ];
      };
    };

    docker = {
      enable = true;

      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    oci-containers = {
      backend = "podman";
      containers.ao3-rss = let
        port = toString 9000;
      in {
        image = "ghcr.io/kthchew/ao3-rss:latest";
        ports = [ "127.0.0.1:${port}:${port}" ];

        environment = {
          PORT = port;
        };
      };
    };
  };
}
