# Fail2Ban Manager Script

## Overview

This script provides a user-friendly interface to manage Fail2Ban on your Linux server. It includes options to install, remove, configure, and check the status of Fail2Ban.

## Features

- **Install Fail2Ban**: Automatically installs Fail2Ban and starts the service.
- **Remove Fail2Ban**: Removes Fail2Ban from your system.
- **Advanced Configuration**: Allows you to enable SSH protection, customize ban time, and retry attempts.
- **Check Status**: Displays the current status of Fail2Ban.
- **Restart Fail2Ban**: Restarts the Fail2Ban service.
- **Stop Fail2Ban**: Stops the Fail2Ban service.
- **Exit**: Exits the management script.

## Quick Install

You can quickly install and run the Fail2Ban Manager script using the following command:

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salarvand-Education/fail2ban/main/fail2ban.sh)"
```

## Usage

1. **Open Terminal**: Access your server's terminal.
2. **Run the Quick Install Command**:
   ```bash
   sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Salarvand-Education/fail2ban/main/fail2ban.sh)"
   ```
3. **Follow the Menu**: The script will display a menu. Use the arrow keys to navigate and press `Enter` to select an option.

### Main Menu Options

- **1. Install Fail2Ban**: Installs Fail2Ban and starts the service.
- **2. Remove Fail2Ban**: Removes Fail2Ban from your system.
- **3. Advanced Fail2Ban Configuration**: Allows you to customize Fail2Ban settings.
  - **1. Enable SSH Protection**: Enables protection for SSH.
  - **2. Customize Ban Time**: Sets the duration for which an IP is banned.
  - **3. Customize Retry Attempts**: Sets the maximum number of retry attempts before banning an IP.
  - **4. Back to Main Menu**: Returns to the main menu.
- **4. Check Fail2Ban Status**: Displays the current status of Fail2Ban.
- **5. Restart Fail2Ban**: Restarts the Fail2Ban service.
- **6. Stop Fail2Ban**: Stops the Fail2Ban service.
- **7. Exit**: Exits the management script.

## Troubleshooting

If you encounter any issues, please review the logs displayed by the script. The logs provide detailed information to help you diagnose and resolve problems.

## Logs

The script automatically checks and displays Fail2Ban logs if there are any issues during installation or restart. You can also manually view the logs using:

```bash
sudo journalctl -u fail2ban --no-pager
```

## Contributing

Contributions are welcome! If you have any improvements or bug fixes, feel free to open a pull request.

## Contact
For any questions or support, please contact us at [support@example.com](mailto:support@example.com).

---
**Maintained by [Amirsam Salarvand]**  
**GitHub Repository**: [https://github.com/Salarvand-Education/fail2ban](https://github.com/Salarvand-Education/fail2ban)
```


این فایل `README.md` ساده‌تر و قابلیت‌های اصلی اسکریپت را به خوبی توصیف می‌کند.
