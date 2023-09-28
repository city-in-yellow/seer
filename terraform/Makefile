.PHONY: init
init:
	@terraform init -backend-config=../environment/backend.tfvars

.PHONY: plan
plan:
	@terraform plan -var-file=../environment/local.tfvars -input=false

.PHONY: apply
apply:
	@terraform apply -var-file=../environment/local.tfvars -input=false -auto-approve
