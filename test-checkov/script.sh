# based on 
https://github.com/PaloAltoNetworks/prisma-cloud-devsecops-workshop/blob/main/guide/DevSecOps-lab.md#section-1-code-scanning-with-checkov
python -m venv .checkov
source .checkov/bin/activate 
# Win: .\.checkov\Scripts\activate.bat 

pip3 list
pip install checkov

checkov -f main.tf --check CKV_GCP_1 --no-cert-verify