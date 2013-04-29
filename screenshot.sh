#!/bin/bash - 
#===============================================================================
#
#          FILE: screenshot.sh
# 
#         USAGE: ./screenshot.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 10/28/2012 04:34:20 PM CET
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
sleep 0.2; scrot -m "/tmp/\$h.png" -e "xdg-open \$f"

