import MySQLdb

wesd_mars = MySQLdb.connect(host = "xxxxxtest.mysql.rds.aliyuncs.com",
                            user = "xxxxxdb",
                            passwd = "xxxxxsha",
                            db = "wesd_mars")

wesd_mars_uat = MySQLdb.connect(host = "xxxxxtest.mysql.rds.aliyuncs.com",
                            user = "xxxxxdb",
                            passwd = "xxxxxsha",
                            db = "wesd_mars_uat")

# wesd_mars_prod = MySQLdb.connect(host = "xxxxx-jira-vpc.mysql.rds.aliyuncs.com",
#                             user = "leixufei",
#                             passwd = "fsf&99&)fds23)!33",
#                             db = "wesd_mars")
wesd_mars_prod = None

database_map = {'wesd_mars' : wesd_mars, 'wesd_mars_uat' : wesd_mars_uat,
                'wesd_mars_prod' : wesd_mars_prod}

# prod_cursor = wesd_mars_prod.cursor()
# prod_cursor.execute("select * from wesd_app")
# print prod_cursor.fetchall()