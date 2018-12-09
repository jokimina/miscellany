import datetime
import sys

from databases import *
from arg_parsers import args

reload(sys)
sys.setdefaultencoding("UTF8")
source_cursor = database_map[args.source].cursor()

if args.targets is None:
    args.targets = ['wesd_mars_uat']

print "memberRefId: ", args.member_ref_id
print "target: ", args.targets
print "source: ", args.source

#print 'SELECT refId FROM mars_app WHERE memberRefId = "{}"'.format(args.member_ref_id)
if args.app_ref_ids is None:
    source_cursor.execute('SELECT refId FROM mars_app WHERE memberRefId = "{}"'.format(args.member_ref_id))
    args.app_ref_ids = [column[0] for column in source_cursor.fetchall()]

#print 'SELECT table_name FROM information_schema.tables WHERE table_schema = "{}"'.format(args.source)
if args.tables is None:
    # source_cursor.execute('SELECT table_name FROM information_schema.tables WHERE table_schema = "{}"'.format(args.source))
    # args.tables = [column[0] for column in source_cursor.fetchall()]
    args.tables = ['mars_loan_template_fee_table', 'mars_loan_template_meta', 'mars_loan_template_stage_table']

print "appRefIds", args.app_ref_ids
print "table", args.tables

targets = [database_map[target] for target in args.targets]

for table in args.tables:
    print "copy data from table ", table

    source_cursor.execute("SHOW columns FROM {}".format(table))
    columns = [column[0] for column in source_cursor.fetchall()]
    columns.remove("id")
    select_fields = ','.join(["`" + column + "`" for column in columns])
    print select_fields
    data = []
    if ("appRefId" in columns):
        for app_ref_id in args.app_ref_ids:
            #print "SELECT {} FROM {} WHERE appRefId = '{}'".format(select_fields, table, app_ref_id)
            sql = "SELECT {} FROM {} WHERE appRefId = '{}'".format(select_fields, table, app_ref_id)
            print sql
            source_cursor.execute(sql)
            data.extend(source_cursor.fetchall())
    elif ("memberRefId" in columns):
        source_cursor.execute("SELECT {} FROM {} WHERE memberRefId = '{}'".format(select_fields, table,
                                                                                  args.member_ref_id))
        data.extend(source_cursor.fetchall())

    #print data
    for row_tuple in data:

        row = list(row_tuple)
        #print row
        for i in xrange(len(row)):
            #print type(row[i])
            if (type(row[i]) is datetime.datetime):
                row[i] = "'" + row[i].strftime("%Y-%m-%d %H:%M:%S") + "'"
            elif (type(row[i]) is long or type(row[i]) is int):
                row[i] = str(row[i])
            elif (row[i] is None):
                row[i] = 'null'
            else:
                row[i] = "'" + row[i] + "'"

        insert_sql = "INSERT INTO {} ({}) VALUES ({})".format(table, select_fields, ','.join(row))

        for target in targets:
            print insert_sql
            target_cursor = target.cursor()
            target_cursor.execute(insert_sql)

try:
    for target in targets:
        target.commit()
except Exception, e:
    for target in targets:
        target.rollback()
    print e


# for conn in database_map.values():
#     conn.close()

