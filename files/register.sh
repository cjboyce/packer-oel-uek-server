#!/usr/bin/env bash
#set -x
usage() {
	echo
	echo "Usage: register.sh {-h hostname -w wrap_token -v vault_target_host_and_port}"
	echo
	exit 1
}


while getopts ":h:w:v:" opt; do
        case $opt in
	h)	HOST=$OPTARG
		;;
        w)      WRAP_TOKEN=$OPTARG 
		;;
        v)	HOSTPORT=$OPTARG 
		;;
        *)    echo "Invalid option: -$OPTARG" >&2
		usage 
		;;
	esac
done

[ -z "${HOST}" ] && usage
[ -z "${WRAP_TOKEN}" ] && usage
[ -z "${HOSTPORT}" ] && usage

#echo "My hostname will be: ${HOST}"
#echo "My wrapped secret id token will be: ${WRAP_TOKEN}"
#echo "And my HOSTPORT will be: ${HOSTPORT}"

# Get my credentials from Vault
# (a) Get roleID baked onto this VM
ROLEID=$(cat /usr/local/etc/role-id)

# (b) Unwrap my response-wrap token so I can get my secret ID
SECRETID=$(curl --insecure --header "X-Vault-Token: $WRAP_TOKEN" --request POST $HOSTPORT/v1/sys/wrapping/unwrap 2>/dev/null | jq -r '.data.secret_id')

#echo "Hey my unwrapped secret ID is: $SECRETID"

# (c) Take roleID and secretID and query the API for my token
VAULT_TOKEN=$(curl --insecure --request POST --data \{\"role_id\":\"$ROLEID\",\"secret_id\":\"$SECRETID\"\} $HOSTPORT/v1/auth/approle/login 2>/dev/null | jq -r '.auth.client_token')

#echo "Hey my vault token is: ${VAULT_TOKEN}"

# (d) Use our token to Authenticate with API and grab our ULN credentials
ULN_CREDS_JSON=$(curl --insecure --header "X-Vault-Token: $VAULT_TOKEN" --request GET $HOSTPORT/v1/secret/ansible/uln 2>/dev/null)

#echo "Hey my ULN_CREDS_JSON is: ${ULN_CREDS_JSON}"

read -r ULN_USERNAME ULN_PASSWORD ULN_CSI <<<$(echo $ULN_CREDS_JSON | jq -r '.data.username,.data.password,.data.csi')

#echo "HEY my username is: $ULN_USERNAME password is: $ULN_PASSWORD and CSI is: $ULN_CSI"

if [ $ULN_USERNAME == 'null' -o $ULN_PASSWORD == 'null' -o $ULN_CSI == 'null' ]; then
	echo "Could not retrieve one or more credentials.  Maybe unwrap token expired?"
	exit 1
fi

echo "<==== Registering with ULN ====>"
/usr/sbin/ulnreg_ks --force --profilename=${HOST} --username=${ULN_USERNAME} --password=${ULN_PASSWORD} --csi=${ULN_CSI}

echo "<==== Running yum update all ====>"
yum update -y
