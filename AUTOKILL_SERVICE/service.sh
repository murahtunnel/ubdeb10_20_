#!/bin/bash
clear

# repo
GIT_CMD="https://raw.githubusercontent.com/murahtunnel/ubdeb10_20_/main/"

# download service
wget -q -O /etc/systemd/system/kill-vme.service "${GIT_CMD}Xray_LIMIT/kill-vme.service" && chmod +x kill-vme.service >/dev/null 2>&1
wget -q -O /etc/systemd/system/kill-vle.service "${GIT_CMD}Xray_LIMIT/kill-vle.service" && chmod +x kill-vle.service >/dev/null 2>&1
wget -q -O /etc/systemd/system/kill-tro.service "${GIT_CMD}Xray_LIMIT/kill-tro.service" && chmod +x kill-tro.service >/dev/null 2>&1
wget -q -O /etc/systemd/system/kill-ssh.service "${GIT_CMD}Xray_LIMIT/kill-ssh.service" && chmod +x kill-ssh.service >/dev/null 2>&1
# systemctl
systemctl daemon-reload
systemctl enable kill-vme
systemctl restart kill-vme
systemctl enable kill-vle
systemctl restart kill-vle
systemctl enable kill-tro
systemctl restart kill-tro
systemctl enable kill-ssh
systemctl restart kill-ssh