
node{
    stage 'Maven Build'
    checkout scm
    def mvnHome = tool 'M3'
    sh "${mvnHome}/bin/mvn -B verify"

    stage 'Docker Build'
    docker.build('terraform-ci-poc')

    stage 'Docker Push to ECR'
    docker.withRegistry('https://752583717420.dkr.ecr.eu-west-1.amazonaws.com','ecr:eu-west-1:aws-deploy') {
        docker.image('terraform-ci-poc').push('latest')
    }
}