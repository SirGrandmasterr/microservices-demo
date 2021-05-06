# Setting up the infrastructure on Google Kubernetes Engine (GKE)

The Docker images and Helm charts can be deployed on any Kubernetes Cluster. In this case, the infrastructure was set up through the Google Kubernetes Engine (GKE).
However, if the Kubernetes Cluster was set up on any other cloud provider or on-premise, the Helm charts can be used directly to do the deployments of the application components on the existing infrastructure.

## Prerequisites

* Install Terraform (see https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/gcp-get-started)
* Install the gcloud sdk (see https://cloud.google.com/sdk) in case the GCP commands are executed from the local machine instead of using Google Cloud Shell
* GCP Billing is enabled for the used project (see https://cloud.google.com/billing/docs/how-to/modify-project?hl=de)
* Google Container Registry API is enabled in order to deploy the Docker containers from there
  This could be done from the GCP console (see https://cloud.google.com/service-usage/docs/enable-disable) or through the GCloud SDK by using the following command:
  ```
    gcloud services enable container.googleapis.com
  ```
* Make sure that gcloud config is pointing to the correct GCP project:
  ```
    gcloud config set project adept-bond-312518
  ```
* Required Docker images are built and available for deployment
* Required Docker containers are pushed into a Docker Registry, which are used on the Helm charts


## Setup GKE cluster and deploying the applications
_Skip this section if there is already an existent Kubernetes Cluster_
* Use Google Cloud Shell (see https://cloud.google.com/shell) or the gcloud sdk with a cli to run the commands from your local machine
* Authenticate through gcloud if no gcp service account is used:
  ```
  gcloud auth application-default login
  ```
* Create Service Account for Terraform
  ```
  gcloud iam service-accounts create terraform \
   --description="This service account is used for Terraform" \
   --display-name="Terraform"
  ```
* Create IAM policy binding
  ```
  gcloud projects add-iam-policy-binding adept-bond-312518 \
   --member="serviceAccount:terraform@adept-bond-312518.iam.gserviceaccount.com" \
   --role="roles/owner"
  ```
* Add IAM policy binding service account user to user accounts
  ```
  gcloud iam service-accounts add-iam-policy-binding \
   terraform@adept-bond-312518.iam.gserviceaccount.com \
   --member="user:MY_GCP_EMAIL_ADDRESS" \
   --role="roles/iam.serviceAccountUser"
  ```
  _While Replacing MY_GCP_EMAIL_ADDRESS with the real account_
* Create service account key for Terraform
  ```
  gcloud iam service-accounts keys create ./key.json \
  --iam-account terraform@adept-bond-312518.iam.gserviceaccount.com
  ```
  _After the key.json file has been created, it has to be copied to the Terraform directory (`/infrastructure/k8s/terraform`) so that it could be used for the Terraform commands below_
* Retrieve the IAM roles if required:
  ```
  gcloud projects get-iam-policy adept-bond-312518 \
  --flatten="bindings[].members" \
  --format='table(bindings.role)' \
  --filter="bindings.members:terraform@adept-bond-312518.iam.gserviceaccount.com"
  ```
* Create the Google Cloud Storage bucket through the GCP console:
  ```
  adept-bond-312518
  ```
  _Rename the name of the bucket if it is not unique. It has to match what is set on the `/infrastructure/k8s/terraform/backend.tf` file_

* Navigate to the folder k8s/terraform and initialize Terraform through the command:
  ```
  terraform init
  ```
* Validate the Terraform plan:
  ```
  terraform plan
  ```
* Apply the Terraform plan and confirm the action:
  ```
  terraform apply
  ```
  _Note: GCP APIs should have been enabled. If not, it could be done through the GCP console as well._
* Repeat the Terraform commands in the same order to apply new changes or in case of failures, i.e.:
  ```
  terraform init
  terraform plan
  terraform apply
  ```
* Configure kubectl with Terraform using the files under `/infrastructure/k8s/terraform`:
  ```
  gcloud container clusters get-credentials $(terraform output cluster_name) --zone $(terraform output zone)
  ```

_Note: Auto scaling could be enabled by adjusting some values on the Terraform files (see comments on the files)_ 

If the Terraform files are not used to deploy the infrastructure and applications, the applications can be deployed through the Helm charts as well (see below TBD).
Otherwise, the Helm commands don't have to be executed since the components should be deployed via Terraform (TBD).

## Deploy infrastructure components with Helm charts
_Note: This part can be skipped if all components were deployed through Terraform_
Kafka, and Prometheus, can be deployed on a Kubernetes cluster using the [Helm](https://helm.sh) charts located in the ``helm`` directory. Configure which charts to deploy in the global values.yaml by setting ``enabled: true`` for each desired component. Cluster sizes and ports for external access can also be specified here.

Each subchart can be deployed by itself and contains its own values.yaml file with further configurations. If deployed from the umbrella chart, values in the global values.yaml will overwrite the values in the subchart's values.yaml.

Deploy the charts with:
```
helm install [DEPLOYMENT NAME] [CHART DIRECTORY]
```

Uninstall the charts with:
```
helm uninstall [DEPLOYMENT NAME]

## Clean Up
Use the command to delete specific Terraform resource, e.g.:
  ```
  terraform destroy -target helm_release.observability_backend
  ```
_Note: Skip the -target part if all resources managed by Terraform should be destroyed_

## Troubleshooting
* Sometimes the Terraform commands don't work immediately. In that case, repeat the Terraform commands mentioned above (see https://stackoverflow.com/questions/62106154/frequent-error-when-deploying-helm-to-gke-with-terraform)
* Update the latest GKE stable version if errors are thrown related to that on the Terraform main.tf file
* Enable the APIs manually through the GCP console if required
* Get cluster credentials without Terraform if required
  ```
  gcloud container clusters get-credentials adept-bond-312518-cluster --zone europe-west3-a
  ```
