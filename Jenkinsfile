pipeline {
    agent any

    triggers {
        pollSCM('H/5 * * * *')
    }


    environment {
        APP_NAME     = "phonestore"
        DOCKER_USER  = "tienmanh24"
        IMAGE_TAG    = "v${env.BUILD_NUMBER}"
        INFRA_REPO   = "https://github.com/TienManh24092003/Pet-project.git"
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
                    bat """
                      echo %DOCKER_TOKEN% | docker login -u %DOCKER_USER% --password-stdin
                      docker build -t docker.io/%DOCKER_USER%/%APP_NAME%:%IMAGE_TAG% .
                      docker push docker.io/%DOCKER_USER%/%APP_NAME%:%IMAGE_TAG%
                    """
                }
            }
        }

        stage('Update Infra Repo with New Tag') {
            steps {
                dir('infra') {
                    git branch: "${INFRA_BRANCH}",
                        url: "${INFRA_REPO}",
                        credentialsId: 'git-token'

                    bat """
                      powershell -Command "(Get-Content kubernetes/springboot-deployment.yaml) -replace 'image: ${DOCKER_USER}/${APP_NAME}:.*', 'image: ${DOCKER_USER}/${APP_NAME}:${IMAGE_TAG}' | Set-Content kubernetes/springboot-deployment.yaml"

                      git config user.email "jenkins@ci.local"
                      git config user.name "Jenkins CI"
                      git add kubernetes/springboot-deployment.yaml
                      git commit -m "Update ${APP_NAME} image to ${IMAGE_TAG}"
                    """

                    withCredentials([usernamePassword(
                        credentialsId: 'git-token',
                        usernameVariable: 'GIT_USER',
                        passwordVariable: 'GIT_TOKEN'
                    )]) {
                        bat """
                          git push https://%GIT_USER%:%GIT_TOKEN%@github.com/TienManh24092003/Pet-project.git ${INFRA_BRANCH}
                        """
                    }
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
