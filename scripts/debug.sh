
# 用于调试输出

function logit() {
    if [[ "$DEBUG" != "" ]] ; then
        echo "`date +"%Y%m%d%H%M%S"` $@"
    fi
}
