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

# Function to get RGB values from terminal color
get_terminal_color() {
  local color_num=$1
  # Query the terminal for the color using OSC 4
  printf "\033]4;%d;?\033\\" "$color_num"

  # Read response with timeout
  local response=""
  IFS= read -t 0.1 -d '\' response 2>/dev/null || true

  # Parse the response (format: rgb:RRRR/GGGG/BBBB)
  if [[ $response =~ rgb:([0-9a-fA-F]+)/([0-9a-fA-F]+)/([0-9a-fA-F]+) ]]; then
    # Convert from 16-bit hex to 8-bit decimal
    local r=$((16#${BASH_REMATCH[1]:0:2}))
    local g=$((16#${BASH_REMATCH[2]:0:2}))
    local b=$((16#${BASH_REMATCH[3]:0:2}))
    echo "$r $g $b"
    return 0
  fi

  # Fallback colors if query fails
  case $color_num in
  0) echo "26 46 40" ;;     # color0 approximation
  1) echo "200 52 30" ;;    # color1 approximation
  2) echo "90 124 110" ;;   # color2 approximation
  3) echo "212 165 116" ;;  # color3 approximation
  4) echo "61 82 72" ;;     # color4 approximation
  5) echo "184 127 79" ;;   # color5 approximation
  6) echo "79 120 102" ;;   # color6 approximation
  7) echo "245 230 211" ;;  # color7 approximation
  8) echo "45 66 56" ;;     # color8 approximation
  9) echo "233 79 55" ;;    # color9 approximation
  10) echo "109 149 132" ;; # color10 approximation
  11) echo "232 199 153" ;; # color11 approximation
  12) echo "74 104 88" ;;   # color12 approximation
  13) echo "212 165 116" ;; # color13 approximation
  14) echo "104 152 129" ;; # color14 approximation
  15) echo "253 248 240" ;; # color15 approximation
  *) echo "128 128 128" ;;
  esac
}

# Build gradient palette from terminal colors
build_terminal_gradient() {
  local -a colors
  # Sample interesting colors from the terminal palette
  # Use colors that typically have good variation: reds, greens, yellows, blues, magentas, cyans
  local color_indices=(1 2 3 4 5 6 9 10 11 12 13 14)

  for idx in "${color_indices[@]}"; do
    read r g b <<<$(get_terminal_color $idx)
    colors+=("$r,$g,$b")
  done

  # Return the color array
  for color in "${colors[@]}"; do
    echo "$color"
  done
}

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

# Build terminal color gradient if not using LGBT or rainbow mode
if ! $LGBT_MODE && ! $RAINBOW; then
  echo "Reading terminal colors..." >&2
  mapfile -t TERMINAL_COLORS < <(build_terminal_gradient)
  COLOR_COUNT=${#TERMINAL_COLORS[@]}
  if ((COLOR_COUNT > 0)); then
    FLAG_COLORS=("${TERMINAL_COLORS[@]}")
    LGBT_MODE=true # Reuse LGBT gradient logic for terminal colors
  fi
fi

i=0

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

    # Build line with proper color
    line=""
    while ((${#line} < cols)); do
      remaining=$((cols - ${#line}))
      if ((remaining >= TOKEN_LEN)); then
        line+="$TOKEN"
      else
        line+=$(printf "%${remaining}s" "")
      fi
    done

    # Print with RGB color
    printf "\e[38;2;%d;%d;%dm%s\e[0m\n" "$r" "$g" "$b" "$line"
  elif $RAINBOW; then
    # Rainbow sine wave
    read r g b <<<$(awk -v i="$i" -v f="0.06" 'BEGIN {
      r = int(127 * (sin(f*i) + 1))
      g = int(127 * (sin(f*i + 2.094) + 1))
      b = int(127 * (sin(f*i + 4.188) + 1))
      print r, g, b
    }')

    # Build line with proper color
    line=""
    while ((${#line} < cols)); do
      remaining=$((cols - ${#line}))
      if ((remaining >= TOKEN_LEN)); then
        line+="$TOKEN"
      else
        line+=$(printf "%${remaining}s" "")
      fi
    done

    # Print with RGB color
    printf "\e[38;2;%d;%d;%dm%s\e[0m\n" "$r" "$g" "$b" "$line"
  fi

  ((i++))
  sleep $DELAY
done
