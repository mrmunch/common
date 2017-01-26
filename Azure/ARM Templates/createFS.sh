#!/bin/bash

STORAGE_ACCOUNT="$1"
STORAGE_KEY="$2"

DATE_ISO=$(TZ=GMT date "+%a, %d %h %Y %H:%M:%S %Z")
VERSION="2015-12-11"
HEADER_RESOURCE="x-ms-date:$DATE_ISO\nx-ms-version:$VERSION"

shift
shift
numargs=$#
for ((i=1 ; i <= numargs ; i++))
do
	SHARE_OR_DIR_NAME="$1"
	if [[ $SHARE_OR_DIR_NAME == *"/"* ]]; then
		TYPE="directory"
	else
		TYPE="share"
	fi

	URL_RESOURCE="/$STORAGE_ACCOUNT/$SHARE_OR_DIR_NAME\nrestype:$TYPE"
	STRING_TO_SIGN="PUT\n\n\n\n\n\n\n\n\n\n\n\n$HEADER_RESOURCE\n$URL_RESOURCE"

	DECODED_KEY="$(echo -n $STORAGE_KEY | base64 -d -w0 | xxd -p -c256)"
	SIGN=$(printf "$STRING_TO_SIGN" | openssl dgst -sha256 -mac HMAC -macopt "hexkey:$DECODED_KEY" -binary |  base64 -w0)

	curl -X PUT \
	  -H "x-ms-date:$DATE_ISO" \
	  -H "x-ms-version:$VERSION" \
	  -H "Authorization: SharedKey $STORAGE_ACCOUNT:$SIGN" \
	  -H "Content-Length:0" \
	  "https://$STORAGE_ACCOUNT.file.core.windows.net/$SHARE_OR_DIR_NAME?restype=$TYPE"

	shift
done
