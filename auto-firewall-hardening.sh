#!/bin/bash
# Automatic Firewall Hardening Script (Non-Interactive)
# Applies hardening immediately with detected IP

set -e

echo "============================================"
echo "Automatic Firewall Hardening"
echo "============================================"
echo ""

# Get current SSH connection IP
CURRENT_IP=$(echo $SSH_CLIENT | awk '{print $1}')
if [ -z "$CURRENT_IP" ]; then
    CURRENT_IP=$(w -h | grep root | head -1 | awk '{print $3}')
fi
if [ -z "$CURRENT_IP" ]; then
    CURRENT_IP="194.9.108.173"  # Fallback to detected IP
fi

echo "Detected IP: $CURRENT_IP"
echo ""

# Backup existing rules
echo "Backing up current rules..."
BACKUP_FILE="/root/iptables-backup-$(date +%Y%m%d-%H%M%S).rules"
iptables-save > "$BACKUP_FILE"
echo "✓ Backup saved: $BACKUP_FILE"
echo ""

# Create rollback script
cat > /root/firewall-rollback.sh << 'ROLLBACK'
#!/bin/bash
echo "Rolling back firewall rules..."
BACKUP_FILE=$(ls -t /root/iptables-backup-*.rules | head -1)
if [ -f "$BACKUP_FILE" ]; then
    iptables-restore < "$BACKUP_FILE"
    echo "✓ Firewall rules restored from: $BACKUP_FILE"
else
    echo "Setting permissive policy..."
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -F INPUT
    echo "✓ Firewall set to permissive mode"
fi
ROLLBACK
chmod +x /root/firewall-rollback.sh
echo "✓ Rollback script created: /root/firewall-rollback.sh"
echo ""

# Apply hardening rules
echo "Applying firewall hardening..."
echo ""

# 1. Whitelist current IP at highest priority
echo "1. Whitelisting your IP ($CURRENT_IP)..."
iptables -I INPUT 1 -p tcp -s "$CURRENT_IP" --dport 22 -j ACCEPT
iptables -I INPUT 2 -p tcp -s "$CURRENT_IP" -m state --state ESTABLISHED,RELATED -j ACCEPT
echo "✓ Your IP protected"

# 2. Allow established connections
echo "2. Allowing established connections..."
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
echo "✓ Established connections allowed"

# 3. Allow loopback
echo "3. Allowing loopback..."
iptables -A INPUT -i lo -j ACCEPT 2>/dev/null || true
iptables -A OUTPUT -o lo -j ACCEPT 2>/dev/null || true
echo "✓ Loopback allowed"

# 4. Allow trusted IPs
echo "4. Allowing trusted IPs..."
iptables -I INPUT 3 -p tcp -s 194.9.108.173 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -I INPUT 4 -p tcp -s 37.228.246.73 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
echo "✓ Trusted IPs allowed"

# 5. SSH rate limiting
echo "5. Adding SSH rate limiting..."
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 --rttl --name SSH -j DROP
echo "✓ Rate limiting enabled"

# 6. ICMP rate limiting
echo "6. Adding ICMP rate limiting..."
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
echo "✓ ICMP limited"

# 7. Add logging
echo "7. Enabling logging..."
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables-dropped: " --log-level 4
echo "✓ Logging enabled"

# 8. Change default policy
echo "8. Changing default policy to DROP..."
iptables -P INPUT DROP
iptables -P FORWARD DROP
echo "✓ Default policy: DROP"

# Save rules
echo ""
echo "Saving rules..."
mkdir -p /etc/iptables
iptables-save > /etc/iptables/rules.v4
echo "✓ Rules saved"

echo ""
echo "============================================"
echo "✓ Firewall Hardening Complete!"
echo "============================================"
echo ""
echo "Summary:"
echo "  - Your IP ($CURRENT_IP): WHITELISTED"
echo "  - Trusted IPs: WHITELISTED"
echo "  - Default policy: DROP"
echo "  - SSH rate limiting: ENABLED"
echo "  - All other ports: BLOCKED"
echo ""
echo "Current rules:"
iptables -L INPUT -n -v --line-numbers | head -15
echo ""
echo "To rollback: bash /root/firewall-rollback.sh"
echo ""
