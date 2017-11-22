#!/bin/bash
set -o pipefail
workspace=$(cd $(dirname $0) && pwd -P)
cd ${workspace}
module="autorder"
app=${module}
monitorLog="log/monitor.log"
mamachinesListFile="conf/machinesList.conf"
cookieFile="var/.cookiefile"
loginURL="http://115.156.135.252/dcms/userlogin.php"
detailURLPrefix="http://115.156.135.252/dcms/showdetail.php?ins_id="
orderURLPrefix="http://115.156.135.252/dcms/applyins.php?ins_id="
logFile="log/${module}.log"
loopFile="var/.loop"
#低于该门限值的,检测前不登录,单位为妙
threshold=180
#租期默认为12天,单位为天
tenancy=12
#系统最大支持的租借天数
maxTenancy=${tenancy}

source conf/account.conf

pidfile=var/.autorder-pid

chmod a+x ./${module}

## function
function start() {
    # 创建日志目录
    mkdir -p var &>/dev/null
    # 以后台方式 启动程序
    # check服务是否存活,如果存在则返回
    check_pid
    if [ $? -ne 0 ];then
        local pid=$(get_pid)
        echo "${app} is started, pid=${pid}"
        exit 0
    fi
    if [ ! -f ${srcfile} ]; then
        echo "程序意外终止:文件缺失"
        exit 1
    fi

    # 开启服务,并保存pid到pidfile文件中
    #nohup ./${app} -c ${conf} >>${logfile} 2>&1 &
    nohup sh ./${app} "${username}" "${password}" "${mamachinesListFile}" "${cookieFile}" "${loginURL}" "${detailURLPrefix}" "${orderURLPrefix}" "${logFile}" "${loopFile}" "${threshold}" "${tenancy}" "${maxTenancy}">${monitorLog} 2>&1 &
    echo $!>${pidfile}
    # 监控程序${app}会记录服务pid
    sleep 1
    # 检查服务是否启动成功
    check_pid
    if [ $? -eq 0 ];then
        echo "${app} start failed, please check"
        exit 1
    fi

    echo "${app} start ok, pid=$(get_pid)"
    # 启动成功, 退出码为 0
    exit 0
}
function stop() {
    # 循环stop服务, 直至60s超时
    for (( i = 0; i < 60; i++ )); do
        # 检查服务是否停止,如果停止则直接返回
        check_pid
        if [ $? -eq 0 ];then
           echo "${app} is stopped"
           exit 0
        fi
        # 检查pid是否存在
        local pid=$(get_pid)
        if [ ${pid} == "" ];then
           echo "${app} is stopped, can't find pid on ${pidfile}"
           exit 0
        fi
        # 停止该服务
        kill ${pid} &>/dev/null
        echo -n 0>${loopFile}
        # 检查该服务是否停止ok
        check_pid
        if [ $? -eq 0 ];then
            # stop服务成功, 返回码为 0
            echo "${app} stop ok"
            exit 0
        fi

        # 服务未停止, 继续循环
        sleep 1
    done
    # stop服务失败, 返回码为 非0
    echo "stop timeout(60s)"
    exit 1
}

function status(){
    check_pid
    local running=$?
    if [ ${running} -ne 0 ];then
        local pid=$(get_pid)
        echo "${app} is started, pid=${pid}"
    else
        echo "${app} is stopped"
    fi
    exit 0
}

## internals
function get_pid() {
    if [ -f $pidfile ];then
        cat $pidfile
    fi
}

function check_pid() {
    pid=$(get_pid)
    if [ "x_" != "x_${pid}" ]; then
        running=$(ps -p ${pid}|grep -v "PID TTY" |wc -l)
        return ${running}
    fi
    return 0
}

action=$1
case $action in
    "start" )
        # 启动服务
        start
        ;;
    "stop" )
        # 停止服务
        stop
        ;;
    "status" )
        # 检查服务
        status
        ;;
    * )
        echo "warming:Unknown option (ignored) $action,Use start|stop|status,please"
        exit 1
        ;;
esac
