now = $(shell date +%s)

prd:
	docker image build . -t localhost:32000/e6e:$(now)
	docker push localhost:32000/e6e:$(now)
	sed s/%TIMESTAMP%/$(now)/g k8s/prd/deployment_template.yaml > k8s/prd/deployment.yaml
	kubectl apply -f k8s/prd/deployment.yaml
# e2e:
# 	docker image build . --file e2e.Dockerfile -t localhost:32000/e6e-e2e:$(now)
# 	docker push localhost:32000/e6e-e2e:$(now)
# 	sed s/%TIMESTAMP%/$(now)/g k8s/e2e/deployment_template.yaml > k8s/e2e/deployment.yaml
# 	kubectl apply -f k8s/e2e/deployment.yaml
staged-e2e:
	docker image build . --target e2e -t localhost:32000/e6e-e2e:$(now)
	docker push localhost:32000/e6e-e2e:$(now)
	sed s/%TIMESTAMP%/$(now)/g k8s/e2e/deployment_template.yaml > k8s/e2e/deployment.yaml
	kubectl apply -f k8s/e2e/deployment.yaml