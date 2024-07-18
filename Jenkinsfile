pipeline {
    agent any
    
    environment {
        // Define environment variables
        DOCKER_IMAGE = "ssepulvedacl/my-spring-boot-app"
        REGISTRY = "registry.hub.docker.com" // e.g., Docker Hub or any other registry
        //KUBE_CREDENTIALS_ID = 'kube-config' // Credential ID for Kubernetes config
        //DOCKER_CREDENTIALS_ID = 'docker-credentials-id' // Credential ID for Docker Registry
        SONARQUBE_SERVER = 'SonarQube'
    }

    stages {
        stage('Checkout') {
            steps {
                // Clona el repositorio
                git branch: 'main', url: 'https://github.com/ssepulvedamcl/my-spring-boot-app.git'
            }
        }
        stage('Build') {
            steps {
                // Construye el proyecto Maven
                sh 'mvn clean package'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                script {
                    // Realiza el análisis de SonarQube
                    def scannerHome = tool 'SonarQube Scanner' // Nombre de la herramienta SonarQube Scanner configurada en Jenkins
                    withSonarQubeEnv(SONARQUBE_SERVER) {
                        sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=my-spring-boot-app -Dsonar.sources=. -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONARQUBE_TOKEN"
                    }
                }
            }
        }
        stage('Quality Gate') {
            steps {
                script {
                    // Espera y comprueba el resultado del análisis de SonarQube
                    timeout(time: 1, unit: 'MINUTES') {
                        waitForQualityGate abortPipeline: true
                    }
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    // Construye la imagen Docker
                    def image = docker.build("${DOCKER_IMAGE}:${env.BUILD_ID}")
                    // Inicia sesión en el registro Docker
                    docker.withRegistry("https://${env.REGISTRY}", env.DOCKER_CREDENTIALS_ID) {
                        // Empuja la imagen al registro
                        image.push()
                    }
                }
            }
        }
        /*
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Crea un archivo de despliegue para Kubernetes
                    sh """
                    cat <<EOF > k8s-deployment.yaml
                    apiVersion: apps/v1
                    kind: Deployment
                    metadata:
                      name: my-spring-boot-app
                      labels:
                        app: my-spring-boot-app
                    spec:
                      replicas: 1
                      selector:
                        matchLabels:
                          app: my-spring-boot-app
                      template:
                        metadata:
                          labels:
                            app: my-spring-boot-app
                        spec:
                          containers:
                          - name: my-spring-boot-app-container
                            image: ${REGISTRY}/${DOCKER_IMAGE}:${env.BUILD_ID}
                            ports:
                            - containerPort: 8080
                    ---
                    apiVersion: v1
                    kind: Service
                    metadata:
                      name: my-spring-boot-app-service
                    spec:
                      type: LoadBalancer
                      ports:
                      - port: 80
                        targetPort: 8080
                      selector:
                        app: my-spring-boot-app
                    EOF
                    """

                    // Despliega en Kubernetes
                    //withKubeConfig([credentialsId: env.KUBE_CREDENTIALS_ID]) {
                        sh 'kubectl apply -f k8s-deployment.yaml'
                    //}
                }
            }
        }*/
        stage('Cleanup') {
            steps {
                // Limpieza despues de cada build
                cleanWs()
            }
        }
    }
}




