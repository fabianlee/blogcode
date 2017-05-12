# /srv/salt/top.sls
base:

  'G@role:matlab':
     - match: compound
     - logrotate

  'G@role:maya3ds':
     - match: compound
     - logrotate
