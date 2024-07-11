-- generic GMCP mapping script for Mudlet
-- by Blizzard. https://worldofpa.in
-- based upon an MSDP script from the Mudlet forums in the generic mapper thread
-- with pieces from the generic mapper script and the mmpkg mapper by breakone9r
-- Modified for LostWishes.

map = map or {}
map.room_info = map.room_info or {}
map.prev_info = map.prev_info or {}
map.aliases = map.aliases or {}
map.configs = map.configs or {}
map.configs.speedwalk_delay = 1
local defaults = {
    -- using Geyser to handle the mapper in this, since this is a totally new script
    mapper = {x = 0, y = 0, width = "100%", height = "100%"}
}

local terrain_types = {
    -- used to make rooms of different terrain types have different colors
    -- add a new entry for each terrain type, and set the color with RGB values
    -- each id value must be unique, terrain types not listed here will use mapper default color
    -- not used if you define these in a map XML file
    ["Inside"] = {id = 1, r = 255, g = 0, b = 0},
}

-- list of possible movement directions and appropriate coordinate changes
local move_vectors = {
    north = {0,1,0}, south = {0,-1,0}, east = {1,0,0}, west = {-1,0,0},
    northwest = {-1,1,0}, northeast = {1,1,0}, southwest = {-1,-1,0}, southeast = {1,-1,0},
    up = {0,0,1}, down = {0,0,-1}
}

local exitmap = {
    n = 'north',    ne = 'northeast',   nw = 'northwest',   e = 'east',
    w = 'west',     s = 'south',        se = 'southeast',   sw = 'southwest',
    u = 'up',       d = 'down',         ["in"] = 'in',      out = 'out',
    l = 'look'
}

local stubmap = {
  north = 1,      northeast = 2,      northwest = 3,      east = 4,
  west = 5,       south = 6,          southeast = 7,      southwest = 8,
  up = 9,         down = 10,          ["in"] = 11,        out = 12,
  northup = 13,   southdown = 14,     southup = 15,       northdown = 16,
  eastup = 17,    westdown = 18,      westup = 19,        eastdown = 20,
  [1] = "north",  [2] = "northeast",  [3] = "northwest",  [4] = "east",
  [5] = "west",   [6] = "south",      [7] = "southeast",  [8] = "southwest",
  [9] = "up",     [10] = "down",      [11] = "in",        [12] = "out",
  [13] = "northup", [14] = "southdown", [15] = "southup", [16] = "northdown",
  [17] = "eastup", [18] = "westdown", [19] = "westup",    [20] = "eastdown",
}

-- Define opposite directions
local opposite_dir = {
    north = "south",    northeast = "southwest",  northwest = "southeast",
    east = "west",      south = "north",          southeast = "northwest",
    southwest = "northeast",   west = "east",     up = "down", 
    down = "up",        ["in"] = "out",           out = "in",
    northup = "southdown", southup = "northdown", northdown = "southup",
    southdown = "northup", eastup = "westdown", westup = "eastdown",
    eastdown = "westup", westdown = "eastup"
}

local short = {}
for k,v in pairs(exitmap) do
    short[v] = k
end

local function debug_print(to_print)
      -- print(to_print)
end

local function reverse_link(source_id, target_id, dir)
  -- Check if the source room exists
  debug_print("Checking if source room exists: " .. tostring(source_id))
  if not getRoomName(source_id) then
    debug_print("Source room does not exist: " .. tostring(source_id))
    return
  end
  
  -- If we have the target, we can directly link
  debug_print("Checking if target room exists: " .. tostring(target_id))
  if getRoomName(target_id) then
    debug_print("Target room exists: " .. tostring(target_id))
    setExit(source_id, target_id, dir)
    debug_print("Set exit from " .. tostring(source_id) .. " to " .. tostring(target_id) .. " in direction " .. dir)
    
    -- Also, check to see if there are any stubs we need to fix.
    local target_stubs = getExitStubs1(target_id)
    local opp_dir = opposite_dir[dir]
    if target_stubs and opp_dir then
      debug_print("Checking target room stubs for opposite direction: " .. opp_dir)
      for _, stub in ipairs(target_stubs) do
        debug_print("Checking stub: " .. tostring(stub))
        if stubmap[opp_dir] == stub then
          setExit(target_id, source_id, opp_dir)
          debug_print("Linked back: " .. tostring(target_id) .. " -> " .. tostring(source_id) .. " (" .. opp_dir .. ")")
          break
        end
      end
    end
  else
    if stubmap[dir] then
      setExitStub(source_id, dir, true)
      debug_print("Set exit stub from " .. tostring(source_id) .. " in direction " .. dir)
    else
      debug_print("Direction " .. dir .. " does not exist in stubmap. Did not set exit stub.")
    end
  end
end


local function make_room()
    local info = map.room_info
    local coords = {0,0,0}
    addRoom(info.vnum)
	  setRoomName(info.vnum, info.name)
    local areas = getAreaTable()
    local areaID = areas[info.area]
    if not areaID then
        areaID = addAreaName(info.area)
    else
        coords = {getRoomCoordinates(map.prev_info.vnum)}
        local shift = {0,0,0}
        for k,v in pairs(info.exits) do
            if v == map.prev_info.vnum and move_vectors[k] then
                shift = move_vectors[k]
                break
            end
        end
        for n = 1,3 do
            coords[n] = coords[n] - shift[n]
        end
        -- map stretching
        local overlap = getRoomsByPosition(areaID,coords[1],coords[2],coords[3])
        if not table.is_empty(overlap) then
            local rooms = getAreaRooms(areaID)
            local rcoords
            for _,id in ipairs(rooms) do
                rcoords = {getRoomCoordinates(id)}
                for n = 1,3 do
                    if shift[n] ~= 0 and (rcoords[n] - coords[n]) * shift[n] <= 0 then
                        rcoords[n] = rcoords[n] - shift[n]
                    end
                end
                setRoomCoordinates(id,rcoords[1],rcoords[2],rcoords[3])
            end
        end
    end
    setRoomArea(info.vnum, areaID)
    setRoomCoordinates(info.vnum, coords[1], coords[2], coords[3])
    if terrain_types[info.terrain] then
        setRoomEnv(info.vnum, terrain_types[info.terrain].id)
    end
    for dir, id in pairs(info.exits) do
        -- Reverse link
        reverse_link(info.vnum, id, dir)
    end
end

local function shift_room(dir)
    local ID = map.room_info.vnum
    local x,y,z = getRoomCoordinates(ID)
    local x1,y1,z1 = table.unpack(move_vectors[dir])
    x = x + x1
    y = y + y1
    z = z + z1
    setRoomCoordinates(ID,x,y,z)
    updateMap()
end

local function handle_move()
    local info = map.room_info
    if not getRoomName(info.vnum) then
        make_room()
    else
        local stubs = getExitStubs1(info.vnum)
       		if stubs then
          for _, n in ipairs(stubs) do
              local dir = stubmap[n]
              if dir then
                local id = info.exits[dir]
  
                debug_print("TYPE: " .. type(n) .. "\n");
                -- debug_print _, n, dir, and id
                debug_print("_: " .. tostring(_) .. ", n: " .. tostring(n) .. ", dir: " .. tostring(dir) .. ", id: " .. tostring(id))
                
  
                -- need to see how special exits are represented to handle those properly here
                if id and getRoomName(id) then
                    -- Reverse link
                    reverse_link(info.vnum, id, dir)
                end
            end
          end
		end
    end
    centerview(map.room_info.vnum)
end

local function config()
		
    -- setting terrain colors
    --for k,v in pairs(terrain_types) do
    --    setCustomEnvColor(v.id, v.r, v.g, v.b, 255)
    --end
    -- making mapper window
    --local info = defaults.mapper
    --Geyser.Mapper:new({name = "myMap", x = info.x, y = info.y, width = info.width, height = info.height})
    -- clearing existing aliases if they exist
    for k,v in pairs(map.aliases) do
        killAlias(v)
    end
    map.aliases = {}
    -- making an alias to let the user shift a room around via command line
    table.insert(map.aliases,tempAlias([[^shift (\w+)$]],[[raiseEvent("shiftRoom",matches[2])]]))
	table.insert(map.aliases,tempAlias([[^make_room$]],[[make_room()]]))
end

local function check_doors(roomID,exits)
    -- looks to see if there are doors in designated directions
    -- used for room comparison, can also be used for pathing purposes
    if type(exits) == "string" then exits = {exits} end
    local statuses = {}
    local doors = getDoors(roomID)
    local dir
    for k,v in pairs(exits) do
        dir = short[k] or short[v]
        if table.contains({'u','d'},dir) then
            dir = exitmap[dir]
        end
        if not doors[dir] or doors[dir] == 0 then
            return false
        else
            statuses[dir] = doors[dir]
        end
    end
    return statuses
end


local continue_walk, timerID
continue_walk = function(new_room)
    if not walking then return end
    -- calculate wait time until next command, with randomness
    local wait = map.configs.speedwalk_delay or 0
    if wait > 0 and map.configs.speedwalk_random then
        wait = wait * (1 + math.random(0,100)/100)
    end
    -- if no wait after new room, move immediately
    if new_room and map.configs.speedwalk_wait and wait == 0 then
        new_room = false
    end
    -- send command if we don't need to wait
    if not new_room then
        send(table.remove(map.walkDirs,1))
        -- check to see if we are done
        if #map.walkDirs == 0 then
            walking = false
        end
    end
    -- make tempTimer to send next command if necessary
    if walking and (not map.configs.speedwalk_wait or (map.configs.speedwalk_wait and wait > 0)) then
        if timerID then killTimer(timerID) end
        timerID = tempTimer(wait, function() continue_walk() end)
    end
end

function compressWalkDirs(dirs)
    local compressed = {}
    local count = 1

    for i = 2, #dirs + 1 do
        if dirs[i] == dirs[i - 1] then
            count = count + 1
        else
            while count > 10 do
                table.insert(compressed, "10 " .. dirs[i - 1])
                count = count - 10
            end
            if count > 1 then
                table.insert(compressed, count .. " " .. dirs[i - 1])
            else
                table.insert(compressed, dirs[i - 1])
            end
            count = 1
        end
    end

    return compressed
end

function map.speedwalk(roomID, walkPath, walkDirs)
    roomID = roomID or speedWalkPath[#speedWalkPath]
    
    getPath(map.room_info.vnum, roomID)
    walkPath = speedWalkPath
    walkDirs = speedWalkDir
  
    -- Walkdirs is an array of commands. I want you to loop through the commands and create a new command.
    -- If walkdirs is   sss, then the new command should be 3 s.
    -- If walkdirs is   snss, then the new command should be s, n, 2 s.
    
    if #speedWalkPath == 0 then
        map.echo("No path to chosen room found.", false, true)
        return
    end
    
    table.insert(walkPath, 1, map.room_info.vnum)

    -- Go through dirs to find doors that need to be opened, etc
    -- Add in necessary extra commands to walkDirs table
    local k = 1
    repeat
        local id, dir = walkPath[k], walkDirs[k]

        if exitmap[dir] or short[dir] then
            local door = check_doors(id, exitmap[dir] or dir)
            local status = door and door[dir]
            if status and status > 1 then
                -- If locked, unlock door
                if status == 3 then
                    table.insert(walkPath, k, id)
                    table.insert(walkDirs, k, "unlock " .. (exitmap[dir] or dir))
                    k = k + 1
                end
                -- If closed, open door
                table.insert(walkPath, k, id)
                table.insert(walkDirs, k, "open " .. (exitmap[dir] or dir))
                k = k + 1
            end
        end
        k = k + 1
    until k > #walkDirs
    
    if map.configs.use_translation then
        for k, v in ipairs(walkDirs) do
            local translated_dir = map.configs.lang_dirs[v] or v
            walkDirs[k] = translated_dir
        end
    end
    
    walkDirs = compressWalkDirs(walkDirs)

    send("do " .. table.concat(walkDirs, ", "))
end



function doSpeedWalk()
    if #speedWalkPath ~= 0 then
        map.speedwalk(nil, speedWalkPath, speedWalkDir)
    else
        map.echo("No path to chosen room found.",false,true)
    end
end


function map.eventHandler(event,...)
    if event == "gmcp.Room.Info" then
        map.prev_info = map.room_info
        map.room_info = {
          vnum = tonumber(gmcp.Room.Info.num),
          area = gmcp.Room.Info.area,
          name = gmcp.Room.Info.name,
          terrain = gmcp.Room.Info.environment,
          exits = gmcp.Room.Info.exits
        }
        for k,v in pairs(map.room_info.exits) do
            map.room_info.exits[k] = tonumber(v)
        end
        handle_move()
    elseif event == "shiftRoom" then
        local dir = exitmap[arg[1]] or arg[1]
        if not table.contains(exits, dir) then
            echo("Error: Invalid direction '" .. dir .. "'.")
        else
            shift_room(dir)
        end
    elseif event == "sysConnectionEvent" then
        config()
    end
end

registerAnonymousEventHandler("gmcp.Room.Info","map.eventHandler")
registerAnonymousEventHandler("shiftRoom","map.eventHandler")
registerAnonymousEventHandler("sysConnectionEvent", "map.eventHandler")
