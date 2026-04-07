#!/bin/bash

# wait-and-open-port.sh
# Waits for port 3000 to be ready and ensures it's visible in Codespaces

PORT=3000
MAX_WAIT=180
ELAPSED=0

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Waiting for port $PORT to be ready...${NC}"

# Wait for port to respond
while [ $ELAPSED -lt $MAX_WAIT ]; do
    if curl -s -m 3 http://localhost:$PORT/ > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Port $PORT is responding${NC}"
        break
    fi
    
    echo -ne "\rWaiting... ($ELAPSED / $MAX_WAIT seconds)"
    sleep 2
    ELAPSED=$((ELAPSED + 2))
done

echo ""

if [ -n "$CODESPACES" ] || [ -n "$GITHUB_CODESPACES" ]; then
    echo -e "${BLUE}Opening port in GitHub Codespaces...${NC}"
    
    if command -v gh &> /dev/null; then
        # Try gh CLI methods to make port visible
        gh codespace ports visibility $PORT:public 2>/dev/null || gh codespace ports forward $PORT:$PORT 2>/dev/null || true
        echo -e "${GREEN}Port configured with gh CLI${NC}"
    fi
    
    # Display access URL
    CODESPACE_NAME="${CODESPACE_NAME:-unknown}"
    DOMAIN="${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-github.dev}"
    URL="https://${CODESPACE_NAME}-${PORT}.${DOMAIN}/"
    
    echo ""
    echo -e "${GREEN}Access: $URL${NC}"
fi
