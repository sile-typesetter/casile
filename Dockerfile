ARG casile_tag=master
FROM archlinux AS casile-base

RUN pacman --needed --noconfirm -Syyuq && yes | pacman -Sccq

COPY build-aux/docker-yay-runner.sh /usr/local/bin
RUN docker-yay-runner.sh "--noconfirm --asexplicit -Sq casile-git sile-git"

FROM casile-base AS pandoc-builder

RUN pacman --needed --noconfirm -Sq ghc stack

COPY build-aux/compile-pandoc-sile.sh
RUN compile-pandoc-sile.sh

FROM casile-base AS casile

COPY --from=pandoc-builder /tmp/pandoc/dist/build/pandoc/pandoc /usr/local/bin

LABEL maintainer="Caleb Maclennan <caleb@alerque.com>"
LABEL version="$casile_tag"

COPY build-aux/docker-entrypoint.sh /usr/local/bin

WORKDIR /data
ENTRYPOINT ["docker-entrypoint.sh"]
