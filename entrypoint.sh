#!/bin/bash

# 環境変数 $SSL がTRUEのときはserver.xmlを編集し、SSL接続待ち受けコネクタを追加する
# ただし、各SSLパラメータが定義されていないときはコンテナを停止させる
# 既にSSL接続待ち受けコネクタが追加されているときはserver.xmlを編集せずそのままにする
if [ "${SSL}" = "TRUE" ]; then
 isMod=$(grep "SSLCONNECTOR_INSERT" -c /opt/atlassian/atlassian-confluence-${CONF_VERSION}/conf/server.xml)

 if [ "${KEYSTORE_PATH}" = "" ]; then
  echo "UNDEFINED KEYSTORE_PATH"
  exit
 elif [ "${KEYSTORE_PASS}" = "" ]; then
  echo "UNDEFINED KEYSTORE_PASS"
  exit
 elif [ "${KEYALIAS}" = "" ]; then
  echo "UNDEFINED KEYALIAS"
  exit
 elif [ ${isMod} -ne 0 ]; then
  echo "Already SSL connector is registered"
 fi

 sed -i 's|</Service>|<Connector port="8443" protocol="org.apache.coyote.http11.Http11Protocol" maxHttpHeaderSize="8192" \
  SSLEnabled="true" maxThreads="150" minSpareThreads="25" enableLookups="false" disableUploadTimeout="true" acceptCount="100" \
  scheme="https" secure="true" clientAuth="false" sslProtocol="TLS" useBodyEncodingForURI="true" keyAlias="'${KEYALIAS}'" \
  keystoreFile="'${KEYSTORE_PATH}'" keystorePass="'${KEYSTORE_PASS}'" keystoreType="JKS"/>\n<!--SSLCONNECTOR_INSERT-->\n </Service>|g' \
  /opt/atlassian/atlassian-confluence-${CONF_VERSION}/conf/server.xml
  echo "SSL connector is registered"
else
 echo "SSL=FALSE"
fi

/opt/atlassian/atlassian-confluence-${CONF_VERSION}/bin/start-confluence.sh -fg
