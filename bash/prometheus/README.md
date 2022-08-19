# Script for install Prometheus-Grafana-Alertmanager-Blackbox 

0. Prepare host, where you want to install prometheus

    apt update
    apt install -y curl git net-tools nano

1. clone git project and cd to directory

    git clone https://github.com/djsasha777/provision.git
    cd provision/bash/prometheus

2. Add executable attributes

    chmod +x install-prometheus-all.sh

3. Config prometheus.yml file, change remote monitoring hosts in section "scrape_configs:" eg:

  - job_name: "nasos"
    scrape_interval: 5s
    static_configs:
      - targets: ["3.84.62.193:8444"]

4. Add allerting rules to file prometheus.rules.yaml, eg:

  - name: my_alert1
    rules:          
      - alert: HostOutOfMemory
        expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100 < 10
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: Host out of memory (instance {{ $labels.instance }})
          description: "Node memory is filling up (< 10% left)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

5. Config receivers in alertmanager.yml file

6. install

    ./install-prometheus-all.sh

# remote host

0. At first you need to ssh to remote host

    ssh root@192.168.1.187

1. Prepare host, where you want to install node-exporter

    apt update
    apt install -y curl git net-tools nano

2. clone git project and cd to directory

    git clone https://github.com/djsasha777/provision.git
    cd provision/bash/prometheus

3. Add executable attributes

    chmod +x install-node-exporter.sh

4. install

    ./install-node-exporter.sh


