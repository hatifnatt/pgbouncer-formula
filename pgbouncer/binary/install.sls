{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import pgbouncer as pgb %}
{%- set conf_dir = salt['file.dirname'](pgb.config.file) -%}

{%- if pgb.install %}
  {#- Install pgbouncer from precompiled binary #}
  {%- if pgb.use_upstream in ('binary', 'archive') %}

pgbouncer_binary_install_method_not_implemented:
  test.show_notification:
    - name: pgbouncer_binary_install_method_not_implemented
    - text: |
        'binary' install method is not implemented for pgbouncer

  {#- Another installation method is selected #}
  {%- else %}
pgbouncer_binary_install_method:
  test.show_notification:
    - name: pgbouncer_binary_install_method
    - text: |
        Another installation method is selected. If you want to use binary
        installation method set 'pgbouncer:use_upstream' to 'binary' or 'archive'.
        Current value of pgbouncer:use_upstream: '{{ pgb.use_upstream }}'
  {%- endif %}

{#- pgbouncer is not selected for installation #}
{%- else %}
pgbouncer_binary_install_notice:
  test.show_notification:
    - name: pgbouncer_binary_install
    - text: |
        pgbouncer is not selected for installation, current value
        for 'pgbouncer:install': {{ pgb.install|string|lower }}, if you want to install pgbouncer
        you need to set it to 'true'.

{%- endif %}
