svn up /svn/resource/download
cd /svn/resource/download
rsync -avz * --exclude ".svn" /data/cdn_data/jialebi-resource/
