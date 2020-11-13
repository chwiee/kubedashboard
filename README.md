# KUBEDASH

## Install

To install execute \
```kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.4/aio/deploy/recommended.yaml```

Change ```type:ClusterPort``` to ```type:NodePort``` \
```kubectl -n kubernetes-dashboard edit service kubernetes-dashboard ```

Create *_useradmin-role.yaml_* \

```
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
```

Apply the  *_useradmin-role.yaml_* \
```kubectl apply -f  useradmin-role.yaml```

## To access

Open in your Browser ```https://[nodeip]:[port]``` in logon screen select token and go terminal to execute this command:

```kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')```

Copy the token and paste in your browser.

## Automation

```bash wb-kubedash.sh $1```

When $1:
>apply  -> to create a dashboard kubernetes
>delete -> to delete the dashboard kubernetes
>token  -> to get token
>help   -> to help
