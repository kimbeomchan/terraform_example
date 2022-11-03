#!/bin/bash

# ========= AKS Script ==========================================================
#    Name    : Terraform Setting in Azure
#    Date    : 2022.10.12
#    Author  : 장현덕
#    Update  : 
# ===============================================================================

# ===============================================================================
#  설명
# ===============================================================================
#  * Azure 리소스 명에 대해서는 각 고객사의 Naming Rule에 맞춰 업데이트하여 진행하기 바람
#  * Service Principal은 만료일 수정 가능. 수정 시, Naming은 고객사에 맞게 수정
#  * 아래 구독ID, 사용자 계정 입력하고 진행하기 바람.
#  * Windows WSL2 Ubuntu 환경에서 진행하여 /r에 대한 추가 작업을 진행하였음.
#    따라서, ubuntu vm에서 진행할 시, 아래 예시와 같이 변경 바람.
#    예시) ${CLIENT_ID/$'\r'/} => $CLIENT_ID
#
#  사전 준비 사항:
#    - Azure CLI
#    - Azure Login
#    - AAD 및 구독 Admin Global 권한
#
#  스크립트 배포 순서:
#    - Terraform Azure Service Principle 생성
#    - Resource Group 생성
#    - Storage Account 리소스 생성
#    - Storage Container 생성
#    - Key Vault 리소스 생성
#    - Key Vault Access Policies 구성
#    - Terraform 로그인을 위한 비밀키:값 생성
#    - Key Vault에 저장한 비밀키:값 리스트
#        - TF-ACCESS-KEY
#        - TF-CLIENT-ID
#        - TF-CLIENT-SECRET
#        - TF-SUBSCRIPTION-ID
#        - TF-TENANT-ID
#
# ===============================================================================
#  Azure Login
# ===============================================================================
az login --use-device-code
az account list -o table
az account set --subscription "8c82895e-6d89-43f5-8414-29e2c36024f2" 
# az account set --subscription "<구독 ID 기입>"
az account list --query "[?user.name=='joehd91@cloocus.com>'].{Name:name, ID:id, Default:isDefault}" --output Table
# az account list --query "[?user.name=='<사용자 계정 기입 예시)joehd91@cloocus.com>'].{Name:name, ID:id, Default:isDefault}" --output Table

# ===============================================================================
#  변수 정의
# ===============================================================================

# ResourceGroup
RESOURCE_GROUP_NAME='demo-terraform-rg'
LOCATION='koreacentral'

# StorageAccount
STORAGE_ACCOUNT_NAME='demoterraformstga'
STORAGE_ACCOUNT_SKU='Standard_LRS'
STORAGE_CONTAINER_NAME='demo-tfstate'

# KeyVault
KEY_VAULT_NAME='demo-terraform-kvlt'

# ===============================================================================
# Check Azure Login
# ===============================================================================
# Azure에 로그인되어 있는지 확인
function check_login() {
    echo 'Checking for an active Azure login...'

    CURRENT_SUBSCRIPTION_ID=$(az account list --query '[?isDefault].id' --output tsv)
    TENANT_ID=$(az account list --query '[?isDefault].homeTenantId' --output tsv)

    if [ -z "$CURRENT_SUBSCRIPTION_ID" ]
    	then 
    		printf '%s\n' 'ERROR! Not logged in to Azure. Run az account login' >&2 # 모든 출력을 강제로 쉘 스크립트의 표준 에러로 출력
    		exit 1 # 성공적으로 프로그램을 종료하지 못함 (EXIT_FAILURE)
    	else
    		echo 'SUCCESS!'
    fi

    ADMIN_USER=$(az ad signed-in-user show --query 'userPrincipalName' --output tsv)
}

# ===============================================================================
# Service Principle
# ===============================================================================
# Azure에 로그인되어 있는지 확인
function service_principle() {

HASH_CURRENT_SUBSCRIPTION_ID=$(echo -n $CURRENT_SUBSCRIPTION_ID | md5sum | awk '{print $1}' )
echo "Hash_Current_Subscription_ID: $HASH_CURRENT_SUBSCRIPTION_ID"

SERVICE_PRINCIPLE_NAME="terraform-$HASH_CURRENT_SUBSCRIPTION_ID"
echo "Checking for an active Service Principle: $SERVICE_PRINCIPLE_NAME..."

CLIENT_ID=$(az ad app list  --query "[?displayName=='$SERVICE_PRINCIPLE_NAME'].appId" --output tsv --all)

if [ -z ${CLIENT_ID/$'\r'/} ]
	then 
		echo "Creating a Terraform Service Principle: $SERVICE_PRINCIPLE_NAME ..."
		az ad app create --display-name "$SERVICE_PRINCIPLE_NAME" --output none
		CLIENT_ID=$(az ad app list --query "[?displayName=='$SERVICE_PRINCIPLE_NAME']".appId --output tsv --all)
		az ad sp create --id ${CLIENT_ID/$'\r'/} --output none
	else
	   	echo "Service Principle exists reseting permissions & password"
		CLIENT_ID=$(az ad app list --query "[?displayName=='$SERVICE_PRINCIPLE_NAME']".appId --output tsv --all)
fi

az role assignment create --assignee $SERVICE_PRINCIPLE_NAME  --role "Contributor" --scope "/subscriptions/$CURRENT_SUBSCRIPTION_ID" --output none
az role assignment create --assignee ${CLIENT_ID/$'\r'/} --role "Resource Policy Contributor" --scope "/subscriptions/$CURRENT_SUBSCRIPTION_ID" --output none 

# -------------------------------------------------------------------------------
# 해당 client id의 password를 알기 위한 작업
# -------------------------------------------------------------------------------
JSON_OUTPUT=$(az ad app credential reset --id "${CLIENT_ID/$'\r'/}")
SEARCH_STRING='"password": "'
FIRST_CUT=${JSON_OUTPUT#*$SEARCH_STRING}; 
SEARCH_STRING_2='"'
SECOND_CUT=${FIRST_CUT#*$SEARCH_STRING_2}; 
LENGTH=$(( ${#FIRST_CUT} - ${#SECOND_CUT} - ${#SEARCH_STRING_2} )); 
PASSWORD=$(echo $FIRST_CUT | cut -c 1-$LENGTH | awk 'FNR==1')

# -------------------------------------------------------------------------------
# 아래 echo tool을 통해 해당 client id의 password 길이 및 값 확인 가능
# -------------------------------------------------------------------------------
# echo $JSON_OUTPUT
# echo $FIRST_CUT
# echo $SECOND_CUT
# echo $LENGTH
# echo $PASSWORD
# }

# ===============================================================================
# New Resource Group
# ===============================================================================
# 리소스 그룹 생성
function resource_group() {
echo "Creating Terraform Management Resource Group: $RESOURCE_GROUP_NAME"
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION --output none
}

# ===============================================================================
# New Storage Account
# ===============================================================================
# 스토리지어카운트 생성
function storage_account() {

echo "Creating Terraform backend Storage Account: $STORAGE_ACCOUNT_NAME"
EXISTING_STORAGE_ACCOUNT_NAME=$(az storage account list --query "[?resourceGroup=='$RESOURCE_GROUP_NAME' && contains(@.name, 'terraform')]".name --output tsv)
if [ -z $EXISTING_STORAGE_ACCOUNT_NAME ]
	then
		az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --sku $STORAGE_ACCOUNT_SKU --output none

		# New Storage Container
		AZURE_STORAGE_ACCOUNT=$STORAGE_ACCOUNT_NAME
		echo 'Creating Terraform State Storage Container: $STORAGE_CONTAINER_NAME'
		az storage container create --name $STORAGE_CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --auth-mode login --output none

	else
		echo 'Storage Account already exists, using: $EXISTING_STORAGE_ACCOUNT_NAME'
		STORAGE_ACCOUNT_NAME=$(echo $EXISTING_STORAGE_ACCOUNT_NAME)
fi

# -------------------------------------------------------------------------------
# 두 번째, 액세스 키 사용 방법
# -------------------------------------------------------------------------------
JSON_OUTPUT=$(az storage account keys renew --account-name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --key secondary)
SEARCH_STRING='"keyName": "key2",'
FIRST_CUT=${JSON_OUTPUT#*$SEARCH_STRING};
SEARCH_STRING_2='"value": "'
SECOND_CUT=${FIRST_CUT#*$SEARCH_STRING_2}
SEARCH_STRING_3='"'
THIRD_CUT=${SECOND_CUT#*$SEARCH_STRING_3}
LENGTH=$(( ${#SECOND_CUT}-${#THIRD_CUT}-${#SEARCH_STRING_3} ))
TF_ACCESS_KEY=$(echo $SECOND_CUT | cut -c1-$LENGTH)

# -------------------------------------------------------------------------------
# 아래 echo tool을 통해 해당 액세스 키값 확인 가능
# -------------------------------------------------------------------------------
# echo $JSON_OUTPUT
# echo $FIRST_CUT
# echo $SECOND_CUT
# echo $THIRD_CUT
# echo $LENGTH
# echo $TF_ACCESS_KEY
}

# ===============================================================================
# KeyVault
# ===============================================================================
# 키볼트 생성
function key_vault() {
echo "Creating Terraform KeyVault: $KEY_VAULT_NAME"
EXISTING_KEY_VAULT_NAME=$(az keyvault list --query "[?resourceGroup=='$RESOURCE_GROUP_NAME' && contains(@.name, 'terraform-kvlt')]".name --output tsv)
if [ -z $EXISTING_KEY_VAULT_NAME ]
	then
		az keyvault create --location $LOCATION --name $KEY_VAULT_NAME --resource-group $RESOURCE_GROUP_NAME --output none
	else
		echo 'Key Vault already exists, using: $EXISTING_KEY_VAULT_NAME'
		KEY_VAULT_NAME=$(echo $EXISTING_KEY_VAULT_NAME)
fi

# -------------------------------------------------------------------------------
# 액세스 접근 정책 설정
# -------------------------------------------------------------------------------
echo "Setting KeyVault Access Policy for Owner: $ADMIN_USER"
KEY_VAULT_ID=$(az keyvault list --query "[?name=='$KEY_VAULT_NAME'].id" --output tsv)
az role assignment create --assignee ${ADMIN_USER/$'\r'/} --role "Owner" --scope ${KEY_VAULT_ID/$'\r'/} --output none 
}

# -------------------------------------------------------------------------------
# KeyVault Secrets 생성
# -------------------------------------------------------------------------------
function set_secrets() {
echo 'Creating KeyVault Secrets for Terraform'
az keyvault secret set --name TF-SUBSCRIPTION-ID --value $CURRENT_SUBSCRIPTION_ID --vault-name $KEY_VAULT_NAME --output none
az keyvault secret set --name TF-CLIENT-ID --value ${CLIENT_ID/$'\r'/} --vault-name $KEY_VAULT_NAME --output none
az keyvault secret set --name TF-CLIENT-SECRET --value $PASSWORD --vault-name $KEY_VAULT_NAME --output none
az keyvault secret set --name TF-TENANT-ID --value $TENANT_ID --vault-name $KEY_VAULT_NAME --output none
az keyvault secret set --name TF-ACCESS-KEY --value $TF_ACCESS_KEY --vault-name $KEY_VAULT_NAME --output none

# -------------------------------------------------------------------------------
# Ending Output
# -------------------------------------------------------------------------------
echo "Terraform resources provisioned:"
echo "SERVICE_PRINCIPLE_NAME:$SERVICE_PRINCIPLE_NAME"
echo "RESOURCE_GROUP_NAME:$RESOURCE_GROUP_NAME"
echo "LOCATION:$LOCATION"
echo "CONTAINER_NAME:$STORAGE_CONTAINER_NAME"
echo "STORAGE_ACCOUNT_NAME:$STORAGE_ACCOUNT_NAME"
echo "KEY_VAULT_NAME:$KEY_VAULT_NAME"
}

# ===============================================================================
# MAIN
# ===============================================================================
if [[ $SKIP == 'FALSE' ]]
	then
		check_login
		service_principle
		resource_group
		storage_account
		key_vault
		set_secrets
		echo 'FINISHED!';

	else
		check_login
		service_principle
		resource_group
		storage_account
		key_vault
		set_secrets
		echo 'FINISHED SKIPPED!';
fi