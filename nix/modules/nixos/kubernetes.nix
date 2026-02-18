{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my.services.kubernetes;
in {
  options.my.services.kubernetes = {
    enable = lib.mkEnableOption "Enables kubernetes (k3s)";

    role = lib.mkOption {
      type = lib.types.enum ["server" "agent"];
      default = "server";
      description = "Whether this node is a control-plane server or a worker agent.";
    };

    clusterInit = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "If true, this node initializes a new cluster. Set to true on only ONE node.";
    };

    serverAddr = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "https://10.0.0.1:6443";
      description = "The API server address to join. Required for agents and secondary servers.";
    };

    tokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the k3s token file (sops-nix secret recommended).";
    };

    nodeLabels = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Extra node labels (e.g. { 'worker' = 'true'; }).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.k3s = {
      enable = true;
      role = cfg.role;
      tokenFile = cfg.tokenFile;

      # Cleanly handle join URL logic
      serverAddr =
        if cfg.clusterInit
        then ""
        else cfg.serverAddr;
      clusterInit = cfg.clusterInit;

      extraFlags = let
        # Base flags (disable Traefik/Servicelb to use your own ingress later)
        baseFlags = [
          "--write-kubeconfig-mode 0644"
          "--disable servicelb"
          "--disable traefik"
          "--disable local-storage"
        ];
        # Convert { foo = "bar"; } -> [ "--node-label foo=bar" ]
        labelFlags = lib.mapAttrsToList (k: v: "--node-label ${k}=${v}") cfg.nodeLabels;
      in
        lib.concatStringsSep " " (baseFlags ++ labelFlags);
    };

    # Firewall logic: Only open what is needed for the specific role
    networking.firewall = {
      allowedTCPPorts =
        [
          # Required for ALL nodes (metrics, etc)
          10250
        ]
        ++ (lib.optionals (cfg.role == "server") [
          # Server (Control Plane) Only
          6443 # API Server
          2379
          2380 # Etcd clients/peers
        ]);

      allowedUDPPorts = [
        # Flannel (VXLAN) - Required for pod-to-pod communication
        8472
      ];
    };

    # Longhorn / ISCSI Requirements
    services.openiscsi = {
      enable = true;
      name = "iqn.2016-04.com.open-iscsi:${config.networking.hostName}";
    };

    # Longhorn hack: link /usr/local/bin for strict binary checks
    systemd.tmpfiles.rules = [
      "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
    ];

    sops.secrets.k3s_token = {};
  };
}
