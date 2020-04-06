# Creating the workflows folder
Note you'll need to update the Looker host URL in the content_validator.yaml and spectacles.yaml if you want these actions to work on other instances.

You also  need to add 3 secrets to your github repo:
my_client_id = api client ID from your Looker instance
my_client_secret = api secret from your Looker instance
slack_webhook = webhook to notify slack.  Specific  to the slack instance  you want to  notify.
