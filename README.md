# Vault MFA TOTP Demo
Demonstrates using TOTP with VAULT.
We will use a demo instance of vault by default.  
If you want to use an existing vault instance, omit the setup.sh part


run setup.sh
copy the root token that is displayed
open a new window
export VAULT_TOKEN= <TOKEN>


edit config_vault.sh and set BARCODE_DEST to the path 
that the barcode will be saved.  
./config_vault.sh

Open the barcode and scan with google authenticator (or the authenticator of your choice)
You should see ProfessorChaosXYZ displayed in your authenticator app

Open the Vault UI & select Username/Password as the auth method
log in as chuck, password: training

Use google authenticator to complete the login