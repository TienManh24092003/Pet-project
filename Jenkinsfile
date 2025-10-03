pipeline {
    agent any

    environment {
        APP_NAME     = "phonestore"
        DOCKER_USER  = "tienmanh24"
        IMAGE_TAG    = "v${env.BUILD_NUMBER}"
        INFRA_REPO   = "https://github.com/TienManh/Pet-project.git"
        INFRA_BRANCH = "develop"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build JAR') {
            steps {
                bat 'mvnw.cmd clean package -DskipTests'
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-token',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_TOKEN'
                )]) {
                    sh '''
                      echo $DOCKER_TOKEN | docker login -u $DOCKER_USER --password-stdin
                      docker build -t $DOCKER_USER/$APP_NAME:$IMAGE_TAG .
                      docker push $DOCKER_USER/$APP_NAME:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Update Infra Repo with New Tag') {
            steps {
                dir('infra') {
                    git branch: "${INFRA_BRANCH}", url: "${INFRA_REPO}", credentialsId: 'git-token'

                    sh '''
                      sed -i "s|image: ${DOCKER_USER}/${APP_NAME}:.*|image: ${DOCKER_USER}/${APP_NAME}:${IMAGE_TAG}|" kubernetes/springboot-deployment.yaml

                      git config user.email "jenkins@ci.local"
                      git config user.name "Jenkins CI"
                      git commit -am "Update ${APP_NAME} image to ${IMAGE_TAG}"
                      git push origin ${INFRA_BRANCH}
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "CI hoàn tất: Image ${DOCKER_USER}/${APP_NAME}:${IMAGE_TAG} đã build & push, manifest đã update"
        }
        failure {
            echo "CI thất bại"
        }
    }
}
