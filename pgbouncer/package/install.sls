{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import pgbouncer as pgb %}
{%- set conf_dir = salt['file.dirname'](pgb.config.file) -%}

{%- if pgb.install %}
  {#- Install pgbouncer from packages #}
  {%- if pgb.use_upstream in ('repo', 'package') %}
include:
  - {{ tplroot }}.repo.install
  - {{ tplroot }}.service.install

    {#- Install packages required for further execution of 'package' installation method #}
    {%- if 'prereq_pkgs' in pgb.package and pgb.package.prereq_pkgs %}
pgbouncer_package_install_prerequisites:
  pkg.installed:
    - pkgs: {{ pgb.package.prereq_pkgs|tojson }}
    - require:
      - sls: {{ tplroot }}.repo.install
    - require_in:
      - pkg: pgbouncer_package_install
    {%- endif %}

    {%- if 'pkgs_extra' in pgb.package and pgb.package.pkgs_extra %}
pgbouncer_package_install_extra:
  pkg.installed:
    - pkgs: {{ pgb.package.pkgs_extra|tojson }}
    - require:
      - sls: {{ tplroot }}.repo.install
    - require_in:
      - pkg: pgbouncer_package_install
    {%- endif %}

pgbouncer_package_install:
  pkg.installed:
    - pkgs:
    {%- for pkg in pgb.package.pkgs %}
      - {{ pkg }}{% if pgb.version is defined and 'pgbouncer' in pkg %}: '{{ pgb.version }}*'{% endif %}
    {%- endfor %}
    - hold: {{ pgb.package.hold }}
    - update_holds: {{ pgb.package.update_holds }}
    {%- if salt['grains.get']('os_family') == 'Debian' %}
    - install_recommends: {{ pgb.package.install_recommends }}
    {%- endif %}
    - watch_in:
      - service: pgbouncer_service_{{ pgb.service.status }}
    - require:
      - sls: {{ tplroot }}.repo.install
    - require_in:
      - sls: {{ tplroot }}.service.install

    {#- Create group and user #}
{# pgbouncer_package_install_group:
  group.present:
    - name: {{ pgb.group }}
    - system: true
    - require:
      - pkg: pgbouncer_package_install

pgbouncer_package_install_user:
  user.present:
    - name: {{ pgb.user }}
    - gid: {{ pgb.group }}
    - system: true
    - password: '!'
    - home: {{ pgb.home }}
    - createhome: false
    - shell: /usr/sbin/nologin
    - fullname: pgbouncer daemon
    - require:
      - group: pgbouncer_package_install_group
    - require_in:
      - sls: {{ tplroot }}.backup_helper.install
      - sls: {{ slsdotpath }}.service.install #}

  {#- Another installation method is selected #}
  {%- else %}
pgbouncer_package_install_method:
  test.show_notification:
    - name: pgbouncer_package_install_method
    - text: |
        Another installation method is selected. If you want to use package
        installation method set 'pgbouncer:use_upstream' to 'package' or 'repo'.
        Current value of pgbouncer:use_upstream: '{{ pgb.use_upstream }}'
  {%- endif %}

{#- pgbouncer is not selected for installation #}
{%- else %}
pgbouncer_package_install_notice:
  test.show_notification:
    - name: pgbouncer_package_install
    - text: |
        pgbouncer is not selected for installation, current value
        for 'pgbouncer:install': {{ pgb.install|string|lower }}, if you want to install pgbouncer
        you need to set it to 'true'.

{%- endif %}
