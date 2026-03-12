# reposync_setup

Full script to install and maintain Oracle Linux mirror repository with Ansible deployment and monthly cron job scheduling.

## Overview

This project contains:
- **setup_server.yml** - Ansible playbook to deploy repository sync scripts and configure monthly cron jobs
- **scripts/** - Shell scripts for repository synchronization
- **config/** - Repository configuration files for different Oracle Linux versions
- **inventory.ini** - Ansible inventory file (update with your servers)
- **ansible.cfg** - Ansible configuration file

## Features

✅ Deploy scripts to target servers  
✅ Deploy configuration files  
✅ Create necessary directories and set permissions  
✅ Execute initial setup script  
✅ Configure monthly cron job automatically  
✅ Generate logs for monitoring  

## Prerequisites

- Ansible 2.9+ installed on the control node
- SSH access to target servers
- `sudo` privileges on target servers (or run as root)
- Oracle Linux 8 or 9 on target servers

## Installation & Usage

### 1. Update Inventory File

Edit `inventory.ini` and add your target servers:

```ini
[repository_servers]
repo-server-1 ansible_host=192.168.1.100 ansible_user=root
repo-server-2 ansible_host=repo.example.com ansible_user=root
```

### 2. Run the Playbook

```bash
# Deploy to all repository servers
ansible-playbook -i inventory.ini setup_server.yml

# Deploy to specific server
ansible-playbook -i inventory.ini setup_server.yml -l repo-server-1

# Run with verbose output
ansible-playbook -i inventory.ini setup_server.yml -v

# Check syntax before running
ansible-playbook -i inventory.ini setup_server.yml --syntax-check
```

### 3. Verify Installation

```bash
# Check if cron job is installed
ssh user@server crontab -l | grep repo_sync

# View script deployment
ssh user@server ls -la /opt/repo-sync/

# Check logs
ssh user@server cat /var/log/repo-sync/cron.log
```

## Deployment Details

### Directories Created

- `/opt/repo-sync/` - Script deployment location
- `/etc/repo-sync/config/` - Configuration files
- `/var/log/repo-sync/` - Log files

### Cron Job Schedule

- **Time:** 2:00 AM UTC
- **Frequency:** First day of every month
- **Command:** `/opt/repo-sync/repo_sync.sh`
- **Logs:** `/var/log/repo-sync/cron.log`

### Modifying Cron Job

To change the cron schedule, modify the `cron_schedule` variable in setup_server.yml:

```yaml
cron_schedule: "0 2 1 * *"  # Current: 2 AM on day 1 of each month
# Examples:
# "0 0 * * *"  - Daily at midnight
# "0 */6 * * *" - Every 6 hours
# "0 3 * * 0"  - Weekly on Sunday at 3 AM
```

## Playbook Tasks

1. **Create Directories** - Ensures all required directories exist
2. **Deploy Scripts** - Copies shell scripts to target servers
3. **Deploy Config** - Copies configuration files
4. **Create Symlinks** - Links deployed scripts to /data/repo/scripts
5. **Verify Scripts** - Ensures scripts have execute permissions
6. **Execute Setup** - Runs the complete_repo_setup.sh script
7. **Configure Cron** - Installs monthly cron job
8. **Verify Cron** - Confirms cron job installation

## Troubleshooting

### Cron job not running

```bash
# Check if crond service is running
systemctl status crond

# Verify cron job exists
crontab -l

# Check system logs for cron errors
grep CRON /var/log/messages
tail -f /var/log/cron
```

### Permission issues

```bash
# Ensure scripts are executable
chmod +x /opt/repo-sync/*.sh

# Check directory permissions
ls -ld /opt/repo-sync/ /var/log/repo-sync/
```

### Script execution failures

```bash
# Run script manually to test
/opt/repo-sync/repo_sync.sh

# Check logs
cat /var/log/repo-sync/cron.log
tail -f /var/log/repo-sync/repo_sync_$(date +%Y.%m.%d).log
```

## Variables Configuration

You can customize the deployment by modifying these variables in setup_server.yml:

```yaml
vars:
  script_deployment_path: /opt/repo-sync
  repo_config_path: /etc/repo-sync/config
  log_path: /var/log/repo-sync
  cron_user: root
  cron_job_name: "Repository Sync - Monthly"
  cron_schedule: "0 2 1 * *"  # Cron format: minute hour day month weekday
```

## License

See LICENSE file for details.
