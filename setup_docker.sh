#/bin/bash
sudo -v
sudo systemctl start docker
# build image
sudo docker build -t core .
# run image
sudo docker run -itd --name core -e DISPLAY \
	-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
	-v ~/core_schema:/root/core_schema:rw \
	--privileged core
