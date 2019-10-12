# torproxy-container

A simple container built with docker-compose which provides a Tor SOCKS proxy, an HTTP proxy, and DNS port to the host machine.

It runs the latest versions of Alpine Linux, Tor, and Privoxy.

To build and run:

    ./build.sh

To build:

    export TOR_CONTROL_PASSWD="$(openssl rand -hex 16)"
    docker-compose -f files/docker-compose.yml --project-directory files -p torproxy --verbose build --no-cache --compress --build-arg TOR_CONTROL_PASSWD=${TOR_CONTROL_PASSWD}

To run:

    docker-compose -f files/docker-compose.yml --project-directory files -p torproxy --verbose up -d torproxy

Services are available on the standard ports and utilize the host network. SOCKS on 9050, Tor control on 9051, HTTP on 8118 and DNS on 9053.

# Recommendations for running Docker

Get docker-compose via Pip. As for Python modules, remember that docker-py is deprecated and docker is preferred.

For security's sake, I use the following DOCKER_OPTS in /etc/default/docker:

    --no-new-privileges=true --selinux-enabled --seccomp-profile=/etc/docker/default.json --experimental=true

The seccomp profile can be found [here](https://github.com/moby/moby/blob/master/profiles/seccomp/default.json).

I also have:

    --ip-forward=true --iptables=true --userland-proxy=true --log-level=debug --icc=true --containerd=/run/containerd/containerd.sock

Ensure you have [containerd](https://github.com/containerd/containerd) for that last one.

Finally, I use the following DNS options which rely upon my local DNS daemon ([CoreDNS](https://github.com/coredns/coredns)).

    --dns='127.0.0.1' --dns-opt='options single-request' --dns-opt='options use-vc' --dns-opt='options edns0' --dns-opt='options debug' --dns-opt='options ndots:0' --dns-opt='options timeout:5' --dns-opt='options attempts:3'

I recommend setting up `--tlsverify`, which requires `--tlscacert`, `--tlscert`, and `--tlskey`, which necessitates the usage of environment variables `DOCKER_CERT_PATH` and `DOCKER_TLS_VERIFY` with docker-compose, but that's outside the scope of this small project.

Any of the above options may alternatively be expressed as JSON in /etc/docker/default.json.

I've included a [systemd override file](files/override.conf) which should be installed at /etc/systemd/system/docker.service.d/override.conf, and loaded with `systemctl daemon-reload`.

# Example usage

Let's say I'm now running the container on Debian, and I want to force all apt traffic through it. Here's some options for /etc/apt/apt.conf:

    Acquire::tor::proxy "socks5h://127.0.0.1:9050/";
    Acquire::http::proxy "http://127.0.0.1:8118/";
    Acquire::https::proxy "http://127.0.0.1:8118/";

You shouldn't ever need a user/password for SOCKS authentication, but it's in [torsocks.conf](files/torsocks.conf) if you need it.

Likewise, you can now set the environment variables for usage by applications:

    export all_proxy="http://127.0.0.1:8118/"
    export http_proxy="http://127.0.0.1:8118/"
    export https_proxy="http://127.0.0.1:8118/"
    export socks_proxy="http://127.0.0.1:9050/"
    export no_proxy="127.0.0.0/8,localhost,::1"

There are other places you can set the proxy, such as in Firefox's network settings, google-chrome with `--proxy-server`, Network Manager, or in /etc/dconf/db/local.d:

    [system/proxy/http]
    host='127.0.0.1:8118'
    enabled=true

Why not make it part of your profile or environment? If you use Tor Browser Bundle, then the following variables will work:


    export TOR_CONTROL_HOST=127.0.0.1
    export TOR_CONTROL_PORT=9051
    export TOR_SKIP_CONTROLPORTTEST=0
    export TOR_SKIP_LAUNCH=1
    export TOR_SOCKS_HOST=127.0.0.1
    export TOR_SOCKS_PORT=9050

Other use cases:

    export SOCKS5_SERVER="127.0.0.1:9050"
    export SOCKS5_USER="torproxy"
    export SOCKS_VERSION=5

In one's SSH client config `~/.ssh/config`, requires connect-proxy:

    VerifyHostKeyDNS no
    ProxyCommand /usr/bin/connect -5 -S 127.0.0.1:9050 $(tor-resolve %h 127.0.0.1:9050) %p


