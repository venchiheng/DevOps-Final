pipeline {
    agent any

    environment {
        // Email for CC on errors
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
                // Install PHP dependencies
                sh 'composer install --no-interaction --prefer-dist'

                // Clear config after dependencies are installed
                sh 'php artisan config:clear'

                // Install Node.js dependencies (if needed)
                sh 'npm install'

                // Build frontend (if applicable)
                sh 'npm run build'
            }
        }

        stage('Test') {
            steps {
                // Your test commands here
                sh './run_tests.sh'  // replace with your real test command
            }
        }

        stage('Deploy') {
            when {
                expression { currentBuild.currentResult == 'SUCCESS' }
            }
            steps {
                // Run Ansible playbook for deployment
                sh 'ansible-playbook -i inventory/webserver.ini deploy.yml'
            }
        }
    }

    post {
        failure {
            script {
                // Get the committer email from the last commit
                def commitEmail = sh(script: "git log -1 --pretty=format:%ae", returnStdout: true).trim()

                // Compose email recipients
                def recipients = "${CC_EMAIL},${commitEmail}"

                // Send email on failure
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
