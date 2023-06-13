
# 主题颜色方案设置
function change_color() {
    color_name="$1"
    color_dir=$POLYBAR_HOME/colors/
    [[ ! -f "$color_dir/${color_name}.ini" ]] && echo "找不到 $color_name 颜色配置文件" && return 1
    # 通过软链接控制启用颜色方案
    ln -sf ${color_dir}/${color_name}.ini ${color_dir}/.current.ini
}


# 控制 module 显示样式
function change_style() {
    choice="$1"
    if [ "${choice}" == "" ]; then
        echo "Please enter a valid choice for the new style"
        return 1
    fi
    font_file=$POLYBAR_HOME/.fonts.ini
    case "${choice}" in
    椭圆形|circle|c)
        sed -i "s/^sep_left =.*/sep_left = \${self.sep_halfcircle_left}/g"  $font_file
        sed -i "s/^sep_right =.*/sep_right = \${self.sep_halfcircle_right}/g"  $font_file
        ;;
    长方形|default|rectangle|r)
        sed -i "s/^sep_left =.*/sep_left = \${self.sep_default_left}/g"  $font_file
        sed -i "s/^sep_right =.*/sep_right = \${self.sep_default_right}/g"  $font_file
        ;;
    三角形|triangle|t)
        sed -i "s/^sep_left =.*/sep_left = \${self.sep_triangle_left}/g"  $font_file
        sed -i "s/^sep_right =.*/sep_right = \${self.sep_triangle_right}/g"  $font_file
        ;;
    esac
}

