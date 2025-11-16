# Keeper Security MOTD - Modular Edition

A modern, modular Message of the Day (MOTD) system for Keeper Security environments, featuring:

- **Modular Architecture**: Easy to customize, enable/disable individual components
- **Performance Caching**: Intelligent caching reduces login delays
- **Configurable**: Extensive configuration options via `~/.keeper_motd.conf`
- **Graceful Degradation**: Missing dependencies don't break the system
- **Animated**: Optional vault unlocking animations and loading effects
- **Branded**: Keeper Security + LAPD threat detection integration

## Quick Start

```bash
# Run the MOTD
~/.keeper_motd.sh

# Show help
~/.keeper_motd.sh --help

# List available modules
~/.keeper_motd.sh --list-modules

# Run specific module only
~/.keeper_motd.sh --module 30-system

# Clear cache and run
~/.keeper_motd.sh --clear-cache

# Disable animations
~/.keeper_motd.sh --no-animation

# Debug mode
~/.keeper_motd.sh --debug
```

## Directory Structure

```
~/.keeper_motd.d/
├── framework.sh              # Shared utilities and functions
├── modules/                  # Individual feature modules
│   ├── 10-header.sh         # Keeper + LAPD logo
│   ├── 20-vault.sh          # Vault unlocking animation
│   ├── 30-system.sh         # System status
│   ├── 40-resources.sh      # Resource monitoring
│   ├── 50-containers.sh     # Docker containers
│   ├── 60-projects.sh       # Project tracking
│   ├── 70-security.sh       # SSH/connection status
│   ├── 75-lapd.sh           # LAPD threat detection
│   ├── 80-activity.sh       # Recent activity
│   ├── 85-commands.sh       # Quick commands
│   └── 90-footer.sh         # Quotes and security tips
├── cache/                   # Performance cache directory
└── README.md               # This file

~/.keeper_motd.conf          # Configuration file
~/.keeper_motd.sh            # Main launcher script
```

## Configuration

Edit `~/.keeper_motd.conf` to customize your MOTD:

### Feature Toggles

```bash
ENABLE_ANIMATIONS=true       # Enable/disable animations
ENABLE_VAULT=true            # Show vault unlocking animation
ENABLE_HEADER=true           # Show Keeper+LAPD logo
ENABLE_SYSTEM_STATUS=true    # Show system information
ENABLE_RESOURCES=true        # Show resource usage
ENABLE_CONTAINERS=true       # Show Docker containers
ENABLE_PROJECTS=true         # Show project tracking
ENABLE_SECURITY=true         # Show SSH/connection info
ENABLE_LAPD=true             # Show threat detection
ENABLE_ACTIVITY=true         # Show recent activity
ENABLE_COMMANDS=true         # Show quick commands
ENABLE_QUOTES=true           # Show motivational quotes
ENABLE_SECURITY_TIP=true     # Show security tips
```

### Performance Settings

```bash
ENABLE_CACHE=true            # Enable caching
CACHE_SYSTEM_TTL=30          # System info cache (seconds)
CACHE_DOCKER_TTL=15          # Docker info cache (seconds)
CACHE_THREAT_TTL=60          # Threat info cache (seconds)
CACHE_GIT_TTL=5              # Git info cache (seconds)
MODULE_TIMEOUT=2             # Module timeout (0 = disabled)
```

### Threshold Settings

```bash
RAM_WARNING=75               # RAM warning threshold (%)
RAM_CRITICAL=90              # RAM critical threshold (%)
DISK_WARNING=75              # Disk warning threshold (%)
DISK_CRITICAL=90             # Disk critical threshold (%)
THREAT_MODERATE=1            # Moderate threat level
THREAT_ELEVATED=500          # Elevated threat level
THREAT_CRITICAL=1000         # Critical threat level
```

## Creating Custom Modules

Modules are simple bash scripts that run in sequence. Create a new module:

```bash
# Create a new module
cat > ~/.keeper_motd.d/modules/95-custom.sh << 'EOF'
#!/bin/bash
# Module: My Custom Module
# Priority: 95

# Check if module is enabled
[ "${ENABLE_CUSTOM:-true}" != "true" ] && exit 0

# Use framework functions
loading_dots "Loading custom data"

# Your code here
echo -e "${KEEPER_GOLD}╔════════════════════════════════════════╗${RESET}"
echo -e "${KEEPER_GOLD}║${RESET}  ${BWHITE}MY CUSTOM SECTION${RESET}          ${KEEPER_GOLD}║${RESET}"
echo -e "${KEEPER_GOLD}╠════════════════════════════════════════╣${RESET}"
echo -e "${KEEPER_GOLD}║${RESET}  Your custom content here..."
echo -e "${KEEPER_GOLD}╚════════════════════════════════════════╝${RESET}"
echo ""
EOF

# Make it executable
chmod +x ~/.keeper_motd.d/modules/95-custom.sh
```

### Module Naming Convention

- `NN-name.sh` where NN is a two-digit number (10-99)
- Lower numbers run first
- Standard ranges:
  - 10-19: Headers/branding
  - 20-29: Animations
  - 30-59: System information
  - 60-79: Security/monitoring
  - 80-89: Activity/commands
  - 90-99: Footers/tips

### Available Framework Functions

```bash
# Colors (see framework.sh for complete list)
KEEPER_GOLD, KEEPER_BLACK, KEEPER_DARK
BGREEN, BYELLOW, BRED, BCYAN, BWHITE
RESET, BOLD, DIM

# Progress bars
progress_bar <percentage> [width]

# Animations
loading_dots "Loading message" [dot_count]
type_text "Text to type" [delay]

# Caching
cache_is_fresh "cache_file" <ttl_seconds>
cache_read "cache_file"
cache_write "cache_file" "content"
cache_clear

# System info
get_system_info <hostname|uptime|load|users|cpu_cores>
get_memory_info  # Returns: total|used|percentage
get_disk_info [mount_point]

# Dependencies
has_command "command_name"
check_dependency "command_name"
require_dependency "command_name" "module_name" || exit 0

# Logging (when DEBUG_MODE=true)
log_debug "message"
log_error "message"
```

## Performance Optimization

The modular system includes several performance optimizations:

1. **Caching**: Expensive operations (Docker, Git, system stats) are cached
2. **Timeouts**: Modules that hang won't block login
3. **Lazy Loading**: Only enabled modules are executed
4. **Parallel Ready**: Framework supports future parallel execution

### Cache Management

```bash
# View cache
ls -lh ~/.keeper_motd.d/cache/

# Clear cache manually
~/.keeper_motd.sh --clear-cache

# Clear cache programmatically
rm -rf ~/.keeper_motd.d/cache/*

# Adjust cache TTL in config
CACHE_SYSTEM_TTL=60  # Increase to 60 seconds
```

## Troubleshooting

### Module Not Appearing

1. Check if module is enabled in config
2. Verify module is executable: `chmod +x ~/.keeper_motd.d/modules/XX-name.sh`
3. Check for errors in debug mode: `~/.keeper_motd.sh --debug`

### Slow Performance

1. Enable caching: `ENABLE_CACHE=true`
2. Increase cache TTL values
3. Set module timeout: `MODULE_TIMEOUT=2`
4. Disable expensive modules temporarily

### Animations Not Working

1. Check terminal supports ANSI colors
2. Verify `ENABLE_ANIMATIONS=true` in config
3. Try running with `--no-animation` to isolate issue

### Dependencies Missing

The system gracefully handles missing dependencies. To see which are missing:

```bash
~/.keeper_motd.sh --debug 2>&1 | grep "missing dependency"
```

Common optional dependencies:
- `docker` - For container status
- `git` - For project tracking
- `tmux` - For session count
- `sqlite3` - For workflow tracking
- `fail2ban-client` - For ban statistics

## Integration with Shell

The MOTD runs automatically when configured in shell RC files:

### Bash (~/.bashrc)
```bash
# Run Keeper MOTD on login
if [ -f "$HOME/.keeper_motd.sh" ]; then
    "$HOME/.keeper_motd.sh"
fi
```

### Zsh (~/.zshrc)
```bash
# Run Keeper MOTD on login
if [ -f "$HOME/.keeper_motd.sh" ]; then
    "$HOME/.keeper_motd.sh"
fi
```

## Backup and Restore

### Backup

```bash
tar -czf keeper-motd-backup-$(date +%Y%m%d).tar.gz \
    ~/.keeper_motd.sh \
    ~/.keeper_motd.conf \
    ~/.keeper_motd.d/
```

### Restore

```bash
tar -xzf keeper-motd-backup-YYYYMMDD.tar.gz -C ~/
```

## Comparison with GitHub Projects

This modular system incorporates best practices from popular MOTD projects:

| Feature | This System | yboetz/motd | bcyran/fancy-motd | desbma/motd |
|---------|-------------|-------------|-------------------|-------------|
| Modular | ✅ | ✅ | ✅ | ❌ |
| Caching | ✅ | ❌ | ❌ | ✅ |
| Config File | ✅ | ❌ | ✅ | ✅ |
| Animations | ✅ | ✅ | ❌ | ❌ |
| Timeouts | ✅ | ❌ | ❌ | ❌ |
| CLI Options | ✅ | ❌ | ❌ | ✅ |
| Branding | ✅ Keeper | ❌ | ❌ | ❌ |
| Threat Detection | ✅ LAPD | ✅ fail2ban | ❌ | ❌ |

## Advanced Features

### Conditional Module Loading

Modules can conditionally execute based on environment:

```bash
# Only run on production servers
[ "$(hostname)" != "production-*" ] && exit 0

# Only run during business hours
current_hour=$(date +%H)
[ $current_hour -lt 8 ] || [ $current_hour -gt 18 ] && exit 0

# Only run if specific file exists
[ ! -f "/opt/keeper/running" ] && exit 0
```

### Custom Themes

Create theme files to override colors:

```bash
# ~/.keeper_motd.d/themes/dark.sh
KEEPER_GOLD='\033[38;5;178m'
KEEPER_BLACK='\033[38;5;235m'

# Load in config
source ~/.keeper_motd.d/themes/dark.sh
```

## Version History

- **v2.0** (2025-01-16): Modular architecture, caching, configuration
- **v1.0** (2024): Original monolithic script

## License

Proprietary - Keeper Security

## Support

For issues or questions, contact your Keeper Security administrator.
