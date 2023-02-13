{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import pgbouncer as pgb %}

{%- if pgb.install %}
  {#- Manage on boot service state in dedicated state to ensure watch trigger properly in service.running state #}
pgbouncer_service_{{ pgb.service.on_boot_state }}:
  service.{{ pgb.service.on_boot_state }}:
    - name: {{ pgb.service.name }}

pgbouncer_service_{{ pgb.service.status }}:
  service:
    - name: {{ pgb.service.name }}
    - {{ pgb.service.status }}
  {%- if pgb.service.status == 'running' %}
    - reload: {{ pgb.service.reload }}
  {%- endif %}
    - require:
        - service: pgbouncer_service_{{ pgb.service.on_boot_state }}
    - order: last

{#- pgbouncer is not selected for installation #}
{%- else %}
pgbouncer_service_notice:
  test.show_notification:
    - name: pgbouncer_service_notice
    - text: |
        pgbouncer is not selected for installation, current value
        for 'pgbouncer:install': {{ pgb.install|string|lower }}, if you want to install pgbouncer
        you need to set it to 'true'.

{%- endif %}
