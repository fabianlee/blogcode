# /srv/pillar/logrotate-matlabl.sls

logrotate-matlab:
  lookup:
    rotatejobs:
      matlab:
        path: /var/log/matlab/matlab.log
  
