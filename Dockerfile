FROM ubuntu:quantal

MAINTAINER Stuart P. Bentley <stuart@testtrack4.com> (@stuartpb)

RUN apt-get update && apt-get upgrade

RUN apt-get install ntp git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev

RUN apt-get install pwgen

RUN curl http://miniupnp.free.fr/files/download.php?file=miniupnpc-1.8.tar.gz |tar -xz
RUN cd miniupnpc-1.8/
RUN make && make install
RUN cd .. && rm -r miniupnpc-1.8

RUN git clone https://github.com/dogecoin/dogecoin
RUN cd dogecoin/src
RUN make -f makefile.unix USE_UPNP=1 USE_QRCODE=1 && strip dogecoind

RUN useradd -mN dogecoin
RUN chmod 0700 /home/dogecoin
RUN mkdir /home/dogecoin/bin
RUN cp dogecoind /home/dogecoin/bin/dogecoind
ADD dogecoin.conf /home/.dogecoin/dogecoin.conf
RUN sed -ine s/^rpcpassword=$/rpcpassword=`pwgen -s 44`/ /home/.dogecoin/dogecoin.conf
RUN chmod 0600 /home/.dogecoin/dogecoin.conf
RUN chown -R dogecoin:users /home/dogecoin/bin

RUN cd .. && rm -r dogecoin

USER dogecoin
WORKDIR /home/dogecoin
ENTRYPOINT ['/home/dogecoin/bin/dogecoind']
