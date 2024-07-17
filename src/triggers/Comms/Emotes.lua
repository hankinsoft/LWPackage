message = matches[3]:match("^%s*(.-)%s*$")
LW.appendChat("Tell", "<11,233,2>From afar, <255,255,0>" .. matches[2] .. " <r>" .. ansi2decho(message));