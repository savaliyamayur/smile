# smile
Smile Assessment
## Deploying REST API on AWS EKS with Terraform

This guide explains how to deploy your REST API on AWS Elastic Kubernetes Service (EKS) using Terraform, focusing on compute and security aspects.

**Prerequisites:**

* An AWS account with sufficient permissions to create necessary resources.
* Terraform installed and configured on your local machine.
* AWS CLI installed and configured with your AWS credentials.
* Docker installed and configured to build and push your API image.
* Kubernetes manifests for your API deployment (deployment.yaml, service.yaml, hpa.yaml).

**Steps:**

1. **Clone this repository:**

   ```bash
   git clone https://github.com/your-repo/your-rest-api-eks-terraform.git
   ```

2. **Update `variables.tf` (optional):**

   You can optionally update the `region` variable in `variables.tf` if you want to deploy in a different region than the default `us-east-1`.

3. **Install required dependencies:**

   ```bash
   cd your-rest-api-eks-terraform
   terraform init
   ```

4. **Build and push your API image:**

   Replace `my-rest-api:latest` with your actual image name and tag in the following command:

   ```bash
   docker build -t my-rest-api:latest .
   docker push my-rest-api:latest
   ```

5. **Deploy the infrastructure:**

   ```bash
   terraform apply
   ```

6. **Get the EKS cluster endpoint:**

   ```bash
   export KUBECTL_URL=$(terraform output -raw cluster_endpoint)
   ```

7. **Configure kubectl for EKS cluster access:**

   ```bash
   aws eks --region $AWS_REGION update-kubeconfig --name my-rest-api-cluster
   ```

8. **Apply Kubernetes manifests:**

   ```bash
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
   kubectl apply -f hpa.yaml
   ```

9. **Access your API:**

   The API endpoint will be available at the LoadBalancer address of the Kubernetes service. You can find the address using `kubectl get service my-rest-api`.


