{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import pgbouncer as pgb %}

pgbouncer_binary_clean_method_not_implemented:
  test.show_notification:
    - name: pgbouncer_binary_clean_method_not_implemented
    - text: |
        'binary' install / clean method is not implemented for pgbouncer
