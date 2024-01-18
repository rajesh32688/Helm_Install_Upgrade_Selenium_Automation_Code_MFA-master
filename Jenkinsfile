pipeline {
	agent any 
   	environment {
        AWS_ACCESS_KEY_ID     = credentials('jenkins-aws-id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret')   
    }
	options {
		disableConcurrentBuilds()
	}
	stages {
		stage ('Deploy To AWS') {
			steps {
				sh "aws configure set region us-east-1"
				sh "sudo -i"
				sh "chmod 777 /var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation/scripts/DeployToAwsScript.sh"
				sh "sed -i 's/\r//g' /var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation/scripts/DeployToAwsScript.sh"
				sh "/var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation/scripts/DeployToAwsScript.sh"
			}
		}
		stage ('UI Tests - Install AA') {
			agent {
				label "Linux"
            }
			steps {
				script {
					echo "NODE_NAME = ${env.NODE_NAME}"
					if (env.NODE_NAME == "built-in") {
				    	echo "Build"
						echo "Try to run something related to maven project build path here for Linux"
						echo "The present Working Directory is:"
						sh "pwd"
						sh "sudo chmod -R 777 /var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation/"
						sh "cd /var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation"
						sh "mvn -e -X test"
					} 
					else {
						sh "echo 'Hello from ${env.BRANCH_NAME} branch!'"
		            } 
				}
			}
		}
		stage ('Perform Helm Upgrade') {
			steps {
				sh "sleep 1m"
				sh "aws configure set region us-east-1"
				sh "sudo -i"
				sh "chmod 777 /var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation/scripts/HelmUpgrade.sh"
				sh "sed -i 's/\r//g' /var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation/scripts/HelmUpgrade.sh"
				sh "/var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation/scripts/HelmUpgrade.sh"
			}
		}
		
		/*
		stage ('Test MFA Environment') {
			agent {
                        label "Windows"
                    }
			
			steps {
			
				echo "Test MFA Environment running on nodes labeled as Windows "
			}
		}
		stage ('Staged MFA Environment') {
			steps {
				echo "Staged MFA Environment"
			}
		}
		stage ('Await Approval For Production') {
			steps {
				echo "Approval For Production"
			}
		}
		*/
		
	}
}
