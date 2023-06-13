#!/usr/bin/env bash
################################
# 功能: 自动根据 module 布局变更色彩
################################

# 读取 config.ini 文件
config_file="$POLYBAR_HOME/themes/$THEME_NAME/config.ini"
module_path="$POLYBAR_HOME/modules"

[[ ! -f "$config_file" ]] && echo "config.ini 配置文件不存在: path=${config_file}" && return 1


# 读取配置文件中的 modules-left/modules-center/modules-right 设置
modules_left=$(grep -oP "(?<=modules-left = ).*" $config_file)
modules_center=$(grep -oP "(?<=modules-center = ).*" $config_file)
modules_right=$(grep -oP "(?<=modules-right = ).*" $config_file)

# 定义颜色列表
colors=("bg_item1" "bg_item2" "bg_item3" "bg_item4" "bg_item5" "bg_item6")

##############################################################
# 处理modules-left中所有模块-背景色自动调整
# 格式:   module1 seplXY module2 seplXY ... moduleN seplX
##############################################################
process_module_left() {
    local module_list="$1"          # 模块列表
    local prev_module_name=""       # sep前一个 module
    local prev_separator_color=""   # 上一次分隔符设置的背景色

    logit "left_module_list: $module_list"
    readarray -t modules <<< "$module_list"
    for module in ${modules[@]} ; do
        logit "current module: $module"
        if [[ $module =~ ^(sepl)[0-9]{1,2}$ ]]; then   # 处理分隔符模块
            local separator_color=${module:4:1}    # 获取 seplXY 中的X
            if [[ $prev_module_name != "" ]]; then
                # 修改前一个模块的 format-foreground
                local prev_module_file="${module_path}/$prev_module_name.ini"
                [[ ! -f "$prev_module_file" ]] && logit "没找到 ${prev_module_name} 配置文件" && continue

                sed -i -E "s/(content-.*background =|tray-.*background =|format-.*background =).*/\1 \${colors.${colors[$(($separator_color - 1))]}}/g" $prev_module_file
                logit "模块 $prev_module_name 背景色设置为: ${colors[$separator_color - 1]}"
            fi
            prev_separator_color=$separator_color
        elif [[ $module =~ ^(sep|sepr[0-9]{1,2})$ ]] ; then  # 忽略分隔符
            # ignore
            ignore_module=$module
        else # 处理普通模块
            prev_module_name=${module}
        fi
    done

}
##############################################################
# 处理中间module列表
#   格式可能:
#       seplX module1 seplXY module2 seplXY ... moduleN seplX
# 规则
#   按照左侧配置规则处理，区别是开头可以是 seprX
##############################################################
process_module_center() {   # 处理中间module列表
    local module_list="$1"          # 模块列表
    local module_name=""            # sep后一个 module

    logit "center_module_list: $module_list"
    readarray -t modules <<< "$module_list"
    for module in ${modules[@]} ; do
        logit "current module: $module"
        if [[ $module =~ ^(sepl)[0-9]{1,2}$ ]]; then   # 处理分隔符模块
            local separator_color=${module:4:1}    # 获取 seplXY 中的X
        elif [[ $module =~ ^(sep|sepr[0-9]{1,2})$ ]] ; then  # 忽略分隔符
            # ignore
            ignore_module=$module
        else # 处理普通模块
            module_name=${module}
            if [[ $module_name != "" ]]; then
                # 修改前一个模块的 format-foreground
                local curr_module_file="${module_path}/$module_name.ini"
                [[ ! -f "$curr_module_file" ]] && logit "没找到 ${module_name} 配置文件" && continue

                sed -i -E "s/(content-.*background =|tray-.*background =|format-.*background =).*/\1 \${colors.${colors[$(($separator_color - 1))]}}/g" $curr_module_file
                logit "模块 $module_name 背景色设置为: ${colors[$separator_color - 1]}"
            fi
        fi
    done
}
##############################################################
# 处理右侧module列表
# 格式: seprX module1 seprXY module2 seprXY ... moduleN
##############################################################
process_module_right() {
    local module_list="$1"          # 模块列表
    local module_name=""            # sep后一个 module
    
    logit "right_module_list: $module_list"
    readarray -t modules <<< "$module_list"
    for module in ${modules[@]} ; do
        logit "current module: $module"
        if [[ $module =~ ^(sepr)[0-9]{1,2}$ ]]; then   # 处理分隔符模块
            local separator_color=${module:4:1}    # 获取 seplXY 中的X
        elif [[ $module =~ ^(sep|sepl[0-9]{1,2})$ ]] ; then  # 忽略分隔符
            # ignore
            ignore_module=$module
        else # 处理普通模块
            module_name=${module}
            if [[ $module_name != "" ]]; then
                # 修改前一个模块的 format-foreground
                local curr_module_file="${module_path}/$module_name.ini"
                [[ ! -f "$curr_module_file" ]] && logit "没找到 ${module_name} 配置文件" && continue

                sed -i -E "s/(content-.*background =|tray-.*background =|format-.*background =).*/\1 \${colors.${colors[$(($separator_color - 1))]}}/g" $curr_module_file
                logit "模块 $module_name 背景色设置为: ${colors[$separator_color - 1]}"
            fi
        fi
    done
}
# 处理左侧模块
process_module_left "$modules_left"

# # 处理中间模块
process_module_center "$modules_center"

# # 处理右侧模块
process_module_right "$modules_right"
