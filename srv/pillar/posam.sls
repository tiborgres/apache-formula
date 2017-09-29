apache:
  lookup:
    install_method: web  # can be one of these: 'repo', 'rpm', 'web'
    {% if salt['grains.get']('osfinger') == 'CentOS-6' %}
    server: httpd24-httpd
    service: httpd24-httpd

    # according to 'install_method' the rpm source can be defined as:
    # for 'rpm' method: salt://apache/files/RPMS/httpd24-httpd-2.4.25-8.el6.x86_64.rpm
    # for 'web' method: http://mirror.centos.org/centos/6/sclo/x86_64/rh/httpd24/httpd24-httpd-2.4.25-8.el6.x86_64.rpm
    #rpm: salt://apache/files/RPMS/httpd24-httpd-2.4.25-8.el6.x86_64.rpm
    rpm: http://mirror.centos.org/centos/6/sclo/x86_64/rh/httpd24/httpd24-httpd-2.4.25-8.el6.x86_64.rpm
    modssl: httpd24-mod_ssl
    #modsslrpm: salt://apache/files/RPMS/httpd24-mod_ssl-2.4.25-8.el6.x86_64.rpm
    modsslrpm: http://mirror.centos.org/centos-6/6/sclo/x86_64/rh/httpd24/httpd24-mod_ssl-2.4.25-8.el6.x86_64.rpm
    logdir: /var/log/httpd24
    {%- set logdir = '/var/log/httpd24' %}  # for reuse in pillar (need to be rewritten)
    {% else %}
    server: httpd
    service: httpd
    #rpm: salt://apache/files/RPMS/httpd-2.4.6-67.el7.centos.2.x86_64.rpm
    rpm: http://mirror.centos.org/centos/7/updates/x86_64/Packages/httpd-2.4.6-67.el7.centos.2.x86_64.rpm
    #modsslrpm: salt://apache/files/RPMS/mod_ssl-2.4.6-67.el7.centos.2.x86_64.rpm
    modsslrpm: http://mirror.centos.org/centos/7/updates/x86_64/Packages/mod_ssl-2.4.6-67.el7.centos.2.x86_64.rpm
    logdir: /var/log/httpd
    {%- set logdir = '/var/log/httpd' %}  # for reuse in pillar (need to be rewritten)
    {% endif %}

    user: apache
    group: apache

    vhostdir: /etc/httpd/vhosts.d
    confdir: /etc/httpd/conf.d
    confext: .conf
    wwwdir: /var/www/html

    version: '2.4'

  sites:
  {%- set site1 = 'posam1.internal' %} # example of setting variable for reuse in this context
    {{ site1 }}:
      template_file: salt://apache/files/vhost_templates/standard.tmpl
      enabled: True

      interface: '*'
      port: '80'

      ServerName: {{ site1 }}
      ServerAlias: www.{{ site1 }}
      ServerAdmin: webmaster@{{ site1 }}
      DocumentRoot: /var/www/{{ site1 }}

      LogLevel: warn
      ErrorLog: {{ logdir }}/{{ site1 }}.errorlog
      CustomLog: {{ logdir }}/{{ site1 }}.accesslog combined

      # ProxyPassReverse syntax: "Source", "Target"
      ProxyPassReverse:
        /test1: http://posam1.internal/test1
        /test2: http://posam1.internal/test2

    posam2.internal:
      template_file: salt://apache/files/vhost_templates/standard.tmpl
      enabled: True
      sslenabled: True

      interface: '*'
      port: '80'
      sslport: '443'

      ServerName: posam2.internal
      ServerAlias: www.posam2.internal

      ServerAdmin: webmaster@posam2.internal

      DocumentRoot: /var/www/posam2.internal

      LogLevel: warn
      ErrorLog: {{ logdir }}/posam2.internal.errorlog
      CustomLog: {{ logdir }}/posam2.internal.accesslog combined

      ProxyPassReverse:
        /test3: http://posam2.internal/test3
        /test4: http://posam2.internal/test4

      # SSL stuff and certificates
      SSLProxyEngine: on
      SSLCertificateFile: /etc/pki/tls/certs/posam2.internal.crt
      SSLCertificateKeyFile: /etc/pki/tls/private/posam2.internal.key
      SSLCACertificateFile: /etc/pki/tls/certs/posam2.internal.intermediate

      SSLCertificateFile_content: |
        -----BEGIN CERTIFICATE-----
        MIICUTCCAfugAwIBAgIBADANBgkqhkiG9w0BAQQFADBXMQswCQYDVQQGEwJDTjEL
        MAkGA1UECBMCUE4xCzAJBgNVBAcTAkNOMQswCQYDVQQKEwJPTjELMAkGA1UECxMC
        VU4xFDASBgNVBAMTC0hlcm9uZyBZYW5nMB4XDTA1MDcxNTIxMTk0N1oXDTA1MDgx
        NDIxMTk0N1owVzELMAkGA1UEBhMCQ04xCzAJBgNVBAgTAlBOMQswCQYDVQQHEwJD
        TjELMAkGA1UEChMCT04xCzAJBgNVBAsTAlVOMRQwEgYDVQQDEwtIZXJvbmcgWWFu
        ZzBcMA0GCSqGSIb3DQEBAQUAA0sAMEgCQQCp5hnG7ogBhtlynpOS21cBewKE/B7j
        V14qeyslnr26xZUsSVko36ZnhiaO/zbMOoRcKK9vEcgMtcLFuQTWDl3RAgMBAAGj
        gbEwga4wHQYDVR0OBBYEFFXI70krXeQDxZgbaCQoR4jUDncEMH8GA1UdIwR4MHaA
        FFXI70krXeQDxZgbaCQoR4jUDncEoVukWTBXMQswCQYDVQQGEwJDTjELMAkGA1UE
        CBMCUE4xCzAJBgNVBAcTAkNOMQswCQYDVQQKEwJPTjELMAkGA1UECxMCVU4xFDAS
        BgNVBAMTC0hlcm9uZyBZYW5nggEAMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQEE
        BQADQQA/ugzBrjjK9jcWnDVfGHlk3icNRq0oV7Ri32z/+HQX67aRfgZu7KWdI+Ju
        Wm7DCfrPNGVwFWUQOmsPue9rZBgO
        -----END CERTIFICATE-----

      SSLCertificateKeyFile_content: |
        -----BEGIN PRIVATE KEY-----
        MIICUTCCAfugAwIBAgIBADANBgkqhkiG9w0BAQQFADBXMQswCQYDVQQGEwJDTjEL
        MAkGA1UECBMCUE4xCzAJBgNVBAcTAkNOMQswCQYDVQQKEwJPTjELMAkGA1UECxMC
        VU4xFDASBgNVBAMTC0hlcm9uZyBZYW5nMB4XDTA1MDcxNTIxMTk0N1oXDTA1MDgx
        NDIxMTk0N1owVzELMAkGA1UEBhMCQ04xCzAJBgNVBAgTAlBOMQswCQYDVQQHEwJD
        TjELMAkGA1UEChMCT04xCzAJBgNVBAsTAlVOMRQwEgYDVQQDEwtIZXJvbmcgWWFu
        ZzBcMA0GCSqGSIb3DQEBAQUAA0sAMEgCQQCp5hnG7ogBhtlynpOS21cBewKE/B7j
        V14qeyslnr26xZUsSVko36ZnhiaO/zbMOoRcKK9vEcgMtcLFuQTWDl3RAgMBAAGj
        gbEwga4wHQYDVR0OBBYEFFXI70krXeQDxZgbaCQoR4jUDncEMH8GA1UdIwR4MHaA
        FFXI70krXeQDxZgbaCQoR4jUDncEoVukWTBXMQswCQYDVQQGEwJDTjELMAkGA1UE
        CBMCUE4xCzAJBgNVBAcTAkNOMQswCQYDVQQKEwJPTjELMAkGA1UECxMCVU4xFDAS
        BgNVBAMTC0hlcm9uZyBZYW5nggEAMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQEE
        BQADQQA/ugzBrjjK9jcWnDVfGHlk3icNRq0oV7Ri32z/+HQX67aRfgZu7KWdI+Ju
        Wm7DCfrPNGVwFWUQOmsPue9rZBgO
        -----END PRIVATE KEY-----

      SSLCACertificateFile_content: |
        -----BEGIN CERTIFICATE-----
        MIIEkjCCA3qgAwIBAgIQCgFBQgAAAVOFc2oLheynCDANBgkqhkiG9w0BAQsFADA/
        MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
        DkRTVCBSb290IENBIFgzMB4XDTE2MDMxNzE2NDA0NloXDTIxMDMxNzE2NDA0Nlow
        SjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUxldCdzIEVuY3J5cHQxIzAhBgNVBAMT
        GkxldCdzIEVuY3J5cHQgQXV0aG9yaXR5IFgzMIIBIjANBgkqhkiG9w0BAQEFAAOC
        AQ8AMIIBCgKCAQEAnNMM8FrlLke3cl03g7NoYzDq1zUmGSXhvb418XCSL7e4S0EF
        q6meNQhY7LEqxGiHC6PjdeTm86dicbp5gWAf15Gan/PQeGdxyGkOlZHP/uaZ6WA8
        SMx+yk13EiSdRxta67nsHjcAHJyse6cF6s5K671B5TaYucv9bTyWaN8jKkKQDIZ0
        Z8h/pZq4UmEUEz9l6YKHy9v6Dlb2honzhT+Xhq+w3Brvaw2VFn3EK6BlspkENnWA
        a6xK8xuQSXgvopZPKiAlKQTGdMDQMc2PMTiVFrqoM7hD8bEfwzB/onkxEz0tNvjj
        /PIzark5McWvxI0NHWQWM6r6hCm21AvA2H3DkwIDAQABo4IBfTCCAXkwEgYDVR0T
        AQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwfwYIKwYBBQUHAQEEczBxMDIG
        CCsGAQUFBzABhiZodHRwOi8vaXNyZy50cnVzdGlkLm9jc3AuaWRlbnRydXN0LmNv
        bTA7BggrBgEFBQcwAoYvaHR0cDovL2FwcHMuaWRlbnRydXN0LmNvbS9yb290cy9k
        c3Ryb290Y2F4My5wN2MwHwYDVR0jBBgwFoAUxKexpHsscfrb4UuQdf/EFWCFiRAw
        VAYDVR0gBE0wSzAIBgZngQwBAgEwPwYLKwYBBAGC3xMBAQEwMDAuBggrBgEFBQcC
        ARYiaHR0cDovL2Nwcy5yb290LXgxLmxldHNlbmNyeXB0Lm9yZzA8BgNVHR8ENTAz
        MDGgL6AthitodHRwOi8vY3JsLmlkZW50cnVzdC5jb20vRFNUUk9PVENBWDNDUkwu
        Y3JsMB0GA1UdDgQWBBSoSmpjBH3duubRObemRWXv86jsoTANBgkqhkiG9w0BAQsF
        AAOCAQEA3TPXEfNjWDjdGBX7CVW+dla5cEilaUcne8IkCJLxWh9KEik3JHRRHGJo
        uM2VcGfl96S8TihRzZvoroed6ti6WqEBmtzw3Wodatg+VyOeph4EYpr/1wXKtx8/
        wApIvJSwtmVi4MFU5aMqrSDE6ea73Mj2tcMyo5jMd6jmeWUHK8so/joWUoHOUgwu
        X4Po1QYz+3dszkDqMp4fklxBwXRsW10KXzPMTZ+sOPAveyxindmjkW8lGy+QsRlG
        PfZ+G6Z6h7mjem0Y+iWlkYcV4PIWL1iwBi8saCbGS5jN2p8M+X+Q7UNKEkROb3N6
        KOqkqm57TH2H3eDJAkSnh6/DNFu0Qg==
        -----END CERTIFICATE-----

