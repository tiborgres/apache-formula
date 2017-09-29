{% from "apache/map.jinja" import apache with context %}

include:
  - apache.setup

# adding HTTP and HTTPS ports to firewall
{% set ports_to_be_added = [] %}
{% for site, confitem in salt['pillar.get']('apache:sites', {}).iteritems() %}
  {% if confitem.enabled is defined and confitem.enabled == True and confitem.port is defined %}
    {% if confitem.port not in ports_to_be_added %}
      {% do ports_to_be_added.append(confitem.port) %}
    {% endif %}
  {% endif %}
  {% if confitem.enabled is defined and confitem.enabled == True and confitem.sslport is defined %}
    {% if confitem.sslport not in ports_to_be_added %}
      {% do ports_to_be_added.append(confitem.sslport) %}
    {% endif %}
  {% endif %}
{% endfor %}

# adding firewall rules to existing ruleset
firewall_append:
  iptables.append:
    - table: filter
    - family: ipv4
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dports:
    {% for port in ports_to_be_added %}
        - {{ port }}
    {% endfor %}
    - proto: tcp
    - save: True
