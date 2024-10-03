#!/bin/bash

BARCODE_DEST=/mnt/c/Users/david.randolph/Downloads/barcode.png

# all the secrets in this file are garbage and are for example only.

vault audit enable file file_path=$PWD/vault-audit.log

vault auth enable userpass
ACCESSOR=`vault auth list -format=json | jq -r '.["userpass/"].accessor'`

####################################################     
#     Configure TOTP MFA
####################################################
read -r -d '' PAYLOAD<< EOF 
{
    "method_name": "testMFA",
    "issuer": "ProfessorChaos",
    "algorithm": "SHA512"
}
EOF

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data "$PAYLOAD" \
    http://127.0.0.1:8200/v1/identity/mfa/method/totp

# extract the UUID for the mfa method
METHOD_ID=`vault list /identity/mfa/method/totp | tail -n 1`

####################################################     
#     Create a user with mfa enabled
####################################################
# First the user/entity
vault write auth/userpass/users/chuck password="training"

ENTITY=`vault write -field=id identity/entity name="chuck" \
     metadata=organization="ACME Inc." \
     metadata=team="Engineering"`

vault write identity/entity-alias name="chuck" \
     canonical_id=$ENTITY \
     mount_accessor=$ACCESSOR 

# Now enforce MFA
read -r -d '' PAYLOAD<< EOF 
{
     "mfa_method_ids": "$METHOD_ID",
     "auth_method_types": ["userpass"]
}
EOF

curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data "$PAYLOAD" \
    http://127.0.0.1:8200/v1/identity/mfa/login-enforcement/test-enforcement | jq



####################################################     
#     Finally, generate a bar code so we can use
#     an authenticator app
####################################################

read -r -d '' PAYLOAD<< EOF 
{
  "method_id": "$METHOD_ID",
  "entity_id": "$ENTITY"
}
EOF



curl -sS \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request POST \
    --data "$PAYLOAD" \
    http://127.0.0.1:8200/v1/identity/mfa/method/totp/admin-generate | jq '.data | .barcode' \
    | sed -e 's/"//g' \
    | base64 -d  > $BARCODE_DEST

