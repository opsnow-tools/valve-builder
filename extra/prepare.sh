#!/bin/bash

NAME=${1:-sample}
BRANCH=${2:-master}
NAMESPACE=${3:-devops}
BASE_DOMAIN=

printf "${NAME}" > ${HOME}/NAME
echo "# NAME: $(cat ${HOME}/NAME)"

printf "${BRANCH}" > ${HOME}/BRANCH
echo "# BRANCH: $(cat ${HOME}/BRANCH)"

get_domain() {
    NAME=${1}
    SAVE=${2}

    # DOMAIN=$(kubectl get ing -n ${NAMESPACE} -o wide | grep ${NAME} | head -1 | awk '{print $2}' | cut -d',' -f1)
    DOMAIN=$(kubectl get ing ${NAME} -n ${NAMESPACE} -o json | jq -r '.spec.rules[0].host')

    if [ ! -z ${DOMAIN} ]; then
        if [ "${NAME}" == "jenkins" ]; then
            BASE_DOMAIN=${DOMAIN:$(expr index $DOMAIN \.)}
            printf "$BASE_DOMAIN" > ${HOME}/BASE_DOMAIN
            echo "$ BASE_DOMAIN: $(cat ${HOME}/BASE_DOMAIN)"
        fi

        if [ ! -z ${BASE_DOMAIN} ]; then
            DOMAIN="${NAME}-${NAMESPACE}.${BASE_DOMAIN}"
        fi
    fi

    printf "${DOMAIN}" > ${HOME}/${SAVE}
    echo "# ${SAVE}: $(cat ${HOME}/${SAVE})"
}

get_maven_mirror() {
    if [ -f /root/extra/settings.xml ]; then
        cp -rf /root/extra/settings.xml ${HOME}/settings.xml
    fi
    NEXUS=$(cat ${HOME}/NEXUS)
    if [ ! -z ${NEXUS} ]; then
        PUBLIC="http://${NEXUS}/repository/maven-public/"
        MIRROR="<mirror><id>mirror</id><url>${PUBLIC}</url><mirrorOf>*</mirrorOf></mirror>"
        sed -i "s|<!-- ### configured mirrors ### -->|${MIRROR}|" ${HOME}/settings.xml
    fi
}

get_domain jenkins JENKINS
get_domain chartmuseum CHARTMUSEUM
get_domain docker-registry REGISTRY
get_domain sonarqube SONARQUBE
get_domain sonatype-nexus NEXUS

get_maven_mirror
