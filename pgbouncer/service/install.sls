{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import pgbouncer as pgb %}

{%- if pgb.install %}
  {#- Install systemd service file #}
  {%- if grains.init == 'systemd' %}
include:
  - {{ tplroot }}.service

pgbouncer_service_install_systemd_unit:
  file.managed:
    - name: {{ salt['file.join'](pgb.service.systemd.unit_dir, pgb.service.name ~ '.service') }}
    - source: salt://{{ tplroot }}/files/pgbouncer.service.jinja
    - user: {{ pgb.root_user }}
    - group: {{ pgb.root_group }}
    - mode: 644
    - template: jinja
    - context:
        tplroot: {{ tplroot }}
    - require_in:
      - sls: {{ tplroot }}.service
    - watch_in:
      - module: pgbouncer_service_install_reload_systemd

    {#- Reload systemd after new unit file added, like `systemctl daemon-reload` #}
pgbouncer_service_install_reload_systemd:
  module.wait:
    {#- Workaround for deprecated `module.run` syntax, subject to change in Salt 3005 #}
    {%- if 'module.run' in salt['config.get']('use_superseded', [])
    or grains['saltversioninfo'] >= [3005] %}
    - service.systemctl_reload: {}
    {%- else %}
    - name: service.systemctl_reload
    {%- endif %}
    - require_in:
      - sls: {{ tplroot }}.service

  {%- else %}
pgbouncer_service_install_warning:
  test.configurable_test_state:
    - name: pgbouncer_service_install
    - changes: false
    - result: false
    - comment: |
        Your OS init system is {{ grains.init }}, currently only systemd init system is supported.
        Service for pgbouncer is not installed.

  {%- endif %}

{#- pgbouncer is not selected for installation #}
{%- else %}
pgbouncer_service_install_notice:
  test.show_notification:
    - name: pgbouncer_service_install
    - text: |
        pgbouncer is not selected for installation, current value
        for 'pgbouncer:install': {{ pgb.install|string|lower }}, if you want to install pgbouncer
        you need to set it to 'true'.

{%- endif %}
