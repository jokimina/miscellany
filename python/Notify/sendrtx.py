#!/usr/bin/env python
#coding:utf-8
import urllib
import sys
import sys
import os
reciver = sys.argv[1]
MESSAGE = sys.argv[2:]
MESSAGE = '\n'.join(MESSAGE)
hostname = os.popen('hostname').read()


def transcode(stotrans):
    return stotrans.decode('utf-8').encode('gb2312')
# Title=transcode("")
# if sys.platform == 'win32':
#        reciver=reciver
#        MESSAGE=MESSAGE+' '+' '.join(args)
# else:
# reciver=transcode(reciver)
MESSAGE = transcode(MESSAGE)
urllib.urlopen('http://10.10.41.58:8012/sendnotify.cgi?msg=' +
               MESSAGE + '&receiver=' + reciver + '&title=' + hostname)
