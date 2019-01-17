mkdir packetbeat
curl -s https://github.com/ns1/ns1-privatedns/blob/master/utils/packetbeat/packetbeat.yml > packetbeat/packetbeat.yml
echo 'please add the following service defintion to your docker-compose file
  packetbeat:
    image: "docker.elastic.co/beats/packetbeat:6.5.4"
    net: host
    cap_add:
      - NET_RAW
      - NET_ADMIN
    log_driver: splunk
    log_opt:
      splunk-token: "fill this in appropriately"
      splunk-url: "fill this in appropriately"
      splunk-format: "json"
      tag: '{{ .ImageName }}/{{ .Name }}/{{ .ID }}'
    volumes:
      - "./packetbeat:/etc/packetbeat"
    command:
      - "--path.config"
      - "/etc/packetbeat"
      - "--strict.perms=false"
      - "-e"'


