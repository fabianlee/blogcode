# /srv/salt/logrotate/init.sls
{% from "logrotate/map.jinja" import logrotate with context %}

{% for key,value in logrotate['rotatejobs'].items() %}
  {% set thisjob = key %}
  {% set thislog = value.path %}
logrotate-task-{{thisjob}}:
  cmd.run:
    - name: echo asked to logrotate {{thislog}}
{% endfor %}

