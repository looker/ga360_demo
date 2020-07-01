#pip install lkml
#pip install PyGithub
#pip install git+https://github.com/llooker/lookml.git@f69ee32e880cada8d8e353e19a39ddfc6cdc1371
#pip install looker-sdk

import os
import json
import re
import argparse

import lookml
import looker_sdk

arguments = argparse.ArgumentParser()
arguments.add_argument('--base-url',type=str,help='URL of Looker instance',required=True)
arguments.add_argument('--client-id',type=str,help='API3 Client ID',required=True)
arguments.add_argument('--client-secret',type=str,help='API3 Secret',required=True)
arguments.add_argument('--port',type=str,default='19999',help='API Port, [Default 19999]')
arguments.add_argument('--github-token',type=str,help='Github token used to write LookML to repo',required=True)
arguments.add_argument('--project',type=str,help='Which project to write LookML to',required=True)
arguments.add_argument('--repo',type=str,help='Which repo to write LookML to',required=True)

args = arguments.parse_args()

os.environ['LOOKERSDK_BASE_URL']=args.base_url+str(':')+args.port
os.environ['LOOKERSDK_CLIENT_ID']=args.client_id
os.environ['LOOKERSDK_CLIENT_SECRET']=args.client_secret

## Use the Looker SDK to query Looker for the values we want for our measures:
sdk = looker_sdk.init31()

# This query gives us the fields we need to generate our LookML
model = 'google_analytics_block'
explore = 'ga_sessions'
fields = [
    'hits_eventInfo.eventAction',
    'hits_eventInfo.eventCategory',
]

body = looker_sdk.models.WriteQuery(
  model= model,
  view= explore, #explore is what view means here...
  fields= fields,
)

results = sdk.run_inline_query('json', body)
resultsList = json.loads(results)


#Setup pyLookML
proj = lookml.Project(
    repo= args.repo
    ,access_token=args.github_token
    ,looker_host=args.base_url+'/'
    ,looker_project_name=args.project
)

def number_of_fields():
        viewFile = proj.file('custom_events.view.lkml')
        customEvents = viewFile.views.custom_events
        return len(customEvents)

try:
    fields_start = number_of_fields()
except:
    fields_start = 0

#create a new LookML view
customEventsView = lookml.View('custom_events')
customEventsView.setExtensionRequired()
customEventsView.setMessage('README: This view is auto-generated by pyLookML (see generate_lookml.py)')

#For each result create a measure
for row in resultsList:
    eventAction=row['hits_eventInfo.eventAction']
    eventCategory=row['hits_eventInfo.eventCategory']
    if eventAction:
        measure_name = lookml.snakeCase(eventAction.replace(' ', '_'))
        measure = lookml.Measure(measure_name)
        measure.setLabel(eventAction)
        measure.setProperty('group_label', eventCategory)
        measure.setType('count')
        measure.setProperty('filters',[{'field': 'eventAction', 'value': eventAction}])

        customEventsView + measure


#Create/append to a new file
newFile = lookml.File(customEventsView)
proj.put(newFile)
proj.deploy()

fields_end = number_of_fields()
print(str(fields_end-fields_start) + ' fields added to ' +newFile.path )