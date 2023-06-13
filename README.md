# 又一个polybar主题
> polybar主题网上很多，但都并不是快速可用，需要很多繁琐配置，或者一大堆的色彩定制。

这个项目就是为了让这些繁琐操作可以更简单化。

## 这个项目做了什么

解决问题
- [x] 色彩方案`快速自动配置`，这是本项目的设计初衷，告别了频繁给每个module调色痛苦。
- [x] 通过 launch.sh 启动脚本自动识别 分辨率(1080p/2K/4K)，简化分辨率带来的外观差异。
- [x] 双屏幕自动识别，并通过环境变量`MONITORX` 获取地`X`个屏幕名称，X开始于`1`。
- [x] 有趣的随机主题 random ，用过 ohmyzsh 的用户一定用过`random`每次都随机一个主题，换个样式，给单调乏味的生活添加一点惊喜。
- [x] dpi/font_size/height 三个参数设置不合理时可能显示内容上下间距不同，解决方法：通过 `vertical_offset`参数调整垂直对齐。

## 如何使用

- 00.polybar主题目录结构说明
- 01.如何编写自己的主题
- 02.关于字体安装说明
- 10.开发项目过程中遇到的问题总结


## 如何应用 polybar

```sh
git clone https://github.com/switchToLinux/polybar-themes.git ~/.config/polybar_themes

# 选择一个主题名 (例如 random 随机一个主题) ，然后将下面这行放入 wm 的启动配置文件中
~/.config/polybar_themes/launch.sh random

```

## 最后

linux 的开源个性化定制也存在局限，总有人走第一条没有人走过的路，为后来者奠基。

如果你希望这个项目可以越来越好，最好的支持方式是 使用然后优化这个项目，让繁琐的配置可以简单化，模块化。

~END~


