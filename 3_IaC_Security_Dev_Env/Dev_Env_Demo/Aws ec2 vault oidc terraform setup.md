# AWS EC2 + HashiCorp Vault + GitHub Actions OIDC + Terraform Setup

## Objective

Set up an EC2 instance running HashiCorp Vault to securely broker AWS credentials for a Terraform-based CI/CD pipeline. Instead of storing long-lived AWS access keys in GitHub Actions secrets, the pipeline authenticates to Vault via OIDC (using a short-lived GitHub-issued JWT), and Vault dynamically generates temporary, auto-expiring AWS IAM credentials scoped to the required permissions (S3 access for Terraform). This removes the need for static AWS keys anywhere in the CI/CD chain.

---

## EC2 instance creation

**Step 1:** Log in to your AWS console and launch an EC2 instance using an Ubuntu AMI with your `.pem` key file, then launch it.

**Step 2:** Connect to the instance via SSH:
```bash
ssh -i filename.pem ubuntu@instance_ip_address
```

**Step 3:** Update all apt repository packages:
```bash
sudo apt update
```

Install basic utilities (`unzip` and `wget`):
```bash
sudo apt install -y unzip wget
```

**Step 4:** Install HashiCorp Vault using `wget`.
Go to [https://developer.hashicorp.com/vault/install](https://developer.hashicorp.com/vault/install) and install Vault based on your OS.

**Step 5:** Run the Vault server locally in dev mode:
```bash
vault server -dev -dev-root-token-id="root" -dev-listen-address="0.0.0.0:8200"
```

**Step 6:** Vault is running on port `8200`, so open that port on the EC2 instance's security group:
```
EC2 → Instances → i-0033f54fse25ab07 → Security → Inbound rules →
launch wizard → (X) → Action → Edit inbound rules → Add rule → port 8200
```

**Step 7:** Browse to the Vault server:
```
http://instance_ip:8200
http://13.50.15.185:8200/ui/vault/dashboard
```

---

## Step 8: Configuring Vault to store AWS credentials

### 8.1 Set Vault address and log in as root
```bash
export VAULT_ADDR='http://13.50.15.185:8200'
vault login root
```

### 8.2 Enable the AWS secrets engine
By default, Vault does not know how to interact with cloud providers. This command tells Vault to prepare a dedicated path (usually `/aws`) to handle AWS credentials.
```bash
vault secrets enable aws
```

### 8.3 Create an IAM access key
```
AWS Console → Prajwal → Security credentials → Create Access Key
```

### 8.4 Add the AWS key and secret to Vault
```bash
vault write aws/config/root \
    access_key="<AWS_ACCESS_KEY>" \
    secret_key="<AWS_SECRET_KEY>" \
    region="us-east-1"
```
Output:
```
Success! Data written to: aws/config/root
```

> **Note:** Treat the root access key/secret as highly sensitive — anyone with these has whatever permissions the root IAM user holds. Rotate them if they are ever exposed (e.g. committed to a repo or shared in plain text).

### 8.5 Create a role that vends temporary S3 credentials
This configures a template inside Vault that dynamically creates temporary AWS IAM users on demand with full access to Amazon S3.
```bash
vault write aws/roles/terraform-role \
    credential_type=iam_user \
    policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
```

### How it works

**Step 1 — Registration**
- Your command registers `terraform-role` in Vault
- Attaches the S3 admin policy (`s3:*`)
- Sets credential type to `iam_user`

**Step 2 — Runtime generation**
- A user or pipeline runs `vault read aws/creds/terraform-role`
- Vault talks to AWS (using the configured root keys)
- Vault creates a dynamic IAM user
- Vault attaches the policy
- Vault returns temporary AWS access keys

**Step 3 — Automatic cleanup**
- When the lease duration (TTL) expires, Vault deletes the temporary IAM user

---

## Step 9: Enabling OIDC authentication for GitHub Actions

We want Vault to be accessible by GitHub Actions without storing static credentials in the repo.

### 9.1 Enable JWT auth
JWT auth allows GitHub Actions to access Vault by presenting a signed token.
```bash
vault auth enable jwt
```

### 9.2 Add OIDC discovery configuration
```bash
vault write auth/jwt/config \
    oidc_discovery_url="https://token.actions.githubusercontent.com" \
    bound_issuer="https://token.actions.githubusercontent.com"
```

### 9.3 Create a read-only policy for the Terraform role
```bash
vault policy write terraform-policy - <<EOF
path "aws/creds/terraform-role" {
  capabilities = ["read"]
}
EOF
```

### 9.4 Bind the policy to your GitHub repository
```bash
vault write auth/jwt/role/gh-actions-role - <<EOF
{
  "role_type": "jwt",
  "bound_audiences": ["https://github.com/prajwalrv"],
  "user_claim": "sub",
  "bound_claims_type": "glob",
  "bound_claims": {
    "sub": "repo:https://github.com/prajwalrv/DevSecOps:*"
  },
  "token_policies": ["terraform-policy"],
  "token_ttl": "1h"
}
EOF
```

---

## Step 10: GitHub Actions workflow (`infra-create.yml`)

```yaml
name: Terraform Deployment
on: [push]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./terraform

    steps:
      - uses: actions/checkout@v4

      - name: Fetch Keys from Vault
        uses: hashicorp/vault-action@v3
        with:
          url: http://44.202.220.115:8200
          role: gh-actions-role
          method: jwt
          secrets: |
            aws/creds/terraform-role access_key | AWS_ACCESS_KEY_ID ;
            aws/creds/terraform-role secret_key | AWS_SECRET_ACCESS_KEY

      - uses: hashicorp/setup-terraform@v3
      - run: terraform init
      - run: terraform plan
      - run: terraform apply -auto-approve
```

---

## Summary

This setup stands up a self-hosted HashiCorp Vault server on an EC2 instance and uses it as a secure broker between AWS and GitHub Actions. Vault's AWS secrets engine is configured once with a root IAM key, then used to define a `terraform-role` that generates short-lived, scoped IAM credentials on demand — automatically cleaned up when their lease expires. Instead of storing AWS keys in GitHub, JWT/OIDC trust is established so GitHub Actions can authenticate to Vault using a token minted per workflow run, scoped to a specific repository. The `infra-create.yml` workflow ties it together: on every push, GitHub fetches temporary AWS credentials from Vault and uses them to run `terraform init`, `plan`, and `apply`. The net result is a pipeline where no long-lived AWS secret ever needs to be stored in CI, reducing the blast radius if the pipeline or repo is ever compromised.