pipeline {
  environment {
    registry = "kmuhametov/app"
    registryCredential = 'dockerhub'
    dockerImage = ''
  }
  parameters {
    string defaultValue: 'nginx-1.22.0', name: 'version'
  }
  agent any
  stages {
    stage('Clone Git') {
      steps {
        git 'https://github.com/kmuhametov/allot_task.git'
      }
    }
    stage('Build') {
      steps{
	    sh '''sed -i "s/NGINX_VERSION=/NGINX_VERSION=$version/" .env'''
        script {
          dockerImage = docker.build registry + ":$BUILD_NUMBER"
		  docker.withRegistry( '', registryCredential ) {
            dockerImage.push()
          }
        }
      }
    }
    stage('Test') {
      steps{
        sh '''docker run -d --name=app kmuhametov/app

		sleep 10

		RUNNING=$(docker inspect --format="{{.State.Running}}" app 2> /dev/null)
		if [ "$RUNNING" == "false" ]; then
		  echo "2" # "CRITICAL - $CONTAINER is not running."
		  exit 2
		fi

		RESTARTING=$(docker inspect --format="{{.State.Restarting}}" app)
		if [ "$RESTARTING" == "true" ]; then
		  echo "1" # "WARNING - $CONTAINER state is restarting."
		  exit 1
		fi'''
      }
    }
    stage('Deploy') {
      steps{
        sh '''kubectl create configmap nginx --from-file nginx.conf
		kubectl apply -f deployment.yaml
		kubectl apply -f service.yaml'''
      }
    }
  }
}