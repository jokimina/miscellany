#!/usr/bin/python
# -*- coding:utf-8 -*-
'''
 @Author:      xiaodong
 @Email:       fuxd@jidongnet.com
 @DateTime:    2016-01-19 17:25:13
 @Description: 根据本地目录结构遍历下载CDN上的文件,和本地进行比对.
               主要通过上线流程自动触发下载进行检测,检验文件上传完毕后的下载文件,是否和本地一致.
 @version :    1.0.0
'''

import requests
import os
import time
import sys
from hashlib import md5
import threading
import progressbar
import json

def md5sum(f):
    '''
        实现文件的md5校验
    '''
    string = ''
    try:
        m = md5()
        _file = file(f,'rb')
        _file.seek(0)
        while 1:
            string = _file.read(8096)
            if not string :
                break
            m.update(string)
        result = m.hexdigest()
    except Exception as e:
        print e,' -- %s --- error by md5sum ' % f
        result = ''
    finally:
        _file.close()
        return result


def mkdirs(path):
    '''
        创建多级目录
    '''
    if sys.platform == 'win32':
        os.system('mkdir %s' % path)
    else:
        os.system('mkdir -p %s' % path)


def checkFiles(download_path,url,local_path):
    '''
        @download_path : 下载文件的保存地址
        @url  : 下载url
        @local_path： 本地的文件位置
    '''
    # 本地存储路径

    try:
        # start = time.time()
        pre_path = os.sep.join(download_path.split(os.sep)[0:-1])
        if not os.path.exists(pre_path):
            mkdirs(pre_path)
        # 下载文件
        r = requests.get(url)
        file(download_path,'wb').write(r.content)

        lock.acquire()
        _m_cdn_file = md5sum(download_path)
        _m_local_file = md5sum(local_path)
    except Exception as error:
        _m_cdn_file = ''
        _m_local_file = ''
    finally:
        error = error if 'error' in dir() else None
        check_result = {
                'url': url,
                'download_path':download_path,
                'local_path' : local_path,
                'error' : error ,
                'checksum' : {
                    'cdn' : _m_cdn_file,
                    'local': _m_local_file
                }
             }
        check_results.append(check_result)
        lock.release()
        # end = time.time()


def parseAndProcess(localResourcePath,cdnUrl,savePath,keep_files=True):
    '''
        根据本地资源路径,生成下载的url列表
        @localResourcePath: 本地资源目录
        @cdnUrl : cdn 地址
        @savePath:  下载文件的保存路径
        @keep_files: 是否保留下载后的文件. 默认为 True.
    '''
    # 本地资源文件列表
    resourceFiles = []
    # 下载存储位置列表
    savePathList = []
    # 各进程运行结果保存列表
    threadList = []

    for root,dirs,files in os.walk(localResourcePath):
        if files:
            for f in files:
                resourceFiles.append(root + os.sep + f)

    if not os.path.exists(savePath):
        os.mkdir(savePath)
    savePathList = map(lambda y : y.replace(localResourcePath,savePath),resourceFiles)
    urls = map(lambda x : x.replace(localResourcePath,cdnUrl).replace('\\','/') ,resourceFiles)

    # 多进程任务开始
    print 'Parent process is %s .' % os.getpid()
    for download_path,url,local_path in zip(savePathList,urls,resourceFiles):
        threadList.append(threading.Thread(target=checkFiles,args=(download_path,url,local_path,),name=url))


    print 'start download files waiting for all process done ....'
    for res in threadList:
        res.start()

    # 进度条
    progress  = progressbar.ProgressBar(maxval=len(threadList)).start()
    for i in range(len(threadList)):
        _thread = threadList[i]
        lock.acquire()
        print 'download : ',_thread.getName(),
        sys.stdout.write('\r\n')
        progress.update(i+1)
        sys.stdout.flush()
        lock.release()
        _thread.join()
    sys.stdout.write('\n')
    print 'All download done ...'

    if not keep_files:
        print 'start delete download files...'
        for _f in savePathList:
            os.remove(_f)
            print 'delete : ' , _f



def run():
    '''
    程序入口:
    最终返回结果.保存至文件 checkfile.json
    check_results:
        [
            {
                'url': http://mgame.bce.baidu-mgame.com/yiciyuanzhanji/jidong/1.0.8/8/check_file.json',
                'local_path' : '/data/gintama/dev_default/hot_resource/jidong/1.0.8/8/check_file.json',
                'download_path' : '/tmp/hot_resource/jidong/1.0.8/8/check_file.json',
                'error' : None
                'checksum' : {
                    'cdn' : 'd41d8cd98f00b204e9800998ecf8427e',
                    'local': '71b2300c9ee7a8c8a87881482704aaa2'
                }
            },
        ]
    '''
    global check_results,lock
    check_results = []
    lock = threading.Lock()

    # 保存校验结果的文件名
    result_file = 'checkfile.json'
    # 对应的CDN下载地址
    cdnUrl = 'http://mgame.bce.baidu-mgame.com/yiciyuanzhanji'
    # 本地需要遍历的目录
    localResourcePath = 'd:\\test'
    # 下载文件的保存位置
    savePath = 'd:\\test1'

    parseAndProcess(localResourcePath,cdnUrl,savePath,keep_files=False)

    # 保存结果
    with open(result_file, 'wb') as f:
        json.dump(check_results,f,indent=2)


if __name__ == '__main__':
    run()
