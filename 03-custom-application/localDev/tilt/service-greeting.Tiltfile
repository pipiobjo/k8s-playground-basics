# ignore all kustomization files
watch_settings(['../../development/service/greeting/k8s/**/kustomization.yaml'])


# https://docs.tilt.dev/api.html#api.custom_build
custom_build(
  'localhost:5003/development/greeting',
  '../../development/build-scripts/build-deploy-greeting-local.sh "$EXPECTED_TAG"',
  ['../../development/service/greeting']
)

k8s_yaml('../../development/build-reports/service/greeting/k8s/k8s-local.yaml')



#
# custom buttons - https://docs.tilt.dev/buttons.html
#
load('ext://uibutton', 'cmd_button')
cmd_button('blueprint-greeting:forward debug port',
         argv=['sh', '-c', 'kubectl -n dbc port-forward deployment/greeting 31001:5082'],
         resource='greeting',
         icon_name='pest_control',
         text='Debug (Port 31001)',
)





