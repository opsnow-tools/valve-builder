#!/bin/bash

get_domain() {
    NAME=${1}
    SAVE=${2}
    NAMESPACE=${3}

    DOMAIN=$(kubectl get ing -n ${NAMESPACE} -o wide | grep ${NAME} | head -1 | awk '{print $2}' | cut -d',' -f1)

    printf "${DOMAIN}" > ${HOME}/${SAVE}

    if [ ! -z ${DOMAIN} ] && [ "${NAME}" == "jenkins" ]; then
        BASE_DOMAIN=${DOMAIN:$(expr index $DOMAIN \.)}
        printf "$BASE_DOMAIN" > ${HOME}/BASE_DOMAIN
        echo "# BASE_DOMAIN: $(cat ${HOME}/BASE_DOMAIN)"
    fi

    echo "# ${SAVE}: $(cat ${HOME}/${SAVE})"
}

NAMESPACE=${1:-devops}

get_domain jenkins JENKINS ${NAMESPACE}
get_domain chartmuseum CHARTMUSEUM ${NAMESPACE}
get_domain docker-registry REGISTRY ${NAMESPACE}
get_domain sonarqube SONARQUBE ${NAMESPACE}
get_domain sonatype-nexus NEXUS ${NAMESPACE}
