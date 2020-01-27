ARG casile_tag=master
FROM archlinux AS casile-base

RUN pacman --needed --noconfirm -Syyuq && yes | pacman -Sccq

COPY build-aux/docker-yay-runner.sh /usr/local/bin
RUN docker-yay-runner.sh "--noconfirm --asexplicit -S git base-devel yay"

FROM casile-base AS pandoc-builder

FROM casile-base AS casile

LABEL maintainer="Caleb Maclennan <caleb@alerque.com>"
LABEL version="$casile_tag"

COPY build-aux/docker-entrypoint.sh /usr/local/bin

WORKDIR /data
ENTRYPOINT ["docker-entrypoint.sh"]
