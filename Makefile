now = $(shell date +%s)

prd:
	docker image build . -t e6e
	docker tag e6e localhost:32000/e6e:$(now)
	docker push localhost:32000/e6e:$(now)
	sed s/%TIMESTAMP%/$(now)/g k8s/prd/deployment_template.yaml > k8s/prd/deployment.yaml
	kubectl apply -f k8s/prd/deployment.yaml
e2e:
	docker image build . --target e2e -t e6e-e2e
	docker tag e6e-e2e localhost:32000/e6e-e2e:$(now)
	docker push localhost:32000/e6e-e2e:$(now)
	sed s/%TIMESTAMP%/$(now)/g k8s/e2e/deployment_template.yaml > k8s/e2e/deployment.yaml
	kubectl apply -f k8s/e2e/deployment.yaml