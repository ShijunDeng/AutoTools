#!/bin/bash
username=`echo -n "TTIwMTU3MjYyMQ==" | base64 -d`
password=`echo -n "NTgzNjYw" | base64 -d`
#echo $username
#echo $password
mamachinesListFile="machinesList"
cookieFile="cookiefile"
loginURL="http://115.156.135.252/dcms/userlogin.php"
detailURLPrefix="http://115.156.135.252/dcms/showdetail.php?ins_id="
orderURLPrefix="http://115.156.135.252/dcms/applyins.php?ins_id="
loginFile="log.txt"
loopFile="loop"
#低于该门限值的,检测前不登录
threshold=300
#请求之前是否需要登录:高频请求不需要总是登录
loginOption=1

function printLog()
{
	local dateStr=`date "+%Y-%m-%d %H:%M:%S"`
	if [ ! -f ${loginFile} ]; then
		:>${loginFile}
	fi
	echo "[${dateStr}] $*" >> ${loginFile}
}

truncate ${loginFile} --size=0
echo -n 1 > ${loopFile}

printLog "启动服务"
while [ `cat ./loop` -eq 1 ];
do
	if [ ${loginOption} -eq 1 ]; then
		curl -F "username=${username}" -F "password=${password}" --cookie-jar ${cookieFile} ${loginURL} > /dev/null
		if [ $? -eq 0 ]; then
			printLog "登录成功"
		else
			printLog "登录失败"
			exit 1
		fi
	fi

	minDiff=$(( 3600 * 24 * 12 ))
	machinesList="`cat ${mamachinesListFile}`"
	for eachMachine in ${machinesList[@]}
	do
	    detailURL="${detailURLPrefix}${eachMachine}"
	    rs=`curl -b ${cookieFile} ${detailURL}`
	    wait
	    if [[ ${rs} =~ "使用人" ]]; then
			startTimeStr=`echo "${rs}" | grep -E  '[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}' -o`
			lease=`echo "${rs}" | grep -E  '[0-9]{2} 天' -o | grep -E '[0-9]{2}' -o`
			secondsA=`date -d "${startTimeStr}" +%s`
			deadline=`expr ${secondsA} + $(( 3600 * 24 * 12 ))`
			secondsNow=`date +%s`
			diffSeconds=$(( ${deadline} - ${secondsNow} ))
			if [ ${diffSeconds} -gt ${minDiff} ];then
				minDiff=${diffSeconds}
			fi
			printLog "${eachMachine}正在使用中,将在$(( ${diffSeconds} / ( 24 * 3600) ))天$(( ${diffSeconds} % ( 24 * 3600) / 3600 ))时$(( ${diffSeconds} % 3600 / 60 ))分$(( ${diffSeconds} % 60 ))秒后到期"
	    elif [[ ${rs} =~ "申请使用" ]]; then
			orderURL="${orderURLPrefix}${eachMachine}"
			curl -F "sel_num=12" -b ${cookieFile} ${orderURL} > /dev/null
			if [ $? -eq 0 ]; then
				printLog "预定${eachMachine}成功"
			else
				printLog "预定${eachMachine}失败"
			fi
		else 
			printLog "未知错误:${rs}"
	    fi
	    loginOption=1
	done
	
	sleepTime=$(( ${minDiff} / 60 + 1))
	printLog "将在${sleepTime}($(( ${sleepTime} / ( 24 * 3600) ))天$(( ${sleepTime} % ( 24 * 3600) / 3600 ))时$(( ${sleepTime} % 3600 / 60 ))分$(( ${sleepTime} % 60 )))秒后再次检测"

	if [ ${minDiff} -gt ${threshold} ];then
		loginOption=1		
	else
		printLog "进入频繁刷新时期,切换到直接请求模式" 
		loginOption=0
	fi
	sleep ${sleepTime}
done



