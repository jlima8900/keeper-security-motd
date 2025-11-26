#!/bin/bash
# Keeper Security MOTD - Modular Edition
# Main launcher script that loads and executes all modules

# Exit on error in strict mode (optional, disabled for graceful degradation)
# set -e

# ============================================================================
# CONFIGURATION
# ============================================================================

# Base directory for MOTD system
MOTD_DIR="$HOME/.keeper_motd.d"
MODULES_DIR="$MOTD_DIR/modules"
FRAMEWORK_FILE="$MOTD_DIR/framework.sh"
CONFIG_FILE="$HOME/.keeper_motd.conf"

# ============================================================================
# LOAD CONFIGURATION
# ============================================================================

# Load default configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    # Default settings if config doesn't exist
    ENABLE_ANIMATIONS=true
    ENABLE_CACHE=true
    DEBUG_MODE=false
    MODULE_TIMEOUT=2
    CACHE_DIR="$MOTD_DIR/cache"
    LOG_FILE="$MOTD_DIR/motd.log"
fi

# ============================================================================
# LOAD FRAMEWORK
# ============================================================================

if [ -f "$FRAMEWORK_FILE" ]; then
    source "$FRAMEWORK_FILE"
    init_framework
else
    echo "ERROR: Framework file not found at $FRAMEWORK_FILE" >&2
    echo "Please reinstall the Keeper MOTD system." >&2
    exit 1
fi

# ============================================================================
# MODULE EXECUTION
# ============================================================================

# Function to execute a module
run_module() {
    local module_file="$1"
    local module_name=$(basename "$module_file" .sh)

    log_debug "Loading module: $module_name"

    # Check if module is executable
    if [ ! -x "$module_file" ]; then
        chmod +x "$module_file" 2>/dev/null
    fi

    # Execute module with timeout if configured
    if [ "${MODULE_TIMEOUT:-0}" -gt 0 ]; then
        local start_time=$(date +%s%N)
        timeout "${MODULE_TIMEOUT}" bash "$module_file" 2>/dev/null
        local exit_code=$?
        local end_time=$(date +%s%N)
        local elapsed=$(( (end_time - start_time) / 1000000 ))

        if [ $exit_code -eq 124 ]; then
            log_error "Module '$module_name' timed out after ${MODULE_TIMEOUT}s"
            [ "${DEBUG_MODE:-false}" = "true" ] && \
                echo "[WARN] Module '$module_name' skipped (timeout)" >&2
        fi

        [ "${DEBUG_MODE:-false}" = "true" ] && \
            log_debug "Module '$module_name' completed in ${elapsed}ms (exit: $exit_code)"
    else
        # No timeout
        bash "$module_file" 2>/dev/null
        local exit_code=$?

        [ "${DEBUG_MODE:-false}" = "true" ] && \
            log_debug "Module '$module_name' completed (exit: $exit_code)"
    fi
}

# Function to run all modules in order
run_all_modules() {
    # Check if modules directory exists
    if [ ! -d "$MODULES_DIR" ]; then
        echo "ERROR: Modules directory not found at $MODULES_DIR" >&2
        echo "Please reinstall the Keeper MOTD system." >&2
        exit 1
    fi

    # Get list of module files sorted by number
    local modules=($(find "$MODULES_DIR" -name "[0-9]*-*.sh" -type f | sort -V))

    if [ ${#modules[@]} -eq 0 ]; then
        echo "ERROR: No modules found in $MODULES_DIR" >&2
        echo "Please reinstall the Keeper MOTD system." >&2
        exit 1
    fi

    log_debug "Found ${#modules[@]} modules to execute"

    # Execute each module
    for module in "${modules[@]}"; do
        run_module "$module"
    done

    log_debug "All modules executed successfully"
}

# ============================================================================
# COMMAND LINE INTERFACE
# ============================================================================

# Parse command line arguments
show_help() {
    cat <<EOF
Keeper Security MOTD - Modular Edition

Usage: $(basename "$0") [OPTIONS]

Options:
    -h, --help              Show this help message
    -d, --debug             Enable debug mode
    -c, --clear-cache       Clear all cached data
    -l, --list-modules      List all available modules
    -m, --module MODULE     Run a specific module only
    -n, --no-animation      Disable animations
    -q, --quiet             Suppress all output except errors
    --config FILE           Use alternative config file

Examples:
    $(basename "$0")                    # Run all modules
    $(basename "$0") --debug            # Run with debug output
    $(basename "$0") -m 30-system      # Run only system module
    $(basename "$0") --clear-cache     # Clear cache and run

Configuration:
    Config file: $CONFIG_FILE
    Modules dir: $MODULES_DIR
    Cache dir:   $CACHE_DIR

EOF
}

list_modules() {
    echo "Available modules in $MODULES_DIR:"
    echo ""
    find "$MODULES_DIR" -name "[0-9]*-*.sh" -type f | sort -V | while read module; do
        local name=$(basename "$module" .sh)
        local desc=$(grep -m1 "^# Module:" "$module" | cut -d: -f2- | xargs)
        printf "  %-20s %s\n" "$name" "$desc"
    done
}

# Main execution logic
main() {
    # Parse arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--debug)
                DEBUG_MODE=true
                export DEBUG_MODE
                ;;
            -c|--clear-cache)
                echo "Clearing cache..."
                cache_clear
                echo "Cache cleared."
                ;;
            -l|--list-modules)
                list_modules
                exit 0
                ;;
            -m|--module)
                shift
                if [ -z "$1" ]; then
                    echo "ERROR: --module requires a module name" >&2
                    exit 1
                fi
                MODULE_NAME="$1"
                if [ -f "$MODULES_DIR/$MODULE_NAME.sh" ]; then
                    run_module "$MODULES_DIR/$MODULE_NAME.sh"
                elif [ -f "$MODULES_DIR/$MODULE_NAME" ]; then
                    run_module "$MODULES_DIR/$MODULE_NAME"
                else
                    echo "ERROR: Module '$MODULE_NAME' not found" >&2
                    exit 1
                fi
                exit 0
                ;;
            -n|--no-animation)
                ENABLE_ANIMATIONS=false
                export ENABLE_ANIMATIONS
                ;;
            -q|--quiet)
                exec 1>/dev/null
                ;;
            --config)
                shift
                if [ -z "$1" ] || [ ! -f "$1" ]; then
                    echo "ERROR: --config requires a valid file path" >&2
                    exit 1
                fi
                source "$1"
                ;;
            *)
                echo "ERROR: Unknown option: $1" >&2
                echo "Use --help for usage information" >&2
                exit 1
                ;;
        esac
        shift
    done

    # Run all modules
    run_all_modules
}

# ============================================================================
# EXECUTE
# ============================================================================

main "$@"
