#! /usr/bin/env python     
# -*- coding: utf-8 -*-     
#@author jinqinghua@gmail.com    
#@version 2012-11-07  
  
import string  
from random import choice  
import sys
  
''''' 
Linux正则命名参考：http://vbird.dic.ksu.edu.tw/linux_basic/0330regularex.php#lang 
[:alnum:]   代表英文大小写字节及数字，亦即 0-9, A-Z, a-z 
[:alpha:]   代表任何英文大小写字节，亦即 A-Z, a-z 
[:blank:]   代表空白键与 [Tab] 按键两者 
[:cntrl:]   代表键盘上面的控制按键，亦即包括 CR, LF, Tab, Del.. 等等 
[:digit:]   代表数字而已，亦即 0-9 
[:graph:]   除了空白字节 (空白键与 [Tab] 按键) 外的其他所有按键 
[:lower:]   代表小写字节，亦即 a-z 
[:print:]   代表任何可以被列印出来的字节 
[:punct:]   代表标点符号 (punctuation symbol)，亦即：" ' ? ! ; : # $... 
[:upper:]   代表大写字节，亦即 A-Z 
[:space:]   任何会产生空白的字节，包括空白键, [Tab], CR 等等 
[:xdigit:]  代表 16 进位的数字类型，因此包括： 0-9, A-F, a-f 的数字与字节 
 
Python自带常量(本例中改用这个，不用手工定义了) 
string.digits          #十进制数字：0123456789 
string.octdigits       #八进制数字：01234567 
string.hexdigits       #十六进制数字：0123456789abcdefABCDEF 
string.ascii_lowercase #小写字母(ASCII)：abcdefghijklmnopqrstuvwxyz 
string.ascii_uppercase #大写字母(ASCII)：ABCDEFGHIJKLMNOPQRSTUVWXYZ 
string.ascii_letters   #字母：(ASCII)abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 
string.punctuation     #标点符号：!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~ 
 
以下的不用，有locale问题 
string.lowercase       #abcdefghijklmnopqrstuvwxyz 
string.uppercase       #ABCDEFGHIJKLMNOPQRSTUVWXYZ 
string.letters         #ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 
 
以下的不能用 
string.whitespace      #On most systems this includes the characters space, tab, linefeed, return, formfeed, and vertical tab. 
string.printable       #digits, letters, punctuation, and whitespace 
'''  
  
  
def generate_passwd(gtype=''):  
    '''''Function to generate a password'''  
    #请在此设置您要生成的密码需求  
    punctuation = '!@#$%^&*()_+-=' if gtype == 'rds' else string.punctuation
    passwd_seed = string.digits + string.ascii_letters + punctuation #密码种子  
    #passwd_seed = string.digits  
    #passwd_seed = string.digits + string.ascii_letters  
    passwd = []  
    while (len(passwd) < passwd_length):  
        passwd.append(choice(passwd_seed))  
    return ''.join(passwd)  
  
def print_string_constants():  
    '''''Test Case'''  
    print string.digits  
    print string.octdigits  
    print string.hexdigits  
    print string.ascii_lowercase  
    print string.ascii_uppercase  
    print string.ascii_letters  
    print string.punctuation  
    print string.lowercase  
    print string.uppercase  
    print string.letters  
    print (string.printable + "ooo")  
    print string.whitespace  
    print '\n\n'  
      
if __name__ == '__main__':  
    #print_string_constants()  
    passwd_length = 20 #密码长度  
    passwd_count = 1 #密码个数  
    gtype = sys.argv[1] if len(sys.argv) > 1 else ''
    for i in range(0, passwd_count):  
        print generate_passwd(gtype)  
