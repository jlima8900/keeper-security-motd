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
