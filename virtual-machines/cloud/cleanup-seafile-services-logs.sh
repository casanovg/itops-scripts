#!/bin/bash
#
# cleanup-seafile-services-logs.sh
# Script to clean up large system logs to free up disk space
# 
# This script automatically detects:
# - MariaDB log location from config file or common locations
# - Seafile installation directory (supports /opt/seafile, /home/seafile, or auto-detection)
# - Works on different server configurations without modification
#
# Usage: sudo ./cleanup-seafile-services-logs.sh [--dry-run]
#
# Author: System maintenance
# Date: 2025-11-05
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Dry-run mode
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "${YELLOW}⚠️  DRY-RUN mode enabled - no changes will be made${NC}"
    echo ""
fi

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ This script must be run as root or with sudo${NC}" 
   exit 1
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Seafile Services Log Cleanup Script                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to get file size
get_size() {
    if [[ -f "$1" ]]; then
        du -h "$1" | cut -f1
    else
        echo "N/A"
    fi
}

# Function to truncate a file
truncate_file() {
    local file="$1"
    local size_before=$(get_size "$file")
    
    if [[ ! -f "$file" ]]; then
        echo -e "  ${YELLOW}⚠️  File does not exist: $file${NC}"
        return
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${BLUE}[DRY-RUN]${NC} Would truncate: $file (size: $size_before)"
    else
        truncate -s 0 "$file"
        echo -e "  ${GREEN}✓${NC} Cleaned: $file (freed: $size_before)"
    fi
}

# Function to delete old files
delete_old_files() {
    local pattern="$1"
    local days="$2"
    local count=0
    
    if [[ "$DRY_RUN" == true ]]; then
        count=$(find $pattern -mtime +$days 2>/dev/null | wc -l)
        if [[ $count -gt 0 ]]; then
            echo -e "  ${BLUE}[DRY-RUN]${NC} Would delete $count old files (>$days days)"
            find $pattern -mtime +$days -ls 2>/dev/null | head -5
        fi
    else
        find $pattern -mtime +$days -delete 2>/dev/null && \
            echo -e "  ${GREEN}✓${NC} Deleted old files in $pattern (>$days days)"
    fi
}

# Show disk space before cleanup
echo -e "${YELLOW}📊 Disk space BEFORE cleanup:${NC}"
df -h / | grep -E '^Filesystem|/$'
echo ""

TOTAL_FREED=0

# 1. Clean MariaDB logs
echo -e "${BLUE}🗄️  Cleaning MariaDB logs...${NC}"
# Try to detect MariaDB log location from configuration
MARIADB_LOG=""
if [[ -f "/etc/my.cnf.d/mariadb-server.cnf" ]]; then
    MARIADB_LOG=$(grep -E "^log-error=" /etc/my.cnf.d/mariadb-server.cnf 2>/dev/null | cut -d'=' -f2)
fi
# Fallback to common locations
if [[ -z "$MARIADB_LOG" ]] || [[ ! -f "$MARIADB_LOG" ]]; then
    if [[ -f "/var/log/mariadb/mariadb.log" ]]; then
        MARIADB_LOG="/var/log/mariadb/mariadb.log"
    elif [[ -f "/var/log/mysql/mysql.log" ]]; then
        MARIADB_LOG="/var/log/mysql/mysql.log"
    fi
fi

if [[ -n "$MARIADB_LOG" ]] && [[ -f "$MARIADB_LOG" ]]; then
    truncate_file "$MARIADB_LOG"
else
    echo -e "  ${YELLOW}⚠️  MariaDB log file not found${NC}"
fi
echo ""

# 2. Clean Seafile logs
echo -e "${BLUE}🐚 Cleaning Seafile logs...${NC}"
# Try to detect Seafile installation directory
SEAFILE_LOG_DIR=""
if [[ -d "/opt/seafile/logs" ]]; then
    SEAFILE_LOG_DIR="/opt/seafile/logs"
elif [[ -d "/home/seafile/logs" ]]; then
    SEAFILE_LOG_DIR="/home/seafile/logs"
else
    # Try to find seafile installation by looking for common process
    SEAFILE_PROCESS=$(ps aux | grep -E "seafile.*seaf-server" | grep -v grep | head -1)
    if [[ -n "$SEAFILE_PROCESS" ]]; then
        SEAFILE_LOG_DIR=$(echo "$SEAFILE_PROCESS" | grep -oP '\-l\s+\K[^\s]+' | xargs dirname 2>/dev/null)
    fi
fi

if [[ -n "$SEAFILE_LOG_DIR" ]] && [[ -d "$SEAFILE_LOG_DIR" ]]; then
    truncate_file "$SEAFILE_LOG_DIR/controller.log"
    truncate_file "$SEAFILE_LOG_DIR/seafdav.log"
    truncate_file "$SEAFILE_LOG_DIR/notification-server.log"
    truncate_file "$SEAFILE_LOG_DIR/file_updates_sender.log"
    
    # Delete old rotated logs (older than 90 days)
    echo -e "  ${BLUE}🗑️  Deleting old rotated logs...${NC}"
    delete_old_files "$SEAFILE_LOG_DIR/*.log.*" 90
else
    echo -e "  ${YELLOW}⚠️  Seafile logs directory not found${NC}"
fi
echo ""

# 3. Clean DNF cache
echo -e "${BLUE}📦 Cleaning DNF cache...${NC}"
if [[ "$DRY_RUN" == true ]]; then
    cache_size=$(du -sh /var/cache/dnf 2>/dev/null | cut -f1 || echo "0")
    echo -e "  ${BLUE}[DRY-RUN]${NC} Would clean DNF cache (current size: $cache_size)"
else
    dnf clean all &>/dev/null || true
    rm -rf /var/cache/dnf/* 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} DNF cache cleaned"
fi
echo ""

# 4. Clean system journal
echo -e "${BLUE}📝 Cleaning system journal (keep last 3 days)...${NC}"
if [[ "$DRY_RUN" == true ]]; then
    journal_size=$(journalctl --disk-usage 2>/dev/null | grep -oP '\d+\.\d+[A-Z]' || echo "N/A")
    echo -e "  ${BLUE}[DRY-RUN]${NC} Would clean system journal (current size: $journal_size)"
else
    journalctl --vacuum-time=3d &>/dev/null
    echo -e "  ${GREEN}✓${NC} System journal cleaned"
fi
echo ""

# 5. Clean old seafevents rotated logs
echo -e "${BLUE}📅 Cleaning seafevents rotated logs...${NC}"
if [[ -n "$SEAFILE_LOG_DIR" ]] && [[ -d "$SEAFILE_LOG_DIR" ]]; then
    delete_old_files "$SEAFILE_LOG_DIR/seafevents.log.*" 60
else
    echo -e "  ${YELLOW}⚠️  No logs found to clean${NC}"
fi
echo ""

# 6. Clean old temporary files
echo -e "${BLUE}🗑️  Cleaning old temporary files...${NC}"
if [[ "$DRY_RUN" == true ]]; then
    tmp_count=$(find /tmp -type f -mtime +7 2>/dev/null | wc -l)
    echo -e "  ${BLUE}[DRY-RUN]${NC} Would delete $tmp_count temporary files (>7 days)"
else
    find /tmp -type f -mtime +7 -delete 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Old temporary files deleted"
fi
echo ""

# Show disk space after cleanup
echo -e "${YELLOW}📊 Disk space AFTER cleanup:${NC}"
df -h / | grep -E '^Filesystem|/$'
echo ""

# Calculate freed space
BEFORE=$(df / | tail -1 | awk '{print $3}')
AFTER=$(df / | tail -1 | awk '{print $3}')

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${GREEN}║  Simulation completed - No changes were made              ║${NC}"
else
    echo -e "${GREEN}║  ✅ Cleanup completed successfully                         ║${NC}"
fi
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}💡 Recommendations:${NC}"
echo -e "   1. Consider configuring logrotate for Seafile logs"
echo -e "   2. Schedule this script with cron (e.g., monthly)"
echo -e "   3. Monitor disk space regularly with: df -h /"
echo ""

exit 0
