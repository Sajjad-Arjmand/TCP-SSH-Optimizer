#!/bin/bash

# Display script title
tput setaf 7 ; tput setab 4 ; tput bold ; printf '%35s%s%-20s\n' "Enhanced SSH Optimizer 1.0" ; tput sgr0

# Function to apply TCP settings
apply_tcp_settings() {
    echo ""
    echo "Applying TCP optimization settings..."
    echo "#SSH_OPTIMIZER" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_window_scaling = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 16384 16777216
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf
    echo "TCP optimization settings applied."
}

# Function to remove TCP settings
remove_tcp_settings() {
    echo ""
    echo "Removing TCP optimization settings..."
    grep -v "^#SSH_OPTIMIZER" /etc/sysctl.conf > /tmp/syscl && mv /tmp/syscl /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf
    echo "TCP optimization settings removed."
}

# Check for existing settings
if grep -q "^#SSH_OPTIMIZER" /etc/sysctl.conf; then
    echo ""
    echo "SSH optimization settings are already applied."
    read -p "Do you want to remove the settings? [y/n]: " -e -i n resposta
    if [[ "$resposta" = 'y' ]]; then
        remove_tcp_settings
    fi
else
    echo ""
    echo "This script will optimize TCP and SSH settings for better performance."
    read -p "Proceed with optimization? [y/n]: " -e -i n resposta
    if [[ "$resposta" = 'y' ]]; then
        apply_tcp_settings

        # SSH-specific optimizations
        echo ""
        echo "Applying SSH optimization settings..."
        echo "Compression yes
CompressionLevel 9
TCPKeepAlive yes
ClientAliveInterval 60
ClientAliveCountMax 100
ServerAliveInterval 60
ServerAliveCountMax 100
ControlMaster auto
ControlPath ~/.ssh/sockets/%r@%h-%p
ControlPersist yes
UseDNS no" >> /etc/ssh/ssh_config

        mkdir -p ~/.ssh/sockets
        chmod 700 ~/.ssh/sockets

        systemctl restart sshd
        echo "SSH optimization settings applied."
    else
        echo ""
        echo "Optimization was canceled by the user."
    fi
fi

exit
