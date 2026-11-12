-- Extracted verbatim from harvardd.lua lines 36276-36826; presentation owned elsewhere.
    local config = context.CFG
    local runtimeState = context.RT
    local hazardReader = context.RD
    local workspace = game:GetService("Workspace")
    local hazards = context.hazards
    local sqrt = math.sqrt
    local abs = math.abs
    local max = math.max
    local min = math.min
    local infinity, dangerGeometry =
        math.huge, {
            target = nil,
            reason = "",
            dangerHere = 0,
            here0 = 0,
            now = 0,
            offsets = {},
            outer = {},
            cands = {},
            boxes = {},
            reach = 2,
            halfHeight = 5,
            feet = 3,
            approach = nil,
            heading = nil,
        }
    dangerGeometry.headingAt = -infinity
    dangerGeometry.evalStats = {}
    local function depthOf(zone, argument, argument2, argument3, argument4)
        local value = argument2 - zone.cy
        if abs(value) > zone.hy + argument4 + (runtimeState.gsRampTallX or 0) then
            if value > 0 then
                if value <= zone.hy + argument4 + (config.sinkSlack or 4) then
                    if zone.hy <= 1.5 then
                        if (zone.r or max(zone.ha or 0, zone.hb or 0)) >= 3 then
                            if context.belowNL then
                                if not (context.belowNL()) then
                                    return -infinity
                                end
                            else
                                return -infinity
                            end
                        else
                            return -infinity
                        end
                    else
                        return -infinity
                    end
                else
                    return -infinity
                end
            else
                return -infinity
            end
        end
        argument2, argument4 = argument - zone.cx, argument3 - zone.cz
        if zone.r then
            argument = sqrt(argument2 * argument2 + argument4 * argument4)
            argument3 = zone.r - argument
            if zone.ring then
                if argument2 * zone.sx + argument4 * zone.sz < 0 then
                    return -infinity
                end
                argument3 = min(argument3, argument - zone.ring)
            end
            return argument3
        end
        value, argument =
            abs(argument2 * zone.ax + argument4 * zone.az) - zone.ha,
            abs(argument2 * zone.bx + argument4 * zone.bz) - zone.hb
        if value <= 0 then
            if argument <= 0 then
                return -max(value, argument)
            end
        end
        return -sqrt(max(value, 0) ^ 2 + max(argument, 0) ^ 2)
    end
    local function helper(argument, argument2, argument3)
        local value = argument + argument2
        if value >= 0 then
            return 1
        end
        if -value < argument3 then
            return 1 + value / argument3
        end
        return 0
    end
    HLGS = game.PlaceId == 101088859550383
    HLGSF = HLGS
    context.GS_DQ_PLACES = { [85776757589518] = true, [115445507767090] = true }
    context.GS_MOB_NAMES = {
        ["archpriest kiryne"] = true,
        ["archpriestess kiryne"] = true,
        ["general cragg"] = true,
        ["vytelus, the dragon lord"] = true,
        vytelus = true,
    }
    context.gsMobName = function(argument)
        local value = string.lower(tostring(argument or ""))
        return value:sub(1, 7) == "dracani" or context.GS_MOB_NAMES[value] == true
    end
    context.gsDetect = function()
        if HLGS == true then
            return true
        end
        if config.gsDqr == false then
            return false
        elseif not context.GS_DQ_PLACES[game.PlaceId] then
            return false
        end
        local value, dungeonName = false, workspace:FindFirstChild("dungeonName")
        if dungeonName and dungeonName:IsA("StringValue") and dungeonName.Value ~= "" then
            value = dungeonName.Value == "Gilded Skies"
        else
            local success, value2 = pcall(function()
                return getService("TeleportService"):GetLocalPlayerTeleportData()
            end)
            if success then
                if type(value2) == "table" then
                    local value3, value4 = { "Dungeon", "dungeon", "dungeonName", "map", "Map" }, value
                    for index, entry in ipairs(value3) do
                        value4 = if value2[entry] == "Gilded Skies" then true else value4
                    end
                    value = value4
                end
            end
            for index2 = 1, 10, 1 do
                if value then
                    break
                end
                value2 = workspace:FindFirstChild("g" .. index2)
                if value2 then
                    for index3, child in ipairs(value2:GetChildren()) do
                        if context.gsMobName(child.Name) then
                            value = true
                            break
                        end
                    end
                end
            end
            if not value then
                for index4, entry2 in ipairs(context.RD and context.RD.enemies or {}) do
                    if entry2.model and context.gsMobName(entry2.model.Name) then
                        value = true
                        break
                    end
                end
            end
        end
        if value then
            HLGS = true
            HLGSF = false
            context.GS_NOMELEE = true
            if getgenv then
                pcall(function()
                    local value5, hlgsf
                    value5, hlgsf, getgenv().HLGS = getgenv(), HLGSF, HLGS
                    value5.HLGSF = hlgsf
                end)
            end
            if context.log then
                context.log(
                    "GS",
                    ("Gilded Skies run in Dungeon Quest (place %d, own game systems: %s)"):format(
                        game.PlaceId,
                        tostring(HLGSF)
                    )
                )
            end
        end
        return value
    end
    if getgenv then
        pcall(function()
            local value, hlgsf
            value, hlgsf, getgenv().HLGS = getgenv(), HLGSF, HLGS
            value.HLGSF = hlgsf
        end)
    end
    pcall(context.gsDetect)
    task.spawn(function()
        while
            HLGS ~= true
            and not (context.RT and context.RT.destroyed)
            and context.GS_DQ_PLACES[game.PlaceId]
        do
            task.wait(1)
            pcall(context.gsDetect)
        end
    end)
    context.GS_NOMELEE = HLGS == true
    context.GS_EMPTY = {}
    local function dangerAt(argument, argument2, argument3, argument4, argument5, argument6, argument7)
        local value, value2, value3, value4, value5 =
            argument5 or dangerGeometry.reach,
            dangerGeometry.halfHeight,
            argument6 or context.GS_NOMELEE and (config.gsDodgeShoulder or 1) or config.dodgeShoulder,
            dangerGeometry.now,
            dangerGeometry.boxes
        argument6 = value4 + argument4
        if context.RT then
            if context.RT.gsInvEnd then
                if argument6 <= context.RT.gsInvEnd then
                    return 0
                end
            end
        end
        argument5 = 0
        for index = 1, #value5, 1 do
            local value6 = value5[index]
            if not value6.far then
                index = nil
                if value6.moving then
                    if
                        argument6 <= value6.untilAt
                        and (
                            value6.ground
                            or abs(argument2 - value6.oy)
                                <= value6.halfH + value2 + (runtimeState.gsRampTallX or 0)
                        )
                    then
                        if not (argument7 and (argument7(value6))) then
                            local value7, value8 =
                                value6.offset + value6.speed * max(argument6 - value6.pathStart, 0),
                                value6.endAlong
                            value7 = if value8 then if value7 > value8 then value8 else value7 else value7
                            local value9, value10 = value6.dx, value6.dz
                            local value11, value12 =
                                argument - (value6.ox + value9 * value7),
                                argument3 - (value6.oz + value10 * value7)
                            local value13, value14, value15, value16 =
                                value11 * value9 + value12 * value10, value6.r
                            if value14 then
                                value8 = -value11 * value10 + value12 * value9
                                value15, value16 =
                                    value14 - sqrt(value13 * value13 + value8 * value8), abs(value8) - value14
                            else
                                local value17 = abs(value13) - value6.halfL
                                value16 = abs(-value11 * value10 + value12 * value9) - value6.halfW
                                value15 = if value17 <= 0 and value16 <= 0
                                    then -max(value17, value16)
                                    else -sqrt(max(value17, 0) ^ 2 + max(value16, 0) ^ 2)
                            end
                            argument5 = if value15 + value < 0
                                then if value6.noLane
                                    then argument5
                                    else if value6.laneFree
                                        then argument5
                                        else if value13 > value6.halfL
                                            then if value16 <= value
                                                then if value13 - value6.halfL
                                                        <= value6.speed
                                                            * min(
                                                                max(value6.untilAt - argument6, 0),
                                                                value6.horizon or config.laneHorizon
                                                            )
                                                    then if argument5
                                                            < (dangerGeometry.laneV or config.pathLaneDanger)
                                                        then dangerGeometry.laneV or config.pathLaneDanger
                                                        else argument5
                                                    else argument5
                                                else argument5
                                            else argument5
                                else argument5
                            index = value15
                        end
                    end
                else
                    local from, exact = value6.from, value6.exact
                    local value18 = (if exact then not exact else value6.telegraphed or value6.from > value4)
                            and max(value6.lead or config.dodgeLead, dangerGeometry.leadFloor or 0)
                        or (dangerGeometry.leadFloor or 0)
                    index = if argument6 >= from - value18
                        then if argument6 <= value6.untilAt
                            then if argument7
                                then if argument7(value6)
                                    then index
                                    else depthOf(value6, argument, argument2, argument3, value2)
                                else depthOf(value6, argument, argument2, argument3, value2)
                            else index
                        else index
                end
                if index then
                    local value19, value20
                    if value6.fullKeep then
                        if dangerGeometry.redRelax then
                            value19, value20 = value, value3
                        else
                            value19, value20 = dangerGeometry.reach or value, config.redOrbShoulder or 0.75
                        end
                    else
                        value19, value20 = value, value3
                    end
                    if value6.slim then
                        value19, value20 =
                            (min(value19, value6.slim + (dangerGeometry.lag or 0) * config.slimLagShare)),
                            min(value20, config.slimShoulder)
                    end
                    local value21 = index + value19
                    value21 = if value21 >= 0
                        then 1
                        else if -value21 < value20 then 1 + value21 / value20 else 0
                    value21 = if value6.weight then value21 * value6.weight else value21
                    value21 = if value6.soft
                        then if argument4 > config.softAfter then value21 * config.softFactor else value21
                        else value21
                    if value21 > argument5 then
                        if value21 >= 1 then
                            return 1
                        end
                        argument5 = value21
                    end
                end
            end
        end
        value4 = hazardReader.leash
        if value4 then
            value2 = value4.enemy.root
            if value2.Parent then
                value5 = value2.Position
                if sqrt((argument - value5.X) ^ 2 + (argument3 - value5.Z) ^ 2) - value4.radius > -4 then
                    return 1
                end
            end
        end
        value2 = context.GS_NOMELEE and config.gsMeleeKeep ~= true and context.GS_EMPTY
            or hazardReader.enemies
        for index2 = 1, #value2, 1 do
            argument2 = value2[index2]
            if argument2.melee then
                if not argument2.isBoss then
                    argument6 = min(argument4, 0.6)
                    value4, value5 =
                        sqrt(
                            (argument - argument2.x - argument2.vx * argument6) ^ 2
                                + (argument3 - argument2.z - argument2.vz * argument6) ^ 2
                        ),
                        argument2.extent + argument2.meleeDistance + 2
                    argument7 = value4 <= value5 + value and 1
                        or helper(-(value4 - value5 - config.meleeBuffer), value, value3 * 2)
                            * config.meleeBandWeight
                    if argument7 > argument5 then
                        if argument7 >= 1 then
                            return 1
                        end
                        argument5 = argument7
                    end
                end
            end
        end
        return argument5
    end
    context.redOrbNear = function(argument, argument2, argument3)
        local value, value2, value3, value4, value5, value6, value7, value8 =
            dangerGeometry.boxes or {},
            dangerGeometry.now or os.clock(),
            dangerGeometry.reach or 1.8,
            (config.redOrbStand or 0.5) + (argument3 or 0),
            config.redOrbStandStep or 0.2,
            argument.X,
            argument.Z,
            (argument2 or 0) + 1.0E-6
        argument2 = type(value5) == "number" and value5 > 0
        for index = 1, #value, 1 do
            argument = value[index]
            if argument.fullKeep and argument.moving then
                argument3 = (argument.r or argument.halfW or 12) + value3 + value4
                local value9, value10, value11, value12, value13, endAlong, value14, value15, value16, value17, value18 =
                    argument3 * argument3,
                    (argument.untilAt or 0) + 0.2,
                    argument.offset or 0,
                    argument.speed or 0,
                    argument.pathStart or value2,
                    argument.endAlong,
                    argument.ox,
                    argument.oz,
                    argument.dx,
                    argument.dz,
                    0
                while value18 <= value8 do
                    index = value2 + value18
                    if index <= value10 then
                        local value19 = value11 + value12 * max(index - value13, 0)
                        value19 = if endAlong
                            then if value19 > endAlong then endAlong else value19
                            else value19
                        local value20, value21 =
                            value6 - (value14 + value16 * value19), value7 - (value15 + value17 * value19)
                        if value20 * value20 + value21 * value21 < value9 then
                            return true
                        end
                    elseif argument2 then
                        break
                    end
                    value18 += value5
                end
            end
        end
        return false
    end
    local function walkable(vector, argument, argument2, argument3, argument4)
        local value = config.maxStepHeight + 1.5
        local value2 = Vector3.new(vector.X, vector.Y - dangerGeometry.feet + value, vector.Z)
        local value3 = workspace:Blockcast(
            CFrame.new(value2),
            Vector3.new(2.5, 3, 2.5),
            Vector3.new(argument, argument2 + value, argument3) - value2,
            argument4
        )
        if value3 then
            if context.stairOk then
                if context.stairWalkOn then
                    if context.stairWalkOn() then
                        argument2, value = value3.Position.X - vector.X, value3.Position.Z - vector.Z
                        local success, value4 = pcall(
                            context.stairOk,
                            vector.X,
                            vector.Y - dangerGeometry.feet,
                            vector.Z,
                            argument,
                            argument3,
                            argument4,
                            math.sqrt(argument2 * argument2 + value * value)
                        )
                        if success then
                            if value4 then
                                return true, nil
                            end
                        end
                    end
                end
            end
        end
        return value3 == nil, value3
    end
    local function decide(argument, argument2)
        local now = os.clock()
        dangerGeometry.lag =
            min((runtimeState.pingS or 0) * max(runtimeState.speedNow or 16, 16), config.pingMarginMax)
        dangerGeometry.now, dangerGeometry.reach, dangerGeometry.halfHeight, dangerGeometry.feet =
            now,
            argument.Size.X * 0.5 + config.dodgeMargin + dangerGeometry.lag,
            (argument2.HipHeight + argument.Size.Y) * 0.5 + 2.5,
            argument2.HipHeight + argument.Size.Y * 0.5
        if context.GS_NOMELEE then
            dangerGeometry.reach = dangerGeometry.reach + (tonumber(config.gsDodgePad) or 1)
        end
        dangerGeometry.halfWidth = argument.Size.X * 0.5
        dangerGeometry.laneV = context.GS_NOMELEE
                and HLGS == true
                and (tonumber(config.gsPathLaneDanger) or 0.35)
            or nil
        if context.carryIgnoresHits and context.carryIgnoresHits() then
            for index = #dangerGeometry.boxes, 1, -1 do
                dangerGeometry.boxes[index] = nil
            end
        else
            hazards(now, dangerGeometry.boxes)
            if HLGS == true then
                if config.gsBallistaLanes == true then
                    if context.gsBallistaBoxes then
                        pcall(context.gsBallistaBoxes, now, dangerGeometry.boxes, argument.Position)
                    end
                end
            end
            if config.spikeGoalWay ~= false then
                local boxes, value = dangerGeometry.boxes, 0
                for index2 = 1, #boxes, 1 do
                    argument2 = boxes[index2]
                    index2 = string.lower(tostring(argument2.name or ""))
                    if
                        not (
                            config.circleGoalWay ~= false
                            and (
                                index2 == "circle next"
                                or index2 == "circle line"
                                or index2 == "secondbosscriclehitbox"
                                or index2 == "secondbossgroundslamcircle"
                                    and context.gsCraggChainLive
                                    and context.gsCraggChainLive(now)
                            )
                        )
                    then
                        if not (index2 == "ground spikes") then
                            if not (index2 == "spikes grow") then
                                if not (index2 == "spike field") then
                                    if index2:find("icespikes", 1, true) then
                                        if index2:find("hitbox", 1, true) then
                                            local value2 = value + 1
                                            boxes[value2] = argument2
                                            value = value2
                                        end
                                    else
                                        local value3 = value + 1
                                        boxes[value3] = argument2
                                        value = value3
                                    end
                                end
                            end
                        end
                    end
                end
                for index3 = #boxes, value + 1, -1 do
                    boxes[index3] = nil
                end
            end
        end
        dangerGeometry.here0, dangerGeometry.dangerHere, dangerGeometry.target, dangerGeometry.reason, dangerGeometry.origin =
            0, 0, nil, "bubble", argument.Position
        for index4 = #dangerGeometry.cands, 1, -1 do
            dangerGeometry.cands[index4] = nil
        end
        runtimeState.moveBoost = false
    end
    context.DG = dangerGeometry
    context.dangerAt = dangerAt
    context.decide = decide
    context.walkable = walkable
    context.depthOf = depthOf
    context.RING_GAPS = { 31.25, 43.75, 56.25, 68.75, 81.25 }
    context.odinRankOff = function(argument)
        local value, value2, value3, value4 =
            config.odinRankIn or 56.25,
            config.odinRankOut or 81.25,
            config.odinRank3In or 43.75,
            config.odinRank3Weight or 1.5
        if argument >= value then
            if argument <= value2 then
                return 0
            end
        end
        if argument > value2 then
            return argument - value2
        end
        if argument >= value3 then
            return (value - argument) * value4
        end
        return (value - value3) * value4 + (value3 - argument)
    end
    context.odinBandOff = function(argument)
        local value, value2 = config.odinBandIn or 43.75, config.odinRankOut or 81.25
        if argument < value then
            return value - argument
        end
        if argument > value2 then
            return argument - value2
        end
        return 0
    end

return function(context)
end
