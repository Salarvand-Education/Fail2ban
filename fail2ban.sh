#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to display the menu
show_menu() {
    clear
    echo -e "${BLUE}-----------------------------${NC}"
    echo -e "${CYAN}     Manage Fail2Ban         ${NC}"
    echo -e "${BLUE}-----------------------------${NC}"
    echo -e "${YELLOW}1. Install Fail2Ban${NC}"
    echo -e "${YELLOW}2. Remove Fail2Ban${NC}"
    echo -e "${YELLOW}3. Advanced Fail2Ban Configuration${NC}"
    echo -e "${YELLOW}4. Check Fail2Ban Status${NC}"
    echo -e "${YELLOW}5. Restart Fail2Ban${NC}"
    echo -e "${YELLOW}6. Stop Fail2Ban${NC}"
    echo -e "${YELLOW}7. Exit${NC}"
    echo -e "${BLUE}-----------------------------${NC}"
}

# Function to install Fail2Ban
install_fail2ban() {
    clear
    echo -e "${CYAN}Updating package list...${NC}"
    sudo apt update
    echo -e "${CYAN}Installing Fail2Ban...${NC}"
    sudo apt install -y fail2ban
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Fail2Ban has been successfully installed!${NC}"
        
        # Create jail.local if it doesn't exist
        if [ ! -f /etc/fail2ban/jail.local ]; then
            echo -e "${CYAN}Creating jail.local from jail.conf...${NC}"
            sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
        fi
        
        # Disable unnecessary jails like selinux-ssh
        echo -e "${CYAN}Disabling unnecessary jails (e.g., selinux-ssh)...${NC}"
        sudo sed -i '/^\[selinux-ssh\]/,/^\[/ s/enabled = true/enabled = false/' /etc/fail2ban/jail.local
        
        # Validate configuration before starting
        echo -e "${CYAN}Validating Fail2Ban configuration...${NC}"
        if sudo fail2ban-client -d > /dev/null 2>&1; then
            echo -e "${GREEN}Configuration is valid!${NC}"
            
            # Enable and start Fail2Ban service
            echo -e "${CYAN}Enabling and starting Fail2Ban service...${NC}"
            sudo systemctl enable fail2ban
            sudo systemctl start fail2ban
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Fail2Ban service has been started and enabled!${NC}"
            else
                echo -e "${RED}Failed to start Fail2Ban service! Checking logs for more details...${NC}"
                echo -e "${CYAN}Displaying Fail2Ban logs:${NC}"
                sudo journalctl -u fail2ban --no-pager | tail -n 20
                echo -e "${YELLOW}Please review the logs above to troubleshoot the issue.${NC}"
            fi
        else
            echo -e "${RED}Error: Invalid configuration detected. Please fix the errors before starting.${NC}"
            echo -e "${CYAN}Displaying Fail2Ban logs:${NC}"
            sudo journalctl -u fail2ban --no-pager | tail -n 20
            echo -e "${YELLOW}Please review the logs above to troubleshoot the issue.${NC}"
        fi
    else
        echo -e "${RED}Failed to install Fail2Ban! Please check your internet connection or package manager.${NC}"
    fi
    
    read -p "Press any key to continue..." -n 1
    clear
}

# Function to remove Fail2Ban
remove_fail2ban() {
    clear
    echo -e "${CYAN}Removing Fail2Ban...${NC}"
    sudo systemctl stop fail2ban
    sudo apt remove --purge -y fail2ban
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Fail2Ban has been successfully removed!${NC}"
    else
        echo -e "${RED}Failed to remove Fail2Ban!${NC}"
    fi
    
    read -p "Press any key to continue..." -n 1
    clear
}

# Function for advanced configuration
advanced_config() {
    clear
    echo -e "${CYAN}Advanced Fail2Ban Configuration:${NC}"
    echo -e "${YELLOW}1. Enable SSH Protection${NC}"
    echo -e "${YELLOW}2. Customize Ban Time${NC}"
    echo -e "${YELLOW}3. Customize Retry Attempts${NC}"
    echo -e "${YELLOW}4. Back to Main Menu${NC}"
    read -p "Enter your choice: " config_choice

    case $config_choice in
        1)
            echo -e "${CYAN}Enabling SSH protection...${NC}"
            if [ ! -f /etc/fail2ban/jail.local ]; then
                echo -e "${CYAN}Creating jail.local from jail.conf...${NC}"
                sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
            fi
            sudo sed -i '/^\[sshd\]/,/^\[/ s/enabled = false/enabled = true/' /etc/fail2ban/jail.local
            echo -e "${GREEN}SSH protection has been enabled!${NC}"
            ;;
        2)
            read -p "Enter ban time (in seconds): " ban_time
            if [[ $ban_time =~ ^[0-9]+$ ]]; then
                sudo sed -i "s/^bantime = .*/bantime = $ban_time/" /etc/fail2ban/jail.local
                echo -e "${GREEN}Ban time has been set to $ban_time seconds!${NC}"
            else
                echo -e "${RED}Invalid input! Please enter a valid number of seconds.${NC}"
            fi
            ;;
        3)
            read -p "Enter max retry attempts: " max_retry
            if [[ $max_retry =~ ^[0-9]+$ ]]; then
                sudo sed -i "s/^maxretry = .*/maxretry = $max_retry/" /etc/fail2ban/jail.local
                echo -e "${GREEN}Max retry attempts have been set to $max_retry!${NC}"
            else
                echo -e "${RED}Invalid input! Please enter a valid number of retries.${NC}"
            fi
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}Invalid option! Please try again.${NC}"
            ;;
    esac
    
    read -p "Press any key to continue..." -n 1
    clear
}

# Function to check Fail2Ban status
check_status() {
    clear
    echo -e "${CYAN}Checking Fail2Ban status...${NC}"
    
    # Check if Fail2Ban service is running
    if systemctl is-active --quiet fail2ban; then
        echo -e "${GREEN}Fail2Ban is running!${NC}"
        sudo fail2ban-client status
    else
        echo -e "${RED}Fail2Ban is not running! Attempting to diagnose the issue...${NC}"
        
        # Check if Fail2Ban is enabled
        if ! systemctl is-enabled --quiet fail2ban; then
            echo -e "${YELLOW}Fail2Ban is not enabled to start on boot. Enabling it now...${NC}"
            sudo systemctl enable fail2ban
        fi
        
        # Check for configuration errors
        if [ -f /etc/fail2ban/jail.local ]; then
            echo -e "${CYAN}Checking for configuration errors in jail.local...${NC}"
            if ! sudo fail2ban-client -d > /dev/null 2>&1; then
                echo -e "${RED}Error: Syntax error detected in /etc/fail2ban/jail.local.${NC}"
                echo -e "${YELLOW}Please review the file for issues and correct them.${NC}"
            fi
        fi
        
        # Display logs for further troubleshooting
        echo -e "${CYAN}Displaying Fail2Ban logs:${NC}"
        sudo journalctl -u fail2ban --no-pager | tail -n 20
        echo -e "${YELLOW}Please review the logs above to troubleshoot the issue.${NC}"
    fi
    
    read -p "Press any key to continue..." -n 1
    clear
}

# Function to restart Fail2Ban
restart_fail2ban() {
    clear
    echo -e "${CYAN}Restarting Fail2Ban...${NC}"
    
    # Clean up Fail2Ban state files to prevent issues
    echo -e "${CYAN}Cleaning up Fail2Ban state files...${NC}"
    sudo rm -rf /var/lib/fail2ban/*
    
    # Validate configuration before restarting
    echo -e "${CYAN}Validating Fail2Ban configuration...${NC}"
    if sudo fail2ban-client -d > /dev/null 2>&1; then
        echo -e "${GREEN}Configuration is valid!${NC}"
        
        # Restart Fail2Ban service
        sudo systemctl restart fail2ban
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Fail2Ban has been restarted!${NC}"
        else
            echo -e "${RED}Failed to restart Fail2Ban service! Checking logs for more details...${NC}"
            echo -e "${CYAN}Displaying Fail2Ban logs:${NC}"
            sudo journalctl -u fail2ban --no-pager | tail -n 20
            echo -e "${YELLOW}Please review the logs above to troubleshoot the issue.${NC}"
        fi
    else
        echo -e "${RED}Error: Invalid configuration detected. Please fix the errors before restarting.${NC}"
        echo -e "${CYAN}Displaying Fail2Ban logs:${NC}"
        sudo journalctl -u fail2ban --no-pager | tail -n 20
        echo -e "${YELLOW}Please review the logs above to troubleshoot the issue.${NC}"
    fi
    
    read -p "Press any key to continue..." -n 1
    clear
}

# Function to stop Fail2Ban
stop_fail2ban() {
    clear
    echo -e "${CYAN}Stopping Fail2Ban...${NC}"
    if systemctl is-active --quiet fail2ban; then
        sudo systemctl stop fail2ban
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Fail2Ban has been stopped!${NC}"
        else
            echo -e "${RED}Failed to stop Fail2Ban!${NC}"
        fi
    else
        echo -e "${YELLOW}Fail2Ban is already stopped.${NC}"
    fi
    
    read -p "Press any key to continue..." -n 1
    clear
}

# Function to disable selinux-ssh jail
disable_selinux_ssh_jail() {
    clear
    echo -e "${CYAN}Disabling selinux-ssh jail...${NC}"
    if [ -f /etc/fail2ban/jail.local ]; then
        sudo sed -i '/^\[selinux-ssh\]/,/^\[/ s/enabled = true/enabled = false/' /etc/fail2ban/jail.local
        echo -e "${GREEN}selinux-ssh jail has been disabled!${NC}"
    else
        echo -e "${YELLOW}/etc/fail2ban/jail.local does not exist. Creating it from jail.conf...${NC}"
        sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
        sudo sed -i '/^\[selinux-ssh\]/,/^\[/ s/enabled = true/enabled = false/' /etc/fail2ban/jail.local
        echo -e "${GREEN}selinux-ssh jail has been disabled!${NC}"
    fi
    
    read -p "Press any key to continue..." -n 1
    clear
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice: " choice

    case $choice in
        1)
            install_fail2ban
            ;;
        2)
            remove_fail2ban
            ;;
        3)
            advanced_config
            ;;
        4)
            check_status
            ;;
        5)
            restart_fail2ban
            ;;
        6)
            stop_fail2ban
            ;;
        7)
            echo -e "${CYAN}Exiting...${NC}"
            break
            ;;
        *)
            echo -e "${RED}Invalid option! Please try again.${NC}"
            ;;
    esac
done
