FROM httpd:2.2

RUN apt-get -qq update && apt-get -qq install --yes --no-install-recommends ca-certificates wget locales iputils-ping mc vim \
  && `#----- Install the dependencies -----` \
  && apt-get -qq install --yes --no-install-recommends fontconfig imagemagick
#  && `#----- Deal with ttf-mscorefonts-installer -----` \
#  && apt-get -qq install --yes --no-install-recommends xfonts-utils cabextract \
#  && apt-get -qq install libgsf-1-114 ttf-mscorefonts-installer t1utils unixodbc \
#  && wget --quiet --output-document /tmp/ttf-mscorefonts-installer_3.6_all.deb http://ftp.us.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.6_all.deb \
#  && dpkg --install /tmp/ttf-mscorefonts-installer_3.6_all.deb 2> /dev/null \
#  && rm /tmp/ttf-mscorefonts-installer_3.6_all.deb \
#  && `#----- Install gosu -----` \
#  && wget --quiet --output-document /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
#  && chmod +x /usr/local/bin/gosu \
#  && gosu nobody true

RUN localedef --inputfile ru_RU --force --charmap UTF-8 --alias-file /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG ru_RU.utf8

ADD *.deb /tmp/

ENV PLATFORM_VERSION 83
ENV SERVER_VERSION 8.3.18-1208

RUN dpkg --install /tmp/*.deb 2> /dev/null \
  && rm /tmp/*.deb \
  && mkdir --parent /var/log/1C /home/usr1cv8/.1cv8/1C/1cv8/conf /usr/local/apache2/htdocs/1CBase 
#  && chown --recursive usr1cv8:grp1cv8 /var/log/1C /home/usr1cv8

#COPY container/httpd.conf /usr/local/apache2/conf/httpd.conf
#COPY container/default.vrd /usr/local/apache2/htdocs/1CBase/default.vrd
#COPY container/index.html /usr/local/apache2/htdocs/index.html
#COPY container/GitHub-Mark-32px.png /usr/local/apache2/htdocs/GitHub-Mark-32px.png

#VOLUME /home/usr1cv8
#VOLUME /var/log/1C
#VOLUME /usr/local/apache2/conf/
#VOLUME /usr/local/apache2/htdocs/

EXPOSE 80
