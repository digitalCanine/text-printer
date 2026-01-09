#!/bin/bash

RAW_TEXT="DC"
TOKEN=""
TOKEN_LEN=0

RAINBOW=false
LGBT_MODE=false
FLAG_COLORS=()
COLOR_COUNT=0

# Default sleep/delay
DELAY=0.013

# Arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  -r | --rainbow)
    RAINBOW=true
    shift
    ;;
  --lgbt)
    if [[ -z "$2" ]]; then
      echo "Usage: $0 --lgbt {flag} [text]"
      exit 1
    fi
    FLAG="$2"
    shift 2
    LGBT_MODE=true
    case "$FLAG" in
    gay) FLAG_COLORS=("228,3,3" "255,140,0" "255,237,0" "0,128,38" "36,64,142" "115,41,130") ;;
    trans) FLAG_COLORS=("91,206,250" "245,169,184" "255,255,255" "245,169,184" "91,206,250") ;;
    nonbinary) FLAG_COLORS=("255,244,48" "255,255,255" "156,89,209" "44,44,44") ;;
    poly) FLAG_COLORS=("246,28,174" "7,213,105" "28,146,246") ;;
    femboy) FLAG_COLORS=("215,121,189" "238,183,218" "255,255,255" "138,188,237") ;;
    lesbian) FLAG_COLORS=("213,45,0" "239,118,39" "255,154,86" "255,255,255" "209,98,164" "181,86,144" "163,2,98") ;;
    bi) FLAG_COLORS=("214,2,112" "214,2,112" "155,79,150" "0,56,168" "0,56,168") ;;
    pan) FLAG_COLORS=("255,33,140" "255,216,0" "33,177,255") ;;
    ace) FLAG_COLORS=("0,0,0" "163,163,163" "255,255,255" "128,0,128") ;;
    aro) FLAG_COLORS=("61,165,66" "169,222,151" "255,255,255" "169,169,169" "0,0,0") ;;
    agender) FLAG_COLORS=("0,0,0" "185,185,185" "255,255,255" "183,244,145" "255,255,255" "185,185,185" "0,0,0") ;;
    genderfluid) FLAG_COLORS=("255,117,162" "255,255,255" "190,24,214" "0,0,0" "51,62,189") ;;
    enby) FLAG_COLORS=("255,244,48" "255,255,255" "156,89,209" "44,44,44") ;;
    *)
      echo "Unknown flag '$FLAG'"
      echo "Available flags: gay, trans, nonbinary, poly, femboy, lesbian, bi, pan, ace, aro, agender, genderfluid, enby"
      exit 1
      ;;
    esac
    COLOR_COUNT=${#FLAG_COLORS[@]}
    ;;
  *)
    RAW_TEXT="$1"
    shift
    ;;
  esac
done

TOKEN="[ ${RAW_TEXT} ] "
TOKEN_LEN=${#TOKEN}

# Terminal setup
tput civis
cleanup() {
  tput cnorm
  clear
  printf "\n\e[2mThe system stands, quietly\e[0m\n"
  sleep 1
  clear
  exit 0
}
trap cleanup INT TERM

# Palette variables
PALETTE_START=16
PALETTE_END=231
color=$PALETTE_START
direction=1
STEP=2
i=0

# Function to interpolate between two RGB colors
interpolate_color() {
  local r1=$1 g1=$2 b1=$3
  local r2=$4 g2=$5 b2=$6
  local ratio=$7

  local r=$(awk -v r1="$r1" -v r2="$r2" -v t="$ratio" 'BEGIN { print int(r1 + (r2 - r1) * t) }')
  local g=$(awk -v g1="$g1" -v g2="$g2" -v t="$ratio" 'BEGIN { print int(g1 + (g2 - g1) * t) }')
  local b=$(awk -v b1="$b1" -v b2="$b2" -v t="$ratio" 'BEGIN { print int(b1 + (b2 - b1) * t) }')

  echo "$r $g $b"
}

# Main loop
while true; do
  cols=$(tput cols)

  if $LGBT_MODE; then
    # Calculate position in the gradient cycle
    cycle_length=300
    total_segments=$((COLOR_COUNT - 1))
    pos=$(awk -v i="$i" -v len="$cycle_length" -v segs="$total_segments" 'BEGIN { print ((i % len) / len) * segs }')

    # Find which color segment we're in
    segment=$(awk -v pos="$pos" 'BEGIN { print int(pos) }')

    # Ensure we don't go out of bounds
    if ((segment >= COLOR_COUNT - 1)); then
      segment=$((COLOR_COUNT - 2))
    fi

    # Calculate position within segment (0.0 to 1.0)
    local_pos=$(awk -v pos="$pos" -v seg="$segment" 'BEGIN { print pos - seg }')

    # Get RGB values for current and next color
    IFS=',' read -r r1 g1 b1 <<<"${FLAG_COLORS[segment]}"
    IFS=',' read -r r2 g2 b2 <<<"${FLAG_COLORS[segment + 1]}"

    # Interpolate
    read r g b <<<$(interpolate_color $r1 $g1 $b1 $r2 $g2 $b2 $local_pos)

    # Build a line without color codes first
    line=""
    while ((${#line} + TOKEN_LEN < cols)); do
      line+="$TOKEN"
    done

    # Print with color
    printf "\e[38;2;%d;%d;%dm%s\e[0m\n" "$r" "$g" "$b" "$line"
  elif $RAINBOW; then
    # Rainbow sine wave
    read r g b <<<$(awk -v i="$i" -v f="0.06" 'BEGIN {
      r = int(127 * (sin(f*i) + 1))
      g = int(127 * (sin(f*i + 2.094) + 1))
      b = int(127 * (sin(f*i + 4.188) + 1))
      print r, g, b
    }')

    # Build a line without color codes first
    line=""
    while ((${#line} + TOKEN_LEN < cols)); do
      line+="$TOKEN"
    done

    # Print with color
    printf "\e[38;2;%d;%d;%dm%s\e[0m\n" "$r" "$g" "$b" "$line"
  else
    # 256-color ping-pong
    # Build a line without color codes first
    line=""
    while ((${#line} + TOKEN_LEN < cols)); do
      line+="$TOKEN"
    done

    # Print with color
    printf "\e[38;5;%dm%s\e[0m\n" "$color" "$line"

    # Advance color for next line
    color=$((color + STEP * direction))
    if ((color >= PALETTE_END)); then
      color=$PALETTE_END
      direction=-1
    elif ((color <= PALETTE_START)); then
      color=$PALETTE_START
      direction=1
    fi
  fi

  ((i++))
  sleep $DELAY
done
