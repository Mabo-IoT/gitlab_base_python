#！/bin/bash
set -e
tag_alpine=3.7-alpine3.11
tag_slim=3.7-slim

docker pull python:$tag_alpine
docker pull python:$tag_slim
docker tag python:$tag_alpine python:latest
# 构建基础通用,alpine版本
docker build -f mabo_base_python_Dockerfile \
    -t base_python:$tag_alpine --build-arg image_tag=$tag_alpine .
docker tag base_python:$tag_alpine base_python:latest
# 构建用于运维，带docker的
docker build -f mabo_base_python_with_docker_Dockerfile \
    -t base_python_docker:$tag_alpine --build-arg image_tag=$tag_alpine .
docker tag base_python_docker:$tag_alpine base_python_docker:latest
# 构建基础通用,slim版本
docker pull python:$tag_slim
docker build -f mabo_base_python_slim_Dockerfile \
    -t base_python:$tag_slim --build-arg image_tag=$tag_slim .
# 构建用于视频处理的python镜像
docker build -f mabo_base_python_with_video_Dockerfile \
    -t base_python_video:$tag_slim --build-arg image_tag=$tag_slim .
docker tag base_python_video:$tag_slim base_python_video:latest
# 保存，清理
docker save -o python \
    base_python:$tag_alpine base_python:$tag_slim base_python:latest \
    base_python_docker:$tag_alpine base_python_docker:latest \
    base_python_video:$tag_slim base_python_video:latest
# docker rmi base_python:$tag_alpine base_python:latest python:latest base_python_docker:$tag_alpine base_python_docker:latest

