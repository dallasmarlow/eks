## Provisioning

The terraform projects have dependencies on output values between each other which requires that they be applied in a specific order. The `terraform-backend` project manages the S3 bucket used as a tf backend for all projects in this deployment as well as the DynamoDB lock table. The contents of `backend.tf` should be commented out for the first `terraform init` and `terraform apply` executions so the backend resources can created. Once the S3 bucket and DynamoDB table have been created uncomment the contents of `backend.tf` and run `terraform init` and confirm that the local state should be imported to the S3 backend. The following projects should be applied locally in the defined order using the instructions listed above:

- `terraform-backend`
- `vpc`
- `eks-cluster`
- `bastion`
- `route53`
- `ecr`

## Docker

```
# build
docker build -t eks -f docker/Dockerfile docker

# run
docker run -it --rm -v $(pwd):/opt/eks -v $HOME/.aws:/root/.aws eks
```