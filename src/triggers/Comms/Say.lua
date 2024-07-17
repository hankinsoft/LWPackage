LW.begin_comm("All",
             "<255,255,0>" .. matches.talker:match("^%s*(.-)%s*$") .. "<11,233,2> " .. matches.verb:match("^%s*(.-)%s*$") ..":<r>",
             matches.what:match("^%s*(.-)%s*$"));