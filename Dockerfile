FROM ubuntu:21.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y libfftw3-dev libfftw3-3 xvfb qsstv pulseaudio build-essential git libsamplerate0-dev alsa-utils xvfb python3 python3-pip && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/miweber67/spyserver_client.git && cd spyserver_client && make && cp ss_client /usr/bin/ss_iq
RUN cd / && git clone https://github.com/F5OEO/csdr && cd csdr && make && make install
RUN mkdir -p /root/.config/ON4QZ/
COPY qsstv_9.0.conf /root/.config/ON4QZ/qsstv_9.0.conf
COPY run.sh /run.sh
RUN chmod a+x /run.sh
RUN adduser root pulse-access
RUN pip3 install Mastodon.py watchdog
COPY poster.py /poster.py
ENTRYPOINT /run.sh
VOLUME /images