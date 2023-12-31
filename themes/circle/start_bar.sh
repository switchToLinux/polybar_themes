#!/usr/bin/env bash

######################################################################
# 文件名: start_bar.sh
# 作者: Awkee
# 创建时间: 2023-07-12
# 描述: polybar主题bar启动脚本，入口参数:  start_bar.sh [theme_style] [theme_color]
# 备注: 
#   - ...
######################################################################


# 导入 功能函数
source $POLYBAR_HOME/scripts/01-functions.sh

themedir=`dirname $0`
# 配置文件路径
CONFIG_FILE="$themedir/config.ini"

# 主题样式设置 circle/default(rectangle)/triangle/wave/fire/random
export THEME_STYLE="${1:-circle}"

# 主题颜色方案: 对应 colors 目录下的 ${THEME_COLOR}.ini 文件
export THEME_COLOR="${2:-circle}"

# 主题显示中文
export THEME_LANG="${3}"

# 启动自动隐藏，默认true开启,false关闭
export ENABLE_AUTOHIDE="${4:-true}"

change_lang  $THEME_LANG
change_style $THEME_STYLE
change_color $THEME_COLOR


# 启动 Polybar
# --reload 参数支持 配置修改后自动加载
# -q quiet 尽量少的输出日志信息
# 配置文件变更后 是否需要自动重新加载(测试期间开启，正式使用建议关闭，变更配置重启i3就可以了)

options=" -q "

nohup polybar ${options} --config="$CONFIG_FILE" main_top >/dev/null 2>&1 &
nohup polybar ${options} --config="$CONFIG_FILE" main_bottom >/dev/null 2>&1 &
if [ "$MONITOR2" != "" ] ; then
    polybar ${options} --config="$CONFIG_FILE" monitor2 &
fi

if [[ "$ENABLE_AUTOHIDE" == "true" ]] ; then
    # 为了视觉窗口悬浮效果 ， 修改 i3wm 配置上下边距
    sed -i "s/^gaps vertical .*/gaps vertical 4/g" ~/.config/i3/config
    sed -i "s/^gaps horizontal .*/gaps horizontal 4/g" ~/.config/i3/config

    # 等待 polybar 启动成功
    sleep 1

    nohup $POLYBAR_HOME/scripts/hideIt.sh --name '^polybar-main_top.*' --region 0x0+${SCREEN_WIDTH}+0 -i 1 -s 30 >/dev/null 2>&1 &
    nohup $POLYBAR_HOME/scripts/hideIt.sh --name '^polybar-main_bottom.*' --region 0x${SCREEN_HEIGHT}+${SCREEN_WIDTH}+-${POLYBAR_HEIGHT} -i 1 -s 30 >/dev/null 2>&1 &
else
    # 为了视觉窗口悬浮效果 ， 修改 i3wm 配置上下边距
    sed -i "s/^gaps vertical .*/gaps vertical ${POLYBAR_HEIGHT}/g" ~/.config/i3/config
    sed -i "s/^gaps horizontal .*/gaps horizontal 4/g" ~/.config/i3/config
fi

# 重新加载一下i3wm配置
i3-msg reload

#END