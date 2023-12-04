# This is Selenium Code Repository which helps automate the Advanced Authentication Server Web UI Cases
1. Make sure docker service is running
2. Create private - AWS ECR Repo like "aaf-audb", .... etc
3. eksctl delete cluster --region=us-east-1 --name=bharath-cloud-automation-cluster
4. aws cloudformation delete-stack --stack-name eksctl-bharath-cloud-automation-cluster-cluster