#!/bin/bash

test_container="task_644_g1_drds-server_drds_5"
test_check="python /checkHealth.py"

function do_check {
    sudo docker exec $1 ${@:2}
}


function do_into {
    sudo docker exec -it $1 bash
}

function do_choice {
    # $1 容器名
    # $2 容器名对应的检查操作
    read -p "$1 [c/n/i/f/g]: " choice
    if [ "$choice" == "c" ];then
        do_check $1 ${@:2}
        echo ""
        echo "$1 ${@:2} is Finished."
    elif [ "$choice" == "n" ];then
        echo "Skip: $1"
        return 100
    elif [ "$choice" == "i" ];then
        do_into $1
    elif [ "$choice" == "f" ];then
        echo "QUIT."
        exit 1
    elif [ "$choice" == "g" ];then
        do_check $1 ${@:2}
        echo ""
        echo "$1 ${@:2} is Finished."
        return 100
    else
        return 404
    fi
}


function main {
    host_name=`hostname`
    script_path=$(dirname $(readlink -f "$0"))
    if [ ! -f "$script_path/drds_docker.db" ];then
        echo "[ERROR]Not found the drds_docker.db"
    fi
    OLDIFS=$IFS
    IFS=$'\n'
    for line in `cat $script_path/drds_docker.db`;
    do
        IFS=$OLDIFS
        check_opt=`echo $line | cut -d @ -f 2`
        container=`echo $line | cut -d @ -f 1 | egrep -o "$host_name/.*?" | sed "s:${host_name}/::g"`
        while :;
        do
            do_choice $container $check_opt
            if [ $? -eq 100 ];then
                break
            fi
        done
        IFS=$'\n'
    done
}



main