{% from "apache/map.jinja" import apache with context %}

apache:
  group.present:
    - name: {{ apache.group }}
    - system: True
  user.present:
    - name: {{ apache.user }}
    - gid: {{ apache.group }}
    - system: True
    - home: /var/www
    - shell: /sbin/nologin
    - require:
      - group: {{ apache.group }}
    - require_in:
      - pkg: {{ apache.server }}
apache-reload:
  module.wait:
    - name: service.reload
    - m_name: {{ apache.service }}
    - order: 3
apache-restart:
  module.wait:
    - name: service.restart
    - m_name: {{ apache.service }}
    - order: 1  # priority over apache-reload