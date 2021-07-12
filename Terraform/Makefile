####
#   Install terraform and init
####

prepare:
	@echo "\e[1;34mInstalling Terraform \e[0m"
	sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
	curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
	#sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
	sudo apt-get update && sudo apt-get install terraform
	terraform version
	@echo "\e[1;34mInstalling ansible\e[0m"
	sudo apt install python3-pip -y
	pip3 install ansible boto 

init:
	@echo "\e[1;34mSetting up backend \e[0m"
	@cd  && ansible-playbook backend/backend.yml -e "aws_region=$$aws_region bucket_name=$$bucket_name dynamo_table=$$dynamo_table"
	@echo "\e[1;34mInitialise Terraform \e[0m"
	@terraform init

plan:
	@echo "\e[1;34mTerraform plan for $$env environment \e[0m"
	terraform workspace select $$env || terraform workspace new $$env
	terraform plan --var-file environments/$$env.tfvars

apply:
	@echo "\e[1;34mTerraform apply for $$env environment \e[0m"
	terraform workspace select $$env || terraform workspace new $$env
	terraform apply --auto-approve --var-file environments/$$env.tfvars
   
destroy:
	@echo "\e[1;34mTerraform destroy for $$env environment \e[0m"
	terraform workspace select $$env
	terraform destroy --auto-approve --var-file environments/$$env.tfvars

setup_bastion:
	@echo "\e[1;34mSetting Up Bastion Hosts \e[0m"
	@cd ../Ansible && ansible-playbook configure_bastion.yml \
	-e "aws_access_key=$(shell sh -c 'terraform output -raw bastion_user_access_key') \
	aws_secret_key=$(shell sh -c  'terraform output -raw bastion_user_secret_key') \
	aws_region=$(shell sh -c  'terraform output -raw aws_region') \
	s3_access_key=$(shell sh -c 'terraform output -raw s3_access_key') \
	s3_secret_key=$(shell sh -c 'terraform output -raw s3_secret_key') \
    s3_region=$(shell sh -c  'terraform output -raw aws_region')    \
	s3_bucket=$(shell sh -c  'terraform output -raw s3_bucket_name')" --private-key ../ssh_keys/one2n-dev-bastion.pem

setup_server:
	@echo "\e[1;34mConfiguring Servers\e[0m"
	ssh ec2-user@ec2-65-1-111-96.ap-south-1.compute.amazonaws.com -i ssh_keys/one2n-dev-bastion.pem  "cd ansible && ansible-playbook configure_server.yml"

deploy_registy:
	@echo "\e[1;34mDeploying Registry \e[0m"
	ssh ec2-user@ec2-65-1-111-96.ap-south-1.compute.amazonaws.com -i ssh_keys/one2n-dev-bastion.pem  "cd ansible && ansible-playbook registry.yml"
