pipeline {
    agent any

    stages{
        stage("build") {
            steps {
                sh "flutter clean"
                sh "flutter pub get"
                sh "flutter build web"
            }
        }
    }
}