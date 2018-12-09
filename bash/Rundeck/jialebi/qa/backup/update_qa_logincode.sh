#!/bin/bash
svn up /svn/services/game_center/
cd /svn/services/game_center/
rsync  -avz   --exclude ".svn" --exclude "config" *  /data/jialebi_app/login_server/
