{% set tplroot = tpldir.split('/')[0] -%}
{% from tplroot ~ '/map.jinja' import pgbouncer -%}

pgbouncer_test_print_data:
  test.configurable_test_state:
    - name: Print some dict
    - result: True
    - changes: False
    - comment: |
        {{ pgbouncer|yaml(False)|indent(width=8) }}
