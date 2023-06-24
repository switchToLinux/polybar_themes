#!/usr/bin/env bash
# RGBA color
BLANK='#00000000'
CLEAR='#ffffff22'
DEFAULT='#FF5722FF'
TEXT='#FF6F00ee'
WRONG='#D50000FF'
VERIFYING='#4CAF50FF'
width=12
radius=120
blur=6

i3lock \
--insidever-color=$CLEAR     \
--ringver-color=$VERIFYING   \
\
--insidewrong-color=$CLEAR   \
--ringwrong-color=$WRONG     \
\
--inside-color=$BLANK        \
--radius=$radius             \
--ring-color=$DEFAULT        \
--ring-width=${width}        \
--line-color=$BLANK          \
--separator-color=$DEFAULT   \
\
--verif-color=$TEXT          \
--wrong-color=$TEXT          \
--time-color=$TEXT           \
--date-color=$TEXT           \
--layout-color=$TEXT         \
--keyhl-color=$VERIFYING     \
--bshl-color=$WRONG          \
\
--screen 1                   \
--blur ${blur}               \
--clock                      \
--indicator                  \
--time-str="%H:%M:%S"        \
--date-str="%A, %Y-%m-%d"    \
--keylayout 1                \