#!/usr/bin/with-contenv bashio

ulimit -n 524288

until [ -e /var/run/avahi-daemon/socket ]; do
  sleep 1s
done

bashio::log.info "Preparing directories"
if [ ! -d /config/cups ]; then cp -v -R /etc/cups /config; fi
rm -v -fR /etc/cups

ln -v -s /config/cups /etc/cups
bashio::log.info "Preparing HP plugin state"
mkdir -p /config/hp

rm -rf /var/lib/hp

ln -s /config/hp /var/lib/hp

mkdir -p /config/hplip-prnt-plugins

rm -rf /usr/share/hplip/prnt/plugins

ln -s /config/hplip-prnt-plugins /usr/share/hplip/prnt/plugins


bashio::log.info "Starting CUPS server as CMD from S6"

cupsd -f
