#/bin/bash
sudo -v
sudo systemctl start docker
# build image
sudo docker build -t core .
# run image
# создаю папку для двухсторонней связи
# с контейнером
dir = ~/core_schema
if [[ ! -e $dir ]]; then
    mkdir $dir
elif [[ ! -d $dir ]]; then
    echo "$dir already exists but is not a directory" 1>&2
fi

sudo docker run -itd --name core -e DISPLAY \
	-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
	-v ~/core_schema:/root/core_schema:rw \
	--privileged core
