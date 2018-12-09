#!/usr/bin/python
# -*- coding:utf-8 -*-
'''
 @Author:      xiaodong
 @Email:       fuxd@jidongnet.com
 @DateTime:    2016-03-11 12:54:42
 @Description: 登陆京东商城,对指定商品下单.
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
            logger.info('------  retry....')
            self._browser.refresh()
            try:
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
            browser.action_click('//*[@id="ttbar-login"]/a[1]', change_page=True)
            browser.action_send_keys('//*[@id="loginname"]',username)
            browser.action_send_keys('//*[@id="nloginpwd"]',password)
            # 消除验证码
            browser._browser.execute_script("""
                var authcode = document.getElementById('o-authcode');
                authcode.style.display == "none" ? console.log('.'): authcode.style.display = "none";
                """
                )
            browser.action_click('//*[@id="loginsubmit"]',change_page=True)
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




@require_login
def get_mi5_conf(browser,username,password):
    goods_url = ['http://item.jd.com/1554223.html',
                'http://item.jd.com/10141116473.html',
                'http://item.jd.com/10141116474.html',
                'http://item.jd.com/10142269653.html',
                'http://item.jd.com/10142269654.html',
                ]
    return goods_url
    # browser._browser.get(goods_url)



@require_login
def get_minote_conf(browser,username,password):
    goods_url = 'http://item.mi.com/buyphone/minote'
    goods_info = ['标准版','双网通 16GB','竹纹 1499元']
    for info in goods_info:
        xpath = "//*[@title='%s']" % info
        browser.action_click(xpath)
    browser.action_click("//*[@id='J_choosePackage']/ul/li[4]")


@require_login
def get_note3_conf(browser,username,password):
    goods_url = 'http://item.mi.com/buyphone/note3'
    browser.action_click("//*[@id='J_proStep']/div[1]/ul/li[1]")
    browser.action_click("//*[@id='J_proStep']/div[2]/ul/li[1]")
    browser.action_click("//*[@id='J_proStep']/div[3]/ul/li[1]")
    browser.action_click("//*[@id='J_choosePackage']/ul/li[4]")

@require_login
def add_address(browser,username,password):
    """添加发货地址
    """
    element = ActionChains(browser._browser).move_to_element(
        browser._browser.find_element_by_xpath('//*[@id="J_userInfo"]/span[1]/a/span')
        )

    # 使用javascript修改href属性为self
    browser._browser.execute_script(
        """
        document.getElementByXPath = function(sValue) {
            var a = this.evaluate(sValue, this, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
            if (a.snapshotLength > 0) {
                return a.snapshotItem(0);
                }
            };
        document.getElementByXPath('//*[@id="J_userInfo"]/span[1]/ul/li[1]/a').target = '_self';
        document.getElementByXPath('//*[@id="J_userInfo"]/span[1]/a').target = '_self';
        """
        )
    # time.sleep(10)
    element.click(browser._browser.find_elements_by_link_text(u'个人中心')).perform()

    # browser._browser.find_elements_by_link_text(u'收货地址')
    browser._browser.find_element_by_xpath('/html/body/div[4]/div/div/div[1]/div/div[2]/div[2]/ul/li[7]/a').click()

    ActionChains(browser._browser).move_to_element(
        browser._browser.find_element_by_xpath('//*[@id="user_name"]')
        ).click().send_keys(u'阿萨德').perform()

    ActionChains(browser._browser).move_to_element(
        browser._browser.find_element_by_xpath('//*[@id="user_phone"]')
        ).click().send_keys(username).perform()

    Select(browser._browser.find_element_by_xpath(
        '//*[@id="J_province"]')).select_by_visible_text(u'上海')
    Select(browser._browser.find_element_by_xpath(
        '//*[@id="J_city"]')).select_by_visible_text(u'上海市')
    Select(browser._browser.find_element_by_xpath(
        '//*[@id="J_county"]')).select_by_visible_text(u'黄埔区')

    WebDriverWait(browser._browser, 10).until(
        EC.element_to_be_clickable((By.XPATH, '//*[@id="J_newAddress"]'))
        ).click()

    browser.action_send_keys('//*[@id="user_adress"]',u'最快捷 啊金山的')
    browser.action_click('//*[@id="J_save"]')





def get_goods(username,password,goods_name,start_time):
    """商品购买主流程
    """

    try:
        # 使用的浏览器类
        # browser = Browser(browser='Firefox')
        browser = Browser()
        browser._browser.get('https://www.jd.com/')
        logger.debug('###############   account [ %s ] start ..... #################' % username)
        goods_url = eval('get_%s_conf(browser,username,password)' % goods_name)
        print goods_url
        for goods in goods_url:
            print goods
            browser._browser.get(goods)
            if 'btn-easybuy' not in browser._browser.page_source:
                continue
            # print  u"添加发货地址"
            # add_address(browser,username, password)
            # time.sleep(get_wait_seconds(start_time))
            logger.debug(u"第一步: 自动登录,选择手机配置")
            browser.action_click('//*[@id="btn-easybuy-submit"]')
            browser.action_click('//*[@id="order-submit"]')
            logger.debug(u"第二步: 保存收货人")
            # 如果有弹出保存收货人. 直接点击
            if 'ui-dialog' in page_source:
                ActionChains(browser._browser).move_to_element(
                browser._browser.find_element_by_xpath(
                    '//*[@id="consignee_county"]')).click()
                Select(browser._browser.find_element_by_xpath(
                    '//*[@id="consignee_county"]')).select_by_index(1)
            
            if 'payment' not in browser._browser.current_url:
                logger.debug(u'第三步: 提交订单')
                browser.action_click('//*[@id="order-submit"]')

            if u'订单提交成功' in browser._browser.page_source:
                logger.info('get goods %s sucessed . write to `sucess.txt` file ' % goods_name)
                lock.acquire()
                sucessd_file.writeline(username + ' -- ' + goods_name)
                lock.release()
    except Exception, e:
        logger.exception(e)
        logger.warning('save error page in error.html !!!')
        error_file = file('error_%s.html' % username, 'w')
        error_file.write(browser._browser.page_source)
        time.sleep(2)
    finally:
        error_file.close()
   


def main():
    #mi4s note3 mi5
    goods_name = u'mi5'
    # 保持登陆状态,正式开始下单时间
    start_time = '2016-03-11 9:40:00'

    sucessd_file = file('sucess.txt','w+' )

    thread_pool = Pool()
    lock = Lock()
    # account_info = file('jd_account.txt','r').readlines()
    account_info = ['13671663037----dansontang']

    for account in account_info:
        info = account.split('----')
        username = info[0]
        password = info[1]
        thread_pool.apply_async(get_goods, args=(username,password,goods_name,start_time))

    thread_pool.close()
    thread_pool.join()
    sucessd_file.close()

if __name__ == '__main__':
    main()
    if 'display' in locals().keys():
        display.stop()
