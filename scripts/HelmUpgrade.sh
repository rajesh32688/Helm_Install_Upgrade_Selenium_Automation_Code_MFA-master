#docker_image_url="http://builder.provo.novell.com/perl-bin/zipper.py/artifacts/AA_Docker_Images/NAAF/6.4.3/AA_Docker_Images~6.4.3_B321_release_6.4.3_20240402_204158.zip?dockerimages/aauth-images.tgz"

docker_image_url="http://builder.provo.novell.com/perl-bin/zipper.py/artifacts/AA_Docker_Images/NAAF/6.4.2/AA_Docker_Images~6.4.2_B354_release_6.4.2_20230830_082835.zip?dockerimages/aauth-images.tgz"

ecr_name="627817533875.dkr.ecr.us-east-1.amazonaws.com"

aws_region="us-east-1"

application_properties="/var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation/application.properties"

helm_charts_path="/var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation/aaf_helm_chart"
helm_namespace="aaf-qa"
helm_name="$helm_namespace-1"

########################################################################################################################################

docker_image_version=$(echo $docker_image_url | grep -o -P '(?<=Images~).*(?=.zip)')

docker_file="/root/$docker_image_version.tgz"

sudo chmod 777 $docker_file

if sudo test -f $docker_file; then #sudo is required if not it work as unexpected
    echo "$docker_file exists."
else 
    echo "$docker_file does not exist."
    sudo curl -L -o $docker_file $docker_image_url
fi

sudo chmod 777 $docker_file
sudo docker load -i $docker_file

aaf_version=$(docker images | awk ' NR==2 { print $2}')
echo "This is the to be upgraded AAF Version $aaf_version"
logspout_version=$(docker images | awk ' END { print $2}')

########################################################################################################################################

sudo date -s "$(wget --method=HEAD -qSO- --max-redirect=0 google.com 2>&1 | sed -n 's/^ *Date: *//p')" #To avoid date mismatch which happens after a reboot of the sles jenkins machine

aws ecr get-login-password --region $aws_region | docker login --username AWS --password-stdin $ecr_name

docker tag mfsecurity/aaf-afisd:$aaf_version $ecr_name/aaf-afisd:$aaf_version
docker tag mfsecurity/aaf-webd:$aaf_version $ecr_name/aaf-webd:$aaf_version
docker tag mfsecurity/aaf-aucore:$aaf_version $ecr_name/aaf-aucore:$aaf_version
docker tag mfsecurity/aaf-audb:$aaf_version $ecr_name/aaf-audb:$aaf_version
docker tag mfsecurity/aaf-radiusd:$aaf_version $ecr_name/aaf-radiusd:$aaf_version
docker tag mfsecurity/aaf-fipsd:$aaf_version $ecr_name/aaf-fipsd:$aaf_version
docker tag mfsecurity/aaf-webauth:$aaf_version $ecr_name/aaf-webauth:$aaf_version
docker tag mfsecurity/aaf-searchd:$aaf_version $ecr_name/aaf-searchd:$aaf_version
docker tag mfsecurity/aaf-repldb:$aaf_version $ecr_name/aaf-repldb:$aaf_version
docker tag mfsecurity/aaf-redis:$aaf_version $ecr_name/aaf-redis:$aaf_version
docker tag mfsecurity/aaf-db-migration:$aaf_version $ecr_name/aaf-db-migration:$aaf_version
docker tag gliderlabs/logspout:$logspout_version $ecr_name/logspout:$logspout_version

docker push $ecr_name/aaf-afisd:$aaf_version
docker push $ecr_name/aaf-webd:$aaf_version
docker push $ecr_name/aaf-aucore:$aaf_version
docker push $ecr_name/aaf-audb:$aaf_version
docker push $ecr_name/aaf-radiusd:$aaf_version
docker push $ecr_name/aaf-fipsd:$aaf_version
docker push $ecr_name/aaf-webauth:$aaf_version
docker push $ecr_name/aaf-searchd:$aaf_version
docker push $ecr_name/aaf-repldb:$aaf_version
docker push $ecr_name/aaf-redis:$aaf_version
docker push $ecr_name/aaf-db-migration:$aaf_version
docker push $ecr_name/logspout:$logspout_version

########################################################################################################################################

charts_path=$helm_charts_path\_$aaf_version

sed -ri "{s/registry:.*/registry: $ecr_name/;}" $charts_path/values.yaml
sed -ri "{s/appVersion:.*/appVersion: \"$aaf_version\"/;}" $charts_path/values.yaml
sed -i 's/\r//g' $charts_path/values.yaml
echo "helm upgrade --namespace $helm_namespace $helm_name --set lb.enabled=true $charts_path"

########################################################################################################################################