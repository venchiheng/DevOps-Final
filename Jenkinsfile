pipeline {
    agent any

    environment {
        // Email for CC on errors/success
        CC_EMAIL = 'chiheng357@gmail.com'
    }

    triggers {
        // Poll SCM every 5 minutes
        pollSCM('H/5 * * * *')
    }

    options {
        // Keep build logs for 30 days, max 50 builds
        buildDiscarder(logRotator(daysToKeepStr: '30', numToKeepStr: '50'))
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'composer install --no-interaction --prefer-dist'
                sh 'cp .env.example .env || true'     // copy if not exist
                sh 'php artisan key:generate'         // generate APP_KEY
                sh 'php artisan config:clear'
            }
        }

        stage('Test') {
            steps {
                sh './vendor/bin/pest'
            }
        }
    }

    post {
        success {
            script {
                def commitEmail = sh(script: "git log -1 --pretty=format:%ae", returnStdout: true).trim()
                def recipients = "${CC_EMAIL},${commitEmail}"

                emailext (
                    to: recipients,
                    subject: "Build Success: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    body: """
                        <p><b>Build succeeded</b> for <b>${env.JOB_NAME}</b> #${env.BUILD_NUMBER}.</p>
                        <p>Check console output: <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>
                    """,
                    mimeType: 'text/html'
                )
            }
        }
        failure {
            script {
                def commitEmail = sh(script: "git log -1 --pretty=format:%ae", returnStdout: true).trim()
                def recipients = "${CC_EMAIL},${commitEmail}"

                emailext (
                    to: recipients,
                    subject: "Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    body: """
                        <p><b>Build failed</b> for <b>${env.JOB_NAME}</b> #${env.BUILD_NUMBER}.</p>
                        <p>Check console output: <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>
                    """,
                    mimeType: 'text/html'
                )
            }
        }
    }
}
