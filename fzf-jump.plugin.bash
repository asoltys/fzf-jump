# Bookmarks

function jump() {

    #dedup directory stack
    declare -A seen
    i=0
    for d in $(dirs -p); do
        if test "${seen[$d]}"; then
            popd -n +$i >/dev/null ;
        else ((i++));
        fi
        seen[$d]=1
    done;

    FZF_ARGS='-e +x --print-query --expect=ctrl-x,ctrl-f,ctrl-c,ctrl-b,ctrl-h'

    F=$(
    { dirs -v; ls -d $1*/ ; } 2>/dev/null | fzf $FZF_ARGS | {
      read query;
      read expect;
      read n dir;

      case "$expect" in
          ctrl-b) jump "$1../";;
          ctrl-c) echo "exit";;
          ctrl-h) echo "$1./";;
          ctrl-x) echo "$query";;
          ctrl-f)
              if test "$dir"; then n="$dir"; fi
              jump "$n"
              ;;
          "")
              if test "$dir"; then echo +$n;
              elif test "$n"; then echo $n;
              elif test "$query"; then echo $query;
              else echo ""
              fi
              ;;
      esac
    }
    )

    if test "$1"; then
        echo $F
        return 0
    fi

    if test "$F" = "exit"; then
        return 0
    fi
    
    pushd $F >/dev/null

}

bind '"\C-g":" jump\n"'
