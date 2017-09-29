{% from "apache/map.jinja" import apache with context %}

apache-uninstall:

# remove HTTP and HTTPS ports from firewall
  {% set ports_to_be_removed = [] %}
  {% for site, confitem in salt['pillar.get']('apache:sites', {}).iteritems() %}
    {% if confitem.enabled is defined and confitem.enabled == True and confitem.port is defined %}
      {% if confitem.port not in ports_to_be_removed %}
        {% do ports_to_be_removed.append(confitem.port) %}
      {% endif %}
    {% endif %}
    {% if confitem.enabled is defined and confitem.enabled == True and confitem.sslport is defined %}
      {% if confitem.sslport not in ports_to_be_removed %}
        {% do ports_to_be_removed.append(confitem.sslport) %}
      {% endif %}
    {% endif %}
  {% endfor %}
  iptables.delete:
      - table: filter
      - family: ipv4
      - chain: INPUT
      - jump: ACCEPT
      - match: state
      - connstate: NEW
      - dports:
      {% for port in ports_to_be_removed %}
          - {{ port }}
      {% endfor %}
      - proto: tcp
      - save: True

# ensure the service is off and disabled
  service.dead:
    - name: {{ apache.service }}
    - enable: False

# remove packages httpd and mod_ssl
  pkg.removed:
    - pkgs:
      - {{ apache.server }}
      - {{ apache.modssl }}

