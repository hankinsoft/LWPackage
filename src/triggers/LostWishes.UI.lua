LW = LW or {}

function LW.createUI()

    if(LW.userWindow) then
        return
    end

    -- Create a user window
    LW.userWindow = Geyser.UserWindow:new({
        name = "userWindow",
        titleText = "User Window",
    })
    
    LW.userWindow:setDockPosition("right")

    -- Create a vertical box to hold the gauges and chat
    LW.vbox = Geyser.VBox:new({
        name = "vbox",
        x = "0%", y = "0%",
        width = "100%", height = "100%",
        color = "white",
    }, LW.userWindow)

    -- Add a text box to the chat container
    LW.chatBox = Geyser.MiniConsole:new({
        name = "chatBox",
        x = "0%", y = "0%",
        width = "100%",
        v_policy = Geyser.Dynamic,
        wrapAt = "auto",
        autoWrap = true,
    }, LW.vbox)
    
    -- Set font and background color for better visibility
    LW.chatBox:setFontSize(12)
    LW.chatBox:setColor(0, 0, 0) -- Black background

    -- Add the separator
    LW.separator = Geyser.Label:new({
        name = "separator",
        width = "100%", height = "5px",
        color = "gray",
        v_policy = Geyser.Fixed,
    }, LW.vbox)

    LW.mapper = Geyser.Mapper:new ({
        name = "mapper",
        x = "0%", y = "0%",
        width = "100%",
        v_policy = Geyser.Dynamic
    }, LW.vbox)

    -- Add the XP bar with appropriate dimensions and colors
    LW.xpBar = Geyser.Gauge:new({
        name = "xpBar",
        width = "100%", height = "30px",
        v_policy = Geyser.Fixed,
    }, LW.vbox)
    
    -- Add the HP bar with appropriate dimensions and colors
    LW.hpBar = Geyser.Gauge:new({
        name = "hpBar",
        width = "100%", height = "30px",
        v_policy = Geyser.Fixed,
    }, LW.vbox)
    
    -- Add the SP bar with appropriate dimensions and colors
    LW.spBar = Geyser.Gauge:new({
        name = "spBar",
        width = "100%", height = "30px",
        v_policy = Geyser.Fixed,
    }, LW.vbox)
    
    -- Add the GP bar with appropriate dimensions and colors
    LW.gpBar = Geyser.Gauge:new({
        name = "gpBar",
        width = "100%", height = "30px",
        v_policy = Geyser.Fixed,
    }, LW.vbox)
    
    -- Set styles for the bars
    LW.xpBar:setFontSize(16)
    LW.xpBar:setStyleSheet([[
        background-color: rgba(80,80,0,50%);
        border: 1px solid yellow;
        text-align: center;
    ]])
    
    LW.hpBar:setFontSize(16)
    LW.hpBar:setStyleSheet([[
        background-color: rgba(80,0,0,50%);
        border: 1px solid red;
        text-align: center;
    ]])
    
    LW.spBar:setFontSize(16)
    LW.spBar:setStyleSheet([[
        background-color: rgba(0,0,80,50%);
        border: 1px solid blue;
        text-align: center;
    ]])
    
    LW.gpBar:setFontSize(16)
    LW.gpBar:setStyleSheet([[
        background-color: rgba(0,80,0,50%);
        border: 1px solid green;
        text-align: center;
    ]])

    -- Set initial labels
    LW.xpBar:setValue(0, 1, "XP: 0.00%")
    LW.hpBar:setValue(0, 1, "HP: 0/0")
    LW.spBar:setValue(0, 1, "SP: 0/0")
    LW.gpBar:setValue(0, 1, "GP: 0/0")

end

-- Create the UI when Mudlet starts
LW.createUI()

-- GMCP handler function
function LW.handleGMCPMessage()
    local channel = gmcp.Comm.Channel.Text.channel
    local talker = gmcp.Comm.Channel.Text.talker
    local text = gmcp.Comm.Channel.Text.text

    if channel and talker and text and talker ~= "" then
        local message = string.format("[%s] %s: %s", channel, ansi2decho(talker), ansi2decho(text))
        LW.chatBox:decho(message .. "\n")
    elseif channel and text then
        local message = string.format("[%s] %s", channel, ansi2decho(text))
        LW.chatBox:decho(message .. "\n")
    end
end

-- Function to update the bars based on GMCP data
function LW.updateVitals()
    if gmcp.Char and gmcp.Char.Vitals then
        if gmcp.Char and gmcp.Char.Vitals and gmcp.Char.Info then
            local name = gmcp.Char.Info.name or "Unknown"
            local level = gmcp.Char.Vitals.level or "Unknown"
            local race = gmcp.Char.Info.race or ""
            local guild = gmcp.Char.Info.guild or ""
            --local title = string.format("%s the level %s %s %s", name, level, race, guild)
            local title = gmcp.Char.Info.title

            LW.userWindow:setTitle(title)
        end

        local xpPercent = gmcp.Char.Vitals.xpPercent or 0.00
        local hp = gmcp.Char.Vitals.hp or 0
        local maxHp = gmcp.Char.Vitals.maxHp or 0
        local sp = gmcp.Char.Vitals.sp or 0
        local maxSp = gmcp.Char.Vitals.maxSp or 0
        local gp = gmcp.Char.Vitals.gp or 0
        local maxGp = gmcp.Char.Vitals.maxGp or 0

        -- Update XP bar
        LW.xpBar:setValue(xpPercent, 100, string.format("XP: %.2f%%", xpPercent))
        LW.xpBar:show() -- Make the XP bar visible

        -- Update HP bar
        if maxHp ~= 0 then
            LW.hpBar:setValue(hp, math.min(hp, maxHp), string.format("HP: %d/%d", hp, maxHp))
            LW.hpBar:show()
        else
            LW.hpBar:setValue(0, 0, string.format("HP: %d/%d", 0, 0))
            LW.hpBar:show()
        end

        -- Update SP bar
        if maxSp ~= 0 then
            LW.spBar:setValue(sp, math.min(sp, maxSp), string.format("SP: %d/%d", sp, maxSp))
            LW.spBar:show()
        else
            LW.spBar:setValue(0, 0, string.format("SP: %d/%d", 0, 0))
            LW.spBar:show()
        end

        -- Update GP bar if maxGp is not zero
        if maxGp ~= 0 then
            LW.gpBar:setValue(gp, math.min(gp, maxGp), string.format("GP: %d/%d", gp, maxGp))
            LW.gpBar:show() -- Make the GP bar visible
        else
            LW.gpBar:hide() -- Hide the GP bar if maxGp is zero
        end
    else
        -- Make sure the bars are hidden
        LW.hpBar:hide()
        LW.spBar:hide()
        LW.gpBar:hide()
    end
end

-- Register the GMCP handler
registerAnonymousEventHandler("gmcp.Comm.Channel.Text", "LW.handleGMCPMessage")

-- Register GMCP handler
registerAnonymousEventHandler("gmcp.Char.Vitals", "LW.updateVitals")
