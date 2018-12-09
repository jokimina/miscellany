SVN_USER_NAME="dengzy"
SVN_USER_PWD="dengzy123"
version=$1
server=$2
path="/svn/channels/$version/$server/"
svnurl="https://svn.break.sh.cn/svn/zhanguo/branches/channels/$version/$server"
if [ ! -d "$path" ] ; then
	mkdir -p $path
	svn co $svnurl $path --username=$SVN_USER_NAME --password=$SVN_USER_PWD
fi
cd $path
svn up
