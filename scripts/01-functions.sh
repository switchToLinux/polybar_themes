
# 创建软链接
function create_symlink() {
    source_file="$1"
    target_file="$2"

    if [ ! -f "$source_file" ]; then
        echo "找不到 $source_file 文件"
        return 1
    fi

    ln -sf "$source_file" "$target_file"
}

# 主题颜色方案设置
function change_color() {
    color_name="$1"
    color_dir="$POLYBAR_HOME/colors"
    [[ -f $color_dir/${color_name}.ini ]] || color_name="zioer"  # default color
    create_symlink "$color_dir/${color_name}.ini" "$color_dir/.current.ini"
}

# 控制 module 显示样式
function change_style() {
    choice="${1:-default}"
    font_file="$POLYBAR_HOME/.fonts.ini"
    all_style="`grep '^sep_.*_left = ' $font_file | awk -F_ '{ a[$2]++}END{for(i in a){ printf("%s ",i) }}'`"
    if [ "${choice}" == "" ]; then
        echo "Please enter a valid choice for the new style"
        echo "choice:"
        echo "    $all_style"
        echo
        return 1
    fi

    case "${choice}" in
        长方形|default|rectangle)   value="default"          ;;
        椭圆形|circle)              value="circle"           ;;
        三角形|triangle)            value="triangle"         ;;
        三角线|triangleline)        value="triangleline"     ;;
        直角形|rtriangle)           value="rtriangle"        ;;
        平行四边形|paral1)           value="paral1"           ;;
        平行四边形2|paral2)          value="paral2"           ;;
        随机|random)
            readarray -t -d' ' style_list <<< "$all_style"
            len=${#style_list[@]}
            idx=$(($RANDOM % ${len}))
            value=${style_list[$idx]}
        ;;
        *)
            for s in $all_style ; do
                if [[ "$s" == "$choice" ]] ; then
                    value=$s
                    break
                fi
            done
        ;; #默认选项
    esac
    if [[ "$value" == "" ]] ; then
        value="default"
    fi
    logit "当前 THEME_STYLE [$value]"
    sed -i "s#^sep_left =.*#sep_left = \${self.sep_${value}_left}#g"  $font_file
    sed -i "s#^sep_right =.*#sep_right = \${self.sep_${value}_right}#g"  $font_file
}

# 更改语言
function change_lang() {
    choice="${1:-zh_CN}"
    lang_dir="$POLYBAR_HOME/i18n"
    [[ -f $lang_dir/i18n_${choice}.ini ]] || choice="zh_CN"
    create_symlink "$lang_dir/i18n_${choice}.ini" "$lang_dir/.i18n.ini"
}
