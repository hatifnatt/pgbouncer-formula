{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import pgbouncer as pgb %}

{#- Stop and disable service #}
pgbouncer_service_clean_dead:
  service.dead:
    - name: {{ pgb.service.name }}

pgbouncer_service_clean_disabled:
  service.disabled:
    - name: {{ pgb.service.name }}

{#- Install systemd service file #}
{%- if grains.init == 'systemd' %}

pgbouncer_service_clean_systemd_unit:
  file.absent:
    - name: {{ salt['file.join'](pgb.service.systemd.unit_dir, pgb.service.name ~ '.service') }}
    - watch_in:
      - module: pgbouncer_service_clean_reload_systemd

  {%- if pgb.use_upstream in ('binary', 'archive') %}
pgbouncer_service_clean_leftover_systemd_unit:
  file.absent:
    - name: {{ salt['file.join']('/usr/lib/systemd/system', pgb.service.name ~ '.service') }}
    - watch_in:
      - module: pgbouncer_service_clean_reload_systemd
  {%- endif %}

  {#- Reload systemd after unit file is removed, like `systemctl daemon-reload` #}
pgbouncer_service_clean_reload_systemd:
  module.wait:
  {#- Workaround for deprecated `module.run` syntax, subject to change in Salt 3005 #}
  {%- if 'module.run' in salt['config.get']('use_superseded', [])
      or grains['saltversioninfo'] >= [3005] %}
    - service.systemctl_reload: {}
  {%- else %}
    - name: service.systemctl_reload
  {%- endif %}

{%- else %}
pgbouncer_service_clean_warning:
  test.configurable_test_state:
    - name: pgbouncer_service_clean
    - changes: false
    - result: false
    - comment: |
        Your OS init system is {{ grains.init }}, currently only systemd init system is supported.
        Service for pgbouncer is not altered (not removed).

{%- endif %}
