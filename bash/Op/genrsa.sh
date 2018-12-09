#!/bin/sh

key_file_prefix=$1
bit_length=$2
if [ "$key_file_prefix" = '' ]; then key_file_prefix=rsa; fi
if [ "$bit_length" = '' ]; then bit_length=2048; fi

temp_private_key_file=/tmp/"$key_file_prefix"_private_rsa.pem
private_key_file="$key_file_prefix"_private.pem
public_key_file="$key_file_prefix"_public.pem

openssl genrsa -out $temp_private_key_file $bit_length >/dev/null 2>&1
openssl pkcs8 -topk8 -inform PEM -in $temp_private_key_file -outform PEM -nocrypt -out $private_key_file >/dev/null 2>&1
openssl rsa -in $temp_private_key_file -pubout -out $public_key_file >/dev/null 2>&1

rm -f $temp_private_key_file

echo Output files are:
echo $private_key_file
echo $public_key_file

