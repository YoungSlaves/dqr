-- Extracted verbatim from harvardd.lua lines 40296-41270; presentation owned elsewhere.
return function(context)
    local config = context.CFG
    local runtimeState, hazardReader = context.RT, context.RD
    local sqrt = math.sqrt
    local max = math.max
    local min = math.min
    local infinity = math.huge
    local abs, bossPhases = math.abs, { boss = nil, phase = "idle" }
    bossPhases.phaseAt = -infinity
    bossPhases.fansSinceSlam = 0
    bossPhases.lastFanAt = -infinity
    bossPhases.lastSlamAt = -infinity
    bossPhases.lastJumpAt = -infinity
    bossPhases.lastChainAt = -infinity
    bossPhases.lastSpikesAt = -infinity
    bossPhases.lastFloorAt = -infinity
    bossPhases.respawnAt = -infinity
    bossPhases.lastLineAt = -infinity
    bossPhases.lastMissileAt = -infinity
    bossPhases.fanSeen = 0
    bossPhases.slamSeen = 0
    bossPhases.note = ""
    context.PB = bossPhases
    local function helper(argument, argument2, argument3, argument4)
        local value, value2 = argument - argument3, argument2 - argument4
        return sqrt(value * value + value2 * value2)
    end
    local function helper2(argument)
        if argument then
            if argument.isBoss then
                if not argument.model then
                    return nil
                end
            else
                return nil
            end
        else
            return nil
        end
        return context.bossProfile(argument.model.Name)
    end
    local function helper3(phase, phaseAt)
        if bossPhases.phase ~= phase then
            bossPhases.phase = phase
            bossPhases.phaseAt = phaseAt
        end
    end
    local function helper4(argument, champEntry, argument2)
        if hazardReader.champEntry then
        elseif argument2 then
            if argument2.root then
                if argument2.root.Parent then
                    local position = argument2.root.Position
                    if helper(champEntry.X, champEntry.Z, position.X, position.Z) <= 140 then
                        hazardReader.champEntry = champEntry
                    end
                end
            end
        end
        local fanStarts = hazardReader.fanStarts
        local lastFanAt = fanStarts and fanStarts[#fanStarts]
        if lastFanAt then
            if lastFanAt ~= bossPhases.lastFanAt then
                bossPhases.lastFanAt = lastFanAt
                bossPhases.fanSeen = bossPhases.fanSeen + 1
                bossPhases.fansSinceSlam = bossPhases.fansSinceSlam + 1
            end
        end
        if hazardReader.lastSlamAt then
            if hazardReader.lastSlamAt ~= bossPhases.lastSlamAt then
                bossPhases.lastSlamAt = hazardReader.lastSlamAt
                bossPhases.slamSeen = bossPhases.slamSeen + 1
                bossPhases.fansSinceSlam = 0
            end
        end
        if hazardReader.jumpUpAt then
            if hazardReader.jumpUpAt ~= bossPhases.lastJumpAt then
                bossPhases.lastJumpAt = hazardReader.jumpUpAt
            end
        end
        local value, value2, value3 =
            hazardReader.fanUntil ~= nil and argument < hazardReader.fanUntil + 1,
            argument - bossPhases.lastFanAt,
            argument - bossPhases.lastSlamAt
        if value then
            helper3(bossPhases.fansSinceSlam == 1 and bossPhases.slamSeen > 0 and "bigfan" or "fan", argument)
        elseif value3 < 3 then
            helper3("slam", argument)
        elseif bossPhases.fansSinceSlam >= 1 and value2 > 6 then
            helper3("vortex", argument)
        elseif bossPhases.lastFanAt > -infinity then
            if value2 > 4 then
                helper3("between", argument)
            else
                helper3("open", argument)
            end
        else
            helper3("open", argument)
        end
        pcall(bossPhases.champHop, argument, champEntry, argument2)
    end
    local function helper5()
        if hazardReader.hopDelays then
            return hazardReader.hopDelays
        end
        local hopDelays = {}
        pcall(function()
            if isfile and isfile("HarvardLabs/data/champ_hop.json") then
                local value =
                    getService("HttpService"):JSONDecode(readfile("HarvardLabs/data/champ_hop.json"))
                if type(value) == "table" then
                    for index, entry in ipairs(value) do
                        if type(entry) == "number" then
                            hopDelays[#hopDelays + 1] = entry
                        end
                    end
                end
            end
        end)
        hazardReader.hopDelays = hopDelays
        return hopDelays
    end
    local function hopDelay()
        local value = helper5()
        if #value == 0 then
            return config.champHopDelay
        end
        local value2 = {}
        for index, entry in ipairs(value) do
            value2[index] = entry
        end
        table.sort(value2)
        return value2[math.ceil(#value2 / 2)]
    end
    bossPhases.hopDelay = hopDelay
    bossPhases.champHop = function(argument, champMid, argument2)
        if config.champHopKeep == false then
            return
        elseif argument2 then
            if argument2.root then
                if not argument2.root.Parent then
                    return
                end
            else
                return
            end
        else
            return
        end
        champMid = argument2.root.Position
        if not hazardReader.champMid then
            if bossPhases.slamSeen == 0 then
                hazardReader.champMid = champMid
            end
        end
        argument2 = hazardReader.hub or hazardReader.champMid
        if not argument2 then
            return
        end
        local value, champHop =
            helper(champMid.X, champMid.Z, argument2.X, argument2.Z), hazardReader.champHop
        if
            bossPhases.slamSeen > 0
            and bossPhases.lastSlamAt > -infinity
            and (if champHop then champHop.slamAt ~= bossPhases.lastSlamAt else not champHop)
        then
            champHop = { slamAt = bossPhases.lastSlamAt, away = false }
            hazardReader.champHop = champHop
        end
        if not champHop then
            return
        end
        if value > (config.champHopAwayR or 20) then
            champHop.away = true
        end
        if champHop.away and not champHop.backAt and value < (config.champHopHomeR or 10) then
            champHop.backAt = argument
            local value2 = argument - champHop.slamAt
            if value2 > 0.3 and value2 < 30 then
                local value3 = helper5()
                value3[#value3 + 1] = value2
                while true do
                    local value4, champHopKeepN = #value3, config.champHopKeepN
                    if not (value4 > (champHopKeepN or 12)) then
                        break
                    end
                    table.remove(value3, 1)
                end
                pcall(function()
                    writefile("HarvardLabs/data/champ_hop.json", getService("HttpService"):JSONEncode(value3))
                end)
            end
            if context.logT then
                context.logT(
                    "champhop",
                    0,
                    "Boss",
                    ("Midgardian hopped back to the middle %.1fs after the slam (learned %.1fs)"):format(
                        value2,
                        hopDelay() or value2
                    )
                )
            end
        end
        value = hopDelay()
        local value5, untilAt =
            value and champHop.slamAt + value - (config.champHopLead or 1.5)
                or champHop.slamAt + (config.champHopFirst or 1),
            champHop.backAt and champHop.backAt + (config.champHopFanHold or 4)
                or champHop.slamAt + (config.champHopMax or 15)
        untilAt = if value
            then if champHop.backAt
                then untilAt
                else if argument > champHop.slamAt + value + (config.champHopLate or 3)
                    then math.min(untilAt, argument + 1)
                    else untilAt
            else untilAt
        local value6 = champHop.backAt
        hazardReader.champHopDue = (if value6 then not value6 else value) and champHop.slamAt + value or nil
        if argument >= value5 and argument < untilAt and context.addZone then
            value6 = config.champHopKeepR or 60
            if not champHop.zone then
                local zone = {
                    name = "hop back",
                    kind = "zone",
                    bubbleKeep = true,
                    round = true,
                    exact = true,
                    weight = 1,
                    madeAt = argument,
                    cframe = CFrame.new(argument2.X, champMid.Y, argument2.Z),
                    size = Vector3.new(value6 * 2, 20, value6 * 2),
                    from = argument,
                    untilAt = untilAt,
                }
                context.addZone(zone)
                champHop.zone = zone
                if context.logT then
                    context.logT(
                        "champhop",
                        1,
                        "Boss",
                        ("hop back %s - out of the middle (%.0f round it)"):format(
                            value and ("due in %.1fs"):format(champHop.slamAt + value - argument)
                                or "not timed yet",
                            value6
                        )
                    )
                end
            end
            champHop.zone.untilAt = untilAt
        elseif champHop.zone then
            if argument >= untilAt then
                champHop.zone.untilAt = math.min(champHop.zone.untilAt or argument, argument)
            end
        end
    end
    local function helper6(argument)
        local lastCircle = hazardReader.lastCircle
        if lastCircle then
            if lastCircle.t ~= bossPhases.lastChainAt then
                bossPhases.lastChainAt = lastCircle.t
            end
        end
        if hazardReader.lastSpikesAt then
            if hazardReader.lastSpikesAt ~= bossPhases.lastSpikesAt then
                bossPhases.lastSpikesAt = hazardReader.lastSpikesAt
            end
        end
        if hazardReader.lastFloorAt then
            if hazardReader.lastFloorAt ~= bossPhases.lastFloorAt then
                bossPhases.lastFloorAt = hazardReader.lastFloorAt
            end
        end
        local value, value2, value3 =
            argument - bossPhases.lastChainAt,
            argument - bossPhases.lastSpikesAt,
            argument - bossPhases.lastFloorAt
        if value < 1.2 then
            helper3("circles", argument)
        elseif value < 4 and value2 > value then
            helper3("spikes-due", argument)
        elseif value2 < 2.5 then
            helper3("spikes", argument)
        elseif value3 < 3 then
            helper3("floor", argument)
        else
            helper3("between", argument)
        end
    end
    local function helper7(argument, vector, argument2)
        local value = hazardReader.odinEntry
        if (if value then not value else argument2) and argument2.root and argument2.root.Parent then
            local odinMiddle = context.Workspace
            local value2 = odinMiddle and (odinMiddle:FindFirstChild("thirdBossMiddlePart", true))
            if value2 then
                odinMiddle = value2.Position
                local value3 = helper(vector.X, vector.Z, odinMiddle.X, odinMiddle.Z)
                if value3 > 1 and value3 < 140 then
                    local value4, value5 =
                        (vector.X - odinMiddle.X) / value3, (vector.Z - odinMiddle.Z) / value3
                    if config.odinFarSide ~= false then
                        value4, value5 = -value4, -value5
                    end
                    local position, value6, value7, value8 =
                        argument2.root.Position,
                        (context.abilityReach and context.abilityReach() or 81) - (config.odinRingIn or 4),
                        { 81.25, 68.75, 56.25, 43.75, 31.25 }
                    for index, entry in ipairs(value7) do
                        local value9, value10 = odinMiddle.X + value4 * entry, odinMiddle.Z + value5 * entry
                        if helper(value9, value10, position.X, position.Z) <= value6 then
                            value8 = Vector3.new(value9, vector.Y, value10)
                            break
                        end
                    end
                    hazardReader.odinEntry = value8
                        or Vector3.new(odinMiddle.X + value4 * 43.75, vector.Y, odinMiddle.Z + value5 * 43.75)
                    hazardReader.odinMiddle = odinMiddle
                end
            end
        end
        if hazardReader.lastLineShotAt then
            if hazardReader.lastLineShotAt ~= bossPhases.lastLineAt then
                bossPhases.lastLineAt = hazardReader.lastLineShotAt
            end
        end
        if hazardReader.lastMissileAt then
            if hazardReader.lastMissileAt ~= bossPhases.lastMissileAt then
                bossPhases.lastMissileAt = hazardReader.lastMissileAt
            end
        end
        value = hazardReader.orbBlastAt
        if hazardReader.charAt and argument - hazardReader.charAt < (config.invulnAfterRespawn or 4) then
            helper3("invuln", argument)
        elseif argument - bossPhases.lastLineAt < 2 then
            helper3("lines", argument)
        elseif value and argument > value - 3 and argument < value + 1 then
            helper3("orbs", argument)
        elseif argument - bossPhases.lastMissileAt < 3 then
            helper3("missiles", argument)
        else
            helper3("odin", argument)
        end
    end
    bossPhases.tick = function(phaseAt, argument, argument2)
        local value = helper2(argument2)
        local boss = value and argument2.model.Name or nil
        if boss ~= bossPhases.boss then
            bossPhases.boss = boss
            bossPhases.phase = "idle"
            bossPhases.phaseAt = phaseAt
            bossPhases.fansSinceSlam = 0
            bossPhases.fanSeen = 0
            bossPhases.slamSeen = 0
            bossPhases.lastFanAt, bossPhases.lastSlamAt, bossPhases.lastJumpAt, bossPhases.lastChainAt, bossPhases.lastSpikesAt, bossPhases.lastFloorAt =
                -infinity, -infinity, -infinity, -infinity, -infinity, -infinity
        end
        if not value then
            bossPhases.phase = "idle"
            return
        end
        if value.fan then
            helper4(phaseAt, argument, argument2)
        elseif value.home then
            helper6(phaseAt)
        else
            helper7(phaseAt, argument, argument2)
        end
    end
    bossPhases.expectSlam = function(argument)
        if bossPhases.boss == nil then
            return false
        end
        if not context.bossProfile(bossPhases.boss).fan then
            return false
        end
        if hazardReader.fanUntil ~= nil then
            if argument < hazardReader.fanUntil + 1 then
                return false
            end
        end
        if argument - bossPhases.lastSlamAt < 10 then
            return false
        end
        if bossPhases.lastFanAt == -infinity then
            return true
        end
        if argument - bossPhases.lastFanAt < 6 then
            return false
        end
        return bossPhases.fansSinceSlam >= 1
    end
    bossPhases.fanHold = function(argument)
        if bossPhases.boss == nil then
            return nil
        elseif not context.bossProfile(bossPhases.boss).fan then
            return nil
        end
        local value, value2, value3 =
            hazardReader.fanUntil ~= nil and argument < hazardReader.fanUntil + 1,
            hazardReader.fanPeriod
                and hazardReader.lastFanStart
                and argument - hazardReader.lastFanStart
                    >= hazardReader.fanPeriod - (config.fanEarly or 2),
            argument - bossPhases.lastSlamAt
        if value then
        elseif value2 then
        elseif
            bossPhases.slamSeen > 0
            and bossPhases.fansSinceSlam == 0
            and value3 >= (config.slamHoldFrom or 10)
            and value3 < 25
        then
        else
            return nil
        end
        return config.fanRadius or 90
    end
    bossPhases.anchorPoint = function(vector, argument)
        local value = helper2(argument)
        if not value then
            return nil
        end
        if value.fan then
            local value2 = context.champWaypointsNow and context.champWaypointsNow() or config.champWaypoints
            if value2 then
                if #value2 == 0 then
                    return hazardReader.flankTarget
                end
            else
                return hazardReader.flankTarget
            end
            if context.champTourTarget then
                local flankTarget = context.champTourTarget(
                    vector,
                    argument and argument.root and argument.root.Parent and argument.root.Position or nil
                )
                if flankTarget then
                    hazardReader.flankTarget = flankTarget
                    return flankTarget
                end
            end
            local value3 = hazardReader.flankTarget
            if value3 then
                if helper(vector.X, vector.Z, value3.X, value3.Z) < 40 then
                    return value3
                end
            end
            local value4, flankTarget2
            for index = 1, #value2, 1 do
                value3 = value2[index]
                index = helper(vector.X, vector.Z, value3[1], value3[3])
                if if value4 then index < value4 else not value4 then
                    value4, flankTarget2 = index, Vector3.new(value3[1], vector.Y, value3[3])
                end
            end
            hazardReader.flankTarget = flankTarget2
            return flankTarget2
        end
        if not value.home then
            return hazardReader.odinEntry
        end
        return nil
    end
    bossPhases.hold = function(argument, argument2)
        local value = helper2(argument2)
        if not value then
            return nil, nil
        end
        if value.fan then
            if config.champWaypoints then
                if #config.champWaypoints > 0 then
                    return nil, nil
                end
            end
            return bossPhases.fanHold(argument), hazardReader.hub
        end
        if not value.home then
            if bossPhases.phase == "lines" then
                if argument2.root then
                    if argument2.root.Parent then
                        if not (value.ringBand and config.odinFirstBeamOnly ~= false) then
                            return config.odinLineHold or 85, argument2.root.Position
                        end
                    end
                end
            end
        end
        return nil, nil
    end
    bossPhases.anchor = function(position, argument, argument2, argument3)
        argument = helper2(argument2)
        if argument then
            if argument2.root then
                if not argument2.root.Parent then
                    return nil
                end
            else
                return nil
            end
        else
            return nil
        end
        position = argument2.root.Position
        if argument.home then
            argument2 = hazardReader.bobHome or context.bobCrystalCentroid()
            if not argument2 then
                return nil
            end
            local value, value2 = argument2.X - position.X, argument2.Z - position.Z
            local value3 = sqrt(value * value + value2 * value2)
            if value3 < 1 then
                return nil
            end
            return Vector3.new(
                position.X + value / value3 * argument3,
                position.Y,
                position.Z + value2 / value3 * argument3
            )
        end
        if argument.fan then
            if hazardReader.hub then
                local value4, value5 = position.X - hazardReader.hub.X, position.Z - hazardReader.hub.Z
                argument2 = sqrt(value4 * value4 + value5 * value5)
                if argument2 < 6 then
                    return nil
                end
                return Vector3.new(
                    position.X + value4 / argument2 * argument3,
                    position.Y,
                    position.Z + value5 / argument2 * argument3
                )
            end
        end
        return nil
    end
    context.bobLine = function()
        if config.bobSpikeLine == false then
            return nil
        end
        local value = context.BR and context.BR.target
        if value then
            if value.isBoss then
                if value.root then
                    if value.root.Parent then
                        if value.model then
                            if not context.bossProfile(value.model.Name).home then
                                return nil
                            end
                        else
                            return nil
                        end
                    else
                        return nil
                    end
                else
                    return nil
                end
            else
                return nil
            end
        else
            return nil
        end
        local vector = context.bobCrystal and context.bobCrystal("green")
        if not vector then
            return nil
        end
        local position = value.root.Position
        local value2, value3 = vector.X - position.X, vector.Z - position.Z
        local value4 = sqrt(value2 * value2 + value3 * value3)
        if value4 < 1 then
            return nil
        end
        local value5 = context.standoffFor and context.standoffFor(value) or 57
        local value6, value7, value8 =
            min(config.bobLineKeep or value5 * (config.bobSpikeBackShare or 0.75), value4),
            value2 / value4,
            value3 / value4
        return {
            ax = vector.X,
            az = vector.Z,
            bx = position.X + value7 * value6,
            bz = position.Z + value8 * value6,
            ux = value7,
            uz = value8,
            len = value4 - value6,
        }
    end
    context.bobLinePoint = function(argument, argument2, argument3)
        argument3 = argument3 or context.bobLine()
        if not argument3 then
            return nil
        end
        local value = (argument - argument3.bx) * argument3.ux + (argument2 - argument3.bz) * argument3.uz
        value = if value < 0 then 0 else if value > argument3.len then argument3.len else value
        local value2, value3 = argument3.bx + argument3.ux * value, argument3.bz + argument3.uz * value
        return value2, value3, sqrt((argument - value2) ^ 2 + (argument2 - value3) ^ 2), value
    end
    bossPhases.lean = function(argument, vector, argument2)
        local value, value2, value3, value4 = vector.X, vector.Z
        local value5, value6 =
            bossPhases.boss and context.bossProfile(bossPhases.boss) or nil,
            context.BR and context.BR.target or nil
        local value7 = value6
                and value6.isBoss
                and value6.root
                and value6.root.Parent
                and value6.root.Position
            or nil
        if value5 and value5.home and value7 then
            if hazardReader.bobHome then
                local value8, value9 = hazardReader.bobHome.X - value7.X, hazardReader.bobHome.Z - value7.Z
                local value10, value11, value12, value13 =
                    sqrt(value8 * value8 + value9 * value9),
                    context.standoffFor and context.standoffFor(value6) or 57
                if value10 > 1 then
                    value12, value13 =
                        Vector3.new(
                            value7.X + value8 / value10 * value11,
                            value7.Y,
                            value7.Z + value9 / value10 * value11
                        ),
                        config.bobCentreBias or 30
                else
                    value12, value13 = value3, value4
                end
                local value14 = helper(value, value2, value7.X, value7.Z)
                local value15 = value14 <= (context.abilityReach and context.abilityReach() or 77) - 6
                if
                    (bossPhases.phase == "circles" or bossPhases.phase == "spikes-due")
                    and value14 < (config.bobCircleLeanRange or 110)
                then
                    if not value15 then
                        value13 = config.bobCircleLean or 40
                        value12 = value7
                    end
                end
                local value16 = argument2 and argument2.box and argument2.box.name or nil
                local value17, value18, value19, value20 = value16 ~= nil
                    and (value16 == "spikes grow" or value16 == "ground spikes" or value16 == "spike field" or value16:find(
                        "icespikes",
                        1,
                        true
                    ) ~= nil)
                    and value14 < 130
                if value17 and config.bobSpikeLine ~= false then
                    if context.bobLinePoint then
                        value18, value19, value20 = context.bobLinePoint(value, value2)
                    end
                end
                if value18 then
                    if value20 > (config.bobLineNear or 4) then
                        value12, value4 =
                            Vector3.new(value18, vector.Y, value19), config.bobSpikeLineLean or 55
                        value3 = value12
                    else
                        if value15 then
                            value3, value4 = value12, value13
                        else
                            value16 = context.bobLine()
                            value12, value4 =
                                Vector3.new(value16.bx, vector.Y, value16.bz), config.bobSpikeLean or 50
                            value3 = value12
                        end
                    end
                else
                    if value17 then
                        local value21, value22, value23 = 0, 0, 0
                        if value10 > 1 then
                            value21, value22 = -value9 / value10, value8 / value10
                            value23 = (value - value7.X) * value21 + (value2 - value7.Z) * value22
                        end
                        local value24 = config.bobSpikeBackAt or value11 * (config.bobSpikeBackShare or 0.75)
                        if value10 > 1 and abs(value23) > (config.bobSpikeSideAt or 34) then
                            value12, value4 =
                                Vector3.new(value - value21 * value23, vector.Y, value2 - value22 * value23),
                                config.bobSpikeMidLean or 55
                            value3 = value12
                        else
                            if value14 < value24 then
                                local value25, value26 = value - value7.X, value2 - value7.Z
                                local value27 = sqrt(value25 * value25 + value26 * value26)
                                if value27 > 1 then
                                    value12, value4 =
                                        Vector3.new(
                                            value + value25 / value27 * (config.bobSpikeBackOut or 40),
                                            vector.Y,
                                            value2 + value26 / value27 * (config.bobSpikeBackOut or 40)
                                        ),
                                        config.bobSpikeBackLean or 55
                                    value3 = value12
                                else
                                    value3, value4 = value12, value13
                                end
                            else
                                if value15 then
                                    value3, value4 = value12, value13
                                else
                                    value4 = config.bobSpikeLean or 50
                                    value3 = value7
                                end
                            end
                        end
                    else
                        value3, value4 = value12, value13
                    end
                end
            end
        end
        if value5 and not value5.fan and not value5.home and value7 and hazardReader.odinEntry then
            if bossPhases.phase ~= "lines" then
                value6 = hazardReader.odinEntry
                value4 = config.odinEntryLean or 30
                value3 = value6
            end
        end
        value6 = hazardReader.missileAxis
        if value5 and not value5.fan and not value5.home and value6 and argument - value6.t < 3 then
            if bossPhases.phase ~= "lines" then
                local value28, value29 = -value6.dz, value6.dx
                local value30 = (value - value6.ox) * value28 + (value2 - value6.oz) * value29
                if abs(value30) > 4 then
                    local value31 =
                        Vector3.new(value - value28 * value30, vector.Y, value2 - value29 * value30)
                    value4 = config.odinAxisLean or 40
                    value3 = value31
                end
            end
        end
        if value5 and not value5.fan and not value5.home and value7 then
            if bossPhases.phase == "lines" then
                local value32, value33 = value - value7.X, value2 - value7.Z
                value6 = sqrt(value32 * value32 + value33 * value33)
                if value6 < (config.odinLineHold or 85) + 10 then
                    if value6 < 1 then
                        value32, value33, value6 = 1, 0, 1
                    end
                    local value34 =
                        Vector3.new(value + value32 / value6 * 60, vector.Y, value2 + value33 / value6 * 60)
                    value4 = config.odinLineLean or 40
                    value3 = value34
                end
            end
        end
        if value5 and value5.fan then
            if hazardReader.hub then
                value6, value7 = nil
                if hazardReader.fanUntil ~= nil then
                    if argument < hazardReader.fanUntil + 1 then
                        local value35, value36 = value - hazardReader.hub.X, value2 - hazardReader.hub.Z
                        local value37 = sqrt(value35 * value35 + value36 * value36)
                        if value37 < 1 then
                            value35, value36, value37 = 1, 0, 1
                        end
                        local value38, value39, value40 =
                            value35 / value37, value36 / value37, hazardReader.fanSweep or 0
                        if value40 ~= 0 then
                            local value41 = value40 * math.rad(config.fanBehindDeg or 30)
                            local value42, value43 = math.cos(value41), math.sin(value41)
                            value38, value39 =
                                value38 * value42 - value39 * value43, value38 * value43 + value39 * value42
                        end
                        value40 = Vector3.new(value + value38 * 60, vector.Y, value2 + value39 * 60)
                        value6 = config.fanLean or 40
                        value7 = value40
                    else
                        value7, value6 = value3, value4
                    end
                else
                    value7, value6 = value3, value4
                end
                if value7 == nil then
                    if context.quietDir then
                        local value44, value45 = context.quietDir(argument, value, value2)
                        if value44 then
                            local value46, value47 = value - hazardReader.hub.X, value2 - hazardReader.hub.Z
                            local value48 = math.clamp(
                                sqrt(value46 * value46 + value47 * value47),
                                (config.hubKeepOut or 60) + 5,
                                (config.fanRadius or 108) - 10
                            )
                            if context.champMid then
                                value47, value46 = context.champMid()
                                value48 = if value47
                                    then max(value48, value46 + (config.champMidRing or 2))
                                    else value48
                            end
                            value47 = Vector3.new(
                                hazardReader.hub.X + value44 * value48,
                                vector.Y,
                                hazardReader.hub.Z + value45 * value48
                            )
                            value4 = config.quietLean or 30
                            value3 = value47
                        else
                            value3, value4 = value7, value6
                        end
                    else
                        value3, value4 = value7, value6
                    end
                else
                    value3, value4 = value7, value6
                end
            end
        end
        if
            value5
            and value5.fan
            and value3 == nil
            and config.champWaypoints
            and hazardReader.flankTarget
            and helper(value, value2, hazardReader.flankTarget.X, hazardReader.flankTarget.Z)
                > (config.waypointHold or 14)
        then
            value3, value4 = hazardReader.flankTarget, config.waypointLean or 25
        else
            if
                value5
                and value5.fan
                and value3 == nil
                and config.champEntryBox
                and context.inEntryBox
                and context.inEntryBox(value, value2, 15)
                and hazardReader.flankTarget
            then
                value3, value4 = hazardReader.flankTarget, config.entranceLean or 20
            else
                if value5 and value5.fan and hazardReader.champEntry then
                    if value3 == nil then
                        if not config.champEntryBox then
                            value6, value7 =
                                value - hazardReader.champEntry.X, value2 - hazardReader.champEntry.Z
                            argument = sqrt(value6 * value6 + value7 * value7)
                            if argument < (config.entranceKeepOut or 45) + 25 then
                                if argument < 1 then
                                    value6, value7, argument = 1, 0, 1
                                end
                                local value49 = Vector3.new(
                                    value + value6 / argument * 60,
                                    vector.Y,
                                    value2 + value7 / argument * 60
                                )
                                value4 = config.entranceLean or 20
                                value3 = value49
                            end
                        end
                    end
                end
            end
        end
        if value5 and value5.fan and hazardReader.hub and argument2 and argument2.box then
            if argument2.box.name == "firstbossjumpslam" then
                value6, value7 = value - hazardReader.hub.X, value2 - hazardReader.hub.Z
                argument = sqrt(value6 * value6 + value7 * value7)
                if argument < 1 then
                    value6, value7, argument = 1, 0, 1
                end
                local value50 =
                    Vector3.new(value + value6 / argument * 60, vector.Y, value2 + value7 / argument * 60)
                value4 = config.slamAwayLean or 35
                value3 = value50
            end
        end
        value7 = context.BB and context.BB.pend or nil
        if value7 then
            for index = 1, #value7, 1 do
                argument = value7[index]
                if
                    argument
                    and (argument.name == "slam incoming" or argument.name == "slam soon")
                    and argument.ox
                    and argument.r
                then
                    value6, index = value - argument.ox, value2 - argument.oz
                    local value51 = sqrt(value6 * value6 + index * index)
                    if value51 < argument.r + 8 then
                        if hazardReader.hub then
                            value6, index = value - hazardReader.hub.X, value2 - hazardReader.hub.Z
                            value51 = sqrt(value6 * value6 + index * index)
                        end
                        if value51 < 1 then
                            value6, index, value51 = 1, 0, 1
                        end
                        value3, value4 =
                            Vector3.new(
                                value + value6 / value51 * 60,
                                vector.Y,
                                value2 + index / value51 * 60
                            ),
                            config.slamLean or 30
                        break
                    end
                end
            end
        end
        if value5 and value5.fan and value3 == nil then
            if context.champMid then
                value7, value6 = context.champMid()
                if value7 then
                    local value52, value53 = value - value7.X, value2 - value7.Z
                    argument = sqrt(value52 * value52 + value53 * value53)
                    if argument < value6 then
                        if argument < 1 then
                            value52, value53, argument = 1, 0, 1
                        end
                        local value54 = value6 + (config.champMidRing or 2)
                        local value55 = Vector3.new(
                            value7.X + value52 / argument * value54,
                            vector.Y,
                            value7.Z + value53 / argument * value54
                        )
                        value4 = config.champMidLean or 40
                        value3 = value55
                    end
                end
            end
        end
        value6 = hazardReader.leash
        if value5 and value5.fan and value6 and value6.enemy and value6.enemy.root then
            if value6.enemy.root.Parent then
                argument = context.arenaCentre and context.arenaCentre() or value6.enemy.root.Position
                local value56, value57, value58, value59, value60 =
                    helper(value, value2, argument.X, argument.Z),
                    (value6.radius or config.leashRadius or 122) - (config.arenaEdge or 32),
                    argument2
                        and argument2.box
                        and (
                            argument2.box.name == "firstbossjumpslam"
                            or argument2.box.name == "slam incoming"
                            or argument2.box.name == "slam soon"
                        )
                if context.champMid then
                    value59, value60 = context.champMid()
                end
                value7 = value57 - 12
                if
                    value56
                    > (if value59 then max(value7, value60 + (config.champMidBand or 10)) else value7)
                then
                    if not value58 then
                        value57 = Vector3.new(argument.X, vector.Y, argument.Z)
                        if value59 then
                            if value56 > 1 then
                                local value61 = value60 + (config.champMidRing or 2)
                                value3 = Vector3.new(
                                    argument.X + (value - argument.X) / value56 * value61,
                                    vector.Y,
                                    argument.Z + (value2 - argument.Z) / value56 * value61
                                )
                            else
                                value3 = value57
                            end
                        else
                            value3 = value57
                        end
                        local value62 = max(value4 or 0, config.rimLean or 12)
                        value4 = value62
                    end
                end
            end
        end
        return value3, value4
    end
    bossPhases.state = function()
        return bossPhases.boss
                and ("%s:%s f%d s%d"):format(
                    bossPhases.boss,
                    bossPhases.phase,
                    bossPhases.fansSinceSlam,
                    bossPhases.slamSeen
                )
            or "-"
    end
end
