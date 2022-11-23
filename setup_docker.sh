#/bin/bash
sudo -v
sudo systemctl start docker
# build image
sudo docker build -t core .
# run image
# создаю папку для двухсторонней связи
# с контейнером

dirname=$HOME/core_schema
if [ -d $dirname ]
then
    echo "Directory already exists"
else
    mkdir $dirname
    echo "$dirname Directory created"
fi

sudo docker run -itd --name core -e DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v $dirname:/root/core_schema:rw \
    --privileged core
