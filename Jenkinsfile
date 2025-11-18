pipeline {
    agent {
        kubernetes {
            inheritFrom 'mvn-builder'     //pod template name
            defaultContainer 'maven'       // Maven container for build/test
        }
    }

    environment {
        DOCKER_IMAGE = "amank47/petclinic"      // Updated Docker Hub repo
        DOCKERHUB_CREDS = credentials('dockerhub')
        DOCKER_HOST = "tcp://localhost:2375"    // docker client -> dind
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

        stage('Test') {
            steps {
                echo "Running unit tests..."
                sh "mvn test"
            }
        }

        // stage('Static Analysis') {
        //     steps {
        //         echo "Running SonarQube analysis..."
        //         withSonarQubeEnv('sonarqube') {
        //             sh "mvn sonar:sonar -Dsonar.projectKey=petclinic"
        //         }
        //     }
        // }

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
    }

    post {
        success {
            echo "Build & push completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs."
        }
    }
}
