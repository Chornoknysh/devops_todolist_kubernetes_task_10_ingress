#!/bin/bash
set -euo pipefail

echo "=== Deploying MySQL ==="
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml -n todo-app
kubectl apply -f .infrastructure/mysql/secret.yml -n todo-app
kubectl apply -f .infrastructure/mysql/service.yml -n todo-app
kubectl apply -f .infrastructure/mysql/statefulSet.yml -n todo-app

echo "=== Deploying ToDo App ==="
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml -n todo-app
kubectl apply -f .infrastructure/app/pvc.yml -n todo-app

# Wait for PVC bound to avoid race condition
kubectl wait --for=condition=Bound pvc --all -n todo-app --timeout=60s

kubectl apply -f .infrastructure/app/secret.yml -n todo-app
kubectl apply -f .infrastructure/app/configMap.yml -n todo-app
kubectl apply -f .infrastructure/app/clusterIp.yml -n todo-app
kubectl apply -f .infrastructure/app/nodeport.yml -n todo-app
kubectl apply -f .infrastructure/app/hpa.yml -n todo-app
kubectl apply -f .infrastructure/app/deployment.yml -n todo-app

echo "=== Installing Ingress Controller ==="
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "=== Waiting for ingress-nginx controller to be ready ==="
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "=== Applying Ingress ==="
kubectl apply -f .infrastructure/ingress/ingress.yml -n todo-app

echo "=== Deployment finished! ==="
echo "Check resources with:"
echo "kubectl get pods -n todo-app"
echo "kubectl get pvc -n todo-app"
echo "kubectl get ingress -n todo-app"
echo
echo "Access your app at: http://localhost"
