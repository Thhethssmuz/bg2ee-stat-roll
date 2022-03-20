#!/bin/bash

CURRENT_MAX=0
CURRENT_ROLL=0
CURRENT_STR_MAX=0
CURRENT_STR_ROLL=0
declare -A STATS

init() {
  echo "Please select BG2 window"

  local info x y w h mx my
  info="$(xwininfo)"

  x="$(grep 'Absolute upper-left X' <<< "$info" | sed 's/.*://')"
  y="$(grep 'Absolute upper-left Y' <<< "$info" | sed 's/.*://')"
  w="$(grep -- '-geometry' <<< "$info" | sed 's/[x+-]/ /g' | awk '{print $2}')"
  h="$(grep -- '-geometry' <<< "$info" | sed 's/[x+-]/ /g' | awk '{print $3}')"

  # The main BG2EE menu is 1024x768, if it is any smaller than that then the
  # menu scales down to fit the window. And since I don't want to deal with
  # scaling the input then we require the window to be at least this size.

  if [ "$w" -lt "1024" ]; then
    echo "Please increase the width of your BG2 window"
    exit 1
  fi

  if [ "$h" -lt "768" ]; then
    echo "Please increase the height of your BG2 window"
    exit 1
  fi

  # Anything above 1024x768 becomes margin for the menu, however depending on
  # whether or not the window is an even or odd number of pixels then the menu
  # may move a pixel in either direction. Thus we screen-grab the upper left
  # corner in order to triangulate exactly which pixel the menu starts at.

  # Educated guess for the size of the margin
  mx="$(( (w - 1024) / 2))"
  my="$(( (h - 768) / 2))"

  local checksum
  checksum="$(scrot -a "$((x+mx+5)),$((y+my+5)),30,30" - | md5sum)"

  case "$checksum" in

    9118f3b9376d590940794203b5767e85*) mx="$((mx-2))"; my="$((my-2))" ;;
    3f248241f51677cebce957ad99a00fe6*) mx="$((mx-2))"; my="$((my-1))" ;;
    4d1476fbf960f28f2481f4848e9039f4*) mx="$((mx-2))"; my="$((my+0))" ;;
    a9908b5a2764cafd3fbccaf0ef1b23a7*) mx="$((mx-2))"; my="$((my+1))" ;;
    ebe0ac9859a9aa9d9e7baf9287ecf026*) mx="$((mx-2))"; my="$((my+2))" ;;

    6c24cc82b06c9581a18b420f44ba3bb1*) mx="$((mx-1))"; my="$((my-2))" ;;
    37085dca35fefda79fb55cb8bd9fed7a*) mx="$((mx-1))"; my="$((my-1))" ;;
    6e728e1f34798770a9cf74de80516e1d*) mx="$((mx-1))"; my="$((my+0))" ;;
    a0129d8a208db6b5d718b5c05e777667*) mx="$((mx-1))"; my="$((my+1))" ;;
    a0012844b29e72a3ce8e93919fc54929*) mx="$((mx-1))"; my="$((my+2))" ;;

    5f8effc923335d74144cb4d026053e50*) mx="$((mx+0))"; my="$((my-2))" ;;
    80b670d680fbf6c557e7f4caa28a40ea*) mx="$((mx+0))"; my="$((my-1))" ;;
    d9c54c6d14ea6f0217d7ee84d9b8cf6a*) mx="$((mx+0))"; my="$((my+0))" ;;
    c2abc63dc506cda2a9a0400d39f403b1*) mx="$((mx+0))"; my="$((my+1))" ;;
    464157fbb160b1315ed2e3df676a462c*) mx="$((mx+0))"; my="$((my+2))" ;;

    cfe8c511d7428d9b4f2897697df520b7*) mx="$((mx+1))"; my="$((my-2))" ;;
    ca11fce02e70432e25e7382bc6394521*) mx="$((mx+1))"; my="$((my-1))" ;;
    f478d3d1c347a0c664805bf52a948b17*) mx="$((mx+1))"; my="$((my+0))" ;;
    890b8ee22efe7e4ba290cfc0bc2980c8*) mx="$((mx+1))"; my="$((my+1))" ;;
    2be1e3bf5843be7206d357d505a179a2*) mx="$((mx+1))"; my="$((my+2))" ;;

    7571ea218bf643a28e8d6231855e9b6a*) mx="$((mx+2))"; my="$((my-2))" ;;
    08335affda68c8b7bed00b436ed290e8*) mx="$((mx+2))"; my="$((my-1))" ;;
    d2f36fb69f70612bdcbae5b2eb507c46*) mx="$((mx+2))"; my="$((my+0))" ;;
    878c9820e7bc47babeab504dc6157120*) mx="$((mx+2))"; my="$((my+1))" ;;
    91b840323fcf9ac24e740dd8ac1b2011*) mx="$((mx+2))"; my="$((my+2))" ;;

    *)
      echo "Unable to triangulate menu location :/"
      echo "$checksum"
      exit 1
      ;;

  esac

  echo "Triangulation $(( (w - 1024) / 2  - mx)) $(( (h - 768) / 2 - my ))"

  SAFE_FOCUS_X="$(( x + mx + 5 ))"
  SAFE_FOCUS_Y="$(( y + my + 5 ))"
  STORE_BTN_X="$(( x + mx + 130 ))"
  STORE_BTN_Y="$(( y + my + 665 ))"
  RECALL_BTN_X="$(( x + mx + 290 ))"
  RECALL_BTN_Y="$(( y + my + 665 ))"
  REROLL_BTN_X="$(( x + mx + 450 ))"
  REROLL_BTN_Y="$(( y + my + 665 ))"

  PLUSS_X="$(( x + mx + 465 ))"
  MINUS_X="$(( x + mx + 505 ))"
  STR_MINUS_Y="$(( y + my + 285 ))"
  DEX_MINUS_Y="$(( y + my + 337 ))"
  CON_MINUS_Y="$(( y + my + 389 ))"
  INT_MINUS_Y="$(( y + my + 441 ))"
  WIS_MINUS_Y="$(( y + my + 493 ))"
  CHA_MINUS_Y="$(( y + my + 545 ))"

  STR_TOP_LEFT_X="$(( x + mx + 370 ))"
  STR_TOP_LEFT_Y="$(( y + my + 272 ))"
  TOTAL_TOP_LEFT_X="$(( x + mx + 382 ))"
  TOTAL_TOP_LEFT_Y="$(( y + my + 586 ))"
}

stats() {
  STATS["$CURRENT_ROLL"]="$((STATS["$CURRENT_ROLL"]+1))"
}

match-total() {

  # We are now able to generate clicks much faster than BG2 can update, thus we
  # have to give BG2 some time to render the new number before we screen-grab
  # it.
  sleep 0.001

  local checksum prev count
  count="$1"
  count="$((count+0))"
  prev="$CURRENT_ROLL"

  checksum="$(scrot -a "${TOTAL_TOP_LEFT_X},${TOTAL_TOP_LEFT_Y},24,17" - | md5sum)"

  case "$checksum" in
    1b11a906a6054872a9e6a668678688af*) CURRENT_ROLL=75 ;;
    f5758a91ff5816749b865b149335fa5e*) CURRENT_ROLL=76 ;;
    569f0fe4438d49fcd379f1666af955c1*) CURRENT_ROLL=77 ;;
    dd2b21781ee965955400936b817cccff*) CURRENT_ROLL=78 ;;
    96b24011a38348b21ed44e0e8603d174*) CURRENT_ROLL=79 ;;
    daec6a75a604051e72031cd658f1b87c*) CURRENT_ROLL=80 ;;
    50454d252c0d73e8348345dad83e23bd*) CURRENT_ROLL=81 ;;
    6058c4d7b8da45778c0e17b251f8d340*) CURRENT_ROLL=82 ;;
    bf22aaf7e5c72eafee9633ae4d471871*) CURRENT_ROLL=83 ;;
    637ef7f6ec09270dc845dba274c753e3*) CURRENT_ROLL=84 ;;
    f3d587ab725b950a446aa2c1eb8d1da0*) CURRENT_ROLL=85 ;;
    4f169b8e73ba0f6e5a6f5d5e12149606*) CURRENT_ROLL=86 ;;
    70613319f2ad760da722b496e5201a4e*) CURRENT_ROLL=87 ;;
    00a1a845bdbbb7bc724467d9b70ea5f2*) CURRENT_ROLL=88 ;;
    10ad01a062799de30eebce264932b37e*) CURRENT_ROLL=89 ;;
    d74939b47327e4f2c1b781d64e2ab28d*) CURRENT_ROLL=90 ;;
    ca49ce8b4c9c0f814dab24668f7313fe*) CURRENT_ROLL=91 ;;
    3e6f8127ac0634bb1fc20acf40c95c48*) CURRENT_ROLL=92 ;;
    7f849edd84a4be895f5c58b4f5b20d4e*) CURRENT_ROLL=93 ;;
    b8f90179e2a0e975fc2647bc7439d9c6*) CURRENT_ROLL=94 ;;
    b1d3b73de16d750b265f5c63000ccd54*) CURRENT_ROLL=95 ;;
    87413f7310bd06b0b66fb4d2e61c5c7a*) CURRENT_ROLL=96 ;;
    b489ad2a17456f8eebe843e4b7e3e685*) CURRENT_ROLL=97 ;;
    25112e67464791f24f9e2e99d38ef9d7*) CURRENT_ROLL=98 ;;
    9c3720b9d3ab1d7f0d11dfb9771a1aef*) CURRENT_ROLL=99 ;;
    3ef9bf6cd4d9946d89765870e5b21566*) CURRENT_ROLL=100 ;;

    *)
      echo
      echo "No match for total found"
      echo "$checksum"
      scrot -a "${TOTAL_TOP_LEFT_X},${TOTAL_TOP_LEFT_Y},24,17" -oF /tmp/bg2ee-stat.png
      echo "I also saved it at /tmp/bg2ee-stat.png for you"
      exit 1
      ;;

  esac

  # echo "$count"

  if [ "$count" -gt "3" ]; then
    # If we get here then we assume that it is actually a duplicate roll, and
    # not just a case where we have screen-grabbed the number before BG2 have
    # been able to refresh
    return 0;
  fi

  if [ "$CURRENT_ROLL" -eq "$prev" ]; then
    # 0.001 is on the low end of what we have to wait for BG2 to refresh, so if
    # we get a duplicate roll try again a few times before we trust that the
    # roll is actually a duplicate roll
    match-total "$((count + 1))"
  fi
}

match-str() {
  for _ in {0..20}; do
    xdotool mousemove "$MINUS_X" "$DEX_MINUS_Y" click --delay=0 1
    xdotool mousemove "$MINUS_X" "$CON_MINUS_Y" click --delay=0 1
    xdotool mousemove "$MINUS_X" "$INT_MINUS_Y" click --delay=0 1
    xdotool mousemove "$MINUS_X" "$WIS_MINUS_Y" click --delay=0 1
    xdotool mousemove "$MINUS_X" "$CHA_MINUS_Y" click --delay=0 1

    xdotool mousemove "$PLUSS_X" "$STR_MINUS_Y" click --delay=0 1
  done

  # Here too we have to wait for BG2 to update the number, however tie breaks
  # are not so common, so we don't care about optimizing it as aggressively as
  # we do for the `match-total` function.
  sleep 0.2

  local checksum
  checksum="$(scrot -a "${STR_TOP_LEFT_X},${STR_TOP_LEFT_Y},49,17" - | md5sum)"

  if grep "776ff3ed0aff439ba36e6353e1764d7e" <<< "$checksum" > /dev/null; then
    # You are rolling a race with -1 str. In this case we cannot perform a
    # tie-break.
    CURRENT_STR_ROLL="0"
    return 0
  fi

  if grep "504c9686e7f4101d47aedb76de8ec0f8" <<< "$checksum" > /dev/null; then
    # You are rolling a race with +1 str. Not sure if the 18/x part matters in
    # this case... perhaps if you get a strength debuf then it might? Don't
    # really hurt to tie-break it either way...
    xdotool mousemove "$MINUS_X" "$STR_MINUS_Y" click --delay=0 1
    sleep 0.2
    checksum="$(scrot -a "${STR_TOP_LEFT_X},${STR_TOP_LEFT_Y},49,17" - | md5sum)"
  fi

  case "$checksum" in
    c82dcd5356f15388dd7738550477f307*) CURRENT_STR_ROLL=1 ;;
    d91da296efe4f632233caf229de919b1*) CURRENT_STR_ROLL=2 ;;
    3e073fe0d7bad4bccaed49a15489e92c*) CURRENT_STR_ROLL=3 ;;
    34647d35e1d3782acf8040e9dcb0fd1f*) CURRENT_STR_ROLL=4 ;;
    8461a9d95bf5210aa009f1c9bd4074eb*) CURRENT_STR_ROLL=5 ;;
    ecff5ca28bfc0c4904a6514c34a31958*) CURRENT_STR_ROLL=6 ;;
    5d067205d5c537d382ca29b101c64408*) CURRENT_STR_ROLL=7 ;;
    57f41f7bffa0115c9173b40c1edeca0b*) CURRENT_STR_ROLL=8 ;;
    419de67d0a09fe7a9f001d848a7102ab*) CURRENT_STR_ROLL=9 ;;
    fafd8738018374c3cad31a39d657c027*) CURRENT_STR_ROLL=10 ;;
    b0618cf13d7165c7eba32fa76dcbda88*) CURRENT_STR_ROLL=11 ;;
    c40d8bdf277da4d14c1ddebbb52614f2*) CURRENT_STR_ROLL=12 ;;
    3479c926fdf5d2f268e754b9765f109b*) CURRENT_STR_ROLL=13 ;;
    ea85bf132950ac69fd03dbc3dae2701e*) CURRENT_STR_ROLL=14 ;;
    ed49b48ba9fec6f40eebbc615284409a*) CURRENT_STR_ROLL=15 ;;
    85f48a3f438a17e27358a1bc94ff1256*) CURRENT_STR_ROLL=16 ;;
    c411f02d2eb15161b75a986baa1fb32a*) CURRENT_STR_ROLL=17 ;;
    6eacc8d96e8b9b01a04f1720d8a1ec50*) CURRENT_STR_ROLL=18 ;;
    8be67616b78812329a96fba4578c6ced*) CURRENT_STR_ROLL=19 ;;
    5e5b70c91076a891df124fd73f679103*) CURRENT_STR_ROLL=20 ;;
    4aeed15070a565490d47454afc0bd2c6*) CURRENT_STR_ROLL=21 ;;
    9e7a4efdee27156f6fd4dc170a183c2d*) CURRENT_STR_ROLL=22 ;;
    dbdcf9290ce6bd5b0db2eb92f070fc80*) CURRENT_STR_ROLL=23 ;;
    f5f48c7ef1faa7129b5678e807f8a581*) CURRENT_STR_ROLL=24 ;;
    83038e7aaf66c41656b6fde08693a3a6*) CURRENT_STR_ROLL=25 ;;
    d888a51c2bed943a0feccb2fb9beaba4*) CURRENT_STR_ROLL=26 ;;
    c8187dbcb063bb5b855f1e3161f791f7*) CURRENT_STR_ROLL=27 ;;
    58ef5cfa5295f04d7717b4b0ef626157*) CURRENT_STR_ROLL=28 ;;
    1a25f18fec6e3280399961afbb9396ec*) CURRENT_STR_ROLL=29 ;;
    915e18c12cd837874e5ed10d6a10f3d2*) CURRENT_STR_ROLL=30 ;;
    42536c964bef23d5653abd53022df1ff*) CURRENT_STR_ROLL=31 ;;
    97a3a8ac9da10bf5a6e6d61017a56920*) CURRENT_STR_ROLL=32 ;;
    c404132c75ecafab5ffcbfedc50eefd6*) CURRENT_STR_ROLL=33 ;;
    bf994b7df97c7c397f8c87b0b3b66c51*) CURRENT_STR_ROLL=34 ;;
    666fc8c1054c492512ed9afcf0380fb3*) CURRENT_STR_ROLL=35 ;;
    06a46be46cf5da327399547c6bb274b1*) CURRENT_STR_ROLL=36 ;;
    e7a89e7d3a9453a6883fcbb6b91b9135*) CURRENT_STR_ROLL=37 ;;
    825c6d55b253a3829ad75d68e5a3474a*) CURRENT_STR_ROLL=38 ;;
    3d58015ae33077aa4079530104f10e5f*) CURRENT_STR_ROLL=39 ;;
    5da09af8a7f3a142b831273cc8bf0a79*) CURRENT_STR_ROLL=40 ;;
    e041e10c9ae553f7ab57b2c2cf79f0b2*) CURRENT_STR_ROLL=41 ;;
    b9e11914e2b5f1e928e2dfdd5bd1b3b2*) CURRENT_STR_ROLL=42 ;;
    325b88e1ef07994108d9809d857253bc*) CURRENT_STR_ROLL=43 ;;
    68f219ab7cf504520559c21fdf5639bc*) CURRENT_STR_ROLL=44 ;;
    28513eb95e5a9b2c8011377e72c2b29c*) CURRENT_STR_ROLL=45 ;;
    8a3ef69ae41bd6fa0c7e2ad432b7f3ec*) CURRENT_STR_ROLL=46 ;;
    c3aff052bae994116ec0b7c5ae11ecab*) CURRENT_STR_ROLL=47 ;;
    ad5a02a658fe6c08b125d76b63af84d6*) CURRENT_STR_ROLL=48 ;;
    50ac2c5f320d2b09aad09b69aa6821b8*) CURRENT_STR_ROLL=49 ;;
    828c484f5ad3b39065eed84c102f08b3*) CURRENT_STR_ROLL=50 ;;
    9368ccf828cb8c8739a3b0285f5642e4*) CURRENT_STR_ROLL=51 ;;
    691926d89a8b2cb5756929b97c50d2ac*) CURRENT_STR_ROLL=52 ;;
    6ae516c31c2fe71eda89be9faae318fb*) CURRENT_STR_ROLL=53 ;;
    ede910ba918e511b5faabfdc65dee419*) CURRENT_STR_ROLL=54 ;;
    ae830524a9b034178dc527244a0c4ac7*) CURRENT_STR_ROLL=55 ;;
    ca8ed3761ed8b0c758c86fff71196dd9*) CURRENT_STR_ROLL=56 ;;
    15e2a3659d2a1f29128e183f80bc0506*) CURRENT_STR_ROLL=57 ;;
    089276311902c830dfb60bb7c644df50*) CURRENT_STR_ROLL=58 ;;
    01697036f5d32696ea3e1a4ce1f09ec8*) CURRENT_STR_ROLL=59 ;;
    3aed797cc142236574f41d08e34ffb7b*) CURRENT_STR_ROLL=60 ;;
    4e5f9f613d025652e9728e452235418f*) CURRENT_STR_ROLL=61 ;;
    31af1d9fc349580c17cce544d8bd9075*) CURRENT_STR_ROLL=62 ;;
    c22f96ff5d391af1545c0b0bccbb888a*) CURRENT_STR_ROLL=63 ;;
    68236d155e4a6acd6131f674a9340b6c*) CURRENT_STR_ROLL=64 ;;
    148d972ed5f7f7ddcfcc71f327bdf984*) CURRENT_STR_ROLL=65 ;;
    7ccd6ec4199f2d511abedb8646bac8ce*) CURRENT_STR_ROLL=66 ;;
    33ab6fd788a157ab93dc87e9dd6660f7*) CURRENT_STR_ROLL=67 ;;
    da69a848e43308be2b20d061040cd9bf*) CURRENT_STR_ROLL=68 ;;
    f367ab61a0e2c95254e725216a58c568*) CURRENT_STR_ROLL=69 ;;
    95548aac5056b9070243e27c12dde402*) CURRENT_STR_ROLL=70 ;;
    36642f6199ac5b01f75a30035f216d9d*) CURRENT_STR_ROLL=71 ;;
    ffdaf44949b70d374df135bdadb6cb38*) CURRENT_STR_ROLL=72 ;;
    7432143d0e2092d15007d26e2a0c38b0*) CURRENT_STR_ROLL=73 ;;
    9254511102213b53af55fc740d1d5ab4*) CURRENT_STR_ROLL=75 ;;
    40a14193572dd1c3fb3abbd6e1c95333*) CURRENT_STR_ROLL=74 ;;
    0595c78f5c6a33659a157156d80f3609*) CURRENT_STR_ROLL=76 ;;
    09c6c5e266b46c27debd5d44a284317e*) CURRENT_STR_ROLL=77 ;;
    a06bce1979988a6d51d68d4ef02f5caf*) CURRENT_STR_ROLL=78 ;;
    6ee7a520eb315dbd991c836b92382c88*) CURRENT_STR_ROLL=79 ;;
    cf48a1557942cd33f8dab5d21d18639e*) CURRENT_STR_ROLL=80 ;;
    69cb4b32c23d646c60064545a5b7500e*) CURRENT_STR_ROLL=81 ;;
    7f5c0181c6ef78294d1e1122525c4511*) CURRENT_STR_ROLL=82 ;;
    080db6d8b5f28c4fa755d701972d744a*) CURRENT_STR_ROLL=83 ;;
    d6abc55f948e65ad13f0f9d7ffb077e2*) CURRENT_STR_ROLL=84 ;;
    cc4a47b56f1dcc19fbd601acecc73956*) CURRENT_STR_ROLL=85 ;;
    8ab944f1a968dff42fb390683dbb6d5d*) CURRENT_STR_ROLL=86 ;;
    755f2864724dcb690cadf101e461a1cc*) CURRENT_STR_ROLL=87 ;;
    9b5c0d806cae3bcfdc1e5d52c321f18e*) CURRENT_STR_ROLL=88 ;;
    0cf8697f2748c591714b8f59b6ced492*) CURRENT_STR_ROLL=89 ;;
    a9ea74855eaa19bc6c0974b843227bfa*) CURRENT_STR_ROLL=90 ;;
    acb9a26916ef3c9102fd7944161aea3a*) CURRENT_STR_ROLL=91 ;;
    0110ec6598e8d2c9f72609c18f856b89*) CURRENT_STR_ROLL=92 ;;
    cae2d754e484c5f2295cfea9d9ccc564*) CURRENT_STR_ROLL=93 ;;
    89d07bef5a42a0247ec41a860d65f60d*) CURRENT_STR_ROLL=94 ;;
    3ca9fd882ac27f6dae41e924afa406c7*) CURRENT_STR_ROLL=95 ;;
    27f93d1d01781e21f311396c9772ad14*) CURRENT_STR_ROLL=96 ;;
    6b446437fbf7f042403e089b71929388*) CURRENT_STR_ROLL=97 ;;
    3c816805ab40254edd72fb89dfba7603*) CURRENT_STR_ROLL=98 ;;
    5f486d2cde1d9b5053688ecf6970fc73*) CURRENT_STR_ROLL=99 ;;
    a1f67fbfd6e43446098e9ee26659723e*) CURRENT_STR_ROLL=100 ;;

    *)
      echo "No match for tie breaker found"
      echo "$checksum"
      scrot -a "${STR_TOP_LEFT_X},${STR_TOP_LEFT_Y},49,17" -oF /tmp/bg2ee-stat.png
      echo "I also saved it at /tmp/bg2ee-stat.png for you"
      exit 1
      ;;

  esac
}

update() {
  match-total

  if [[ "$CURRENT_ROLL" -gt "$CURRENT_MAX" ]]; then

    xdotool mousemove "$STORE_BTN_X" "$STORE_BTN_Y" click 1
    sleep 0.25
    xdotool click 1
    CURRENT_MAX="$CURRENT_ROLL"

    match-str
    CURRENT_STR_MAX="$CURRENT_STR_ROLL"

  elif [[ "$CURRENT_ROLL" -eq "$CURRENT_MAX" ]]; then

    match-str
    if [[ "$CURRENT_STR_ROLL" -gt "$CURRENT_STR_MAX" ]]; then
      xdotool mousemove "$STORE_BTN_X" "$STORE_BTN_Y" click 1
      sleep 0.25
      xdotool click 1
      CURRENT_STR_MAX="$CURRENT_STR_ROLL"
    fi

  fi
}

recall() {
  xdotool mousemove "$RECALL_BTN_X" "$RECALL_BTN_Y" click 1
  update
}

roll() {
  xdotool mousemove "$REROLL_BTN_X" "$REROLL_BTN_Y" click --delay=0 1
  update
}

focus() {
  xdotool mousemove "$SAFE_FOCUS_X" "$SAFE_FOCUS_Y"
  sleep 1
  xdotool click 1
  sleep 1
}

loop() {
  local count mouseid
  count=0
  mouseid="$(xinput --list | grep -im 1 'mouse' | sed 's/.*id=\([0-9]\+\).*/\1/')"

  while true; do
    if xinput --query-state "$mouseid" | grep '=down$' >/dev/null; then
      echo 'Stopping'
      break
    fi
    count=$((count+1))
    roll
    stats
    echo "${count}: ${CURRENT_ROLL} - ${CURRENT_MAX} (18/${CURRENT_STR_MAX})"
  done
}

printStats() {
  echo
  echo "STATS"
  for key in "${!STATS[@]}"; do
    echo "  ${key}: ${STATS["$key"]}"
  done | sort
  echo
}

# Main

trap printStats EXIT

init
focus
recall
time loop
