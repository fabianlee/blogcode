# /srv/pillar/logrotate-maya3ds.sls

logrotate-maya3ds:
  lookup:
    rotatejobs:
      maya3ds:
        path: /var/log/3ds/3ds.log
