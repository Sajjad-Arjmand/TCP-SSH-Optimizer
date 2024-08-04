# Enhanced SSH Optimizer 1.0

## Overview

Enhanced SSH Optimizer 1.0 is a Bash script designed to optimize TCP and SSH settings to improve connection speed and reduce latency. This script applies a series of network and SSH-specific optimizations to enhance overall performance, particularly for SSH connections.

## Features

- TCP optimization for better throughput and reduced latency.
- SSH-specific settings to improve connection speed and stability.
- Easy application and removal of settings.
- Connection multiplexing to reduce the overhead of multiple SSH sessions.

## Prerequisites

- Bash shell
- Root or sudo privileges

## Installation

1. Clone the repository or download the script directly:
   ```bash
   git clone https://github.com/yourusername/enhanced-ssh-optimizer.git
   cd enhanced-ssh-optimizer
   ```

2. Make the script executable:
   ```bash
   chmod +x ssh_optimizer.sh
   ```

## Usage

1. **Backup Existing Configurations:**
   Before running the script, it's recommended to backup your existing configurations:
   ```bash
   sudo cp /etc/sysctl.conf /etc/sysctl.conf.backup
   sudo cp /etc/ssh/ssh_config /etc/ssh/ssh_config.backup
   ```

2. **Run the Script:**
   Execute the script with root privileges to apply the optimizations:
   ```bash
   sudo bash ./ssh_optimizer.sh
   ```

3. **Verify Changes:**
   After running the script, verify the applied settings:
   ```bash
   sysctl -p
   cat /etc/sysctl.conf | grep -A 10 "#SSH_OPTIMIZER"
   cat /etc/ssh/ssh_config | grep -A 10 "Compression"
   ```

4. **Test SSH Connection:**
   Open a new SSH session and observe the improvements in speed and latency.

5. **Rollback If Needed:**
   If you encounter any issues, you can revert the changes using the backup files:
   ```bash
   sudo mv /etc/sysctl.conf.backup /etc/sysctl.conf
   sudo mv /etc/ssh/ssh_config.backup /etc/ssh/ssh_config
   sudo sysctl -p
   sudo systemctl restart sshd
   ```

## Script Details

The script performs the following optimizations:

### TCP Optimizations
- Enables TCP window scaling.
- Increases maximum read and write buffer sizes.
- Configures TCP read and write memory allocation.
- Enables low latency mode.
- Disables slow start after idle.
- Sets the default queueing discipline to `fq`.
- Changes the congestion control algorithm to `bbr`.

### SSH-Specific Optimizations
- Enables compression with maximum level.
- Configures keep-alive settings to maintain connection stability.
- Enables connection multiplexing for reduced overhead.
- Disables DNS lookups for faster connection establishment.

## Notes

- This script is experimental and should be used with caution.
- Test the script in a non-production environment first to ensure it works as expected.
- Monitor your system's performance after applying the changes to detect any potential issues.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on GitHub.

## Contact

For questions or support, please open an issue on GitHub.

---

Feel free to modify this README to better suit your repository's structure and your preferences.
