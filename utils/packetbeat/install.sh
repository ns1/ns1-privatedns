mkdir packetbeat
curl -s https://github.com/ns1/ns1-privatedns/blob/master/utils/packetbeat/packetbeat.yml > packetbeat/packetbeat.yml
echo 'please add the following service defintion to your docker-compose file. be sure to insert your api token and splunk-url'
  packetbeat:
    image: "docker.elastic.co/beats/packetbeat:6.5.4"
    network_mode: host
    cap_add:
      - NET_RAW
      - NET_ADMIN
    logging:
      driver: splunk
      options:
        splunk-token: "<your splunk api token>"
        splunk-url: "<your splunk url>"
        splunk-format: "json"
        tag: '{{ .ImageName }}/{{ .Name }}/{{ .ID }}'
    volumes:
      - "./packetbeat:/etc/packetbeat"
    command:
      - "--path.config"
      - "/etc/packetbeat"
      - "--strict.perms=false"
      - "-e"'


