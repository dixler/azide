# Code

afu_zles=( \
  self-insert backward-delete-char backward-kill-word kill-line \
  kill-whole-line kill-word magic-space yank \
)

# Keybinds. may conflict with other behaviors
afu-install () {
   bindkey -N afu emacs
   bindkey -M afu "^I" afu+expand-or-complete
   bindkey -M afu "^M" afu+accept-line

   #fix delete
   bindkey -M afu "^[[3~" delete-char
   bindkey -M afu "^[3;5~" delete-char

   #fix better history autocompletion
   autoload -U up-line-or-beginning-search
   autoload -U down-line-or-beginning-search
   zle -N up-line-or-beginning-search
   zle -N down-line-or-beginning-search
   bindkey -M afu "^[[A" up-line-or-beginning-search # Up
   bindkey -M afu "^[[B" down-line-or-beginning-search # Down
}

afu-register-zle-accept-line () {
  local afufun="$1"
  local rawzle=".${afufun#*+}"
  local code=${"$(<=(cat <<"EOT"
  $afufun () {
    if (( isTyping == 1 )); then
        BUFFER="$buffer_cur"
    fi
    __accepted=($WIDGET ${=NUMERIC:+-n $NUMERIC} "$@")
    zle $rawzle && {
      local hi
    }
    zstyle -T ':auto-fu:var' postdisplay/clearp && POSTDISPLAY=''
    return 0
  }
  zle -N $afufun
EOT
  ))"}
  eval "${${code//\$afufun/$afufun}//\$rawzle/$rawzle}"
  afu_accept_lines+=$afufun
}

afu-register-zle-expand-or-complete () {
   local afufun="$1"
   local rawzle=".${afufun#*+}"
   local code=${"$(<=(cat <<"EOT"
      $afufun () {
         isTyping=0
         zle $rawzle
      return 0
      }
      zle -N $afufun
EOT
  ))"}
   eval "${${code//\$afufun/$afufun}//\$rawzle/$rawzle}"
}

# Entry point.
auto-fu-init () {
   local auto_fu_init_p=1
   local ps
   {
      local afu_in_p=0
      local afu_paused_p=0
      zstyle -s ':auto-fu:var' postdisplay ps
      [[ -z ${ps} ]] || POSTDISPLAY="$ps"
      afu-recursive-edit-and-accept
      zle -I
   } always {
      [[ -z ${ps} ]] || POSTDISPLAY=''
  }
}

afu-recursive-edit-and-accept () {
   local -a __accepted
   region_highlight=("${#buffer_cur} ${#buffer_new} fg=white")
   zle recursive-edit -K afu || { zle -R ''; zle send-break; return }
   [[ -n ${__accepted} ]] &&
      (( ${#${(M)afu_accept_lines:#${__accepted[1]}}} > 1 )) &&
         { zle "${__accepted[@]}"} || { zle accept-line }
}


#replaces character buffer to right with typing letter
afu-clearing-maybe () {
   if ((afu_in_p == 1)); then
      [[ "$BUFFER" != "$buffer_new" ]] || ((CURSOR != cursor_cur)) &&
      { afu_in_p=0 }
   fi
}

with-afu () {
   local zlefun="$1"; shift
   local -a zs
   : ${(A)zs::=$@}
   afu-clearing-maybe
   ((afu_in_p == 1)) && { afu_in_p=0; BUFFER="$buffer_cur" }
   zle $zlefun && {
      local es ds
      zstyle -a ':auto-fu:var' enable es; (( ${#es} == 0 )) && es=(all)
      if [[ -n ${(M)es:#(#i)all} ]]; then
         zstyle -a ':auto-fu:var' disable ds
         : ${(A)es::=${zs:#(${~${(j.|.)ds}})}}
      fi
   [[ -n ${(M)es:#${zlefun#.}} ]]
   } && {
      auto-fu-maybe
   }
}

afu-register-zle-afu () {
   local afufun="$1"
   local rawzle=".${afufun#*+}"
   eval "function $afufun () { with-afu $rawzle $afu_zles; }; zle -N $afufun"
}

afu-initialize-zle-afu () {
   local z
   for z in $afu_zles ;do
   afu-register-zle-afu $z
   done
}

auto-fu-maybe () {
   (($PENDING== 0)) && [[ $LBUFFER != *$'\012'*  ]] &&
   { auto-fu }
}

auto-fu () {
   cursor_cur="$CURSOR"
   buffer_cur="$BUFFER"
   with-afu-completer-vars zle complete-word
   cursor_new="$CURSOR"
   buffer_new="$BUFFER"
   region_highlight=("${#buffer_cur} ${#buffer_new} fg=240,underline")

   if [[ "$buffer_cur[1,cursor_cur]" == "$buffer_new[1,cursor_cur]" ]]; then
      CURSOR="$cursor_cur"
      isTyping=1

      if [[ "$buffer_cur" != "$buffer_new" ]] || ((cursor_cur != cursor_new))
      then afu_in_p=1; {
            local BUFFER="$buffer_cur"
            local CURSOR="$cursor_cur"
            with-afu-completer-vars zle list-choices
         }
      fi
      else
         BUFFER="$buffer_cur"
         CURSOR="$cursor_cur"
         zle list-choices
      fi
}

with-afu-completer-vars () {
   local LISTMAX=999999
   with-afu-compfuncs "$@"
}

with-afu-compfuncs () {
   comppostfuncs=(afu-comppost)
   "$@"
}

afu-comppost () {
   ((compstate[list_lines] + 2 > ( LINES ))) && {
      compstate[list]=''
      zle -M "$compstate[list_lines]($compstate[nmatches]) too many matches..."
   }
}

afu-install
afu-register-zle-accept-line afu+accept-line
afu-register-zle-expand-or-complete afu+expand-or-complete
zle -N auto-fu-init
afu-initialize-zle-afu
zle -N auto-fu

## END OF FILE #################################################################
# vim:filetype=zsh foldmethod=marker autoindent expandtab shiftwidth=3
# Local variables:
# mode: sh
# End:

