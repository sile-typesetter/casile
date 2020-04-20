FROM archlinux:20200306 AS casile
RUN sed -i -e '/IgnorePkg *=/s/^.*$/IgnorePkg = coreutils/' /etc/pacman.conf

# Setup Caleb's hosted Arch repository with prebuilt dependencies
RUN pacman-key --init && pacman-key --populate
RUN sed -i -e '/^.community/{n;n;s!^!\n\[alerque\]\nServer = https://arch.alerque.com/$arch\n!}' /etc/pacman.conf
RUN pacman-key --recv-keys 63CC496475267693 && pacman-key --lsign-key 63CC496475267693

# Freshen all base system packages
RUN pacman --needed --noconfirm -Syuq && yes | pacman -Sccq

# Install Arch CaSILE package (turtles all the way down)
RUN pacman --needed --noconfirm -Syq casile-git remake && yes | pacman -Sccq

# Set at build time, forces Docker's layer caching to reset at this point
ARG VCS_REF=0

# Freshen everything again, makes Docker's layer caching useful to save downloads
RUN pacman --needed --noconfirm -Syuq && yes | pacman -Sccq

# Patch up Arch's Image Magick security settings to let it run Ghostscript
RUN sed -i -e '/pattern="gs"/d' /etc/ImageMagick-7/policy.xml

LABEL maintainer="Caleb Maclennan <caleb@alerque.com>"
LABEL version="$VCS_REF"

COPY build-aux/docker-entrypoint.sh /usr/local/bin

WORKDIR /data
ENTRYPOINT ["docker-entrypoint.sh"]
