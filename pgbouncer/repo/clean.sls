{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import pgbouncer as pgb %}

{#- Remove any configured repo form the system #}
{#- If only one repo configuration is present - convert it to list #}
{%- if pgb.repo.config is mapping %}
  {%- set configs = [pgb.repo.config] %}
{%- else %}
  {%- set configs = pgb.repo.config %}
{%- endif %}
{%- for config in configs %}
pgbouncer_repo_clean_{{ loop.index0 }}:
  {%- if grains.os_family != 'Debian' %}
  pkgrepo.absent:
    - name: {{ config.name | yaml_dquote }}
  {%- else %}
  {#- Due bug in pkgrepo.absent we need to manually remove repositry '.list' files
      See https://github.com/saltstack/salt/issues/61602 #}
  file.absent:
    - name: {{ config.file }}
  {%- endif %}

{%- endfor %}

{#- Remove keyring #}
pgbouncer_repo_clean_keyring:
  file.absent:
    - name: {{ pgb.repo.keyring.get('dst', '') }}
