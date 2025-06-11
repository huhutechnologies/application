# based on https://cloud.google.com/build/docs/build-push-docker-image

# Enable the APIs
https://console.cloud.google.com/flows/enableapi?apiid=cloudbuild.googleapis.com,compute.googleapis.com,artifactregistry.googleapis.com&redirect=https://cloud.google.com/cloud-build/docs/quickstart-automate


######
# CHECK PERMISSIONS
######

# Extract client_email from sa.json
EMAIL=$(jq -r '.client_email' ../../cluster/sa.json)
PROJECT_ID=$(jq -r '.project_id' ../../cluster/sa.json)

# Check for roles/storage.objectUser role
STORAGE_ROLE=$(gcloud projects get-iam-policy $PROJECT_ID \
  --format="json" | jq -r '.bindings[] | select(.role=="roles/storage.objectUser") | .members[] | select(. == "serviceAccount:'$EMAIL'") | .')

# Check for roles/artifactregistry.writer role
ARTIFACT_ROLE=$(gcloud projects get-iam-policy $PROJECT_ID \
  --format="json" | jq -r '.bindings[] | select(.role=="roles/artifactregistry.writer") | .members[] | select(. == "serviceAccount:'$EMAIL'") | .')

# Output results --- They result empty in ACG project
echo "Service Account: $EMAIL"
echo "Has roles/storage.objectUser: $([ -n "$STORAGE_ROLE" ] && echo "Yes" || echo "No")"
echo "Has roles/artifactregistry.writer: $([ -n "$ARTIFACT_ROLE" ] && echo "Yes" || echo "No")"

######
# CHECK PERMISSIONS --end 
######


mkdir quickstart-docker
cd quickstart-docker

touch Dockerfile
chmod +x quickstart.sh

REGISTRY_URL=$(terraform output -state="../../../cluster/terraform.tfstate" -raw gc_artifact_registry_url)
REGION=$(terraform output -state="../../../cluster/terraform.tfstate" -raw region)

# build with cloudbuild from cli
gcloud builds submit --region=$REGION --tag $REGISTRY_URL/quickstart-image:tag1

# OR Using  cloudbuild file

cat <<EOF > cloudbuild.yaml
steps:
- name: 'gcr.io/cloud-builders/docker'
  script: |
    docker build -t $REGISTRY_URL/quickstart-image:tag1 .
  automapSubstitutions: true
images:
- '$REGISTRY_URL/quickstart-image:tag1'
EOF

# start the build
gcloud builds submit --region=$REGION --config cloudbuild.yaml