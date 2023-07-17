#!/usr/bin/env bash
################################
workdir=`dirname $0`   # 不是每个人都会安装到 ~/.config/polybar 目录的，因此需要动态设置这个目录
# 获取屏幕分辨率
screen_height=$(xrandr | grep ' connected primary' | awk '{print $4}' | awk -F'[x+]' '{ print $2 }')
screen_width=$(xrandr | grep ' connected primary' | awk '{print $4}' | awk -F'[x+]' '{ print $1 }')
monitor_list=$(xrandr --listmonitors | awk 'NR>2{printf(" ")}NR>1{printf("%s", $NF) }')

# 需要导出的环境变量信息
export_env_file="$workdir/.polybar_env"
font_file=$workdir/.fonts.ini

# 主题列表
themes="`ls $workdir/themes`"
style_list="`grep '^sep_.*_left = ' $workdir/template/icons.ini | awk -F_ '{ a[$2]++}END{for(i in a){ printf("%s ",i) }}'`"
colors="`ls --ignore="base*" $workdir/colors|sed 's/.ini//g'`"
lang_list="`ls --ignore=".i18n.ini" $workdir/i18n|sed 's/.ini//g;s/i18n_//g'`"
function usage() {
    echo "Usage:"
    echo
    echo "    `basename $0` <theme> [style] [color] [lang]"
    echo "    polybar 启动器, 可选择不同主题"
    echo
    echo "可选主题列表-theme:"
    for t in $themes; do
        echo "  $t"
    done
    echo
    echo "可选提示符样式-style:"
    echo "    $style_list"
    echo
    echo "可选颜色搭配方案-color:"
    echo "    $colors"
    echo
    echo "可选语言支持-lang:"
    echo "    $lang_list"
    echo
}

if [ "$1" = "" ] ; then
    usage
    exit 0
fi

export DEBUG="1"
source $workdir/scripts/debug.sh
export -f logit

echo > $export_env_file

# polybar高度
height=
#高分辨率调整此参数
dpi=
#圆角半径参数
radius=
#字体大小
font_size=
# 缩放icon大小(当发生图标过大时修改此参数),用于Font Awesome 等可缩放字体
scale_size=
#垂直偏移量(文本垂直方向不对齐时调整此参数)
vertical_offset=0


# 分辨率检测并设置polybar高度
function check_resolution() {
    if [[ $screen_height -le 1080 ]] ; then # 老旧非高分屏幕 11英寸-13英寸
        height=24
        dpi=96
        radius=12
        font_size=14
        scale_size=14
        vertical_offset=4
    elif [[ $screen_height -le 1440 ]]; then
        height=36
        dpi=140
        radius=18
        font_size=14
        scale_size=14
    else # elif [[ $screen_height -gt 1440 ]]; then
        height=50
        dpi=196
        radius=24
        font_size=14
        scale_size=13
        vertical_offset=7
    fi
    echo export POLYBAR_HEIGHT=$height      >> ${export_env_file}
    echo export POLYBAR_DPI=$dpi            >> ${export_env_file}
    echo export POLYBAR_HOME=$workdir       >> ${export_env_file}
    echo export RADIUS=$radius              >> ${export_env_file}
    echo export SCREEN_HEIGHT=$screen_height >> ${export_env_file}
    echo export SCREEN_WIDTH=$screen_width  >> ${export_env_file}
    logit "resolution: $screen_height , dpi: $dpi , font_size: $font_size , scale_size: $scale_size , vertical_offset: $vertical_offset"
}
# 检测屏幕数量(1-2)
function check_monitors() {
    logit "当前monitors : $monitor_list"
    [[ "$monitor_list" == "" ]] && echo "没有找到链接的显示器" && exit 0
    readarray -t mointors <<< "$monitor_list"
    idx=1
    for m in ${mointors[@]} ; do
        echo "export MONITOR${idx}=${m}" >> ${export_env_file}
        let idx=$idx+1
    done
}

function install_fontconfig() {
    command -v fc-match >/dev/null && return 0
    command -v apt >/dev/null && pac_cmd="apt install -y"
    command -v dnf >/dev/null && pac_cmd="dnf install -y"
    command -v zypper >/dev/null && pac_cmd="zypper install -y"
    command -v fc-match >/dev/null || $pac_cmd fontconfig
    ! command -v fc-match >/dev/null  && echo "Failed to install fontconfig" && exit 1
}

# 根据分辨率设置字体大小,同时增加字体缺失校验和补充安装
# 输出内容: $export_env_file 和 fonts/.fonts.ini 文件
function generate_font() {
    install_fontconfig  # 安装必要工具
    font_dir=$HOME/.local/share/fonts
    [[ -r $font_dir ]] || mkdir -p $font_dir

    cnt=1
    echo "# 自动生成 font 环境变量" >> $export_env_file
    cat $workdir/template/icons.ini > $font_file
    cat $workdir/template/fonts.list | while read font
    do
        font_prefix=`echo $font|awk -F"[: ]" '{print $1 }'`
        if fc-match "$font" | grep -i ${font_prefix} >/dev/null  ; then
            logit "字体 $font 已经安装"
        else
            cp -fp $workdir/fonts/${font_prefix}* $font_dir
            [[ "$?" == "0" ]] && logit "字体 $font 安装成功"
        fi
        name="FONT_${cnt}"
        if [[ "$font" == *"Awesome"* ]]; then
            echo "export $name=\"$font:size=${scale_size};${vertical_offset}\"" >> $export_env_file
        else
            echo "export $name=\"$font:size=${font_size};${vertical_offset}\"" >> $export_env_file
        fi
        echo "font-${cnt} = \${env:${name}}" >> $font_file
        let cnt=$cnt+1
    done
}

function launch_bar() {

    [[ "$THEME_NAME" == "" ]] && echo "请先设置主题!" && exit 1
    [[ ! -r "$workdir/themes/$THEME_NAME" ]] && echo "没找到 $workdir/themes/$THEME_NAME 目录" && exit 1
    [[ ! -r "$workdir/themes/$THEME_NAME/config.ini" ]] && echo "没找到 $workdir/themes/$THEME_NAME/config.ini 配置文件" && exit 1

	# 终止先前已启动的polybar进程
    killall -q polybar
	# Wait until the processes have been shut down
	while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

    logit "开始启动polybar, 当前主题: $THEME_NAME"

    check_resolution
    check_monitors
    generate_font

    # 加载自动生成的 env 信息
    source $export_env_file

    # 自动设置 module 色彩
    $workdir/scripts/00-autocolor.sh

    # 自动设置 var.ini 变量信息
    $workdir/scripts/00-autosetvar.sh

    # 无法预测 polybar主题是否使用了hideIt.sh ，因此在启动/重启等操作前统一的kill hideIt.sh 进程
    if ps -ef |grep $POLYBAR_HOME/scripts/hideIt.sh | grep -v grep >/dev/null 2>&1 ; then
        ps -ef |grep $POLYBAR_HOME/scripts/hideIt.sh | grep -v grep | awk '{ print $2 }' | xargs kill
    fi

    $workdir/themes/$THEME_NAME/start_bar.sh $@
    echo
}

function select_theme() {
    choice="$1"
    readarray -t theme_list <<< "$themes"
    [[ "$choice" == "" ]] && echo "Please select a theme from [$themes]"
    len=${#theme_list[@]}
    if [[ "$choice" == "random" ]] ; then
        idx=$(($RANDOM % ${len}))
        export THEME_NAME=${theme_list[$idx]}
        logit "当前主题 idx: $idx, theme name: $THEME_NAME"
        return 0
    fi
    for m in ${theme_list[@]} ; do
        if [[ "$m" == "$choice" ]] ; then
            export THEME_NAME=${m}
            logit "当前主题 theme name: $THEME_NAME"
            return 0
        fi
    done
    return 1
}
################################################################
#   主题配置信息
#
################################################################


# 主题名称: 对应 themes 目录下的目录名
select_theme "$1"

shift

launch_bar $@

# END
