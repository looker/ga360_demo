import looker_sdk
import sys
import os
import argparse

arguments = argparse.ArgumentParser()
arguments.add_argument('--base-url',type=str)
arguments.add_argument('--client-id',type=str)
arguments.add_argument('--client-secret',type=str)
arguments.add_argument('--port',type=str,default='19999')
args = arguments.parse_args()

os.environ['LOOKERSDK_BASE_URL']=args.base_url+str(':')+args.port
os.environ['LOOKERSDK_CLIENT_ID']=args.client_id
os.environ['LOOKERSDK_CLIENT_SECRET']=args.client_secret

sdk = looker_sdk.init31()
#TODO - run this content validator as the person that is requesting the pull request 

results = sdk.content_validation()
num_errors = len(results.content_with_errors)

f = open("looks.txt", "w")
f.write('• Looks Validated:   '+str(results.total_looks_validated))
f.close()

f = open("dashboards.txt", "w")
f.write('• Tiles Validated:   '+str(results.total_dashboard_elements_validated))
f.close()

f = open("explores.txt", "w")
f.write('• Explores Validated:    '+str(results.total_explores_validated))
f.close()

f = open("errors.txt", "w")
f.write('• Errors:    '+str(num_errors))
f.close()
# if num_errors > 0:
#     sys.exit(1) # to use with workflows where you want to notfiy on failure()
