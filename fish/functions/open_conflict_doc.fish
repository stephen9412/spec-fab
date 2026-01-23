function open_conflict_doc --description "Open a document with conflict markers highlighted"
    set file_path $argv[1]
    set line_num (math $argv[2] + 4)

    command vim -c 'syntax match ConfStart "^<<<<<<<.*$"' \
         -c 'syntax match ConfMid "^=======$"' \
         -c 'syntax match ConfEnd "^>>>>>>>.*$"' \
         -c 'highlight link ConfStart DiffAdd' \
         -c 'highlight link ConfMid Search' \
         -c 'highlight link ConfEnd DiffDelete' \
         +$line_num $file_path
end
