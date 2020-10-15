# valve-builder

[![GitHub release](https://img.shields.io/github/release/opsnow-tools/valve-builder.svg)](https://github.com/opsnow-tools/valve-builder/releases)
[![CircleCI](https://circleci.com/gh/opsnow-tools/valve-builder.svg?style=svg)](https://circleci.com/gh/opsnow-tools/valve-builder)

[![DockerHub Badge](http://dockeri.co/image/opsnowtools/valve-builder)](https://hub.docker.com/r/opsnowtools/valve-builder/)


valve-builder 는 젠킨스에서 개별 작업을 실행하는 젠킨스 슬레이브가 실제 필드 작업에 사용할 컨테이너 이미지를 제공합니다.
docker를 베이스 이미지로 사용하여 각 종 툴을 설치해 최종 이미지를 제공합니다.
설치되는 주요 도구는 아래와 같습니다.

## tools
```
ENV awscli 1.16.159
ENV awsauth 0.3.0
ENV helm v2.16.3
ENV kubectl v1.18.10
```

## docket image
최종적으로 만들어진 이미지는 도커허브에 업로드 됩니다.
```bash
docker pull opsnowtools/valve-builder
```