#!/bin/bash
#set -ex

temp_path=$PWD

echo "Building universal apk path"
echo "Getting app bundle from ${aab_path}"
echo "Signing with ${keystore_url} key and alias ${keystore_alias}"
echo "Apk output name ${apk_output_name}"

bundletool="${temp_path}/bundletool.jar"
keystore="${temp_path}/keystore.jks"
source="https://github.com/google/bundletool/releases/download/1.2.0/bundletool-all-1.2.0.jar"

# Building
universal_deploy_dir="${temp_path}/universal/deploy"
universal_deploy_apk="${universal_deploy_dir}/${apk_output_name}.apk"
universal_deploy_aab="${universal_deploy_dir}/${apk_output_name}.aab"

aab_output_path="${temp_path}/output/bundle"
aab_output="${aab_output_path}/${apk_output_name}.apks"

apk_output_path="${temp_path}/output/apk"

mkdir -p "${universal_deploy_dir}" &
mkdir -p "${aab_output_path}" &
mkdir -p "${apk_output_path}" &
wait

echo "Downloading keystore"
curl -o "keystore.jks" "${keystore_url}"
wait

echo "Downloading bundle tool"
wget -nv "${source}" --output-document="${bundletool}" &
wait

echo "Extracting bundle apks"
exec java -jar "${bundletool}" build-apks --bundle="${aab_path}" --output="${aab_output}" --mode=universal --ks=${keystore} --ks-pass=pass:"${keystore_password}" --ks-key-alias="${keystore_alias}" --key-pass=pass:"${keystore_private_key_password}" &
wait
echo "APK created in ${apk_output_path}"
exec unzip ${aab_output} -d ${apk_output_path} &
wait

# rename universal.apk to the given name
mv ${apk_output_path}/universal.apk ${universal_deploy_apk} &
wait

# rename .aab to the given name
mv ${aab_path} ${universal_deploy_aab} &
wait


envman add --key BITRISE_UNIVERSAL_APK_PATH --value ${universal_deploy_apk}
envman add --key BITRISE_UNIVERSAL_DEPLOY_DIR --value ${universal_deploy_dir}

exit 0
