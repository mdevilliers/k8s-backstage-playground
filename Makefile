KIND_INSTANCE=k8s-backstage-playground

BACKSTAGE_APP=my-backstage-app
BACKSTAGE_VERSION=1.0.0
BACKSTAGE_DOCKER_IMAGE_NAME=backstage

# creates a K8s instance
.PHONY: k8s_new
k8s_new:
	kind create cluster --config ./kind/kind.yaml --name $(KIND_INSTANCE)

# deletes a k8s instance
.PHONY: k8s_drop
k8s_drop:
	kind delete cluster --name $(KIND_INSTANCE)

# sets KUBECONFIG for the K8s instance
.PHONY: k8s_connect
k8s_connect:
	kind export kubeconfig --name $(KIND_INSTANCE)

# loads the docker containers into the kind environment
.PHONY: k8s_side_load
k8s_side_load:
	kind load docker-image backstage:$(BACKSTAGE_VERSION) --name $(KIND_INSTANCE)

.PHONY: install
install: k8s_connect
	kubectl apply -f k8s/backstage.yaml

.PHONY: port_forward
port_forward:
	sudo kubectl port-forward --namespace=backstage svc/backstage 80:80

.PHONY: build_backstage
build_backstage:
	cd ${BACKSTAGE_APP} && yarn install --frozen-lockfile && yarn tsc && yarn build

.PHONY: build_backstage_image
build_backstage_image:
	docker image build -f ${BACKSTAGE_APP}/packages/backend/Dockerfile --tag ${BACKSTAGE_DOCKER_IMAGE_NAME}:${BACKSTAGE_VERSION} ./${BACKSTAGE_APP}
