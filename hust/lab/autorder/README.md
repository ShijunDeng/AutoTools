# 欢迎使用autorder

##autorder是什么？

**autorder**针对WNLO-DSAL实验室的[小机房预定系统](http://115.156.135.252/dcms/index.php)(HUST校园内网访问)，通过程序自动抢占机器，进行预定，一次设置，便可以省去在实验室定期预定机器的麻烦。

-------------------

## autorder使用方法

### 配置

1.克隆autorder到本地，进入hust/lab/autorder目录

```
git clone https://github.com/ShijunDeng/AutoTools.git
cd hust/lab/autorder
```

2.修改配置文件

- 修改conf/account.conf中的配置参数，参照示例和说明即可
- email为接收预定通知的邮箱，若不需要启用邮箱通知服务将该字段置空即可；若启用该服务，请确保mail工具已被正确安装且可以被使用；mail的配置参照conf/mail.rc即可，可以用该文件直接覆盖mail默认配置文件；centos安装mail工具可使用命令``` yum -y install mail && yum -y install sendmail```
- 修改conf/machinesList.conf，将要预定的机器的编号填入，每台机器编号之间以空格隔开
- 修改autorder权限(最新版本若是root权限账户已经不需要该步骤)，```chmod a+x autorder```

### 使用

1.运行control.sh 启停、状态查看

```
sh control.sh start|stop|status
```

2.查看日志

- log/monitor.log为autorder软件的系统日志
- log/autorder.log为程序预定机器和监控机器的日志

### 其它

程序比较简单，可结合代码移植。


## 反馈与建议

- 邮箱：<dengshijun1992@qq.com>

---------
感谢阅读这份帮助文档。
