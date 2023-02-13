{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import pgbouncer as pgb %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}
{%- set conf_dir = salt['file.dirname'](pgb.config.file) -%}

  {#- Remove config file #}
pgbouncer_config_clean_file:
  file.absent:
    - name: {{ pgb.config.file }}
    - require_in:
        - file: pgbouncer_config_clean_directory

  {#- Remove parameters / environment file #}
pgbouncer_config_clean_env_file:
  file.absent:
    - name: {{ pgb.env.file }}

  {#- Remove config dir #}
pgbouncer_config_clean_directory:
  file.absent:
    - name: {{ conf_dir }}
