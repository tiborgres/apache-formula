{% from "apache/map.jinja" import apache with context %}

include:
  - apache.setup

{%- for site, confcert in salt['pillar.get']('apache:sites', {}).iteritems() %}

# deploy SSL KEY file
{% if confcert.sslenabled is defined and confcert.sslenabled == True and confcert.SSLCertificateKeyFile is defined and confcert.SSLCertificateKeyFile_content is defined %}
apache_cert_config_{{ site }}_key_file:
  file.managed:
    - name: {{ confcert.SSLCertificateKeyFile }}
    - contents_pillar: apache:sites:{{ site }}:SSLCertificateKeyFile_content
    - makedirs: True
    - mode: 0640
    - user: root
    - group: {{ apache.group }}
    - require:
      - user: {{ apache.user }}
      - group: {{ apache.group }}
    - watch_in:
      - module: apache-restart
{% endif %}

# deploy SSL CRT file
{% if confcert.sslenabled is defined and confcert.sslenabled == True and confcert.SSLCertificateFile is defined and confcert.SSLCertificateFile_content is defined %}
apache_cert_config_{{ site }}_cert_file:
  file.managed:
    - name: {{ confcert.SSLCertificateFile }}
    - contents_pillar: apache:sites:{{ site }}:SSLCertificateFile_content
    - makedirs: True
    - mode: 0640
    - user: root
    - group: {{ apache.group }}
    - require:
      - user: {{ apache.user }}
      - group: {{ apache.group }}
    - watch_in:
      - module: apache-restart
{% endif %}

# deploy SSL CA CRT file
{% if confcert.sslenabled is defined and confcert.sslenabled == True and confcert.SSLCACertificateFile is defined and confcert.SSLCACertificateFile_content is defined %}
apache_cert_config_{{ site }}_bundle_file:
  file.managed:
    - name: {{ confcert.SSLCACertificateFile }}
    - contents_pillar: apache:sites:{{ site }}:SSLCACertificateFile_content
    - makedirs: True
    - mode: 0640
    - user: root
    - group: {{ apache.group }}
    - require:
      - user: {{ apache.user }}
      - group: {{ apache.group }}
    - watch_in:
      - module: apache-restart
{% endif %}
{%- endfor %}
