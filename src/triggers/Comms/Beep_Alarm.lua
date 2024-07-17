-- Get the Mudlet home directory
local mudletHomeDir = getMudletHomeDir()
local packageName = "LostWishes"
local resourcesFolder = mudletHomeDir .. "/packages/" .. packageName .. "/resources/"
local soundFilePath = resourcesFolder .. "ding.mp3"

-- Check if the file exists
local file = io.open(soundFilePath, "r")
if not file then
    soundFilePath = mudletHomeDir .. "/" .. packageName .. "/ding.mp3"
    file = io.open(soundFilePath, "r")
end

if file then
    file:close()
    -- Play the sound file
    playSoundFile(soundFilePath)
else
    print("Could not find the sound file: " .. soundFilePath)
end