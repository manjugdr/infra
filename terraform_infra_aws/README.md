**Terraform Commands:**

#To initialize Terraform Plugins

**terraform init**

#To execute terraform plan.

**terraform plan -var-file="dev-terraform.tfvars"**

#To execute changes to infrastructure/ create infrastructure

**terraform apply -var-file="dev-terraform.tfvars"**

**terraform apply -var-file="dev-terraform.tfvars" -var "aws_access_key_id=##########" -var "aws_secret_access_key=#########"**

#To destroy the infrastruture created

**terraform destroy -var-file="dev-terraform.tfvars"**

**NOTE:**

-var-file indicates the variable file which varies for different environments
