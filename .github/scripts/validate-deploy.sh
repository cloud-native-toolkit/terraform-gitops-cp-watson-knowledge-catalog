#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

export KUBECONFIG=$(cat .kubeconfig)
NAMESPACE=$(cat .namespace)
COMPONENT_NAME=$(jq -r '.name // "my-module"' gitops-output.json)
SUBSCRIPTION_NAME=$(jq -r '.sub_name // "sub_name"' gitops-output.json)
INSTANCE_NAME=$(jq -r '.instance_name // "instance_name"' gitops-output.json)
OPERATOR_NAMESPACE=$(jq -r '.operator_namespace // "operator_namespace"' gitops-output.json)
CPD_NAMESPACE=$(jq -r '.cpd_namespace // "cpd_namespace"' gitops-output.json)
BRANCH=$(jq -r '.branch // "main"' gitops-output.json)
SERVER_NAME=$(jq -r '.server_name // "default"' gitops-output.json)
LAYER=$(jq -r '.layer_dir // "2-services"' gitops-output.json)
TYPE=$(jq -r '.type // "base"' gitops-output.json)

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

if [[ ! -f "argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml" ]]; then
  echo "ArgoCD config missing - argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"
  exit 1
fi

echo "Printing argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"
cat "argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"

if [[ ! -f "payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml" ]]; then
  echo "Application values not found - payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"
  exit 1
fi

echo "Printing payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"
cat "payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"

count=0
until kubectl get namespace "${NAMESPACE}" 1> /dev/null 2> /dev/null || [[ $count -eq 20 ]]; do
  echo "Waiting for namespace: ${NAMESPACE}"
  count=$((count + 1))
  sleep 15
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for namespace: ${NAMESPACE}"
  exit 1
else
  echo "Found namespace: ${NAMESPACE}. Sleeping for 30 seconds to wait for everything to settle down"
  sleep 30
fi

echo "CP4D Operators namespace : "${OPERATOR_NAMESPACE}""
echo "CP4D namespace : "${CPD_NAMESPACE}""

CSV=""
count=0
csvstr="ibm-cpd-wkc."
while [ true ]; do
  sleep 60
  CSV=$(kubectl get sub -n "${OPERATOR_NAMESPACE}" "${SUBSCRIPTION_NAME}" -o jsonpath='{.status.installedCSV} {"\n"}')
  echo "Found CSV : "${CSV}""
  count=$((count + 1))
  if [[ $CSV == *"$csvstr"* ]];
  then
      echo "Found CSV : "${CSV}""
      break
  fi
  if [[ $count -eq 120 ]]; then
    echo "Timed out waiting for CSV"
    exit 1
  fi
done

SUB_STATUS=0
while [[ $SUB_STATUS -ne 1 ]]; do
  sleep 10
  SUB_STATUS=$(kubectl get deployments -n "${OPERATOR_NAMESPACE}" -l olm.owner="${CSV}" -o jsonpath="{.items[0].status.availableReplicas} {'\n'}")
  echo "Waiting for subscription "${SUBSCRIPTION_NAME}" to be ready in "${OPERATOR_NAMESPACE}""
done

echo "WKC Operator is READY"
sleep 60
INSTANCE_STATUS=""
while [ true ]; do
  INSTANCE_STATUS=$(kubectl get WKC "${INSTANCE_NAME}" -n "${CPD_NAMESPACE}" -o jsonpath='{.status.wkcStatus} {"\n"}')
  echo "Waiting for instance "${INSTANCE_NAME}" to be ready. Current status : "${INSTANCE_STATUS}""
  if [ $INSTANCE_STATUS == "Completed" ]; then
    break
  fi
  sleep 30
done

echo "Watson Knowledge Catalog WKC/"${INSTANCE_NAME}" is "${INSTANCE_STATUS}""

#Cleanup WKC
echo "Cleaning up UG"
UGCR=$(oc get ug "${CPD_NAMESPACE}" --no-headers | awk '{print $1}')
oc patch ug $UGCR -n "${CPD_NAMESPACE}" -p '{"metadata":{"finalizers":[]}}' --type=merge
oc delete ug -n "${CPD_NAMESPACE}" $UGCR

UGCRD=$(oc get crd "${CPD_NAMESPACE}" --no-headers | grep ug.wkc | awk '{print $1}')
oc delete crd -n "${CPD_NAMESPACE}" $UGCRD

echo "Cleaning up IIS"
IISCR=$(oc get iis "${CPD_NAMESPACE}" --no-headers | awk '{print $1}')
oc patch iis $IISCR -n "${CPD_NAMESPACE}" -p '{"metadata":{"finalizers":[]}}' --type=merge
oc delete iis -n "${CPD_NAMESPACE}" $IISCR

IISCRD=$(oc get crd "${CPD_NAMESPACE}" --no-headers | grep iis | awk '{print $1}')
oc delete crd -n "${CPD_NAMESPACE}" $IISCRD

oc delete sub ibm-cpd-iis-operator -n "${OPERATOR_NAMESPACE}"

IISCSV=$(oc get csv -n "${OPERATOR_NAMESPACE}" --no-headers | grep ibm-cpd-iis | awk '{print $1}')
oc delete csv $IISCSV -n "${OPERATOR_NAMESPACE}"

DB2OR=$(oc get operandrequests -n "${CPD_NAMESPACE}" --no-headers | grep iis-requests-db2uaas | awk '{print $1}')
oc delete operandrequests $DB2OR -n "${CPD_NAMESPACE}"

oc delete catsrc ibm-cpd-iis-operator-catalog -n openshift-marketplace

echo "Cleaning up WKC"
WKCCR=$(oc get wkc "${CPD_NAMESPACE}" --no-headers | awk '{print $1}')
oc patch wkc $WKCCR -n "${CPD_NAMESPACE}" -p '{"metadata":{"finalizers":[]}}' --type=merge
oc delete wlc -n "${CPD_NAMESPACE}" $WKCCR

WKCCRD=$(oc get crd "${CPD_NAMESPACE}" --no-headers | grep wkc.wkc | awk '{print $1}')
oc delete crd -n "${CPD_NAMESPACE}" $WKCCRD

oc delete sub "${SUBSCRIPTION_NAME}" -n "${OPERATOR_NAMESPACE}"

WKCCSV=$(oc get csv -n "${OPERATOR_NAMESPACE}" --no-headers | grep wkc | awk '{print $1}')
oc delete csv $WKCCSV -n "${OPERATOR_NAMESPACE}"

echo "Cleaning up operandrequests"
$ORCERT=$(oc get operandrequests -n "${CPD_NAMESPACE}" --no-headers | grep cert-mgr-dep | awk '{print $1}')
oc delete operandrequest $ORCERT -n "${CPD_NAMESPACE}"
oc delete operandrequest wkc-requests-ccs -n "${CPD_NAMESPACE}"
oc delete operandrequest wkc-requests-datarefinery -n "${CPD_NAMESPACE}"
oc delete operandrequest wkc-requests-db2uaas -n "${CPD_NAMESPACE}"
oc delete operandrequest wkc-requests-iis -n "${CPD_NAMESPACE}"

oc delete catsrc ibm-cpd-wkc-operator-catalog -n openshift-marketplace

echo "Cleaning up installplan"
WKCIP=$(oc get ip -n "${OPERATOR_NAMESPACE}" --no-headers | grep wkc | awk '{print $1}')
IISIP=$(oc get ip -n "${OPERATOR_NAMESPACE}" --no-headers | grep iis | awk '{print $1}')
oc delete ip $WKCIP -n "${OPERATOR_NAMESPACE}"
oc delete ip $IISIP -n "${OPERATOR_NAMESPACE}"

cd ..
rm -rf .testrepo