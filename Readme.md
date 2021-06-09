# 使用范围

1. 需要更新python
2. 需要增加python依赖库
3. 环境变更。





# 使用方法

**注意：sh与ci.yml存在关于python的tag版本名字需要相同。sh中为tag字段，ci.yml中为VERSION字段。更新时，需要检查。**



1. **在外网，带有docker客户端的电脑中**，通过运行`download_alpine_python.sh`文件后，生成一个名为python的大文件。
2. 然后直接向gitlab提交即可，后续程序的构建，会由ci自动执行。





# runner部署时

runner部署时需要修改配置文件，改为对应的的镜像。



# 实现说明

1. sh中下载python的对应镜像。
2. 在sh中build镜像，包括基础的依赖库的安装，等等。
3. 然后在ci中修改名字，上传至register，由后续的base_python进行操作。

<!--本来想做成python与包分开两步，但在实际操作中发现，这个想法很蠢。-->

<!--分离doctopus、ziyan是正确，其他的就没必要了。-->



# 构建命令行：

#### alpine版本：

```
docker build -f mabopython_Dockerfile_alpine -t mabo/python:3.7.1-alpine-0.1.5 .

# 修改tag 
docker tag mabo/python:3.7.1-alpine-0.1.5 mabo/python:latest
```

#### 完整版本：（不需要）

```
docker build -f mabopython_Dockerfile -t mabo/python:3.7.0-stretch .
```



# 更新记录

#### 20-03-04 zhy:

- 增加关于video的处理的python镜像。

- 解决某些包（twisted）需要先升级另外一些包（incremental）才能安装的问题。

- 添加某些包(pendulum)需要的apt库。

- 把pip一长串，使用pip_install_proxy代替，增加可读性。

- opencv还不能直接装啊，不能转到alpine上，只能装到slim上啊。好吧

  > https://github.com/skvark/opencv-python/issues/75#issuecomment-388571221

<!--每次重新构建镜像，感觉都是玄学式更新，艹-->