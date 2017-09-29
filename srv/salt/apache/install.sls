{% from "apache/map.jinja" import apache with context %}

include:
  - apache

# in case we are dealing with CentOS6 and HTTPD2.4 pkg (httpd24-httpd defined in posam.sls pillar)
{% if apache.server == 'httpd24-httpd' %}
centos-release-scl:
  pkg.installed
/etc/httpd:
  file.symlink:
    - target: /opt/rh/httpd24/root/etc/httpd
{{ apache.wwwdir }}/html:
  file.directory:
    - user: root
    - group: root
    - mode: 0755
    - makedirs: True
    - watch_in:
      - module: apache-restart
{% endif %}

install:
  pkg.installed:
    - name: {{ apache.server }}
    - order: 2
{% if apache.server == 'httpd24-httpd' %}

  # repo, rpm or web-based pkg installation
  {% if apache.install_method == 'rpm' or apache.install_method == 'web' %}
    - sources:
      - {{ apache.server}}: {{ apache.rpm }}
  {% endif %}
    - require:
      - pkg: centos-release-scl
      - file: /etc/httpd
      - file: {{ apache.wwwdir }}/html
{% elif apache.install_method == 'rpm' or apache.install_method == 'web' %}
    - sources:
      - {{ apache.server}}: {{ apache.rpm }}
{% endif %}

{% for site, confitem in salt['pillar.get']('apache:sites', {}).iteritems() %}
{% if confitem.sslenabled is defined and confitem.sslenabled == True %}
install_mod_ssl:
  pkg.installed:
    - order: 2
    - name: {{ apache.modssl }}
  {% if apache.server == 'httpd24-httpd' and (apache.install_method == 'rpm' or apache.install_method == 'web') %}
    - sources:
      - {{ apache.modssl }}: {{ apache.modsslrpm }} # modssl version must be compatible with apache
  {% elif apache.install_method == 'rpm' or apache.install_method == 'web' %}
    - sources:
      - {{ apache.modssl }}: {{ apache.modsslrpm }}
  {% endif %}
    - require:
      - pkg: {{ apache.server }}
    - watch_in:
      - module: apache-restart
{% endif %}
{%- endfor %}
