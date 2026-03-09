#!/bin/sh
# YUM repository resync script

MIRROR_BASE="/data/repo/OracleLinux"
VERS=("OL9" "OL8")
REPOS=("baseos" "appstream" "epel")
ARCH="x86_64"
LOG_FILE=/data/repo/logs/repo_sync_$(date +%Y.%m.%d).log

# Remove old logs
find "$LOG_FILE*" -mtime +5 -delete; >> $LOG_FILE 2>&1

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Mirror each repository
for ver in "${VERS[@]}"; do
    for repo in "${REPOS[@]}"; do
        log "Starting sync for repository: $ver $repo"

        # Create repository directory
        mkdir -p "$MIRROR_BASE/$ver/$repo"

        # Sync repository with cleanup and metadata
        reposync \
            --newest-only \
            --config="../config/$ver/repo.conf" \
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

    log "Repository mirror setup completed"
