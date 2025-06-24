pipeline {
	agent any

	environment {
    	// Email for CC on errors
    	CC_EMAIL = 'srengty@gmail.com'
	}

	options {
    	// Poll SCM every 5 minutes
    	pollSCM('H/5 * * * *')
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
            	// Your build commands here, e.g.:
            	sh './build.sh'  // replace with your build command
        	}
    	}

    	stage('Test') {
        	steps {
            	// Your test commands here, e.g.:
            	sh './run_tests.sh'  // replace with your test command
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
            	def commitEmail = sh(script: "git log -1 --pretty=format:'%ae'", returnStdout: true).trim()
           	 
            	// Compose email recipients
            	def recipients = "${CC_EMAIL},${commitEmail}"
           	 
            	// Send email on failure
            	emailext (
                	to: recipients,
                	subject: "Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                	body: """<p>Build failed for ${env.JOB_NAME} #${env.BUILD_NUMBER}.</p>
                         	<p>Check console output at <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>"""
            	)
        	}
    	}
	}
}
