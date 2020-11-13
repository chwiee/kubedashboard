#!/bin/bash
#-- Wallace Bruno Gentil
#-- Script tp deploy the kubernetes dashboard 

check () {
  if [ $1 -eq 0 ]; then echo -e "[  Ok  ]" ; else echo -e "[ Fail ]" ; exit 1 ; fi
}

apply () {
  printf '%-120s' 'Using recommended.yaml to create Kubernetes Dashboard'
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.4/aio/deploy/recommended.yaml &>/dev/null
  check $?

  printf '%-120s' 'Exposing the dashboard-svc'
  kubectl -n kubernetes-dashboard get service kubernetes-dashboard -o yaml | sed "s/ClusterIP/NodePort/" | kubectl replace -f - &>/dev/null
  check $?

  sleep 10

  printf '%-120s' 'Creating useradmin-role.yaml'
  cat <<EOF >>useradmin-role.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard

EOF
  check $?

  printf '%-120s' 'Apply role'
  kubectl apply -f  useradmin-role.yaml --validate=false &>/dev/null
  check $?

  printf '%-120s' 'Deleting yaml file'
  rm -f useradmin-role.yaml &>/dev/null
  check $?

  printf '%-120s' 'Get external IP and port to access'
  PORTDASH=$(kubectl get svc -n kubernetes-dashboard | grep NodePort | awk '{print $5}' | awk -F':' '{print $2}' | awk -F'/' '{print $1}')
  IPDASH=$(kubectl get nodes -o wide | grep $(kubectl get pods -n kubernetes-dashboard -o wide | grep kubernetes-dashboard | awk '{print $7}') | awk {'print $7'})
  check $?

  echo "
    Open your browser and access the link below with the token type access data listed below
    URL: https://$IPDASH:$PORTDASH

    $(token)
  "
  
}

delete () {
  printf '%-120s' 'Using recommended.yaml to delete Kubernetes Dashboard'
  kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.4/aio/deploy/recommended.yaml -n kubernetes-dashboard &>/dev/null
  check $?

  echo '
    Delete Dashboard Kubernetes with sucess
  '
}

token () {
    kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') | awk 'END{print}'
}

case $1 in
  'apply')
    apply
  ;;
  'delete')
    delete
  ;;
  'token')
    token
  ;;
  '--help')
    echo 'wb-kubedash.sh man:
    This script need follow args \$1:
    
    apply   ->  Create and expose the kubernetes-dashboard for world.
    delete  ->  Delete pods,svc,deploy,namespace and others about kubernetes-dashboard'
  ;;
  *)
    echo 'Invalid parameter $1 use --help to help'
  ;;
esac