chat_color = "<orange>";
cecho(LW.chatBox.name, "\n" .. getTime(true, "h:mmAP ") .. chat_color .. matches[2]);
if matches[3]
  then
    chat_color = "<white>";
    cecho(LW.chatBox.name, chat_color .. matches[3]);
end