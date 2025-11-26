#!/bin/bash
# Keeper MOTD Framework
# Shared utilities and functions for all modules

# ============================================================================
# ANSI COLOR CODES
# ============================================================================

RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
BLINK='\033[5m'

# Standard Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Bold Colors
BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BBLUE='\033[1;34m'
BMAGENTA='\033[1;35m'
BCYAN='\033[1;36m'
BWHITE='\033[1;37m'

# RGB Colors
ORANGE='\033[38;5;208m'
PURPLE='\033[38;5;141m'
LIME='\033[38;5;118m'
PINK='\033[38;5;213m'

# Keeper Brand Colors
KEEPER_GOLD='\033[38;5;220m'
KEEPER_BLACK='\033[38;5;232m'
KEEPER_DARK='\033[38;5;240m'

# Export all color variables so modules can use them
export RESET BOLD DIM BLINK
export RED GREEN YELLOW BLUE MAGENTA CYAN WHITE
export BRED BGREEN BYELLOW BBLUE BMAGENTA BCYAN BWHITE
export ORANGE PURPLE LIME PINK
export KEEPER_GOLD KEEPER_BLACK KEEPER_DARK

# ============================================================================
# TERMINAL UTILITIES
# ============================================================================

# Get terminal dimensions
get_terminal_width() {
    tput cols 2>/dev/null || echo 80
}

# Calculate box width based on terminal and config
calculate_box_width() {
    local term_width=$(get_terminal_width)
    local max_width=${MAX_BOX_WIDTH:-120}

    if [ "$term_width" -gt "$max_width" ]; then
        echo "$max_width"
    else
        echo $((term_width - 2))
    fi
}

# ============================================================================
# PROGRESS BAR GENERATOR
# ============================================================================

progress_bar() {
    local pct=$1
    local width=${2:-25}
    local filled=$((pct * width / 100))
    local empty=$((width - filled))

    # Color based on usage
    local color
    if [ "$pct" -ge "${RAM_CRITICAL:-90}" ]; then
        color="${BRED}"
    elif [ "$pct" -ge "${RAM_WARNING:-75}" ]; then
        color="${BYELLOW}"
    else
        color="${BGREEN}"
    fi

    echo -n "${color}["
    for ((i=0; i<filled; i++)); do echo -n "█"; done
    for ((i=0; i<empty; i++)); do echo -n "░"; done
    echo -n "] ${pct}%${RESET}"
}

# ============================================================================
# ANIMATION FUNCTIONS
# ============================================================================

# Animated typing effect
type_text() {
    local text="$1"
    local delay="${2:-${ANIMATION_SPEED:-0.01}}"

    if [ "${ENABLE_ANIMATIONS:-true}" = "true" ]; then
        for ((i=0; i<${#text}; i++)); do
            echo -n "${text:$i:1}"
            sleep "$delay"
        done
        echo ""
    else
        echo "$text"
    fi
}

# Loading dots animation
loading_dots() {
    local text="$1"
    local count="${2:-3}"

    if [ "${ENABLE_ANIMATIONS:-true}" = "true" ]; then
        echo -ne "${KEEPER_GOLD}>>> ${RESET}${text}"
        for i in $(seq 1 $count); do
            echo -n "."
            sleep "${LOADING_DELAY:-0.05}"
        done
        echo -e " ${BGREEN}✓${RESET}"
    else
        echo -e "${KEEPER_GOLD}>>> ${RESET}${text} ${BGREEN}✓${RESET}"
    fi

    [ "${ENABLE_ANIMATIONS:-true}" = "true" ] && sleep 0.1
}

# ============================================================================
# CACHE FUNCTIONS
# ============================================================================

# Check if cache file exists and is fresh
cache_is_fresh() {
    local cache_file="$1"
    local ttl="$2"

    [ "${ENABLE_CACHE:-true}" != "true" ] && return 1
    [ ! -f "$cache_file" ] && return 1

    local file_age=$(( $(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0) ))
    [ "$file_age" -lt "$ttl" ]
}

# Read from cache
cache_read() {
    local cache_file="$1"
    [ -f "$cache_file" ] && cat "$cache_file"
}

# Write to cache
cache_write() {
    local cache_file="$1"
    local content="$2"

    [ "${ENABLE_CACHE:-true}" != "true" ] && return

    mkdir -p "$(dirname "$cache_file")"
    echo "$content" > "$cache_file"
}

# Clear all cache
cache_clear() {
    [ -d "${CACHE_DIR}" ] && rm -f "${CACHE_DIR}"/*
}

# ============================================================================
# DEPENDENCY CHECKING
# ============================================================================

# Check if command exists
has_command() {
    command -v "$1" >/dev/null 2>&1
}

# Check if command exists, return status silently
check_dependency() {
    local cmd="$1"
    has_command "$cmd"
}

# Require dependency, exit module if missing
require_dependency() {
    local cmd="$1"
    local module_name="${2:-Unknown module}"

    if ! has_command "$cmd"; then
        [ "${DEBUG_MODE:-false}" = "true" ] && \
            echo "[DEBUG] Module '$module_name' skipped: missing dependency '$cmd'" >&2
        return 1
    fi
    return 0
}

# ============================================================================
# BOX DRAWING UTILITIES
# ============================================================================

# Generate horizontal line
draw_line() {
    local width="$1"
    local char="${2:-═}"
    printf "${char}%.0s" $(seq 1 $((width - 2)))
}

# Draw box header
draw_box_header() {
    local width="$1"
    local color="${2:-$KEEPER_GOLD}"
    echo -e "${color}╔$(draw_line "$width")╗${RESET}"
}

# Draw box footer
draw_box_footer() {
    local width="$1"
    local color="${2:-$KEEPER_GOLD}"
    echo -e "${color}╚$(draw_line "$width")╝${RESET}"
}

# Draw box divider
draw_box_divider() {
    local width="$1"
    local color="${2:-$KEEPER_GOLD}"
    echo -e "${color}╠$(draw_line "$width")╣${RESET}"
}

# Draw box line with content
draw_box_line() {
    local content="$1"
    local width="$2"
    local color="${3:-$KEEPER_GOLD}"

    # Strip ANSI codes for length calculation
    local clean_content=$(echo -e "$content" | sed 's/\x1b\[[0-9;]*m//g')
    local content_length=${#clean_content}
    local padding=$((width - content_length - 4))

    if [ "$padding" -lt 0 ]; then
        padding=0
    fi

    local spaces=$(printf ' %.0s' $(seq 1 $padding))
    echo -e "${color}║${RESET}  ${content}${spaces}${color}║${RESET}"
}

# ============================================================================
# SYSTEM INFORMATION HELPERS
# ============================================================================

# Get system info with caching
get_system_info() {
    local info_type="$1"
    local cache_file="${CACHE_DIR}/system_${info_type}"

    if cache_is_fresh "$cache_file" "${CACHE_SYSTEM_TTL:-30}"; then
        cache_read "$cache_file"
        return
    fi

    local result=""
    case "$info_type" in
        hostname)
            result=$(hostname)
            ;;
        uptime)
            result=$(uptime -p | sed 's/up //')
            ;;
        load)
            result=$(uptime | awk -F'load average:' '{print $2}' | xargs | cut -d',' -f1)
            ;;
        users)
            result=$(who | wc -l)
            ;;
        cpu_cores)
            result=$(nproc)
            ;;
    esac

    cache_write "$cache_file" "$result"
    echo "$result"
}

# Get memory info with caching
get_memory_info() {
    local cache_file="${CACHE_DIR}/memory_info"

    if cache_is_fresh "$cache_file" "${CACHE_SYSTEM_TTL:-30}"; then
        cache_read "$cache_file"
        return
    fi

    local total=$(free -h | awk '/^Mem:/{print $2}')
    local used=$(free -h | awk '/^Mem:/{print $3}')
    local pct=$(free | awk '/^Mem:/{printf "%.0f", $3/$2 * 100}')

    local result="${total}|${used}|${pct}"
    cache_write "$cache_file" "$result"
    echo "$result"
}

# Get disk info with caching
get_disk_info() {
    local mount_point="${1:-/}"
    local cache_file="${CACHE_DIR}/disk_info"

    if cache_is_fresh "$cache_file" "${CACHE_SYSTEM_TTL:-30}"; then
        cache_read "$cache_file"
        return
    fi

    local pct=$(df "$mount_point" | awk 'NR==2 {print $5}' | sed 's/%//')
    cache_write "$cache_file" "$pct"
    echo "$pct"
}

# ============================================================================
# LOGGING UTILITIES
# ============================================================================

# Log message
log_message() {
    local level="$1"
    local message="$2"
    local log_file="${LOG_FILE:-$HOME/.keeper_motd.d/motd.log}"

    [ "${DEBUG_MODE:-false}" != "true" ] && return

    mkdir -p "$(dirname "$log_file")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$log_file"
}

# Log debug message
log_debug() {
    log_message "DEBUG" "$1"
}

# Log error message
log_error() {
    log_message "ERROR" "$1"
}

# ============================================================================
# MODULE EXECUTION HELPERS
# ============================================================================

# Execute module with timeout
execute_with_timeout() {
    local timeout="${MODULE_TIMEOUT:-2}"
    local module_name="$1"
    shift

    if [ "$timeout" -eq 0 ]; then
        "$@"
        return $?
    fi

    timeout "$timeout" "$@" 2>/dev/null
    local exit_code=$?

    if [ $exit_code -eq 124 ]; then
        log_error "Module '$module_name' timed out after ${timeout}s"
        return 1
    fi

    return $exit_code
}

# Measure module execution time
measure_time() {
    local start=$(date +%s%N)
    "$@"
    local end=$(date +%s%N)
    local elapsed=$(( (end - start) / 1000000 ))

    [ "${DEBUG_MODE:-false}" = "true" ] && \
        echo "[DEBUG] Execution time: ${elapsed}ms" >&2
}

# ============================================================================
# INITIALIZATION
# ============================================================================

# Initialize framework
init_framework() {
    # Create cache directory
    mkdir -p "${CACHE_DIR:-$HOME/.keeper_motd.d/cache}"

    # Create log directory
    mkdir -p "$(dirname "${LOG_FILE:-$HOME/.keeper_motd.d/motd.log}")"

    log_debug "Framework initialized"
}

# Export all functions for use in modules
export -f progress_bar type_text loading_dots
export -f cache_is_fresh cache_read cache_write cache_clear
export -f has_command check_dependency require_dependency
export -f draw_line draw_box_header draw_box_footer draw_box_divider draw_box_line
export -f get_system_info get_memory_info get_disk_info
export -f log_message log_debug log_error
export -f execute_with_timeout measure_time
export -f get_terminal_width calculate_box_width

# Export configuration variables
export ENABLE_ANIMATIONS ENABLE_VAULT ENABLE_HEADER ENABLE_SYSTEM_STATUS
export ENABLE_RESOURCES ENABLE_CONTAINERS ENABLE_PROJECTS ENABLE_SECURITY
export ENABLE_LAPD ENABLE_ACTIVITY ENABLE_COMMANDS ENABLE_QUOTES ENABLE_SECURITY_TIP
export ANIMATION_SPEED LOADING_DELAY VAULT_DELAY
export MAX_BOX_WIDTH SHOW_DOCKER SHOW_KEEPER_SERVICES SHOW_GIT SHOW_PROJECT_TRACKING
export RAM_WARNING RAM_CRITICAL DISK_WARNING DISK_CRITICAL
export LOAD_WARNING LOAD_CRITICAL
export ENABLE_LAPD_THREATS THREAT_MODERATE THREAT_ELEVATED THREAT_CRITICAL
export SSH_LOG FAIL2BAN_LOG
export ENABLE_CACHE CACHE_DIR
export CACHE_SYSTEM_TTL CACHE_DOCKER_TTL CACHE_THREAT_TTL CACHE_GIT_TTL
export SECURITY_TIPS_FILE CURRENT_PROJECT_FILE AUTOMATION_DB
export DEBUG_MODE LOG_FILE MODULE_TIMEOUT
