# Validation Instructions

1. Create the cluster:
```
   ./bootstrap.sh
```
2. Verify all pods are running:

```
kubectl get pods -n todo-app
kubectl get pods -n ingress-nginx
```
Check Ingress:
```
kubectl get ingress -n todo-app
```
Expected output:

```
NAME           CLASS   HOSTS       ADDRESS   PORTS   AGE
todo-ingress   nginx   localhost   ...       80      ...
```
Open in browser:

Go to http://localhost

You should see the ToDo app running.

Open DevTools → Network → confirm no requests return 404.

Test with curl:
```
curl http://localhost/
curl http://localhost/api/health
```