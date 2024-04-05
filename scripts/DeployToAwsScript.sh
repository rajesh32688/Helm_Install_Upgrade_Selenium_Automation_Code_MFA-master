docker_image_url="http://builder.provo.novell.com/perl-bin/zipper.py/artifacts/AA_Docker_Images/NAAF/6.4.2/AA_Docker_Images~6.4.2_B354_release_6.4.2_20230830_082835.zip?dockerimages/aauth-images.tgz"
#docker_image_url="http://builder.provo.novell.com/perl-bin/zipper.py/artifacts/AA_Docker_Images/NAAF/6.4.3/AA_Docker_Images~6.4.3_B321_release_6.4.3_20240402_204158.zip?dockerimages/aauth-images.tgz"


ecr_name="627817533875.dkr.ecr.us-east-1.amazonaws.com"

aws_region="us-east-1"
kubernetes_version="1.24"
eks_cluster_name="rajesh-cloud-automation-cluster"
node_group_name="rajesh-cloud-automation-nodegroup"
node_type="t3.large"
wanted_nodes="1"
min_nodes="1"
max_nodes="2"
application_properties="/var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation/application.properties"
ssh_public_key_path="/var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation/myPublicKey.pub"
helm_charts_path="/var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation/aaf_helm_chart"
ebs_sc_yaml="/var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation/scripts/ebs-sc.yaml"
trust_policy_json="/var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation/scripts/trust-policy.json"
trust_policy_backup_json="/var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation/scripts/trust-policy-backup.json"
helm_namespace="aaf-qa"
helm_name="$helm_namespace-1"

########################################################################################################################################

sudo docker system prune -a -f #Clean existing docker images

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
echo "This is the before upgrade AAF Version $aaf_version"
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
docker push $ecr_name/logspout:$logspout_version

########################################################################################################################################

eksctl delete cluster --region=us-east-1 --name=$eks_cluster_name
aws cloudformation delete-stack --stack-name eksctl-$eks_cluster_name-cluster

echo "Going to sleep"
sleep 5m 
echo "Woke up from sleep"

########################################################################################################################################

eksctl create cluster --name $eks_cluster_name --region $aws_region --version $kubernetes_version --full-ecr-access --node-type $node_type --nodes $wanted_nodes --nodes-min $min_nodes --nodes-max $max_nodes --ssh-access --ssh-public-key $ssh_public_key_path --nodegroup-name $node_group_name --node-volume-type gp2

eksctl utils associate-iam-oidc-provider --region=$aws_region --cluster=$eks_cluster_name --approve

eksctl create iamserviceaccount --name ebs-csi-controller-sa --namespace kube-system --cluster $eks_cluster_name  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --approve --role-only --role-name AmazonEKS_EBS_CSI_DriverRole --override-existing-serviceaccounts

eksctl create addon --name aws-ebs-csi-driver --cluster $eks_cluster_name --service-account-role-arn arn:aws:iam::627817533875:role/AmazonEKS_EBS_CSI_DriverRole --force

########################################################################################################################################

created_oidc_idp=$(aws eks describe-cluster --name $eks_cluster_name --query "cluster.identity.oidc.issuer" --output text | awk 'END {print $1}' | grep -o -P '(?<=id/).*(?=)')
echo $created_oidc_idp
cp $trust_policy_backup_json $trust_policy_json
cp $trust_policy_json temp.json
jq -r ".Statement[].Principal.Federated = \"arn:aws:iam::627817533875:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/$created_oidc_idp\"" temp.json > $trust_policy_json
cp $trust_policy_json temp.json
jq -r ".Statement[].Condition.StringEquals.\"oidc.eks.us-east-1.amazonaws.com/id/$created_oidc_idp:aud\" =  \"sts.amazonaws.com\"" temp.json > $trust_policy_json
sed -i 's/\r//g' $trust_policy_json
aws iam update-assume-role-policy --role-name AmazonEKS_EBS_CSI_DriverRole --policy-document file://$trust_policy_json
eksctl utils associate-iam-oidc-provider --region=$aws_region --cluster=$eks_cluster_name --approve

########################################################################################################################################v

kubectl apply -f $ebs_sc_yaml
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass ebs-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl delete sc gp2

########################################################################################################################################

charts_path=$helm_charts_path\_$aaf_version

sed -ri "{s/registry:.*/registry: $ecr_name/;}" $charts_path/values.yaml
sed -ri "{s/appVersion:.*/appVersion: \"$aaf_version\"/;}" $charts_path/values.yaml
sed -i 's/\r//g' $charts_path/values.yaml
helm install --create-namespace --namespace $helm_namespace $helm_name --set lb.enabled=true $charts_path

########################################################################################################################################

echo "Going to sleep"
sleep 10m 
echo "Woke up from sleep"

svc_lb=$(kubectl get svc -n $helm_namespace | awk 'END {print $4}')
echo https://$svc_lb
sudo cp $application_properties $application_properties.backup
sudo sed -i "s/UrlOfAA\ =\ .*/UrlOfAA\ =\ $svc_lb/g" application.properties

########################################################################################################################################