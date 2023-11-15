pipeline {
    agent any

    stages{
        stage("build") {
            steps {
                sh "flutter build web"
            }
        }

        stage("test") {
            steps {
                echo "testing..."
            }
        }

    }
}