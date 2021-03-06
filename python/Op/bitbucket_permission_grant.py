#!/usr/bin/python
# -*- coding:utf-8 -*-
'''
 @Author:      xiaodong
 @Email:       fuxd@jidongnet.com
 @DateTime:    2016-09-27 12:54:42
 @Description: 授权bitbucket
'''

from selenium import webdriver
from selenium.webdriver import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support import expected_conditions as EC
from multiprocessing import Pool,Lock
import threading
import json
import logging

import time,sys
reload(sys)
sys.setdefaultencoding('utf-8')

# linux模式下开启虚拟显示
if sys.platform != 'win32':
    from pyvirtualdisplay import Display
    display = Display(visible=0, size=(1024, 768))
    display.start()
################   log setting   ####################
# create logger
logger = logging.getLogger("jd")
logger.setLevel(logging.DEBUG)
# create console handler and set level to debug
# ch = logging.FileHandler("test.log")
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
logger.setLevel(logging.DEBUG)
# create formatter
formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
# add formatter to ch
ch.setFormatter(formatter)
logger.addHandler(ch)

class Browser(object):
    """浏览器对象:
        Chrome需要先安裝chrome驱动 http://chromedriver.storage.googleapis.com/2.7/chromedriver_win32.zip
    """
    def __init__(self, browser='Chrome'):
        self._browser = eval('webdriver.%s()' % browser)

    def __del__(self):
        self._browser.close()

    # @classmethod
    def action_send_keys(self,xpath=None,keys=None):
        """填充表单
            Args:
                xpath : xpath匹配语句,默认为None
                keys  : 填充内容
        """
        try:

            element = WebDriverWait(self._browser, 20).until(
                EC.presence_of_all_elements_located((By.XPATH, xpath))
                )
            self._browser.find_element_by_xpath(xpath).send_keys(keys)
        except Exception, e:
            logger.error('send_keys %s failed !!' % keys)
            logger.error(e)
            return False
        return True

    # @classmethod
    def action_click(self,xpath=None,change_page=False):
        """点击按钮
            Args:
                xpath : xpath匹配语句,默认为None
                change_page : 点击后是否会切换页面.
        """
        self.result = True
        self.current_url = self._browser.current_url
        try:
            element = WebDriverWait(self._browser, 20).until(
                EC.element_to_be_clickable((By.XPATH, xpath))
                )
            element.click()
            # self._browser.find_element_by_xpath(xpath).click()
        except Exception, e:
            logger.error('%s click failed!!!' % xpath)
            logger.error(e)
            self._browser.refresh()
            try:
                logger.error('------  retry....')
                element = WebDriverWait(self._browser, 20).until(EC.element_to_be_clickable((By.XPATH, xpath)));
                element.click()
            except:
                result = False
            # ActionChains(self._browser).move_to_element(xpath).click().perform()
        finally:
            i = 0
            # 判断是否成功切换页面
            if change_page:
                while 1:
                    if self.current_url != self._browser.current_url:
                        logger.debug('change page to %s' % self._browser.current_url)
                        break
                    elif i < 3:
                        time.sleep(1)
                        try:
                            self._browser.find_element_by_xpath(xpath).click()
                        except Exception, e:
                            pass
                        finally:
                            i +=1
                    else:
                        break

        return self.result


def require_login(func):
    def _deco(browser,username,password):
        try:
            assert 'unick' in [ cookie['name'] for cookie in browser._browser.get_cookies()]
        except Exception, e:
            # browser.action_click('//*[@id="js-email-field"]', change_page=True)
            browser.action_send_keys('//*[@id="js-email-field"]',username)
            browser.action_send_keys('//*[@id="js-password-field"]', password)
            # 消除验证码
            # browser._browser.execute_script("""
            #     var authcode = document.getElementById('o-authcode');
            #     authcode.style.display == "none" ? console.log('.'): authcode.style.display = "none";
            #     """
            #     )
            browser.action_click('//*[@id="aid-login-form"]/div[2]/input',change_page=True)
        ret = func(browser,username,password)
        return ret
    return _deco



def get_wait_seconds(dst_time):
    """获取到目标时间的等待秒数
        Args:
            dst_time: 目标时间点.  数据格式: 2016-03-10 17:00:00
        @returns {int} [到目标时间点的秒数]

    """
    now_time = int(time.mktime(time.localtime()))
    dst_time = int(
            time.mktime(time.strptime('2016-03-10 17:00:00','%Y-%m-%d %H:%M:%S'))
        )
    return  dst_time - now_time

def get_goods(project_name,account,browser):
    """商品购买主流程
    """
    try:
        logger.info('###############   project [ %s ] start ..... #################' % project_name)
        # 使用的浏览器类
        # browser = Browser(browser='Firefox')
        url = "https://bitbucket.org/xxxxx/%s/admin/access" % project_name
        print url
        browser._browser.get(url)
        browser.action_send_keys('//*[@id="username"]',account)
        browser.action_click('//*[@id="s2id_id_user_access_level"]')
        browser.action_click('//*[@id="id_user_access_level"]/option[2]')
        browser.action_click('//*[@id="user-access"]/tbody/tr[1]/td[3]/div/button', change_page=False)
        browser.action_click('//*[@id="user-access"]/tbody/tr[1]/td[3]/div/button', change_page=False)
        # time.sleep(20)
        logger.info('###############   project [ %s ] done ..... #################' % project_name)
    except Exception, e:
        logger.exception(e)

def main():
    thread_pool = Pool(1)
    browser = Browser()
    # 登陆
    browser._browser.get('https://bitbucket.org/account/signin/?next=/xxxxx/xxxxx-admin/admin/access')
    browser.action_send_keys('//*[@id="js-email-field"]', 'xx@xxxxx.com')
    browser.action_send_keys('//*[@id="js-password-field"]', 'xxx')
    browser.action_click('//*[@id="aid-login-form"]/div[2]/input', change_page=True)



    for _project_name in project_list :
        _project_name = _project_name.lower()
        # logger.info('---- %s' % _project_name)
        # thread_pool.apply_async(get_goods, args=(_project_name,account,browser))
        get_goods(_project_name,account,browser)

    thread_pool.close()
    thread_pool.join()
    time.sleep(300)
    # sucessd_file.close()
    # browser.__del__()

if __name__ == '__main__':
    account = 'wangyuxin@xxxxx.com'
    project_list = [
        # 'xxxxx-haorenhaoxin',
        # 'xxxxx-mercuryclient',
        'cashBus-libweixin',
        'cashBus-libwechat',
        'cashBus-libusernocetic',
        'cashBus-libtasklog',
        'cashBus-libstorage',
        'cashBus-libshard',
        'cashBus-libons',
        'cashBus-libjobworker',
        'cashBus-libjira',
        'cashBus-libhaorenhaoxin',
        'cashBus-libgaia',
        'cashBus-libconfigclient',
        'cashBus-libconfig',
        'cashBus-libcollection',
        'cashBus-libcallcenter',
        'cashBus-libbasenotice',
        'cashBus-libbackend',
        'cashBus-libathenaworkflow',
        'cashBus-libathena',
        'cashBus-libadmin',
        'xxxxx-libstorage',
        'xxxxx-libconfigclient',
        'xxxxx-libtasklog',
        'xxxxx-libmybatis',
        'xxxxx-libwechat',
        'xxxxx-libusernotice',
        'xxxxx-libons',
        'xxxxx-libathenaworkflow',
        'xxxxx-libplugin',
    ]

    main()
    if 'display' in locals().keys():
        display.stop()
