#!/bin/bash

if [[ "$#" == 0 || "$1" == '--help' ]]; then
  echo "Usage: make-user.sh [USERNAME ...]"
  echo "For each user:"
  echo "  - generate x509 certificate"
  echo "  - generate private key"
  echo "  - append user to crypto-config.yaml file"
  echo "  - generate user-keys-secret.yaml manifest"
fi

# generate certs
for USER in "$@"; do
  openssl genrsa -out ${USER}.key 2048 && \
  openssl req -new -key ${USER}.key -subj "/CN=${USER}/O=${USER}" -out ${USER}.csr && \
  openssl x509 -req -in ${USER}.csr -signkey ${USER}.key -out ${USER}.crt
done

# generate crypto-config
f="edm/config/crypto-config.yaml"
echo 'clients:' > $f
for USER in "$@"; do
  echo "  - clientId: ${USER}" >> $f
  echo "    certFileName: ${USER}.crt" >> $f
  echo "    keyFileName: ${USER}.key" >> $f
done

# generate secret
keyArgs=()
for ARG in "$@"; do
  keyArgs+=("--from-file=$ARG.key")
  keyArgs+=("--from-file=$ARG.crt")
done

kubectl create secret generic user-keys-secret \
--dry-run=client \
$(echo ${keyArgs[*]}) \
--namespace=ives \
-o yaml | kubeseal -o yaml -w edm/sealed-secrets/user-keys-sealedsecret.yaml
