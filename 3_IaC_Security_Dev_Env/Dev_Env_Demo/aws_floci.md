===================================== AWS

==> EC2 INSTANCE CREATION : 

	-> Step 1 : Login to your AWS console and launch an ec2 instance with ubuntu ami with your pem file & launch it

	-> Step 2 : COnnect to the instance via ssh :
	[ssh -i filename.pem ubuntu@instance_ip_address]
	
	-> Step 3 : update all apt repositories packages
	[sudo apt update]
	
		-> install basic utilities [unzip & wget]
		[sudo apt install -y unzip wget]
	
	-> Step 4 : Lets now intall hashicorp zip using wget
	[go to https://developer.hashicorp.com/vault/install and install vault based on your installer os]
	
	-> Step 5 : Rnn the vault server locally in dev mode - mode
	[vault server  -dev  -dev-root-token-id="root" -dev-listen-address="0.0.0.0:8200"]
	
	-> Step 6 : We started vault server on port : 8200 so we need to open that port on ec2 instance in console
	[
		EC2->> Instances->> i-0033f54fse25ab07->> Security->> Inbound rules->> 
		launch wizard->> (X)->> Action-->> Edit inbound rules->> Add rule->> with port 8200
	]
	
	-> Step 7 : now browser the vault server http://instance_ip:8200
	[http://13.50.15.185:8200/ui/vault/dashboard]
	
	-> Step 8 : Configuring vault to aws to store our (AWS_ACCESS_KEY & AWS_ACCESS_SECRET)
	
		-> Step 1 : Setting vault address and login as root 
		[export VAULT_ADDR='http://13.50.15.185:8200']
		[vault login root]
		
		-> Step 2 : By default, Vault does not know how to interact with cloud providers. 
		Running this command tells Vault to prepare a dedicated path (usually /aws) to handle AWS credentials.
		[vault secrets enable aws]
		
		-> Step 3 : Configure connection using your IAM User keys (Manager keys)
		[AWS Console->> Prajwal->> Security credentials->> Create Access Key]
		
		-> Step 4 : Run this cmd on instance's ssh to add AWS key & secret to hashicorp vault
		[
			vault write aws/config/root \
			    access_key="" \
			    secret_key="" \
			    region="us-east-1"
		]
		outpu : [Success! Data written to: aws/config/root]
		
		-> Steps 5 : This command configures a specific template inside HashiCorp Vault that dynamically creates 
		temporary AWS IAM users on-demand with full access to Amazon S3
		[
			# Create the role that vends S3 keys
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
		]
		
		HOW IT WORKS
		[STEP 1: REGISTRATION]
		Your Command --> Registers "terraform-role" in Vault
				   |--> Attaches S3 Admin Policy (s3:*)
				   |--> Sets type to "iam_user"

		[STEP 2: RUNTIME GENERATION]
		User/Pipeline --> `vault read aws/creds/terraform-role`
				    |--> Vault talks to AWS (using root keys)
				    |--> Vault creates dynamic IAM user
				    |--> Vault attaches policy
				    |--> Returns Temporary AWS Access Keys

		[STEP 3: AUTOMATIC CLEANUP]
		Lease Duration (TTL) Expires --> Vault deletes temporary IAM user
		
	-> Step 9 : Lets enable OIDC protocol on this vault server
	
		-> We want this vault to be accessed by GH Actions
		[vault auth enable jwt] - jwt enables GH Actions to access vault by seeking the credentils.
		
		-> Adding OIDC connection configuration so github will use this connection
		[
		    vault write auth/jwt/config \
		    oidc_discovery_url="https://token.actions.githubusercontent.com" \
		    bound_issuer="https://token.actions.githubusercontent.com"
		]
		
		-> Create Policy
		[
			vault policy write terraform-policy - <<EOF
			path "aws/creds/terraform-role" {
			  capabilities = ["read"]
			}
			EOF
		]
		
		-> Bind the above 'read' policy to your github repository
		[
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
		]
		
	
	
	
	-> Step 10 : Set up infra-create.yml file:

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


	

		
		
