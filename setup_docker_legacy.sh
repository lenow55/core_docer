#/bin/bash
sudo -v
sudo systemctl start docker
sudo docker run -itd --name core -e DISPLAY \
	-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
	-v /home/nemo/core_schema:/root/core_schema:rw \
	--privileged core
# enable xhost access to the root user
xhost +local:root
# launch core-gui
sudo docker exec -it core core-gui-legacy
