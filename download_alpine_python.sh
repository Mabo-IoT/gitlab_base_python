#！/bin/bash
tag=3.7-alpine
docker pull python:$tag
docker tag python:$tag python:latest
docker build -f mabo_base_python_Dockerfile -t base_python:$tag .
docker tag base_python:$tag base_python:latest
docker save -o python base_python:$tag base_python:latest python:$tag python:latest
docker rmi base_python:$tag base_python:latest python:latest

