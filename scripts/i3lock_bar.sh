#!/usr/bin/env bash
# RGBA color
BLANK='#00000000'
CLEAR='#ffffff22'
DEFAULT='#FF5722FF'
TEXT='#FF6F00ee'
WRONG='#D50000FF'
VERIFYING='#4CAF50FF'
blur=6

i3lock                      \
--blur $blur                \
--bar-indicator             \
--bar-pos y+h               \
--bar-direction 1           \
--bar-max-height 50         \
--bar-base-width 50         \
--bar-color $BLANK          \
--keyhl-color $VERIFYING    \
--bar-periodic-step 50      \
--bar-step 50               \
--redraw-thread             \
\
--clock \
--force-clock \
--time-pos x+5:y+h-80       \
--time-color $TEXT          \
--date-pos tx:ty+15         \
--date-color $TEXT          \
--date-align 1              \
--time-align 1              \
--ringver-color $VERIFYING  \
--ringwrong-color $WRONG    \
--status-pos x+5:y+h-16     \
--verif-align 1             \
--wrong-align 1             \
--verif-color $VERIFYING    \
--wrong-color $WRONG        \
--modif-pos -50:-50