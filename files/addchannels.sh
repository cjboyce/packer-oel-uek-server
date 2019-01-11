#!/usr/bin/env bash
#set -x
usage() {
        echo
        echo "Usage: addchannels.sh {-c channel -w wrap_token -v vault_target_host_and_port}"
        echo
        exit 1
}

while getopts ":c:w:v:" opt; do
        case $opt in
        c)      CHANNEL=$OPTARG
                ;;
        w)      WRAP_TOKEN=$OPTARG
                ;;
        v)      HOSTPORT=$OPTARG
                ;;
        *)    echo "Invalid option: -$OPTARG" >&2
                usage
                ;;
        esac
done

[ -z "${CHANNEL}" ] && usage
[ -z "${WRAP_TOKEN}" ] && usage
[ -z "${HOSTPORT}" ] && usage

####
# Get my credentials from Vault
# (a) Get roleID baked onto this VM
ROLEID=$(cat /usr/local/etc/role-id)

# (b) Unwrap my response-wrap token so I can get my secret ID
SECRETID=$(curl --header "X-Vault-Token: $WRAP_TOKEN" --request POST $HOSTPORT/v1/sys/wrapping/unwrap 2>/dev/null | jq -r '.data.secret_id')

# (c) Take roleID and secretID and query the API for my token
VAULT_TOKEN=$(curl --request POST --data \{\"role_id\":\"$ROLEID\",\"secret_id\":\"$SECRETID\"\} $HOSTPORT/v1/auth/approle/login 2>/dev/null | jq -r '.auth.client_token')

# (d) Use our token to Authenticate with API and grab our ULN credentials
ULN_CREDS_JSON=$(curl --header "X-Vault-Token: $VAULT_TOKEN" --request GET $HOSTPORT/v1/secret/ansible/uln 2>/dev/null)

read -r ULN_USERNAME ULN_PASSWORD <<<$(echo $ULN_CREDS_JSON | jq -r '.data.username,.data.password')

if [ $ULN_USERNAME == 'null' -o $ULN_PASSWORD == 'null' ]; then
        echo "Could not retrieve one or more credentials.  Maybe unwrap token expired?"
        exit 1
fi
####


####
# Add the channel to this node

# Must enable box as a yum server or it can't see channels
/sbin/uln-channel --enable-yum-server -u ${ULN_USERNAME} -p ${ULN_PASSWORD}

# Add addons channel
/sbin/uln-channel -a -v -c ${CHANNEL} -u ${ULN_USERNAME} -p ${ULN_PASSWORD}

# No more yum server...
/sbin/uln-channel --disable-yum-server -u ${ULN_USERNAME} -p ${ULN_PASSWORD}

yum clean all
####

