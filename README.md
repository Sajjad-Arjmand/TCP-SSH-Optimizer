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

You can run the script directly from the command line using `curl`:

```bash
sudo bash -c "$(curl -Ls https://raw.githubusercontent.com/Sajjad-Arjmand/TCP-SSH-Optimizer/master/ssh_optimizer.sh)"
```

## Usage

### Verify Changes

After running the script, verify the applied settings:

```bash
sudo sysctl -p
cat /etc/sysctl.conf | grep -A 10 "#SSH_OPTIMIZER"
cat /etc/ssh/ssh_config | grep -A 10 "Compression"
```

### Test SSH Connection

Open a new SSH session and observe the improvements in speed and latency.

### Rollback If Needed

If you encounter any issues, you can revert the changes using your backup files:

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

Ensure the script is correctly hosted on your GitHub repository at the specified URL, and replace `yourusername` with your actual GitHub username. You can now add this README to your GitHub repository.
