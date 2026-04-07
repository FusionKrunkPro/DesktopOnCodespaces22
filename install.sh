git clone https://github.com/quantumnova87/DesktopOnCodespaces
cd DesktopOnCodespaces
pip install textual
sleep 2
python3 installer.py
docker build -t desktoponcodespaces . --no-cache
cd ..

sudo apt update
sudo apt install -y jq

mkdir -p Save
cp -r DesktopOnCodespaces/root/config/* Save

json_file="DesktopOnCodespaces/options.json"

echo "Starting Docker container..."
if jq ".enablekvm" "$json_file" | grep -q true; then
    docker run -d --name=DesktopOnCodespaces -e PUID=1000 -e PGID=1000 --device=/dev/kvm --security-opt seccomp=unconfined -e TZ=Etc/UTC -e SUBFOLDER=/ -e TITLE=GamingOnCodespaces -p 3000:3000 --shm-size="2gb" -v $(pwd)/Save:/config --restart unless-stopped desktoponcodespaces
else
    docker run -d --name=DesktopOnCodespaces -e PUID=1000 -e PGID=1000 --security-opt seccomp=unconfined -e TZ=Etc/UTC -e SUBFOLDER=/ -e TITLE=GamingOnCodespaces -p 3000:3000 --shm-size="2gb" -v $(pwd)/Save:/config --restart unless-stopped desktoponcodespaces
fi

echo ""
echo "============================================"
echo "Container started. Port 3000 is now open."
echo "============================================"
echo ""

# Try to open port in Codespaces
if [ -n "$CODESPACES" ] || [ -n "$GITHUB_CODESPACES" ]; then
    CODESPACE_NAME="${CODESPACE_NAME:-unknown}"
    DOMAIN="${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-github.dev}"
    URL="https://${CODESPACE_NAME}-3000.${DOMAIN}/"
    echo "Access your desktop at:"
    echo "$URL"
    echo ""
    
    if command -v gh &> /dev/null; then
        echo "Opening port in Codespaces UI..."
        gh codespace ports visibility 3000:public 2>/dev/null || true
        echo "Port should now appear in the Ports tab."
    fi
else
    echo "Access your desktop at: http://localhost:3000/"
fi

echo ""
echo "Installation complete!"
echo "Container logs: docker logs DesktopOnCodespaces"
echo "Stop container: docker stop DesktopOnCodespaces"
