#!groovy

import jenkins.model.*
import hudson.security.*

def env = System.getenv()

def instance = Jenkins.getInstance()
def username = env["ADMIN_JENKINS_USER"]
def password = env["ADMIN_JENKINS_PASSWORD"]

println "Creating admin user=" + username + " password=" + password

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(username, password)
instance.setSecurityRealm(hudsonRealm)

println "Setting up auth"
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)
instance.save()
println "Ready"
