--deleteLine();
if matches[2] == "chat" then
    chat_color = "<cyan>"
    cecho(LW.chatBox.name, "\n" .. getTime(true, "h:mmAP ") .. chat_color .. matches[3])
    chat_color = "<white>"
    cecho(LW.chatBox.name, chat_color .. matches[4])
end
if matches[2] == "auction" then
    chat_color = "<green>"
    cecho(LW.chatBox.name, "\n" .. getTime(true, "h:mmAP ") .. chat_color .. matches[3])
    chat_color = "<white>"
    cecho(LW.chatBox.name, chat_color .. matches[4])
end
if matches[2] == "game" then
    chat_color = "<yellow>"
    cecho(LW.chatBox.name, "\n" .. getTime(true, "h:mmAP ") .. chat_color .. matches[3])
    chat_color = "<white>"
    cecho(LW.chatBox.name, chat_color .. matches[4])
end
if matches[2] == "high" then
    chat_color = "<blue>"
    cecho(LW.chatBox.name, "\n" .. getTime(true, "h:mmAP ") .. chat_color .. matches[3])
    chat_color = "<white>"
    cecho(LW.chatBox.name, chat_color .. matches[4])
end
if matches[2] == "newbie" then
    chat_color = "<magenta>"
    cecho(LW.chatBox.name, "\n" .. getTime(true, "h:mmAP ") .. chat_color .. matches[3])
    chat_color = "<white>"
    cecho(LW.chatBox.name, chat_color .. matches[4])
end
if matches[2] == "BS" then
    chat_color = "<grey>"
    cecho(LW.chatBox.name, "\n" .. getTime(true, "h:mmAP ") .. chat_color .. matches[3])
    chat_color = "<white>"
    cecho(LW.chatBox.name, chat_color .. matches[4])
end