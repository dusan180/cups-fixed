
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

bashio::log.info "Starting HP USB URI watchdog"

(
  while true; do
    sleep 30

    detected_uri="$(hp-probe -busb 2>/dev/null | awk '/hp:\/usb\// {print $1; exit}')"

    if [ -z "$detected_uri" ]; then
      continue
    fi

    current_uri="$(lpstat -v HP_LaserJet_Professional_P1102 2>/dev/null | sed 's/^device for HP_LaserJet_Professional_P1102: //')"

    if [ -n "$current_uri" ] && [ "$current_uri" != "$detected_uri" ]; then
      bashio::log.warning "HP printer URI changed: ${current_uri} -> ${detected_uri}"
      lpadmin -p HP_LaserJet_Professional_P1102 -v "$detected_uri"
    fi
  done
) &

bashio::log.info "Starting CUPS server as CMD from S6"

cupsd -f
