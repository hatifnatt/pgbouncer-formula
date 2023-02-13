{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import pgbouncer as pgb %}
include:
{%- if pgb.use_upstream in ('binary', 'archive') %}
  - .binary.clean
{%- elif pgb.use_upstream in ('repo', 'package') %}
  - .package.clean
{%- endif %}
