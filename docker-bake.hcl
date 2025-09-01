# variables defined in .env file to pass into Dockerfile
variable "NAGIOS_HOME" {}
variable "NAGIOS_USER" {}
variable "NAGIOS_GROUP" {}
variable "NAGIOS_BRANCH" {}
variable "NAGIOS_PLUGINS_BRANCH" {}
variable "NRPE_BRANCH" {}
variable "NSCA_BRANCH" {}
variable "NAGIOSADMIN_PASSWORD" {}
variable "NSCA_PASSWORD" {}
variable "NAGIOS_VERSION" {}
variable "GIT_COMMIT_SHORT" {}

target "default" {
    context = "."
    dockerfile = "Dockerfile"
    args = {
        NAGIOS_HOME = "${NAGIOS_HOME}"
        NAGIOS_USER = "${NAGIOS_USER}"
        NAGIOS_GROUP = "${NAGIOS_GROUP}"
        NAGIOS_BRANCH = "${NAGIOS_BRANCH}"
        NAGIOS_PLUGINS_BRANCH = "${NAGIOS_PLUGINS_BRANCH}"
        NRPE_BRANCH = "${NRPE_BRANCH}"
        NSCA_BRANCH = "${NSCA_BRANCH}"
    }
    secret = [
        "id=NAGIOSADMIN_PASSWORD,env=NAGIOSADMIN_PASSWORD",
        "id=NSCA_PASSWORD,env=NSCA_PASSWORD"
    ]
    cache-from = ["type=gha,scope=bake"]
    cache-to = ["type=gha,scope=bake,mode=max"]
    tags = [
        "cpuchalver/nagios:latest",
        "cpuchalver/nagios:${NAGIOS_VERSION}",
        notequal(GIT_COMMIT_SHORT, "") ? "cpuchalver/nagios:${GIT_COMMIT_SHORT}" : ""
    ]
    platforms = ["linux/amd64"]
}