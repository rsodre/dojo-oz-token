
#-------------------
# validate arguments
#
if [ $# -lt 1 ]; then
  echo "❌ Error: Missing profile!"
  echo "usage: $0 <PROFILE> [--offline] [--inspect] [--bindings]"
  exit 1
fi

# initialize argument variables
export PROFILE=
export ARG_BINDINGS=
export ARG_OFFLINE=
export ARG_INSPECT=

# parse arguments
for arg in "$@"
do
  echo ":$arg"
  if [[ -z "$PROFILE" ]]; then # if not set
    # $1: Profile
    export PROFILE=$1
    export DOJO_PROFILE_FILE="dojo_$PROFILE.toml"
    if [ ! -f $DOJO_PROFILE_FILE ]; then
      echo "❌ Error: Missing profile config file: $DOJO_PROFILE_FILE"
      exit 1
    fi
  elif [[ $arg == "--offline" ]]; then
    export ARG_OFFLINE="--offline"
  elif [[ $arg == "--inspect" ]]; then
    export ARG_INSPECT="true"
  elif [[ $arg == "--bindings" ]]; then
    export ARG_BINDINGS="--typescript"
  # else
  #   echo "❌ Error: Invalid argument: $arg"
  #   exit 1
  fi
done


#-----------------
# check tools
#
if ! [ -x "$(command -v toml)" ]; then
  echo '❌ Error: toml not instlaled!'
  echo 'Instal with: cargo install toml-cli'
  exit 1
fi
if ! [ -x "$(command -v starkli)" ]; then
  echo '❌ Error: starkli not instlaled!'
  echo 'Instal with: curl https://get.starkli.sh | sh'
  exit 1
fi


#-----------------
# helper functions
#

get_profile_env () {
  local ENV_NAME=$1
  local RESULT=$(toml get $DOJO_PROFILE_FILE --raw env.$ENV_NAME)
  if [[ -z "$RESULT" ]]; then # if not set
    >&2 echo "get_profile_env($ENV_NAME) not found! 👎"
  fi
  echo $RESULT
}

get_contract_address () {
  local TAG=$1
  local RESULT=$(cat $MANIFEST_FILE_PATH | jq -r ".contracts[] | select(.tag == \"$TAG\" ).address")
  if [[ -z "$RESULT" ]]; then # if not set
    >&2 echo "get_contract_address($TAG) not found! 👎"
  fi
  echo $RESULT
}

execute_command () {
  local COMMAND=$1
  echo "🚦 execute: $COMMAND"
  $COMMAND
}


#-----------------
# env setup
#
export GAME_SLUG="example"
export PROJECT_NAME=$(toml get $DOJO_PROFILE_FILE --raw world.name)
export WORLD_ADDRESS=$(get_profile_env "world_address")
export TORII_CONFIG_TEMPLATE_PATH="./torii_TEMPLATE.toml"
export TORII_CONFIG_PATH="./torii_$PROFILE.toml"
# use $DOJO_ACCOUNT_ADDRESS else read from profile
export ACCOUNT_ADDRESS=${DOJO_ACCOUNT_ADDRESS:-$(get_profile_env "account_address")}
# use $STARKNET_RPC_URL else read from profile
export RPC_URL=${STARKNET_RPC_URL:-$(get_profile_env "rpc_url")}
export CHAIN_ID=$(starkli chain-id --no-decode --rpc $RPC_URL | xxd -r -p)

export MANIFEST_FILE_PATH="./manifest_$PROFILE.json"
export SDK_GAME_PATH="../sdk/src/games/$GAME_SLUG"
export SDK_MANIFEST_PATH="$SDK_GAME_PATH/manifests"


echo "------------------------------------------------------------------------------"
echo "Profile    : $PROFILE"
echo "Project    : $PROJECT_NAME"
echo "PC Url     : $RPC_URL"
echo "Chain Id   : $CHAIN_ID"
echo "World      : $WORLD_ADDRESS"
echo "Account    : $ACCOUNT_ADDRESS"
echo "Torii CFG  : $TORII_CONFIG_PATH"
echo "------------------------------------------------------------------------------"
