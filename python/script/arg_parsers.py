import argparse

parser = argparse.ArgumentParser()

parser.add_argument('member_ref_id', type = str, help = 'memberRefId of the data need to be copy')

parser.add_argument('--source', type = str, default = 'wesd_mars',
                    help = 'source database name, default wesd_mars, accept wesd_mars, wesd_mars_uat, wesd_mars_prod')

parser.add_argument('--targets', nargs='*', help = 'target database names, default ["wesd_mars_uat", "wesd_mars_prod"], '
                                               'element must be one of wesd_mars, wesd_mars_uat, wesd_mars_prod')

parser.add_argument('--app_ref_ids', nargs='*', help = 'the specified appRefId, default use all appRefId')

parser.add_argument('--tables', nargs='*', help = 'table need to be copied, default all the table of source database')

args = parser.parse_args()