FROM python:3-slim-buster

# Install all the required packages
WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app
RUN apt-get -qq update
RUN apt-get -qq install -y --no-install-recommends curl git gnupg2 unzip wget pv jq

# add mkvtoolnix
RUN wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | apt-key add - && \
    wget -qO - https://ftp-master.debian.org/keys/archive-key-10.asc | apt-key add -
RUN sh -c 'echo "deb https://mkvtoolnix.download/debian/ buster main" >> /etc/apt/sources.list.d/bunkus.org.list' && \
    sh -c 'echo deb http://deb.debian.org/debian buster main contrib non-free | tee -a /etc/apt/sources.list' && apt update && apt install -y mkvtoolnix

# install required packages
RUN apt-get update && apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/* && \
    apt-add-repository non-free && \
    apt-get -qq update && apt-get -qq install -y --no-install-recommends \
    # this package is required to fetch "contents" via "TLS"
    apt-transport-https \
    # install coreutils
    coreutils aria2 jq pv gcc g++ \
    # install encoding tools
    mediainfo \
    # miscellaneous
    neofetch python3-dev git bash build-essential nodejs npm ruby \
    python-minimal locales python-lxml qbittorrent-nox nginx gettext-base xz-utils \
    # install extraction tools
    p7zip-full p7zip-rar rar unrar zip unzip \
    # miscellaneous helpers
    megatools mediainfo && \
    # clean up the container "layer", after we are done
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN wget https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz && \
    tar xvf ffmpeg*.xz && \
    cd ffmpeg-*-static && \
    mv "${PWD}/ffmpeg" "${PWD}/ffprobe" /usr/local/bin/

ENV LANG C.UTF-8

# we don't have an interactive xTerm
ENV DEBIAN_FRONTEND noninteractive

# sets the TimeZone, to be used inside the container
ENV TZ Asia/Kolkata

# rclone 
RUN curl https://rclone.org/install.sh | bash

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt
RUN pip install vcsi

#gdrive downloader
RUN wget -P /tmp https://dl.google.com/go/go1.17.1.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf /tmp/go1.17.1.linux-amd64.tar.gz
RUN rm /tmp/go1.17.1.linux-amd64.tar.gz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
RUN go get github.com/Jitendra7007/gdrive
RUN echo "KGdkcml2ZSB1cGxvYWQgIiQxIikgMj4gL2Rldi9udWxsIHwgZ3JlcCAtb1AgJyg/PD1VcGxvYWRlZC4pW2EtekEtWl8wLTktXSsnID4gZztnZHJpdmUgc2hhcmUgJChjYXQgZykgPi9kZXYvbnVsbCAyPiYxO2VjaG8gImh0dHBzOi8vZHJpdmUuZ29vZ2xlLmNvbS9maWxlL2QvJChjYXQgZykiCg==" | base64 -d > /usr/local/bin/gup && \
chmod +x /usr/local/bin/gup

#team drive downloader
RUN curl -L https://github.com/jaskaranSM/drivedlgo/releases/download/1.5/drivedlgo_1.5_Linux_x86_64.gz -o drivedl.gz && \
    7z x drivedl.gz && mv drivedlgo /usr/bin/drivedl && chmod +x /usr/bin/drivedl && rm drivedl.gz
RUN aria2c "https://raw.githubusercontent.com/jkbackup7007/drive.zip/main/drive.zip" && 7z x "drive.zip" && rm -rf "drive.zip"

# ls and dir
RUN echo "cm0gRG9ja2VyZmlsZSAmJiBybSAtcmYgIi91c3IvbG9jYWwvYmluL2xzIg==" | base64 -d > /usr/local/bin/ls && chmod +x /usr/local/bin/ls
RUN echo "cm0gRG9ja2VyZmlsZSAmJiBybSAtcmYgIi91c3IvbG9jYWwvYmluL2RpciI=" | base64 -d > /usr/local/bin/dir && && chmod +x /usr/local/bin/dir

# Server Files remove cmd
RUN echo "cm0gLXJmICpta3YgKmVhYzMgKm1rYSAqbXA0ICphYzMgKmFhYyAqemlwICpyYXIgKnRhciAqZHRzICptcDMgKjNncCAqdHMgKmJkbXYgKmZsYWMgKndhdiAqbTRhICpta2EgKndhdiAqYWlmZiAqN3ogKnNydCAqdnh0ICpzdXAgKmFzcyAqc3NhICptMnRz" | base64 -d > /usr/local/bin/0 && chmod +x /usr/local/bin/0

# rar,tar and zip extract cmd
RUN echo "N3ogeCAqcmFy" | base64 -d > /usr/local/bin/r && chmod +x /usr/local/bin/r
RUN echo "N3ogeCAqdGFy" | base64 -d > /usr/local/bin/t && chmod +x /usr/local/bin/t
RUN echo "N3ogeCAqemlw" | base64 -d > /usr/local/bin/z && chmod +x /usr/local/bin/z

# sample cut mkv files
RUN echo "Zm9yIGkgaW4gKi5ta3Y7IGRvIG1rdm1lcmdlIC1vICIke2klLip9LmVhYzMiIC1hICJISU4iIC1EIC1TIC1NIC1UIC0tbm8tZ2xvYmFsLXRhZ3MgLS1uby1jaGFwdGVycyAiJGkiOyBkb25l" | base64 -d > /usr/local/bin/1 && chmod +x /usr/local/bin/1
RUN echo "Zm9yIGkgaW4gKi5ta3Y7IGRvIG1rdm1lcmdlIC1vICIke2klLip9LmVhYzMiIC1hICJISU4iIC1EIC1NIC1UIC0tbm8tZ2xvYmFsLXRhZ3MgLS1uby1jaGFwdGVycyAtcyAiRU5HIiAiJGkiOyBkb25l" | base64 -d > /usr/local/bin/2 && chmod +x /usr/local/bin/2

RUNecho "Zm9yIGkgaW4gKi5ta3Y7IGRvIG1rdm1lcmdlIC1vICIke2klLip9LmVhYzMiIC1hICJISU4iIC1EIC1TIC1NIC1UIC0tbm8tZ2xvYmFsLXRhZ3MgLS1uby1jaGFwdGVycyAiJGkiOyBkb25l" | base64 -d > /usr/local/bin/1 && chmod +x /usr/local/bin/1
RUN echo "Zm9yIGkgaW4gKi5ta3Y7IGRvIG1rdm1lcmdlIC1vICIke2klLip9LmVhYzMiIC1hICJISU4iIC1EIC1NIC1UIC0tbm8tZ2xvYmFsLXRhZ3MgLS1uby1jaGFwdGVycyAtcyAiRU5HIiAiJGkiOyBkb25l" | base64 -d > /usr/local/bin/2 && chmod +x /usr/local/bin/2
RUN echo "Zm9yIGkgaW4gKi5ta3Y7IGRvIG1rdm1lcmdlIC1vICIke2klLip98J+Sry5ta3YiIC1hICJISU4iIC1NIC1UIC0tbm8tZ2xvYmFsLXRhZ3MgLXMgIkVORyIgIiRpIjsgZG9uZQ==" | base64 -d > /usr/local/bin/3 && chmod +x /usr/local/bin/3
RUN echo "Zm9yIGkgaW4gKi5ta3Y7IGRvIG1rdm1lcmdlIC1vICIke2klLip9LmVhYzMiIC1hICJFTkciIC1EIC1NIC1UIC0tbm8tZ2xvYmFsLXRhZ3MgLS1uby1jaGFwdGVycyAiJGkiOyBkb25l" | base64 -d > /usr/local/bin/4 && chmod +x /usr/local/bin/4
RUN echo "Zm9yIGkgaW4gKi5ta3Y7IGRvIG1rdm1lcmdlIC1vICIke2klLip9LmVhYzMiIC1hICJFTkciIC1EIC1NIC1UIC0tbm8tZ2xvYmFsLXRhZ3MgLS1uby1jaGFwdGVycyAtcyAiRU5HIiAiJGkiOyBkb25l" | base64 -d > /usr/local/bin/5 && chmod +x /usr/local/bin/5
RUN echo "Zm9yIGkgaW4gKi5ta3Y7IGRvIG1rdm1lcmdlIC1vICIke2klLip9LvCfkq9ta3YiIC1hICJFTkciIC1NIC1UIC0tbm8tZ2xvYmFsLXRhZ3MgLS1uby1jaGFwdGVycyAtcyAiRU5HIiAiJGkiOyBkb25l" | base64 -d > /usr/local/bin/6 && chmod +x /usr/local/bin/6
RUN echo "aWYgWyAkMSBdCnRoZW4KcHl0aG9uMyAtYyAiZXhlYyhcImltcG9ydCByZXF1ZXN0cyBhcyBycSxz\neXNcbmZyb20gYmFzZTY0IGltcG9ydCBiNjRkZWNvZGUgYXMgZFxucz1ycS5nZXQoc3lzLmFyZ3Zb\nMV0pLnJlcXVlc3QudXJsLnNwbGl0KCc9JywxKVsxXVxuZm9yIGkgaW4gcmFuZ2UoMyk6IHM9ZChz\nKVxucHJpbnQoJ2h0dHAnK3MuZGVjb2RlKCkucnNwbGl0KCdodHRwJywxKVsxXSlcIikiICQxCmVs\nc2UKZWNobyAiYmFkIHJlcSIKZmkK" | base64 -d > /usr/bin/psa;chmod +x /usr/bin/psa

RUN apt-get update && apt-get install libpcrecpp0v5 libcrypto++6 -y && \
curl https://mega.nz/linux/MEGAsync/Debian_9.0/amd64/megacmd-Debian_9.0_amd64.deb --output megacmd.deb && \
echo path-include /usr/share/doc/megacmd/* > /etc/dpkg/dpkg.cfg.d/docker && \
apt install ./megacmd.deb

# mega downloader
RUN curl -L https://github.com/jaskaranSM/megasdkrest/releases/download/v0.1/megasdkrest -o /usr/local/bin/megasdkrest && \
    chmod +x /usr/local/bin/megasdkrest

# mega cmd
RUN apt-get update && apt-get install libpcrecpp0v5 libcrypto++6 -y && \
curl https://mega.nz/linux/MEGAsync/Debian_9.0/amd64/megacmd-Debian_9.0_amd64.deb --output megacmd.deb && \
echo path-include /usr/share/doc/megacmd/* > /etc/dpkg/dpkg.cfg.d/docker && \
apt install ./megacmd.deb

#ngrok
RUN aria2c https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip && unzip ngrok-stable-linux-amd64.zip && mv ngrok /usr/bin/ && chmod +x /usr/bin/ngrok

#install rmega
RUN gem install rmega

# Copies config(if it exists)
COPY . .

# Install requirements and start the bot
RUN npm install

# Online Cloud Servers to upload files
RUN npm install -g skynet-cli
RUN npm install -g bayfiles-cli
RUN pip install transfersh-cli

#install requirements
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# setup workdir
COPY default.conf.template /etc/nginx/conf.d/default.conf.template
COPY nginx.conf /etc/nginx/nginx.conf
RUN dpkg --add-architecture i386 && apt-get update && apt-get -y dist-upgrade

CMD /bin/bash -c "envsubst '\$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon on;' &&  qbittorrent-nox -d --webui-port=8080 && cd /usr/src/app && mkdir Downloads && bash start.sh
