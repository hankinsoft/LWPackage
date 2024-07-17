local channel = string.title(matches.channel);
local talker = string.title(matches.talker);
local what = matches.what;

local source
if matches.emote == ":"
  then
    source = "<255,255,0>" .. "[" .. channel .. "]" .. " <11,233,2>" .. talker .. ": ";
  else
    source = "<255,255,0>" .. "[" .. channel .. "]: <11,233,2>" .. talker .. " ";
end

LW.begin_comm("Guild",
              source .. "<r>",
              matches.what:match("^%s*(.-)%s*$"));