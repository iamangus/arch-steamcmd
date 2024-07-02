FROM archlinux

ENV STEAM_HOME="/home/steam" \
    STEAM_USER="steam" \
    STEAM_PATH="/home/steam/.steam/steam" \
    PROTON_VERSION=GE-Proton9-5


RUN \
  # Enable multilib
  printf "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist">> /etc/pacman.conf && \
  # update
  pacman -Syyu --noconfirm && \
  # install packages
  pacman -S --noconfirm glibc lib32-glibc git wget vi xorg-server-xvfb sudo base-devel wine-staging lib32-gnutls lib32-gcc-libs wine-mono winetricks samba && \
  # create steam group
  groupadd -r -g 1000 steam && \
  # create steam user
  useradd -r -m -u 1000 -g 1000 steam && \
  # remove password
  passwd -d steam && \
  # add steam user to wheel
  usermod -aG wheel steam && \
  # wheel stuff
  echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel

USER steam
WORKDIR /home/steam

RUN \
  #install steamcmd
  git clone https://aur.archlinux.org/steamcmd.git && \
  cd steamcmd  && \
  makepkg -si --noconfirm && \
  #initial steamcmd configuration
  steamcmd +quit

RUN mkdir -p compatibilitytools.d/
RUN wget -O - \
    https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${PROTON_VERSION}/${PROTON_VERSION}.tar.gz \
    | tar -xz -C compatibilitytools.d/

RUN chown -R ${USER}:${USER} ${STEAM_HOME}

# Export Proton paths
ENV STEAM_COMPAT_CLIENT_INSTALL_PATH=$STEAM_PATH
ENV PROTON=${STEAM_PATH}/compatibilitytools.d/${PROTON_VERSION}/proton

ENTRYPOINT bash ~/entrypoint.sh
