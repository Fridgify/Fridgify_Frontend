FROM cirrusci/flutter:stable-web

USER root
RUN groupadd -r fridgify && useradd --no-log-init -r -g fridgify fridgify
RUN cd /

RUN mkdir /web
RUN chown fridgify /web

WORKDIR /web
ADD ./fridgify /web

RUN flutter channel beta
RUN flutter upgrade

RUN pub global activate dhttpd

RUN flutter pub get
RUN flutter pub upgrade
RUN flutter config --enable-web
RUN flutter build web

EXPOSE 1420
CMD pub global run dhttpd --host=0.0.0.0 --port=1420 --path=./build/web/
