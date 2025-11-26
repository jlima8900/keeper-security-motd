#!/bin/bash
# Module: Resource Vault Status
# Priority: 40

[ "${ENABLE_RESOURCES:-true}" != "true" ] && exit 0

loading_dots "Analyzing resources"

# Get resource info
MEM_INFO=$(get_memory_info)
TOTAL_RAM=$(echo "$MEM_INFO" | cut -d'|' -f1)
USED_RAM=$(echo "$MEM_INFO" | cut -d'|' -f2)
RAM_PCT=$(echo "$MEM_INFO" | cut -d'|' -f3)
DISK_PCT=$(get_disk_info /)
CPU_CORES=$(get_system_info cpu_cores)
LOAD=$(get_system_info load)

echo -e "${KEEPER_GOLD}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${KEEPER_GOLD}║${RESET}  ${BWHITE}💾 RESOURCE VAULT STATUS${RESET}                                                  ${KEEPER_GOLD}║${RESET}"
echo -e "${KEEPER_GOLD}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${KEEPER_GOLD}║${RESET}  ${KEEPER_BLACK}RAM:${RESET}     $(progress_bar $RAM_PCT) ${DIM}(${USED_RAM} / ${TOTAL_RAM})${RESET}"
echo -e "${KEEPER_GOLD}║${RESET}  ${KEEPER_BLACK}Disk:${RESET}    $(progress_bar $DISK_PCT) ${DIM}(/ filesystem)${RESET}"
echo -e "${KEEPER_GOLD}║${RESET}  ${KEEPER_BLACK}CPU:${RESET}     ${KEEPER_GOLD}${CPU_CORES}${RESET} cores ${DIM}│${RESET} Load: ${BYELLOW}${LOAD}${RESET}"
echo -e "${KEEPER_GOLD}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Warnings if resources are critical
if [ "$RAM_PCT" -ge "${RAM_CRITICAL:-90}" ] || [ "$DISK_PCT" -ge "${DISK_CRITICAL:-90}" ]; then
    echo -e "${BRED}⚠️  ${BWHITE}WARNING: System resources running high!${RESET} ${BRED}⚠️${RESET}"
    echo ""
fi
