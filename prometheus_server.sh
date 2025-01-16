#!/bin/bash

PROMETHEUS_VERSION="3.1.0"

cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz
tar -xvzf prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz
cd prometheus-$PROMETHEUS_VERSION.linux-amd64

mv prometheus /usr/bin
mkdir -p /etc/prometheus/data
mv prometheus.yml /etc/prometheus


rm -rf /tmp/prometheus-$PROMETHEUS_VERSION.linux-amd64*

useradd -rs /bin/false prometheus || true
chown prometheus:prometheus /usr/bin/prometheus
chown -R prometheus:prometheus /etc/prometheus

cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Server
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
ExecStart=/usr/bin/prometheus \
  --config.file       /etc/prometheus/prometheus.yml \
  --storage.tsdb.path /etc/prometheus/data
[Install]
WantedBy=multi-user.target
EOF




systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus
systemctl status prometheus
