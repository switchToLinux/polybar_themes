#!/usr/bin/env bash

# 本脚本用于自动修改 var.ini 配置文件中变量

config_file=$POLYBAR_HOME/template/var.ini
output_file=$POLYBAR_HOME/.var.ini

function set_cpu_path() { #设置CPU温度监控路径
    value=`ls /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input|head -1`
    sed -i -E "s|^(hwmon_path =).*|\1 ${value}|g" $output_file
}

function set_network_interface() { #设置网络接口类型有线或无线
    value=`ip route|awk '/^default/{ print $5 }'|head -1`
    sed -i -E "s|^(network_interface =).*|\1 ${value}|g" $output_file
}

################################
cp $config_file $output_file
set_cpu_path
set_network_interface
