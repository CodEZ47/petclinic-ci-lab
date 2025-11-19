pipeline {
    agent {
        kubernetes {
            inheritFrom 'mvn-builder'     
            defaultContainer 'maven'      
        }
    }

    environment {
        DOCKER_IMAGE = "amank47/petclinic"      
        DOCKERHUB_CREDS = credentials('dockerhub')
        DOCKER_HOST = "tcp://localhost:2375"    
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out project source code..."
                checkout scm
            }
        }

        stage('Build with Maven') {
            steps {
                echo "Building app using Maven..."
                sh "mvn -B clean package -DskipTests"
            }
        }

        stage('Static Analysis') {
            steps {
                echo "Running SonarQube analysis..."
                withSonarQubeEnv('sonarqube') {
                    sh """
                        mvn sonar:sonar \
                            -Dsonar.projectKey=petclinic \
                            -Dsonar.host.url=$SONAR_HOST_URL \
                            -Dsonar.login=$SONAR_AUTH_TOKEN
                    """
                }
            }
        }


        stage('Build Docker Image') {
            steps {
                container('docker') {
                    echo "Building Docker image using dind..."
                    sh """
                        docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                container('docker') {
                    echo "Pushing Docker image to Docker Hub..."
                    sh """
                        echo "${DOCKERHUB_CREDS_PSW}" | docker login \
                            -u "${DOCKERHUB_CREDS_USR}" --password-stdin

                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}

                        docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                        docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                        echo "Deploying Petclinic and MySQL..."
                        sh """
                            kubectl --kubeconfig=\$KUBECONFIG apply -f k8s/mysql/
                            kubectl --kubeconfig=\$KUBECONFIG apply -f k8s/petclinic/
                        """
                    }
                }
            }
        }

    }

    


    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs."
        }
    }
}
