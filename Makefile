now = $(shell date +%s)

prd:
	docker image build --file go/e6e/Dockerfile -t e6e go/e6e
	docker tag e6e localhost:32000/e6e:$(now)
	docker push localhost:32000/e6e:$(now)
	sed s/%TIMESTAMP%/$(now)/g k8s/prd/deployment_template.yaml > k8s/prd/deployment.yaml
	kubectl apply -f k8s/prd/deployment.yaml
e2e:
	docker image build --file go/ftr/Dockerfile -t ftr go/ftr
	docker tag ftr localhost:32000/ftr:$(now)
	docker push localhost:32000/ftr:$(now)

	docker image build --file go/e6e/Dockerfile -t e6e-e2e --target e2e go/e6e
	docker tag e6e-e2e localhost:32000/e6e-e2e:$(now)
	docker push localhost:32000/e6e-e2e:$(now)

	sed s/%TIMESTAMP%/$(now)/g k8s/e2e/deployment_template.yaml > k8s/e2e/deployment.yaml
	kubectl apply -f k8s/e2e/deployment.yaml