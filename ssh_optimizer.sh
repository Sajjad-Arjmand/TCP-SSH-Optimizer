#!/bin/bash

# Display script title
tput setaf 7 ; tput setab 4 ; tput bold ; printf '%40s%s%-20s\n' "Enhanced SSH VPN Optimizer 2.0" ; tput sgr0

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root. Use sudo."
        exit 1
    fi
}

# Function to create backups
create_backups() {
    echo "Creating configuration backups..."
    cp /etc/sysctl.conf /etc/sysctl.conf.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null
    cp /etc/ssh/ssh_config /etc/ssh/ssh_config.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null
    cp /etc/security/limits.conf /etc/security/limits.conf.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null
    echo "Backups created with timestamp."
}

# Function to apply TCP settings optimized for SSH VPN
apply_tcp_settings() {
    echo ""
    echo "Applying TCP optimization settings for SSH VPN..."
    
    # Remove existing SSH_VPN_OPTIMIZER settings if any
    sed -i '/#SSH_VPN_OPTIMIZER/,/^$/d' /etc/sysctl.conf
    
    cat >> /etc/sysctl.conf << 'EOF'
#SSH_VPN_OPTIMIZER - Start
# TCP Window Scaling and Buffer Optimization
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fack = 1

# Increased buffer sizes for high throughput
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.rmem_default = 262144
net.core.wmem_default = 262144
net.ipv4.tcp_rmem = 8192 262144 67108864
net.ipv4.tcp_wmem = 8192 262144 67108864

# Connection handling optimization
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 30000
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15

# Performance and latency optimization
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_no_delay_ack = 1
net.ipv4.tcp_thin_linear_timeouts = 1
net.ipv4.tcp_thin_dupack = 1

# Congestion control - BBR for better performance
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Memory pressure thresholds
net.ipv4.tcp_mem = 786432 1048576 26777216

# Keep alive settings
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 3

# Connection limits for multiple users
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_max_orphans = 262144

# File descriptor limits
fs.file-max = 2097152
fs.nr_open = 2097152
#SSH_VPN_OPTIMIZER - End

EOF

    sysctl -p /etc/sysctl.conf
    echo "TCP optimization settings applied."
}

# Function to apply SSH server optimizations for VPN usage
apply_ssh_server_settings() {
    echo ""
    echo "Applying SSH server optimization settings for VPN usage..."
    
    # Remove existing SSH_VPN_OPTIMIZER settings if any
    sed -i '/#SSH_VPN_OPTIMIZER/,/^$/d' /etc/ssh/sshd_config
    
    cat >> /etc/ssh/sshd_config << 'EOF'
#SSH_VPN_OPTIMIZER - Start
# Connection limits and performance
MaxStartups 100:30:200
MaxSessions 50
MaxAuthTries 6
LoginGraceTime 60

# Compression for better throughput over slow connections
Compression yes

# Keep alive settings for stable VPN connections
TCPKeepAlive yes
ClientAliveInterval 30
ClientAliveCountMax 10

# Performance optimizations
UseDNS no
GSSAPIAuthentication no

# Allow TCP forwarding for VPN functionality
AllowTcpForwarding yes
PermitTunnel yes
GatewayPorts no

# Disable unnecessary features
X11Forwarding no
PrintMotd no
PrintLastLog no

# Authentication optimizations
PubkeyAuthentication yes
PasswordAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes

# Ciphers and algorithms optimized for speed
Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-256,hmac-sha2-512,hmac-sha1
KexAlgorithms diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521
#SSH_VPN_OPTIMIZER - End

EOF

    echo "SSH server optimization settings applied."
}

# Function to apply SSH client optimizations
apply_ssh_client_settings() {
    echo ""
    echo "Applying SSH client optimization settings..."
    
    # Remove existing SSH_VPN_OPTIMIZER settings if any
    sed -i '/#SSH_VPN_OPTIMIZER/,/^$/d' /etc/ssh/ssh_config
    
    cat >> /etc/ssh/ssh_config << 'EOF'
#SSH_VPN_OPTIMIZER - Start
Host *
    # Compression for better performance
    Compression yes
    CompressionLevel 6
    
    # Keep alive settings
    TCPKeepAlive yes
    ServerAliveInterval 30
    ServerAliveCountMax 10
    
    # Connection multiplexing
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 10m
    
    # Performance optimizations
    UseDNS no
    GSSAPIAuthentication no
    HashKnownHosts no
    
    # Fast connection establishment
    ConnectTimeout 10
    
    # Optimized ciphers for speed
    Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com
    MACs hmac-sha2-256,hmac-sha2-512
    KexAlgorithms diffie-hellman-group14-sha256,ecdh-sha2-nistp256,ecdh-sha2-nistp384
#SSH_VPN_OPTIMIZER - End

EOF

    # Create SSH sockets directory for all users
    mkdir -p /etc/skel/.ssh/sockets
    chmod 700 /etc/skel/.ssh/sockets
    
    # Create for existing users
    for user_home in /home/*; do
        if [ -d "$user_home" ]; then
            username=$(basename "$user_home")
            sudo -u "$username" mkdir -p "$user_home/.ssh/sockets" 2>/dev/null
            sudo -u "$username" chmod 700 "$user_home/.ssh/sockets" 2>/dev/null
        fi
    done
    
    echo "SSH client optimization settings applied."
}

# Function to apply system limits for multiple concurrent connections
apply_system_limits() {
    echo ""
    echo "Applying system limits for multiple SSH VPN connections..."
    
    # Remove existing SSH_VPN_OPTIMIZER settings if any
    sed -i '/#SSH_VPN_OPTIMIZER/,/^$/d' /etc/security/limits.conf
    
    cat >> /etc/security/limits.conf << 'EOF'
#SSH_VPN_OPTIMIZER - Start
# Increase limits for SSH VPN users
* soft nofile 65535
* hard nofile 65535
* soft nproc 32768
* hard nproc 32768
root soft nofile 65535
root hard nofile 65535
#SSH_VPN_OPTIMIZER - End

EOF

    echo "System limits applied."
}

# Function to remove all SSH VPN optimizations
remove_ssh_vpn_settings() {
    echo ""
    echo "Removing SSH VPN optimization settings..."
    
    # Remove from sysctl.conf
    sed -i '/#SSH_VPN_OPTIMIZER/,/^$/d' /etc/sysctl.conf
    
    # Remove from SSH configs
    sed -i '/#SSH_VPN_OPTIMIZER/,/^$/d' /etc/ssh/sshd_config
    sed -i '/#SSH_VPN_OPTIMIZER/,/^$/d' /etc/ssh/ssh_config
    
    # Remove from limits.conf
    sed -i '/#SSH_VPN_OPTIMIZER/,/^$/d' /etc/security/limits.conf
    
    # Apply changes
    sysctl -p /etc/sysctl.conf
    systemctl restart sshd
    
    echo "SSH VPN optimization settings removed."
    echo "System restart recommended for complete cleanup."
}

# Function to display current status
show_status() {
    echo ""
    echo "=== Current SSH VPN Optimization Status ==="
    
    if grep -q "#SSH_VPN_OPTIMIZER" /etc/sysctl.conf; then
        echo "✓ TCP optimizations: ACTIVE"
    else
        echo "✗ TCP optimizations: NOT ACTIVE"
    fi
    
    if grep -q "#SSH_VPN_OPTIMIZER" /etc/ssh/sshd_config; then
        echo "✓ SSH server optimizations: ACTIVE"
    else
        echo "✗ SSH server optimizations: NOT ACTIVE"
    fi
    
    if grep -q "#SSH_VPN_OPTIMIZER" /etc/ssh/ssh_config; then
        echo "✓ SSH client optimizations: ACTIVE"
    else
        echo "✗ SSH client optimizations: NOT ACTIVE"
    fi
    
    if grep -q "#SSH_VPN_OPTIMIZER" /etc/security/limits.conf; then
        echo "✓ System limits: CONFIGURED"
    else
        echo "✗ System limits: NOT CONFIGURED"
    fi
    
    echo ""
    echo "Current connections: $(ss -t | grep :22 | wc -l)"
    echo "Available file descriptors: $(ulimit -n)"
    echo "TCP congestion control: $(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | cut -d= -f2 | xargs)"
}

# Main script logic
check_root

# Check for existing settings
if grep -q "#SSH_VPN_OPTIMIZER" /etc/sysctl.conf; then
    show_status
    echo ""
    echo "SSH VPN optimization settings are already applied."
    echo ""
    echo "Options:"
    echo "1) Remove all optimizations"
    echo "2) Show current status"
    echo "3) Re-apply optimizations"
    echo "4) Exit"
    echo ""
    read -p "Choose an option [1-4]: " -e choice
    
    case $choice in
        1)
            remove_ssh_vpn_settings
            ;;
        2)
            show_status
            ;;
        3)
            echo "Re-applying optimizations..."
            create_backups
            apply_tcp_settings
            apply_ssh_server_settings
            apply_ssh_client_settings
            apply_system_limits
            systemctl restart sshd
            echo ""
            echo "✓ SSH VPN optimizations re-applied successfully!"
            echo "✓ SSH daemon restarted"
            echo ""
            echo "Recommended: Test your SSH VPN connections now."
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Exiting..."
            exit 1
            ;;
    esac
else
    echo ""
    echo "Enhanced SSH VPN Optimizer 2.0"
    echo "==============================="
    echo ""
    echo "This script will optimize your VPS for SSH VPN usage with:"
    echo "• TCP performance tuning for multiple concurrent connections"
    echo "• SSH server configuration for VPN stability"
    echo "• Enhanced connection limits and buffers"
    echo "• Optimized ciphers and algorithms for speed"
    echo ""
    echo "Suitable for: NPV Tunnel, Netmod, and other SSH VPN clients"
    echo ""
    read -p "Proceed with SSH VPN optimization? [y/N]: " -e response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        create_backups
        apply_tcp_settings
        apply_ssh_server_settings
        apply_ssh_client_settings
        apply_system_limits
        
        # Restart SSH daemon
        systemctl restart sshd
        
        echo ""
        echo "============================================="
        echo "✓ SSH VPN optimizations applied successfully!"
        echo "✓ SSH daemon restarted"
        echo "============================================="
        echo ""
        echo "Next steps:"
        echo "1. Test your SSH VPN connections"
        echo "2. Monitor server performance"
        echo "3. Adjust user limits if needed"
        echo ""
        echo "For troubleshooting, check the backup files created."
        
        show_status
    else
        echo ""
        echo "Optimization was canceled by the user."
    fi
fi

exit 0
