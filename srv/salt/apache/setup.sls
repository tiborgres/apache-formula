{% from "apache/map.jinja" import apache with context %}

include:
  - apache.install

setup:
  service.running:
    - name: {{ apache.service }}
    - enable: True
    - require:
      - pkg: {{ apache.server }}
      - file: {{ apache.configfile }}

{{ apache.configfile }}:
  file.managed:
    - template: jinja
    - source:
      - salt://apache/files/{{ salt['grains.get']('os_family') }}/apache-{{ apache.version }}.config.jinja
    - require:
      - pkg: {{ apache.server }}
    - watch_in:
      - module: apache-reload

# disable the 'Listen 443 https' directive in default ssl.conf config file
{{ apache.sslconfigfile }}:
  file.replace:
    - pattern:
        Listen 443 https\n
    - repl:
        \n
    - backup: False
    - require:
      - pkg: {{ apache.modssl }}
    - watch_in:
      - module: apache-reload

{{ apache.vhostdir }}:
  file.directory:
    - makedirs: True
    - require:
      - pkg: {{ apache.server }}
    - watch_in:
      - module: apache-restart

{%- for site, confitem in salt['pillar.get']('apache:sites', {}).iteritems() %}
{% if confitem.enabled is defined and confitem.enabled == True %}

# generate vhost config file
apache_vhost_{{ site }}_conf_file:
  file.managed:
    - name: {{ apache.vhostdir }}/{{ site }}{{ apache.confext }}
    - source: {{ confitem.template_file }}
    - template: jinja
    - context:
        site: {{ site|json }}
        confitem: {{ confitem|json }}
    - makedirs: True
    - mode: 0640
    - user: root
    - group: {{ apache.group }}
    - require:
      - pkg: {{ apache.server }}
    - watch_in:
      - module: apache-reload

# ensure the vhost directory exists
apache_vhost_{{ site }}_directory:
  file.directory:
    - name: {{ confitem.DocumentRoot }}
    - mode: 0750
    - user: {{ apache.user }}
    - group: {{ apache.group }}
    - require:
      - file: apache_vhost_{{ site }}_conf_file
    - watch_in:
      - module: apache-restart

# remove disabled vhosts
{% elif confitem.enabled is defined and confitem.enabled == False %}
apache_vhost_{{ site }}_conf_file:
  file.absent:
    - name: {{ apache.vhostdir }}/{{ site }}{{ apache.confext }}
    - watch_in:
      - module: apache-reload
{% endif %}

{%- endfor %}