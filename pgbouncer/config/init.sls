{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import pgbouncer as pgb %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}
{%- set conf_dir = salt['file.dirname'](pgb.config.file) -%}

{%- if pgb.install %}
  {#- Manage pgbouncer configuration #}
include:
  - {{ tplroot }}.install
  - {{ tplroot }}.service

  {#- Create parameters / environment file #}
pgbouncer_config_env_file:
  file.managed:
    - name: {{ pgb.env.file }}
    - source: salt://{{ tplroot }}/files/env_file.jinja
    - template: jinja
    - context:
        tplroot: {{ tplroot }}
        options: {{ pgb.env.options|tojson }}
    - watch_in:
      - service: pgbouncer_service_{{ pgb.service.status }}

  {#- Create data dir #}
pgbouncer_config_directory:
  file.directory:
    - name: {{ conf_dir }}
    - user: {{ pgb.root_user }}
    - group: {{ pgb.root_group }}
    - dir_mode: 755

  {#- Put config file in place #}
pgbouncer_config_file:
  file.managed:
    - name: {{ pgb.config.file }}
    - source: salt://{{ tplroot }}/templates/{{ pgb.config.template }}
    - template: jinja
    - user: {{ pgb.user }}
    - group: {{ pgb.group }}
    - mode: 640
    - context:
        tplroot: {{ tplroot }}
        config: {{ pgb.config.data|tojson }}
    {#- By default don't show changes to don't reveal secrets. #}
    - show_changes: {{ pgb.config.show_changes }}
    - require:
        - file: pgbouncer_config_directory
    - watch_in:
      - service: pgbouncer_service_{{ pgb.service.status }}

  {#- Create userlist file #}
pgbouncer_userlist_file:
  file.managed:
    - name: {{ pgb.config.data|traverse('pgbouncer:auth_file', '/etc/pgbouncer/userlist.txt') }}
    - source: salt://{{ tplroot }}/files/userlist.jinja
    - template: jinja
    - user: {{ pgb.user }}
    - group: {{ pgb.group }}
    - mode: 640
    - makedirs: true
    - context:
        userlist: {{ pgb.userlist|tojson }}

  {# TODO: Create pg_hba file? #}

  {#- Create data dir #}
{# pgbouncer_config_data_directory:
  file.directory:
    - name: {{ pgb.config.data.data_dir }}
    - user: {{ pgb.user }}
    - group: {{ pgb.group }}
    - dir_mode: 750
    - makedirs: True
    - require_in:
      - service: pgbouncer_service_{{ pgb.service.status }} #}

{#- pgbouncer is not selected for installation #}
{%- else %}
pgbouncer_config_install_notice:
  test.show_notification:
    - name: pgbouncer_config_install_notice
    - text: |
        pgbouncer is not selected for installation, current value
        for 'pgbouncer:install': {{ pgb.install|string|lower }}, if you want to install pgbouncer
        you need to set it to 'true'.

{%- endif %}
