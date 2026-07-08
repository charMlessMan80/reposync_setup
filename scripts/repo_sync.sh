#!/bin/sh
# YUM repository resync script

STORAGE_BASE="/data/repo"
MIRROR_BASE="$STORAGE_BASE/OracleLinux"
VERS=("OL9")
REPOS=("baseos" "appstream" "epel" "addons" "zabbix-agent2-plugins" "zabbix" "zabbix-non-supported")
ARCH="x86_64"
LOG_FOLDER="$STORAGE_BASE/logs"
LOG_FILE="$LOG_FOLDER/repo_sync_$(date +%Y.%m.%d).log"

# Remove old logs
find "$LOG_FOLDER" -name "repo_sync_*.log" -mtime +5 -delete >> "$LOG_FILE" 2>&1

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Mirror each repository
for ver in "${VERS[@]}"; do
    for repo in "${REPOS[@]}"; do
        log "Starting sync for repository: $ver $repo"

        # Sync repository with cleanup and metadata
        reposync \
            --newest-only \
            --download-metadata \
            --refresh \
            --config="$STORAGE_BASE/config/$ver/repo.conf" \
            --repoid="$repo" \
            --download-path="$MIRROR_BASE/$ver" \
            --delete \
            >> "$LOG_FILE" 2>&1

        if [ $? -eq 0 ]; then
            log "Successfully synced repository: $ver $repo"

        else
            log "Error syncing repository: $ver $repo"
        fi
    done
done

# Restore SELinux context on newly downloaded content so Apache can serve it
if command -v restorecon >/dev/null 2>&1 && [ "$(getenforce 2>/dev/null)" != "Disabled" ]; then
    log "Restoring SELinux context on $STORAGE_BASE"
    restorecon -Rv "$STORAGE_BASE" >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
        log "Successfully restored SELinux context on $STORAGE_BASE"
    else
        log "Error restoring SELinux context on $STORAGE_BASE"
    fi
fi

    log "Repository mirror resync completed"
