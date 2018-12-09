#!/user/bin python
# -*- coding:utf-8 -*- 
'''
 @Author:      xiaodong
 @Email:       fuxd@jidongnet.com
 @DateTime:    2015-11-08 19:06:43
 @Description: 提取word文档信息 转换Excel 
 需求字段 ： 姓名，职位，性别，年龄，教育程度，手机号码，邮箱，户籍，简历更新日期，工作经历，项目经历。
'''

from win32com.client import Dispatch, constants
import os,sys
import re
import chardet 
from openpyxl import Workbook
from openpyxl.styles import Alignment, Font

reload(sys)
sys.setdefaultencoding('utf-8')
print sys.getdefaultencoding()


def get_doc(rootDir="."):
    list_dirs = os.walk(rootDir)
    filelist = []
    # 遍历查找关键文件
    for root, dirs, files in list_dirs:
        for d in files:
            # if keyFile in d:
            if d.endswith('.doc') or d.endswith('.docx'):
                filelist.append(os.path.join(root, d))
    if filelist:            
        return filelist
    else:
        sys.exit('没有找到word文件,请确认运行目录是否正确.')



def get_encode(s):
    '''
        获取编码
    '''
    encoding = chardet.detect(s)['encoding']
    if encoding == "GB2312":
        encoding = "gbk"
    return encoding

def Filter(content,keyWordList=''):
    '''
        过滤器：姓名，职位，性别，年龄，教育程度，手机号码，邮箱，户籍，简历更新日期，工作经历，项目经历。
    '''
    encoding = get_encode(content)
    content = content.decode(encoding)
    
    pattern_config = [
         { 'header':u'姓名',      'flied' : 'name',       'pattern' : ur'(?ms)(.*姓名)[:：]*?\s+(?P<name>.*?)\s','result' : '' },
         { 'header':u'职位',      'flied' : 'job',        'pattern' : ur'(?ms)(.*职位.*?)[:：]*?\s+(?P<job>.*?)\s','result' : '' },
         { 'header':u'性别',      'flied' : 'sex',        'pattern' : ur'(?ms).*(?P<sex>[男女]).*','result' : '' },
         { 'header':u'年龄',      'flied' : 'age',        'pattern' : ur'(?s)(.*年龄.*?)[:：]\s+?(?P<age>\d{2}).*','result' : '' },
         { 'header':u'教育程度',  'flied':  'education',  'pattern' : ur'(?ms).*(?P<education>本科|大专|硕士|博士).*','result' : '' },
         { 'header':u'电话号码',  'flied' : 'phoneNumber','pattern' : ur'(?ms).*?(?P<phoneNumber>1\d{10}).*','result' : '' },
         { 'header':u'邮箱',      'flied' : 'mail',      'pattern' : ur'(?s).*\s(?P<mail>\S+?@\S+)','result' : '' },
         { 'header':u'户籍',      'flied' : 'homeTown',  'pattern' : ur'(?ms).*(户口|籍)[:：]\s+(?P<homeTown>\S+)\s','result' : '' },
         { 'header':u'更新时间',  'flied' : 'updateTime','pattern' : ur'(?ms).*?(?P<updateTime>\d{4}-\d{2}-\d{2}\s+\d{2}[:：]+\d+)','result' : '' },
         { 'header':u'工作经历',  'flied' : 'workExperience','pattern' : ur'(?ms).*?\s(工作(经历|经验))[:： ]*(?P<workExperience>.*)(项目经历)','result' : '' },
         { 'header':u'项目经历',  'flied' : 'projectExperience','pattern' : ur'(?ms).*?(项目经历)[:： ]*\s(?P<projectExperience>.*)','result' : '' },
    ]
    for num in range(len(pattern_config)):
        pattern = pattern_config[num]['pattern']
        p = re.compile(pattern)
        result = p.match(content)
        # print pattern
        if result:
            _result = result.group(pattern_config[num]['flied'])
            pattern_config[num]['result'] = _result

            print '获取到%s信息 --------------- %s ' % ( pattern_config[num]['header'], _result )
        else:
            print '未匹配到%s信息' % pattern_config[num]['header'] 
    return pattern_config

def toExcel(pattern_result,saveFileExcel):
    title = [ t['header'] for t in pattern_result ]
    content = [ t['result'] for t in pattern_result]

    wb = Workbook()
    ws = wb.active
    ws.title = pattern_result[0]['header']
    ws.sheet_properties.tabColor = "1072BA"
    ws.append(title)
    ws.append(content)
    wb.save(saveFileExcel)





def docFilter(fileList):
    '''
        转换word为txt,提取信息后清除txt.
    '''
    error_file = []
    for f in fileList:
        # fileName = f.split('\\')[-1].split('.')[-2].decode('gbk')
        # filePath = ''.join(f.split('\\')[:-1]).decode('gbk')
        f = os.path.realpath(f)
        fileName = f.split('\\')[-1].split('.')[0]

        print fileName.decode('gbk') + '  start ..'
        print '-------------------------------------'
        word = Dispatch("Word.Application")
        # 后台静默运行
        word.Visible = 0
        word.DisplayAlerts = 0
        try:
            doc = word.Documents.Open(f,0,ReadOnly = 1)
            saveFileTxt = re.sub('.doc','.txt',f).decode('gbk')
            #保存为 txt 格式
            doc.SaveAs(u'%s' % saveFileTxt ,7)
            content = open(saveFileTxt,'r').read()
            #开始过滤
            pattern_result =  Filter(content)
        except Exception, E:
            print E
            error_file.append(f)
            continue
        finally:
            doc.Close()
            os.remove(saveFileTxt)

        #写入excel
        saveFileExcel = re.sub('.doc','.xlsx',f).decode('gbk')
        # saveFileExcel = u'猎聘网.xlsx'
        toExcel(pattern_result,saveFileExcel)
       # if os.path.exists(u'test.txt'):os.remove(u'test.txt')

    word.Quit()
    if error_file:
        print '失败的文件:'
        print '\n'.join(error_file).decode('gbk')


if __name__ == '__main__':
    filelist = get_doc()
    docFilter(filelist)
