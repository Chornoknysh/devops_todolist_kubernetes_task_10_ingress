#!/bin/bash
set -euo pipefail

echo "=== Deploying MySQL ==="
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

echo "=== Deploying ToDo App ==="
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml

# Wait for PVC bound to avoid race condition
kubectl wait --for=condition=Bound pvc --all -n app --timeout=60s

kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/app/deployment.yml

echo "=== Installing Ingress Controller ==="
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "=== Waiting for ingress-nginx controller to be ready ==="
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "=== Applying Ingress ==="
kubectl apply -f .infrastructure/ingress/ingress.yml

echo "=== Deployment finished! ==="
echo "Check resources with:"
echo "kubectl get pods -n mysql"
echo "kubectl get pods -n app"
echo "kubectl get ingress -n app"
echo
echo "Access your app at: http://localhost"
