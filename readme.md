## Docker

While not a technical requirement, interactions with this deployment are assumed to be performed within the docker container defined within this repo. This includes terraform executions and bastion ssh sessions.

```
# build
docker build -t eks -f docker/Dockerfile docker

# run
docker run -it --rm -v $HOME/.aws:/root/.aws -v $(pwd):/opt/eks eks
```

Alternatively AWS credentials can be setup w/i the docker directory in the event that a user does not want to expose credentials from `$HOME/.aws`.

```
# build
docker build -t eks -f docker/Dockerfile docker

# configure AWS CLI credentials (one-time setup)
docker run -it --rm -v $(pwd)/docker/aws:/root/.aws eks aws configure

# run
docker run -it --rm -v $(pwd)/docker/aws:/root/.aws -v $(pwd):/opt/eks eks
```

Once you have identified the docker run command that works for your setup, create a `run.sh` script which includes both the docker build and run commands to be used as part of your normal workflow.

## Provisioning

The terraform projects have dependencies on output values between each other which requires that they be applied in a specific order. The `terraform-backend` project manages the S3 bucket used as a tf backend for all projects in this deployment as well as the DynamoDB lock table. The contents of `backend.tf` should be commented out for the first `terraform init` and `terraform apply` executions so the backend resources can created. Once the S3 bucket and DynamoDB table have been created uncomment the contents of `backend.tf` and run `terraform init` and confirm that the local state should be imported to the S3 backend. The following projects should be applied locally in the defined order using the instructions listed above:

- `terraform-backend`
- `vpc`
- `ssh`
- `eks-cluster`
- `eks-compute`
- `bastion`
- `route53`
- `ecr`

The initial setup described above for the `terraform-backend` project can be performed using the following commands:

```
# start eks management docker container
./run.sh

# provision backend resources
cd /opt/eks/projects/terraform-backend

# remove any existing terraform state and temporarily
# remove terraform backend config before creating backend resources.
rm -rfv .terraform terraform.tfstate*
mv ./backend.tf /var/tmp

# provision resources
terraform init
terraform apply

# import local state to remote backend
mv /var/tmp/backend.tf .
terraform init
```

Once the initial backend setup has been completed terraform projects can be automatically applied using `tf.sh apply`.
```
# start management container if not already running
./run.sh

cd /opt/eks
./tf.sh apply
```

## Using an existing route53 zone

In order to use an existing route53 zone (instead of creating a new one) the route53 zone must be imported before running `tf.sh apply` or `terraform apply` in the route53 project directory.

```
cd projects/route53
terraform init
terraform import aws_route53_zone.primary <zone id>
```

## Provisioning K8S resources

Once all AWS terraform resources have been created (via `tf.sh apply` or manually using instructions above) some initial setup steps are required to setup K8S level authentication. Kubelet hosts will not be able to join the cluster and other admin IAM roles will not be able to access the K8S control plane API until a `aws_auth` ConfigMap is configured. Below is an example of how to perform the initial setup using the `eks` management container and bastion EC2 host:

```
# start eks management docker container
./run.sh

# sync the K8S terraform project to bastion host
./sync.sh

# ssh into bastion host
./bastion.sh

# using the AWS credentials used to provision the EKS cluster resource
# terraform apply the `aws_auth` ConfigMap.
cd ~/k8s
terraform init
env AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... terraform apply -target kubernetes_config_map.aws_auth
```

Once the initial AWS authentication setup is complete `kubectl` and `terraform` commands can be run on the bastion host w/o any external AWS credentials. Any running kubelet hosts should also start to join the cluster. The remaining K8S terraform resources should now be applied from the bastion host:

```
cd ~/k8s
terraform init
terraform apply
```

## Scaling kubelet hosts

Kubelet hosts are provisioned through the `eks-compute` auto-scaling group. A local script (`compute.sh`) can be used to control the desired number of instances to run using scheduled scaling events or by setting a static configuration. The examples below show some common use-cases for scaling kubelet hosts.

```
# start eks management container
./run.sh

cd /opt/eks

# print usage message
./compute.sh

# scale ephemeral compute (by default 1 instance for 1 hour)
./compute.sh scale-interval

# set a static number of instances to run
./compute.sh scale 3

# scale down instances
./compute.sh scale 0

# list auto-scaling group activity
./compute.sh activity

# describe auto-scaling group (including running EC2 instances)
./compute.sh describe
```

## Using kubectl

The EKS control plane is deployed within private subnets which requires that K8S clients like kubectl be used in envs that have access to the private cluster subnets and security groups. The provisioned bastion host is configured to automatically install and configure kubectl and can be used to interact with the K8S cluster.

```
# start eks management container
./run.sh

cd /opt/eks

# kubectl commands can be executed remotely
./bastion.sh kubectl get svc

# alternatively users can ssh into the bastion host and use kubectl directly
./bastion.sh

kubectl get nodes
kubectl get pods --all-namespaces
kubectl cluster-info dump
```
