#!/usr/bin/env bash

# set the stubdomain to the ip address of the input variable

read -rp 'Please enter consul-dns-service-name': CONSUL_DNS_SERVICE_NAME

CONSUL_DNS_CLUSTER_IP=$(kubectl get svc ${CONSUL_DNS_SERVICE_NAME} -o jsonpath='{.spec.clusterIP}')

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    addonmanager.kubernetes.io/mode: EnsureExists
  name: kube-dns
  namespace: kube-system
data:
  stubDomains: |
    {"consul": ["$CONSUL_DNS_IP"]}
EOF

printf "Now outputting the contents of the kube-dns configmap....."
kubectl get configmap kube-dns -n kube-system -o yaml