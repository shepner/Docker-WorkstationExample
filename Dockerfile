FROM ubuntu:trusty

###########################################################################################
# general settings
ENV \
  DEBIAN_FRONTEND=noninteractive
  #LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

###########################################################################################
# user setup
ENV PUSR=docker

ENV \
  HOME="/$PUSR" \
  PUID=1003 \
  PGID=1100 \
  TERM=xterm

RUN \
  groupadd -r -g $PGID $PUSR \
  && useradd -r -d $HOME -u $PUID -g $PGID -s /bin/bash $PUSR \
  && mkdir -p $HOME \
  && chown -R $PUID:$PGID $HOME

###########################################################################################
# prep to install software
RUN \
  apt-get update \
  && apt-get -y upgrade \
  && apt-get -y dist-upgrade

###########################################################################################
# general utils
RUN apt-get install -y wget
#    python \
#    python-numpy \
#    unzip 
    
###########################################################################################
# X
RUN apt-get install -y Xvfb

ENV DISPLAY=:1

###########################################################################################
# VNC
# noVNC webport, connect via http://IP:6900/?password=vncpassword

# VNC server
RUN apt-get install -y x11vnc

ENV \
  VNC_COL_DEPTH=24 \
  VNC_RESOLUTION=1280x1024 \
  VNC_VIEW_ONLY=false

# VNC web client
RUN \
  apt-get install -y \
    git \
    python3 \
    python-numpy \
  && git clone https://github.com/novnc/noVNC.git $HOME/noVNC \
  && ln -s $HOME/noVNC/vnc_custom.html $HOME/noVNC/index.html \
  && git clone https://github.com/novnc/websockify.git $HOME/noVNC/utils/websockify

ADD vnc_custom.html $HOME/noVNC/vnc_custom.html

RUN chown -R $PUID:$PGID $HOME

ENV NO_VNC_HOME=$HOME/noVNC
  
EXPOSE 6080

###########################################################################################
# window manager
RUN apt-get install -y openbox

###########################################################################################
# window manager application menu
RUN apt-get install -y menu

###########################################################################################
# firefox
RUN apt-get install -y firefox

###########################################################################################
# installation cleanup
RUN \
  apt-get autoclean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*

###########################################################################################
# startup tasks
ADD startup.sh $HOME/startup.sh

RUN \
  chmod 555 $HOME/startup.sh \
  && chown -R $PUID:$PGID $HOME

USER $PUSR:$PGID

CMD $HOME/startup.sh
