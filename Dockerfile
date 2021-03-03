# Original credit: https://github.com/jpetazzo/dockvpn
# Original credit: https://github.com/kylemanna/docker-openvpn

# Smallest base image
FROM debian:buster-slim

LABEL maintainer="chris42"

ARG TZ=Europe/Berlin

ENV DEBIAN_FRONTEND=noninteractive

# Install missing software
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y \
    dumb-init \
    easy-rsa \
    iptables \
    libpam-google-authenticator \
    openvpn \
    pamtester \
    qrencode

RUN rm -rf /var/lib/apt/lists/*

# Set timezone and link easyrsa
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
RUN ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin

# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV EASYRSA /usr/share/easy-rsa
ENV EASYRSA_PKI $OPENVPN/pki
ENV EASYRSA_VARS_FILE $OPENVPN/vars

# Prevents refused client connection because of an expired CRL
ENV EASYRSA_CRL_DAYS 3650

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/
