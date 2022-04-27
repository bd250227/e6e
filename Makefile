now = $(shell date +%s)

prd:
	docker image build --file go/urproj/Dockerfile -t urproj go/urproj
	docker tag e6e localhost:32000/urproj:$(now)
	docker push localhost:32000/urproj:$(now)
	sed s/%TIMESTAMP%/$(now)/g k8s/prd/deployment_template.yaml > k8s/prd/deployment.yaml
	kubectl apply \
		-f k8s/namespace.yaml \
		-f k8s/prd/deployment.yaml \
		-f k8s/prd/service.yaml
e2e:
	docker image build --file go/ftr/Dockerfile -t ftr go/ftr
	docker tag ftr localhost:32000/ftr:$(now)
	docker push localhost:32000/ftr:$(now)

	docker image build --file go/urproj/Dockerfile -t urproj-e2e --target e2e go/urproj
	docker tag urproj-e2e localhost:32000/urproj-e2e:$(now)
	docker push localhost:32000/urproj-e2e:$(now)

	sed s/%TIMESTAMP%/$(now)/g k8s/e2e/deployment_template.yaml > k8s/e2e/deployment.yaml
	kubectl apply \
		-f k8s/namespace.yaml \
		-f k8s/e2e/deployment.yaml \
		-f k8s/e2e/service.yaml
cleanup:
	kubectl delete \
		-f k8s/e2e/service.yaml \
		-f k8s/prd/service.yaml \
		-f k8s/e2e/deployment.yaml \
		-f k8s/prd/deployment.yaml \
		-f k8s/namespace.yaml