#!/bin/bash
#
# Dumps credentials of current gcloud user from configs
# The output can be used to run 'grestore.sh' from another host and use the same credentials
#
# inspired by:
# https://www.jhanley.com/blog/google-cloud-where-are-my-credentials-stored/
#

function encrypt_with_openssl_tobase64() {
  text="$1"
  # using OS level base64 which can output full width of screen
  # avoid 3des weak cipher
  echo "$text" | openssl enc -aes-256-cbc -pbkdf2 -iter 1234567 -salt | base64 -w0
  # -pass pass:fakepass123
} 

function ensure_binary() {
  thebinary=$1
  themsg="$2"

  findbinary=$(which $thebinary)
  [[ -n "$findbinary" ]] || { echo "ERROR could not find binary $thebinary, $themsg"; exit 3; }

}
ensure_binary gcloud "install gcloud, https://cloud.google.com/sdk/docs/install"
ensure_binary sqlite3 "use 'sudo apt install sqlite3 -y' to install sqlite"
ensure_binary base64 "use 'sudo apt install coreutils -y' to install base64"
ensure_binary openssl "use 'sudo apt install openssl -y' to install openssl"

current_user=$(gcloud auth list 2>/dev/null | grep "^*" | cut -d'*' -f2 | tr -d ' ')
[[ -n "$current_user" ]] || { echo "ERROR could not retrieve gcloud current user"; exit 3; }
echo "Exporting encrypted credentials for $current_user, use grestore.sh to import" >&2
echo "" >&2

access_output=$(sqlite3 ~/.config/gcloud/access_tokens.db "select * from access_tokens where account_id='$current_user'")
[[ -n "$access_output" ]] || access_output="n/a"

credentials_output=$(sqlite3 ~/.config/gcloud/credentials.db ".dump" | grep "VALUES('$current_user',")
[[ -n "$credentials_output" ]] || credentials_output="n/a"

# create multi-line paragraph
# 1st line=user id, 2nd line=data dump from access | seperator,3rd line=sql insert stmt from credentials
read -r -d '' to_encrypt_stringb64 <<EOF
$current_user
$access_output
$credentials_output
EOF
# make single line without special chars/unicode
to_encrypt_stringb64=$(echo "$to_encrypt_stringb64" | base64 -w0)

# the encryption itself puts a base64 wrapping also, so we can-copy paste encrypted text easily (not binary)
# You could call this 'double wrapping' inefficient, but it avoids special char/unicode edge cases
for_user_to_copy=$(encrypt_with_openssl_tobase64 $(echo "$to_encrypt_stringb64"))

# this is what users would copy-paste
echo "=====COPY EVERYTHING AFTER THIS MARKER=====" >&2
echo "$for_user_to_copy"
echo ""
echo "=====COPY EVERYTHING BEFORE THIS MARKER=====" >&2

