IMAGE_NAME = hello-ecs
ECR_REPO = 519316597947.dkr.ecr.eu-west-1.amazonaws.com/hello-ecs
ECR_TAG = latest

build:
	docker build -t $(IMAGE_NAME):$(ECR_TAG) ./docker
tag:
	docker tag $(IMAGE_NAME):$(ECR_TAG) $(ECR_REPO):latest
push:
	docker push $(ECR_REPO):latest
