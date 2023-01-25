#!/bin/bash
#
# Processes output of 'gsave.sh'
# Inserts credentials into gcloud configs
#
# inspired by:
# https://www.jhanley.com/blog/google-cloud-where-are-my-credentials-stored/
#

function decrypt_with_openssl() {
  text="$1"
  # base64 encoding was applied twice:
  # 1. once to get rid of special chars/unicode and create single line of text to encode
  # 2. another time to turn encrypted binary into ascii-friendly text for copy-paste
  echo "$text" | base64 -d | openssl enc -d -aes-256-cbc -pbkdf2 -iter 1234567 -salt | base64 -d
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
ensure_binary base64 "use 'sudo apt install openssl -y' to install openssl"

# input comes as one line of encrypted text, base64 encoded
read -r stdin_line
# throw away any extra lines of stdin, so that password entry is not stuffed
if test -t 0; then
  while read -r -t 1 foo; do true; done
fi
decrypted_lines=$(decrypt_with_openssl $stdin_line)
#echo "decrypted=$decrypted_lines"

COUNT=0
IFS=$'\n'
for line in $decrypted_lines; do

  # throw out boundary lines if user accidently included
  if [[ "$line" =~ =====COPY ]]; then continue; fi
  # skip empty lines
  [[ -n "$line" ]] || continue
  #echo "processing line $COUNT: $line"

  case $COUNT in
  0)
    current_user=$line
    [[ -n "$current_user" ]] || { echo "ERROR could not retrieve target gcloud user"; exit 3; }
    echo -e "\n"
    echo "===RESTORE for $current_user"
    ;;
  1)
    if [ "$line" == "n/a" ]; then
      echo "No access_tokens to restore for $current_user"
    else
      sqlite3 ~/.config/gcloud/access_tokens.db "delete from access_tokens where account_id='$current_user'"
      echo $line | sqlite3 ~/.config/gcloud/access_tokens.db ".import \"|cat -\" access_tokens"
      echo "INSERT ~/.config/gcloud/access_tokens.db, exit code $?"
    fi
    ;;
  2)
    if [ "$line" == "n/a" ]; then
      echo "No credentials to restore for $current_user"
    else
      sqlite3 ~/.config/gcloud/credentials.db "delete from credentials where account_id='$current_user'"
      echo $line | sqlite3 ~/.config/gcloud/credentials.db
      echo "INSERT ~/.config/gcloud/credentials.db, exit code $?"
    fi

    ;;
  *)
    true
    #echo "ERROR only first 3 non-empty lines are valid (id,access_tokens,credentials)"
  esac

  ((COUNT+=1))
done < <(echo $all_lines)


# throw away any extra lines of stdin
if test -t 0; then
  #echo "going to eat the rest of stdin"
  while read -r -t 1 foo; do true; done
fi
