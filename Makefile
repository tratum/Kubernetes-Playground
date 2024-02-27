.PHONY: help all create delete deploy check clean app webv test load-test jumpbox

help :
	@echo "Usage:"
	@echo "   make all              - create a cluster and deploy the apps"
	@echo "   make create           - create a k3d cluster"
	@echo "   make delete           - delete the k3d cluster"
	@echo "   make deploy           - deploy the apps to the cluster"
	
all : create deploy jumpbox

delete :
	# delete the cluster (if exists)
	@# this will fail harmlessly if the cluster does not exist
	@k3d cluster delete

create : delete
	@# create the cluster and wait for ready
	@# this will fail harmlessly if the cluster exists
	@# default cluster name is k3d

	@k3d cluster create --registry-use k3d-registry.localhost:5500 --config deploy/k3d.yaml --k3s-server-arg "--no-deploy=traefik" --k3s-server-arg "--no-deploy=servicelb"

	@sleep 10
	@kubectl wait pod -A --all --for condition=ready --timeout=60s

deploy :
	# deploy the app
	@# continue on most errors
	@kubectl apply -f deploy/ngsa-memory

	# deploy prometheus and grafana
	@kubectl apply -f deploy/prometheus
	@kubectl apply -f deploy/grafana

	# deploy fluent bit
	@kubectl apply -f deploy/fluentbit

	# wait for the pods to start
	@kubectl wait pod -n monitoring --for condition=ready --all --timeout=30s
	@kubectl wait pod -n logging fluentbit --for condition=ready --timeout=30s

	# display pod status
	@kubectl get po -A | grep "default\|monitoring\|logging"

clean :
	# delete the deployment
	@# continue on error
	-kubectl delete pod jumpbox --ignore-not-found=true
	-kubectl delete -f deploy/webv --ignore-not-found=true
	-kubectl delete -f deploy/ngsa-memory --ignore-not-found=true
	-kubectl delete ns monitoring --ignore-not-found=true
	-kubectl delete ns logging --ignore-not-found=true

	# show running pods
	@kubectl get po -A




