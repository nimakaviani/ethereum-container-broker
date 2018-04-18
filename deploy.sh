#/bin/bash
export BOSH_DEPLOYMENT=docker-broker

# name of cf deployment in BOSH, e.g. 'cf'
cf_deployment=cf

system_domain=$(bosh -d $cf_deployment manifest | bosh int - --path /instance_groups/name=api/jobs/name=cloud_controller_ng/properties/system_domain)
skip_verify=$(bosh -d $cf_deployment manifest | bosh int - --path /instance_groups/name=api/jobs/name=cloud_controller_ng/properties/ssl/skip_cert_verify)
admin_password=$(bosh -d $cf_deployment manifest | bosh int - --path /instance_groups/name=uaa/jobs/name=uaa/properties/uaa/scim/users/name=admin/password)

echo $system_domain
echo $skip_verify
echo $admin_password

bosh deploy -n manifests/docker-broker.yml \
  -o manifests/local-release.yml \
  -o manifests/operators/cf-integration.yml \
  -o manifests/operators/services/geth.yml \
  -v cf-api-url=https://api.$system_domain \
  -v cf-skip-ssl-validation=$skip_verify \
  -v cf-admin-username=admin \
  -v "cf-admin-password=$admin_password" \
  -v broker-route-name=docker-broker \
  -v broker-route-uri=docker-broker.$system_domain \
  --vars-file creds.yml
