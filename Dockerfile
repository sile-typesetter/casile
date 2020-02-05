ARG casile_tag=master
FROM archlinux AS casile-base

RUN pacman --needed --noconfirm -Syyuq && yes | pacman -Sccq

COPY build-aux/docker-yay-runner.sh /usr/local/bin
RUN docker-yay-runner.sh "--noconfirm --asexplicit -Sq casile-git sile-git"

FROM casile-base AS pandoc-builder

RUN pacman --needed --noconfirm -Sq git base-devel ghc stack

WORKDIR /pandoc-sile
RUN git clone --depth 1 https://github.com/alerque/pandoc.git -b sile-writer-pr .
RUN sed -i -e '10s!--test !!' Makefile
RUN make quick

FROM casile-base AS casile

COPY --from=pandoc-builder /root/.local/bin/pandoc /usr/local/bin

LABEL maintainer="Caleb Maclennan <caleb@alerque.com>"
LABEL version="$casile_tag"

COPY build-aux/docker-entrypoint.sh /usr/local/bin

WORKDIR /data
ENTRYPOINT ["docker-entrypoint.sh"]
