{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import pgbouncer as pgb %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}

{# TODO: Add options to configure repo by including postgresql.repo state or skip repo configuration at all #}

{%- if pgb.install %}
  {#- If pgbouncer:use_upstream is 'repo' or 'package' official repo will be configured #}
  {%- if pgb.use_upstream in ('repo', 'package') %}

    {#- Install required packages if defined #}
    {%- if pgb.repo.prerequisites %}
pgbouncer_repo_install_prerequisites:
  pkg.installed:
    - pkgs: {{ pgb.repo.prerequisites|tojson }}
    {%- endif %}

    {#- Install keyring / gpg key if provided #}
    {%- if 'keyring' in pgb.repo and pgb.repo.keyring %}
pgbouncer_repo_install_keyring:
  file.managed:
    - name: {{ pgb.repo.keyring.get('dst', '') }}
    - source: {{ pgb.repo.keyring.get('src', '') }}
    - skip_verify: {{ pgb.repo.keyring.get('skip_verify', false) }}
    {%- endif %}

    {#- If only one repo configuration is present - convert it to list #}
    {%- if pgb.repo.config is mapping %}
      {%- set configs = [pgb.repo.config] %}
    {%- else %}
      {%- set configs = pgb.repo.config %}
    {%- endif %}
    {%- for config in configs %}
pgbouncer_repo_install_{{ loop.index0 }}:
  pkgrepo.managed:
    {{- format_kwargs(config) }}
      {%- if 'keyring' in pgb.repo and pgb.repo.keyring %}
    - require:
      - file: pgbouncer_repo_install_keyring
      {%- endif %}
    {%- endfor %}

  {#- Another installation method is selected #}
  {%- else %}
pgbouncer_repo_install_method:
  test.show_notification:
    - name: pgbouncer_repo_install_method
    - text: |
        Another installation method is selected. Repo configuration is not required.
        If you want to configure repository set 'pgbouncer:use_upstream' to 'repo' or 'package'.
        Current value of pgbouncer:use_upstream: '{{ pgb.use_upstream }}'
  {%- endif %}

{#- pgbouncer is not selected for installation #}
{%- else %}
pgbouncer_repo_install_notice:
  test.show_notification:
    - name: pgbouncer_repo_install
    - text: |
        pgbouncer is not selected for installation, current value
        for 'pgbouncer:install': {{ pgb.install|string|lower }}, if you want to install pgbouncer
        you need to set it to 'true'.

{%- endif %}
