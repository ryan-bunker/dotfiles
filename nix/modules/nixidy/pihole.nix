{
  lib,
  config,
  charts,
  ...
}: let
  cfg = config.my.k3s.pihole;
in {
  options.my.k3s.pihole = {
    domain = lib.mkOption {
      type = lib.types.str;
      description = "DNS domain pihole should handle.";
    };
    ip = lib.mkOption {
      type = lib.types.str;
      description = "IP address of the pihole service.";
    };
    reverseCidr = lib.mkOption {
      type = lib.types.str;
    };
    reverseTarget = lib.mkOption {
      type = lib.types.str;
    };
  };

  config.applications.pihole = {
    namespace = "pihole-system";
    createNamespace = true;

    helm.releases.pihole = {
      chart = charts.mojo2600.pihole;
      values = {
        persistentVolumeClaim.enabled = true;
        ingress = {
          enabled = true;
          hosts = ["pihole.${cfg.domain}"];
        };
        serviceWeb = {
          loadBalancerIP = cfg.ip;
          annotations."metallb.universe.tf/allow-shared-ip" = "pihole-svc";
          type = "LoadBalancer";
        };
        serviceDns = {
          loadBalancerIP = cfg.ip;
          annotations."metallb.universe.tf/allow-shared-ip" = "pihole-svc";
          type = "LoadBalancer";
        };
        serviceDhcp.enabled = false;
        replicaCount = 1;

        DNS1 = "127.0.0.1#5335";
        DNS2 = null;

        admin.existingSecret = "pihole-admin-secret";

        extraEnvVars = {
          REV_SERVER = "true";
          REV_SERVER_CIDR = cfg.reverseCidr;
          REV_SERVER_TARGET = cfg.reverseTarget;
        };

        ftl.MAXDBDAYS = 120;

        extraContainers = [
          {
            name = "unbound";
            image = "mvance/unbound";
            imagePullPolicy = "IfNotPresent";
            volumeMounts = [
              {
                name = "unbound-conf";
                mountPath = "/opt/unbound/etc/unbound/unbound.conf";
                subPath = "unbound.conf";
              }
            ];
          }
        ];

        extraVolumes.unbound-conf.configMap = {
          name = "unbound-custom-conf";
          items = [
            {
              key = "unbound.conf";
              path = "unbound.conf";
            }
          ];
        };
      };
    };

    yamls = [
      (builtins.readFile ../../../secrets/k8s/pihole.yaml)
    ];

    resources.configMaps.unbound-custom-conf.data = {
      "unbound.conf" = ''
        server:
          # Empty string means to log to stderr
          logfile: ""
          use-syslog: no
          verbosity: 1

          interface: 127.0.0.1
          port: 5335
          do-ip4: yes
          do-udp: yes
          do-tcp: yes

          # May be set to yes if you have IPv6 connectivity
          do-ip6: no

          # You want to leave this to no unless you have *native* IPv6. With 6to4 and
          # Terredo tunnels your web browser should favor IPv4 for the same reasons
          prefer-ip6: no

          # Use this only when you downloaded the list of primary root servers!
          # If you use the default dns-root-data package, unbound will find it automatically
          #root-hints: "/var/lib/unbound/root.hints"

          # Trust glue only if it is within the server's authority
          harden-glue: yes

          # Require DNSSEC data for trust-anchored zones, if such data is absent, the zone becomes BOGUS
          harden-dnssec-stripped: yes

          # Don't use Capitalization randomization as it known to cause DNSSEC issues sometimes
          # see https://discourse.pi-hole.net/t/unbound-stubby-or-dnscrypt-proxy/9378 for further details
          use-caps-for-id: no

          # Reduce EDNS reassembly buffer size.
          # IP fragmentation is unreliable on the Internet today, and can cause
          # transmission failures when large DNS messages are sent via UDP. Even
          # when fragmentation does work, it may not be secure; it is theoretically
          # possible to spoof parts of a fragmented DNS message, without easy
          # detection at the receiving end. Recently, there was an excellent study
          # >>> Defragmenting DNS - Determining the optimal maximum UDP response size for DNS <<<
          # by Axel Koolhaas, and Tjeerd Slokker (https://indico.dns-oarc.net/event/36/contributions/776/)
          # in collaboration with NLnet Labs explored DNS using real world data from the
          # the RIPE Atlas probes and the researchers suggested different values for
          # IPv4 and IPv6 and in different scenarios. They advise that servers should
          # be configured to limit DNS messages sent over UDP to a size that will not
          # trigger fragmentation on typical network links. DNS servers can switch
          # from UDP to TCP when a DNS response is too big to fit in this limited
          # buffer size. This value has also been suggested in DNS Flag Day 2020.
          edns-buffer-size: 1232

          # Perform prefetching of close to expired message cache entries
          # This only applies to domains that have been frequently queried
          prefetch: yes

          # One thread should be sufficient, can be increased on beefy machines. In reality for most users running on small networks or on a single machine, it should be unnecessary to seek performance enhancement by increasing num-threads above 1.
          num-threads: 1

          # Ensure kernel buffer is large enough to not lose messages in traffic spikes
          so-rcvbuf: 1m

          # Ensure privacy of local IP ranges
          private-address: 192.168.0.0/16
          private-address: 169.254.0.0/16
          private-address: 172.16.0.0/12
          private-address: 10.0.0.0/8
          private-address: fd00::/8
          private-address: fe80::/10
      '';
    };
  };
}
