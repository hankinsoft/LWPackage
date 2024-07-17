-- Old trigger
-- ^\[(chat|game|newbie|high|auction)\]\s+(.*)

local channel = string.title(matches.channel);
local talker = string.title(matches.talker);
local what = matches.what:match("^%s*(.-)%s*$");



local color = "<255,255,0>"
local channel_for_emco = "All"

if string.lower(channel) == "chat" then
    -- Color cyan
    color = "<0,255,255>"
    channel_for_emco = "Chat"
elseif string.lower(channel) == "game" then
    -- Color green
    color = "<0,255,0>"
elseif string.lower(channel) == "newbie" then
    -- Color red
    color = "<255,0,0>"
elseif string.lower(channel) == "high" then
    -- Color blue
    color = "<0,0,255>"
elseif string.lower(channel) == "auction" then
    -- Color red
    color = "<255,0,0>"
elseif LW.partyInfo and string.lower(channel) == string.lower(LW.partyInfo.name) then
    color = "<150,150,200>"
    channel_for_emco = "Party"
else
    -- Default color if none of the channels match
    color = "<255,255,0>"
end

LW.begin_comm(channel_for_emco,
             color .. "[" .. channel .. "]<11,233,2> " .. talker .. matches.separator .. "<r>",
             what);