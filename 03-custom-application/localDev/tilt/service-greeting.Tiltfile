# ignore all kustomization files
watch_settings(['../../development/service/greeting/k8s/**/kustomization.yaml'])


# https://docs.tilt.dev/api.html#api.custom_build
custom_build(
  'localhost:5003/development/greeting',
  '../../development/build-scripts/build-deploy-greeting-local.sh "$EXPECTED_TAG"',
  ['../../development/service/greeting']
)

k8s_yaml('../../development/build-reports/service/greeting/k8s/k8s-local.yaml')


#custom_build(
#  'localhost:5003/development/greeting',
#  '../../development/build-scripts/generic-docker-build.sh -t "localhost:5003/development/greeting" -p "service/greeting" -m "debug" -v "$EXPECTED_TAG" -n "localhost:5003/development/service-base-image:latest" -c "localhost:5003/development/greeting:latest"',
#  ['../../development/service/greeting']
#)


# k8s_yaml automatically creates resources in Tilt for the entities
# and will inject any images referenced in the Tiltfile when deploying
# https://docs.tilt.dev/api.html#api.k8s_yaml
# k8s_yaml(kustomize('../../development/service/greeting/k8s/local'))
# k8s_yaml('../../development/build-reports/service/greeting/k8s/k8s-local.yaml')

#myGeneratedYaml = local('../../development/build-scripts/generic-k8s-build.sh -p "service/greeting"  -t "greeting" -d "localhost:5003/development/greeting:$EXPECTED_TAG" -m "local"')
#k8s_yaml(myGeneratedYaml)

#k8s_resource(
#    workload='greeting',
#    objects=['greeting:Ingress:local'],
#    port_forwards='30015:5005'
#)






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





