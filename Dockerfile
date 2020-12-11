FROM docker.io/library/archlinux:base-20201108.0.8567 AS casile-base

# Setup Caleb's hosted Arch repository with prebuilt dependencies
RUN pacman-key --init && pacman-key --populate
RUN sed -i  /etc/pacman.conf -e \
	'/^.community/{n;n;s!^!\n\[alerque\]\nServer = https://arch.alerque.com/$arch\n!}'
RUN echo 'keyserver pool.sks-keyservers.net' >> /etc/pacman.d/gnupg/gpg.conf
RUN pacman-key --recv-keys 63CC496475267693 && pacman-key --lsign-key 63CC496475267693

# This is a hack to convince Docker Hub that its cache is behind the times.
# This happens when the contents of our dependencies changes but the base
# system hasn't been refreshed. It's helpful to have this as a separate layer
# because it saves a lot of time for local builds, but it does periodically
# need a poke. Incrementing this when changing dependencies or just when the
# remote Docker Hub builds die should be enough.
ARG DOCKER_HUB_CACHE=0

# Freshen all base system packages
RUN pacman --needed --noconfirm -Syuq && yes | pacman -Sccq

# Install CaSILE run-time dependecies (increment cache var above)
RUN pacman --needed --noconfirm -Syq \
		bc bcprov cpdf entr epubcheck git imagemagick inetutils inkscape \
		java-commons-lang jq kindlegen m4 make moreutils nodejs otf-libertinus \
		pandoc-sile-git pcre pdftk podofo poppler povray rsync sile-git sqlite \
		tex-gyre-fonts texlive-core ttf-hack xcftools yarn yq zint zsh \
		lua-{colors,filesystem,yaml} \
		perl-{yaml,yaml-merge-simple} \
		python-{isbnlib,pandocfilters,ruamel-yaml,usfm2osis-cw-git} \
    && yes | pacman -Sccq

# Patch up Arch's Image Magick security settings to let it run Ghostscript
RUN sed -i -e '/pattern="gs"/d' /etc/ImageMagick-7/policy.xml

FROM casile-base AS casile-builder

RUN pacman --needed --noconfirm -Syq \
		base-devel rust cargo \
	&& yes | pacman -Sccq

# Set at build time, forces Docker's layer caching to reset at this point
ARG VCS_REF=0

COPY ./ /src
WORKDIR /src

# GitHub Actions builder stopped providing git history :(
# See feature request at https://github.com/actions/runner/issues/767
RUN build-aux/bootstrap-docker.sh

RUN ./bootstrap.sh
RUN ./configure
RUN make
RUN make check
RUN make install DESTDIR=/pkgdir

FROM casile-base AS casile

LABEL maintainer="Caleb Maclennan <caleb@alerque.com>"
LABEL version="$VCS_REF"

COPY --from=casile-builder /pkgdir /
RUN casile --version

WORKDIR /data
ENTRYPOINT ["casile"]
