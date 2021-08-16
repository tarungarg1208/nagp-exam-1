pipeline {
    agent any
    options {
        timestamps()
        timeout(60)
    }
    tools {
        jdk 'Java'
        nodejs 'nodejs'
        dockerTool 'Test_Docker'
    }
    environment {
        registry = 'tarungarg1208/nagp-exam-1'
        username = 'tarungarg02'
        dockerport = 7400
        PROJECT_ID = 'nagp-devops-assignment'
        CLUSTER = 'nagp-assignment'
        LOCATION = 'us-central1-c'
        CREDENTIALS = 'nagp-gcp-key'
    }
    stages {
        stage('checkout code') {
            steps {
                echo 'Fetching Code from SCM'
                checkout scm
                // checkout([$class: 'GitSCM', branches: [[name: '*/feature']], extensions: [], userRemoteConfigs: [[credentialsId: '70c8e005-4a66-4653-b36f-7cb529170c6a', url: 'https://github.com/tarungarg1208/nagp-exam-1.git']]])
            }
        }
        stage('Build') {
            steps {
                bat 'npm install'
            }
        }
        stage('Unit Tests') {
            steps {
                bat 'npm test'
            }
        }
        stage('Sonar Analysis') {
            steps {
                echo 'SONAR Analysis'
            bat "..\\..\\tools\\hudson.plugins.sonar.SonarRunnerInstallation\\SonarQubeScanner\\bin\\sonar-scanner.bat -Dsonar.host.url=http://localhost:9000 -Dsonar.login=658cd6afba259bd114439d623d10e01af79523cc"
            }
        }
        stage('Building Docker Image') {
            steps {
                echo 'Creating Docker Image'
                bat "docker build . -t i-${username}:latest"
            }
        }
        stage('Docker Tagging/Push') {
            steps {
                echo 'Tagging Docker Image'
                bat "docker tag i-${username}:latest ${registry}:${BUILD_NUMBER}"
                bat "docker tag i-${username}:latest ${registry}:latest"

                echo 'Pushing Docker Image'
                withDockerRegistry(credentialsId: 'DockerHub', url: '') {
                    bat "docker push ${registry}:${BUILD_NUMBER}"
                    bat "docker push ${registry}:latest"
                }
            }
        }
        stage('Pre-Container Check') {
            steps {
                echo 'Removing docker container if any'
                script {
                    try {
                        bat "docker rm -f c-${username}"
                    }
                catch (Exception e) {
                        echo 'No container to remove'}
                }
            }
        }
        stage('Deployment') {
            steps {
                parallel(
                'Docker Deployment': {
                    bat "docker run --name=c-${username} -d -p=${dockerport}:7100 ${registry}:latest"
                },
                'Kubetnetes Deployment': {
                    echo 'Deploying onto kubernetes'
                    step([$class: 'KubernetesEngineBuilder',
                        projectId: env.PROJECT_ID,
                        clusterName: env.CLUSTER,
                        zone: env.LOCATION,
                        manifestPattern: 'k8s/deployment.yaml',
                        credentialsId: env.CREDENTIALS,
                        verifyDeployments: false])
                }
                )
            // Deploying on docker and kubernetes in parallel
            }
        }
    }
}
