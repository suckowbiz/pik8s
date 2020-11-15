#!/usr/bin/env bash
#
# Intentionally created to run a smoke-test as described here:
# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/13-smoke-test.md

readonly GREP_RUNNING_NGINX='kubectl get pods -l app=nginx  |grep "Running" --count'
if [[ "${API_IP}" = "" ]]; then
  echo "Failure to read API_IP. Provide the current master node external IP to run tests."
  echo "Example: 'export API_IP=192.168.220.10'"
  exit
fi

echo "Cleaning up orphans from possible previous failed runs..."
kubectl delete deployments.apps nginx 2>/dev/null
kubectl delete service nginx 2>/dev/null
sleep 5

echo -e "\n\n1. Verifying the ability to create and manage deployments..."
kubectl create deployment nginx --image=nginx
echo "Waiting for nginx to be 'Running'..."
grep_result=$(eval "${GREP_RUNNING_NGINX}")
while [[ "${grep_result}" != "1" ]]; do
  grep_result=$(eval "${GREP_RUNNING_NGINX}")
  sleep 10
done
echo "Success. Found nginx 'Running'."
sleep 5

echo -e "\n\n2. Verifying the ability to access applications remotely using port forwarding"
readonly POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")
(kubectl port-forward "${POD_NAME}" 6080:80)&
readonly FORWARD_PID=$!
sleep 5
readonly CURL_RES=$(curl --silent --head http://127.0.0.1:6080 1>/dev/null; echo $?)
kill -9 ${FORWARD_PID}
if [[ "${CURL_RES}" = "0" ]]; then
  echo "Success. Service reachable."
else
  echo "Failure. Service not reachable."
  exit
fi

echo -e "\n\n3. Verify the ability to retrieve container logs."
readonly NGINX_LOGS=$(kubectl logs "${POD_NAME}")
readonly NGINX_LOG_GREP=$(echo "${NGINX_LOGS}" |grep HEAD --count)
if [[ "${NGINX_LOG_GREP}" = "0" ]]; then
  echo "Failure. No logs available."
  exit
else
  echo "Success. Logs available."
fi

echo -e "\n\n4. Verify the ability to execute commands in a container."
readonly CMD_RES=$(kubectl exec -ti "${POD_NAME}" -- nginx -v)
readonly CMD_RES_GREP=$(echo "${CMD_RES}" |grep version --count)
if [[ "${CMD_RES_GREP}" = "0" ]]; then
  echo "Failure. Command execution failed."
  exit
else
  echo "Success. Command execution succeeded."
fi

echo -e "\n\n5. Verify the ability to expose applications using service type NodePort."
kubectl expose deployment nginx --port 80 --type NodePort
sleep 5
readonly NODE_PORT=$(kubectl get svc nginx --output=jsonpath='{range .spec.ports[0]}{.nodePort}')
readonly SERVICE_CALL_RES=$(curl --silent --head "http://${API_IP}:${NODE_PORT}" 1>/dev/null; echo $?)
kubectl delete service nginx || true
echo "NodePort: ${NODE_PORT}"
if [[ "${SERVICE_CALL_RES}" = "0" ]]; then
  echo "Success. Service exposed."
else
  echo "Failure. Service not reachable."
  exit
fi

echo -e "\n\n6. Verify the ability to expose applications using service type LoadBalancer"
kubectl expose deployment nginx --port 80 --type LoadBalancer
sleep 5
readonly INGRESS_IP=$(kubectl get svc nginx --output=jsonpath='{range .status.loadBalancer.ingress[0]}{.ip}')
kubectl delete service nginx || true
echo "INGRESS_IP: ${INGRESS_IP}"
if [[ "${INGRESS_IP}" = "" ]]; then
  echo "Failure. No IP found."
  exit
else
  echo "Success. Service exposed."
fi

# TODO: Add a test for csi

echo -e '\n\n'
kubectl delete deployments.apps nginx 2>/dev/null
