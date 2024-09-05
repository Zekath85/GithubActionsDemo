# Base64-enkoda cloud-init.sh
base64 -w 0 cloud-init_dotnet.yaml > cloud-init_dotnet-base64.txt
base64 -w 0 config_reverseproxy.sh > config_reverseproxy-base64.txt
base64 -w 0 config_bastion.sh > config_bastion-base64.txt


# Ange variabler
RG=Demo1
LOCATION=northeurope
DEPLOYMENT_NAME=storageAccountDeployment
STORAGE_ACCOUNT_NAME="storageacc$(date +%s)" # Ensure this is unique and valid
CONTAINER_NAME="rickardhagmans"
BLOB_NAME="picture.jpg"
VM_SCRIPTS_DIR=./
PICTURE_FILE="${VM_SCRIPTS_DIR}cat.jpg"

# Skapa resursgruppen
az group create --name $RG --location $LOCATION
 
# Kör deployment
az deployment group create \
    --resource-group $RG \
    --template-file VM_ARM_appserver.json \
    --parameters customDataScript="$(base64 -w 0 cloud-init_dotnet.yaml)" \
    --parameters sshPublicKey="$(cat ~/.ssh/id_rsa.pub)"
# Kör deployment reverseProxy
    az deployment group create \
    --resource-group $RG \
    --template-file VM_ARM_revproxy.json \
    --parameters customDataScript="$(base64 -w 0 config_reverseproxy.sh)" \
    --parameters sshPublicKey="$(cat ~/.ssh/id_rsa.pub)"
# Kör deployment Bastion
az deployment group create \
    --resource-group $RG \
    --template-file VM_ARM_bastion.json \
    --parameters customDataScript="$(base64 -w 0 config_bastion.sh)" \
    --parameters sshPublicKey="$(cat ~/.ssh/id_rsa.pub)"

# Create Storage Account
az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RG --location $LOCATION --sku Standard_LRS --allow-blob-public-access true --encryption-services blob
# Retrieve Storage Account Key
STORAGE_ACCOUNT_KEY=$(az storage account keys list --resource-group $RG --account-name "$STORAGE_ACCOUNT_NAME" --query '[0].value' --output tsv)
# Create Blob Container
az storage container create --name $CONTAINER_NAME --account-name "$STORAGE_ACCOUNT_NAME" --account-key $STORAGE_ACCOUNT_KEY
# Set Public Access Level for the Container to Blob
az storage container set-permission --name $CONTAINER_NAME --account-name "$STORAGE_ACCOUNT_NAME" --account-key $STORAGE_ACCOUNT_KEY --public-access blob
# Upload Picture to Blob Container
az storage blob upload --container-name $CONTAINER_NAME --file $PICTURE_FILE --name $BLOB_NAME --account-name "$STORAGE_ACCOUNT_NAME" --account-key $STORAGE_ACCOUNT_KEY
# Generate the Blob URL
BLOB_URL="https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${CONTAINER_NAME}/${BLOB_NAME}"
# Optional: Display the blob URL as the last output
echo "Blob URL: $BLOB_URL"


# Kontrollera om distributionen lyckades
if [ $? -eq 0 ]; then
  echo "Deployment succeeded!"
else
  echo "Deployment failed!"
  exit 1
fi

# Variables
PUBLIC_IP_APP_TAG="APPPublicIP"  # Name of the Public IP resource
PUBLIC_IP_Bastion_TAG="BastionPublicIP"  # Name of the Public IP resource
PUBLIC_IP_Proxy_TAG="ProxyPublicIP"  # Name of the Public IP resource
# Get the public IP address
PUBLIC_IP_APP=$(az network public-ip show --resource-group $RG --name $PUBLIC_IP_APP_TAG --query "ipAddress" --output tsv)
PUBLIC_IP_Bastion=$(az network public-ip show --resource-group $RG --name $PUBLIC_IP_Bastion_TAG --query "ipAddress" --output tsv)
PUBLIC_IP_Proxy=$(az network public-ip show --resource-group $RG --name $PUBLIC_IP_Proxy_TAG --query "ipAddress" --output tsv)
# Output the Public IP
echo "The APP Public IP is: $PUBLIC_IP_APP"
echo "The Bastion Public IP is: $PUBLIC_IP_Bastion"
echo "The Proxy Public IP is: $PUBLIC_IP_Proxy"

# Utför SCP-kommandot med den dynamiska IP-adressen (-i ~/.ssh/id_rsa)
#scp c:/index.html azureuser@$PUBLIC_IP:/home/azureuser/

# Anslut via SSH och flytta index.html till webbkatalogen (-i ~/.ssh/id_rsa)
#ssh azureuser@$PUBLIC_IP << EOF
   # sudo mv /home/azureuser/index.html /var/www/html/index.html
#EOF
#az group delete --resource-group $RG