# /srv/pillar/top.sls
base:

  'G@role:matlab':
    - match: compound
    - logrotate-matlab

  'G@role:maya3ds':
    - match: compound
    - logrotate-maya3ds

