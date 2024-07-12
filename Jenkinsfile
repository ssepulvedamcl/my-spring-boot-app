pipeline {
    agent any
    
    environment {
        // Define environment variables
        DOCKER_IMAGE = "ssepulvedacl/my-spring-boot-app"
        REGISTRY = "registry.hub.docker.com" // e.g., Docker Hub or any other registry
        //KUBE_CONFIG_PATH = credentials('kube-config') // Credential ID for Kubernetes config
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
        stage('Build Docker Image') {
            steps {
                script {
                    // Construye la imagen Docker
                    def image = docker.build("${DOCKER_IMAGE}:${env.BUILD_ID}")
                    // Inicia sesión en el registro Docker
                    docker.withRegistry("https://${env.REGISTRY}", 'docker-credentials-id') {
                        // Empuja la imagen al registro
                        image.push()
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Crea un archivo de despliegue para Kubernetes
                    sh '''
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
                    '''

                    // Despliega en Kubernetes
                    //withKubeConfig([credentialsId: env.KUBE_CONFIG_PATH]) {
                        sh 'kubectl apply -f k8s-deployment.yaml'
                    //}
                }
            }
        }
	stage('Cleanup'){
		steps{
			//Limpieza despues de cada build
			cleanWs()
		}
	}
    }

}

