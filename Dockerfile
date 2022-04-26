FROM python:3-slim-buster

# Install all the required packages
WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app
RUN apt-get -qq update
RUN apt-get -qq install -y curl git gnupg2 unzip wget pv jq build-essential make python

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
    neofetch python3-dev git bash ruby \
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

#COPY requirements.txt .
#RUN pip3 install --no-cache-dir -r requirements.txt

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

#local host downloader - bot ke storage ki files ko leech ya mirror ke liye http://localhost:8000/
RUN echo "cHl0aG9uMyAtbSBodHRwLnNlcnZlcg==" | base64 -d > /usr/bin/l;chmod +x /usr/bin/l
RUN echo "ZWNobyBodHRwOi8vbG9jYWxob3N0OjgwMDAvJChweXRob24zIC1jICdmcm9tIHVybGxpYi5wYXJzZSBpbXBvcnQgcXVvdGU7IGltcG9ydCBzeXM7IHByaW50KHF1b3RlKHN5cy5hcmd2WzFdKSknICIkMSIpCg==" | base64 -d > /usr/bin/g;chmod +x /usr/bin/g

#heroku files downloader - bot ki files ko https://.herokuapp.com ke through download karna
RUN echo "cGtpbGwgZ3VuaWNvcm47cHl0aG9uMyAtbSBodHRwLnNlcnZlciAiJFBPUlQiO3B5dGhvbjMgLW0gaHR0cC5zZXJ2ZXIgIiRQT1JUIiAmJiBweXRob24zIC1tIGh0dHAuc2VydmVy" | base64 -d > /usr/local/bin/heroku && chmod +x /usr/local/bin/heroku
RUN echo "ZWNobyAkQkFTRV9VUkxfT0ZfQk9ULyQocHl0aG9uMyAtYyAnZnJvbSB1cmxsaWIucGFyc2UgaW1wb3J0IHF1b3RlOyBpbXBvcnQgc3lzOyBwcmludChxdW90ZShzeXMuYXJndlsxXSkpJyAiJDEiKQ==" | base64 -d > /usr/local/bin/hl && chmod +x /usr/local/bin/hl

#ls and dir
RUN echo "cm0gRG9ja2VyZmlsZSAmJiBybSBsb2cudHh0ICYmIHJtIC1yZiAiL3Vzci9sb2NhbC9iaW4vbHMi" | base64 -d > /usr/local/bin/ls && chmod +x /usr/local/bin/ls
RUN echo "cm0gRG9ja2VyZmlsZSAmJiBybSBsb2cudHh0ICYmIHJtIC1yZiAiL3Vzci9sb2NhbC9iaW4vbHMi" | base64 -d > /usr/local/bin/dir && chmod +x /usr/local/bin/dir

#gdtot batch script
RUN echo "IyEvdXNyL2Jpbi9lbnYgYmFzaAppZiBbWyAiJCoiIF1dCnRoZW4KcHl0aG9uMyAtYyAiZXhlYyhc\nImltcG9ydCBzeXMsc3VicHJvY2VzcyxyZVxuZj1yZS5maW5kYWxsKHInaHR0cHM/Oi4qZ2R0b3Qu\nKlxTKycsJ1xcXFxuJy5qb2luKHN5cy5hcmd2WzE6XSksZmxhZ3M9cmUuTSlcbmZvciBpIGluIGY6\nc3VicHJvY2Vzcy5ydW4oWydnZHRvdCcsICclcycgJWldKVwiKSIgIiQqIgplbHNlCmVjaG8gImJh\nZCByZXEiCmZpCg==" | base64 -d > /usr/bin/gd;chmod +x /usr/bin/gd

RUN echo "IyEvYmluL2Jhc2gKaWYgWyAiJCoiIF0KdGhlbgpweXRob24zIC1jICJleGVjKFwiaW1wb3J0IHJlcXVlc3RzIGFzIHJxLHN5cyxyZVxuZnJvbSBiYXNlNjQgaW1wb3J0IGI2NGRlY29kZSBhcyBkXG5zPVsnaHR0cCcrZChkKGQocnEuZ2V0KGkpLnJlcXVlc3QudXJsLnNwbGl0KCc9JywxKVsxXSkpKS5kZWNvZGUoKS5yc3BsaXQoJ2h0dHAnLDEpWzFdIGZvciBpIGluIHJlLmZpbmRhbGwocidodHRwcz86Ly8uKnNpcmlnYW4uKi9bYS16QS1aMC05XSsnLCcnLmpvaW4oc3lzLmFyZ3ZbMTpdKSldXG5wcmludCgnXFxcblxcXG4nLmpvaW4ocykpXCIpIiAiJCoiCmVsc2UKZWNobyAiYmFkIHJlcSIKZmkK" | base64 -d > /usr/bin/psa;chmod +x /usr/bin/psa
RUN echo "bWt2bWVyZ2UgLW8gJzJtaW4ubWt2JyAqbWt2IC0tc3BsaXQgcGFydHM6MDA6MDA6MDAtMDA6MDI6MDA=" | base64 -d > /usr/local/bin/2min && chmod +x /usr/local/bin/2min
RUN echo "N3ogeCAqcmFy" | base64 -d > /usr/local/bin/r && chmod +x /usr/local/bin/r
RUN echo "N3ogeCAqdGFy" | base64 -d > /usr/local/bin/t && chmod +x /usr/local/bin/t
RUN echo "N3ogeCAqemlw" | base64 -d > /usr/local/bin/z && chmod +x /usr/local/bin/z
RUN echo "Zm9yIGkgaW4gKi5ta3Y7IGRvIG1rdm1lcmdlIC1vICIke2klLip9LmVhYzMiIC1hICJISU4iIC1EIC1TIC1NIC1UIC0tbm8tZ2xvYmFsLXRhZ3MgLS1uby1jaGFwdGVycyAiJGkiOyBkb25l" | base64 -d > /usr/local/bin/1 && chmod +x /usr/local/bin/1
RUN echo "Zm9yIGkgaW4gKi5ta3Y7IGRvIG1rdm1lcmdlIC1vICIke2klLip9LmVhYzMiIC1hICJISU4iIC1EIC1NIC1UIC0tbm8tZ2xvYmFsLXRhZ3MgLS1uby1jaGFwdGVycyAtcyAiRU5HIiAiJGkiOyBkb25l" | base64 -d > /usr/local/bin/2 && chmod +x /usr/local/bin/2
RUN echo "Zm9yIGkgaW4gKi5ta3Y7IGRvIG1rdm1lcmdlIC1vICIke2klLip98J+Sry5ta3YiIC1hICJISU4iIC1NIC1UIC0tbm8tZ2xvYmFsLXRhZ3MgLXMgIkVORyIgIiRpIjsgZG9uZQ==" | base64 -d > /usr/local/bin/3 && chmod +x /usr/local/bin/3
RUN echo "Zm9yIGkgaW4gKi5ta3Y7IGRvIG1rdm1lcmdlIC1vICIke2klLip9LmVhYzMiIC1hICJFTkciIC1EIC1NIC1UIC0tbm8tZ2xvYmFsLXRhZ3MgLS1uby1jaGFwdGVycyAiJGkiOyBkb25l" | base64 -d > /usr/local/bin/4 && chmod +x /usr/local/bin/4
RUN echo "Zm9yIGkgaW4gKi5ta3Y7IGRvIG1rdm1lcmdlIC1vICIke2klLip9LmVhYzMiIC1hICJFTkciIC1EIC1NIC1UIC0tbm8tZ2xvYmFsLXRhZ3MgLS1uby1jaGFwdGVycyAtcyAiRU5HIiAiJGkiOyBkb25l" | base64 -d > /usr/local/bin/5 && chmod +x /usr/local/bin/5
RUN echo "Zm9yIGkgaW4gKi5ta3Y7IGRvIG1rdm1lcmdlIC1vICIke2klLip9LvCfkq9ta3YiIC1hICJFTkciIC1NIC1UIC0tbm8tZ2xvYmFsLXRhZ3MgLS1uby1jaGFwdGVycyAtcyAiRU5HIiAiJGkiOyBkb25l" | base64 -d > /usr/local/bin/6 && chmod +x /usr/local/bin/6
RUN echo "cm0gLXJmICpta3YgKmVhYzMgKm1rYSAqbXA0ICphYzMgKmFhYyAqemlwICpyYXIgKnRhciAqZHRzICptcDMgKjNncCAqdHMgKmJkbXYgKmZsYWMgKndhdiAqbTRhICpta2EgKndhdiAqYWlmZiAqN3ogKnNydCAqdnh0ICpzdXAgKmFzcyAqc3NhICptMnRz" | base64 -d > /usr/local/bin/0 && chmod +x /usr/local/bin/0
RUN echo "bWt2bWVyZ2UgLW8gJzFtaW4ubWt2JyAqbWt2IC0tc3BsaXQgcGFydHM6MDA6MDA6MDAtMDA6MDE6MDA=" | base64 -d > /usr/local/bin/1min && chmod +x /usr/local/bin/1min
#RUN apt-get update && apt-get install libpcrecpp0v5 libcrypto++6 -y && \
#curl https://mega.nz/linux/MEGAsync/Debian_9.0/amd64/megacmd-Debian_9.0_amd64.deb --output megacmd.deb && \
#echo path-include /usr/share/doc/megacmd/* > /etc/dpkg/dpkg.cfg.d/docker && \
#apt install ./megacmd.deb

#mega downloader
#RUN curl -L https://github.com/jaskaranSM/megasdkrest/releases/download/v0.1/megasdkrest -o /usr/local/bin/megasdkrest && \
#    chmod +x /usr/local/bin/megasdkrest

# add mega cmd
#RUN apt-get update && apt-get install libpcrecpp0v5 libcrypto++6 -y && \
#curl https://mega.nz/linux/MEGAsync/Debian_9.0/amd64/megacmd-Debian_9.0_amd64.deb --output megacmd.deb && \
#echo path-include /usr/share/doc/megacmd/* > /etc/dpkg/dpkg.cfg.d/docker && \
#apt install ./megacmd.deb

#ngrok
#RUN aria2c https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip && unzip ngrok-stable-linux-amd64.zip && mv ngrok /usr/bin/ && chmod +x /usr/bin/ngrok

#install rmega
#RUN gem install rmega

# Copies config(if it exists)
COPY . .

# Install requirements and start the bot
#install requirements
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt
RUN curl -sL https://deb.nodesource.com/setup_14.x | sh
RUN apt-get install -y nodejs
RUN npm install
CMD node server
# setup workdir
#COPY default.conf.template /etc/nginx/conf.d/default.conf.template
#COPY nginx.conf /etc/nginx/nginx.conf
#RUN dpkg --add-architecture i386 && apt-get update && apt-get -y dist-upgrade

#CMD /bin/bash -c "envsubst '\$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon on;' &&  qbittorrent-nox -d --webui-port=8080 && cd /usr/src/app && mkdir Downloads && bash start.sh
