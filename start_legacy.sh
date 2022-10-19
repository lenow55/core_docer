sudo -v
sudo systemctl start docker
sudo docker start core
# enable xhost access to the root user
xhost +local:root
# launch core-gui
sleep 5
sudo docker exec -it core core-gui-legacy

