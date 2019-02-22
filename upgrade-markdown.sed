s#zsh -c 'for f in *#loadchapters.zsh "#
s#; do cat \$f; echo; done'#"#
s#\\lang\([a-z]\+\){\([^}]\+\)}#[\2]{lang="\1"}#g
