#!/usr/bin/env bash

# 导入 功能函数
source $POLYBAR_HOME/scripts/01-functions.sh

themedir=`dirname $0`
# 配置文件路径
CONFIG_FILE="$themedir/config.ini"

# 主题样式设置 circle/default(rectangle)/triangle/wave/fire/random
export THEME_STYLE="${1:-triangle}"

# 主题颜色方案: 对应 colors 目录下的 ${THEME_COLOR}.ini 文件
export THEME_COLOR="${2:-zioer}"

# 主题显示中文
export THEME_LANG="${3:-zh_CN}"

change_lang  $THEME_LANG
change_style $THEME_STYLE
change_color $THEME_COLOR

# 启动 Polybar
# --reload 参数支持 配置修改后自动加载
# -q quiet 尽量少的输出日志信息
# 配置文件变更后 是否需要自动重新加载(测试期间开启，正式使用建议关闭，变更配置重启i3就可以了)

options=" -q "

polybar ${options} --config="$CONFIG_FILE" main_top &
polybar ${options} --config="$CONFIG_FILE" main_bottom &
if [ "$MONITOR2" != "" ] ; then
    polybar ${options} --config="$CONFIG_FILE" monitor2 &
fi

#END