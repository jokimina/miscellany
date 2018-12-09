#!/bin/bash
svn up /svn/services/game_server/
cd /svn/services/game_server/
rsync  -avz   --exclude ".svn" --exclude "config" *  /data/jialebi_app/jialebi_server/
