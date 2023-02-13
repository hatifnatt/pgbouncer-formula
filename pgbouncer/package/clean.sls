{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import pgbouncer as pgb %}

include:
  - {{ tplroot }}.service.clean
  - {{ tplroot }}.repo.clean

pgbouncer_package_clean:
  pkg.removed:
    - pkgs:
    {%- for pkg in pgb.package.pkgs %}
      - {{ pkg }}
    {%- endfor %}
    - require_in:
      - sls: {{ tplroot }}.repo.clean

{#- Remove user and group #}
pgbouncer_package_clean_user:
  user.absent:
    - name: {{ pgb.user }}
    - require_in:
      - sls: {{ tplroot }}.repo.clean

pgbouncer_package_clean_group:
  group.absent:
    - name: {{ pgb.group }}
    - require_in:
      - sls: {{ tplroot }}.repo.clean
