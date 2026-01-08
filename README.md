# Jenkins CI/CD Demo

A simple Node.js Todo application with automated Docker deployment using Jenkins.

## 🚀 Quick Start

### Prerequisites

-   Docker
-   Jenkins
-   Node.js 20+
-   Docker Hub account

### Local Development

```bash
# Clone the repository
git clone https://github.com/wissemgrari/jenkins-cicd-demo.git
cd jenkins-cicd-demo

# Install dependencies
npm install

# Run the app
node src/index.js
```

Access the app at `http://localhost:3000`

## 🐳 Docker

### Build and Run Manually

```bash
# Build image
docker build -t wissemgrari/todoapp:v1 .

# Run container
docker run -d -p 3000:3000 --name todoapp wissemgrari/todoapp:v1
```

## 🔧 Jenkins Setup

### 1. Configure Docker Permissions

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### 2. Add Docker Hub Credentials

1. Jenkins Dashboard → Manage Jenkins → Manage Credentials
2. Add Credentials:
    - **Kind**: Username with password
    - **ID**: `dockerhub`
    - **Username**: Your Docker Hub username
    - **Password**: Your Docker Hub access token

### 3. Create Pipeline Job

1. New Item → Pipeline
2. Pipeline definition: Pipeline script from SCM
3. Repository: `https://github.com/wissemgrari/jenkins-cicd-demo.git`
4. Branch: `main`
5. Script Path: `Jenkinsfile`

### 4. Jenkinsfile Configuration

Copy this pipeline script into the Jenkins Pipeline script field:

```groovy
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "wissemgrari/todoapp"
        CONTAINER_NAME = "todoapp-container"
        APP_PORT = "3000"
        HOST_PORT = "3000"
    }

    stages {
        stage("Code checkout") {
            steps {
                git branch: 'main', url: 'https://github.com/wissemgrari/jenkins-cicd-demo.git'
            }
        }

        stage("Build Docker Image") {
            steps {
                script {
                    echo "Building Docker image: ${DOCKER_IMAGE}:v${BUILD_ID}"
                    sh "docker image build -t ${DOCKER_IMAGE}:v${BUILD_ID} ."
                    sh "docker image tag ${DOCKER_IMAGE}:v${BUILD_ID} ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage("Push to Docker Hub") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub',
                                                  passwordVariable: 'password',
                                                  usernameVariable: 'user')]) {
                    sh "docker login -u ${user} -p ${password}"
                    sh "docker image push ${DOCKER_IMAGE}:v${BUILD_ID}"
                    sh "docker image push ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage("Deploy Container") {
            steps {
                script {
                    echo "Deploying container: ${CONTAINER_NAME}"

                    // Stop and remove old container if exists
                    sh "docker stop ${CONTAINER_NAME} || true"
                    sh "docker rm ${CONTAINER_NAME} || true"

                    // Run new container
                    sh """
                        docker run -d \
                        --name ${CONTAINER_NAME} \
                        -p ${HOST_PORT}:${APP_PORT} \
                        --restart unless-stopped \
                        ${DOCKER_IMAGE}:v${BUILD_ID}
                    """

                    echo "Container deployed successfully on port ${HOST_PORT}"
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up created images..."
            sh "docker rmi ${DOCKER_IMAGE}:v${BUILD_ID} || true"
            sh "docker rmi ${DOCKER_IMAGE}:latest || true"
            sh 'docker image prune -f || true'
        }
        success {
            echo "✅ Build successful! Image: ${DOCKER_IMAGE}:v${BUILD_ID}"
        }
        failure {
            echo "❌ Build failed. Check logs for details."
        }
    }
}
```

## 📋 Pipeline Stages

The Jenkins pipeline automatically:

1. **Checkout** - Pulls code from GitHub
2. **Build** - Creates Docker image with version tag
3. **Push** - Uploads image to Docker Hub
4. **Deploy** - Runs container on Jenkins server
5. **Cleanup** - Removes local images to save space

## 🛠️ Troubleshooting

### Docker Permission Denied

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### SQLite Binding Error

```bash
npm rebuild sqlite3
```

### View Container Logs

```bash
docker logs todoapp-container
```

### Check Running Containers

```bash
docker ps
```

## 📝 Project Structure

```
├── src/
│   └── index.js          # App entry point
├── persistence/
│   └── sqlite.js         # Database
├── Dockerfile            # Docker config
├── Jenkinsfile          # Pipeline definition
└── package.json         # Dependencies
```

## 👤 Author

**Wissem Grari**

-   GitHub: [@wissemgrari](https://github.com/wissemgrari)
