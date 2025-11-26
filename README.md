# Keeper Security MOTD

<table>
<tr>
<td><img width="380" alt="MOTD Screenshot 1" src="screenshots/screenshot1.png" /></td>
<td><img width="380" alt="MOTD Screenshot 2" src="screenshots/screenshot2.png" /></td>
</tr>
</table>

> **Hey there!** This is an unofficial, community-created project. The MOTD theme is inspired by Keeper Security but is **not affiliated with, endorsed by, or connected to Keeper Security, Inc.** Just a fan having fun with terminal aesthetics!

A stylish Message of the Day (MOTD) script that makes your Linux server login look way cooler.

---

## Requirements

- Linux (any flavor - Debian, Ubuntu, RHEL, CentOS, Fedora, Arch, whatever)
- Bash or Zsh
- Root access (or adjust paths accordingly)
- Optional: fail2ban (makes threat detection cooler)
- Optional: Docker (if you want container stats)

---

## Quick Start

```bash
# Clone the repo
git clone https://github.com/jlima8900/keeper-security-motd.git
cd keeper-security-motd

# Make it executable
chmod +x .keeper_motd.sh

# Add to your shell config (.bashrc or .zshrc)
echo 'source ~/.keeper_motd.sh' >> ~/.bashrc

# Copy files to home directory
cp -r .keeper_motd.sh .keeper_motd.d password_humor.txt ~/
```

---

## What You'll See on Login

| Section | What It Shows |
|---------|---------------|
| **Vault Animation** | A fancy unlock sequence (because why not?) |
| **System Status** | Your server's vitals - hostname, uptime, load |
| **Resource Vault** | RAM, disk, CPU with cool progress bars |
| **Docker Status** | Container count and service health |
| **Projects** | Current project, git branch, uncommitted sins |
| **Security** | SSH connections, tmux sessions, who's lurking |
| **Threat Detection** | Failed login attempts, banned IPs, threat level |
| **Recent Activity** | What's been happening |
| **Quick Commands** | Handy shortcuts for the lazy (efficient!) |
| **Motivational Quote** | Wisdom to start your session |
| **Password Humor** | A joke to brighten your day |

### Threat Levels

| Level | What It Means |
|-------|---------------|
| **LOW** | Chill. 0-10 failed attempts |
| **MODERATE** | Someone's poking around. 11-50 attempts |
| **HIGH** | They're persistent. 50+ attempts |
| **CRITICAL** | Time to pay attention! 100+ attempts |

---

## Command Line Options

```bash
.keeper_motd.sh [OPTIONS]
```

| Option | What It Does |
|--------|--------------|
| `-h, --help` | Show help (you're reading this, so you're good) |
| `-d, --debug` | Nerd mode - see all the timing info |
| `-c, --clear-cache` | Fresh start, clear all cached data |
| `-l, --list-modules` | See what modules are available |
| `-m, --module NAME` | Run just one module |
| `-n, --no-animation` | Skip the fancy stuff, get to business |
| `-q, --quiet` | Shhhh mode |

### Examples

```bash
# Debug mode for the curious
.keeper_motd.sh --debug

# Just show the threat detection
.keeper_motd.sh -m 75-lapd

# In a hurry? Skip animations
.keeper_motd.sh --no-animation
```

---

## The Modules

They run in order (the numbers matter!):

| Module | Job |
|--------|-----|
| `10-header.sh` | The fancy title |
| `20-vault.sh` | That cool unlock animation |
| `30-system.sh` | System stats |
| `40-resources.sh` | RAM, disk, CPU bars |
| `50-containers.sh` | Docker stuff |
| `60-projects.sh` | Git and project info |
| `70-security.sh` | Who's connected |
| `75-lapd.sh` | Threat detection |
| `80-activity.sh` | Recent happenings |
| `85-commands.sh` | Quick command reference |
| `90-footer.sh` | Quotes and humor |

---

## Configuration

Create `~/.keeper_motd.conf` to tweak things:

```bash
# Turn stuff on/off
ENABLE_ANIMATIONS=true      # The vault animation
ENABLE_CACHE=true           # Speed things up
ENABLE_LAPD=true            # Threat detection
ENABLE_LAPD_THREATS=true    # Show threat details
ENABLE_QUOTES=true          # Motivational quotes
ENABLE_SECURITY_TIP=true    # Password humor

# Performance tweaks
MODULE_TIMEOUT=2            # Seconds before giving up on a module
DEBUG_MODE=false            # Extra output for troubleshooting

# When to panic about resources
RAM_WARNING=75              # Yellow at this %
RAM_CRITICAL=90             # Red at this %

# Log locations (adjust for your distro)
SSH_LOG=/var/log/secure     # RHEL/CentOS/Fedora
# SSH_LOG=/var/log/auth.log # Debian/Ubuntu
FAIL2BAN_LOG=/var/log/fail2ban.log
```

---

## Files

| File | Purpose |
|------|---------|
| `.keeper_motd.sh` | Main MOTD script |
| `.keeper_motd.d/` | All the modules and framework |
| `password_humor.txt` | 251 jokes about passwords |

---

## Related Projects

Looking for SSH-based firewall whitelisting? Check out [ssh-doorknock-firewall](https://github.com/jlima8900/ssh-doorknock-firewall) - dynamic IP whitelisting via SSH authentication.

---

## License

MIT - Do whatever you want with it!
