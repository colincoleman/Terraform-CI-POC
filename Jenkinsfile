stage 'build'
node{
    checkout scm
    def mvnHome = tool 'M3'
    sh "${mvnHome}/bin/mvn -B verify"
}