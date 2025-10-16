pipeline {
  agent any

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '15'))
    skipDefaultCheckout(true)
  }

  triggers {
    githubPush()
  }


  parameters {
    booleanParam(name: 'BUILD_DOCKER', defaultValue: false, description: 'Also build Docker image (dev only)')
  }

  environment {
    APP_ENV = 'development'
    MAVEN_OPTS = '-Dmaven.test.failure.ignore=false -DskipITs=true'
    AWS_REGION     = 'us-east-1'
    AWS_CREDS_ID   = 'aws-credentials'
    ECR_ACCOUNT_ID = '716547170035'
    ECR_REPO       = 'spring-petclinic-dev'
    ECR_REGISTRY   = "${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    KUBE_CRED_ID   = 'kubeconfig-credentials'
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/sravuri07/spring-petclinic.git', credentialsId: 'github-creds-id'
      }
    }

    stage('Build & Test') {
      steps {
        sh 'chmod +x mvnw || true'
        sh './mvnw -v'
        sh './mvnw -B -U clean verify'
      }
      post {
        always {
          junit allowEmptyResults: true, testResults: '**/surefire-reports/*.xml, **/failsafe-reports/*.xml'
        }
      }
    }

    stage('Package') {
      steps {
        sh './mvnw -B -DskipTests package'
      }
      post {
        success {
          archiveArtifacts artifacts: 'target/*.jar', fingerprint: true, onlyIfSuccessful: true
        }
      }
    }

    stage('Docker Build & Login to ECR') {
      when {
        expression { return params.BUILD_DOCKER && fileExists('Dockerfile') }
      }
      steps {
        sh """
            aws ecr get-login-password --region ${AWS_REGION} | \
            docker login --username AWS --password-stdin ${ECR_REGISTRY}

            docker build --platform linux/amd64 -t ${ECR_REPO}:latest .
            docker tag ${ECR_REPO}:latest ${ECR_REGISTRY}/${ECR_REPO}:latest
        """
      }
    }

    stage('Push to ECR') {
      when {
        expression { return params.BUILD_DOCKER }
      }
      steps {
        sh "docker push ${ECR_REGISTRY}/${ECR_REPO}:latest"
      }
    }

    stage('Deploy') {
      steps {
        echo 'Deploying application...'
      }
    }

    stage('Restart App') {
      steps {
        echo 'Restarting app...'
      }
    }
  }

  post {
    success {
      echo "Build completed for development environment."
    }
    failure {
      echo "Build failed. Check test reports and logs."
    }
    always {
      echo "Pipeline finished (dev)."
    }
  }
}
