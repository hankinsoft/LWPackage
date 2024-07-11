--deleteLine();
chat_color = "<purple>";
cecho(LW.chatBox.name, "\n" .. getTime(true, "h:mmAP ") .. chat_color .. matches[2]);
chat_color = "<white>";
cecho(LW.chatBox.name, chat_color .. matches[3]);

--\ \<.*\>\