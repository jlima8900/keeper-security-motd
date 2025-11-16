#!/bin/bash
# Module: Project & Automation Status
# Priority: 60

[ "${ENABLE_PROJECTS:-true}" != "true" ] && exit 0

loading_dots "Scanning projects"

echo -e "${KEEPER_GOLD}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${KEEPER_GOLD}║${RESET}  ${BWHITE}🚀 ACTIVE PROJECTS & AUTOMATION${RESET}                                           ${KEEPER_GOLD}║${RESET}"
echo -e "${KEEPER_GOLD}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"

# Check for active projects
CURRENT_PROJECT=""
if [ -f "${CURRENT_PROJECT_FILE:-$HOME/.current_automation_project}" ]; then
    CURRENT_PROJECT=$(cat "${CURRENT_PROJECT_FILE:-$HOME/.current_automation_project}" 2>/dev/null)
fi

if [ -n "$CURRENT_PROJECT" ]; then
    echo -e "${KEEPER_GOLD}║${RESET}  ${KEEPER_BLACK}Current Project:${RESET} ${BGREEN}✓${RESET} ${BWHITE}${CURRENT_PROJECT}${RESET}"
else
    echo -e "${KEEPER_GOLD}║${RESET}  ${KEEPER_BLACK}Current Project:${RESET} ${DIM}No active project${RESET}"
fi

# Git status for current directory
if [ "${SHOW_GIT:-true}" = "true" ] && [ -d ".git" ]; then
    CACHE_FILE="${CACHE_DIR}/git_info"

    if cache_is_fresh "$CACHE_FILE" "${CACHE_GIT_TTL:-5}"; then
        GIT_INFO=$(cache_read "$CACHE_FILE")
        GIT_BRANCH=$(echo "$GIT_INFO" | cut -d'|' -f1)
        GIT_STATUS=$(echo "$GIT_INFO" | cut -d'|' -f2)
    else
        GIT_BRANCH=$(git branch --show-current 2>/dev/null)
        GIT_STATUS=$(git status --porcelain 2>/dev/null | wc -l)
        cache_write "$CACHE_FILE" "${GIT_BRANCH}|${GIT_STATUS}"
    fi

    if [ "$GIT_STATUS" -gt 0 ]; then
        echo -e "${KEEPER_GOLD}║${RESET}  ${KEEPER_BLACK}Git Branch:${RESET}      ${BYELLOW}${GIT_BRANCH}${RESET} ${DIM}│${RESET} ${YELLOW}${GIT_STATUS} uncommitted changes${RESET}"
    else
        echo -e "${KEEPER_GOLD}║${RESET}  ${KEEPER_BLACK}Git Branch:${RESET}      ${BGREEN}${GIT_BRANCH}${RESET} ${DIM}│${RESET} ${BGREEN}✓ Clean${RESET}"
    fi
fi

# Check for automation database
if [ "${SHOW_PROJECT_TRACKING:-true}" = "true" ] && [ -f "${AUTOMATION_DB:-$HOME/.automation_context.db}" ]; then
    if check_dependency sqlite3; then
        WORKFLOW_COUNT=$(sqlite3 "${AUTOMATION_DB}" "SELECT COUNT(*) FROM workflows WHERE status='running'" 2>/dev/null || echo "0")
        if [ "$WORKFLOW_COUNT" -gt 0 ]; then
            echo -e "${KEEPER_GOLD}║${RESET}  ${KEEPER_BLACK}Workflows:${RESET}       ${BGREEN}✓${RESET} ${KEEPER_GOLD}${WORKFLOW_COUNT}${RESET} workflow(s) ${BGREEN}RUNNING${RESET}"
        else
            echo -e "${KEEPER_GOLD}║${RESET}  ${KEEPER_BLACK}Workflows:${RESET}       ${DIM}No active workflows${RESET}"
        fi
    fi
fi

echo -e "${KEEPER_GOLD}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
