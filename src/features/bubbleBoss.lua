-- Extracted verbatim from harvardd.lua lines 41272-51563; presentation owned elsewhere.
return function(context)
    local config = context.CFG
    local runtimeState = context.RT
    local hazardReader = context.RD
    local dangerGeometry = context.DG
    local depthOf = context.depthOf
    local parent = game:GetService("Workspace")
    local sharedValue = getService("Players")
    local abs = math.abs
    local sqrt = math.sqrt
    local max = math.max
    local min = math.min
    local infinity = math.huge
    local cos = math.cos
    local sin = math.sin
    local toRadians = math.rad
    local toDegrees = math.deg
    local atan2, bubbleBoss =
        math.atan2, {
            active = false,
            lethal = false,
            threats = {},
            rel = {},
            soft = {},
            pend = {},
            mov = {},
            primary = nil,
        }
    bubbleBoss.lastBreach = -infinity
    bubbleBoss.dir = nil
    bubbleBoss.dirAt = -infinity
    bubbleBoss.count = 0
    bubbleBoss.warmCount = 0
    bubbleBoss.warnCount = 0
    bubbleBoss.escapes = 0
    bubbleBoss.folder = nil
    bubbleBoss.pickedSafe = false
    bubbleBoss.pickedDist = 0
    context.BB = bubbleBoss
    local function helper(argument, argument2, argument3, argument4)
        local value = argument.offset + argument.speed * max(argument4 - argument.pathStart, 0)
        value = if argument.endAlong
            then if value > argument.endAlong then argument.endAlong else value
            else value
        value = if argument.bounces
            then if argument.freeAhead then min(value, argument.freeAhead) else value
            else value
        local value2, value3 =
            argument2 - (argument.ox + argument.dx * value), argument3 - (argument.oz + argument.dz * value)
        if argument.r and (argument.bbRound or config.roundMoving ~= false) then
            return argument.r - sqrt(value2 * value2 + value3 * value3)
        end
        argument2, argument4 =
            abs(value2 * argument.dx + value3 * argument.dz) - argument.halfL,
            abs(-value2 * argument.dz + value3 * argument.dx) - argument.halfW
        if argument2 <= 0 then
            if argument4 <= 0 then
                return -max(argument2, argument4)
            end
        end
        return -sqrt(max(argument2, 0) ^ 2 + max(argument4, 0) ^ 2)
    end
    local sharedValue2 = 0
    local function helper2(argument, argument2, argument3)
        local value = argument2 > sharedValue2 + 0.05 and not argument.noGrace and (config.expiryGrace or 0.6)
        local value2 = value or 0
        argument3 = if argument.noLead then 0 else argument3
        return (argument.from or 0) <= argument2 + (argument3 or 0)
            and (argument.untilAt or infinity) + value2 >= argument2
    end
    local setMetatable, weakKeys = setmetatable, { __mode = "k" }
    local sharedValue3 = setMetatable({}, weakKeys)
    local function velocityOf(argument, argument2)
        if argument.moving then
            return argument.dx * argument.speed, argument.dz * argument.speed
        end
        if config.gsOrbNoPredict ~= false then
            if argument.name then
                if string.find(string.lower(tostring(argument.name)), "movingorb", 1, true) then
                    return 0, 0
                end
            end
        end
        local value, value2 = argument.cx, argument.cz
        if value then
            if not value2 then
                return 0, 0
            end
        else
            return 0, 0
        end
        local value3 = sharedValue3[argument]
        if not value3 then
            sharedValue3[argument] = { x = value, z = value2, t = argument2, vx = 0, vz = 0 }
            return 0, 0
        end
        argument = argument2 - value3.t
        if argument > 0.011111111111111112 then
            local value4, value5 = (value - value3.x) / argument, (value2 - value3.z) / argument
            if value4 * value4 + value5 * value5 > 160000 then
                value4, value5 = 0, 0
            end
            value3.vx, value3.vz = value3.vx * 0.5 + value4 * 0.5, value3.vz * 0.5 + value5 * 0.5
            value3.x = value
            value3.z = value2
            value3.t = argument2
        end
        return value3.vx, value3.vz
    end
    bubbleBoss.velocityOf = velocityOf
    local function helper3(argument, argument2, argument3, argument4, argument5, argument6, argument7)
        if not (helper2(argument, argument5, argument7)) then
            return nil
        end
        if argument.moving then
            if not argument.ground then
                if
                    not (
                        abs(argument3 - argument.oy)
                        <= (argument.halfH or 6) + argument6 + (runtimeState.gsRampTallX or 0)
                    )
                then
                    return nil
                end
            end
            return helper(argument, argument2, argument4, argument5)
        end
        argument7 = argument5 - sharedValue2
        if argument7 > 0.001 then
            local value, value2 = velocityOf(argument, sharedValue2)
            if value * value + value2 * value2 > 4 then
                argument2, argument4 = argument2 - value * argument7, argument4 - value2 * argument7
            end
        end
        argument7 = depthOf(argument, argument2, argument3, argument4, argument6)
        if argument7 == -infinity then
            return nil
        end
        return argument7
    end
    local function helper4(argument)
        if argument.moving then
            if argument.r then
                if argument.bbRound then
                    return argument.r
                elseif config.roundMoving ~= false then
                    return argument.r
                end
            end
            if argument.halfL then
                if argument.halfW then
                    return sqrt(argument.halfL * argument.halfL + argument.halfW * argument.halfW)
                end
            end
            return nil
        end
        if argument.r then
            return argument.r
        end
        if argument.ha then
            if argument.hb then
                return sqrt(argument.ha * argument.ha + argument.hb * argument.hb)
            end
        end
        return nil
    end
    local function helper5(argument, argument2)
        local value = argument.offset + argument.speed * max(argument2 - argument.pathStart, 0)
        value = if argument.endAlong
            then if value > argument.endAlong then argument.endAlong else value
            else value
        return if argument.bounces
            then if argument.freeAhead then min(value, argument.freeAhead) else value
            else value
    end
    local function depthBound(argument, argument2, argument3, argument4, argument5)
        if not (helper2(argument, argument4, argument5)) then
            return infinity
        end
        argument5 = helper4(argument)
        if not argument5 then
            return nil
        end
        local value, value2
        if argument.moving then
            if argument.offset then
                if argument.speed then
                    if argument.pathStart then
                        if argument.ox then
                            if not argument.dx then
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
            local value3 = helper5(argument, argument4)
            value, value2 = argument.ox + argument.dx * value3, argument.oz + argument.dz * value3
        else
            value, value2 = argument.cx, argument.cz
            if value then
                if not value2 then
                    return nil
                end
            else
                return nil
            end
            local value4 = argument4 - sharedValue2
            if value4 > 0.001 then
                local value5, value6 = velocityOf(argument, sharedValue2)
                if value5 * value5 + value6 * value6 > 4 then
                    argument2, argument3 = argument2 - value5 * value4, argument3 - value6 * value4
                end
            end
        end
        argument4, argument = argument2 - value, argument3 - value2
        local value7 = sqrt(argument4 * argument4 + argument * argument) - argument5
        if value7 > 0 then
            return value7
        end
        return nil
    end
    local function laneBound(argument, argument2, argument3, argument4, argument5)
        if not argument.moving then
            return -infinity
        end
        local value = helper4(argument)
        if value then
            if argument.offset then
                if argument.speed then
                    if argument.pathStart then
                        if argument.ox then
                            if not argument.dx then
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
        local value2, value3 = helper5(argument, argument4), helper5(argument, argument5)
        local value4, value5, value6, value7 =
            argument.ox + argument.dx * value2,
            argument.oz + argument.dz * value2,
            argument.dx * (value3 - value2),
            argument.dz * (value3 - value2)
        argument = value6 * value6 + value7 * value7
        value3 = if argument > 1.0E-9
            then min(max(((argument2 - value4) * value6 + (argument3 - value5) * value7) / argument, 0), 1)
            else 0
        argument4, value2 = argument2 - (value4 + value6 * value3), argument3 - (value5 + value7 * value3)
        value5 = sqrt(argument4 * argument4 + value2 * value2) - value
        if value5 > 0 then
            return value5
        end
        return -infinity
    end
    bubbleBoss.depthBound = depthBound
    bubbleBoss.laneBound = laneBound
    local function shadowMiss(argument, argument2, argument3, argument4, argument5, argument6)
        bubbleBoss.shadowBad = (bubbleBoss.shadowBad or 0) + 1
        bubbleBoss.shadowList = bubbleBoss.shadowList or {}
        if #bubbleBoss.shadowList < 40 then
            bubbleBoss.shadowList[#bubbleBoss.shadowList + 1] = ("%s at (%.1f, %.1f) +%.2fs full=%s fast=%s primary=%s"):format(
                argument,
                argument2,
                argument3,
                argument4 - sharedValue2,
                argument5,
                argument6,
                tostring(bubbleBoss.primary and bubbleBoss.primary.box and bubbleBoss.primary.box.name or "-")
            )
        end
    end
    bubbleBoss.shadowMiss = shadowMiss
    local function helper6(argument, argument2, argument3, argument4, argument5, argument6)
        local value = argument.from or 0
        if not argument.moving then
            return helper3(argument, argument2, argument3, argument4, value, argument5, 0)
        end
        local value2 = min(argument.untilAt or value + 2, value + argument6)
        argument6 = nil
        for index = 0, 6, 1 do
            local value3 = helper3(
                argument,
                argument2,
                argument3,
                argument4,
                value + (value2 - value) * index / 6,
                argument5,
                0
            )
            argument6 = if value3
                then if argument6 then if value3 > argument6 then value3 else argument6 else value3
                else argument6
        end
        return argument6
    end
    local function arenaCentre()
        local value = hazardReader.leash
        if value then
            if not value.enemy then
                return nil
            end
        else
            return nil
        end
        local root = value.enemy.root
        if root then
            if not root.Parent then
                return nil
            end
        else
            return nil
        end
        if context.champMid then
            value = context.champMid()
            if value then
                return value
            end
        end
        if hazardReader.hub then
            if os.clock() - (hazardReader.hubAt or 0) < 20 then
                return hazardReader.hub
            end
        end
        return root.Position
    end
    local function helper7(argument, argument2, argument3, argument4)
        local value, value2, value3, value4 =
            argument2 - argument[1], argument3 - argument[2], argument[3], argument[4]
        argument2, argument3 = value * value3 + value2 * value4, -value * value4 + value2 * value3
        return abs(argument2) <= argument[5] + argument4 and abs(argument3) <= argument[6] + argument4
    end
    context.entryBoxDepth = function(argument, argument2)
        if not hazardReader.leash then
            return nil
        end
        local value = config.champEntryBoxes or config.champEntryBox and { config.champEntryBox } or nil
        if not value then
            return nil
        end
        local value2
        for index = 1, #value, 1 do
            local value3 = value[index]
            local value4, value5 = argument - value3[1], argument2 - value3[2]
            local value6, value7 =
                value4 * value3[3] + value5 * value3[4], -value4 * value3[4] + value5 * value3[3]
            value5, index = value3[5] - abs(value6), value3[6] - abs(value7)
            if value5 > 0 then
                if index > 0 then
                    value3 = min(value5, index)
                    value2 = if value2 then if value3 > value2 then value3 else value2 else value3
                end
            end
        end
        return value2
    end
    context.inEntryBox = function(argument, argument2, argument3)
        if not hazardReader.leash then
            return false
        end
        argument3 = argument3 or 0
        local value = config.champEntryBoxes
        if value then
            for index = 1, #value, 1 do
                if helper7(value[index], argument, argument2, argument3) then
                    return true
                end
            end
            return false
        end
        value = config.champEntryBox
        return value ~= nil and helper7(value, argument, argument2, argument3)
    end
    local sharedValue4, sharedValue5, sharedValue6 = false
    local sharedValue7, sharedValue8 = false
    local sharedValue9, sharedValue10, sharedValue11, sharedValue12, sharedValue13, sharedValue14, sharedValue15 =
        false
    local function arenaOf(argument, argument2)
        local value, arenaC, value2 = hazardReader.leash, bubbleBoss.arenaC
        if
            config.perfMemo ~= false
            and arenaC
            and runtimeState.frameN
            and arenaC.f == runtimeState.frameN
            and arenaC.L == value
        then
            value2 = arenaC.e
        else
            value2 = arenaCentre()
            local value3 = value and value.enemy and value.enemy.root
            arenaC = arenaC or {}
            arenaC.f, arenaC.L, arenaC.e, arenaC.bp =
                runtimeState.frameN, value, value2, value3 and value3.Parent and value3.Position or nil
            bubbleBoss.arenaC = arenaC
        end
        if not value2 then
            return false, nil, nil, nil
        end
        local value4 = (value.radius or 122) - (config.arenaEdge or 32)
        if value4 <= 0 then
            return false, nil, nil, nil
        end
        local value5 = min(config.hubKeepOut or 45, value4 - 20)
        value5 = if sharedValue6
            then if sharedValue6 > value5 then min(sharedValue6, value4 - 4) else value5
            else value5
        local value6, value7 = argument - value2.X, argument2 - value2.Z
        local value8 = sqrt(value6 * value6 + value7 * value7)
        if arenaC.bp then
            value6 = arenaC.bp
            local value9, value10 = argument - value6.X, argument2 - value6.Z
            if
                sqrt(value9 * value9 + value10 * value10)
                > (value.radius or 122) - (config.leashMargin or 8)
            then
                return true, value8, value5, value4
            end
        end
        if value8 > value4 then
            return true, value8, value5, value4
        end
        if value5 > 0 then
            if value8 < value5 then
                return true, value8, value5, value4
            end
        end
        if config.champEntryBox then
            if sharedValue4 then
                if context.inEntryBox(argument, argument2, 3) then
                    return true, value8, value5, value4
                end
            end
            if sharedValue5 then
                value6 = context.entryBoxDepth(argument, argument2)
                if value6 then
                    if value6 > sharedValue5 - 2 then
                        return true, value8, value5, value4
                    end
                end
            end
        elseif sharedValue7 then
            if hazardReader.champEntry then
                value, value7 = argument - hazardReader.champEntry.X, argument2 - hazardReader.champEntry.Z
                if sqrt(value * value + value7 * value7) < (config.entranceKeepOut or 45) then
                    return true, value8, value5, value4
                end
            end
        end
        return false, value8, value5, value4
    end
    context.outsideArena = function(argument, argument2)
        return (arenaOf(argument, argument2))
    end
    context.arenaOf = arenaOf
    context.arenaCentre = arenaCentre
    context.champFanDue = function(fanDueT)
        fanDueT = fanDueT or os.clock()
        if hazardReader.fanDueT then
            if fanDueT - hazardReader.fanDueT < 0.05 then
                return hazardReader.fanDueV
            end
        end
        local fanDueV = false
        if hazardReader.fanBeamAt and fanDueT - hazardReader.fanBeamAt < (config.champFanTail or 1) then
            fanDueV = true
        else
            if hazardReader.hopUpAt and fanDueT - hazardReader.hopUpAt < (config.champFanAfterHop or 1.5) then
                fanDueV = true
            else
                local value = config.champFanFromSlam == true and hazardReader.lastSlamAt or nil
                if value then
                    if not (hazardReader.hopUpAt and hazardReader.hopUpAt > value) then
                        local value2 = value
                            + (
                                context.PB and context.PB.hopDelay and context.PB.hopDelay()
                                or config.champHopDelay
                                or 16
                            )
                        fanDueV = fanDueT >= value2 - (config.champFanLead or 2.5)
                            and fanDueT <= value2 + (config.champFanLate or 4)
                    end
                end
            end
        end
        hazardReader.fanDueT = fanDueT
        hazardReader.fanDueV = fanDueV
        return fanDueV
    end
    context.champMid = function()
        if config.champMidKeep == false then
            return nil
        end
        if config.champMidTimed ~= false then
            if not (context.champFanDue(os.clock())) then
                return nil
            end
        end
        local champMidPart = hazardReader.leash
        if champMidPart then
            if champMidPart.enemy then
                if champMidPart.enemy.root then
                    if not champMidPart.enemy.root.Parent then
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
        champMidPart = hazardReader.champMidPart
        if not (champMidPart and champMidPart.Parent) then
            local champMidLook = os.clock()
            if champMidLook - (hazardReader.champMidLook or -infinity) > 5 then
                hazardReader.champMidLook = champMidLook
                champMidPart = parent:FindFirstChild("firstBossMiddlePart")
                hazardReader.champMidPart = champMidPart
            end
        end
        local champMidLast = champMidPart and champMidPart.Parent and champMidPart.Position
            or hazardReader.hub
            or hazardReader.champMidLast
        if not champMidLast then
            return nil
        end
        hazardReader.champMidLast = champMidLast
        return champMidLast, (context.fanFloorRaw and context.fanFloorRaw() or 78) + (config.champMidPad or 6)
    end
    context.champInside = function(argument, argument2)
        local vector, value = context.champMid()
        if not vector then
            return false
        end
        local value2, value3 = argument - vector.X, argument2 - vector.Z
        return value2 * value2 + value3 * value3 < value * value
    end
    context.champRingPoint = function(vector, argument)
        local vector2, value = context.champMid()
        if vector2 then
            if not vector then
                return vector, false
            end
        else
            return vector, false
        end
        local value2, value3 = vector.X - vector2.X, vector.Z - vector2.Z
        local value4 = sqrt(value2 * value2 + value3 * value3)
        if value4 >= value then
            return vector, false
        end
        if value4 < 2 then
            if argument then
                local value5, value6 = argument.X - vector2.X, argument.Z - vector2.Z
                local value7 = sqrt(value5 * value5 + value6 * value6)
                value2, value3, value4 = value5, value6, value7
            end
        end
        if value4 < 0.5 then
            value2, value3, value4 = 1, 0, 1
        end
        argument = value + (config.champMidRing or 2)
        return Vector3.new(
            vector2.X + value2 / value4 * argument,
            vector.Y,
            vector2.Z + value3 / value4 * argument
        ),
            true
    end
    context.champRingStep = function(argument, vector)
        local vector2, value = context.champMid()
        if vector2 then
            if argument then
                if not vector then
                    return nil
                end
            else
                return nil
            end
        else
            return nil
        end
        local value2, value3 = vector.X - argument.X, vector.Z - argument.Z
        local value4 = value2 * value2 + value3 * value3
        local value5 = if value4 > 0.01
            then math.clamp(
                ((vector2.X - argument.X) * value2 + (vector2.Z - argument.Z) * value3) / value4,
                0,
                1
            )
            else 0
        local value6, value7 =
            argument.X + value2 * value5 - vector2.X, argument.Z + value3 * value5 - vector2.Z
        if value6 * value6 + value7 * value7 >= value * value then
            return nil
        end
        value7, value4, value2, value3 =
            atan2(argument.Z - vector2.Z, argument.X - vector2.X),
            vector.X - vector2.X,
            vector.Z - vector2.Z,
            config.champMidAimR or 20
        value6, argument =
            (
                (value4 * value4 + value2 * value2 >= value3 * value3 and atan2(value2, value4) or value7)
                - value7
                + 3.141592653589793
            )
                    % 6.283185307179586
                - 3.141592653589793,
            toRadians(config.champMidStepDeg or 20)
        value6 = if value6 > argument then argument else if value6 < -argument then -argument else value6
        value4 = value + (config.champMidRing or 2)
        return Vector3.new(
            vector2.X + cos(value7 + value6) * value4,
            vector.Y,
            vector2.Z + sin(value7 + value6) * value4
        )
    end
    local function helper8(argument, argument2, argument3)
        return argument.slim and min(argument2, argument.slim + (argument3 or 0)) or argument2
    end
    local function helper9(argument, argument2, argument3)
        local value = helper8(argument, argument2, argument3)
        if argument.tight then
            return value
        end
        return max(value, config.bubbleBreachFloor or 3.5)
    end
    local function helper10(zone, argument, argument2)
        if zone.moving then
            local value, value2 = argument - zone.ox, argument2 - zone.oz
            local value3 = -value * zone.dz + value2 * zone.dx >= 0 and 1 or -1
            return -zone.dz * value3, zone.dx * value3
        end
        local value4, value5 = argument - zone.cx, argument2 - zone.cz
        if zone.r then
            argument2 = sqrt(value4 * value4 + value5 * value5)
            if argument2 < 0.5 then
                return 1, 0
            end
            local value6, value7 = value4 / argument2, value5 / argument2
            if zone.ring then
                if zone.r - argument2 > argument2 - zone.ring then
                    return -value6, -value7
                end
            end
            return value6, value7
        end
        local value8, value9 = value4 * zone.ax + value5 * zone.az, value4 * zone.bx + value5 * zone.bz
        if zone.ha - abs(value8) <= zone.hb - abs(value9) then
            argument = value8 >= 0 and 1 or -1
            return zone.ax * argument, zone.az * argument
        end
        value8 = value9 >= 0 and 1 or -1
        return zone.bx * value8, zone.bz * value8
    end
    bubbleBoss.spikeTimeAt = function(argument, argument2, argument3)
        local line = argument.line
        if line then
            if line.launch then
                if line.speed then
                    if line.speed > 0 then
                        if line.ox then
                            if not line.ux then
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
        local value, value2 = argument2 - line.ox, argument3 - line.oz
        argument3, argument2, argument =
            value * line.ux + value2 * line.uz,
            abs(-value * line.uz + value2 * line.ux),
            (line.halfW or 10) + (dangerGeometry.reach or 1.8) + (config.oldLineMargin or 1.5)
        if argument2 > argument then
            return nil
        elseif argument3 < -argument then
            return nil
        elseif argument3 > (line.len or 0) + argument then
            return nil
        end
        return line.launch + max(min(argument3, line.len or argument3), 0) / line.speed
    end
    bubbleBoss.oldLineAt = function(argument, argument2, argument3, argument4, argument5, argument6)
        if config.oldLineFirst == false then
            return nil
        end
        local lineBoxes = bubbleBoss.lineBoxes
        if lineBoxes then
            if #lineBoxes == 0 then
                return nil
            end
        else
            return nil
        end
        local value = (runtimeState.dataPingS or 0.06) + (config.oldLineSlack or 0.15)
        for index = 1, #lineBoxes, 1 do
            local value2 = lineBoxes[index]
            if (value2.untilAt or infinity) > argument3 then
                if not (argument5 and bubbleBoss.spikeTimeAt(value2, argument5, argument6)) then
                    index = bubbleBoss.spikeTimeAt(value2, argument, argument2)
                    if index then
                        local value3 = ((value2.line.halfW or 10) + (dangerGeometry.reach or 1.8))
                                / value2.line.speed
                            + value
                        if index + value3 >= argument3 then
                            if index - value3 <= argument3 + (argument4 or 0) then
                                return value2, index
                            end
                        end
                    end
                end
            end
        end
        return nil
    end
    bubbleBoss.oldLineCut = function(
        argument,
        argument2,
        argument3,
        argument4,
        argument5,
        argument6,
        argument7
    )
        if config.oldLineFirst == false then
            return argument5, false
        elseif bubbleBoss.lineBoxes then
            if not (#bubbleBoss.lineBoxes > 0) then
                return argument5, false
            end
        else
            return argument5, false
        end
        local value, value2, value3 = max(argument6 or 16, 4), config.oldLineHold or 0.6, 2
        while value3 <= argument5 do
            if
                bubbleBoss.oldLineAt(
                    argument + argument3 * value3,
                    argument2 + argument4 * value3,
                    argument7 + value3 / value,
                    value3 + 2 > argument5 and value2 or 0,
                    argument,
                    argument2
                )
            then
                argument6 = value3 - 2
                if argument6 >= 3 then
                    if
                        not (
                            bubbleBoss.oldLineAt(
                                argument + argument3 * argument6,
                                argument2 + argument4 * argument6,
                                argument7 + argument6 / value,
                                value2,
                                argument,
                                argument2
                            )
                        )
                    then
                        return argument6, false
                    end
                end
                return argument5, true
            end
            value3 += 2
        end
        return argument5, false
    end
    local function helper11(argument)
        if not argument.kind then
            if not argument.bubbleKeep then
                return 0
            end
        end
        return argument.weight or 1
    end
    local function helper12(argument)
        return argument.bubbleKeep == true and argument.kind == nil
    end
    local sharedValue16 = false
    local function helper13(argument, argument2, argument3)
        if hazardReader.noGoArmed then
            if hazardReader.noGoZones then
                if not depthOf then
                    return false
                end
            else
                return false
            end
        else
            return false
        end
        for index = 1, #hazardReader.noGoZones, 1 do
            local value = hazardReader.noGoZones[index]
            if value.cx then
                index = depthOf(value, argument, argument2, argument3, 2)
                if index then
                    if index >= 0 then
                        return true
                    end
                end
            end
        end
        return false
    end
    local function helper14(argument)
        local value = helper11(argument)
        if value < (config.bubbleMinWeight or 0.25) then
            return 0, value
        end
        if argument.noGo then
            if sharedValue16 then
                return 2, math.min(value, config.noGoFleeWeight or 0.35)
            end
        end
        if helper12(argument) then
            return 1, value
        end
        if value >= (config.bubbleHardAt or 1) then
            return 3, value
        end
        return 2, value
    end
    local sharedValue17, sharedValue18 = {}, 0
    local function helper15(argument)
        argument = math.clamp(math.floor(argument or 24), 8, 48)
        if argument == sharedValue18 then
            return
        end
        sharedValue18 = argument
        for index = #sharedValue17, 1, -1 do
            sharedValue17[index] = nil
        end
        for index2 = 0, argument - 1, 1 do
            sharedValue17[index2 + 1] = index2 * (360 / argument)
        end
    end
    helper15(24)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.RespectCanCollide = true
    bubbleBoss.slamBlend = function(argument, vector, argument2)
        if config.slamBlend == false then
            return nil
        end
        local value = runtimeState.reflex
        if value then
            if value.name == "slam" then
                if value.from then
                    if value.radius then
                        if argument > (value.untilAt or 0) then
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
        local value2, value3 = vector.X, vector.Z
        if argument2 then
            if argument2.point then
                if not argument2.soft then
                    local value4, value5 = argument2.point.X - value.from.X, argument2.point.Z - value.from.Z
                    if value4 * value4 + value5 * value5 >= value.radius * value.radius then
                        return nil
                    end
                end
            end
        end
        local value6, value7 = value2 - value.from.X, value3 - value.from.Z
        local value8, value9 = sqrt(value6 * value6 + value7 * value7), dangerGeometry.reach or 1.8
        local value10, value11 = value.radius - value8, dangerGeometry.boxes or {}
        for index = 1, #value11, 1 do
            argument2 = value11[index]
            if
                argument2.name == "firstbossjumpslam"
                and argument2.r
                and argument2.cx
                and not argument2.moving
            then
                local value12, value13 = value2 - argument2.cx, value3 - argument2.cz
                value10 = argument2.r
                    + value9
                    + (config.slamBlendSpare or 2)
                    - sqrt(value12 * value12 + value13 * value13)
                break
            end
        end
        if value10 <= 0 then
            return nil
        end
        argument2, value11 = nil
        if value.dir and (value.dir.X ~= 0 or value.dir.Z ~= 0) then
            argument2, value11 = value.dir.X, value.dir.Z
        else
            if value8 > 0.5 then
                argument2, value11 = value6 / value8, value7 / value8
            else
                return nil
            end
        end
        local value14, value15, value16, value17, value18 = bubbleBoss.threats or {}, 0, 0, 0
        for index2 = 1, #value14, 1 do
            value7 = value14[index2]
            value6 = value7.box
            if value6 and (value7.hard or value7.rank == 1) then
                if not (string.lower(tostring(value6.name or "")):find("slam", 1, true)) then
                    index2, value8 = helper10(value6, value2, value3)
                    local value19 = (value7.hard and 1 or (config.slamBlendWarm or 0.5))
                        * (max(value7.depth or 0, 0) + value9 + 1)
                    local value20, value21, value22 =
                        value15 + index2 * value19, value16 + value8 * value19, value17 + 1
                    value18 = value18 or tostring(value6.name or "?")
                    value15, value16, value17 = value20, value21, value22
                end
            end
        end
        if value17 == 0 then
            return nil
        end
        value14, value8 = argument2 * value10 + value15, value11 * value10 + value16
        if
            sqrt(value14 * value14 + value8 * value8)
            < (config.slamBlendMin or 0.35) * max(value10, sqrt(value15 * value15 + value16 * value16))
        then
            return nil
        end
        local value23, value24, value25, value26 =
            atan2(value8, value14),
            atan2(value11, argument2),
            config.slamBurstMax or config.burstMax or 28,
            value.startedAt and not value.pre and (config.slamLandAt or 1.98) - (argument - value.startedAt)
                or infinity
        for index3 = 0, 12, 1 do
            value14, value7, argument =
                cos(value23),
                sin(value23),
                abs((value23 - value24 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793)
            if index3 > 0 then
                if argument < toRadians(1) then
                    return nil
                end
            end
            value8 = value14 * argument2 + value7 * value11
            if
                value8 > 0.05
                and (
                    value26 == infinity
                    or value10 / value8 / value25 <= value26 - (runtimeState.dataPingS or 0.06)
                )
            then
                value9 = parent:Raycast(
                    vector + Vector3.new(0, 2, 0),
                    Vector3.new(value14, 0, value7) * 40,
                    raycastParams
                )
                value = value9 and value9.Distance or 40
                if value >= 8 then
                    value6 = min(config.slamBlendStep or 14, value - 3)
                    local value27 = Vector3.new(value2 + value14 * value6, vector.Y, value3 + value7 * value6)
                    if not (bubbleBoss.pathBlocked and bubbleBoss.pathBlocked(vector, value27, value25)) then
                        local value28, value29 = value17 + 1, math.floor(toDegrees(argument) + 0.5)
                        return value27,
                            ("SLAM + %s: both at once - %d ways out added up, %d deg off the slam's%s, %.0f to go"):format(
                                value18,
                                value28,
                                value29,
                                index3 > 0 and (" (turned %d deg toward it)"):format(index3 * 15) or "",
                                value10
                            )
                    end
                end
            end
            index3 = (value24 - value23 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
            if abs(index3) < 0.001 then
                return nil
            end
            value23 += if index3 > toRadians(15)
                then toRadians(15)
                else if index3 < -toRadians(15) then -toRadians(15) else index3
        end
        return nil
    end
    local sharedValue19, sharedValue20, sharedValue21
    local sharedValue22 = {}
    local function helper16()
        local folder = bubbleBoss.folder
        if if folder then not bubbleBoss.folder.Parent else not folder then
            local dqBubble = Instance.new("Folder")
            dqBubble.Name = "DQBubble"
            dqBubble.Parent = parent
            bubbleBoss.folder = dqBubble
        end
        return bubbleBoss.folder
    end
    local function helper17(argument)
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.CastShadow = false
        part.Material, part.Shape = Enum.Material.SmoothPlastic, argument or Enum.PartType.Block
        part.Parent = helper16()
        return part
    end
    local function helper18(argument)
        for index = argument, #sharedValue22, 1 do
            local value = sharedValue22[index]
            if value then
                if value.Parent then
                    value.Transparency = 1
                end
            end
        end
    end
    local function helper19()
        if sharedValue19 then
            sharedValue19:Destroy()
            sharedValue19 = nil
        end
        if sharedValue20 then
            sharedValue20:Destroy()
            sharedValue20 = nil
        end
        if sharedValue21 then
            sharedValue21:Destroy()
            sharedValue21 = nil
        end
        helper18(1)
    end
    local function helper20(vector, box, argument)
        if context.NOVIS then
            helper19()
            return
        elseif config.drawBubble then
            if config.visuals == false then
                helper19()
                return
            end
        else
            helper19()
            return
        end
        if if sharedValue19 then not sharedValue19.Parent else not sharedValue19 then
            sharedValue19 = helper17(Enum.PartType.Cylinder)
        end
        if if sharedValue20 then not sharedValue20.Parent else not sharedValue20 then
            sharedValue20 = helper17(Enum.PartType.Cylinder)
        end
        local color, transparency =
            bubbleBoss.active and (bubbleBoss.lethal and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(
                255,
                190,
                60
            )) or Color3.fromRGB(70, 230, 130),
            sharedValue19
        transparency.Size = Vector3.new(0.25, box * 2, box * 2)
        transparency = sharedValue19
        transparency.CFrame = CFrame.new(vector.X, vector.Y - argument + 0.2, vector.Z)
            * CFrame.Angles(0, 0, toRadians(90))
        local value, value2, transparency2 = sharedValue19, sharedValue19, bubbleBoss.active and 0.35 or 0.6
        value.Color = color
        value2.Transparency = transparency2
        transparency = sharedValue20
        transparency.Size = Vector3.new(5, box * 2, box * 2)
        transparency2 = sharedValue20
        transparency2.CFrame = CFrame.new(vector.X, vector.Y - argument + 2.5, vector.Z)
            * CFrame.Angles(0, 0, toRadians(90))
        transparency2, value2, transparency = sharedValue20, sharedValue20, bubbleBoss.active and 0.82 or 0.9
        transparency2.Color = color
        value2.Transparency = transparency
        color = bubbleBoss.primary
        if color and color.box then
            if sharedValue21 then
                if not sharedValue21.Parent then
                    sharedValue21 = helper17()
                end
            else
                sharedValue21 = helper17()
            end
            box = color.box
            value, value2 = box.moving and box.ox or box.cx, box.moving and box.oz or box.cz
            transparency2, transparency = value - vector.X, value2 - vector.Z
            local value3, value4 =
                max(sqrt(transparency2 * transparency2 + transparency * transparency), 0.5), sharedValue21
            value4.Size = Vector3.new(0.35, 0.35, value3)
            value3 = sharedValue21
            value3.CFrame = CFrame.lookAt(
                Vector3.new(
                    vector.X + transparency2 * 0.5,
                    vector.Y - argument + 1.2,
                    vector.Z + transparency * 0.5
                ),
                Vector3.new(value, vector.Y - argument + 1.2, value2)
            )
            value4, value3 = sharedValue21, sharedValue21
            value4.Color = Color3.fromRGB(255, 170, 40)
            value3.Transparency = 0.25
        elseif sharedValue21 then
            sharedValue21:Destroy()
            sharedValue21 = nil
        end
    end
    local function helper21(argument, argument2, argument3)
        if context.NOVIS or not config.drawBubble or config.visuals == false then
            helper18(1)
            return
        elseif (config.bubbleTrajLead or 0) <= 0 then
            helper18(1)
            return
        end
        local value, value2 = min(argument2, 24), 0
        for index = 1, value, 1 do
            argument2 = argument[index]
            local value3, value4, value5 = argument2.cx, argument2.cz, false
            if argument2.moving then
                value5 = (argument2.from or 0) > sharedValue2
                local value6, speed, value7 = argument2.offset or 0, argument2.speed, sharedValue2
                index = value6 + speed * max(value7 - (argument2.pathStart or sharedValue2), 0)
                value3, value4 = argument2.ox + argument2.dx * index, argument2.oz + argument2.dz * index
            end
            if value3 then
                local value8, value9 = velocityOf(argument2, sharedValue2)
                local value10 = sqrt(value8 * value8 + value9 * value9)
                if value10 > 2 then
                    if not argument2.noLane then
                        local value11, value12 = value10 * config.bubbleTrajLead, value2 + 1
                        local value13 = sharedValue22[value12]
                        if value13 then
                            if not value13.Parent then
                                local value14 = helper17()
                                sharedValue22[value12] = value14
                                value13 = value14
                            end
                        else
                            local value15 = helper17()
                            sharedValue22[value12] = value15
                            value13 = value15
                        end
                        local value16 = argument2.halfW and (argument2.halfW - (argument2.pad or 0)) * 2
                            or (argument2.slim and max(argument2.slim * 2, 4) or 6)
                        value13.Size = Vector3.new(min(max(value16, 2), 40), 0.3, value11)
                        value16 = Vector3.new(
                            value3 + value8 / value10 * value11 * 0.5,
                            argument3,
                            value4 + value9 / value10 * value11 * 0.5
                        )
                        value13.CFrame = CFrame.lookAt(
                            value16,
                            value16 + Vector3.new(value8 / value10, 0, value9 / value10)
                        )
                        value13.Color = value5 and Color3.fromRGB(255, 225, 90)
                            or Color3.fromRGB(255, 150, 40)
                        value13.Transparency = value5 and 0.8 or 0.72
                        value2 = value12
                    end
                end
            end
        end
        if config.drawBlueBeams ~= false and bubbleBoss.blueBeams then
            argument = bubbleBoss.blueBeams()
            for index2 = 1, #argument, 1 do
                if value2 >= 80 then
                    break
                end
                value = argument[index2]
                index2 = max(value.dL or value.L, 0.5)
                if value.cone then
                    local value17, value18 = math.atan(value.cone), config.orbConeStrips or 7
                    for index3 = 0, value18 - 1, 1 do
                        if value2 >= 80 then
                            break
                        end
                        local value19 = -value17 + 2 * value17 * index3 / max(value18 - 1, 1)
                        local value20, gearProfiles = math.cos(value19), math.sin(value19)
                        index3, value19 =
                            value.ux * value20 - value.uz * gearProfiles,
                            value.ux * gearProfiles + value.uz * value20
                        value2 += 1
                        value20 = sharedValue22[value2]
                        if value20 then
                            if not value20.Parent then
                                gearProfiles = helper17()
                                sharedValue22[value2] = gearProfiles
                                value20 = gearProfiles
                            end
                        else
                            local gearProfiles2 = helper17()
                            sharedValue22[value2] = gearProfiles2
                            value20 = gearProfiles2
                        end
                        value20.Size = Vector3.new(max(value.vw * 2, 2), 0.3, index2)
                        gearProfiles = Vector3.new(
                            value.ox + index3 * index2 * 0.5,
                            argument3,
                            value.oz + value19 * index2 * 0.5
                        )
                        value20.CFrame =
                            CFrame.lookAt(gearProfiles, gearProfiles + Vector3.new(index3, 0, value19))
                        value20.Color = Color3.fromRGB(255, 225, 90)
                        value20.Transparency = 0.82
                    end
                else
                    value2 += 1
                    local value21 = sharedValue22[value2]
                    if value21 then
                        if not value21.Parent then
                            local gearProfiles3 = helper17()
                            sharedValue22[value2] = gearProfiles3
                            value21 = gearProfiles3
                        end
                    else
                        local gearProfiles4 = helper17()
                        sharedValue22[value2] = gearProfiles4
                        value21 = gearProfiles4
                    end
                    value21.Size = Vector3.new(max(value.vw * 2, 2), 0.3, index2)
                    local value22 = Vector3.new(
                        value.ox + value.ux * index2 * 0.5,
                        argument3,
                        value.oz + value.uz * index2 * 0.5
                    )
                    value21.CFrame = CFrame.lookAt(value22, value22 + Vector3.new(value.ux, 0, value.uz))
                    value21.Color = Color3.fromRGB(255, 225, 90)
                    value21.Transparency = 0.7
                end
            end
        end
        helper18(value2 + 1)
    end
    bubbleBoss.tick = function(argument, point, argument2, argument3)
        local value = {}
        value[34] = {}
        argumentHelpers:appendPackedValues(value[34], 0, argumentHelpers[108](os.clock()))
        value[1] = value[34][1]
        bubbleBoss.scanNodes = bubbleBoss.scanNodes or {}
        bubbleBoss.softAt = nil
        sharedValue2 = argument
        argument3 = bubbleBoss.oscW
        if not argument3 then
            argument3 = { pts = {}, at = -infinity }
            bubbleBoss.oscW = argument3
        end
        if argument - argument3.at >= 0.15 then
            argument3.at = argument
            local pts = argument3.pts
            pts[#pts + 1] = { x = point.X, z = point.Z, t = argument }
            while #pts > 0 and argument - pts[1].t > (config.oscWindow or 3) do
                table.remove(pts, 1)
            end
            if config.oscBreak ~= false and #pts >= 10 and not bubbleBoss.osc then
                local value2, value3, value4 = 0
                local value5, value6, value7 = 0, 0, 0
                for index = 3, #pts, 2 do
                    local value8, value9 = pts[index].x - pts[index - 2].x, pts[index].z - pts[index - 2].z
                    index = sqrt(value8 * value8 + value9 * value9)
                    value2 += index
                    if index > 1.5 then
                        value8 /= index
                        value9 /= index
                        value5 = if value3
                            then if value8 * value3 + value9 * value4 < -0.5 then value5 + 1 else value5
                            else value5
                        local value10, value11 = value8, value9
                        if value6 * value8 + value7 * value9 < 0 then
                            value8, value9 = -value10, -value11
                        else
                            value8, value9 = value10, value11
                        end
                        value3, value4, value6, value7 =
                            value10, value11, value6 + value8 * index, value7 + value9 * index
                    end
                end
                local value12, value13 =
                    sqrt((pts[#pts].x - pts[1].x) ^ 2 + (pts[#pts].z - pts[1].z) ^ 2),
                    sqrt(value6 * value6 + value7 * value7)
                if value5 >= (config.oscFlips or 2) then
                    if value2 > (config.oscPath or 20) then
                        if value12 < (config.oscNet or 8) then
                            if value13 > 1 then
                                bubbleBoss.osc = {
                                    ax = value6 / value13,
                                    az = value7 / value13,
                                    untilAt = argument + (config.oscFor or 2.5),
                                    at = argument,
                                }
                                bubbleBoss.oscCount = (bubbleBoss.oscCount or 0) + 1
                                bubbleBoss.dGoal = nil
                                bubbleBoss.flipDetour = true
                                if context.logT then
                                    pcall(
                                        context.logT,
                                        "bubble",
                                        2,
                                        "Bubble",
                                        ("oscillating: %d flips over %.0f studs for %.0f gained - going another way"):format(
                                            value5,
                                            value2,
                                            value12
                                        )
                                    )
                                end
                            end
                        end
                    end
                end
            end
        end
        if bubbleBoss.osc then
            if argument >= bubbleBoss.osc.untilAt then
                bubbleBoss.osc = nil
                argument3.pts = {}
            end
        end
        value[35] = {}
        argumentHelpers:appendValues(value[35], 0, config.bubbleRadius)
        value[35].n = 1
        value[2] = value[35][1]
        value[36] = {}
        argumentHelpers:appendValues(value[36], 0, config.bubbleLookahead)
        value[36].n = 1
        value[3] = value[36][1]
        value[37] = {}
        value[38] = dangerGeometry.halfHeight or 4
        argumentHelpers:appendValues(value[37], 0, value[38])
        value[37].n = 1
        value[4] = value[37][1]
        value[39] = {}
        argumentHelpers:appendValues(value[39], 0, point.X)
        value[39].n = 1
        value[5] = value[39][1]
        value[40] = {}
        argumentHelpers:appendValues(value[40], 0, point.Y)
        value[40].n = 1
        value[6] = value[40][1]
        value[41] = {}
        argumentHelpers:appendValues(value[41], 0, point.Z)
        value[41].n = 1
        value[7] = value[41][1]
        value[42] = {}
        value[43] = dangerGeometry.boxes or {}
        argumentHelpers:appendValues(value[42], 0, value[43])
        value[44] = bubbleBoss.lineBoxes or {}
        argumentHelpers:appendValues(value[42], 1, value[44], 0)
        value[42].n = 3
        value[8], value[9], value[10] = value[42][1], value[42][2], value[42][3]
        for index2 = 1, #value[8], 1 do
            value[45] = index2
            argument3 = value[8][value[45]]
            if argument3.line and argument3.line.launch then
                if argument3.line.speed then
                    index2 = value[10] + 1
                    value[9][index2] = argument3
                    value[10] = index2
                end
            end
        end
        for index3 = value[10] + 1, #value[9], 1 do
            value[9][index3] = nil
        end
        value[46] = bubbleBoss
        value[46].lineBoxes = value[9]
        value[9] = bubbleBoss.threats
        for index4 = #value[9], 1, -1 do
            value[9][index4] = nil
        end
        value[47] = {}
        value[48] = dangerGeometry.lag or 0
        argumentHelpers:appendValues(value[47], 0, value[48])
        value[47].n = 1
        value[11] = value[47][1]
        value[49] = {}
        argumentHelpers:appendValues(value[49], 0, bubbleBoss.rel, 0)
        value[49].n = 2
        value[12], value[13] = value[49][1], value[49][2]
        value[50] = {}
        argumentHelpers:appendValues(value[50], 0, bubbleBoss.soft, 0)
        value[50].n = 2
        value[14], value[15] = value[50][1], value[50][2]
        value[51] = {}
        argumentHelpers:appendValues(value[51], 0, bubbleBoss.pend, 0)
        value[51].n = 2
        value[16], value[17] = value[51][1], value[51][2]
        value[52] = {}
        argumentHelpers:appendValues(value[52], 0, bubbleBoss.mov, 0)
        value[52].n = 2
        value[18], value[19] = value[52][1], value[52][2]
        value[53] = {}
        value[54] = config.bubbleWarnLead or 1.5
        argumentHelpers:appendValues(value[53], 0, value[54])
        value[53].n = 1
        value[20] = value[53][1]
        value[55] = {}
        value[56] = config.rodinSpiralOneObject ~= false
            and config.rodinSpiralDodgerOff ~= false
            and hazardReader.rodinRig ~= nil
            and hazardReader.rodinRig.Parent ~= nil
            and not (context.colourAttackLive and context.colourAttackLive(argument))
        argumentHelpers:appendValues(value[55], 0, value[56])
        value[57] = #value[8]
        argumentHelpers:appendValues(value[55], 1, value[57])
        value[55].n = 2
        value[21], value[22] = value[55][1], value[55][2]
        value[58] = {}
        argumentHelpers:appendValues(value[58], 0, 0, 0)
        value[58].n = 2
        value[23], value[24] = value[58][1], value[58][2]
        for index5 = 1, value[22], 1 do
            value[59] = index5
            argument3 = value[8][value[59]]
            local value14, value15 = helper14(argument3)
            value14 = if value[21]
                    and value14 > 0
                    and context.isSpiralBox
                then if context.isSpiralBox(argument3) then 0 else value14
                else value14
            if value14 > 0 then
                local value16, value17 =
                    argument3.moving and argument3.ox or argument3.cx,
                    argument3.moving and argument3.oz or argument3.cz
                local depth, value18, value19 =
                    value16 ~= nil and (value16 - value[5]) ^ 2 + (value17 - value[7]) ^ 2 < 40000,
                    velocityOf(argument3, argument)
                if argument3.bounces then
                    if argument3.moving then
                        if argument - (argument3.freeAt or 0) > 0.2 then
                            argument3.freeAt = argument
                            raycastParams.FilterDescendantsInstances =
                                { sharedValue.LocalPlayer.Character, bubbleBoss.folder }
                            value16 = parent:Raycast(
                                Vector3.new(argument3.ox, argument3.oy, argument3.oz),
                                Vector3.new(argument3.dx, 0, argument3.dz) * 260,
                                raycastParams
                            )
                            argument3.freeAhead = value16
                                    and max(value16.Distance - (argument3.halfL or 6), 0)
                                or nil
                        end
                    end
                end
                value17 = (helper9(argument3, value[2], value[11]))
                index5 = (argument3.from or 0) - argument
                value16 = argument3.warn == true
                    and value14 >= 2
                    and index5 > (config.bubbleLead or 0)
                    and index5 <= value[20]
                if depth then
                    if value14 == 3 and not value16 then
                        value[60] = 1
                        value[13] = value[13] + value[60]
                        value[12][value[13]] = argument3
                    else
                        if value16 then
                            value[61] = 1
                            value[17] = value[17] + value[61]
                            value[16][value[17]] = argument3
                        else
                            value[62] = 1
                            value[15] = value[15] + value[62]
                            value[14][value[15]] = argument3
                        end
                    end
                    if
                        (value14 == 3 or value16)
                        and not argument3.noFlee
                        and (argument3.moving or value18 * value18 + value19 * value19 > 9)
                    then
                        value[63] = 1
                        value[19] = value[19] + value[63]
                        value[18][value[19]] = argument3
                    end
                end
                if value16 then
                    value[65] = helper6
                    value[66] = argument3
                    value[67] = value[5]
                    value[68] = value[6]
                    value[69] = value[7]
                    value[70] = value[4]
                    value[64] = value[3]
                    depth = (
                        value[65](
                            value[66],
                            value[67],
                            value[68],
                            value[69],
                            value[70],
                            value[20] + value[64]
                        )
                    )
                    if depth then
                        if depth >= -value17 then
                            local value20, value21, value22 =
                                value[23] + 1, #value[9] + 1, {
                                    box = argument3,
                                    w = value15,
                                    hard = false,
                                    rank = 2,
                                    tti = index5,
                                    depth = depth,
                                }
                            value[71] = value15 * (1 / (index5 + 0.15)) * (1 + max(depth, 0) / value17)
                            value22.score = value[71]
                            value[9][value21] = value22
                            value[23] = value20
                        end
                    end
                else
                    if value14 >= 2 then
                        if not argument3.noFlee then
                            local value23 = argument3.moving or value18 * value18 + value19 * value19 > 4
                            local value24 = value23 and max(value[3], config.bubbleTrajLead or 0) or 0
                            value24 = if argument3.kind == "wall"
                                then if value24 > (config.wallLead or 1.2)
                                    then config.wallLead or 1.2
                                    else value24
                                else value24
                            local hard, tti, depth2 = value23 and math.clamp(math.ceil(value24 / 0.15), 4, 12)
                                or 0
                            for index6 = 0, hard, 1 do
                                value23 = hard > 0 and value24 * index6 / hard or 0
                                index6 = (
                                    helper3(
                                        argument3,
                                        value[5],
                                        value[6],
                                        value[7],
                                        argument + value23,
                                        value[4],
                                        config.bubbleLead
                                    )
                                )
                                if index6 then
                                    if index6 >= -value17 then
                                        tti, depth2 = value23, index6
                                        break
                                    end
                                end
                            end
                            if tti then
                                hard = value14 == 3
                                value[24] = if hard then value[24] else value[24] + 1
                                value23 = nil
                                if argument3.line then
                                    if config.oldLineFirst ~= false then
                                        local value25 = bubbleBoss.spikeTimeAt(argument3, value[5], value[7])
                                        if value25 then
                                            local value26 = (
                                                (argument3.line.halfW or 10) + (dangerGeometry.reach or 1.8)
                                            )
                                                    / max(argument3.line.speed or 80, 1)
                                                + (runtimeState.dataPingS or 0.06)
                                            value23 = value25 + value26 >= argument
                                                    and max(value25 - value26 - argument, 0)
                                                or (config.oldLinePassedTti or 9)
                                        else
                                            value23 = tti
                                        end
                                    else
                                        value23 = tti
                                    end
                                else
                                    value23 = tti
                                end
                                local value27, value28 =
                                    #value[9] + 1, {
                                        box = argument3,
                                        w = value15,
                                        hard = hard,
                                        rank = hard and 0 or 1,
                                        tti = tti,
                                        depth = depth2,
                                    }
                                value[72] = value15 * (1 / (value23 + 0.15)) * (1 + max(depth2, 0) / value17)
                                value28.score = value[72]
                                value[9][value27] = value28
                            end
                        end
                    end
                end
            end
        end
        for index7 = value[13] + 1, #value[12], 1 do
            value[12][index7] = nil
        end
        for index8 = value[15] + 1, #value[14], 1 do
            value[14][index8] = nil
        end
        for index9 = value[17] + 1, #value[16], 1 do
            value[16][index9] = nil
        end
        for index10 = value[19] + 1, #value[18], 1 do
            value[18][index10] = nil
        end
        value[25] = function(argument4)
            return argument4 and (argument4.r or max(argument4.halfW or 0, argument4.halfL or 0)) or 0
        end
        value[73] = {}
        value[74] = config.bubbleOnNow or 0.05
        argumentHelpers:appendValues(value[73], 0, value[74])
        value[73].n = 1
        value[26] = value[73][1]
        table.sort(value[9], function(argument4, argument5)
            if argument4.rank ~= argument5.rank then
                return argument4.rank < argument5.rank
            end
            local value29, value30 = (argument4.tti or 1) <= value[26], (argument5.tti or 1) <= value[26]
            if value29 ~= value30 then
                return value29
            end
            if value29 then
                if value30 then
                    if not (config.oldLineFirst ~= false and argument4.box.line and argument5.box.line) then
                        local value31, value32 = value[25](argument4.box), value[25](argument5.box)
                        if abs(value31 - value32) > (config.bubbleSizeTie or 2) then
                            return value31 > value32
                        end
                    end
                end
            end
            return argument4.score > argument5.score
        end)
        value[75] = bubbleBoss
        value[76] = #value[9]
        value[75].count = value[76]
        value[77] = bubbleBoss
        value[77].warmCount = value[24]
        value[78] = bubbleBoss
        value[78].warnCount = value[23]
        sharedValue16 = false
        if #value[9] > 0 then
            bubbleBoss.lastBreach = argument
            if not bubbleBoss.active then
                value[8] = bubbleBoss.dir ~= nil
                    and argument - (bubbleBoss.dirAt or 0) < (config.bubbleDirMemory or 5)
                bubbleBoss.active, bubbleBoss.escapes = true, bubbleBoss.escapes + 1
                if value[8] then
                    bubbleBoss.dirAt = argument
                else
                    bubbleBoss.dir = nil
                    bubbleBoss.anchor = nil
                end
            end
            value[79] = bubbleBoss
            value[80] = value[9][1]
            value[79].primary = value[80]
            value[81] = bubbleBoss
            value[82] = value[9][1].hard
            value[81].lethal = value[82]
            argument3 = 0
            for index11 = 1, #value[9], 1 do
                value[86] = nil
                value[83] = index11
                if value[9][value[83]].hard then
                    value[85] = nil
                    value[84] = index11
                    if (value[9][value[84]].tti or 0) <= (config.unionTti or 1.5) then
                        value[85] = argument3 + 1
                    else
                        value[85] = argument3
                    end
                    value[86] = value[85]
                else
                    value[86] = argument3
                end
                argument3 = value[86]
            end
            bubbleBoss.union = config.unionAsOne ~= false and argument3 >= 2
            if bubbleBoss.lethal then
                bubbleBoss.lethalAt = argument
            end
            value[21] = config.noGoSlamFree ~= false
                and (
                    runtimeState.reflex ~= nil and runtimeState.reflex.name == "slam"
                    or runtimeState.tellRun ~= nil
                )
            value[21] = bubbleBoss.lethal == true or value[21]
            value[87] = value[21]
                and not (bubbleBoss.primary.box ~= nil and bubbleBoss.primary.box.noGo == true)
            sharedValue16 = value[87]
        elseif bubbleBoss.active then
            bubbleBoss.primary = nil
            bubbleBoss.lethal = false
            bubbleBoss.goal = nil
            if argument - bubbleBoss.lastBreach > config.bubbleSettle then
                bubbleBoss.active = false
                bubbleBoss.dir = nil
                bubbleBoss.anchor = nil
            end
        end
        helper20(point, value[2], dangerGeometry.feet or 3)
        value[89] = helper21
        value[90] = value[18]
        value[91] = value[19]
        value[88] = (dangerGeometry.feet or 3)
        value[89](value[90], value[91], value[6] - value[88] + 0.3)
        value[92] = {}
        argumentHelpers:appendValues(value[92], 0, false)
        value[92].n = 1
        value[27], value[28] = value[92][1], value[92][2]
        if config.bobOrbSolid ~= false and hazardReader.orbScan then
            value[21] = bubbleBoss.bobOrbs or {}
            value[22] = {}
            argument3 = 0
            for index12, entry in ipairs(hazardReader.orbScan) do
                index12 = entry.part
                if index12 and index12.Parent then
                    value[93] = index12
                    if not value[22][value[93]] then
                        value[22][index12] = true
                        value[8] = index12.Position
                        if
                            (value[8].X - value[5]) ^ 2 + (value[8].Z - value[7]) ^ 2
                            < (config.bobOrbNear or 90) ^ 2
                        then
                            local value33, value34 = hazardReader.parts[index12], argument3 + 1
                            value[94] = value34
                            local value35 = value[21][value[94]] or {}
                            value[21][value34] = value35
                            value[95] = value[8].X
                            value[96] = value[8].Z
                            value35.x = value[95]
                            value35.z = value[96]
                            value35.vx, value35.vz = value33 and value33.vx or 0, value33 and value33.vz or 0
                            value35.homing = value33 == nil
                                or value33.owner == nil
                                or value33.owner == "me"
                                or entry.mine == true
                            local mine = entry.mine
                            value35.keep = (if mine then not mine else context.bobOrbTheirs)
                                    and context.bobOrbTheirs(index12, value33)
                                    and context.bobOrbBody(index12, config.bobOrbOtherKeep or 3)
                                or nil
                            value35.colour = string.lower(index12.Name):match("secondboss(%a+)orb")
                            argument3 = value34
                        end
                    end
                end
            end
            for index13 = argument3 + 1, #value[21], 1 do
                value[21][index13] = nil
            end
            value[27] = argument3 > 0
            value[97] = bubbleBoss
            value[97].bobOrbs = value[21]
            value[28] = value[27]
        else
            value[28] = value[27]
        end
        value[98] = {}
        value[99] = config.bubbleLead or 0.35
        argumentHelpers:appendValues(value[98], 0, value[99])
        value[98].n = 1
        value[29] = value[98][1]
        value[30] = function(argument4, argument5, argument6, argument7)
            local value29, value30 = infinity
            for index14 = 1, value[13] + value[17], 1 do
                local value31 = index14 <= value[13] and value[12][index14] or value[16][index14 - value[13]]
                if not (argument7 and argument7[value31]) then
                    index14 = (
                        helper3(value31, argument4, value[6], argument5, argument6, value[4], value[29])
                    )
                    if index14 then
                        local value32 = -index14 - helper8(value31, value[2], value[11])
                        if value32 < value29 then
                            value29, value30 = value32, value31
                        end
                    end
                end
            end
            return value29, value30
        end
        value[31] = function(argument4, argument5, argument6, argument7, argument8)
            local value29 = max(argument6 - argument, 0)
            if value[30](argument4, argument5, argument6, argument7) <= 0 then
                return false
            end
            if argument8 then
                return true
            end
            if
                value[30](
                    argument4,
                    argument5,
                    argument + value29 * (config.stepInSlow or 1.1) + (config.stepInPad or 0.15) + value[11],
                    argument7
                ) <= 0
            then
                return false
            end
            if value29 > 0.1 then
                if
                    value[30](
                        argument4,
                        argument5,
                        argument + value29 * (config.stepInFast or 0.9),
                        argument7
                    ) <= 0
                then
                    return false
                end
            end
            return true
        end
        value[32] = function(
            argument4,
            argument5,
            argument6,
            argument7,
            argument8,
            argument9,
            argument10,
            argument11
        )
            local value29, value30 = argument6 - argument4, argument7 - argument5
            argument7 = sqrt(value29 * value29 + value30 * value30)
            argument6 = max(1, math.ceil(argument7 / (config.stepInStep or 1.5)))
            for index14 = 1, argument6, 1 do
                local value31 = index14 / argument6
                if
                    not (
                        value[31](
                            argument4 + value29 * value31,
                            argument5 + value30 * value31,
                            argument8 + argument7 * value31 / argument9,
                            argument10,
                            argument11
                        )
                    )
                then
                    return false
                end
            end
            return true
        end
        value[33] = function(argument4, argument5, argument6)
            local value29 = config.arriveHold or 1
            return value[30](argument4, argument5, argument6 + value29 * 0.5) > 0
                and value[30](argument4, argument5, argument6 + value29) > 0
        end
        local function helper22(argument4, argument5, argument6, argument7)
            local value29, value30, value31 =
                config.stepInWays or 12, config.stepInExitMax or 26, config.stepInStep or 1.5
            raycastParams.FilterDescendantsInstances =
                { sharedValue.LocalPlayer.Character, bubbleBoss.folder }
            local value32, value36, value37 = Vector3.new(argument4, value[6] + 2, argument5), infinity
            for index14 = 0, value29 - 1, 1 do
                local value38 = index14 * 2 * 3.141592653589793 / value29
                local value39, value40 = cos(value38), sin(value38)
                index14 =
                    parent:Raycast(value32, Vector3.new(value39, 0, value40) * (value30 + 2), raycastParams)
                local value41, value42 =
                    min(value30, index14 and index14.Distance - (config.wallClear or 5) or value30), value31
                while value42 <= value41 and value42 < value36 do
                    local value43, value44, value45 =
                        argument4 + value39 * value42,
                        argument5 + value40 * value42,
                        argument6 + value42 / argument7
                    if not (value[31](value43, value44, value45)) then
                        break
                    end
                    if value[33](value43, value44, value45) then
                        if
                            config.ledgeGuard == false
                            or parent:Raycast(
                                Vector3.new(value43, value[6] + 3, value44),
                                Vector3.new(0, -(3 + (config.ledgeDrop or 7)), 0),
                                raycastParams
                            )
                        then
                            value37 = (Vector3.new(value43, value[6], value44))
                            value36 = value42
                        end
                        break
                    end
                    value42 += value31
                end
            end
            return value37, value36
        end
        local value46 = {}
        value[100] = value[17]
        for index15 = 1, value[13] + value[100], 1 do
            value[102] = index15 <= value[13]
            if value[102] then
                value[101] = index15
                value[102] = value[12][value[101]]
            end
            value[104] = value[102]
            if not value[104] then
                value[103] = index15 - value[13]
                value[104] = value[16][value[103]]
            end
            value[21] = value[104]
            index15 = (helper3(value[21], value[5], value[6], value[7], argument, value[4], value[29]))
            if index15 then
                if index15 >= -helper8(value[21], value[2], value[11]) then
                    value46[value[21]] = true
                end
            end
        end
        local function helper23(argument4, argument5, dist, argument6)
            local value29, value30, value31 =
                value[5] + argument4 * dist, value[7] + argument5 * dist, argument + dist / argument6
            if not (value[32](value[5], value[7], value29, value30, argument, argument6, value46)) then
                return nil
            end
            local value32, value36, value37 = value31
            while value32 <= value31 + (config.stepInLook or 3) do
                local value38, value39 = value[30](value29, value30, value32)
                if value38 <= 0 then
                    value36, value37 = value32, value39
                    break
                end
                value32 += 0.05
            end
            if not value36 then
                return nil
            end
            local exit, exitD = helper22(value29, value30, value31, argument6)
            if not exit then
                return nil
            end
            local value40 = {}
            value40.dx = argument4
            value40.dz = argument5
            value40.dist = dist
            value40.q = Vector3.new(value29, value[6], value30)
            value40.exit = exit
            value40.exitD = exitD
            value40.tBad = value36
            value40.onB = value37
            value40.depth = max(-value[30](value29, value30, value36), 0)
            value40.slack = value36 - (value31 + exitD / argument6)
            return value40
        end
        value[22] = bubbleBoss.stepIn
        if
            value[22]
            and (argument > value[22].tBad + 0.3 or argument - value[22].at > (config.stepInFor or 3))
        then
            bubbleBoss.stepIn = nil
            value[22] = nil
        end
        if value[22] then
            if not value[22].out then
                if
                    sqrt((value[22].q.X - value[5]) ^ 2 + (value[22].q.Z - value[7]) ^ 2)
                    <= (config.stepInArrive or 2.5)
                then
                    value[22].out = true
                end
            end
            if value[22].out then
                value[21] = (sqrt((value[22].exit.X - value[5]) ^ 2 + (value[22].exit.Z - value[7]) ^ 2))
                value[105] = (config.bubbleArrive or 1.5)
                if value[21] <= value[105] then
                    bubbleBoss.stepIn = nil
                else
                    argument3 = (
                        value[32](
                            value[5],
                            value[7],
                            value[22].exit.X,
                            value[22].exit.Z,
                            argument,
                            value[22].speed,
                            value46
                        )
                    )
                    if not argument3 then
                        value[8] = (helper22(value[5], value[7], argument, value[22].speed))
                        if value[8] then
                            value[22].exit = value[8]
                            argument3 = true
                        end
                    end
                    if argument3 then
                        bubbleBoss.goal = nil
                        bubbleBoss.pickedSafe = true
                        value[106] = bubbleBoss
                        value[106].pickedDist = value[21]
                        value[107] = {}
                        value[107].point = value[22].exit
                        value[107].soft = false
                        value[107].burst = value[22].speed
                        value[107].label = ("STEP-IN: straight out of the %s it stepped into, %.0f studs, %.1fs before it goes off"):format(
                            tostring(value[22].name),
                            value[21],
                            max(value[22].tBad - argument, 0)
                        )
                        return value[107]
                    end
                    bubbleBoss.stepIn = nil
                end
            end
        end
        if config.fanDance ~= false then
            if hazardReader.fanUntil then
                if argument < hazardReader.fanUntil then
                    if hazardReader.hubAt then
                        if argument - hazardReader.hubAt < 2 then
                            value[8] = (os.clock())
                            value[108] = argumentHelpers[108](
                                pcall(
                                    bubbleBoss.fanDance,
                                    argument,
                                    point,
                                    context.planSpeed and context.planSpeed(argument) or config.tweenEscape
                                )
                            )
                            value[22] = value[108][1]
                            value[21] = value[108][2]
                            value[109] = bubbleBoss
                            value[110] = (os.clock() - value[8]) * 1000
                            value[109].danceMs = value[110]
                            if value[22] and value[21] then
                                bubbleBoss.goal = nil
                                bubbleBoss.stepIn = nil
                                return value[21]
                            elseif value[22] then
                            else
                                value[111] = runtimeState
                                value[112] = "fan dance: " .. tostring(value[21])
                                value[111].lastError = value[112]
                                runtimeState.lastErrorAt = argument
                            end
                        end
                    end
                end
            end
        end
        value[8] = bubbleBoss.active
        if if value[8] then #value[9] == 0 else not value[8] then
            bubbleBoss.goal = nil
            return nil
        end
        local soft = not bubbleBoss.lethal
        local speed = soft and (runtimeState.walkSpeed or config.tweenWalk)
            or (context.planSpeed and context.planSpeed(argument) or config.tweenEscape)
        local value47 = config.crissStepSafe ~= false
            and soft
            and bubbleBoss.primary ~= nil
            and bubbleBoss.primary.box ~= nil
            and (
                config.softStepSafe ~= false
                or string.find(
                        string.lower(tostring(bubbleBoss.primary.box.name or "")),
                        "criss",
                        1,
                        true
                    )
                    ~= nil
            )
        local function helper24(vector)
            if value47 then
                if not vector then
                    return nil
                end
            else
                return nil
            end
            if sqrt((vector.X - value[5]) ^ 2 + (vector.Z - value[7]) ^ 2) < 0.5 then
                return nil
            end
            if not (bubbleBoss.wayClear(point, vector, speed, argument)) then
                return "the way off it"
            end
            return nil
        end
        local function helper25(argument4, argument5)
            bubbleBoss.goal = nil
            bubbleBoss.crissHoldAt = argument
            local value29 = tostring(
                bubbleBoss.primary and bubbleBoss.primary.box and bubbleBoss.primary.box.name or "warning"
            )
            local value30 = string.find(string.lower(value29), "criss", 1, true)
                    and "the criss-cross's yellow"
                or "the " .. value29 .. " yellow"
            if argument5 then
                if config.softStepRound ~= false then
                    if bubbleBoss.detour then
                        local success, point2, value31 = pcall(bubbleBoss.detour, point, argument5, speed)
                        if success then
                            if point2 then
                                if bubbleBoss.wayClear(point, point2, speed, argument) then
                                    return {
                                        point = point2,
                                        soft = true,
                                        label = ("STEP OFF %s: round the attack in the way (%d deg)"):format(
                                            value30,
                                            value31 or 0
                                        ),
                                    }
                                end
                            end
                        end
                    end
                end
            end
            return {
                point = point,
                soft = true,
                hold = true,
                label = ("STEP OFF %s: %s runs into an attack - standing still until it is gone"):format(
                    value30,
                    argument4
                ),
            }
        end
        bubbleBoss.cmH = nil
        bubbleBoss.cmF = nil
        if context.champMid then
            bubbleBoss.cmH, bubbleBoss.cmF = context.champMid()
        end
        local lP, value48 = arenaOf(value[5], value[7])
        sharedValue6 = nil
        if hazardReader.fanUntil ~= nil then
            if argument < hazardReader.fanUntil + 1 then
                if value48 then
                    if hazardReader.hub then
                        sharedValue6 = min(value48 - (config.fanInSlack or 4), (config.fanRadius or 108) - 6)
                    end
                end
            end
        end
        sharedValue7 = false
        if hazardReader.champEntry then
            value[113] = hazardReader.champEntry.X
            argument3 = value[5] - value[113]
            value[114] = hazardReader.champEntry.Z
            value[22] = value[7] - value[114]
            value[117] = sqrt
            value[116] = argument3 * argument3
            value[115] = value[22]
            value[118] = value[117](value[116] + value[22] * value[115])
                >= (config.entranceKeepOut or 45) + 10
            sharedValue7 = value[118]
        end
        value[119] = config.champEntryBox ~= nil and not context.inEntryBox(value[5], value[7], 0)
        sharedValue4 = value[119]
        value[120] = config.champEntryBox ~= nil
                and not sharedValue4
                and context.entryBoxDepth(value[5], value[7])
            or nil
        sharedValue5 = value[120]
        sharedValue15 = nil
        value[21] = hazardReader.missileAxis
        if value[21] then
            if argument - value[21].t < 3 then
                value[125] = max
                value[124] = abs
                value[121] = value[21].ox
                value[123] = (value[5] - value[121]) * -value[21].dz
                value[122] = value[21].oz
                value[126] = (
                    value[125](
                        value[124](value[123] + (value[7] - value[122]) * value[21].dx) - 2,
                        config.missileAxisRoom or 6
                    )
                )
                sharedValue15 = value[126]
            end
        end
        sharedValue11 = nil
        value[21] = bubbleBoss.primary
        value[22] = ((value[21] and value[21].box and tostring(value[21].box.name or "") or ""):lower())
        argument3 = true
        if config.seekSideSolo ~= false then
            local value49, value50
            for index16 = 1, #value[9], 1 do
                value[127] = index16
                value[8] = value[9][value[127]]
                if value[8].hard then
                    if argument3 then
                        local value51, value52, value53 = value[8].box
                        if value51.line and value51.line.ux and value51.line.uz then
                            value52, value53 = value51.line.ux, value51.line.uz
                        else
                            if value51.moving and value51.dx then
                                if value51.dz then
                                    index16 = sqrt(value51.dx * value51.dx + value51.dz * value51.dz)
                                    if index16 > 0.5 then
                                        local value54, value55 = value51.dx / index16, value51.dz / index16
                                        value52, value53 = value54, value55
                                    end
                                end
                            end
                        end
                        if value52 then
                            if value49 then
                                argument3 = if abs(value52 * value49 + value53 * value50)
                                        < (config.seekSideSameDot or 0.985)
                                    then false
                                    else argument3
                            else
                                value49, value50 = value52, value53
                            end
                        else
                            value51 = false
                            argument3 = value51
                        end
                    end
                end
            end
        end
        bubbleBoss.crissLive = false
        if config.seekCrissWay ~= false then
            value[8] = dangerGeometry.boxes or {}
            for index17 = 1, #value[8], 1 do
                value[128] = index17
                local zone = value[8][value[128]]
                if string.lower(tostring(zone.name or "")):find("criss", 1, true) then
                    if (zone.untilAt or 0) > argument then
                        if (zone.from or argument) < argument + (config.seekCrissLook or 1.5) then
                            index17 = zone.cframe and zone.cframe.Position
                            local value56, value57 =
                                zone.cx or index17 and index17.X, zone.cz or index17 and index17.Z
                            if value56 then
                                if
                                    (value56 - value[5]) ^ 2 + (value57 - value[7]) ^ 2
                                    < (config.seekCrissNear or 90) ^ 2
                                then
                                    bubbleBoss.crissLive = true
                                    break
                                end
                            else
                                bubbleBoss.crissLive = true
                                break
                            end
                        end
                    end
                end
            end
            argument3 = if bubbleBoss.crissLive then false else argument3
        end
        bubbleBoss.seekSolo = argument3
        value[8] = argument3 and (value[22]:find("big spike", 1, true) or value[22]:find("bigspike", 1, true))
        if value[8] then
            local value58, value59, value60, value61 = value[21].box
            if value58.dx and value58.dz then
                if value58.dx * value58.dx + value58.dz * value58.dz > 0.5 then
                    local value62, value63, value64 = value58.dx, value58.dz, "lane"
                    value59, value60, value61 = value62, value63, value64
                end
            end
            if not value59 then
                for index18 = 1, #(dangerGeometry.boxes or {}), 1 do
                    local value65 = dangerGeometry.boxes[index18]
                    if
                        value65 ~= value58
                        and tostring(value65.name or "") == "big spike"
                        and value65.dx
                        and value65.dz
                        and value65.dx * value65.dx + value65.dz * value65.dz > 0.5
                    then
                        value59, value60, value61 = value65.dx, value65.dz, "announced lane"
                        break
                    end
                end
            end
            if not value59 then
                local value66, value67
                for key, part in pairs(hazardReader.parts) do
                    if key.Parent then
                        if string.lower(key.Name):gsub("%s", ""):find("bigspike", 1, true) then
                            part = (key.Position.X - value[5]) ^ 2 + (key.Position.Z - value[7]) ^ 2
                            if value66 then
                                if part < value66 then
                                    value66, value67 = part, key
                                end
                            else
                                value66, value67 = part, key
                            end
                        end
                    end
                end
                if value67 then
                    value58 = hazardReader.parts[value67]
                    if value58 and value58.vx * value58.vx + value58.vz * value58.vz > 400 then
                        value59, value60, value61 = value58.vx, value58.vz, "part velocity"
                    else
                        value[129] = value67.Position.X
                        value59 = value[5] - value[129]
                        value[130] = value67.Position.Z
                        value60 = value[7] - value[130]
                        value61 = "part line"
                    end
                end
            end
            bubbleBoss.seekFrom = value59 and value61 or "none"
            if value59 then
                value58 = sqrt(value59 * value59 + value60 * value60)
                if value58 > 1 then
                    sharedValue11 = { x = value59 / value58, z = value60 / value58 }
                end
            end
        elseif value[22] == "secondbossspreadbeam" then
            local value68, value69
            for index19, enemy in ipairs(hazardReader.enemies) do
                if
                    enemy.isBoss
                    and enemy.root
                    and enemy.root.Parent
                    and string.lower(tostring(enemy.model and enemy.model.Name or "")):find("bob", 1, true)
                then
                    value68, value69 = enemy.root.Position.X, enemy.root.Position.Z
                    break
                end
            end
            if value68 then
                value[131] = value68
                value[133] = value[5] - value[131]
                value[132] = value69
                local value70, value71 = value[133], value[7] - value[132]
                local value72 = sqrt(value70 * value70 + value71 * value71)
                if value72 > 1 then
                    sharedValue11 = { x = value70 / value72, z = value71 / value72 }
                end
            end
        elseif
            (value[22] == "spearmanstrikehitbox" or value[22] == "northernwarriorlinestrike")
            and bubbleBoss.primary
            and bubbleBoss.primary.box
            and bubbleBoss.primary.box.ax
        then
            local value73 = bubbleBoss.primary.box
            local value74, value75 = value73.ax, value73.az
            if (value73.hb or 0) > (value73.ha or 0) then
                value74, value75 = value73.bx, value73.bz
            end
            value73 = sqrt(value74 * value74 + value75 * value75)
            if value73 > 0.01 then
                sharedValue11 = { x = value74 / value73, z = value75 / value73 }
            end
        elseif argument3 and (value[22]:find("seeking", 1, true)) then
            local value76, value77, value78 = value[21].box
            if config.seekOwnLine ~= false and value76 then
                if value76.line and value76.line.ux and value76.line.uz then
                    value77, value78 = value76.line.ux, value76.line.uz
                else
                    if value76.moving and value76.dx and value76.dz then
                        if value76.dx * value76.dx + value76.dz * value76.dz > 0.5 then
                            local value79, value80 = value76.dx, value76.dz
                            value77, value78 = value79, value80
                        end
                    end
                end
            end
            local value81, value82
            if value77 then
                value76 = sqrt(value77 * value77 + value78 * value78)
                sharedValue11 = { x = value77 / value76, z = value78 / value76 }
                bubbleBoss.seekFrom = "own line"
            else
                for key2, part2 in pairs(hazardReader.parts) do
                    if key2.Parent then
                        if string.lower(key2.Name):find("seeking", 1, true) then
                            part2 = (key2.Position.X - value[5]) ^ 2 + (key2.Position.Z - value[7]) ^ 2
                            if value82 then
                                if part2 < value82 then
                                    value82, value81 = part2, key2
                                end
                            else
                                value82, value81 = part2, key2
                            end
                        end
                    end
                end
            end
            if value81 then
                local value83, value84, value85 = hazardReader.parts[value81]
                if value83 and value83.vx * value83.vx + value83.vz * value83.vz > 400 then
                    value84, value85 = value83.vx, value83.vz
                else
                    value[134] = value81.Position.X
                    value84 = value[5] - value[134]
                    value[135] = value81.Position.Z
                    value85 = value[7] - value[135]
                end
                value76 = sqrt(value84 * value84 + value85 * value85)
                if value76 > 1 then
                    sharedValue11 = { x = value84 / value76, z = value85 / value76 }
                end
            end
        end
        sharedValue12 = nil
        if config.sweepBehind ~= false then
            if hazardReader.fanSweep then
                if hazardReader.fanSweepAt then
                    if argument - hazardReader.fanSweepAt < (config.sweepFor or 1.6) then
                        if hazardReader.hub then
                            if not (hazardReader.fanUntil and argument < hazardReader.fanUntil) then
                                argument3 = bubbleBoss.primary
                                        and bubbleBoss.primary.box
                                        and tostring(bubbleBoss.primary.box.name or "")
                                    or ""
                                if argument3 == "firstbosspassivebeam" or argument3 == "beam next" then
                                    value[21] = hazardReader.fanSweep
                                    value[22] = hazardReader.hub.X
                                    value[8] = hazardReader.hub.Z
                                    sharedValue12 = value[21]
                                    sharedValue13 = value[22]
                                    sharedValue14 = value[8]
                                end
                            end
                        end
                    end
                end
            end
        end
        sharedValue10 = nil
        argument3 = bubbleBoss.primary
        if argument3 then
            if argument3.box then
                if tostring(argument3.box.name or "") == "secondbossspreadbeam" then
                    if context.BR then
                        if context.BR.target then
                            if context.BR.target.isBoss then
                                if context.BR.target.root then
                                    if context.BR.target.root.Parent then
                                        value[21] = context.BR.target.root.Position
                                        value[136] = {}
                                        value[136].x = value[21].X
                                        value[136].z = value[21].Z
                                        value[136].d =
                                            sqrt((value[21].X - value[5]) ^ 2 + (value[21].Z - value[7]) ^ 2)
                                        value[137] = value[136]
                                        sharedValue10 = value[137]
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        sharedValue8, sharedValue9 = nil, false
        if config.spikeOnUs ~= false and config.spikeGoalWay == false then
            value[138] = config.spikeOnUs or 20
            argument3 = value[138]
            value[8] = nil
            for index20, entry2 in ipairs(hazardReader.zones or {}) do
                index20 = string.lower(tostring(entry2.name or ""))
                if
                    (index20 == "ground spikes" or index20 == "spikes grow")
                    and entry2.cx
                    and (entry2.untilAt or 0) > argument
                    and (entry2.from or 0) > argument - 0.3
                then
                    value[21] = (sqrt((entry2.cx - value[5]) ^ 2 + (entry2.cz - value[7]) ^ 2))
                    value[139] = argument3
                    if value[21] < value[139] then
                        argument3 = value[21]
                        value[8] = entry2
                    end
                end
            end
            value[22] = false
            if value[8] and hazardReader.walls then
                for key3, wall in pairs(hazardReader.walls) do
                    if
                        wall.cx
                        and sqrt((wall.cx - value[5]) ^ 2 + (wall.cz - value[7]) ^ 2)
                            < (config.wallNear or 30)
                    then
                        value[22] = true
                        break
                    end
                end
            end
            if value[8] then
                if argument3 > 0.5 then
                    if not value[22] then
                        value[140] = {}
                        value[140].x = (value[8].cx - value[5]) / argument3
                        value[140].z = (value[8].cz - value[7]) / argument3
                        value[141] = value[140]
                        sharedValue8 = value[141]
                        sharedValue9 = true
                    end
                end
            end
            if value[8] then
                if not value[22] then
                    if config.spikeSafeSide ~= false then
                        if bubbleBoss.spikeSide then
                            local success2, value86 =
                                pcall(bubbleBoss.spikeSide, argument, point, value[8], speed)
                            if success2 then
                                if value86 then
                                    sharedValue8, sharedValue9 = { x = -value86.ux, z = -value86.uz }, true
                                end
                            end
                        end
                    end
                end
            end
        end
        value[22] = (if sharedValue8 then not sharedValue8 else config.spikeGoalWay == false)
            and context.PB
            and (context.PB.phase == "spikes" or context.PB.phase == "spikes-due")
        if
            value[22]
            and context.BR
            and context.BR.target
            and context.BR.target.isBoss
            and context.BR.target.root
            and context.BR.target.root.Parent
            and not (context.bobLine and context.bobLine())
            and not (config.spikeLeadFree ~= false and hazardReader.orbLead and hazardReader.orbLead.goal)
        then
            value[8] = context.BR.target.root.Position
            argument3 = value[8].X - value[5]
            value[21] = value[8].Z - value[7]
            value[144] = sqrt
            value[143] = argument3 * argument3
            value[142] = value[21]
            local value87 = value[144](value[143] + value[21] * value[142])
            if value87 > 1 then
                value[145] = {}
                value[145].x = argument3 / value87
                value[146] = value87
                value[145].z = value[21] / value[146]
                value[147] = value[145]
                sharedValue8 = value[147]
            end
            if sharedValue8 and hazardReader.walls then
                local iteratePairs, walls = pairs, hazardReader.walls
                for key4, wall2 in iteratePairs(walls) do
                    if wall2.cx then
                        if
                            sqrt((wall2.cx - value[5]) ^ 2 + (wall2.cz - value[7]) ^ 2)
                            < (config.wallNear or 30)
                        then
                            sharedValue8 = nil
                            break
                        end
                    end
                end
            end
        end
        local value88 = {}
        local function helper26(primary)
            if not primary.stillSeek then
                return false
            end
            primary = bubbleBoss.primary
            return primary ~= nil
                and primary.box ~= nil
                and string.lower(tostring(primary.box.name or "")):find("seeking", 1, true) ~= nil
        end
        local value89 = bubbleBoss.primary ~= nil
            and bubbleBoss.primary.box ~= nil
            and tostring(bubbleBoss.primary.box.name or ""):lower():find("spike", 1, true) ~= nil
        local function helper27(argument4, argument5, argument6)
            local value29, value30, bubbleLead, value31, value32 =
                -infinity, -infinity, config.bubbleLead, bubbleBoss.beamWhite, infinity
            for index14 = 1, value[13], 1 do
                local value36 = value[12][index14]
                index14 = value36.stillSeek and helper26(value36)
                local value37 = (
                    if index14
                        then not index14
                        else helper3(
                            value36,
                            argument4,
                            value[6],
                            argument5,
                            argument6,
                            value[4],
                            bubbleLead
                        )
                ) or nil
                if value37 then
                    index14 = -value37 - helper8(value36, value[2], value[11])
                    value32, value29 =
                        if index14 < value32 then index14 else value32,
                        if value37 > value29 then value37 else value29
                    local value38 = value88[value36]
                    value30 = if value37 > value30
                        then if value38
                            then if config.bubbleDeeperCut ~= false
                                then if value37 > value38 + (config.bubbleDeeperBy or 3)
                                    then if value31
                                        then if value31[value36] then value30 else value37
                                        else value37
                                    else value30
                                else value30
                            else if value31
                                then if value31[value36] then value30 else value37
                                else value37
                        else value30
                end
            end
            for index21 = 1, value[19], 1 do
                argument6 = value[18][index21]
                if argument6.laneHard then
                    value31 = (helper8(argument6, value[2], value[11]))
                    index21 = config.bubbleTrajLead or 1.2
                    index21 = if value89 then max(index21, config.spikeWallLead or 3) else index21
                    local value39 = config.laneStepT or 0.2
                    local value40 = math.max(4, math.ceil(index21 / value39))
                    for index22 = 1, value40, 1 do
                        value39 = index21 * index22 / value40
                        index22 = (
                            helper3(
                                argument6,
                                argument4,
                                value[6],
                                argument5,
                                argument + value39,
                                value[4],
                                (config.bubbleLead or 0) + value39
                            )
                        )
                        if index22 and index22 >= -value31 then
                            local value41 = -index22 - value31
                            value32, value29, value30 =
                                if value41 < value32 then value41 else value32,
                                if index22 > value29 then index22 else value29,
                                if index22 > value30
                                    then if value88[argument6]
                                        then if config.bubbleDeeperCut ~= false
                                            then if index22
                                                    > value88[argument6] + (config.bubbleDeeperBy or 3)
                                                then index22
                                                else value30
                                            else value30
                                        else index22
                                    else value30
                            break
                        end
                    end
                end
            end
            argument6 = bubbleBoss.liveNow
            for index23 = 1, bubbleBoss.liveNowN or 0, 1 do
                value31 = (
                    helper3(
                        argument6[index23],
                        argument4,
                        value[6],
                        argument5,
                        argument,
                        value[4],
                        bubbleLead
                    )
                )
                value30 = if value31
                    then if value31 >= 0 then if value31 > value30 then value31 else value30 else value30
                    else value30
            end
            return value32, value29, value30
        end
        local function helper28(argument4, argument5, argument6)
            local value29, value30, bubbleLead, value31 =
                -infinity, -infinity, config.bubbleLead, bubbleBoss.beamWhite
            local value32 = infinity
            for index14 = 1, value[13], 1 do
                local value36 = value[12][index14]
                if not (value36.stillSeek and helper26(value36)) then
                    index14 = depthBound(value36, argument4, argument5, argument6, bubbleLead)
                    if
                        not (
                            index14
                            and -index14 <= value29
                            and -index14 <= value30
                            and index14 - helper8(value36, value[2], value[11]) >= value32
                        )
                    then
                        local value37 =
                            helper3(value36, argument4, value[6], argument5, argument6, value[4], bubbleLead)
                        if value37 then
                            local value38 = -value37 - helper8(value36, value[2], value[11])
                            value32, value29 =
                                if value38 < value32 then value38 else value32,
                                if value37 > value29 then value37 else value29
                            value38 = value88[value36]
                            value30 = if value37 > value30
                                then if value38
                                    then if config.bubbleDeeperCut ~= false
                                        then if value37 > value38 + (config.bubbleDeeperBy or 3)
                                            then if value31
                                                then if value31[value36] then value30 else value37
                                                else value37
                                            else value30
                                        else value30
                                    else if value31
                                        then if value31[value36] then value30 else value37
                                        else value37
                                else value30
                        end
                    end
                end
            end
            for index21 = 1, value[19], 1 do
                argument6 = value[18][index21]
                if argument6.laneHard then
                    value31 = (helper8(argument6, value[2], value[11]))
                    index21 = config.bubbleTrajLead or 1.2
                    index21 = if value89 then max(index21, config.spikeWallLead or 3) else index21
                    local value39 = config.laneStepT or 0.2
                    local value40 = math.max(4, math.ceil(index21 / value39))
                    if
                        not (
                            laneBound(
                                argument6,
                                argument4,
                                argument5,
                                argument + index21 / value40,
                                argument + index21
                            ) > value31
                        )
                    then
                        for index22 = 1, value40, 1 do
                            value39 = index21 * index22 / value40
                            index22 = (
                                helper3(
                                    argument6,
                                    argument4,
                                    value[6],
                                    argument5,
                                    argument + value39,
                                    value[4],
                                    (config.bubbleLead or 0) + value39
                                )
                            )
                            if index22 and index22 >= -value31 then
                                local value41 = -index22 - value31
                                value32, value29, value30 =
                                    if value41 < value32 then value41 else value32,
                                    if index22 > value29 then index22 else value29,
                                    if index22 > value30
                                        then if value88[argument6]
                                            then if config.bubbleDeeperCut ~= false
                                                then if index22
                                                        > value88[argument6]
                                                            + (config.bubbleDeeperBy or 3)
                                                    then index22
                                                    else value30
                                                else value30
                                            else index22
                                        else value30
                                break
                            end
                        end
                    end
                end
            end
            value31 = bubbleBoss.liveNow
            for index23 = 1, bubbleBoss.liveNowN or 0, 1 do
                argument6 = value31[index23]
                if not (depthBound(argument6, argument4, argument5, argument, bubbleLead)) then
                    index23 = (
                        helper3(argument6, argument4, value[6], argument5, argument, value[4], bubbleLead)
                    )
                    value30 = if index23
                        then if index23 >= 0 then if index23 > value30 then index23 else value30 else value30
                        else value30
                end
            end
            return value32, value29, value30
        end
        local function fitsAt(argument4, argument5, argument6)
            local value29, value30, value31, value32 = false
            if hazardReader.leash then
                value29, value30, value31, value32 = arenaOf(argument4, argument5)
            end
            if sharedValue15 then
                local missileAxis = hazardReader.missileAxis
                local value36 = abs(
                    (argument4 - missileAxis.ox) * -missileAxis.dz
                        + (argument5 - missileAxis.oz) * missileAxis.dx
                )
                if value36 > sharedValue15 then
                    return -infinity, infinity, infinity
                end
            end
            if sharedValue11 then
                local value37 =
                    abs((argument4 - value[5]) * sharedValue11.x + (argument5 - value[7]) * sharedValue11.z)
                if value37 > (config.seekAlongMax or 8) then
                    return -infinity, infinity, infinity
                end
            end
            if sharedValue12 then
                local value38, value39 = value[5] - sharedValue13, value[7] - sharedValue14
                local value40 = sqrt(value38 * value38 + value39 * value39)
                if value40 > 5 then
                    local value41 = sharedValue12
                    if
                        value41
                            * (value39 * (argument4 - value[5]) - value38 * (argument5 - value[7]))
                            / value40
                        > (config.sweepAheadSlack or 3)
                    then
                        return -infinity, infinity, infinity
                    end
                end
            end
            if sharedValue10 then
                local value42, value43 = argument4 - sharedValue10.x, argument5 - sharedValue10.z
                if
                    sqrt(value42 * value42 + value43 * value43)
                    < sharedValue10.d - (config.spreadOutSlack or 3)
                then
                    return -infinity, infinity, infinity
                end
            end
            if sharedValue8 then
                local value44, value45 = argument4 - value[5], argument5 - value[7]
                local value90 = sqrt(value44 * value44 + value45 * value45)
                if value90 > 3 then
                    local value91, value92 =
                        (value44 * sharedValue8.x + value45 * sharedValue8.z) / value90,
                        sharedValue9 and (config.spikeOnUsCos or 0.94)
                    if value91 > -(value92 or (config.spikeAxisCos or 0.8)) then
                        return -infinity, infinity, infinity
                    end
                end
            end
            if value29 then
                if not (value89 and hazardReader.orbLead ~= nil and config.spikeLeadArenaFree ~= false) then
                    local value93, value94 =
                        config.arenaSlack or 8, value89 and (config.spikeArenaSlack or 14)
                    local value95 = value93 + (value94 or 0)
                    value93 = value32 and value32 + value95
                    if value93 then
                        if value30 ~= nil then
                            if value30 > value93 then
                                if value48 == nil then
                                    return -infinity, infinity, infinity
                                elseif value48 <= value93 then
                                    return -infinity, infinity, infinity
                                end
                            end
                        end
                    end
                    if value48 ~= nil and value31 ~= nil and value32 ~= nil then
                        value93 = value48 > value32 and value48 - value32
                            or value48 < value31 and value31 - value48
                            or 0
                        if
                            (
                                value30 > value32 and value30 - value32
                                or value30 < value31 and value31 - value30
                                or 0
                            ) > value93 + value95
                        then
                            return -infinity, infinity, infinity
                        end
                    elseif value48 == nil then
                        return -infinity, infinity, infinity
                    end
                end
            end
            local value96 = config.bbFast
            value96 = if value96 == nil then true else value96
            if value96 == true then
                return helper28(argument4, argument5, argument6)
            end
            local value97, value98, value99 = helper27(argument4, argument5, argument6)
            if value96 == "shadow" then
                local value100, value101, value102 = helper28(argument4, argument5, argument6)
                bubbleBoss.shadowN = (bubbleBoss.shadowN or 0) + 1
                if value97 ~= value100 or value98 ~= value101 or value99 ~= value102 then
                    shadowMiss(
                        "fitsAt",
                        argument4,
                        argument5,
                        argument6,
                        ("%s/%s/%s"):format(value97, value98, value99),
                        ("%s/%s/%s"):format(value100, value101, value102)
                    )
                end
            end
            return value97, value98, value99
        end
        bubbleBoss.fitsAt = fitsAt
        local value103 = config.bubbleSoftCost or 6
        local function helper29(argument4, argument5, argument6)
            local value29 = 0
            for index14 = 1, value[15], 1 do
                local value30 = value[14][index14]
                index14 = (
                    helper3(value30, argument4, value[6], argument5, argument6, value[4], config.bubbleLead)
                )
                if index14 then
                    local value31 = index14 + helper8(value30, value[2], value[11])
                    value29 = if value31 > 0
                        then value29 + value31 * helper11(value30) * value103
                        else value29
                end
            end
            for index21 = 1, value[17], 1 do
                argument6 = value[16][index21]
                index21 = (helper6(argument6, argument4, value[6], argument5, value[4], value[20] + value[3]))
                if index21 then
                    local value32 = index21 + helper8(argument6, value[2], value[11])
                    if value32 > 0 then
                        local value36 = 1 - min(max(((argument6.from or 0) - argument) / value[20], 0), 1)
                        value29 += value32 * helper11(argument6) * value103 * (0.35 + 0.65 * value36)
                    end
                end
            end
            return value29
        end
        local function helper30(argument4, argument5, argument6)
            local value29 = 0
            for index14 = 1, value[15], 1 do
                local value30 = value[14][index14]
                local value31, value32 =
                    helper8(value30, value[2], value[11]),
                    depthBound(value30, argument4, argument5, argument6, config.bubbleLead)
                if not (value32 and value32 >= value31) then
                    index14 = (
                        helper3(
                            value30,
                            argument4,
                            value[6],
                            argument5,
                            argument6,
                            value[4],
                            config.bubbleLead
                        )
                    )
                    if index14 then
                        local value36 = index14 + value31
                        value29 = if value36 > 0
                            then value29 + value36 * helper11(value30) * value103
                            else value29
                    end
                end
            end
            for index21 = 1, value[17], 1 do
                argument6 = value[16][index21]
                index21 = (helper8(argument6, value[2], value[11]))
                local value37
                if argument6.moving then
                    local value38 = argument6.from or 0
                    value37 = laneBound(
                        argument6,
                        argument4,
                        argument5,
                        value38,
                        (min(argument6.untilAt or value38 + 2, value38 + value[20] + value[3]))
                    ) >= index21
                else
                    local value39 = depthBound(argument6, argument4, argument5, argument6.from or 0, 0)
                    value37 = value39 ~= nil and value39 >= index21
                end
                if not value37 then
                    local value40 =
                        helper6(argument6, argument4, value[6], argument5, value[4], value[20] + value[3])
                    if value40 then
                        local value41 = value40 + index21
                        if value41 > 0 then
                            local value42 = 1 - min(max(((argument6.from or 0) - argument) / value[20], 0), 1)
                            value29 += value41 * helper11(argument6) * value103 * (0.35 + 0.65 * value42)
                        end
                    end
                end
            end
            return value29
        end
        local function softAt(argument4, argument5, argument6)
            local value29 = config.bbFast
            value29 = if value29 == nil then true else value29
            if value29 == true then
                return helper30(argument4, argument5, argument6)
            end
            local value30 = helper29(argument4, argument5, argument6)
            if value29 == "shadow" then
                local value31 = helper30(argument4, argument5, argument6)
                bubbleBoss.shadowN = (bubbleBoss.shadowN or 0) + 1
                if value30 ~= value31 then
                    shadowMiss(
                        "softAt",
                        argument4,
                        argument5,
                        argument6,
                        tostring(value30),
                        tostring(value31)
                    )
                end
            end
            return value30
        end
        bubbleBoss.softAt = softAt
        local function helper31(argument4, argument5)
            local value29 = {}
            local value30, prefMid = 0, hazardReader.hub
            if prefMid then
                if context.fanFloor then
                    local value31 = context.fanFloor()
                    if value31 > 0 then
                        local value32 = sqrt((argument4 - prefMid.X) ^ 2 + (argument5 - prefMid.Z) ^ 2)
                        value30 = if value32 < value31
                            then value30 + min((config.fanInnerWeight or 0.6) * (value31 - value32), 12)
                            else value30
                    end
                end
            end
            if bubbleBoss.cmH then
                prefMid = sqrt((argument4 - bubbleBoss.cmH.X) ^ 2 + (argument5 - bubbleBoss.cmH.Z) ^ 2)
                value30 = if prefMid < bubbleBoss.cmF
                    then value30 + min((config.champMidPref or 0.6) * (bubbleBoss.cmF - prefMid), 12)
                    else value30
            end
            prefMid = hazardReader.ringBand and hazardReader.arenaCentre or nil
            if prefMid then
                local value36, value37, value38 =
                    sqrt((argument4 - prefMid.X) ^ 2 + (argument5 - prefMid.Z) ^ 2),
                    config.ringBandRadius or 81.25,
                    config.odinRanks ~= false and context.odinRankOff ~= nil
                for index14 = 1, #context.RING_GAPS, 1 do
                    local value39 = context.RING_GAPS[index14]
                    value37 = if if value38 then context.odinRankOff(value39) == 0 else not value38
                        then if abs(value36 - value39) < abs(value36 - value37) then value39 else value37
                        else value37
                end
                value30 += min((config.ringBandWeight or 0.3) * max(abs(value36 - value37) - 1.5, 0), 12)
                value30 = if value38
                    then value30 + min(
                        (config.odinRankDodgeWeight or 0.6) * context.odinRankOff(value36),
                        config.odinRankDodgeCap or 30
                    )
                    else value30
            end
            if hazardReader.rodinRig then
                if hazardReader.rodinRig.Parent then
                    if config.rodinHome ~= false then
                        if bubbleBoss.prefMidAt ~= value[1] then
                            prefMid = parent:FindFirstChild("thirdBossMiddlePart")
                            value29[1] = bubbleBoss
                            value29[2] = value[1]
                            value29[1].prefMidAt = value29[2]
                            bubbleBoss.prefMid = prefMid
                            if prefMid then
                                local position = prefMid.Position
                                bubbleBoss.prefMidX, bubbleBoss.prefMidZ = position.X, position.Z
                            end
                        end
                        if bubbleBoss.prefMid then
                            local value40 = sqrt(
                                (argument4 - bubbleBoss.prefMidX) ^ 2 + (argument5 - bubbleBoss.prefMidZ) ^ 2
                            )
                            local value41, value42 =
                                value30 + min(
                                    (config.rodinHomePull or 1.2)
                                        * max(
                                            abs(value40 - (config.rodinHomeRing or 56))
                                                - (config.rodinHomeReach or 10),
                                            0
                                        ),
                                    config.rodinHomeCap or 45
                                ),
                                value40 - (config.rodinLeash or 62)
                            value41 = if value42 > 0
                                then value41 + min(
                                    (config.rodinLeashPull or 6) * value42,
                                    config.rodinLeashCap or 600
                                )
                                else value41
                            value40, value42 = hazardReader.rodinBands, hazardReader.rodinBandC
                            if value40 then
                                if value42 then
                                    local value43, value44, value45 =
                                        sqrt((argument4 - value42.x) ^ 2 + (argument5 - value42.z) ^ 2),
                                        config.rodinBandPad or 3.5,
                                        value41
                                    for index21 = 1, #value40, 1 do
                                        local value90 = abs(value43 - value40[index21])
                                        value45 = if value90 < value44
                                            then value45
                                                + (config.rodinBandCost or 30)
                                                    * (value44 - value90)
                                                    / value44
                                            else value45
                                    end
                                    value30 = value45
                                else
                                    value30 = value41
                                end
                            else
                                value30 = value41
                            end
                        end
                    end
                end
            end
            prefMid = context.bobPullTo and context.bobPullTo(value[1]) or hazardReader.bobHome
            if prefMid then
                if not hazardReader.orbLead then
                    local value91 = sqrt((argument4 - prefMid.X) ^ 2 + (argument5 - prefMid.Z) ^ 2)
                    value30 += min(
                        (config.bobHomePull or 0.35) * max(value91 - (config.bobHomeReach or 18), 0),
                        config.bobHomeCap or 12
                    )
                end
            end
            if config.dodgeMeleePref ~= false then
                if not (context.GS_NOMELEE and config.gsMeleeKeep ~= true) then
                    local value92, value93, value94 = config.dodgeMeleeKeep or 30, config.meleeDeadly or 18, 0
                    for index22 = 1, #(hazardReader.enemies or {}), 1 do
                        prefMid = hazardReader.enemies[index22]
                        if
                            prefMid.melee
                            and not prefMid.isBoss
                            and prefMid.root
                            and prefMid.root.Parent
                            and (prefMid.humanoid == nil or prefMid.humanoid.Health > 0)
                        then
                            index22 = sqrt((argument4 - prefMid.x) ^ 2 + (argument5 - prefMid.z) ^ 2)
                            value94 = if index22 < value93
                                then value94 + (config.dodgeMeleeDeadly or 3)
                                else if index22 < value92
                                    then value94 + (value92 - index22) / max(value92 - value93, 1)
                                    else value94
                        end
                    end
                    value30 = if value94 > 0
                        then value30 + min(
                            value94 * (config.dodgeMeleeWeight or 10),
                            config.dodgeMeleeCap or 60
                        )
                        else value30
                end
            end
            local vector, origin =
                hazardReader.orbLead and hazardReader.orbLead.goal or nil, dangerGeometry.origin
            if vector then
                if origin then
                    prefMid = sqrt((argument4 - vector.X) ^ 2 + (argument5 - vector.Z) ^ 2)
                        - sqrt((origin.X - vector.X) ^ 2 + (origin.Z - vector.Z) ^ 2)
                    value30 = if prefMid > 0
                        then value30 + min((config.orbGoalPull or 0.6) * prefMid, config.orbGoalCap or 20)
                        else value30
                end
            end
            return value30
        end
        local value104 = config.bubbleTrajLead or 1.2
        local value105 = config.bubbleTrajCost or 14
        local function helper32(argument4, argument5)
            if value[19] == 0 then
                return 0
            elseif value104 <= 0 then
                return 0
            end
            local value29 = 0
            for index14 = 1, value[19], 1 do
                local value30 = value[18][index14]
                if not ((value30.from or 0) > argument) then
                    index14 = (helper8(value30, value[2], value[11]))
                    for index21 = 1, 5, 1 do
                        local value31 = value104 * index21 / 5
                        index21 = (
                            helper3(
                                value30,
                                argument4,
                                value[6],
                                argument5,
                                argument + value31,
                                value[4],
                                (config.bubbleLead or 0) + value31
                            )
                        )
                        if index21 and index21 >= -index14 then
                            value29 += value105 / (value31 + 0.3)
                            break
                        end
                    end
                end
            end
            return value29
        end
        argument3 = bubbleBoss.beamWhite
        if not argument3 then
            value[22] = setmetatable
            value[8] = { __mode = "k" }
            argument3 = (value[22]({}, value[8]))
            bubbleBoss.beamWhite = argument3
        end
        for index24 = 1, value[13], 1 do
            value[148] = index24
            value[22] = value[12][value[148]]
            if value[22].name == "firstbosspassivebeam" then
                if value[22].ax then
                    value[149] = value[22].cx
                    value[151] = (value[5] - value[149]) * value[22].bx
                    value[150] = value[22].cz
                    index24 = value[151] + (value[7] - value[150]) * value[22].bz
                    value[21] = argument3[value[22]]
                    if value[21] then
                        if
                            value[22].fired
                            or argument - value[21].at > (config.beamCrossHold or 0.9)
                            or index24 * value[21].side < 0 and math.abs(index24) > (value[22].hb or 4)
                        then
                            argument3[value[22]] = nil
                        end
                    elseif value[22].bornAt then
                        if argument - value[22].bornAt < (config.beamCrossYoung or 0.5) then
                            if not value[22].fired then
                                value[152] = { at = argument, side = index24 >= 0 and 1 or -1 }
                                argument3[value[22]] = value[152]
                            end
                        end
                    end
                end
            end
        end
        value[21] = bubbleBoss.liveNow
        if not value[21] then
            value[21] = {}
            value[153] = bubbleBoss
            value[153].liveNow = value[21]
        end
        for entry3 in pairs(value88) do
            value88[entry3] = nil
        end
        for index25 = 1, value[13], 1 do
            value[155] = helper3
            value[154] = index25
            value[8] = (
                value[155](
                    value[12][value[154]],
                    value[5],
                    value[6],
                    value[7],
                    argument,
                    value[4],
                    config.bubbleLead
                )
            )
            if value[8] then
                if value[8] >= 0 then
                    value[156] = index25
                    value[157] = value[12][value[156]]
                    value88[value[157]] = value[8]
                end
            end
        end
        for index26 = 1, value[19], 1 do
            value[158] = index26
            value[8] = value[18][value[158]]
            if value[8].laneHard then
                argument3 = (
                    helper3(value[8], value[5], value[6], value[7], argument, value[4], config.bubbleLead)
                )
                if argument3 then
                    if argument3 >= 0 then
                        value88[value[8]] = argument3
                    end
                end
            end
        end
        value[22] = argument + (config.bubbleProbe or 72) / max(speed, 1)
        argument3 = 0
        for index27 = 1, value[13], 1 do
            value[159] = index27
            value[8] = value[12][value[159]]
            index27 = value88[value[8]]
            if
                (if index27 then not index27 else (value[8].from or 0) <= argument)
                and (value[8].untilAt or infinity) >= argument
                and (value[8].moving or (value[8].untilAt or infinity) < value[22])
            then
                argument3 += 1
                value[21][argument3] = value[8]
            end
        end
        for index28 = 1, value[19], 1 do
            value[160] = index28
            value[8] = value[18][value[160]]
            if
                value[8].laneHard
                and not value88[value[8]]
                and (value[8].from or 0) <= argument
                and (value[8].untilAt or infinity) >= argument
            then
                argument3 += 1
                value[21][argument3] = value[8]
            end
        end
        bubbleBoss.liveNowN = argument3
        bubbleBoss.gsHere = next(value88) ~= nil
        bubbleBoss.gsNearOnly = bubbleBoss.gsHere
                and context.gsNearOnlyHere ~= nil
                and context.gsNearOnlyHere(value88)
            or false
        bubbleBoss.orbMidX = nil
        bubbleBoss.orbMidZ = nil
        bubbleBoss.orbMidW = nil
        if bubbleBoss.gsHere then
            if context.gsOrbMidDir then
                value[161] = bubbleBoss
                value[162] = bubbleBoss
                value[163] = argumentHelpers[108](context.gsOrbMidDir(value[5], value[7], value[6], value88))
                value[161].orbMidX = value[163][1]
                value[162].orbMidZ = value[163][2]
            end
        end
        if not bubbleBoss.orbMidX then
            if context.gsDodgeMidDir then
                value[164] = bubbleBoss
                value[165] = bubbleBoss
                value[166] = argumentHelpers[108](context.gsDodgeMidDir(value[5], value[7], value[6]))
                value[164].orbMidX = value[166][1]
                value[165].orbMidZ = value[166][2]
                bubbleBoss.orbMidW = bubbleBoss.orbMidX and (config.gsDodgeMidW or 100) or nil
            end
        end
        local L, value106 = fitsAt(value[5], value[7], argument)
        local function lineEnters(argument4, argument5, argument6)
            local value29, value30 = argument4 - value[5], argument5 - value[7]
            local value31 = sqrt(value29 * value29 + value30 * value30)
            if value31 < 0.5 then
                return false
            end
            if config.ringPathCheck ~= false then
                if context.OD then
                    if context.OD.pathCrossesRing then
                        if
                            context.OD.pathCrossesRing(
                                value[5],
                                value[7],
                                argument4,
                                argument5,
                                argument,
                                argument6
                            )
                        then
                            return true
                        end
                    end
                end
            end
            local value32, value36, value37 = value29 / value31, value30 / value31, config.bubbleStep or 2
            argument4, value29 = value37, value106 < 0
            while argument4 <= value31 do
                local qP, value38, value39 = fitsAt(
                    value[5] + value32 * argument4,
                    value[7] + value36 * argument4,
                    argument6 + argument4 / speed
                )
                if value39 >= 0 then
                    return true
                elseif value29 then
                    if value38 >= 0 then
                        return true
                    end
                end
                if
                    bubbleBoss.oldLineAt(
                        value[5] + value32 * argument4,
                        value[7] + value36 * argument4,
                        argument6 + argument4 / speed,
                        0,
                        value[5],
                        value[7]
                    )
                then
                    return true
                end
                value29 = if value38 < 0 then true else value29
                argument4 = argument4 + value37
            end
            return false
        end
        bubbleBoss.lineEnters = lineEnters
        bubbleBoss.mageCommitX = nil
        bubbleBoss.mageCommitZ = nil
        if bubbleBoss.mageCommitDir then
            bubbleBoss.mageCommitX, bubbleBoss.mageCommitZ = bubbleBoss.mageCommitDir(point, argument)
        end
        if context.GS_NOMELEE then
            if config.gsEscSafeStop ~= false then
                if next(value88) == nil then
                    if
                        value[30](value[5], value[7], argument)
                        > (config.gsEscSafeMargin or 0.5) + (dangerGeometry.lag or 0)
                    then
                        if
                            value[30](value[5], value[7], argument + (config.gsEscSafeLook or 0.5))
                            > (config.gsEscSafeMargin or 0.5) + (dangerGeometry.lag or 0)
                        then
                            bubbleBoss.goal = nil
                            bubbleBoss.lethal = false
                            bubbleBoss.gsSafeAt = argument
                            return nil
                        end
                    end
                end
            end
        end
        local prevGoal = bubbleBoss.goal
        if prevGoal then
            local pickedDist = sqrt((prevGoal.p.X - value[5]) ^ 2 + (prevGoal.p.Z - value[7]) ^ 2)
            if pickedDist <= config.bubbleArrive then
                bubbleBoss.goal = nil
            else
                if
                    bubbleBoss.gsNearOnly
                    and config.gsNearHoldMax ~= false
                    and pickedDist > (config.gsNearHoldMax or 14)
                then
                    bubbleBoss.goal = nil
                else
                    if
                        context.GS_NOMELEE
                        and config.gsBeamSideHeld ~= false
                        and context.gsBeamsShooting
                        and context.gsShooterAxis
                        and context.gsBeamsShooting(value[5], value[7], argument)
                        and (function()
                            local value29, value30 = context.gsShooterAxis(value[5], value[7])
                            return value29 ~= nil
                                and math.abs(
                                        (
                                            (prevGoal.p.X - value[5]) * value29
                                            + (prevGoal.p.Z - value[7]) * value30
                                        )
                                            / math.max(pickedDist, 0.01)
                                    )
                                    > math.cos(math.rad(config.gsBeamSideBanDeg or 50))
                        end)()
                    then
                        bubbleBoss.goal = nil
                    else
                        if
                            bubbleBoss.mageCommitX
                            and not prevGoal.bad
                            and pickedDist > 1
                            and (
                                        (prevGoal.p.X - value[5]) * bubbleBoss.mageCommitX
                                        + (prevGoal.p.Z - value[7]) * bubbleBoss.mageCommitZ
                                    )
                                    / pickedDist
                                < -(config.mageBackCos or 0.2)
                        then
                            bubbleBoss.goal = nil
                        else
                            if
                                config.slamStopWhenOut ~= false
                                and prevGoal.box
                                and prevGoal.box.name == "firstbossjumpslam"
                                and not prevGoal.box.moving
                                and next(value88) == nil
                                and depthOf(prevGoal.box, value[5], value[6], value[7], value[4])
                                    < -(dangerGeometry.reach + (config.slamOutMargin or 1))
                            then
                                bubbleBoss.goal = nil
                                bubbleBoss.prevGoal = prevGoal
                            else
                                if
                                    (function()
                                        if prevGoal.bad then
                                            return false
                                        elseif argument - prevGoal.at < 0.12 then
                                            return false
                                        end
                                        if
                                            not (
                                                bubbleBoss.primary ~= nil
                                                and bubbleBoss.primary.box ~= nil
                                                and bubbleBoss.primary.box ~= prevGoal.box
                                                and value88[bubbleBoss.primary.box] ~= nil
                                            )
                                        then
                                            if
                                                argument - (bubbleBoss.staleAt or 0)
                                                < (config.bubbleRestale or 0.35)
                                            then
                                                return false
                                            end
                                        end
                                        for entry4 in pairs(value88) do
                                            if entry4 ~= prevGoal.box then
                                                bubbleBoss.staleAt = argument
                                                return true
                                            end
                                        end
                                        return false
                                    end)()
                                then
                                    bubbleBoss.goal = nil
                                    bubbleBoss.prevGoal = prevGoal
                                else
                                    value[8] = argument - prevGoal.at
                                    value[21] = prevGoal.soft
                                    value[167] = (
                                        (if value[21] then not value[21] else prevGoal.box)
                                            and (bubbleBoss.primary and bubbleBoss.primary.box == prevGoal.box or value88[prevGoal.box])
                                            and (config.escapeCommit or 1.5)
                                        or context.BR and context.BR.target and context.BR.target.isBoss and max(
                                            config.bubbleCommit or 0.15,
                                            config.bubbleCommitMin or 0.1
                                        )
                                        or (config.bubbleCommitMob or 0.9)
                                    )
                                    if value[8] > value[167] then
                                        bubbleBoss.goal = nil
                                    else
                                        if
                                            (hazardReader.boxGen or 0) ~= (prevGoal.gen or 0)
                                            and argument - prevGoal.at > 0.12
                                            and context.BR
                                            and context.BR.target
                                            and context.BR.target.isBoss
                                            and not (
                                                config.bobChainKeepGoal ~= false
                                                and (
                                                    prevGoal.name == "circle next"
                                                    or prevGoal.name == "circle line"
                                                    or prevGoal.name == "secondbosscriclehitbox"
                                                )
                                            )
                                        then
                                            bubbleBoss.goal = nil
                                            bubbleBoss.prevGoal = prevGoal
                                        else
                                            if
                                                config.blueOrbSolid ~= false
                                                and context.rodinOrbs()
                                                and not bubbleBoss.orbPathSafe(point, prevGoal.p, speed)
                                            then
                                                bubbleBoss.goal = nil
                                            else
                                                if
                                                    config.bobOrbSolid ~= false
                                                    and bubbleBoss.bobOrbs
                                                    and #bubbleBoss.bobOrbs > 0
                                                    and not bubbleBoss.bobOrbPathSafe(
                                                        point,
                                                        prevGoal.p,
                                                        speed
                                                    )
                                                then
                                                    bubbleBoss.goal = nil
                                                else
                                                    if prevGoal.bad then
                                                        if
                                                            argument - prevGoal.at
                                                            > (config.bubbleBadCommit or 0.35)
                                                        then
                                                            bubbleBoss.goal = nil
                                                        elseif
                                                            lineEnters(prevGoal.p.X, prevGoal.p.Z, argument)
                                                        then
                                                            bubbleBoss.goal = nil
                                                        else
                                                            bubbleBoss.pickedSafe = false
                                                            bubbleBoss.pickedDist = pickedDist
                                                            return {
                                                                point = prevGoal.p,
                                                                soft = false,
                                                                label = ("ESCAPE %s -> last resort %.0f studs (held)"):format(
                                                                    tostring(prevGoal.name or "?"),
                                                                    pickedDist
                                                                ),
                                                            }
                                                        end
                                                    else
                                                        if
                                                            config.seekCrissWay ~= false
                                                            and bubbleBoss.crissLive
                                                            and not prevGoal.bad
                                                            and bubbleBoss.wayClear
                                                            and not bubbleBoss.wayClear(
                                                                point,
                                                                prevGoal.p,
                                                                speed,
                                                                argument
                                                            )
                                                        then
                                                            bubbleBoss.goal = nil
                                                            bubbleBoss.prevGoal = nil
                                                        else
                                                            if
                                                                fitsAt(
                                                                    prevGoal.p.X,
                                                                    prevGoal.p.Z,
                                                                    argument + pickedDist / speed
                                                                )
                                                                <= 0
                                                            then
                                                                bubbleBoss.goal = nil
                                                            else
                                                                if
                                                                    select(
                                                                        3,
                                                                        fitsAt(
                                                                            prevGoal.p.X,
                                                                            prevGoal.p.Z,
                                                                            argument
                                                                        )
                                                                    )
                                                                    >= 0
                                                                then
                                                                    bubbleBoss.goal = nil
                                                                else
                                                                    if
                                                                        prevGoal.noSpike
                                                                        and bubbleBoss.spikeSideAt
                                                                        and bubbleBoss.spikeSideAt(
                                                                            point,
                                                                            prevGoal.p,
                                                                            speed,
                                                                            argument
                                                                        )
                                                                    then
                                                                        bubbleBoss.goal = nil
                                                                    else
                                                                        if
                                                                            prevGoal.soft
                                                                            and bubbleBoss.lethal
                                                                        then
                                                                            bubbleBoss.goal = nil
                                                                        else
                                                                            local value107, value108, qP, value109 =
                                                                                (prevGoal.p.X - value[5])
                                                                                    / pickedDist,
                                                                                (prevGoal.p.Z - value[7])
                                                                                    / pickedDist,
                                                                                fitsAt(
                                                                                    value[5],
                                                                                    value[7],
                                                                                    argument
                                                                                )
                                                                            local value110, value111, value112 =
                                                                                value109 < 0,
                                                                                config.bubbleStep or 2,
                                                                                config.bubbleStep or 2
                                                                            argument3 = nil
                                                                            value109 = 0
                                                                            while value111 < pickedDist do
                                                                                value[169] = fitsAt
                                                                                value[168] = value107
                                                                                    * value111
                                                                                value[171] = value[5]
                                                                                    + value[168]
                                                                                value[170] = value108
                                                                                    * value111
                                                                                local hP, value113, value114 =
                                                                                    value[169](
                                                                                        value[171],
                                                                                        value[7] + value[170],
                                                                                        argument
                                                                                            + value111
                                                                                                / speed
                                                                                    )
                                                                                if
                                                                                    value114 >= 0
                                                                                    or value110
                                                                                        and value113 >= 0
                                                                                then
                                                                                    argument3 = value111
                                                                                    break
                                                                                end
                                                                                value[173] =
                                                                                    bubbleBoss.oldLineAt
                                                                                value[172] = value107
                                                                                    * value111
                                                                                value[175] = value[5]
                                                                                    + value[172]
                                                                                value[174] = value108
                                                                                    * value111
                                                                                if
                                                                                    value[173](
                                                                                        value[175],
                                                                                        value[7] + value[174],
                                                                                        argument
                                                                                            + value111
                                                                                                / speed,
                                                                                        0,
                                                                                        value[5],
                                                                                        value[7]
                                                                                    )
                                                                                then
                                                                                    argument3 = value111
                                                                                    break
                                                                                end
                                                                                if value113 < 0 then
                                                                                    value110, value109 =
                                                                                        true, value111
                                                                                end
                                                                                value111 = value111 + value112
                                                                            end
                                                                            if argument3 then
                                                                                if
                                                                                    context.BR
                                                                                    and context.BR.target
                                                                                    and context.BR.target.isBoss
                                                                                then
                                                                                    bubbleBoss.goal = nil
                                                                                else
                                                                                    value[22] = value109
                                                                                        - value112
                                                                                    value[176] = (
                                                                                        config.bubbleTrimMin
                                                                                        or 4
                                                                                    )
                                                                                    if
                                                                                        value[22]
                                                                                        >= value[176]
                                                                                    then
                                                                                        local value115
                                                                                        value[178] =
                                                                                            Vector3.new
                                                                                        value[177] = value107
                                                                                            * value[22]
                                                                                        value[180] = value[5]
                                                                                            + value[177]
                                                                                        value[181] =
                                                                                            prevGoal.p.Y
                                                                                        value[179] = value108
                                                                                            * value[22]
                                                                                        value115 = (
                                                                                            value[178](
                                                                                                value[180],
                                                                                                value[181],
                                                                                                value[7]
                                                                                                    + value[179]
                                                                                            )
                                                                                        )
                                                                                        pickedDist = value[22]
                                                                                        prevGoal.p = value115
                                                                                    else
                                                                                        bubbleBoss.goal = nil
                                                                                    end
                                                                                end
                                                                            end
                                                                            if bubbleBoss.goal then
                                                                                bubbleBoss.pickedSafe = true
                                                                                bubbleBoss.pickedDist =
                                                                                    pickedDist
                                                                                if prevGoal.soft then
                                                                                    if value47 then
                                                                                        if
                                                                                            helper24(
                                                                                                prevGoal.p
                                                                                            )
                                                                                        then
                                                                                            return (
                                                                                                helper25(
                                                                                                    "the way off it",
                                                                                                    prevGoal.p
                                                                                                )
                                                                                            )
                                                                                        end
                                                                                    end
                                                                                end
                                                                                return {
                                                                                    point = prevGoal.p,
                                                                                    soft = prevGoal.soft,
                                                                                    burst = bubbleBoss.stepIn
                                                                                            and not bubbleBoss.stepIn.out
                                                                                            and bubbleBoss.stepIn.speed
                                                                                        or nil,
                                                                                    label = ("%s %s -> gap %.0f studs (held%s)"):format(
                                                                                        prevGoal.soft
                                                                                                and "STEP OFF"
                                                                                            or "ESCAPE",
                                                                                        tostring(
                                                                                            prevGoal.name
                                                                                                or "?"
                                                                                        ),
                                                                                        pickedDist,
                                                                                        argument3
                                                                                                and ", trimmed"
                                                                                            or ""
                                                                                    ),
                                                                                }
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        local value116, value117 = 0, 0
        value[182] = argumentHelpers[108](pcall(function()
            return argument2.AssemblyLinearVelocity
        end))
        argument3 = value[182][1]
        value[21] = value[182][2]
        if argument3 and value[21] then
            value[8] = (sqrt(value[21].X * value[21].X + value[21].Z * value[21].Z))
            if value[8] > 3 then
                value116 = value[21].X / value[8]
                value117 = value[21].Z / value[8]
            end
        end
        local value118, value119
        if
            value116 == 0
            and value117 == 0
            and bubbleBoss.dir
            and argument - (bubbleBoss.dirAt or 0) < (config.bubbleStickFor or 1)
        then
            value116 = bubbleBoss.dir.X
            value117 = bubbleBoss.dir.Z
            value118, value119 = value116, value117
        else
            value118, value119 = value116, value117
        end
        local primary2, value120, value121 = bubbleBoss.primary, 0, 0
        value[22] = #value[9]
        for index29 = 1, value[22], 1 do
            value[183] = index29
            argument3 = value[9][value[183]]
            local value122, value123, value124 =
                (argument3.hard and 1 or 0.35) / (1 + (index29 - 1) * 0.5),
                helper10(argument3.box, value[5], value[7])
            value120 += value123 * value122
            value121 += value124 * value122
        end
        value[22] = (sqrt(value120 * value120 + value121 * value121))
        if value[22] > 0.001 then
            value[184] = value[22]
            value120 = value120 / value[184]
            value[185] = value[22]
            value121 = value121 / value[185]
        else
            value120, value121 = 0, 0
        end
        local value125, value126, value127, value128, value129, value130 = 0, 0, 0
        if primary2 and #value[9] >= 2 and value[22] < 0.45 then
            value[186] = primary2.box
            value[21] = value[186]
            argument3 = nil
            value[8] = nil
            local value131 = value126
            if
                value[21].moving
                and (value[21].kind == "wall" or (value[21].halfW or 0) > (value[21].halfL or 0) * 1.5)
            then
                argument3 = -value[21].dz
                value[8] = value[21].dx
                value126 = value[8]
            else
                if value[21].moving then
                    argument3 = value[21].dx
                    value[8] = value[21].dz
                    value126 = value[8]
                else
                    local value132 = value[21].r
                    if if value132 then not value132 else value[21].ax then
                        if (value[21].ha or 0) >= (value[21].hb or 0) then
                            argument3 = value[21].ax
                            value[8] = value[21].az
                            value126 = value[8]
                        else
                            argument3 = value[21].bx
                            value[8] = value[21].bz
                            value126 = value[8]
                        end
                    else
                        value126 = value[8]
                    end
                end
            end
            if argument3 then
                value127 = config.bubbleAlongBonus or 14
                value125 = argument3
            else
                value126 = value131
            end
            value128, value129, value130 = value125, value126, value127
        else
            value128, value129, value130 = value125, value126, value127
        end
        raycastParams.FilterDescendantsInstances = { sharedValue.LocalPlayer.Character, bubbleBoss.folder }
        value[21] = hazardReader.hub ~= nil
            and hazardReader.fanUntil ~= nil
            and argument < hazardReader.fanUntil + 1
        helper15(value[21] and (config.fanRays or 72) or config.bubbleRays)
        local escAway, value133, value134 = config.bubbleProbe, {}, 0
        for index30 = 1, #sharedValue17, 1 do
            value[8] = (toRadians(sharedValue17[index30]))
            value[22] = (
                parent:Raycast(
                    point + Vector3.new(0, 2, 0),
                    Vector3.new(cos(value[8]), 0, sin(value[8])) * escAway,
                    raycastParams
                )
            )
            argument3 = value[22] and value[22].Distance or escAway
            value133[index30] = argument3
            value134 += argument3
        end
        local value135
        local value136 = 0
        if config.escapeMelee ~= false then
            argument3 = config.escapeMeleeLook or 60
            value[8] = ipairs
            value[22] = hazardReader.enemies or {}
            for key5, entry5 in value[8](value[22]) do
                if
                    (entry5.melee or (entry5.isSpear or entry5.isMage) and config.escapeRanged ~= false)
                    and not entry5.isBoss
                    and entry5.root
                    and entry5.root.Parent
                    and (entry5.humanoid == nil or entry5.humanoid.Health > 0)
                then
                    local value137, value138 = entry5.x - value[5], entry5.z - value[7]
                    if value137 * value137 + value138 * value138 <= argument3 * argument3 then
                        value135 = value135 or {}
                        value136 += 1
                        value135[value136] = {
                            x = entry5.x,
                            z = entry5.z,
                            keep = entry5.melee and (config.escapeMeleeKeep or 26)
                                or (config.escapeRangedKeep or 18),
                        }
                    end
                end
            end
        end
        value[22] = context.BR and context.BR.target
        local value139 = value[22] ~= nil and value[22].isBoss == true
        bubbleBoss.runDx = nil
        bubbleBoss.runDz = nil
        if runtimeState.runOn then
            if runtimeState.runOn.d then
                if runtimeState.runOn.d > 1 then
                    if config.runOnDodge ~= false then
                        if not value139 then
                            value[187] = bubbleBoss
                            value[188] = bubbleBoss
                            value[189] = (runtimeState.runOn.x - value[5]) / runtimeState.runOn.d
                            value[190] = (runtimeState.runOn.z - value[7]) / runtimeState.runOn.d
                            value[187].runDx = value[189]
                            value[188].runDz = value[190]
                        end
                    end
                end
            end
        end
        local value140, value141 = 0, 0
        if config.escapeOrbit ~= false and not value139 and not runtimeState.runOn then
            local value142, value143, value144, value145 = config.escapeOrbitNear or 90, 0, 0, 0
            for index31, entry6 in ipairs(hazardReader.enemies or {}) do
                argument3 = entry6.isBoss
                if
                    (if argument3 then not argument3 else entry6.root)
                    and entry6.root.Parent
                    and (entry6.humanoid == nil or entry6.humanoid.Health > 0)
                then
                    value[22] = entry6.x - value[5]
                    index31 = entry6.z - value[7]
                    value[191] = value[22]
                    if value[22] * value[191] + index31 * index31 <= value142 * value142 then
                        value143, value144, value145 = value143 + entry6.x, value144 + entry6.z, value145 + 1
                    end
                end
            end
            if value145 > 0 then
                value[192] = value143 / value145
                value[8] = value[5] - value[192]
                value[193] = value144 / value145
                value142 = value[7] - value[193]
                value[195] = sqrt
                value[194] = value[8]
                local value146 = value[195](value[8] * value[194] + value142 * value142)
                if value146 > (config.escapeOrbitMin or 8) then
                    local value147 = runtimeState.orbitSide or context.BR and context.BR.strafeDir or 1
                    value140 = -(value142 / value146) * value147
                    value[196] = value146
                    value141 = value[8] / value[196] * value147
                    value147 = math.min(
                        (context.fireReach and context.fireReach() or 0) * (config.escapeOrbitShare or 0.45),
                        config.escapeOrbitCap or 44
                    )
                    if value146 < value147 then
                        local value148 = math.min((value147 - value146) / value147, 1)
                            * (config.escapeOrbitOut or 0.8)
                        value[197] = value146
                        local value149, value150 =
                            value140 + value[8] / value[197] * value148,
                            value141 + value142 / value146 * value148
                        value148 = sqrt(value149 * value149 + value150 * value150)
                        if value148 > 0.01 then
                            value140 = value149 / value148
                            value141 = value150 / value148
                        end
                    end
                end
            end
        end
        local value151, value152
        if
            config.orbitDodgeLean ~= false
            and runtimeState.orbitLive
            and not value139
            and context.orbitDir
        then
            value[198] = argumentHelpers[108](context.orbitDir(point, argument))
            value[8] = value[198][1]
            value[22] = value[198][2]
            if value[8] then
                value140 = value[8]
                value141 = value[22]
            end
            value151, value152 = value140, value141
        else
            value151, value152 = value140, value141
        end
        local value153, value154
        if config.escapeCorner ~= false and not value139 and (value120 ~= 0 or value121 ~= 0) then
            value[8] = -2
            argument3 = nil
            for index32 = 1, #sharedValue17, 1 do
                value[22] = (toRadians(sharedValue17[index32]))
                local value155 = cos(value[22]) * value120 + sin(value[22]) * value121
                if value155 > value[8] then
                    value[8] = value155
                    argument3 = index32
                end
            end
            if argument3 then
                value153 = value133[argument3]
            end
            value154 = value153
        else
            value154 = value153
        end
        value[8] = 1 - min(value134 / (#sharedValue17 * escAway), 1)
        value[200] = config.bubbleOpenWeight
        value[199] = config.bubbleCornerBoost
        local value156 = value[200] * (1 + value[8] * value[199])
        local value157, value158 = config.rodinOpenDodge ~= false
            and hazardReader.rodinRig ~= nil
            and hazardReader.rodinRig.Parent ~= nil
            and hazardReader.arenaCentre ~= nil
        if value157 then
            value156 *= config.rodinOpenBoost or 3
            value158 = value156
        else
            value158 = value156
        end
        local value159 = hazardReader.rodinSweep ~= nil
            and hazardReader.rodinSweep.model ~= nil
            and hazardReader.rodinSweep.model.Parent ~= nil
        value[201] = bubbleBoss
        value[201].enclosed = value[8]
        value[8] = primary2 and primary2.box or nil
        if value[8] ~= nil then
            value[202] = bubbleBoss.lastPrimaryBox
            value[22] = value[8] == value[202]
        end
        local value160, value161, value162, value163, value164, value165, value166, value167 = 0, 0, 0, 0
        if config.mobSideDodge ~= false and value[8] then
            argument3 = (string.lower(tostring(value[8].name or "")))
            if argument3 ~= "" and not argument3:find("boss", 1, true) then
                local value168, value169
                if value[8].moving and value[8].dx then
                    value168 = value[8].dx
                    value169 = value[8].dz
                else
                    local value170 = value[8].r
                    if if value170 then not value170 else value[8].ax then
                        if (value[8].ha or 0) >= (value[8].hb or 0) then
                            value168 = value[8].ax
                            value169 = value[8].az
                        else
                            value168 = value[8].bx
                            value169 = value[8].bz
                        end
                    end
                end
                if value168 == nil and value[8].cx then
                    value[203] = value[8].cx
                    value[205] = value[5] - value[203]
                    value[204] = value[8].cz
                    local value171, value172 = value[205], value[7] - value[204]
                    local value173 = sqrt(value171 * value171 + value172 * value172)
                    if value173 > 0.01 then
                        value168, value169 = value171 / value173, value172 / value173
                    end
                end
                local value174 = value168 and sqrt(value168 * value168 + value169 * value169) or 0
                if value174 > 0.01 then
                    value168 /= value174
                    value169 /= value174
                    local value175, value176, value177 =
                        -value169,
                        bubbleBoss.sideDir ~= nil
                            and argument - (bubbleBoss.sideAt or 0) <= (config.mobSideHold or 3)
                    if
                        if value176
                                and bubbleBoss.runDx
                                and bubbleBoss.sideDir.X * bubbleBoss.runDx
                                        + bubbleBoss.sideDir.Z * bubbleBoss.runDz
                                    < -(config.runOnSideCos or 0.2)
                            then false
                            else value176
                    then
                        if value175 * bubbleBoss.sideDir.X + value168 * bubbleBoss.sideDir.Z < 0 then
                            value175, value177 = -value175, -value168
                        else
                            value177 = value168
                        end
                    else
                        local value178, value179
                        if bubbleBoss.runDx then
                            value178, value179 = bubbleBoss.runDx, bubbleBoss.runDz
                        else
                            value178, value179 = value151, value152
                        end
                        if value178 == 0 and value179 == 0 then
                            value178, value179 = value118, value119
                        end
                        if value178 == 0 and value179 == 0 and bubbleBoss.dir then
                            value178, value179 = bubbleBoss.dir.X, bubbleBoss.dir.Z
                        end
                        if value178 ~= 0 or value179 ~= 0 then
                            if value178 * value175 + value179 * value168 < 0 then
                                value175, value177 = -value175, -value168
                            else
                                value177 = value168
                            end
                        else
                            local raycastResult, raycastResult2 =
                                parent:Raycast(
                                    point + Vector3.new(0, 2, 0),
                                    Vector3.new(value175, 0, value168) * escAway,
                                    raycastParams
                                ),
                                parent:Raycast(
                                    point + Vector3.new(0, 2, 0),
                                    Vector3.new(-value175, 0, -value168) * escAway,
                                    raycastParams
                                )
                            if
                                (raycastResult and raycastResult.Distance or escAway)
                                < (raycastResult2 and raycastResult2.Distance or escAway)
                            then
                                value175, value177 = -value175, -value168
                            else
                                value177 = value168
                            end
                        end
                    end
                    bubbleBoss.sideDir = Vector3.new(value175, 0, value177)
                    bubbleBoss.sideAt = argument
                    value160, value161, value162, value163 = value175, value177, value168, value169
                end
            end
            value164, value165, value166, value167 = value160, value161, value162, value163
        else
            value164, value165, value166, value167 = value160, value161, value162, value163
        end
        local value180, value181 = config.pitWall ~= false and point.Y < (config.dropArenaY or -40), 1
        local value182, value183, value184 =
            value[8] and tostring(value[8].name or "") or "", config.slamNoBack ~= false
        if value183 then
            value184 = value182 == "firstbossjumpslam"
                or value182 == "slam soon"
                or value182 == "slam incoming"
        else
            value184 = value183
        end
        if value182 == "firstbosspassivebeam" then
            value181 = config.closestOutMult or 4
        else
            if value182:find("secondbossspread", 1, true) then
                value181 = config.spreadOutMult or 10
            else
                if string.lower(value182):find("bigspike", 1, true) then
                    value181 = config.bigSpikeOutMult or 12
                else
                    if
                        string.lower(value182):find("secondbosshorizontal", 1, true)
                        or value182 == "beam next"
                    then
                        value181 = config.hbeamOutMult or 14
                    end
                end
            end
        end
        local value185, value186 = value184
        if (game.PlaceId == 101088859550383 or HLGS == true) and config.gsShortestOut ~= false then
            value181 = math.max(value181, config.gsClosestOutMult or 10)
            value186 = value181
        else
            value186 = value181
        end
        local value187, value188 = false
        if config.meleeNoFlip ~= false and primary2 ~= nil and primary2.box ~= nil then
            escAway = string.lower(tostring(primary2.box.name or ""))
            if
                escAway ~= ""
                and not string.find(escAway, "boss", 1, true)
                and (string.find(escAway, "strike", 1, true) or string.find(escAway, "swing", 1, true))
            then
                value187 = (primary2.tti or 9) <= (config.meleeNoFlipTti or 0.9)
            end
            value188 = value187
        else
            value188 = value187
        end
        local vector2, value189, value190 =
            config.odinRanks ~= false
                    and config.odinRankDodge ~= false
                    and hazardReader.ringBand
                    and context.odinBandOff ~= nil
                    and context.PB ~= nil
                    and context.PB.boss == "Odin"
                    and hazardReader.arenaCentre
                or nil,
            false
        if vector2 and config.odinRankExtend ~= false then
            escAway = primary2
                    and primary2.box
                    and primary2.box.castRed
                    and primary2.box.untilAt
                    and primary2.box.untilAt < infinity
                    and primary2.box.untilAt - argument
                or primary2 and primary2.tti
                or 9
            value189 = not (
                primary2 ~= nil
                and primary2.rank == 0
                and escAway < (config.cleanTtiFloor or 1.2)
            )
            value190 = value189
        else
            value190 = value189
        end
        local value191 = config.wrongPillarGuard ~= false
            and context.wrongPillarStep ~= nil
            and context.bobOrbsOnMe ~= nil
            and #context.bobOrbsOnMe() > 0
        local value192 = hazardReader.dodgeCentre
        local value193 = config.centreBias or 14
        if context.PB and context.PB.lean then
            escAway, value182 = context.PB.lean(argument, point, primary2)
            if escAway then
                value193 = value182 or value193
                value192 = escAway
            end
        end
        if vector2 then
            value[206] = vector2.X
            value183 = value[5] - value[206]
            value[207] = vector2.Z
            value182 = value[7] - value[207]
            argument3 = sqrt(value183 * value183 + value182 * value182)
            if argument3 > 1 and context.odinBandOff(argument3) > 0 then
                escAway =
                    math.clamp(argument3, (config.odinBandIn or 43.75) + 3, (config.odinRankOut or 81.25) - 3)
                value192 = (
                    Vector3.new(
                        vector2.X + value183 / argument3 * escAway,
                        value[6],
                        vector2.Z + value182 / argument3 * escAway
                    )
                )
                value193 = config.odinRankLean or 40
            else
                if
                    not (
                        hazardReader.missileAxis
                        and argument - hazardReader.missileAxis.t < 3
                        and context.PB.phase ~= "lines"
                    )
                then
                    value192 = nil
                end
            end
        end
        if hazardReader.orbLead and hazardReader.orbLead.goal then
            value192 = hazardReader.orbLead.goal
            value193 = config.orbDodgeBias or 30
        end
        local value194, value195, value196, value197, value198, value199, value200, value201
        if
            config.orbGuideDodge ~= false
            and hazardReader.orbLead
            and hazardReader.orbLead.goal
            and hazardReader.orbNear
            and hazardReader.orbNear.x
        then
            value196 = hazardReader.orbNear.x
            value197 = hazardReader.orbNear.z
            escAway, value182 = hazardReader.orbLead.goal.X - value196, hazardReader.orbLead.goal.Z - value197
            value183 = sqrt(escAway * escAway + value182 * value182)
            if value183 > 1 then
                value194 = escAway / value183
                value195 = value182 / value183
            end
            value198, value199, value200, value201 = value194, value195, value196, value197
        else
            value198, value199, value200, value201 = value194, value195, value196, value197
        end
        local value202, value203, value204, value205, value206, value207
        if config.orbRay ~= false and hazardReader.orbLead and hazardReader.orbLead.ray and value200 then
            value202 = hazardReader.orbLead.ray.ux
            value203 = hazardReader.orbLead.ray.uz
            value204 = hazardReader.orbLead.ray.dOC
            value205, value206, value207 = value202, value203, value204
        else
            value205, value206, value207 = value202, value203, value204
        end
        local value208, value209 = 0, 0
        local value210 = config.escapeGoalWeight or 28
        if
            config.escapeToGoal ~= false
            and context.BR
            and context.BR.goTo
            and context.BR.goToAt
            and argument - context.BR.goToAt < (config.escapeGoalFresh or 2)
        then
            escAway = context.BR.goTo.X - value[5]
            argument3 = context.BR.goTo.Z - value[7]
            value182 = sqrt(escAway * escAway + argument3 * argument3)
            if value182 > (config.escapeGoalMin or 6) then
                value208 = escAway / value182
                value209 = argument3 / value182
            end
            if
                (primary2 and primary2.box and string.lower(tostring(primary2.box.name or "")) or ""):find(
                    "spike",
                    1,
                    true
                )
            then
                value210 = config.escapeGoalSpikeWeight or 55
            end
        end
        bubbleBoss.runGoal = nil
        if
            config.escapeToUntagged ~= false
            and (runtimeState.sweeping == true or runtimeState.runOn and runtimeState.runOn.far and not value139)
            and context.nextUntagged
        then
            value183 = runtimeState.runOn and runtimeState.runOn.far and runtimeState.runOn
                or context.nextUntagged(value[5], value[7])
            if value183 and value183.d > (config.escapeGoalMin or 6) then
                value208 = (value183.x - value[5]) / value183.d
                value209 = (value183.z - value[7]) / value183.d
                escAway, argument3 = math.max, runtimeState.runOn and (config.runOnWeight or 150)
                value210 = escAway(value210, argument3 or (config.escapeUntaggedWeight or 45))
                value[208] = bubbleBoss
                value[209] = (Vector3.new(value183.x, value[6], value183.z))
                value[208].runGoal = value[209]
            end
        end
        if
            config.mageExitLean ~= false
            and runtimeState.mageExit
            and runtimeState.mageExit.q
            and argument - (runtimeState.mageExit.at or -infinity) < 0.3
        then
            value182 = runtimeState.mageExit.q.X - value[5]
            value183 = runtimeState.mageExit.q.Z - value[7]
            argument3 = sqrt(value182 * value182 + value183 * value183)
            if argument3 > 1 then
                value208 = value182 / argument3
                value209 = value183 / argument3
                value210 = math.max(value210, config.mageExitLeanW or 120)
                bubbleBoss.runGoal = runtimeState.mageExit.q
            end
        end
        if
            config.orbitDodgeLean ~= false
            and runtimeState.orbitLive
            and not runtimeState.mageExit
            and context.orbitDir
        then
            argument3, value183 = context.orbitDir(point, argument)
            if argument3 then
                value210 = runtimeState.runOn and (config.orbitDodgeLean or 60)
                    or math.max(value210, config.orbitDodgeLean or 60)
                value[210] = bubbleBoss
                value[212] = Vector3.new
                value[211] = argument3 * 20
                value[214] = value[5] + value[211]
                value[215] = value[6]
                value[213] = value183 * 20
                value[216] = (value[212](value[214], value[215], value[7] + value[213]))
                value[210].runGoal = value[216]
                value208, value209 = argument3, value183
            end
        end
        local value211
        bubbleBoss.bobLeanOn = false
        if context.bobReachLean and not hazardReader.orbLead then
            argument3 = primary2 and primary2.box and string.lower(tostring(primary2.box.name or "")) or ""
            value182 = argument3:find("spread", 1, true)
            if if value182 then not value182 else not argument3:find("spike", 1, true) then
                value[217] = argumentHelpers[108](context.bobReachLean(value[5], value[7], argument))
                escAway = value[217][1]
                value183 = value[217][2]
                if escAway then
                    local value212, value213 = escAway - value[5], value183 - value[7]
                    local value214 = sqrt(value212 * value212 + value213 * value213)
                    if value214 > (config.escapeGoalMin or 6) then
                        value208 = value212 / value214
                        value209 = value213 / value214
                        value211 = (Vector3.new(escAway, value[6], value183))
                        value210 = math.max(value210, config.bobEscapeLeanW or 40)
                        bubbleBoss.bobLeanOn = true
                    end
                end
            end
        end
        if config.escapeToLead ~= false and hazardReader.orbLead and hazardReader.orbLead.goal then
            argument3 = hazardReader.orbSteer
            value182, value183 =
                argument3
                        and argument3.p
                        and argument3.colour == hazardReader.orbLead.colour
                        and argument - (argument3.at or 0) < (config.escapeSteerFresh or 1.5)
                        and argument3.p
                    or hazardReader.orbLead.goal,
                config.spikeLeadPillar ~= false and value89
            if value183 then
                escAway = hazardReader.orbLead.goal
                if
                    (escAway.X - value[5]) ^ 2 + (escAway.Z - value[7]) ^ 2
                    >= ((config.escapeGoalMin or 6) + 2) ^ 2
                then
                    value182 = escAway
                else
                    local ray, value215, value216 = hazardReader.orbLead.ray
                    if ray and ray.ux then
                        value215, value216 = ray.ux, ray.uz
                    else
                        if hazardReader.orbLead.orb and hazardReader.orbLead.orb.Parent then
                            local value217, value218 =
                                escAway.X - hazardReader.orbLead.orb.Position.X,
                                escAway.Z - hazardReader.orbLead.orb.Position.Z
                            local value219 = sqrt(value217 * value217 + value218 * value218)
                            if value219 > 1 then
                                value215, value216 = value217 / value219, value218 / value219
                            end
                        end
                    end
                    value[223] = nil
                    if value215 then
                        value[219] = Vector3.new
                        value[218] = value215 * (config.spikeLeadOn or 30)
                        value[221] = value[5] + value[218]
                        value[222] = value[6]
                        value[220] = value216 * (config.spikeLeadOn or 30)
                        value[223] = value[219](value[221], value[222], value[7] + value[220])
                    else
                        value[223] = value182
                    end
                    value182 = value[223]
                end
            end
            local value220, value221 = value182.X - value[5], value182.Z - value[7]
            local value222 = sqrt(value220 * value220 + value221 * value221)
            if value222 > (config.escapeGoalMin or 6) then
                value208 = value220 / value222
                value209 = value221 / value222
                local value223 = primary2 and primary2.box and string.lower(tostring(primary2.box.name or ""))
                    or ""
                local value224 = value183 and (config.spikeLeadPillarW or 120)
                    or value223:find("spike", 1, true) and (config.escapeLeadSpikeWeight or 80)
                if value224 then
                    value210 = value224
                else
                    value210 = config.escapeLeadWeight or 40
                end
                value211 = value182
            end
        end
        local value225, value226, value227, value228, value229, value230 = false, 0, 0
        if
            config.pkEscapeSide ~= false
            and context.isEvent
            and context.isEvent()
            and context.BR
            and context.BR.target
            and context.BR.target.isBoss
            and context.BR.target.root
        then
            value183 = context.pkFanCentre and context.pkFanCentre(context.BR.target)
                or context.BR.target.root.Position
            value[224] = value183.X
            value182 = value[5] - value[224]
            value[225] = value183.Z
            argument3 = value[7] - value[225]
            escAway = sqrt(value182 * value182 + argument3 * argument3)
            if escAway > 1 then
                value225 = true
                value226 = value182 / escAway
                value227 = argument3 / escAway
            end
            value228, value229, value230 = value225, value226, value227
        else
            value228, value229, value230 = value225, value226, value227
        end
        local value231, value232, value233, value234, value235, value236, value237 = false
        if
            config.pkEscapeToCandy ~= false
            and context.PK
            and context.PK.goal
            and context.PK.greenLive
            and context.PK.greenLive()
        then
            argument3 = (context.PK.goal(Vector3.new(value[5], value[6], value[7])))
            if
                argument3
                and (config.pkCandyFanRule == true or context.pkNoHits and context.pkNoHits())
                and context.PK.fanWindow
                and context.PK.fanWindow()
                and context.BR
                and context.BR.target
                and context.BR.target.root
            then
                escAway = context.pkFanCentre and context.pkFanCentre(context.BR.target)
                    or context.BR.target.root.Position
                argument3 = if sqrt((argument3.X - escAway.X) ^ 2 + (argument3.Z - escAway.Z) ^ 2)
                        < (config.pkFanCandyFar or 30)
                    then nil
                    else argument3
            end
            if argument3 then
                value182 = argument3.X - value[5]
                value183 = argument3.Z - value[7]
                local value238 = sqrt(value182 * value182 + value183 * value183)
                if value238 > 2 then
                    value208 = value182 / value238
                    value209 = value183 / value238
                    value211 = (Vector3.new(argument3.X, value[6], argument3.Z))
                    value210 = math.max(value210, config.pkCandyEscapeW or 60)
                end
                value192 = (Vector3.new(argument3.X, value[6], argument3.Z))
                value193 = config.pkCandyLean or 30
                value231 = true
            end
            value232, value233, value234, value235, value236, value237 =
                value192, value193, value208, value209, value210, value211
        else
            value232, value233, value234, value235, value236, value237 =
                value192, value193, value208, value209, value210, value211
        end
        local value239, value240, value241, value242 = 0, 0
        if
            config.spikeHomePull ~= false
            and hazardReader.bobHome
            and not (value205 ~= nil and config.orbRayNoHome ~= false)
        then
            if
                (primary2 and primary2.box and string.lower(tostring(primary2.box.name or "")) or ""):find(
                    "spike",
                    1,
                    true
                )
            then
                value183 = context.bobPullTo and context.bobPullTo(argument) or hazardReader.bobHome
                escAway = value183.X - value[5]
                value182 = value183.Z - value[7]
                argument3 = sqrt(escAway * escAway + value182 * value182)
                if argument3 > (config.spikeHomeMin or 6) then
                    value239 = escAway / argument3
                    value240 = value182 / argument3
                end
            end
            value241, value242 = value239, value240
        else
            value241, value242 = value239, value240
        end
        local value243 = value[21] and (config.fanStep or 1.5) or config.bubbleStep
        value183 = config.bubbleMaxOut
        value183 = if primary2
                and primary2.tti
                and primary2.tti > 0
            then min(
                max(value183, primary2.tti * speed * (config.bubbleReachShare or 0.8)),
                config.bubbleProbe or 72
            )
            else value183
        value183 = if primary2
                and primary2.box
                and (
                    primary2.box.kind == "wall"
                    or primary2.box.moving and (primary2.box.halfW or 0) > (primary2.box.halfL or 0) * 1.5
                )
            then max(value183, config.bubbleProbe or 45)
            else value183
        local value244
        if config.escapeLanes ~= false then
            argument3, value182 = ipairs, hazardReader.enemies or {}
            for key6, entry7 in argument3(value182) do
                if
                    entry7.isSpear
                    and not entry7.isBoss
                    and entry7.root
                    and entry7.root.Parent
                    and (entry7.humanoid == nil or entry7.humanoid.Health > 0)
                then
                    value[21] = entry7.root.CFrame.LookVector
                    escAway = (sqrt(value[21].X * value[21].X + value[21].Z * value[21].Z))
                    if escAway > 0.01 then
                        value244 = value244 or {}
                        value[226] = #value244 + 1
                        value[227] = {}
                        value[227].x = entry7.x
                        value[227].z = entry7.z
                        value[227].dx = value[21].X / escAway
                        value[227].dz = value[21].Z / escAway
                        value[228] = value[227]
                        value244[value[226]] = value[228]
                    end
                end
            end
        end
        local function helper33(argument4, argument5)
            if not value244 then
                return 0
            end
            local value29 = 0
            for index14 = 1, #value244, 1 do
                local value30 = value244[index14]
                local value31, value32 = argument4 - value30.x, argument5 - value30.z
                index14 = value31 * value30.dx + value32 * value30.dz
                if index14 > -2 then
                    if index14 < (config.spearLaneLen or 140) then
                        local value36, value37 =
                            abs(value31 * -value30.dz + value32 * value30.dx),
                            (config.spearLaneWide or 11) * 0.5 + (config.spearLaneMargin or 8)
                        value29 = if value36 < value37
                            then value29 + (value37 - value36) / value37
                            else value29
                    end
                end
            end
            return value29
        end
        local value245, value246, value247, value248, value249, value250 = 0, 0
        if config.escapeRetreat ~= false then
            argument3 = context.BR and context.BR.target
            if
                argument3
                and not argument3.isBoss
                and argument3.root
                and argument3.root.Parent
                and (argument3.humanoid == nil or argument3.humanoid.Health > 0)
            then
                value245 = argument3.root.Position.X
                value246 = argument3.root.Position.Z
                value247 =
                    max((context.fireReach and context.fireReach() or 60) - (config.escapeHoldIn or 14), 30)
            end
            value248, value249, value250 = value245, value246, value247
        else
            value248, value249, value250 = value245, value246, value247
        end
        local value251
        local value252, value253, value254 = -infinity, infinity
        local value255, far, value256 = -infinity, false
        local value257 = -infinity
        local value258 = config.rodinYellowAvoid ~= false and context.rodinOrbs()
        local value259, value260 = value258 and bubbleBoss.blueBeams() or nil
        local value261, value262 = -infinity
        local value263 = -infinity
        bubbleBoss.nsFire, bubbleBoss.nsBest, bubbleBoss.nsScore = nil, nil, -infinity
        if
            config.beamSpikeSide ~= false
            and primary2
            and primary2.box
            and (primary2.box.name == "firstbosspassivebeam" or primary2.box.name == "beam next")
        then
            value182 = hazardReader.hitDelay and hazardReader.hitDelay.firstbosspassivebeam
            bubbleBoss.nsFire = primary2.box.fired and infinity
                or primary2.box.bornAt and primary2.box.bornAt + (value182 and value182.med or 0.916)
                or (primary2.box.untilAt or argument) - 0.45
        end
        local value264 = config.blueOrbSolid ~= false and context.rodinOrbs()
        local value265 = primary2 ~= nil and primary2.rank == 0 and (config.leanWhileLethal or 0.25) or 1
        if hazardReader.orbLead and hazardReader.orbLead.goal then
            value265 = config.orbLeanWhileLethal or 1
        end
        local value266
        if value231 then
            value265 = config.orbLeanWhileLethal or 1
            value266 = value265
        else
            value266 = value265
        end
        local value267
        local value268 = -infinity
        local value269, value270 = value103 * 0.5
        local value271 = infinity
        local value272 = min(config.bubbleMinRun or 6, value183)
        local value273 = softAt(value[5], value[7], argument)
        bubbleBoss.inside = value106 >= 0
        value182 = 0
        if
            primary2
            and primary2.rank == 0
            and primary2.tti <= (config.bubbleFirstAt or 1)
            and value[13] > 1
        then
            local value274, value275, value276 = primary2.tti + (config.bubbleFirstSlack or 0.6), {}, {}
            for index33 = 1, #value[9], 1 do
                value[229] = index33
                value[230] = value[9][value[229]].box
                value[231] = index33
                value[232] = value[9][value[231]].tti
                value275[value[230]] = value[232]
                value[233] = index33
                value[234] = value[9][value[233]].box
                value[235] = index33
                value[236] = value[9][value[235]].depth
                value276[value[234]] = value[236]
            end
            local function helper34(argument4)
                local value29 = value275[argument4]
                if value29 == nil then
                    return false
                elseif argument4 == primary2.box then
                    return false
                end
                return value29 > value274 + math.max(value276[argument4] or 0, 0) / speed
            end
            argument3 = nil
            for index34 = 1, value[13], 1 do
                value[237] = index34
                escAway = value[12][value[237]]
                value[10] = value275[escAway]
                if helper34(escAway) then
                    argument3 = argument3 or {}
                    argument3[#argument3 + 1] = escAway
                end
            end
            if argument3 then
                value[21] = 0
                for index35 = 1, value[13], 1 do
                    value[238] = index35
                    local value277 = value[12][value[238]]
                    value134 = value275[value277]
                    if not (helper34(value277)) then
                        value[239] = 1
                        value[21] = value[21] + value[239]
                        value[12][value[21]] = value277
                    end
                end
                for index36 = 1, #argument3, 1 do
                    value[240] = index36
                    value[241] = value[21] + value[240]
                    value[242] = argument3[index36]
                    value[12][value[241]] = value[242]
                end
                value182 = #argument3
                value[13] = value[21]
            end
        end
        local value278, value279
        local value280 = cos(toRadians(config.mageAxisBanDeg or 35))
        local value281 = bubbleBoss.wallsComing and bubbleBoss.wallsComing(value[5], value[7]) or nil
        if
            config.mageSideFirst ~= false
            and value[8]
            and bubbleBoss.isMageShot(value[8].name)
            and bubbleBoss.mageFace(point, value[8])
        then
            value[243] = argumentHelpers[108](bubbleBoss.mageFace(point, value[8]))
            escAway = value[243][1]
            argument3 = value[243][2]
            value280 = cos(toRadians(config.mageSideBanDeg or 45))
            value278, value279 = escAway, argument3
        else
            if config.mageAxisBanDeg ~= false and value[8] then
                value[21] = (tostring(value[8].name or ""))
                if
                    value[21] == "northernmageshot"
                    and hazardReader.lastRowDir
                    and argument - hazardReader.lastRowDir.t < 1.5
                then
                    value278 = hazardReader.lastRowDir.dx
                    value279 = hazardReader.lastRowDir.dz
                else
                    if value[21] == "wall" and value[8].moving and value[8].dx then
                        value278 = value[8].dx
                        value279 = value[8].dz
                    else
                        if
                            (
                                value[21] == "circle next"
                                or value[21] == "circle line"
                                or value[21] == "secondbosscriclehitbox"
                            )
                            and hazardReader.circleChain
                            and argument - (hazardReader.circleChain.lastAt or -infinity) < 2
                        then
                            value278 = hazardReader.circleChain.dx
                            value279 = hazardReader.circleChain.dz
                        else
                            if
                                string.lower(value[21]):find("seeking", 1, true)
                                and runtimeState.seekPart
                                and hazardReader.parts[runtimeState.seekPart]
                            then
                                local value282 = hazardReader.parts[runtimeState.seekPart]
                                local value283 = sqrt((value282.vx or 0) ^ 2 + (value282.vz or 0) ^ 2)
                                if value283 > 20 then
                                    value278 = value282.vx / value283
                                    value279 = value282.vz / value283
                                end
                            else
                                if value[21]:sub(1, 11) == "volley next" and value[8].rowDx then
                                    value278 = value[8].rowDx
                                    value279 = value[8].rowDz
                                end
                            end
                        end
                    end
                end
            end
        end
        value[244] = bubbleBoss
        value[245] = (game.PlaceId == 101088859550383 or HLGS == true)
            and (
                value[8] ~= nil and value[8].name == "gs circle" and config.gsCircleNearest ~= false
                or config.gsShortestOut ~= false
            )
        value[244].gsCircleNow = value[245]
        bubbleBoss.gsFwd = nil
        if bubbleBoss.gsCircleNow then
            if value[8] ~= nil then
                if value[8].name == "gs circle" then
                    if context.gsChainAxis then
                        value[246] = argumentHelpers[108](context.gsChainAxis(argument))
                        value[21] = value[246][1]
                        escAway = value[246][2]
                        if value[21] then
                            value[247] = bubbleBoss
                            value[248] = {}
                            value[248].x = value[21]
                            value[248].z = escAway
                            value[248].c = cos(toRadians(config.gsChainFwdDeg or 35))
                            value[249] = value[248]
                            value[247].gsFwd = value[249]
                        end
                    end
                end
            end
        end
        value[250] = bubbleBoss
        value[251] = context.gsSnakeBan and context.gsSnakeBan(value[8], value[5], value[7]) or nil
        value[250].gsSnake = value[251]
        if bubbleBoss.gsSnake then
            value278 = bubbleBoss.gsSnake.x
            value279 = bubbleBoss.gsSnake.z
            value280 = bubbleBoss.gsSnake.c
            bubbleBoss.gsFwd = nil
        end
        argument3 = bubbleBoss.gsCircleNow
        if
            (if argument3 then not argument3 else not value278)
            and value[8]
            and value[8].name == "gs circle"
            and context.gsChainAxis
        then
            value[252] = argumentHelpers[108](context.gsChainAxis(argument))
            value[21] = value[252][1]
            escAway = value[252][2]
            if value[21] then
                value280 = cos(toRadians(config.gsChainBanDeg or 45))
                value278 = value[21]
                value279 = escAway
            end
        end
        if (if value278 then not value278 else not bubbleBoss.gsCircleNow) and context.gsOrbitAxis then
            value[253] = argumentHelpers[108](context.gsOrbitAxis(value[5], value[7], argument))
            escAway = value[253][1]
            argument3 = value[253][2]
            if escAway then
                value280 = cos(toRadians(config.gsOrbitBanDeg or 45))
                value278, value279 = escAway, argument3
            end
        end
        bubbleBoss.gsBeamSide = nil
        if
            (if value278 then not value278 else not bubbleBoss.gsNearOnly)
            and config.gsBeamSideOn ~= false
            and context.gsBeamsShooting
            and context.gsShooterAxis
            and context.gsBeamsShooting(value[5], value[7], argument)
        then
            value[254] = bubbleBoss
            value[255] = bubbleBoss
            value[256] = argumentHelpers[108](context.gsShooterAxis(value[5], value[7]))
            value[254].sax = value[256][1]
            value[255].saz = value[256][2]
            if bubbleBoss.sax then
                value278 = bubbleBoss.sax
                value279 = bubbleBoss.saz
                value280 = cos(toRadians(config.gsBeamSideBanDeg or 50))
                bubbleBoss.gsBeamSide = true
            end
        end
        escAway, argument3 = if value278 then not value278 else not bubbleBoss.gsNearOnly
        if escAway then
            value[21] = bubbleBoss.gsCircleNow
            argument3 = if value[21]
                then context.gsBeamsShooting and context.gsBeamsShooting(value[5], value[7], argument)
                else not value[21]
        else
            argument3 = escAway
        end
        local value284, value285, value286
        if argument3 and context.gsSideAxis then
            value[257] = argumentHelpers[108](context.gsSideAxis(value[5], value[7]))
            escAway = value[257][1]
            value[21] = value[257][2]
            if escAway then
                value280 = cos(toRadians(config.gsSideBanDeg or 45))
                value278 = escAway
                value279 = value[21]
            end
            value284, value285, value286 = value278, value279, value280
        else
            value284, value285, value286 = value278, value279, value280
        end
        local value287, chasing = false
        if config.chaseRoomy ~= false and value[8] then
            argument3 = (string.lower(tostring(value[8].name or "")))
            escAway = argument3:find("seeking", 1, true) ~= nil
                or argument3:find("spike", 1, true) ~= nil
                or argument3:find("circle", 1, true) ~= nil
                or argument3:find("cricle", 1, true) ~= nil
                or argument3 == "northernmageshot"
                or argument3:sub(1, 11) == "volley next"
            if escAway then
                value287 = escAway
            else
                value287 = argument3 == "wall" and value[8].moving == true
            end
            chasing = value287
        else
            chasing = value287
        end
        value[21] = false
        argument3 = 0
        if config.bunchN ~= false and value[9] then
            escAway = {}
            local value288, value289 = 0, 0
            for index37 = 1, #value[9], 1 do
                value[258] = index37
                local value290 = value[9][value[258]]
                if
                    value290
                    and (value290.rank == nil or value290.rank == 0)
                    and (value290.depth or -infinity) >= -(config.bunchNear or 30)
                then
                    index37 = value290.box
                    local value291 = index37 and tostring(index37.name or "") or ""
                    if value291 == "northernmageshot" or value291:sub(1, 11) == "volley next" then
                        local value292, value293, value294 =
                            index37.rowDx or index37.ax, index37.rowDz or index37.az, "row"
                        if value292 and value293 then
                            local value295 = math.deg(math.atan2(value293, value292))
                            value295 = if value295 < 0 then value295 + 180 else value295
                            value294 = "row" .. tostring(math.floor(value295 / 12 + 0.5))
                        end
                        if not escAway[value294] then
                            escAway[value294] = true
                            argument3, value288 = argument3 + 1, value288 + 1
                        end
                    else
                        argument3, value289 = argument3 + 1, value289 + 1
                    end
                end
            end
            value[21] = argument3 >= (config.bunchN or 3) and (value289 >= 1 or value288 >= 3)
        end
        value[259] = bubbleBoss
        value[259].bunched = value[21]
        bubbleBoss.bunchCount = argument3
        bubbleBoss.chasing = chasing
        local value296, value297, value298 = config.volleyNoBack ~= false
            and value[21]
            and value[8]
            and context.burstBox
            and context.burstBox(value[8].name)
            and (value118 ~= 0 or value119 ~= 0)
        if config.keepGoing ~= false and bubbleBoss.escAway and not bubbleBoss.gsCircleNow then
            escAway = nil
            for key7, entry8 in pairs(bubbleBoss.escAway) do
                escAway = if (key7.untilAt or 0) > argument
                        and argument - entry8.at < (config.escNoBackFor or 2.5)
                        and (if escAway then entry8.at < escAway.at else not escAway)
                    then entry8
                    else escAway
            end
            if escAway then
                value297 = escAway.x
                value298 = escAway.z
            end
        end
        local value299, keepX, keepZ = config.oneWay ~= false
                and bubbleBoss.oneWay
                and argument - bubbleBoss.oneWay.last <= (config.oneWayQuiet or 3)
                and bubbleBoss.oneWay
            or nil
        if value299 and not value297 and config.keepGoing ~= false and not bubbleBoss.gsCircleNow then
            value297 = value299.x
            value298 = value299.z
            keepX, keepZ = value297, value298
        else
            keepX, keepZ = value297, value298
        end
        bubbleBoss.keepX = keepX
        bubbleBoss.keepZ = keepZ
        local value300
        if config.escapeNoBack ~= false and bubbleBoss.escAway and not bubbleBoss.gsCircleNow then
            argument3, escAway = pairs, bubbleBoss.escAway
            for key8, entry9 in argument3(escAway) do
                if (key8.untilAt or 0) > argument and argument - entry9.at < (config.escNoBackFor or 2.5) then
                    if key8 ~= value[8] then
                        value300 = value300 or {}
                        value300[#value300 + 1] = entry9
                    end
                else
                    bubbleBoss.escAway[key8] = nil
                end
            end
        end
        if value299 and not bubbleBoss.gsCircleNow then
            value300 = value300 or {}
            value300[#value300 + 1] = value299
        end
        local value301, value302, value303 = config.stepIn ~= false and not soft, {}, {}
        local value304 = (config.dodgeBudgetMs or 6) / 1000
        local value305 = value304 * 2
        bubbleBoss.hardB = (tonumber(config.dodgeHardMs) or 16) / 1000
        function bubbleBoss.overHard()
            local value29 = config.dodgeHardMs ~= false
                and os.clock() - value[1] > bubbleBoss.hardB
                and (value251 ~= nil or value254 ~= nil or value256 ~= nil or value267 ~= nil)
            return value29
        end
        bubbleBoss.scanMemo = bubbleBoss.scanMemo
            or { C = {}, D = {}, E = {}, O = {}, H = {}, S = {}, L = {} }
        bubbleBoss.scanMemo.on = config.perfMemo ~= false
        bubbleBoss.scanMemo.clear = bubbleBoss.scanMemo.clear
            or function(argument4)
                local value29 = { "C", "D", "E", "O", "H", "S", "L" }
                for index14, entry4 in ipairs(value29) do
                    table.clear(argument4[entry4])
                end
            end
        bubbleBoss.scanMemo:clear()
        function bubbleBoss.scanMemo.hold(argument4, argument5, argument6)
            local value29 = config.arriveHold or 1
            for index14 = 1, 2, 1 do
                local value30, Co, value31 = fitsAt(argument4, argument5, argument6 + value29 * index14 / 2)
                if value30 <= 0 then
                    return false
                elseif value31 >= 0 then
                    return false
                end
            end
            if bubbleBoss.beamWhite then
                for entry4 in pairs(bubbleBoss.beamWhite) do
                    value29 = (
                        helper3(
                            entry4,
                            argument4,
                            value[6],
                            argument5,
                            argument6,
                            value[4],
                            config.bubbleLead
                        )
                    )
                    if value29 then
                        if value29 >= -helper8(entry4, value[2], value[11]) then
                            return false
                        end
                    end
                end
            end
            return true
        end
        local function pickedDist2(argument4, argument5)
            local value29 = {}
            value29[1] = bubbleBoss
            value29[2] = context.gsOrbWedge and context.gsOrbWedge(value[5], value[7]) or nil
            value29[1].gsWedge = value29[2]
            for index14, entry4 in ipairs(sharedValue17) do
                repeat
                    if config.dodgeBudgetMs ~= false and index14 % 2 == 0 then
                        local value30 = os.clock() - value[1]
                        argument5 = if value30 > value305
                            then (max(argument5, 4))
                            else if value30 > value304 then (max(argument5, 2)) else argument5
                        if bubbleBoss.overHard() then
                            runtimeState.dodgeCut = (runtimeState.dodgeCut or 0) + 1
                            return
                        end
                    end
                    if argument5 > 1 then
                        if index14 % argument5 ~= 0 then
                            break
                        end
                    end
                    local free = toRadians(entry4)
                    local value31, value32 = cos(free), sin(free)
                    if value185 then
                        local value36, value37 = 0, 0
                        if bubbleBoss.dir then
                            value36, value37 = bubbleBoss.dir.X, bubbleBoss.dir.Z
                        else
                            if value118 ~= 0 then
                                value36, value37 = value118, value119
                            else
                                if value119 ~= 0 then
                                    value36, value37 = value118, value119
                                end
                            end
                        end
                        if value36 ~= 0 or value37 ~= 0 then
                            if value31 * value36 + value32 * value37 < -(config.slamBackCos or 0.2) then
                                break
                            end
                        end
                    end
                    if value284 then
                        if math.abs(value31 * value284 + value32 * value285) > value286 then
                            break
                        end
                    end
                    if value281 then
                        if bubbleBoss.towardWall(value31, value32, value281) then
                            break
                        end
                    end
                    if value296 then
                        if value31 * value118 + value32 * value119 < -(config.volleyBackCos or 0.5) then
                            break
                        end
                    end
                    if bubbleBoss.gsFwd then
                        if
                            value31 * bubbleBoss.gsFwd.x + value32 * bubbleBoss.gsFwd.z > bubbleBoss.gsFwd.c
                        then
                            break
                        end
                    end
                    if bubbleBoss.gsWedge then
                        if
                            value31 * bubbleBoss.gsWedge.x + value32 * bubbleBoss.gsWedge.z
                            > bubbleBoss.gsWedge.c
                        then
                            break
                        end
                    end
                    if value300 then
                        free = false
                        for index21, entry10 in ipairs(value300) do
                            if value31 * entry10.x + value32 * entry10.z < -(config.escBackCos or 0.2) then
                                free = true
                                break
                            end
                        end
                        if free then
                            break
                        end
                    end
                    free = value133[index14]
                    if free >= 5 then
                        local yellow, dist, value38, value39, dist2, dist3, margin, value40, dist4, margin2, value41, dist5, margin3, value42, dist6, margin4 =
                            max(min(argument4, free - (config.wallClear or 5)), 0),
                            value243,
                            value106 < 0,
                            -infinity
                        local soft2 = 0
                        while dist <= yellow do
                            local value43, value44, value45, value90, margin5, value91, value92 =
                                value[5] + value31 * dist,
                                value[7] + value32 * dist,
                                argument + dist / speed,
                                index14 * 100000 + math.floor(dist * 100 + 0.5)
                            if bubbleBoss.scanMemo.on then
                                margin5, value91 =
                                    bubbleBoss.scanMemo.C[value90], bubbleBoss.scanMemo.D[value90]
                                value92 = bubbleBoss.scanMemo.E[value90]
                            end
                            if margin5 == nil then
                                local value93, value94, value95 = fitsAt(value43, value44, value45)
                                if bubbleBoss.scanMemo.on then
                                    bubbleBoss.scanMemo.C[value90], bubbleBoss.scanMemo.D[value90], bubbleBoss.scanMemo.E[value90] =
                                        value93, value94, value95
                                end
                                margin5, value91, value92 = value93, value94, value95
                            end
                            if config.drawScan then
                                if not context.NOVIS then
                                    if (bubbleBoss.scanN or 0) < 240 then
                                        if index14 % 2 == 0 then
                                            local scanN = (bubbleBoss.scanN or 0) + 1
                                            bubbleBoss.scanN = scanN
                                            local value96 = bubbleBoss.scanNodes[scanN]
                                            if not value96 then
                                                value96 = {}
                                                bubbleBoss.scanNodes[scanN] = value96
                                            end
                                            value96.x = value43
                                            value96.z = value44
                                            value96.v = value91 == infinity and 3
                                                or (value92 >= 0 or value38 and value91 >= 0) and 2
                                                or (value91 >= 0 or margin5 <= 0) and 4
                                                or (softAt(value43, value44, value45) > value269 and 1 or 0)
                                        end
                                    end
                                end
                            end
                            local value97 = value39
                            if value92 >= 0 or value38 and value91 >= 0 then
                                value39 = if margin5 > value97 then margin5 else value97
                                break
                            end
                            local value98 = if bubbleBoss.scanMemo.on
                                then bubbleBoss.scanMemo.O[value90]
                                else nil
                            if value98 == nil then
                                value98 = bubbleBoss.oldLineAt(
                                    value43,
                                    value44,
                                    value45,
                                    0,
                                    value[5],
                                    value[7]
                                ) and true or false
                                if bubbleBoss.scanMemo.on then
                                    bubbleBoss.scanMemo.O[value90] = value98
                                end
                            end
                            if value98 then
                                value39 = value97
                                break
                            end
                            value38, value98 = if value91 < 0 then true else value38, false
                            if margin5 > 0 then
                                value98 = if bubbleBoss.scanMemo.on
                                    then bubbleBoss.scanMemo.H[value90]
                                    else value98
                                if value98 == nil or not bubbleBoss.scanMemo.on then
                                    value98 = bubbleBoss.scanMemo.hold(value43, value44, value45)
                                    if bubbleBoss.scanMemo.on then
                                        bubbleBoss.scanMemo.H[value90] = value98
                                    end
                                end
                            end
                            dist2 = if (if value98 then not value98 else margin5 > 0)
                                    and value301
                                    and not dist2
                                then if dist >= value272 then dist else dist2
                                else dist2
                            if value98 then
                                local soft3 = bubbleBoss.scanMemo.on and bubbleBoss.scanMemo.S[value90] or nil
                                if soft3 == nil then
                                    soft3 = softAt(value43, value44, value45)
                                    if bubbleBoss.scanMemo.on then
                                        bubbleBoss.scanMemo.S[value90] = soft3
                                    end
                                end
                                if if soft then soft3 <= value269 else not soft then
                                    local value99 = bubbleBoss.scanMemo.on and bubbleBoss.scanMemo.L[value90]
                                        or nil
                                    if value99 == nil then
                                        value99 =
                                            softAt(value43, value44, value45 + (config.bubbleSoftLook or 1.2))
                                        if bubbleBoss.scanMemo.on then
                                            bubbleBoss.scanMemo.L[value90] = value99
                                        end
                                    end
                                    local value100 = value99 > soft3 and value99 or soft3
                                    if dist3 == nil then
                                        dist3, margin, value40 = dist, margin5, value100
                                    end
                                    if dist >= value272 then
                                        if
                                            value258
                                            and bubbleBoss.yellowAt(value43, value44, value45, value259)
                                        then
                                            if not dist4 then
                                                dist4, margin2, value41 = dist, margin5, value100
                                            end
                                        else
                                            if
                                                value190
                                                and context.odinBandOff(
                                                        sqrt(
                                                            (value43 - vector2.X) ^ 2
                                                                + (value44 - vector2.Z) ^ 2
                                                        )
                                                    )
                                                    > (config.odinRankSlack or 1)
                                            then
                                                if not dist5 then
                                                    dist5, margin3, value42 = dist, margin5, value100
                                                end
                                            else
                                                value39, dist6, margin4, soft2 =
                                                    value97, dist, margin5, value100
                                                break
                                            end
                                        end
                                    end
                                end
                                if soft3 < value271 then
                                    value271, value270 =
                                        soft3, {
                                            dx = value31,
                                            dz = value32,
                                            dist = dist,
                                            free = free,
                                            margin = margin5,
                                            soft = soft3,
                                        }
                                end
                            end
                            value39 = if margin5 > value97 then margin5 else value97
                            if dist5 then
                                if dist - dist5 >= (config.odinRankExtMax or 24) then
                                    break
                                end
                                dist += config.odinRankExtStep or 3
                            else
                                dist += value243
                            end
                        end
                        if dist2 then
                            yellow = math.floor(entry4 * 10 + 0.5)
                            if not value303[yellow] then
                                value303[yellow] = true
                                value302[#value302 + 1] = { dx = value31, dz = value32, dist = dist2 }
                            end
                        end
                        if
                            dist5
                            and (
                                if dist6
                                    then (dist6 - dist5) * config.bubbleNearWeight * value186
                                        > context.odinBandOff(
                                                sqrt(
                                                    (value[5] + value31 * dist5 - vector2.X) ^ 2
                                                        + (value[7] + value32 * dist5 - vector2.Z) ^ 2
                                                )
                                            )
                                            * (config.odinRankEscW or 8)
                                    else not dist6
                            )
                        then
                            dist6, margin4, soft2 = dist5, margin3, value42
                        end
                        yellow = false
                        if if dist6 then not dist6 else dist4 then
                            dist6, margin4, soft2, yellow = dist4, margin2, value41, true
                        end
                        if if dist6 then not dist6 else dist3 then
                            yellow = value258
                                    and bubbleBoss.yellowAt(
                                        value[5] + value31 * dist3,
                                        value[7] + value32 * dist3,
                                        argument + dist3 / speed,
                                        value259
                                    )
                                or false
                            dist6, margin4, soft2 = dist3, margin, value40
                        end
                        local value101 = dist6 or free
                        local function helper35(argument6, argument7)
                            if config.ledgeGuard == false then
                                return true
                            end
                            return parent:Raycast(
                                Vector3.new(argument6, point.Y + 3, argument7),
                                Vector3.new(0, -(3 + (config.ledgeDrop or 7)), 0),
                                raycastParams
                            ) ~= nil
                        end
                        if dist6 and not helper35(value[5] + value31 * dist6, value[7] + value32 * dist6) then
                            bubbleBoss.ledgeCuts = (bubbleBoss.ledgeCuts or 0) + 1
                            free, dist6 = if free > value101 then (min(free, value101)) else free, nil
                        end
                        dist6 = if dist6
                                and (
                                    value264
                                        and not bubbleBoss.orbPathSafe(
                                            point,
                                            Vector3.new(
                                                value[5] + value31 * dist6,
                                                value[6],
                                                value[7] + value32 * dist6
                                            ),
                                            speed
                                        )
                                    or value[28]
                                        and not bubbleBoss.bobOrbPathSafe(
                                            point,
                                            Vector3.new(
                                                value[5] + value31 * dist6,
                                                value[6],
                                                value[7] + value32 * dist6
                                            ),
                                            speed
                                        )
                                )
                            then nil
                            else dist6
                        local value102, value306, value307, value308 =
                            value31 * value120 + value32 * value121,
                            value130 * abs(value31 * value128 + value32 * value129),
                            0,
                            runtimeState.groupPlan
                        local value309, value310 = value308 and value308.x
                        if value309 then
                            value101 = runtimeState.groupPlanAt == nil
                            if value101 then
                                value310 = value101
                            else
                                local value311 = sharedValue2
                                value310 = value311 - runtimeState.groupPlanAt < (config.pullPlanFor or 3)
                            end
                        else
                            value310 = value309
                        end
                        if value310 then
                            value309 = value308.x - value[5]
                            value101 = value308.z - value[7]
                            local value312 = sqrt(value309 * value309 + value101 * value101)
                            value307 = if value312 > 4
                                then (value31 * value309 + value32 * value101) / value312
                                else value307
                        end
                        value309 = 0
                        if value232 then
                            value101 = value232.X - value[5]
                            value310 = value232.Z - value[7]
                            value308 = sqrt(value101 * value101 + value310 * value310)
                            value309 = if value308 > 1
                                then (value31 * value101 + value32 * value310) / value308
                                else value309
                        end
                        value310 = config.bubbleWallMargin or 30
                        local value313, value314, value315, value316 =
                            free < value[2] + value310
                                    and (value[2] + value310 - free) * config.bubbleWallPenalty
                                or 0,
                            bubbleBoss.dir
                                    and argument - (bubbleBoss.dirAt or 0) < (config.bubbleStickFor or 1)
                                    and value31 * bubbleBoss.dir.X + value32 * bubbleBoss.dir.Z
                                or 0,
                            value118 ~= 0 or value119 ~= 0
                        if value315 then
                            value101, value308 =
                                (1 - (value31 * value118 + value32 * value119)) * 0.5, config.bubbleTurnCost
                            local value317, value318 =
                                value101 * (value308 or 30),
                                bubbleBoss.gsCircleNow and (config.gsTurnScale or 0.35)
                            value316 = value317 * (value318 or 1)
                        else
                            value316 = value315
                        end
                        value310 = value316 or 0
                        value310 = if keepX
                            then value310
                                + (1 - (value31 * keepX + value32 * keepZ))
                                    * 0.5
                                    * (config.keepGoingCost or 40)
                            else value310
                        value310 = if bubbleBoss.gsCircleNow and context.gsPullCost
                            then value310
                                + context.gsPullCost(value[5], value[7], value31, value32)
                                    * context.gsNearScale()
                            else value310
                        value310 = if bubbleBoss.gsCircleNow and context.gsSideCost
                            then value310
                                + context.gsSideCost(value[5], value[7], value31, value32)
                                    * context.gsNearScale()
                            else value310
                        value310 = if bubbleBoss.gsCircleNow and context.gsOrbitBackCost
                            then value310
                                + context.gsOrbitBackCost(value[5], value[7], value31, value32)
                                    * context.gsNearScale()
                            else value310
                        value310 = if bubbleBoss.gsCircleNow and context.gsOrbitFwdCost
                            then value310 - context.gsOrbitFwdCost(value[5], value[7], value31, value32)
                            else value310
                        if
                            bubbleBoss.gsCircleNow
                            and config.gsKeepHeading ~= false
                            and (value118 ~= 0 or value119 ~= 0)
                        then
                            value316 = value31 * value118 + value32 * value119
                            value310 = if value316 < 0
                                then value310 - value316 * (config.gsKeepHeadingW or 600) * context.gsNearScale()
                                else value310
                            if config.gsBlockKeep ~= false and context.gsBlocksActive then
                                if context.gsBlocksActive(argument) then
                                    value315, value308 = (1 - value316) * 0.5, config.gsBlockKeepW
                                    local value319, value320 =
                                        value315 * (value308 or 2000),
                                        bubbleBoss.gsNearOnly and (config.gsBlockKeepInAttack or 0.25)
                                    value310 += value319 * (value320 or 1)
                                end
                            end
                        end
                        value316, value315 = 0, bubbleBoss.anchor or bubbleBoss.dir
                        if
                            value315
                            and argument
                                    - (bubbleBoss.anchor and bubbleBoss.anchorAt or bubbleBoss.dirAt or 0)
                                < (config.bubbleNoFlip or 1.2)
                        then
                            value101 = value31 * value315.X + value32 * value315.Z
                            if value101 < -0.2 then
                                if
                                    not (
                                        bubbleBoss.runDx
                                        and value31 * bubbleBoss.runDx + value32 * bubbleBoss.runDz
                                            > (config.runOnFlipCos or 0.3)
                                    )
                                then
                                    local value321, bubbleFlipPenalty = -value101, config.bubbleFlipPenalty
                                    local value322, value323 =
                                        value321 * (bubbleFlipPenalty or 40),
                                        bubbleBoss.gsCircleNow and (config.gsTurnScale or 0.35)
                                    value316 = value322 * (value323 or 1)
                                end
                            end
                            value316 = if value188
                                then if value101 < (config.meleeFlipCos or 0.5)
                                    then value316
                                        + ((config.meleeFlipCos or 0.5) - value101)
                                            * (config.bubbleFlipPenalty or 40)
                                            * (config.meleeFlipMult or 3)
                                    else value316
                                else value316
                        end
                        value315, value101 = 0, 0
                        if value164 ~= 0 or value165 ~= 0 then
                            local value324, value325 =
                                value31 * value164 + value32 * value165,
                                value31 * value166 + value32 * value167
                            if value324 >= 0 then
                                value308 = min(free / (config.sideRoomFull or 30), 1)
                                value101 = -value324 * (config.mobSideWeight or 55) * value308
                            else
                                value101 = -value324 * (config.mobSideCross or 140)
                            end
                            value101 += abs(value325) * (config.mobSideBackCost or 18)
                        end
                        if dist6 then
                            if value180 then
                                local value326, value327 = free - dist6, config.pitWallPad or 10
                                value315 = if value326 < value327
                                    then min(
                                        (value327 - value326) * (config.pitWallWeight or 6),
                                        config.pitWallCap or 60
                                    )
                                    else value315
                            end
                            local value328, value329, value330 =
                                value[5] + value31 * dist6, value[7] + value32 * dist6, 0
                            for index22 = 1, 4, 1 do
                                value308 = index22 / 5
                                index22 = (
                                    softAt(
                                        value[5] + value31 * dist6 * value308,
                                        value[7] + value32 * dist6 * value308,
                                        argument + dist6 * value308 / speed
                                    )
                                )
                                value330 = if index22 > value330 then index22 else value330
                            end
                            local value331, value332, value333 =
                                (dist3 or dist6) / speed, helper32(value328, value329), 0
                            if config.mageEscapePull ~= false and hazardReader.mageMid then
                                if
                                    (hazardReader.warriorNearD or 1000000000) < (config.mageEscapeFrom or 40)
                                then
                                    local value334, value335 =
                                        hazardReader.mageMid.x - value[5], hazardReader.mageMid.z - value[7]
                                    local value336 = sqrt(value334 * value334 + value335 * value335)
                                    value333 = if value336 > 6
                                        then (value31 * value334 + value32 * value335) / value336
                                        else value333
                                end
                            end
                            local value337, value338 =
                                hazardReader.noGoExit and (config.noGoExitCross or 0.2) or 1, 0
                            if (config.noGoEndCost or 0) > 0 then
                                if helper13(value328, value[6], value329) then
                                    local value339, value340 =
                                        runtimeState.reflex ~= nil and runtimeState.reflex.name == "slam"
                                            or runtimeState.tellRun ~= nil,
                                        false
                                    if
                                        config.noGoEndSpike ~= false
                                        and not value339
                                        and bubbleBoss.primary
                                    then
                                        if bubbleBoss.primary.box then
                                            local name2 = bubbleBoss.primary.box.name
                                            value340 = name2 ~= nil
                                                and string.find(
                                                        string.lower(tostring(name2)),
                                                        "spike",
                                                        1,
                                                        true
                                                    )
                                                    ~= nil
                                        end
                                    end
                                    local value341
                                    value341, value340 = config.noGoEndCost or 45, value339 or value340
                                    value338 = value341
                                        * (value340 and (config.noGoEndSlamShare or 0.33) or 1)
                                end
                            end
                            local value342 = 0
                            if context.OD and context.OD.inRingBand and context.OD.setList then
                                if #context.OD.setList > 0 then
                                    local value343 = config.ringSlim or 2.5
                                    local value344 = if context.OD.inRingBand(
                                            value328,
                                            value329,
                                            argument + dist6 / speed,
                                            value343
                                        )
                                        then config.ringEndCost or 90
                                        else value342
                                    for index23 = 1, 4, 1 do
                                        local value345 = index23 / 5
                                        if
                                            context.OD.inRingBand(
                                                value[5] + value31 * dist6 * value345,
                                                value[7] + value32 * dist6 * value345,
                                                argument + dist6 * value345 / speed,
                                                value343
                                            )
                                        then
                                            value344 += config.ringCrossCost or 22
                                            break
                                        end
                                    end
                                    value342 = value344
                                end
                            end
                            local value346 = 0
                            if value244 then
                                local value347 = (helper33(value328, value329))
                                for index38 = 1, 4, 1 do
                                    local value348 = index38 / 5
                                    index38 = (
                                        helper33(
                                            value[5] + value31 * dist6 * value348,
                                            value[7] + value32 * dist6 * value348
                                        )
                                    )
                                    value347 = if index38 > value347 then index38 else value347
                                end
                                value346 = if value347 > 0
                                    then min(
                                        value347 * (config.escapeLaneWeight or 20),
                                        config.escapeLaneCap or 55
                                    )
                                    else value346
                            end
                            local value349, value350 =
                                if value154 and value154 < (config.escapeCornerAt or 26)
                                    then if value102 > 0
                                        then value102
                                            * ((config.escapeCornerAt or 26) - value154)
                                            * (config.escapeCornerWeight or 2.2)
                                        else 0
                                    else 0,
                                0
                            if value250 then
                                local value351, value352 =
                                    sqrt((value328 - value248) ^ 2 + (value329 - value249) ^ 2),
                                    sqrt((value[5] - value248) ^ 2 + (value[7] - value249) ^ 2)
                                value350 = if value351 > value250
                                    then if value351 > value352
                                        then min(
                                            (value351 - max(value250, value352))
                                                * (config.escapeRetreatWeight or 5),
                                            config.escapeRetreatCap or 80
                                        )
                                        else value350
                                    else value350
                            end
                            local value353 = 0
                            if value135 then
                                local value354 = config.escapeMeleeKeep or 26
                                local value355, value356 = value354, 0
                                for index39 = 0, 4, 1 do
                                    local value357 = index39 == 0 and 1 or index39 / 5
                                    local value358, value359 =
                                        value[5] + value31 * dist6 * value357,
                                        value[7] + value32 * dist6 * value357
                                    value355 = value354
                                    for index40 = 1, value136, 1 do
                                        value357 = value135[index40]
                                        index39, index40 = value358 - value357.x, value359 - value357.z
                                        local value360 = sqrt(index39 * index39 + index40 * index40)
                                        value354 = value357.keep or value355
                                        if value360 < value354 then
                                            index40 = (value354 - value360) / value354
                                            value356 = if index40 > value356 then index40 else value356
                                        end
                                    end
                                end
                                value353 = value356 * (config.escapeMeleeCost or 120)
                            end
                            local value361, value362 =
                                value346 + value350 + value349 + value353, config.escapePenCap or 90
                            if value361 > value362 then
                                if value361 > 0 then
                                    local value363 = value362 / value361
                                    local value364, value365, value366, value367 =
                                        value346 * value363,
                                        value350 * value363,
                                        value349 * value363,
                                        value353 * value363
                                    value346, value349, value350, value353 =
                                        value364, value366, value365, value367
                                end
                            end
                            local value368, value369, value370 =
                                (value151 ~= 0 or value152 ~= 0) and value31 * value151 + value32 * value152
                                    or 0,
                                (value234 ~= 0 or value235 ~= 0) and value31 * value234 + value32 * value235
                                    or 0,
                                0
                            if
                                (value234 ~= 0 or value235 ~= 0)
                                and config.escapeTrip ~= false
                                and (value237 or context.BR.goTo or bubbleBoss.runGoal)
                            then
                                value361 = context.BR.goTo
                                        and context.BR.goToAt
                                        and argument - context.BR.goToAt < (config.escapeGoalFresh or 2)
                                        and context.BR.goTo
                                    or nil
                                value362 = value237
                                    or (runtimeState.runOn or runtimeState.orbitLive or runtimeState.mageExit) and bubbleBoss.runGoal
                                    or value361
                                    or bubbleBoss.runGoal
                                    or context.BR.goTo
                                local value371 =
                                    sqrt((value362.X - value[5]) ^ 2 + (value362.Z - value[7]) ^ 2)
                                value370 = max(
                                    dist6
                                        + sqrt((value362.X - value328) ^ 2 + (value362.Z - value329) ^ 2)
                                        - value371,
                                    0
                                ) * (config.escapeTripWeight or 2)
                            end
                            if value157 then
                                if not value159 then
                                    value361 = hazardReader.arenaCentre
                                    value362 = sqrt((value328 - value361.X) ^ 2 + (value329 - value361.Z) ^ 2)
                                    local value372, value373 =
                                        value370
                                            + max(value362 - (config.rodinOpenR or 62), 0)
                                                * (config.rodinOpenCost or 5),
                                        hazardReader.rodinSplit
                                    value372 = if config.rodinRingDodge ~= false
                                        then if value373
                                                and value373.model
                                                and value373.model.Parent
                                                and not value373.over
                                            then value372
                                            else value372 + max(
                                                (
                                                    config.rodinRestR ~= false
                                                        and (config.rodinRestR or 40)
                                                    or (hazardReader.rodinRingR or config.rodinRingR or 56)
                                                )
                                                    - (config.rodinRingBand or 6)
                                                    - value362,
                                                0
                                            ) * (config.rodinRingInCost or 2)
                                        else value372
                                    value373 = (
                                        sqrt((value[5] - value361.X) ^ 2 + (value[7] - value361.Z) ^ 2)
                                    )
                                    if value373 > (config.rodinOutwardR or 60) then
                                        local value374 = (
                                            value31 * (value[5] - value361.X)
                                            + value32 * (value[7] - value361.Z)
                                        ) / value373
                                        value370 = if value374 > 0
                                            then value372 + value374 * (config.rodinOutwardCost or 40)
                                            else value372
                                    else
                                        value370 = value372
                                    end
                                end
                            end
                            if value157 and value159 then
                                if config.rodinSweepDodgeMid ~= false then
                                    value362, value361 =
                                        if context.sweepHotAt
                                            then if context.sweepHotAt(
                                                    value328,
                                                    value329,
                                                    argument + dist6 / max(speed, 1) + 0.5,
                                                    argument
                                                )
                                                then value370 + (config.rodinSweepHotCost or 400)
                                                else value370
                                            else value370,
                                        hazardReader.rodinSweepSafe
                                    value362 = if value361
                                        then if argument - (value361.at or -infinity) < 0.5
                                            then value362 + max(
                                                abs(
                                                    (value328 - value361.x) * -value361.az
                                                        + (value329 - value361.z) * value361.ax
                                                )
                                                    - (config.rodinSweepMidBand or 10),
                                                0
                                            ) * (config.rodinSweepMidCost or 3)
                                            else value362
                                        else value362
                                    local arenaCentre2 = hazardReader.arenaCentre
                                    value370 = value362
                                        + max(
                                                sqrt(
                                                    (value328 - arenaCentre2.X) ^ 2
                                                        + (value329 - arenaCentre2.Z) ^ 2
                                                )
                                                    - (config.rodinSweepWallR or 88),
                                                0
                                            )
                                            * (config.rodinSweepWallCost or 6)
                                end
                            end
                            value361 = hazardReader.rodinSplit
                            value370 = if config.rodinSplitDodgeLine ~= false
                                    and value361
                                    and value361.nx
                                    and value361.model
                                    and value361.model.Parent
                                then if value361.over
                                    then value370
                                    else value370 + max(
                                        abs(
                                            (value328 - value361.cx) * value361.nx
                                                + (value329 - value361.cz) * value361.nz
                                        )
                                            - (config.rodinSplitStand or 5.5)
                                            - 2,
                                        0
                                    ) * (config.rodinSplitLineCost or 6)
                                else value370
                            value370 = if bubbleBoss.gsCircleNow
                                then if context.gsReachAt
                                    then value370 + context.gsReachAt(value328, value329) * context.gsKcScale(
                                        value[5],
                                        value[7]
                                    )
                                    else value370
                                else value370
                            value370 = if bubbleBoss.gsCircleNow
                                then if context.gsRoomAt
                                    then value370 + context.gsRoomAt(
                                        value328,
                                        value[6],
                                        value329,
                                        dist6 / max(speed, 1)
                                    ) * (config.gsAreaFirst ~= false and not (context.gsB1Lanes and context.gsB1Lanes()) and 1 or context.gsKcScale(
                                        value[5],
                                        value[7]
                                    ))
                                    else value370
                                else value370
                            value370 = if bubbleBoss.gsCircleNow
                                then if context.gsWallOpenCost
                                    then value370 + context.gsWallOpenCost(
                                        value328,
                                        value[6],
                                        value329,
                                        dist6 / max(speed, 1)
                                    ) * (config.gsAreaFirst ~= false and not (context.gsB1Lanes and context.gsB1Lanes()) and 1 or context.gsKcScale(
                                        value[5],
                                        value[7]
                                    ))
                                    else value370
                                else value370
                            if
                                bubbleBoss.gsCircleNow
                                and context.gsKcRoomCost
                                and (config.gsRoomAlways ~= false or context.gsInKc(value[5], value[7]))
                            then
                                value362 = (
                                    context.gsKcRoomCost(value328, value[6], value329, value31, value32)
                                )
                                value361 = config.gsAreaFirst ~= false
                                        and not (context.gsB1Lanes and context.gsB1Lanes())
                                        and 1
                                    or (
                                        config.gsRoomAlways ~= false and context.gsNearScale()
                                        or context.gsKcScale(value[5], value[7])
                                    )
                                value370 += value362 * value361
                            end
                            value370 = if bubbleBoss.gsCircleNow and context.gsKcGraze
                                then if context.gsInKc(value[5], value[7])
                                    then value370 + context.gsKcGraze(
                                        value[5],
                                        value[6],
                                        value[7],
                                        value31,
                                        value32,
                                        dist6,
                                        speed
                                    )
                                    else value370
                                else value370
                            value370 = if bubbleBoss.gsCircleNow
                                then if context.gsLateCost
                                    then value370 + context.gsLateCost(
                                        primary2,
                                        value[5],
                                        value[6],
                                        value[7],
                                        value31,
                                        value32,
                                        speed
                                    )
                                    else value370
                                else value370
                            value370 = if bubbleBoss.gsCircleNow
                                then if context.gsTurnBackCost
                                    then value370 + context.gsTurnBackCost(value31, value32)
                                    else value370
                                else value370
                            value370 = if bubbleBoss.gsCircleNow and context.gsInnerCost
                                then value370 + context.gsInnerCost(value[5], value[7], value31, value32)
                                else value370
                            value370 = if bubbleBoss.gsSnake and context.gsSnakeSideCost
                                then value370 + context.gsSnakeSideCost(value31, value32)
                                else value370
                            value370 = if bubbleBoss.gsCircleNow and context.gsOrbRailCost
                                then value370
                                    + context.gsOrbRailCost(value328, value329)
                                        * (config.gsKcStudCost or 45)
                                        * context.gsKcScale(value[5], value[7])
                                else value370
                            value370 = if bubbleBoss.gsCircleNow and context.gsConeCost
                                then value370
                                    + context.gsConeCost(value328, value329, value[6])
                                        * context.gsKcScale(value[5], value[7])
                                else value370
                            value370 = if bubbleBoss.gsCircleNow and context.gsOrbitDistCost
                                then value370 + context.gsOrbitDistCost(value328, value329) * context.gsKcScale(
                                    value[5],
                                    value[7]
                                )
                                else value370
                            value370 = if bubbleBoss.gsCircleNow
                                    and context.gsOrbitDistCost
                                    and config.gsOnOrbitDodge ~= false
                                    and context.gsKcScale(value[5], value[7]) < 1
                                then value370 + math.min(
                                    context.gsOrbitDistCost(value328, value329) / (config.gsOrbitStayW or 24),
                                    config.gsOnOrbitCap or 10
                                ) * (config.gsOnOrbitW or 120) * context.gsNearScale()
                                else value370
                            value370 = if bubbleBoss.gsCircleNow and context.gsBossBodyCost
                                then value370 + context.gsBossBodyCost(value328, value329)
                                else value370
                            value370 = if bubbleBoss.gsCircleNow and context.gsEdgeCost
                                then value370 + context.gsEdgeCost(value328, value329) * context.gsKcScale(
                                    value[5],
                                    value[7]
                                )
                                else value370
                            value370 = if config.orbLaneAvoid ~= false and value[19] > 0
                                then if bubbleBoss.orbLaneAt(value328, value329)
                                    then value370 + (config.orbLaneEndCost or 60)
                                    else if bubbleBoss.orbLaneHit(
                                            value[5],
                                            value[7],
                                            value328,
                                            value329
                                        )
                                        then value370 + (config.orbLaneCrossCost or 25)
                                        else value370
                                else value370
                            value361 = 0
                            if bubbleBoss.osc then
                                value362 = bubbleBoss.osc
                                value361 = abs(value31 * value362.ax + value32 * value362.az)
                                    * (config.oscAxisCost or 45)
                                value361 = if value362.dir
                                    then value361
                                        - (value31 * value362.dir.X + value32 * value362.dir.Z)
                                            * (config.oscStick or 35)
                                    else value361
                            end
                            local value375, value376, value377 =
                                (value241 ~= 0 or value242 ~= 0) and value31 * value241 + value32 * value242
                                    or 0,
                                0,
                                0
                            if value205 then
                                local value378, value379 = value328 - value200, value329 - value201
                                local value380, value381 =
                                    value378 * value205 + value379 * value206,
                                    value378 * value206 - value379 * value205
                                value381 = if value381 < 0 then -value381 else value381
                                value362 = value207 + (config.orbRayBehindMin or 4) - value380
                                value377 = if value362 > 0
                                    then value377 - min(
                                        value362 * (config.orbRayFrontCost or 4),
                                        config.orbRayFrontCap or 80
                                    )
                                    else value377
                                value379 = value381 - (config.orbRayLatFree or 6)
                                value377 = if value379 > 0
                                    then value377 - min(
                                        value379 * (config.orbRayLatCost or 2.5),
                                        config.orbRayLatCap or 60
                                    )
                                    else value377
                                if value380 >= value207 then
                                    value379 = 1 - value381 / (config.orbRayLatSpan or 24)
                                    value377 = if value379 > 0
                                        then value377 + value379 * (config.orbRayWeight or 40)
                                        else value377
                                end
                            else
                                if value198 then
                                    local value382, value383 = value328 - value200, value329 - value201
                                    local value384 = sqrt(value382 * value382 + value383 * value383)
                                    value376 = if value384 > 1
                                        then (value382 * value198 + value383 * value199) / value384
                                        else value376
                                end
                            end
                            local nsScore, value385 = -dist6, config.bubbleNearWeight
                            local value386, value387 =
                                nsScore * value385 * value186,
                                bubbleBoss.gsCircleNow
                                    and config.gsMostArea ~= false
                                    and not (context.gsB1Lanes and context.gsB1Lanes())
                                    and (config.gsMostAreaNear or 0.15)
                            value385, value362 =
                                value386 * (value387 or 1) + free * value158, min(margin4, 12)
                            value387, nsScore = value385 + value362 * 1.5, config.bubbleLeaveWeight
                            value386, value385 =
                                value387 - value331 * (nsScore or 12) - value338 + value102 * 3,
                                sharedValue9 and (config.spikeStickWeight or 60)
                            nsScore = value386
                                + value314 * (value385 or (config.bubbleStickWeight or 6))
                                - value310
                                + (value306 + value309 * value233 - helper31(value328, value329)) * value266
                                - value313
                                - value316
                                - soft2 * value337
                                + value307 * (config.pullWeight or 8) * (config.bubbleSoftPick or 6)
                                - value330 * (config.bubbleCrossCost or 14) * value337
                                - value332
                                + value333 * (config.mageEscapePullWeight or 14)
                                - value342
                                - value101
                                - value315
                                - value346
                                - value350
                                - value349
                                + value368 * (config.escapeOrbitWeight or 34)
                                - value353
                                + value376 * (config.orbGuideWeight or 34)
                                + value377
                                + value369 * (bubbleBoss.bobLeanOn and primary2 ~= nil and primary2.rank == 0 and dist6 / max(
                                    speed,
                                    1
                                ) > (primary2.tti or 9) - (config.cleanTtiMargin or 0.15) and 0 or value236)
                                + value375 * (config.spikeHomeWeight or 30)
                                - value370
                                - value361
                            nsScore = if bubbleBoss.gsNearOnly
                                    and not (
                                        bubbleBoss.gsCircleNow
                                        and config.gsMostArea ~= false
                                        and not (context.gsB1Lanes and context.gsB1Lanes())
                                    )
                                then nsScore - dist6 * (config.gsNearStudW or 255)
                                else nsScore
                            nsScore = if bubbleBoss.gsNearOnly
                                    and config.gsNearWall ~= false
                                    and free < dist6 + (config.gsNearWallClear or 12)
                                then nsScore
                                    - (dist6 + (config.gsNearWallClear or 12) - free)
                                        * (config.gsNearWallW or 150)
                                else nsScore
                            nsScore = if value191
                                    and context.wrongPillarStep(
                                        point,
                                        Vector3.new(value328, value[6], value329)
                                    )
                                then nsScore - (config.wrongPillarCost or 800)
                                else nsScore
                            nsScore = if vector2
                                then nsScore - min(
                                    context.odinBandOff(
                                        sqrt((value328 - vector2.X) ^ 2 + (value329 - vector2.Z) ^ 2)
                                    )
                                        * (config.odinRankEscW or 8),
                                    config.odinRankEscCap or 240
                                )
                                else nsScore
                            if bubbleBoss.cmH then
                                value361 = bubbleBoss.cmF
                                    - sqrt(
                                        (value328 - bubbleBoss.cmH.X) ^ 2 + (value329 - bubbleBoss.cmH.Z) ^ 2
                                    )
                                nsScore = if value361 > 0
                                    then nsScore - min(
                                        value361 * (config.champMidEscW or 8),
                                        config.champMidEscCap or 240
                                    )
                                    else nsScore
                            end
                            nsScore = if bubbleBoss.orbMidX
                                then nsScore
                                    + (value31 * bubbleBoss.orbMidX + value32 * bubbleBoss.orbMidZ)
                                        * (bubbleBoss.orbMidW or config.gsOrbMidW or 150)
                                else nsScore
                            if bubbleBoss.mageCommitX then
                                value385 = value31 * bubbleBoss.mageCommitX + value32 * bubbleBoss.mageCommitZ
                                nsScore = if value385 < 0
                                    then nsScore + value385 * (config.mageBackCost or 500)
                                    else nsScore
                            end
                            if config.mageArc ~= false and context.mageGap then
                                value361, value337, value386 = context.mageGap(value328, value329)
                                value375 = config.mageArcMin or 220
                                nsScore = if value386 >= 2
                                    then if value361 < value375
                                        then nsScore - math.min(
                                            (value375 - value361) * (config.escapeMageArcWeight or 0.6),
                                            config.escapeMageArcCap or 80
                                        )
                                        else nsScore
                                    else nsScore
                                nsScore = if value386 >= 2
                                    then if context.mageArcBad(value328, value329, value[5], value[7])
                                        then nsScore - (config.escapeMageArcHard or 600)
                                        else nsScore
                                    else nsScore
                            end
                            value387 = config.escapeCone ~= false
                                and not value139
                                and context.mobCone
                                and (nsScore > value252 or nsScore > value255 or nsScore > value257)
                            if value387 then
                                value362 = (context.mobCone(value328, value329, nil, value[6]))
                                value368 = config.escapeConeFrom or config.orbitConeSoft or 120
                                nsScore = if value362 > value368
                                    then nsScore - math.min(
                                        (value362 - value368) * (config.escapeConeWeight or 1.5),
                                        config.escapeConeCap or 180
                                    )
                                    else nsScore
                            end
                            nsScore = if context.PK
                                    and context.PK.redOnPath
                                    and context.PK.redOnPath(value[5], value[7], value328, value329)
                                then nsScore - (config.pkRedPathCost or 5000)
                                else nsScore
                            if value228 then
                                value368 = value31 * value229 + value32 * value230
                                nsScore = nsScore
                                    + (1 - math.abs(value368)) * (config.pkSideW or 30)
                                    - math.max(value368, 0) * (config.pkAwayW or 30)
                            end
                            value385, value386, value331, value369 =
                                false,
                                value258 and not yellow and (nsScore > value261 or nsScore > value263),
                                config.escapeNoCross ~= false
                            if value331 then
                                value386 = nsScore > value252
                                    or nsScore > value255
                                    or nsScore > value257
                                    or value386
                                value369 = value386
                                    or bubbleBoss.nsFire ~= nil and nsScore > bubbleBoss.nsScore
                            else
                                value369 = value331
                            end
                            if value369 then
                                value385 = (
                                    bubbleBoss.pathBlocked(
                                        point,
                                        Vector3.new(value328, value[6], value329),
                                        speed
                                    )
                                )
                                if value385 then
                                    value331, value361 =
                                        nsScore - (config.escapeCrossCost or 400),
                                        config.mageArc ~= false
                                            and hazardReader.mageArcList
                                            and #hazardReader.mageArcList >= 2
                                            and (config.escapeMageArcHard or 600)
                                    nsScore = value331 - (value361 or 0)
                                end
                            end
                            if nsScore > value252 then
                                value362 = nil
                                value362, value252 =
                                    {
                                        dx = value31,
                                        dz = value32,
                                        dist = dist6,
                                        free = free,
                                        margin = margin4,
                                        soft = soft2,
                                        far = far,
                                        yellow = yellow,
                                    }, nsScore
                                value251 = value362
                            end
                            if dist6 < value253 then
                                value253 = dist6
                            end
                            if value258 then
                                if yellow then
                                elseif value385 then
                                elseif nsScore > value261 then
                                    value362 = nil
                                    value362, value261 =
                                        {
                                            dx = value31,
                                            dz = value32,
                                            dist = dist6,
                                            free = free,
                                            margin = margin4,
                                            soft = soft2,
                                            far = far,
                                        }, nsScore
                                    value260 = value362
                                end
                            end
                            if bubbleBoss.nsFire then
                                if not value385 then
                                    if nsScore > bubbleBoss.nsScore then
                                        if
                                            dist6 / speed
                                            <= bubbleBoss.nsFire
                                                - argument
                                                - (config.beamSideSpare or 0.15)
                                        then
                                            if
                                                not (
                                                    bubbleBoss.spikeSideAt(
                                                        point,
                                                        Vector3.new(value328, value[6], value329),
                                                        speed,
                                                        argument
                                                    )
                                                )
                                            then
                                                bubbleBoss.nsScore, bubbleBoss.nsBest =
                                                    nsScore, {
                                                        dx = value31,
                                                        dz = value32,
                                                        dist = dist6,
                                                        free = free,
                                                        margin = margin4,
                                                        soft = soft2,
                                                        far = far,
                                                    }
                                            end
                                        end
                                    end
                                end
                            end
                            if not value385 then
                                if soft2 <= value269 then
                                    if value330 <= max(value269, value273) then
                                        if value332 <= 0 then
                                            if value342 <= 0 then
                                                if nsScore > value255 then
                                                    value329 = nil
                                                    value329, value255 =
                                                        {
                                                            dx = value31,
                                                            dz = value32,
                                                            dist = dist6,
                                                            free = free,
                                                            margin = margin4,
                                                            soft = soft2,
                                                            far = far,
                                                            clean = true,
                                                            yellow = yellow,
                                                        }, nsScore
                                                    value254 = value329
                                                end
                                                if value258 then
                                                    if not yellow then
                                                        if nsScore > value263 then
                                                            value328 = nil
                                                            value328, value263 =
                                                                {
                                                                    dx = value31,
                                                                    dz = value32,
                                                                    dist = dist6,
                                                                    free = free,
                                                                    margin = margin4,
                                                                    soft = soft2,
                                                                    far = far,
                                                                    clean = true,
                                                                }, nsScore
                                                            value262 = value328
                                                        end
                                                    end
                                                end
                                                value368 = chasing and (config.chaseRoomyMargin or 16)
                                                    or (config.roomyMargin or 10)
                                                if margin4 >= value368 then
                                                    if nsScore > value257 then
                                                        value386 = nil
                                                        value386, value257 =
                                                            {
                                                                dx = value31,
                                                                dz = value32,
                                                                dist = dist6,
                                                                free = free,
                                                                margin = margin4,
                                                                soft = soft2,
                                                                far = far,
                                                                clean = true,
                                                                roomy = true,
                                                                yellow = yellow,
                                                            }, nsScore
                                                        value256 = value386
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            local value388 = max(min(argument4, free - 3), 3)
                            value388 = if helper35(
                                    value[5] + value31 * value388,
                                    value[7] + value32 * value388
                                )
                                then value388
                                else 3
                            local dist7, value389 = bubbleBoss.oldLineCut(
                                value[5],
                                value[7],
                                value31,
                                value32,
                                value388,
                                speed,
                                argument
                            )
                            local value390 = value316 * max(0, 1 - value39 * (config.flipDangerFree or 3))
                            local value391 = value39 * 10
                                + free * value158
                                + value102 * 6
                                + value314 * 3
                                - value310
                                + value306
                                - value313
                                - value390
                                - value101
                                - max(
                                        softAt(
                                            value[5] + value31 * dist7,
                                            value[7] + value32 * dist7,
                                            argument + dist7 / speed
                                        ),
                                        softAt(
                                            value[5] + value31 * dist7,
                                            value[7] + value32 * dist7,
                                            argument + dist7 / speed + (config.bubbleSoftLook or 1.2)
                                        )
                                    )
                                    * (config.bubbleBadSoft or 3)
                            value391 = if value389
                                then value391 - (config.oldLineBadCost or 2000)
                                else value391
                            value391 = if context.PK
                                    and context.PK.redOnPath
                                    and context.PK.redOnPath(
                                        value[5],
                                        value[7],
                                        value[5] + value31 * dist7,
                                        value[7] + value32 * dist7
                                    )
                                then value391 - (config.pkRedPathCost or 5000)
                                else value391
                            if value228 then
                                value389 = value31 * value229 + value32 * value230
                                value391 = value391
                                    + (1 - math.abs(value389)) * (config.pkSideW or 30)
                                    - math.max(value389, 0) * (config.pkAwayW or 30)
                            end
                            if bubbleBoss.mageCommitX then
                                value390 = value31 * bubbleBoss.mageCommitX + value32 * bubbleBoss.mageCommitZ
                                value391 = if value390 < 0
                                    then value391 + value390 * (config.mageBackCost or 500)
                                    else value391
                            end
                            if value391 > value268 then
                                if
                                    not (
                                        value264
                                        and not bubbleBoss.orbPathSafe(
                                            point,
                                            Vector3.new(
                                                value[5] + value31 * dist7,
                                                value[6],
                                                value[7] + value32 * dist7
                                            ),
                                            speed
                                        )
                                    )
                                then
                                    if
                                        not (
                                            value[28]
                                            and not bubbleBoss.bobOrbPathSafe(
                                                point,
                                                Vector3.new(
                                                    value[5] + value31 * dist7,
                                                    value[6],
                                                    value[7] + value32 * dist7
                                                ),
                                                speed
                                            )
                                        )
                                    then
                                        value390 = nil
                                        value390, value268 =
                                            { dx = value31, dz = value32, dist = dist7, free = free },
                                            value391
                                        value267 = value390
                                    end
                                end
                            end
                        end
                    end
                until true
            end
        end
        if bubbleBoss.union then
            value185, value284, value281, value296, value300, keepX, keepZ, sharedValue15, sharedValue11, sharedValue12, sharedValue10, sharedValue8 =
                nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
            bubbleBoss.gsFwd = nil
        end
        if bubbleBoss.gsSnake then
            value284 = bubbleBoss.gsSnake.x
            value285 = bubbleBoss.gsSnake.z
            value286 = bubbleBoss.gsSnake.c
        end
        bubbleBoss.fsW = runtimeState.gsFwd
        if
            config.gsFirstOrbit ~= false
            and context.gsFirstStrikeOn
            and bubbleBoss.fsW
            and bubbleBoss.fsW.cx
            and bubbleBoss.fsW.dir
            and bubbleBoss.fsW.at
            and argument - bubbleBoss.fsW.at >= 0
            and argument - bubbleBoss.fsW.at < 0.5
            and context.gsFirstStrikeOn(argument)
        then
            value[260] = bubbleBoss
            value[261] = bubbleBoss
            value[262] = bubbleBoss.fsW.cx
            value[263] = value[5] - value[262]
            value[264] = bubbleBoss.fsW.cz
            value[265] = value[7] - value[264]
            value[260].fsRx = value[263]
            value[261].fsRz = value[265]
            bubbleBoss.fsRl = sqrt(bubbleBoss.fsRx * bubbleBoss.fsRx + bubbleBoss.fsRz * bubbleBoss.fsRz)
            if bubbleBoss.fsRl > 1 then
                value300 = value300 or {}
                value300[#value300 + 1] = {
                    x = -bubbleBoss.fsRz / bubbleBoss.fsRl * bubbleBoss.fsW.dir,
                    z = bubbleBoss.fsRx / bubbleBoss.fsRl * bubbleBoss.fsW.dir,
                    orbit = true,
                }
                runtimeState.gsFirstOrbitDodge = argument
            end
        end
        bubbleBoss.scanN = 0
        pickedDist2(value183, 1)
        if
            (not value256 or value[21])
            and (config.bubbleFarOut or 70) > value183
            and not bubbleBoss.overHard()
        then
            far = true
            pickedDist2(config.bubbleFarOut or 70, value[21] and 2 or 3)
            far = false
        end
        if value296 and not value251 and not value254 and not value256 and not value267 then
            value296 = false
            pickedDist2(value183, 1)
        end
        if value300 and not value251 and not value254 and not value256 and not value267 then
            value300 = nil
            pickedDist2(value183, 1)
        end
        if
            value284
            and not value251
            and not value254
            and not value256
            and not (bubbleBoss.gsBeamSide and value267)
        then
            argument3 = value284
            value284 = nil
            pickedDist2(value183, 1)
            value284 = argument3
        end
        if value281 and not value251 and not value254 and not value256 and not value267 then
            argument3 = value281
            value281 = nil
            pickedDist2(value183, 1)
            value281 = argument3
        end
        if sharedValue8 then
            if not value256 then
                value299 = sharedValue9 and (value251 or value254 or value267)
                if not value299 then
                    argument3 = sharedValue8
                    sharedValue8 = nil
                    bubbleBoss.scanMemo:clear()
                    pickedDist2(value183, 1)
                    sharedValue8 = argument3
                end
            end
        end
        local value392 = primary2
                and primary2.box
                and primary2.box.castRed
                and primary2.box.untilAt
                and primary2.box.untilAt < infinity
                and primary2.box.untilAt - argument
            or primary2 and primary2.tti
            or 9
        local value393 = primary2 ~= nil and primary2.rank == 0 and value392 < (config.cleanTtiFloor or 1.2)
        local function helper36(argument4)
            local value29 = argument4 ~= nil
                and (
                    (
                        if value393
                            then argument4.dist / speed <= value392 - (config.cleanTtiMargin or 0.15)
                            else not value393
                    )
                    or value251 ~= nil and argument4.dist <= value251.dist + (config.cleanHurryExtra or 0)
                )
            return value29
        end
        local function helper37(argument4)
            if argument4 == nil then
                return false
            end
            if argument4.far then
                if value254 then
                    if not value254.far then
                        return false
                    end
                end
            end
            if value251 == nil then
                return true
            end
            if value106 >= 0 then
                local dist, value29 = argument4.dist, value253
                return dist <= value29 + (config.insideExtra or 6) / value186
            end
            if (value251.soft or 0) > value269 then
                if argument4.dist / speed <= (config.cleanFarTime or 1) then
                    return true
                end
            end
            local dist2, value30 =
                argument4.dist, math.min(value253, value251.dist) + (config.bubbleCleanExtra or 15) / value186
            return dist2 <= value30
        end
        if (value[21] or chasing) and value256 and helper36(value256) then
            value251 = value256
        else
            if (value[21] or chasing) and value254 and helper36(value254) then
                value251 = value254
            else
                if value256 and helper36(value256) and helper37(value256) then
                    value251 = value256
                else
                    if value254 and helper36(value254) and helper37(value254) then
                        value251 = value254
                    end
                end
            end
        end
        if value258 and value251 and value251.yellow then
            if value262 and helper36(value262) then
                value251 = value262
            else
                if value260 and helper36(value260) then
                    value251 = value260
                end
            end
        end
        if bubbleBoss.nsFire and value251 and not value251.side then
            value[271] = bubbleBoss.spikeSideAt
            value[272] = point
            value[267] = Vector3.new
            value[266] = value251.dx * value251.dist
            value[269] = value[5] + value[266]
            value[270] = value[6]
            value[268] = value251.dz * value251.dist
            if
                value[271](
                    value[272],
                    value[267](value[269], value[270], value[7] + value[268]),
                    speed,
                    argument
                )
            then
                if bubbleBoss.nsBest then
                    value251, bubbleBoss.nsBest.noSpike = bubbleBoss.nsBest, true
                end
            else
                value251.noSpike = true
            end
        end
        if value182 > 0 then
            value[273] = value182
            value[13] = value[13] + value[273]
        end
        if config.mageSideFirst ~= false and value[8] and bubbleBoss.isMageShot(value[8].name) then
            value251 = bubbleBoss.mageSideStep(value[8], point, argument, speed, fitsAt, lineEnters)
                or value251
        end
        if soft and not value251 then
            value[282] = value270 and value271 <= value273 - value103 * 2
            if value[282] then
                value[281] = value264
                if value[281] then
                    value[279] = bubbleBoss.orbPathSafe
                    value[280] = point
                    value[275] = Vector3.new
                    value[274] = value270.dx * value270.dist
                    value[277] = value[5] + value[274]
                    value[278] = value[6]
                    value[276] = value270.dz * value270.dist
                    value[281] = not value[279](
                        value[280],
                        value[275](value[277], value[278], value[7] + value[276]),
                        speed
                    )
                end
                value[282] = not value[281]
            end
            value[291] = value[282]
            if value[291] then
                value[290] = value[28]
                if value[290] then
                    value[288] = bubbleBoss.bobOrbPathSafe
                    value[289] = point
                    value[284] = Vector3.new
                    value[283] = value270.dx * value270.dist
                    value[286] = value[5] + value[283]
                    value[287] = value[6]
                    value[285] = value270.dz * value270.dist
                    value[290] = not value[288](
                        value[289],
                        value[284](value[286], value[287], value[7] + value[285]),
                        speed
                    )
                end
                value[291] = not value[290]
            end
            if value[291] then
                value251 = value270
            else
                if value47 then
                    return (helper25("no clear step"))
                end
                bubbleBoss.goal = nil
                return nil
            end
        end
        if value301 and bubbleBoss.lethal and primary2 ~= nil and not (value251 and value251.side) then
            value182 = os.clock()
            value183 = nil
            helper37 = false
            if value251 then
                argument3, helper36 = { value251, value256, value254, value262, value260 }, {}
                for index41 = 1, 5, 1 do
                    value[21] = argument3[index41]
                    if value[21] and not helper36[value[21]] and not value[21].side then
                        helper36[value[21]] = true
                        value[292] = value[21].dx * value[21].dist
                        pickedDist2 = value[5] + value[292]
                        value[293] = value[21].dz * value[21].dist
                        index41 = value[7] + value[293]
                        if
                            value[32](
                                value[5],
                                value[7],
                                pickedDist2,
                                index41,
                                argument,
                                speed,
                                value46,
                                true
                            )
                        then
                            if value[33](pickedDist2, index41, argument + value[21].dist / speed) then
                                helper37 = true
                            else
                                value183 = (helper23(value[21].dx, value[21].dz, value[21].dist, speed))
                                helper37 = value183 ~= nil
                            end
                            if helper37 then
                                value251 = value[21]
                                break
                            end
                        end
                    end
                end
            end
            if not helper37 then
                table.sort(value302, function(argument4, argument5)
                    return argument4.dist < argument5.dist
                end)
                value299 = 0
                value183 = nil
                for index42, entry11 in ipairs(value302) do
                    if
                        value299 >= (config.stepInTry or 8)
                        or os.clock() - value182 > (config.stepInBudget or 0.008)
                    then
                        break
                    end
                    value299 += 1
                    escAway = helper23(entry11.dx, entry11.dz, entry11.dist, speed)
                    index42 = escAway
                        and (
                            (if value183 then escAway.depth < value183.depth - 0.5 else not value183)
                            or abs(escAway.depth - value183.depth) <= 0.5
                                and escAway.slack > value183.slack
                        )
                    value183 = if index42 then escAway else value183
                end
                if value183 then
                    value251 = {}
                    value251.dx = value183.dx
                    value251.dz = value183.dz
                    value251.dist = value183.dist
                    value251.free = value183.dist
                    value251.margin = 0
                    value251.soft = 0
                    value251.stepIn = true
                end
            end
            bubbleBoss.stepIn = nil
            if value183 then
                bubbleBoss.stepIn = {
                    q = value183.q,
                    exit = value183.exit,
                    at = argument,
                    tBad = value183.tBad,
                    speed = speed,
                    out = false,
                    depth = value183.depth,
                    name = value183.onB and value183.onB.name or "attack",
                }
            end
        end
        if not value251 and bubbleBoss.lethal then
            if config.odinYellowThrough ~= false then
                if context.PB then
                    if context.PB.boss == "Odin" then
                        if bubbleBoss.yellowThrough then
                            argument3 = max(speed, config.burstMax or 28)
                            value[294] = argumentHelpers[108](
                                pcall(bubbleBoss.yellowThrough, point, argument, argument3)
                            )
                            value[21] = value[294][1]
                            helper37 = value[294][2]
                            pickedDist2 = value[294][3]
                            escAway = value[294][4]
                            if value[21] then
                                if helper37 then
                                    bubbleBoss.goal = nil
                                    bubbleBoss.pickedSafe = true
                                    bubbleBoss.pickedDist = pickedDist2
                                    return {
                                        point = helper37,
                                        soft = false,
                                        burst = argument3,
                                        label = ("ESCAPE %s -> nowhere clear: through the yellow to a clear spot %.0f studs%s"):format(
                                            tostring(primary2 and primary2.box and primary2.box.name or "?"),
                                            pickedDist2,
                                            escAway or ""
                                        ),
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
        pickedDist2 = value251 or value267
        if not pickedDist2 then
            return nil
        end
        if not value251 and bubbleBoss.keepX and (pickedDist2.dist or 0) < (config.keepGoingMinRun or 8) then
            value[21] = bubbleBoss.keepX
            value182 = bubbleBoss.keepZ
            value299 = config.keepGoingRun or 16
            value183 = (Vector3.new(value[5], value[6] + 2, value[7]))
            helper23 = (
                parent:Raycast(value183, Vector3.new(value[21], 0, value182) * (value299 + 3), raycastParams)
            )
            value[302] = config.ledgeGuard == false
            if not value[302] then
                value[301] = parent
                value[297] = Vector3.new
                value[295] = value299
                value[296] = value[21] * value[295]
                value[299] = value[5] + value[296]
                value[300] = value[6] + 3
                value[298] = value182 * value299
                value[302] = value[301]:Raycast(
                    value[297](value[299], value[300], value[7] + value[298]),
                    Vector3.new(0, -(3 + (config.ledgeDrop or 7)), 0),
                    raycastParams
                )
            end
            escAway = value[302]
            if if helper23 then not helper23 else escAway then
                value[303] = {}
                value[303].dx = value[21]
                value[303].dz = value182
                value[303].dist = value299
                value[303].bad = true
                value[303].keep = true
                pickedDist2 = value[303]
                bubbleBoss.keptGoing = argument
            end
        end
        helper37 = false
        if config.pocketTrap ~= false and hazardReader.volleyRows then
            helper23 = 0
            for key9, volleyRow in pairs(hazardReader.volleyRows) do
                helper23 = if argument - (volleyRow.t or 0) < (config.volleyLiveFor or 1.5)
                    then helper23 + 1
                    else helper23
            end
            if helper23 >= 2 and hazardReader.enemies then
                for index43, enemy2 in ipairs(hazardReader.enemies) do
                    if
                        enemy2.isSpear
                        and enemy2.root
                        and enemy2.root.Parent
                        and (enemy2.humanoid == nil or enemy2.humanoid.Health > 0)
                    then
                        escAway = enemy2.root.Position.X - value[5]
                        value183 = enemy2.root.Position.Z - value[7]
                        if
                            sqrt(escAway * escAway + value183 * value183) <= (config.spearStrafeRange or 85)
                        then
                            helper37 = true
                            break
                        end
                    end
                end
            end
        end
        helper23 = false
        if hazardReader.enemies then
            for index44, enemy3 in ipairs(hazardReader.enemies) do
                if
                    enemy3.melee
                    and enemy3.root
                    and enemy3.root.Parent
                    and (enemy3.humanoid == nil or enemy3.humanoid.Health > 0)
                then
                    argument3 = enemy3.root.Position.X - value[5]
                    value183 = enemy3.root.Position.Z - value[7]
                    index44 = sqrt(argument3 * argument3 + value183 * value183)
                    if index44 <= (config.mageHoldMeleeAt or 28) then
                        helper23 = true
                        break
                    end
                    if
                        index44 <= (config.mageHoldMeleeClosing or 45)
                        and ((enemy3.vx or 0) * -argument3 + (enemy3.vz or 0) * -value183)
                                / max(index44, 1)
                            > 4
                    then
                        helper23 = true
                        break
                    end
                end
            end
        end
        if
            primary2
            and primary2.box
            and (primary2.box.name == "northernmageshot" or tostring(primary2.box.name):sub(1, 11) == "volley next")
            and config.mageHold ~= false
            and not pickedDist2.bad
            and not helper37
            and not helper23
            and not runtimeState.runOn
            and config.mageStrafeKeep == false
        then
            value299, argument3, value183, escAway =
                config.mageHoldClear or 2.5, ipairs, { 0, 0.4, 0.8, config.mageHoldLook or 1.2 }, true
            for key10, entry12 in argument3(value183) do
                value[304] = argumentHelpers[108](fitsAt(value[5], value[7], argument + entry12))
                value182 = value[304][1]
                helper36 = value[304][2]
                if helper36 == nil or helper36 > -value299 then
                    escAway = false
                    break
                end
            end
            if escAway then
                bubbleBoss.goal = nil
                return {
                    point = point,
                    soft = false,
                    label = ("MAGE HOLD: every shot %.1f+ studs off for %.1fs, staying"):format(
                        value299,
                        config.mageHoldLook or 1.2
                    ),
                }
            end
        end
        bubbleBoss.pickedSafe, bubbleBoss.pickedDist = value251 ~= nil, pickedDist2.dist
        value299 = Vector3.new(pickedDist2.dx, 0, pickedDist2.dz)
        if bubbleBoss.osc then
            if not bubbleBoss.osc.dir then
                bubbleBoss.osc.dir = value299
            end
        end
        value[21] = bubbleBoss.anchor
        if
            if value[21]
                then argument - (bubbleBoss.anchorAt or 0) >= (config.bubbleNoFlip or 1.2)
                else not value[21]
        then
            bubbleBoss.anchor = value299
            bubbleBoss.anchorAt = argument
        end
        helper36 = bubbleBoss.dir
        if if helper36 then value299:Dot(bubbleBoss.dir) < 0.9 else not helper36 then
            bubbleBoss.dir = value299
            bubbleBoss.dirAt = argument
        end
        if
            config.escapeNoBack ~= false
            and value[8]
            and primary2
            and not value[8].noFlee
            and not value[8].noGo
            and (primary2.hard or value[8].weight == nil or value[8].weight >= 1)
        then
            argument3, escAway = bubbleBoss.escAway
            if argument3 then
                escAway = argument3
            else
                value183 = setmetatable
                value[21] = { __mode = "k" }
                escAway = (value183({}, value[21]))
            end
            bubbleBoss.escAway = escAway
            helper23 = bubbleBoss.escAway[value[8]]
            if helper23 then
                helper23.seen = argument
            else
                value[305] = bubbleBoss.escAway
                value[306] = { x = value299.X, z = value299.Z, at = argument }
                value[305][value[8]] = value[306]
            end
            if config.oneWay ~= false then
                helper36 = bubbleBoss.oneWay
                if
                    if helper36 then argument - helper36.last > (config.oneWayQuiet or 3) else not helper36
                then
                    bubbleBoss.oneWay = { x = value299.X, z = value299.Z, at = argument, last = argument }
                else
                    helper36.last = argument
                end
            end
        end
        value[307] = bubbleBoss
        value[307].lastPrimaryBox = value[8]
        value[308] = point + value299 * pickedDist2.dist
        value[21] = value[308]
        helper36 = nil
        if value251 then
            value[8] = value251.roomy and 3 or value251.clean and 2
            helper36 = value[8] or 1
        else
            helper36 = value251
        end
        argument3 = helper36 or 0
        if value251 then
            value[309] = bubbleBoss
            value[310] = {}
            value[310].p = value[21]
            value[310].at = argument
            value[310].soft = soft
            value[310].name = primary2 and primary2.box.name or "?"
            value[310].box = primary2 and primary2.box or nil
            value[310].gen = hazardReader.boxGen or 0
            value[310].tier = argument3
            value[310].noSpike = value251.noSpike
            value[311] = value[310]
            value[309].goal = value[311]
        else
            if
                config.mageExit ~= false
                and primary2
                and primary2.box
                and (
                    primary2.box.name == "northernmageshot"
                    or tostring(primary2.box.name):sub(1, 11) == "volley next"
                    or config.mageSideFirst ~= false and bubbleBoss.isMageShot(primary2.box.name)
                )
            then
                value183, helper23 = value284, value285
                if not value183 then
                    value183, helper23 = primary2.box.rowDx, primary2.box.rowDz
                end
                if
                    (if value183 then not value183 else hazardReader.lastRowDir)
                    and argument - hazardReader.lastRowDir.t < 1.5
                then
                    value183, helper23 = hazardReader.lastRowDir.dx, hazardReader.lastRowDir.dz
                end
                if value183 and helper23 then
                    value[8] = config.mageExitDist or 12
                    value[312] = (config.burstMax or 28)
                    helper36 = argument + value[8] / value[312]
                    value[313] = argumentHelpers[108](fitsAt(value[21].X, value[21].Z, helper36))
                    escAway = value[313][1]
                    helper37 = value[313][2]
                    local value394, value395, value396, value397 = { 1, -1 }, helper37 or -infinity
                    for index45, entry13 in ipairs(value394) do
                        value[314] = helper23 * value[8] * entry13
                        value[316] = value[5] - value[314]
                        value[315] = value183 * value[8] * entry13
                        local value398, value399 = value[316], value[7] + value[315]
                        if
                            not (
                                bubbleBoss.mageCommitX
                                and -helper23 * entry13 * bubbleBoss.mageCommitX
                                        + value183 * entry13 * bubbleBoss.mageCommitZ
                                    < 0
                            )
                        then
                            local w, value400 = fitsAt(value398, value399, helper36)
                            value400 = value400 or -infinity
                            if value400 <= value395 then
                                value395, value396, value397 = value400, value398, value399
                            end
                        end
                    end
                    if value396 then
                        value[21] = (Vector3.new(value396, point.Y, value397))
                        value299 = Vector3.new(value396 - value[5], 0, value397 - value[7]).Unit
                        bubbleBoss.dir = value299
                        bubbleBoss.dirAt = argument
                    end
                end
            end
            value[317] = bubbleBoss
            value[318] = {}
            value[318].p = value[21]
            value[318].at = argument
            value[318].soft = false
            value[318].bad = true
            value[318].name = primary2 and primary2.box.name or "?"
            value[318].box = primary2 and primary2.box or nil
            value[318].gen = hazardReader.boxGen or 0
            value[318].tier = 0
            value[319] = value[318]
            value[317].goal = value[319]
        end
        helper37 = bubbleBoss.prevGoal
        bubbleBoss.prevGoal = nil
        helper37 = if value251 and value251.side then nil else helper37
        helper37 = if bubbleBoss.stepIn and bubbleBoss.stepIn.at == argument then nil else helper37
        helper37 = if helper37
                and bubbleBoss.mageCommitX
                and (helper37.p.X - value[5]) * bubbleBoss.mageCommitX
                        + (helper37.p.Z - value[7]) * bubbleBoss.mageCommitZ
                    < 0
            then nil
            else helper37
        value183, helper23 =
            false,
            config.bubbleKeepExit ~= false
                and primary2 ~= nil
                and primary2.depth ~= nil
                and primary2.depth >= 0
                and bubbleBoss.lastDepth ~= nil
                and bubbleBoss.lastDepthBox == primary2.box
                and argument - (bubbleBoss.lastDepthAt or 0) < 0.5
                and primary2.depth < bubbleBoss.lastDepth - 0.3
        bubbleBoss.lastDepth, bubbleBoss.lastDepthBox =
            primary2 and primary2.depth or nil, primary2 and primary2.box or nil
        bubbleBoss.lastDepthAt = argument
        helper36 = nil
        if helper37 then
            value[8] = helper37.bad
            helper36 = (if value[8] then helper23 else not value[8]) or value251 == nil
        else
            helper36 = helper37
        end
        if helper36 and argument - (helper37.at or 0) < (config.bubbleNoFlip or 1.2) then
            value[8] = (Vector3.new(helper37.p.X - value[5], 0, helper37.p.Z - value[7]))
            value183 = if value[8].Magnitude > 1 and value299:Dot(value[8].Unit) < -0.3
                then true
                else value183
        end
        value[8] = helper37 and helper37.bad and value183 and (helper23 or value251 == nil)
        if value[8] then
            if
                sqrt((helper37.p.X - value[5]) ^ 2 + (helper37.p.Z - value[7]) ^ 2)
                > (config.bubbleArrive or 1.5)
            then
                helper37.gen = hazardReader.boxGen or 0
                helper37.at = argument
                bubbleBoss.goal = helper37
                value[21] = helper37.p
                value299 = (Vector3.new(helper37.p.X - value[5], 0, helper37.p.Z - value[7]))
                value299 = if value299.Magnitude > 0.1 then value299.Unit else value299
            end
        else
            if
                helper37
                and not helper37.bad
                and (
                    value183
                    or (helper37.tier or 1) >= argument3
                    or helper37.box
                        and (primary2 and primary2.box == helper37.box or value88[helper37.box])
                )
            then
                helper23 = (sqrt((helper37.p.X - value[5]) ^ 2 + (helper37.p.Z - value[7]) ^ 2))
                if
                    helper23 > (config.bubbleArrive or 1.5)
                    and fitsAt(helper37.p.X, helper37.p.Z, argument + helper23 / speed) > 0
                    and not lineEnters(helper37.p.X, helper37.p.Z, argument)
                then
                    helper37.gen = hazardReader.boxGen or 0
                    bubbleBoss.goal = helper37
                    value[21] = helper37.p
                    value299 = (Vector3.new(helper37.p.X - value[5], 0, helper37.p.Z - value[7]))
                    value299 = if value299.Magnitude > 0.1 then value299.Unit else value299
                end
            end
        end
        helper23 = value251 and value251.side and "MAGE STRAFE"
            or primary2
                and (primary2.rank == 0 and "ESCAPE" or primary2.rank == 1 and "STEP OFF" or "CLEAR WARNING")
        argument3 = primary2
                and ("%s %s in %.2fs (%d: %d red, %d warm, %d yellow) %.0f deg"):format(
                    helper23 or "escape",
                    tostring(primary2.box.name or "?"),
                    primary2.tti,
                    #value[9],
                    #value[9] - value[24] - value[23],
                    value[24],
                    value[23],
                    toDegrees(atan2(value299.Z, value299.X))
                )
            or "escape: settling"
        argument3 = if value251 and value251.far then argument3 .. " (far)" else argument3
        argument3 = if bubbleBoss.union and primary2
            then argument3 .. " (overlapping attacks as one)"
            else argument3
        argument3 = if bubbleBoss.stepIn and bubbleBoss.stepIn.at == argument
            then argument3
                .. (" (step-in: %.0f studs into the %s, out %.0f studs %.1fs before it goes off)"):format(
                    pickedDist2.dist,
                    tostring(bubbleBoss.stepIn.name),
                    sqrt(
                        (bubbleBoss.stepIn.exit.X - bubbleBoss.stepIn.q.X) ^ 2
                            + (bubbleBoss.stepIn.exit.Z - bubbleBoss.stepIn.q.Z) ^ 2
                    ),
                    max(bubbleBoss.stepIn.tBad - argument, 0)
                )
            else argument3
        argument3 = if value251 and value251.roomy
            then argument3 .. " (roomy)"
            else if value251 and value251.clean then argument3 .. " (clean)" else argument3
        if
            value[21]
            and arenaCentre
            and not (bubbleBoss.stepIn and bubbleBoss.stepIn.at == argument)
            and not (value89 and hazardReader.orbLead ~= nil and config.spikeLeadArenaFree ~= false)
        then
            value299 = arenaCentre()
            if value299 then
                value[320] = argumentHelpers[108](arenaOf(value[21].X, value[21].Z))
                lineEnters = value[320][1]
                helper37 = value[320][2]
                helper36 = value[320][3]
                value183 = value[320][4]
                if
                    lineEnters
                    and helper37
                    and helper36
                    and value183
                    and helper37 > 0.1
                    and value183 > helper36
                then
                    helper23 = math.clamp(helper37, helper36 + 2, value183 - 2)
                    if math.abs(helper23 - helper37) > 0.5 then
                        pickedDist2 = (value[21].X - value299.X) / helper37
                        value[9] = (value[21].Z - value299.Z) / helper37
                        value[323] = Vector3.new
                        value[324] = value299.X + pickedDist2 * helper23
                        value[325] = value[21].Y
                        value[322] = value299.Z
                        value[321] = helper23
                        value[8] = (value[323](value[324], value[325], value[322] + value[9] * value[321]))
                        local value401 = sqrt((value[8].X - value[5]) ^ 2 + (value[8].Z - value[7]) ^ 2)
                        if
                            config.keptArenaCheck == false
                            or fitsAt(value[8].X, value[8].Z, argument + value401 / speed) > 0
                                and not (bubbleBoss.pathBlocked and bubbleBoss.pathBlocked(
                                    point,
                                    value[8],
                                    speed
                                ))
                        then
                            value[21] = value[8]
                            argument3 = argument3 .. " (kept in the arena)"
                        else
                            argument3 = argument3 .. " (not kept in the arena - red there)"
                        end
                    end
                end
            end
        end
        if value47 then
            helper23 = (helper24(value[21]))
            if helper23 then
                return (helper25(helper23, value[21]))
            end
        end
        value[326] = {}
        value[326].point = value[21]
        value[326].soft = soft
        value[326].label = argument3
        value[326].burst = bubbleBoss.stepIn and bubbleBoss.stepIn.at == argument and bubbleBoss.stepIn.speed
            or nil
        return value[326]
    end
    bubbleBoss.isMageShot = function(argument)
        argument = tostring(argument or "")
        return string.find(string.lower(argument), "mageshot", 1, true) ~= nil
            or argument:sub(1, 11) == "volley next"
    end
    bubbleBoss.shotLine = function(argument)
        if argument then
            if argument.r then
                return nil
            elseif argument.ax then
                if not argument.cx then
                    return nil
                end
            else
                return nil
            end
        else
            return nil
        end
        if (argument.ha or 0) >= (argument.hb or 0) then
            return argument.ax, argument.az, argument.hb or 0
        end
        return argument.bx, argument.bz, argument.ha or 0
    end
    bubbleBoss.mageFace = function(argument, zone)
        local value, value2 = argument.X, argument.Z
        if context.mageGap then
            context.mageGap(value, value2)
        end
        local mageArcList, value3, value4, value5, value6, value7, value8, value9 =
            hazardReader.mageArcList, config.mageStrafeFaceRange or config.mageArcRange or 140, 0, 0, 0
        if mageArcList then
            value9 = infinity
            for index = 1, #mageArcList, 1 do
                local value10, value11 = mageArcList[index].X - value, mageArcList[index].Z - value2
                index = sqrt(value10 * value10 + value11 * value11)
                if index > 1 then
                    if index <= value3 then
                        argument = 1 / max(index, 15)
                        local value12, value13, value14 =
                            value4 + value10 / index * argument,
                            value5 + value11 / index * argument,
                            value6 + 1
                        if index < value9 then
                            local value15, value16 = value10 / index, value11 / index
                            value9, value7, value8 = index, value15, value16
                        end
                        value4, value5, value6 = value12, value13, value14
                    end
                end
            end
        else
            value9 = infinity
        end
        if value6 > 0 then
            value3 = sqrt(value4 * value4 + value5 * value5)
            if value3 < (config.mageFaceMinSum or 0.25) / max(value9, 15) then
                return value7, value8, value9, value6
            end
            return value4 / value3, value5 / value3, value9, value6
        end
        if zone then
            argument, mageArcList = bubbleBoss.shotLine(zone)
            if argument then
                local value17, value18 = -mageArcList
                if (zone.cx - value) * value17 + (zone.cz - value2) * argument < 0 then
                    value17, value18 = -value17, -argument
                else
                    value18 = argument
                end
                return value17, value18, nil, 0
            end
        end
        return nil
    end
    bubbleBoss.mageFireLive = function(argument, argument2)
        if config.mageCommit == false then
            return false
        end
        local mageShotSeen = hazardReader.mageShotSeen
        if mageShotSeen then
            if not (argument2 - mageShotSeen.t < (config.mageStrafeHold or 2)) then
                return false
            end
        else
            return false
        end
        if
            (mageShotSeen.x - argument.X) ^ 2 + (mageShotSeen.z - argument.Z) ^ 2
            >= (config.mageStrafeNear or 120) ^ 2
        then
            return false
        end
        argument = context.BR and context.BR.target
        if argument and argument.isBoss then
            return false
        elseif context.PB then
            if context.PB.boss then
                return false
            end
        end
        return true
    end
    bubbleBoss.mageCommitDir = function(vector, argument)
        local mcCache = bubbleBoss.mcCache
        if mcCache then
            if mcCache.at == argument then
                if mcCache.x0 == vector.X then
                    if mcCache.z0 == vector.Z then
                        return mcCache.x, mcCache.z
                    end
                end
            end
        end
        local value, value2
        if bubbleBoss.mageFireLive(vector, argument) then
            local value3, L, value4, value5, c, value6 = bubbleBoss.mageStrafeDir(vector, argument)
            if value3 then
                if value4 then
                    if value6 then
                        local value7, value8 = -value5 * value6, value4 * value6
                        value, value2 = value7, value8
                    end
                end
            end
        end
        bubbleBoss.mcCache = { at = argument, x0 = vector.X, z0 = vector.Z, x = value, z = value2 }
        return value, value2
    end
    bubbleBoss.mageStrafeDir = function(side, argument, argument2)
        if context.orbitDir then
            if runtimeState.orbitLive then
                local value, value2, value3, value4, value5, value6 = context.orbitDir(side, argument)
                if value then
                    if config.mageCommit ~= false then
                        if value6 then
                            local value7, value8 = bubbleBoss.mageFace(side, argument2)
                            if value7 then
                                local side2, mageStrafe =
                                    -value4 * value6 * -value8 + value3 * value6 * value7 >= 0 and 1 or -1,
                                    bubbleBoss.mageStrafe
                                if not mageStrafe then
                                    mageStrafe = { side = side2, flipAt = -infinity }
                                    bubbleBoss.mageStrafe = mageStrafe
                                end
                                mageStrafe.side = side2
                                mageStrafe.at = argument
                            end
                        end
                    end
                    return value, value2, value3, value4, value5, value6
                end
            end
        end
        local value9, value10, value11 = bubbleBoss.mageFace(side, argument2)
        if not value9 then
            return nil
        end
        local value12, mageStrafe2 = side + Vector3.new(0, 2, 0), bubbleBoss.mageStrafe
        if
            if mageStrafe2
                then argument - (mageStrafe2.at or -infinity) > (config.mageStrafeForget or 8)
                else not mageStrafe2
        then
            local value13, value14, side3 = { 1, -1 }, -infinity, 1
            for index, entry in ipairs(value13) do
                index, argument2 = -value10 * entry, value9 * entry
                local raycastResult =
                    parent:Raycast(value12, Vector3.new(index, 0, argument2) * 40, raycastParams)
                local value15, value16 = raycastResult and raycastResult.Distance or 40, runtimeState.runOn
                value15 = if value16
                    then if value16.d
                        then if value16.d > 1
                            then value15
                                + ((value16.x - side.X) * index + (value16.z - side.Z) * argument2)
                                    / value16.d
                                    * 30
                            else value15
                        else value15
                    else value15
                value16 = bubbleBoss.oneWay
                value15 = if config.oneWay ~= false
                    then if value16
                        then if argument - value16.last <= (config.oneWayQuiet or 3)
                            then value15 + (index * value16.x + argument2 * value16.z) * 100
                            else value15
                        else value15
                    else value15
                if value15 > value14 then
                    value14, side3 = value15, entry
                end
            end
            mageStrafe2 = { side = side3, flipAt = -infinity }
            bubbleBoss.mageStrafe = mageStrafe2
        end
        mageStrafe2.at = argument
        side = mageStrafe2.side
        local value17, value18, value19 = -value10 * side, value9 * side, config.mageStrafeWallAt or 10
        if argument - mageStrafe2.flipAt > (config.mageStrafeFlipGap or 3) then
            argument2 = Vector3.new(value17, 0, value18) * value19
            if parent:Raycast(value12, argument2, raycastParams) then
                local value20 = Vector3.new(-value17, 0, -value18) * value19
                if not (parent:Raycast(value12, value20, raycastParams)) then
                    local side4 = -side
                    mageStrafe2.side = side4
                    mageStrafe2.flipAt = argument
                    mageStrafe2.wallFlipAt = argument
                    local value21, value22 = -value17, -value18
                    side, value17, value18 = side4, value21, value22
                end
            end
        end
        if value11 then
            value19 = value11 < (config.mageStrafeMin or 30) and -1
                or value11 > (config.mageStrafeMax or 75) and 1
                or 0
            if value19 ~= 0 then
                argument2 = toRadians(config.mageStrafeTilt or 25)
                value12, argument = cos(argument2), sin(argument2) * value19
                value17, value18 =
                    value17 * value12 + value9 * argument, value18 * value12 + value10 * argument
            end
        end
        return value17, value18, value9, value10, value11, side
    end
    bubbleBoss.mageSideStep = function(argument, vector, argument2, argument3, argument4, argument5)
        local value, value2, value3, value4, A, side = bubbleBoss.mageStrafeDir(vector, argument2, argument)
        if not value then
            return nil
        end
        local value5 = vector.X
        local value6 = vector.Z
        local value7, value8, value9, value10 =
            vector + Vector3.new(0, 2, 0),
            config.mageStrafeStep or 14,
            { 0, 20, -20, 40, -40 },
            runtimeState.mageExit
        if
            config.mageExitLean ~= false
            and value10
            and value10.q
            and argument2 - (value10.at or -infinity) < 0.3
        then
            local value11, value12, value13 = value10.q.X - value5, value10.q.Z - value6, {}
            for index, entry in ipairs(value9) do
                index = toRadians(entry)
                local value14, value15 =
                    value * cos(index) + value3 * sin(index), value2 * cos(index) + value4 * sin(index)
                argument = sqrt(value14 * value14 + value15 * value15)
                value13[entry] = argument > 0 and (value14 * value11 + value15 * value12) / argument
                    or -infinity
            end
            table.sort(value9, function(argument6, argument7)
                return value13[argument6] > value13[argument7]
            end)
        elseif
            config.runOnDodge ~= false
            and runtimeState.runOn
            and runtimeState.runOn.d
            and runtimeState.runOn.d > 1
            and not (context.BR and context.BR.target and context.BR.target.isBoss)
        then
            local value16, value17, value18 = runtimeState.runOn.x - value5, runtimeState.runOn.z - value6, {}
            for index2, entry2 in ipairs(value9) do
                index2 = toRadians(entry2)
                local value19, value20 =
                    value * cos(index2) + value3 * sin(index2), value2 * cos(index2) + value4 * sin(index2)
                index2 = sqrt(value19 * value19 + value20 * value20)
                value18[entry2] = index2 > 0 and (value19 * value16 + value20 * value17) / index2 or -infinity
            end
            table.sort(value9, function(argument6, argument7)
                return value18[argument6] > value18[argument7]
            end)
        end
        for index3, entry3 in ipairs(value9) do
            index3 = toRadians(entry3)
            local value21 = value * cos(index3) + value3 * sin(index3)
            local value22 = value2 * cos(index3) + value4 * sin(index3)
            argument = sqrt(value21 * value21 + value22 * value22)
            value21 /= argument
            value22 /= argument
            value10 = parent:Raycast(value7, Vector3.new(value21, 0, value22) * (value8 + 11), raycastParams)
            entry3 = min(value8 + 8, (value10 and value10.Distance or infinity) - (config.wallClear or 3))
            local function helper22(argument6)
                local value23, value24, value25 =
                    value5 + value21 * argument6,
                    value6 + value22 * argument6,
                    argument2 + argument6 / max(argument3, 1)
                local value26, T, value27 = argument4(value23, value24, value25)
                if value26 > 0 then
                    if not (value27 < 0) then
                        return nil
                    end
                else
                    return nil
                end
                local value28, C, value29 =
                    argument4(value23, value24, value25 + (config.mageStrafeHoldT or 0.5))
                if value28 > 0 then
                    if value29 < 0 then
                        if argument5(value23, value24, argument2) then
                            return nil
                        end
                    else
                        return nil
                    end
                else
                    return nil
                end
                if context.mageArcBad then
                    if context.mageArcBad(value23, value24, value5, value6) then
                        return nil
                    end
                end
                if context.coneBad then
                    if context.coneBad(value23, value24, value5, value6, nil, vector.Y) then
                        return nil
                    end
                end
                if config.ledgeGuard ~= false then
                    value27, value29 =
                        Vector3.new(value23, vector.Y + 3, value24),
                        Vector3.new(0, -(3 + (config.ledgeDrop or 7)), 0)
                    if not (parent:Raycast(value27, value29, raycastParams)) then
                        return nil
                    end
                end
                return min(value26, value28)
            end
            local dist, margin
            if value8 <= entry3 then
                margin = helper22(value8)
                dist = if margin then value8 else dist
            end
            if not dist then
                index3 = config.mageStrafeMinStep or 6
                while index3 <= entry3 do
                    margin = helper22(index3)
                    if margin then
                        dist = index3
                        break
                    end
                    index3 = index3 + 2
                end
            end
            if dist then
                return {
                    dx = value21,
                    dz = value22,
                    dist = dist,
                    free = entry3,
                    margin = margin,
                    soft = 0,
                    clean = true,
                    roomy = margin >= (config.roomyMargin or 10),
                    side = side,
                    strafe = true,
                }
            end
        end
        if config.mageCommit == false then
            return nil
        end
        local function helper23(argument6, argument7)
            return config.ledgeGuard == false
                or parent:Raycast(
                        Vector3.new(argument6, vector.Y + 3, argument7),
                        Vector3.new(0, -(3 + (config.ledgeDrop or 7)), 0),
                        raycastParams
                    )
                    ~= nil
        end
        argument, value10 = infinity
        for index4, entry4 in ipairs(value9) do
            index4 = toRadians(entry4)
            local value30, value31 =
                value * cos(index4) + value3 * sin(index4), value2 * cos(index4) + value4 * sin(index4)
            index4 = sqrt(value30 * value30 + value31 * value31)
            value30 /= index4
            value31 /= index4
            index4 = parent:Raycast(value7, Vector3.new(value30, 0, value31) * (value8 + 11), raycastParams)
            entry4 = min(value8 + 8, (index4 and index4.Distance or infinity) - (config.wallClear or 3))
            index4 = (min(value8, entry4))
            while index4 >= (config.mageStrafeMinStep or 6) do
                local value32, value33 = value5 + value30 * index4, value6 + value31 * index4
                if helper23(value32, value33) then
                    local margin2, value34, value35 =
                        argument4(value32, value33, argument2 + index4 / max(argument3, 1))
                    if margin2 > 0 then
                        if value35 < 0 then
                            return {
                                dx = value30,
                                dz = value31,
                                dist = index4,
                                free = entry4,
                                margin = margin2,
                                soft = 0,
                                clean = false,
                                side = side,
                                strafe = true,
                                kept = 1,
                            }
                        end
                    end
                    margin2 = max(value35 or 0, value34 or 0)
                    if margin2 < argument then
                        argument, value10 =
                            margin2, {
                                dx = value30,
                                dz = value31,
                                dist = index4,
                                free = entry4,
                                margin = 0,
                                soft = 0,
                                clean = false,
                                side = side,
                                strafe = true,
                                kept = 2,
                            }
                    end
                    break
                end
                index4 -= 2
            end
        end
        return value10
    end
    bubbleBoss.pathBlocked = function(vector, vector2, argument)
        if config.perfMemo == false then
            return bubbleBoss.pathBlockedRaw(vector, vector2, argument)
        end
        local pbMemo = bubbleBoss.pbMemo
        if
            (if pbMemo then pbMemo.f ~= runtimeState.frameN else not pbMemo)
            or pbMemo.boxes ~= dangerGeometry.boxes
            or pbMemo.gen ~= hazardReader.boxGen
            or runtimeState.frameN == nil
        then
            pbMemo =
                { f = runtimeState.frameN, boxes = dangerGeometry.boxes, gen = hazardReader.boxGen, n = 0 }
            bubbleBoss.pbMemo = pbMemo
        end
        local value = string.format(
            "%d,%d,%d,%d,%d",
            math.floor(vector.X * 2),
            math.floor(vector.Z * 2),
            math.floor(vector2.X * 2),
            math.floor(vector2.Z * 2),
            math.floor(argument or 0)
        )
        local value2 = pbMemo[value]
        if value2 then
            sharedValue2 = os.clock()
            bubbleBoss.blockReason = value2.why
            return value2.r
        end
        value2 = bubbleBoss.pathBlockedRaw(vector, vector2, argument)
        if pbMemo.n < 400 then
            pbMemo.n = pbMemo.n + 1
            pbMemo[value] = { r = value2, why = bubbleBoss.blockReason }
        end
        return value2
    end
    bubbleBoss.pathBlockedRaw = function(vector, vector2, argument)
        local value, bubbleRadius, value2, value3, now =
            dangerGeometry.boxes or {},
            config.bubbleRadius,
            dangerGeometry.halfHeight or 4,
            dangerGeometry.lag or 0,
            os.clock()
        sharedValue2 = now
        local value4, value5 = vector2.X - vector.X, vector2.Z - vector.Z
        local value6 = sqrt(value4 * value4 + value5 * value5)
        if value6 < 0.1 then
            return false
        end
        local value7 = max(argument, 4)
        argument = value6 / value7
        local value8, n, value9 =
            math.clamp(math.ceil(max(value6 / 6, argument / 0.25)), 2, 24), arenaOf(vector.X, vector.Z)
        local value10, value11, value12 =
            hazardReader.orbLead ~= nil and config.leadArenaFree ~= false,
            hazardReader.orbLead ~= nil and config.leadOrbBoxFree ~= false
        if config.pathLeaveOk ~= false then
            for index = 1, #value, 1 do
                local value13 = value[index]
                if not value13.moving then
                    if helper14(value13) == 3 then
                        index = helper3(
                            value13,
                            vector.X,
                            vector.Y,
                            vector.Z,
                            max(now, value13.from or now),
                            value2,
                            config.bubbleLead
                        )
                        if index then
                            if index >= -helper8(value13, bubbleRadius, value3) then
                                local value14 = helper3(
                                    value13,
                                    vector2.X,
                                    vector.Y,
                                    vector2.Z,
                                    max(now + argument, value13.from or now),
                                    value2,
                                    config.bubbleLead
                                )
                                if value14 then
                                    if not (value14 >= -helper8(value13, bubbleRadius, value3)) then
                                        local value15 = value12 or {}
                                        value15[value13] = true
                                        value12 = value15
                                    end
                                else
                                    local value16 = value12 or {}
                                    value16[value13] = true
                                    value12 = value16
                                end
                            end
                        end
                    end
                end
            end
        end
        local value17, value18 = {}, 0
        for index2 = 1, #value, 1 do
            local value19 = value[index2]
            index2 = value19.warn == true
                and (value19.from or 0) > now + (config.bubbleLead or 0)
                and not value19.hardPending
            if value11 then
                if value19.bobOrb == nil then
                    local value20 = string.lower(tostring(value19.name or ""))
                    value19.bobOrb = value20:find("secondboss", 1, true) ~= nil
                            and value20:find("orb", 1, true) ~= nil
                        or false
                end
            end
            if helper14(value19) == 3 then
                if not index2 then
                    if not (value12 and value12[value19]) then
                        if value11 then
                            if value19.bobOrb ~= true then
                                local value21 = value18 + 1
                                value17[value21] = value19
                                value18 = value21
                            end
                        else
                            local value22 = value18 + 1
                            value17[value22] = value19
                            value18 = value22
                        end
                    end
                end
            end
        end
        for index3 = 1, value8, 1 do
            value11 = index3 / value8
            local value23, value24, value25, value26, value27, value28, value29 =
                vector.X + value4 * value11, vector.Z + value5 * value11, now + value6 * value11 / value7
            if not value10 then
                value26, value27, value28, value29 = arenaOf(value23, value24)
            end
            value = value29 and value29 + (config.arenaSlack or 8) or nil
            if value26 then
                if value then
                    if value27 ~= nil then
                        if value27 > value then
                            if value9 == nil then
                                bubbleBoss.blockReason = "arena out " .. index3
                                return true
                            elseif value9 <= value then
                                bubbleBoss.blockReason = "arena out " .. index3
                                return true
                            end
                        end
                    end
                end
            end
            if value26 and value9 ~= nil and value28 ~= nil and value29 ~= nil then
                local value30 = value9 > value29 and value9 - value29
                    or value9 < value28 and value28 - value9
                    or 0
                if
                    (value27 > value29 and value27 - value29 or value27 < value28 and value28 - value27 or 0)
                    > value30 + (config.arenaSlack or 8)
                then
                    bubbleBoss.blockReason = "arena band " .. index3
                    return true
                end
            elseif value26 then
                if value9 == nil then
                    bubbleBoss.blockReason = "arena nostart " .. index3
                    return true
                end
            end
            if bubbleBoss.oldLineAt(value23, value24, value25, 0, vector.X, vector.Z) then
                bubbleBoss.blockReason = "old spike line " .. index3
                return true
            end
            for index4 = 1, value18, 1 do
                local value31 = value17[index4]
                index4 = helper3(value31, value23, vector.Y, value24, value25, value2, config.bubbleLead)
                if index4 then
                    if index4 >= -helper8(value31, bubbleRadius, value3) then
                        bubbleBoss.blockReason = tostring(value31.name or value31.kind or "?")
                            .. " "
                            .. index3
                            .. "/"
                            .. value8
                        return true
                    end
                end
            end
        end
        if
            bubbleBoss.oldLineAt(
                vector2.X,
                vector2.Z,
                now + argument,
                config.oldLineHold or 0.6,
                vector.X,
                vector.Z
            )
        then
            bubbleBoss.blockReason = "old spike line at the end"
            return true
        end
        bubbleBoss.blockReason = nil
        return false
    end
    bubbleBoss.pathTouchesRed = function(vector, argument, argument2, argument3, argument4)
        local value, value2, value3 = dangerGeometry.boxes or {}, dangerGeometry.halfHeight or 4, os.clock()
        sharedValue2 = value3
        local value4, value5 = argument.X - vector.X, argument.Z - vector.Z
        local value6 = sqrt(value4 * value4 + value5 * value5)
        if value6 < 0.5 then
            return false
        end
        local value7, value8, value9, value10, value11 =
            max(argument2 or 16, 4),
            (dangerGeometry.reach or 1.8) + (config.redTouchMargin or 0.5),
            dangerGeometry.lag or 0,
            math.clamp(math.ceil(value6 / (config.redNodeStep or 2)), 1, 80),
            value3 + (argument4 or 0)
        argument2, value3 = value11 + value6 / value7
        for index = 1, #value, 1 do
            argument4 = value[index]
            if not argument4.moving then
                if not argument4.noDraw then
                    if not (argument3 and (argument3(argument4))) then
                        if helper14(argument4) == 3 then
                            if (argument4.from or 0) <= value11 then
                                if (argument4.untilAt or infinity) >= value11 then
                                    local value12, value13 =
                                        argument4.slim and min(value8, argument4.slim + value9) or value8,
                                        helper3(argument4, vector.X, vector.Y, vector.Z, value11, value2, 0)
                                    if value13 then
                                        if value13 >= -value12 then
                                            index = helper3(
                                                argument4,
                                                argument.X,
                                                vector.Y,
                                                argument.Z,
                                                argument2,
                                                value2,
                                                0
                                            )
                                            if index then
                                                if not (index >= -value12) then
                                                    local value14 = value3 or {}
                                                    value14[argument4] = true
                                                    value3 = value14
                                                end
                                            else
                                                local value15 = value3 or {}
                                                value15[argument4] = true
                                                value3 = value15
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        for index2 = 1, value10, 1 do
            argument = index2 / value10
            index2, argument4, argument2 =
                vector.X + value4 * argument,
                vector.Z + value5 * argument,
                value11 + value6 * argument / value7
            for index3 = 1, #value, 1 do
                local value16 = value[index3]
                if helper14(value16) == 3 then
                    if not value16.noDraw then
                        if not (argument3 and (argument3(value16))) then
                            if not (value3 and value3[value16]) then
                                if (value16.from or 0) <= argument2 then
                                    if (value16.untilAt or infinity) >= argument2 then
                                        local value17, value18 =
                                            value16.slim and min(value8, value16.slim + value9) or value8,
                                            helper3(
                                                value16,
                                                index2,
                                                vector.Y,
                                                argument4,
                                                argument2,
                                                value2,
                                                0
                                            )
                                        if value18 then
                                            if value18 >= -value17 then
                                                return true, value16
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return false
    end
    bubbleBoss.redAtSpot = function(argument, argument2, argument3, argument4, argument5)
        local value, value2, value3, value4 =
            dangerGeometry.boxes or {},
            dangerGeometry.halfHeight or 4,
            (dangerGeometry.reach or 1.8) + (config.redTouchMargin or 0.5),
            dangerGeometry.lag or 0
        for index = 1, #value, 1 do
            local value5 = value[index]
            local value6, value7 = value5.from or 0, value5.untilAt or infinity
            if
                helper14(value5) == 3
                and not value5.noDraw
                and value6 <= argument5
                and value7 >= argument4
            then
                local value8, value9 =
                    value5.slim and min(value3, value5.slim + value4) or value3, {
                        max(argument4, value6),
                        (argument4 + argument5) * 0.5,
                        argument5,
                        min(argument5, value7),
                    }
                for index2 = 1, 4, 1 do
                    index = value9[index2]
                    if index >= value6 then
                        if index <= value7 then
                            if index >= argument4 then
                                if index <= argument5 then
                                    index2 = helper3(value5, argument, argument2, argument3, index, value2, 0)
                                    if index2 then
                                        if index2 >= -value8 then
                                            return true
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return false
    end
    bubbleBoss.yellowThrough = function(vector, argument, argument2)
        local value = max(argument2 or 16, 4)
        local value2 = config.yellowThroughHold or 1
        local value3 = config.yellowThroughSpare or 0.8
        local value4 = bubbleBoss.blueBeams and bubbleBoss.blueBeams() or {}
        local arenaCentre2, value5 = hazardReader.arenaCentre, vector.Y
        local function helper22(vector2, argument3)
            local value6 = argument3 / value
            if
                bubbleBoss.redAtSpot(
                    vector2.X,
                    value5,
                    vector2.Z,
                    argument + value6,
                    argument + value6 + value2
                )
            then
                return nil
            end
            if #value4 > 0 then
                if bubbleBoss.onBlueBeam(vector2.X, vector2.Z, 0, value4) then
                    argument3 = bubbleBoss.orbArrive(vector2.X, vector2.Z, value4) - value6
                    if argument3 < value3 then
                        return nil
                    end
                    return argument3
                end
            end
            return infinity
        end
        local function helper23(argument3)
            local value6 = bubbleBoss.pathTouchesRed(vector, argument3, value)
            return if value6 then not value6 else bubbleBoss.orbPathSafe(vector, argument3, value)
        end
        local value7 = bubbleBoss.ytLast
        if value7 then
            if argument - value7.at < (config.yellowThroughKeep or 0.4) then
                local value8 = sqrt((value7.q.X - vector.X) ^ 2 + (value7.q.Z - vector.Z) ^ 2)
                if value8 > 2 then
                    if helper22(value7.q, value8) then
                        if helper23(value7.q) then
                            return value7.q, value8, value7.note
                        end
                    end
                end
            end
        end
        bubbleBoss.ytLast = nil
        raycastParams.FilterDescendantsInstances = { sharedValue.LocalPlayer.Character, bubbleBoss.folder }
        local value9, value10, note, value11 =
            config.yellowThroughWays or 32, config.yellowThroughFar or 60, vector + Vector3.new(0, 2, 0), {}
        for index = 0, value9 - 1, 1 do
            value7 = index * 2 * 3.141592653589793 / value9
            local value12, value13 = cos(value7), sin(value7)
            index = parent:Raycast(note, Vector3.new(value12, 0, value13) * value10, raycastParams)
            local value14, value15 =
                index and index.Distance - (config.wallClear or 5) or value10, config.yellowThroughMin or 4
            while value15 <= value14 do
                index = Vector3.new(vector.X + value12 * value15, value5, vector.Z + value13 * value15)
                local spare = helper22(index, value15)
                if spare then
                    local value16 = value15 + (spare < infinity and (config.yellowThroughLaneCost or 20) or 0)
                    value16 = if arenaCentre2
                        then if context.odinBandOff
                            then value16 + context.odinBandOff(
                                sqrt((index.X - arenaCentre2.X) ^ 2 + (index.Z - arenaCentre2.Z) ^ 2)
                            ) * (config.yellowThroughRankW or 1)
                            else value16
                        else value16
                    value11[#value11 + 1] = { q = index, d = value15, c = value16, spare = spare }
                    break
                end
                value15 += 2
            end
        end
        table.sort(value11, function(argument3, argument4)
            return argument3.c < argument4.c
        end)
        for index2 = 1, min(#value11, config.yellowThroughTry or 12), 1 do
            helper22 = value11[index2]
            if
                config.ledgeGuard == false
                or parent:Raycast(
                        Vector3.new(helper22.q.X, value5 + 3, helper22.q.Z),
                        Vector3.new(0, -(3 + (config.ledgeDrop or 7)), 0),
                        raycastParams
                    )
                    ~= nil
            then
                if helper23(helper22.q) then
                    note = helper22.spare < infinity
                            and (", in a blue orb's lane %.1fs before it comes"):format(helper22.spare)
                        or ""
                    bubbleBoss.ytLast = { q = helper22.q, at = argument, note = note }
                    return helper22.q, helper22.d, note
                end
            end
        end
        return nil
    end
    context.crissWayBad = function(argument, argument2)
        if config.seekCrissWay == false then
            return false
        elseif not bubbleBoss.crissLive then
            return false
        end
        return not bubbleBoss.wayClear(argument, argument2, config.tweenEscape or 26, os.clock())
    end
    bubbleBoss.wayClear = function(argument, vector, argument2, argument3)
        argument3 = argument3 or os.clock()
        local value, bubbleRadius = dangerGeometry.boxes or {}, config.bubbleRadius
        local value2 = dangerGeometry.halfHeight or 4
        local value3 = dangerGeometry.lag or 0
        local value4 = config.bubbleLead or 0.35
        local value5, value6, value7 = argument.Y, {}, {}
        for index = 1, #value, 1 do
            local value8 = value[index]
            if helper14(value8) == 3 then
                if not value8.noDraw then
                    if not ((value8.untilAt or infinity) < argument3) then
                        value6[#value6 + 1] = value8
                        index = helper3(value8, argument.X, value5, argument.Z, argument3, value2, value4)
                        if index then
                            if index >= -helper8(value8, bubbleRadius, value3) then
                                value7[value8] = true
                            end
                        end
                    end
                end
            end
        end
        local function helper22(argument4, argument5, argument6, argument7)
            for index2 = 1, #value6, 1 do
                local value9 = value6[index2]
                if not (argument7 and argument7[value9]) then
                    index2 = helper3(value9, argument4, value5, argument5, argument6, value2, value4)
                    if index2 then
                        if index2 >= -helper8(value9, bubbleRadius, value3) then
                            return false
                        end
                    end
                end
            end
            return true
        end
        local value10, value11, value12 =
            max(argument2 or 16, 4), vector.X - argument.X, vector.Z - argument.Z
        argument2 = sqrt(value11 * value11 + value12 * value12)
        value = max(1, math.ceil(argument2 / (config.stepInStep or 1.5)))
        for index3 = 1, value, 1 do
            local value13 = index3 / value
            local value14, value15, value16 =
                argument.X + value11 * value13, argument.Z + value12 * value13, argument2 * value13 / value10
            if not (helper22(value14, value15, argument3 + value16, value7)) then
                return false
            end
            if
                not (
                    helper22(
                        value14,
                        value15,
                        argument3 + value16 * (config.stepInSlow or 1.1) + (config.stepInPad or 0.15) + value3,
                        value7
                    )
                )
            then
                return false
            end
            if value16 > 0.1 then
                if
                    not (helper22(value14, value15, argument3 + value16 * (config.stepInFast or 0.9), value7))
                then
                    return false
                end
            end
        end
        argument, value11 = argument3 + argument2 / value10, config.arriveHold or 1
        return helper22(vector.X, vector.Z, argument + value11 * 0.5)
            and helper22(vector.X, vector.Z, argument + value11)
    end
    bubbleBoss.SPIKE_KIND = {
        ["seeking spike"] = "seek",
        ["seeking line"] = "seek",
        ["big spike"] = "big",
        ["big spike line"] = "big",
    }
    bubbleBoss.spikeSideAt = function(vector, argument, argument2, argument3)
        if config.beamSpikeSide == false then
            return false
        end
        local value = argument3 or os.clock()
        if bubbleBoss.spkFor ~= dangerGeometry.now or not bubbleBoss.spkList then
            local value2, spkList, value3 = dangerGeometry.boxes or {}, bubbleBoss.spkList or {}, 0
            for index = 1, #value2, 1 do
                local value4 = value2[index]
                index = value4.spikeKind
                if index == nil then
                    local value5 = tostring(value4.name or "")
                    local value6 = string.lower(value5)
                    index = bubbleBoss.SPIKE_KIND[value5]
                        or value6:find("bigspike", 1, true) and "big"
                        or value6:find("seekingspike", 1, true) and "seek"
                        or false
                    value4.spikeKind = index
                end
                if index then
                    value3 += 1
                    spkList[value3] = value4
                end
            end
            for index2 = value3 + 1, #spkList, 1 do
                spkList[index2] = nil
            end
            bubbleBoss.spkList, bubbleBoss.spkFor = spkList, dangerGeometry.now
        end
        local spkList2 = bubbleBoss.spkList
        if #spkList2 == 0 then
            return false
        end
        local value7 = dangerGeometry.halfHeight or 4
        local value8 = config.bubbleLead or 0.35
        local value9 = vector.Y
        local value10 = config.spikeSideSeek or 10
        local value11, value12 = config.spikeSideBig or 20, {}
        for index3 = 1, #spkList2, 1 do
            local value13 = spkList2[index3]
            index3 = helper3(value13, vector.X, value9, vector.Z, value, value7, value8)
            if index3 then
                if index3 >= -(value13.spikeKind == "big" and value11 or value10) then
                    value12[value13] = true
                end
            end
        end
        local function helper22(argument4, argument5, argument6, argument7)
            for index4 = 1, #spkList2, 1 do
                local value14 = spkList2[index4]
                if not (argument7 and argument7[value14]) then
                    if not ((value14.untilAt or infinity) < value) then
                        index4 = helper3(value14, argument4, value9, argument5, argument6, value7, value8)
                        if index4 then
                            if index4 >= -(value14.spikeKind == "big" and value11 or value10) then
                                return true
                            end
                        end
                    end
                end
            end
            return false
        end
        local value15, value16 = argument.X - vector.X, argument.Z - vector.Z
        local value17, value18 = sqrt(value15 * value15 + value16 * value16), max(argument2 or 16, 4)
        local value19, value20 = value + value17 / value18, config.spikeSideHold or 1.5
        for index5 = 0, 3, 1 do
            if helper22(argument.X, argument.Z, value19 + value20 * index5 / 3) then
                return true
            end
        end
        argument = max(1, math.ceil(value17 / 3))
        for index6 = 1, argument - 1, 1 do
            if
                helper22(
                    vector.X + value15 * index6 / argument,
                    vector.Z + value16 * index6 / argument,
                    value + value17 * index6 / argument / value18,
                    value12
                )
            then
                return true
            end
        end
        return false
    end
    bubbleBoss.fanDance = function(argument, point, burst)
        local value = hazardReader.hub
        if not value then
            return nil
        end
        local value2 = value.X
        local value3 = value.Z
        local value4 = point.X
        local value5 = point.Y
        local value6 = point.Z
        local value7 = sqrt((value4 - value2) ^ 2 + (value6 - value3) ^ 2)
        if value7 < (config.danceMinR or 20) then
            return nil
        end
        local value8, value9, value10 =
            atan2(value6 - value3, value4 - value2), 3.141592653589793, 1.5707963267948966
        local value11, bubbleRadius = dangerGeometry.boxes or {}, config.bubbleRadius
        local value12 = dangerGeometry.halfHeight or 4
        local value13 = dangerGeometry.lag or 0
        value = hazardReader.hitDelay and hazardReader.hitDelay.firstbosspassivebeam
        local value14, value15, value16, value17 =
            value and value.med or 0.916,
            math.clamp(runtimeState.dataPingS or runtimeState.pingS or 0, 0, 0.4),
            config.danceLook or 2,
            config.bubbleLead or 0.35
        local value18, value19, value20, value21 = math.asin, {}, {}, {}
        for index = 1, #value11, 1 do
            value = value11[index]
            index = value.name
            if
                index == "firstbosspassivebeam"
                and value.cx
                and value.ha
                and value.hb
                and not value.moving
            then
                local value22, value23, value24
                if value.hb >= value.ha then
                    value22, value23, value24 = value.bx, value.bz, value.ha
                else
                    value22, value23, value24 = value.ax, value.az, value.hb
                end
                local born, value25 =
                    value.bornAt or argument,
                    abs((value.cx - value2) * -value23 + (value.cz - value3) * value22)
                value19[#value19 + 1] = {
                    c = (atan2(value23, value22) - value8 + value10) % value9 - value10,
                    w0 = value24 + helper8(value, bubbleRadius, value13) + value25,
                    t1 = born + value14,
                    born = born,
                    fired = value.fired == true,
                }
            elseif index ~= "beam next" then
                if index ~= "firstbosspassivebeam" then
                    if helper14(value) == 3 then
                        if not value.noDraw then
                            if not ((value.untilAt or infinity) < argument) then
                                value20[#value20 + 1] = value
                                local value26 =
                                    helper3(value, value4, value5, value6, argument, value12, value17)
                                if value26 then
                                    if value26 >= -helper8(value, bubbleRadius, value13) then
                                        value21[value] = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        if #value19 == 0 then
            return nil
        end
        local value27 = config.danceDt or 0.05
        value = math.ceil(value16 / value27)
        local value28 = value
        local value29 = min((config.danceSpan or 60) / value7, 1.2)
        local value30, value31 = max(burst or 16, 8) * (config.danceSpeedShare or 0.85) * value27 / value7, {}
        local function helper22(argument2)
            local value32 = {}
            for index2 = 1, #value31, 1 do
                local value33 = value31[index2]
                if value33.s0 <= argument2 and argument2 <= value33.s1 then
                    for index3 = -1, 1, 1 do
                        local value34, value35 =
                            value33.c + index3 * value9 - value33.a, value33.c + index3 * value9 + value33.a
                        if value35 >= -value29 then
                            if value34 <= value29 then
                                value32[#value32 + 1] = { max(value34, -value29), min(value35, value29) }
                            end
                        end
                    end
                end
            end
            table.sort(value32, function(argument3, argument4)
                return argument3[1] < argument4[1]
            end)
            argument2 = {}
            for index4, entry in ipairs(value32) do
                index4 = argument2[#argument2]
                if index4 and entry[1] <= index4[2] then
                    if entry[2] > index4[2] then
                        index4[2] = entry[2]
                    end
                else
                    argument2[#argument2 + 1] = { entry[1], entry[2] }
                end
            end
            return argument2
        end
        local function helper23(argument2)
            local value32, value33 = {}, -value29
            for index2, entry in ipairs(argument2) do
                if entry[1] > value33 then
                    value32[#value32 + 1] = { value33, entry[1] }
                end
                value33 = if entry[2] > value33 then entry[2] else value33
            end
            if value33 < value29 then
                value32[#value32 + 1] = { value33, value29 }
            end
            return value32
        end
        local function helper24(argument2, argument3)
            local value32 = {}
            for index2, entry in ipairs(argument2) do
                local value33, value34, value35 =
                    max(entry[1] - argument3, -value29), min(entry[2] + argument3, value29), value32[#value32]
                if value35 then
                    if value33 <= value35[2] then
                        if value34 > value35[2] then
                            value35[2] = value34
                        end
                    else
                        value32[#value32 + 1] = { value33, value34 }
                    end
                else
                    value32[#value32 + 1] = { value33, value34 }
                end
            end
            return value32
        end
        local function helper25(argument2, argument3)
            local value32, value33, value34 = {}, 1, 1
            while value33 <= #argument2 and value34 <= #argument3 do
                local value35, value36 =
                    max(argument2[value33][1], argument3[value34][1]),
                    min(argument2[value33][2], argument3[value34][2])
                if value35 < value36 then
                    value32[#value32 + 1] = { value35, value36 }
                end
                if argument2[value33][2] < argument3[value34][2] then
                    value33 = value33 + 1
                else
                    value34 = value34 + 1
                end
            end
            return value32
        end
        local function helper26(argument2, argument3)
            for index2, entry in ipairs(argument2) do
                if argument3 >= entry[1] then
                    if argument3 <= entry[2] then
                        return true
                    end
                end
            end
            return false
        end
        local value37 = math.ceil((config.danceHold or 0.3) / value27)
        raycastParams.FilterDescendantsInstances = { sharedValue.LocalPlayer.Character, bubbleBoss.folder }
        local function helper27(argument2, argument3, argument4, argument5)
            for index2 = 1, #value20, 1 do
                local value32 = value20[index2]
                if not (argument5 and value21[value32]) then
                    index2 = helper3(value32, argument2, value5, argument3, argument4, value12, value17)
                    if index2 then
                        if index2 >= -helper8(value32, bubbleRadius, value13) then
                            return false
                        end
                    end
                end
            end
            return true
        end
        local function helper28(argument2)
            return value2 + value7 * cos(value8 + argument2), value3 + value7 * sin(value8 + argument2)
        end
        local value38 = {}
        local function helper29(argument2)
            local value32 = abs(argument2)
            local value33 = value32 < 1.0E-9 and 0 or math.ceil(value32 / value30)
            if value33 + 1 > value28 then
                return false
            end
            local value34 = argument2 >= 0 and 1 or -1
            for index2 = 1, value33, 1 do
                local value35 = value34 * min(index2 * value30, value32)
                if not (helper26(value38[index2], value35)) then
                    return false
                end
                local value36, value39 = helper28(value35)
                if not (helper27(value36, value39, argument + index2 * value27, true)) then
                    return false
                end
            end
            for index3 = max(value33, 1), min(value33 + value37, value28), 1 do
                if not (helper26(value38[index3], argument2)) then
                    return false
                end
            end
            local value40, value41 = helper28(argument2)
            if helper27(value40, value41, argument + max(value33, 1) * value27, false) then
                if not (helper27(value40, value41, argument + (value33 + value37) * value27, false)) then
                    return false
                end
            else
                return false
            end
            if value32 * value7 > 1 then
                value33, argument2 =
                    Vector3.new(value4, value5 + 2, value6),
                    Vector3.new(value40 - value4, 0, value41 - value6)
                if parent:Raycast(value33, argument2, raycastParams) then
                    return false
                end
            end
            return true
        end
        value11, value14 =
            {
                {
                    sh = 0,
                    pre = (config.dancePre or 0.1) + value15 * (config.dancePingK or 1.5),
                    post = config.dancePost or 0.08,
                    m = config.danceMargin or 0.75,
                },
                { sh = value15, pre = 0.08 + value15 * 0.25, post = 0.06 + value15 * 0.25, m = 0.5 },
                { sh = value15, pre = 0.06 + value15 * 0.2, post = 0.05 + value15 * 0.2, m = 0 },
                { sh = value15, pre = 0.06 + value15 * 0.2, post = 0.05 + value15 * 0.2, m = 0.25, first = true },
            }, infinity
        for index5, entry2 in ipairs(value19) do
            value14 = if entry2.fired
                then value14
                else if entry2.t1 > argument - 0.05
                    then if abs(entry2.c) - value18(min(1, entry2.w0 / value7)) <= value29
                        then if entry2.t1 < value14 then entry2.t1 else value14
                        else value14
                    else value14
        end
        value18 = math.clamp(config.danceLevels or 4, 1, 4)
        local value42, value43
        for index6 = 1, value18, 1 do
            value15 = value11[index6]
            value28 = value
            if value15.first then
                if value14 == infinity then
                    break
                end
                value28 = math.clamp(math.ceil((value14 - argument + 0.3) / value27), 2, value)
            end
            value31 = {}
            for index7, entry3 in ipairs(value19) do
                index7 = value15.first
                if if index7 then entry3.t1 <= value14 + (config.danceFirstSpan or 0.12) else not index7 then
                    local value44, value45 =
                        entry3.t1 - value15.sh - value15.pre, entry3.t1 - value15.sh + value15.post
                    value45 = if entry3.fired
                        then value45
                        else if argument > entry3.t1 + 0.05
                            then max(value45, min(argument + 0.1, entry3.born + (config.danceWaitMax or 1.4)))
                            else value45
                    value45 = if entry3.fired then (min(value45, argument)) else value45
                    if value45 > argument then
                        if value44 < argument + value16 then
                            local value46, value47, value48 =
                                entry3.w0 + value15.m, #value31 + 1, { c = entry3.c }
                            value48.a, value48.s0, value48.s1, value31[value47] =
                                value46 >= value7 and value10 or math.asin(value46 / value7),
                                value44,
                                value45,
                                value48
                        end
                    end
                end
            end
            if #value31 == 0 then
                if index6 == 1 then
                    return nil
                end
                break
            end
            value38 = {}
            value38[value28] = helper23((helper22(argument + value28 * value27)))
            for index8 = value28 - 1, 1, -1 do
                value38[index8] = helper25(
                    helper24(value38[index8 + 1], value30),
                    (helper23((helper22(argument + index8 * value27))))
                )
            end
            if helper29(0) then
                value42 = 0
            else
                local value49, value50 = (config.danceStep or 0.75) / value7, bubbleBoss.danceSign or 1
                for index9 = 1, math.floor(value29 / value49), 1 do
                    if helper29(value50 * index9 * value49) then
                        value42 = value50 * index9 * value49
                        break
                    end
                    if helper29(-value50 * index9 * value49) then
                        value42 = -value50 * index9 * value49
                        break
                    end
                end
            end
            if value42 then
                value43 = index6
                break
            end
        end
        if not value42 then
            return nil
        end
        helper23 = infinity
        for index10 = 1, #value31, 1 do
            value11 = value31[index10]
            helper23 = if abs(value11.c) <= value11.a
                then if value11.s0 < helper23 then value11.s0 else helper23
                else helper23
        end
        if value42 == 0 then
            if helper23 - argument > (config.danceIdle or 0.8) then
                if hazardReader.fanBeamAt then
                    if not (argument - hazardReader.fanBeamAt < (config.danceFanHold or 0.6)) then
                        return nil
                    end
                else
                    return nil
                end
            end
            return {
                point = point,
                hold = true,
                soft = true,
                dance = true,
                label = helper23 < infinity
                        and ("FAN DANCE: holding between the lanes - the next beam over this spot in %.2fs, out by then"):format(
                            max(helper23 - argument, 0)
                        )
                    or "FAN DANCE: holding between the lanes",
            }
        end
        bubbleBoss.danceSign = value42 > 0 and 1 or -1
        helper25, value11 = helper28(value42)
        value18, value14, value15 =
            {
                point = Vector3.new(helper25, value5, value11),
                soft = false,
                dance = true,
                noCast = true,
                burst = burst,
            }, helper23 < infinity and ("FAN DANCE: %.0f studs round - the beam over this spot fires in %.2fs, parked by its edge"):format(abs(value42) * value7, max(helper23 - argument, 0)) or ("FAN DANCE: %.0f studs round, to a spot it can keep dodging from"):format(abs(value42) * value7), value43 and value43 > 1 and (value43 == 4 and " (the first beam only)" or (" (tight timing %d)"):format(value43))
        value18.label = value14 .. (value15 or "")
        return value18
    end
    bubbleBoss.isRedOrb = function(argument)
        local value = argument and argument.name
        return type(value) == "string" and string.lower(value):find("bouncingorbbad", 1, true) ~= nil
    end
    local function helper38(argument)
        return not bubbleBoss.isRedOrb(argument)
    end
    bubbleBoss.redInWay = function(argument, argument2, argument3, argument4)
        return (bubbleBoss.pathTouchesRed(argument, argument2, argument3, helper38, argument4))
    end
    local sharedValue23 = { 20, -20, 35, -35, 50, -50, 70, -70, 90, -90, 115, -115, 140, -140 }
    bubbleBoss.route = function(vector, vector2, argument)
        if
            not (bubbleBoss.orbLaneHit and bubbleBoss.orbLaneHit(vector.X, vector.Z, vector2.X, vector2.Z))
        then
            if not (bubbleBoss.pathBlocked(vector, vector2, argument)) then
                return vector2
            end
        end
        local value, value2 = vector2.X - vector.X, vector2.Z - vector.Z
        local value3 = sqrt(value * value + value2 * value2)
        if value3 < 1 then
            return nil
        end
        local value4, value5 = value / value3, value2 / value3
        raycastParams.FilterDescendantsInstances = { sharedValue.LocalPlayer.Character, bubbleBoss.folder }
        value, value2 = infinity
        for index, entry in ipairs(config.routeLegs or { 8, 14, 22 }) do
            for index2, entry2 in ipairs(sharedValue23) do
                repeat
                    if abs(entry2) > (config.routeMaxAngle or 70) then
                        break
                    end
                    index2 = toRadians(entry2)
                    local value6, value7 =
                        value4 * cos(index2) - value5 * sin(index2),
                        value4 * sin(index2) + value5 * cos(index2)
                    local vector3, value8, value9 =
                        Vector3.new(vector.X + value6 * entry, vector.Y, vector.Z + value7 * entry),
                        vector + Vector3.new(0, 2, 0),
                        Vector3.new(value6, 0, value7) * (entry + 2)
                    if not (parent:Raycast(value8, value9, raycastParams)) then
                        if not (bubbleBoss.pathBlocked(vector, vector3, argument)) then
                            if
                                not (
                                    bubbleBoss.orbLaneHit
                                    and bubbleBoss.orbLaneHit(vector.X, vector.Z, vector3.X, vector3.Z)
                                )
                            then
                                value7 = sqrt((vector2.X - vector3.X) ^ 2 + (vector2.Z - vector3.Z) ^ 2)
                                if value7 < value3 - (config.routeMinGain or 1) then
                                    index = bubbleBoss.pathBlocked(vector3, vector2, argument)
                                    value6 = not index
                                    local value10, value11 =
                                        entry + value7,
                                        (if index then value6 else 0) or (config.routeNotThrough or 400)
                                    local value12 = value10 + value11
                                    if value12 < value then
                                        value, value2 = value12, vector3
                                    end
                                end
                            end
                        end
                    end
                until true
            end
        end
        return value2
    end
    bubbleBoss.redRoute = function(vector, vector2, argument)
        if not (bubbleBoss.redInWay(vector, vector2, argument)) then
            return vector2
        end
        local value, value2 = vector2.X - vector.X, vector2.Z - vector.Z
        local value3 = sqrt(value * value + value2 * value2)
        if value3 < 1 then
            return nil
        end
        local value4, value5, value6 = value / value3, value2 / value3, max(argument or 16, 4)
        raycastParams.FilterDescendantsInstances = { sharedValue.LocalPlayer.Character, bubbleBoss.folder }
        value, value2 = infinity
        for index, entry in ipairs(config.routeLegs or { 8, 14, 22 }) do
            for index2, entry2 in ipairs(sharedValue23) do
                repeat
                    if abs(entry2) > (config.routeMaxAngle or 70) then
                        break
                    end
                    index2 = toRadians(entry2)
                    local value7, value8 =
                        value4 * cos(index2) - value5 * sin(index2),
                        value4 * sin(index2) + value5 * cos(index2)
                    local vector3, value9, value10 =
                        Vector3.new(vector.X + value7 * entry, vector.Y, vector.Z + value8 * entry),
                        vector + Vector3.new(0, 2, 0),
                        Vector3.new(value7, 0, value8) * (entry + 2)
                    if not (parent:Raycast(value9, value10, raycastParams)) then
                        if not (bubbleBoss.redInWay(vector, vector3, argument)) then
                            value8 = sqrt((vector2.X - vector3.X) ^ 2 + (vector2.Z - vector3.Z) ^ 2)
                            if value8 < value3 - (config.routeMinGain or 1) then
                                value7 = bubbleBoss.redInWay(vector3, vector2, argument, entry / value6)
                                index = not value7
                                local value11, value12 =
                                    entry + value8,
                                    (if value7 then index else 0) or (config.routeNotThrough or 400)
                                local value13 = value11 + value12
                                if value13 < value then
                                    value, value2 = value13, vector3
                                end
                            end
                        end
                    end
                until true
            end
        end
        return value2
    end
    local sharedValue24, sharedValue25 = { 25, -25, 45, -45, 70, -70, 95, -95, 125, -125 }, 1
    local sharedValue26, sharedValue27, sharedValue28 = -infinity
    local sharedValue29 = {}
    local function helper39()
        local olCache = bubbleBoss.olCache
        if
            (if olCache then olCache.f ~= runtimeState.frameN else not olCache)
            or olCache.parts ~= hazardReader.parts
            or runtimeState.frameN == nil
        then
            olCache = { f = runtimeState.frameN, parts = hazardReader.parts }
            bubbleBoss.olCache = olCache
        end
        return olCache
    end
    local function helper40(argument, argument2)
        local value, value2 = (argument or 0) * 2 + (argument2 and 1 or 0), helper39()
        if config.perfMemo ~= false then
            if value2[value] then
                return value2[value]
            end
        end
        local value3 = {}
        value2[value] = value3
        value2, value = pairs, hazardReader.parts or {}
        for key, entry in value2(value) do
            if key.Parent then
                local value4 = string.lower(key.Name)
                if
                    value4:find("bouncingorb", 1, true)
                    and not value4:find("good", 1, true)
                    and not (value4 == "bonusbossbouncingorbbad" and config.redOrbNoPath ~= false)
                then
                    local osp = sqrt((entry.vx or 0) ^ 2 + (entry.vz or 0) ^ 2)
                    if osp > 2 then
                        local value5, osp2, value6 =
                            (if argument then not argument else not argument2)
                                    and context.isBlueOrb(value4)
                                    and (config.blueLaneFrac or 0.75)
                                or 1,
                            osp * (argument or config.orbLaneTime or config.bubbleTrajLead or 2.4),
                            argument and infinity or (config.orbLaneMax or 120)
                        local value7, value8 = min(osp2, value6) * value5, max(key.Size.X, key.Size.Z) * 0.5
                        local value9 = value8
                            + (dangerGeometry.reach or 1.8)
                            + (config.orbLaneMargin or 2)
                            + (entry.box and entry.box.pad or 0)
                        local blue = context.isBlueOrb(value4)
                        local orbX = key.Position.X
                        local orbZ = key.Position.Z
                        local function helper22(
                            argument3,
                            argument4,
                            argument5,
                            argument6,
                            argument7,
                            argument8
                        )
                            local value10 = {
                                ox = argument3,
                                oz = argument4,
                                ux = argument5,
                                uz = argument6,
                                L = argument7,
                                w = value9,
                                vw = value8,
                                dL = argument8,
                                blue = blue,
                                orbX = orbX,
                                orbZ = orbZ,
                                osp = osp,
                                t0 = 0,
                                orb = key,
                            }
                            value3[#value3 + 1] = value10
                            return value10
                        end
                        value6 = blue
                                and config.orbPathFollow ~= false
                                and entry.orbSlot ~= nil
                                and context.orbLegs
                                and context.orbLegs(entry.orbSlot)
                            or nil
                        if value6 then
                            osp2 = entry.orbPathSpd or max(osp, config.orbBlueSpeed or 25)
                            local value11, value12 =
                                osp2 * (argument or config.orbLaneTime or config.bubbleTrajLead or 2.4),
                                argument and infinity or (config.orbLaneMax or 120)
                            local value13, value14 = min(value11, value12) * value5, entry.orbLegN or 1
                            local value15, value16, value17, value18 = value6[value14], entry.orbAlong or 0
                            value17, value18 =
                                value15.x + value15.ux * value16, value15.z + value15.uz * value16
                            value11 = 0
                            while value15 and value13 > 0.5 do
                                value12 = min(value15.len - value16, value13)
                                if value12 > 0.05 then
                                    local value19 =
                                        helper22(value17, value18, value15.ux, value15.uz, value12, value12)
                                    value19.rec = true
                                    value19.t0 = value11
                                    value19.osp = osp2
                                    value11 += value12 / osp2
                                    value13 = value13 - value12
                                end
                                value14 += 1
                                value15, value16 = value6[value14], 0
                                if value15 then
                                    value17, value18 = value15.x, value15.z
                                end
                            end
                        else
                            local value20 = entry.bounced
                            if value20 then
                                if value20.rec then
                                    local value21 = (sharedValue2 or os.clock()) - (value20.at or 0)
                                    if value21 >= 0 then
                                        if value21 <= (config.orbConeAfter or 0.2) then
                                            local value22 = helper22(
                                                value20.x,
                                                value20.z,
                                                value20.dx,
                                                value20.dz,
                                                value7,
                                                value7
                                            )
                                            value22.rec = true
                                            value22.t0 = -value21
                                        end
                                    end
                                end
                            end
                            if value20 then
                                if not value20.rec then
                                    if not (blue and config.orbBlueNoGuess ~= false) then
                                        if config.orbBounceCone ~= false then
                                            local value23 = (sharedValue2 or os.clock()) - (value20.at or 0)
                                            if value23 >= 0 then
                                                if value23 <= (config.orbConeAfter or 0.2) then
                                                    local value24 = value7 * (config.orbConeLenFrac or 0.6)
                                                    local value25 = helper22(
                                                        value20.x,
                                                        value20.z,
                                                        value20.dx,
                                                        value20.dz,
                                                        value24,
                                                        value24
                                                    )
                                                    value25.cone = math.tan(
                                                        math.rad((config.orbBounceConeDeg or 65) * 0.5)
                                                    )
                                                    value25.bounce = true
                                                    value25.t0 = -value23
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            value20 = entry.bounce
                            if value20 and (value20.dist or infinity) < value7 then
                                helper22(
                                    orbX,
                                    orbZ,
                                    entry.vx / osp,
                                    entry.vz / osp,
                                    value20.dist + value9,
                                    value20.dist
                                )
                                local value26, bounce2 = value7 - value20.dist, entry.bounce2
                                if value20.rec then
                                    if value20.dist > (config.orbConeGone or 1.5) then
                                        local value27 = helper22(
                                            value20.x,
                                            value20.z,
                                            value20.dx,
                                            value20.dz,
                                            value26,
                                            value26
                                        )
                                        value27.rec = true
                                        value27.t0 = value20.dist / osp
                                    end
                                elseif not (blue and config.orbBlueNoGuess ~= false) then
                                    if config.orbBounceMirror == true then
                                        if value20.dist > (config.orbConeGone or 1.5) then
                                            if value20.dist <= (config.orbConeNear or 25) then
                                                local value28 = value26
                                                    * (
                                                        config.orbMirrorLenFrac
                                                        or config.orbConeLenFrac
                                                        or 0.6
                                                    )
                                                local value29 = helper22(
                                                    value20.x,
                                                    value20.z,
                                                    value20.dx,
                                                    value20.dz,
                                                    value28,
                                                    value28
                                                )
                                                value29.bounce = true
                                                value29.t0 = value20.dist / osp + (config.orbBounceDelay or 0)
                                            end
                                        end
                                    elseif config.orbBounceCone ~= false then
                                        if value20.dist > (config.orbConeGone or 1.5) then
                                            if value20.dist <= (config.orbConeNear or 70) then
                                                local value30 = value26 * (config.orbConeLenFrac or 0.6)
                                                local value31 = helper22(
                                                    value20.x,
                                                    value20.z,
                                                    value20.dx,
                                                    value20.dz,
                                                    value30,
                                                    value30
                                                )
                                                value31.cone =
                                                    math.tan(math.rad((config.orbBounceConeDeg or 65) * 0.5))
                                                value31.bounce = true
                                                value31.t0 = value20.dist / osp
                                            end
                                        end
                                    elseif bounce2 and (bounce2.dist or infinity) < value26 then
                                        helper22(
                                            value20.x,
                                            value20.z,
                                            value20.dx,
                                            value20.dz,
                                            bounce2.dist + value9,
                                            bounce2.dist
                                        )
                                        helper22(
                                            bounce2.x,
                                            bounce2.z,
                                            bounce2.dx,
                                            bounce2.dz,
                                            value26 - bounce2.dist,
                                            value26 - bounce2.dist
                                        )
                                    else
                                        helper22(
                                            value20.x,
                                            value20.z,
                                            value20.dx,
                                            value20.dz,
                                            value26,
                                            value26
                                        )
                                    end
                                end
                            else
                                helper22(orbX, orbZ, entry.vx / osp, entry.vz / osp, value7, value7)
                            end
                        end
                    end
                end
            end
        end
        return value3
    end
    local function helper41(argument, argument2, argument3)
        for index = 1, #argument, 1 do
            local value = argument[index]
            local value2, value3 = argument2 - value.ox, argument3 - value.oz
            index = value2 * value.ux + value3 * value.uz
            if index > -value.w then
                if index < value.L then
                    if
                        abs(value2 * value.uz - value3 * value.ux)
                        < value.w + (value.cone and max(index, 0) * value.cone or 0)
                    then
                        return true
                    end
                end
            end
        end
        return false
    end
    bubbleBoss.orbLaneAt = function(argument, argument2)
        return config.orbLaneAvoid ~= false and helper41(helper40(), argument, argument2)
    end
    bubbleBoss.blueBeamsLong = function(argument)
        local value, value2 = helper39(), "L" .. tostring(argument)
        if config.perfMemo ~= false then
            if value[value2] then
                return value[value2]
            end
        end
        local value3 = {}
        for index, entry in ipairs(helper40(argument)) do
            if entry.blue then
                value3[#value3 + 1] = entry
            end
        end
        value[value2] = value3
        return value3
    end
    bubbleBoss.blueBeams = function()
        local value = helper39()
        if config.perfMemo ~= false then
            if value.b then
                return value.b
            end
        end
        local value2 = {}
        for index, entry in ipairs(helper40()) do
            if entry.blue then
                value2[#value2 + 1] = entry
            end
        end
        value.b = value2
        return value2
    end
    bubbleBoss.blueBeamsFull = function()
        local value = helper39()
        if config.perfMemo ~= false then
            if value.bf then
                return value.bf
            end
        end
        local value2 = {}
        for index, entry in ipairs(helper40(nil, true)) do
            if entry.blue then
                value2[#value2 + 1] = entry
            end
        end
        value.bf = value2
        return value2
    end
    bubbleBoss.onBlueBeam = function(argument, argument2, argument3, argument4)
        argument4 = argument4 or bubbleBoss.blueBeams()
        local value, value2 = dangerGeometry.reach or 1.8, config.orbBeamMargin or 1
        for index = 1, #argument4, 1 do
            local value3 = argument4[index]
            local value4, value5 = argument - value3.ox, argument2 - value3.oz
            local value6, value7 =
                value4 * value3.ux + value5 * value3.uz, value3.vw + value + value2 + (argument3 or 0)
            if value6 > -value7 then
                if value6 < (value3.dL or value3.L) + value7 then
                    if
                        abs(value4 * value3.uz - value5 * value3.ux)
                        < value7 + (value3.cone and max(value6, 0) * value3.cone or 0)
                    then
                        return value3
                    end
                end
            end
        end
        return nil
    end
    bubbleBoss.wallBeams = function()
        local wallBeamsAt = os.clock()
        if bubbleBoss.wallBeamsList then
            if wallBeamsAt - (bubbleBoss.wallBeamsAt or -infinity) < (config.wallBeamsTTL or 0.004) then
                return bubbleBoss.wallBeamsList
            end
        end
        local wallBeamsList = {}
        bubbleBoss.wallBeamsList = wallBeamsList
        bubbleBoss.wallBeamsAt = wallBeamsAt
        if not hazardReader.walls then
            return wallBeamsList
        end
        for key, wall in pairs(hazardReader.walls) do
            if wall.cx then
                if wall.vx then
                    if wall.vz then
                        wallBeamsAt, key = nil
                        local value = 0
                        if context.wallVel then
                            wallBeamsAt, key, value = context.wallVel(wall)
                        end
                        value = value or 0
                        if value > 2 then
                            local value2, zone =
                                #wallBeamsList + 1, {
                                    cx = wall.cx,
                                    cz = wall.cz,
                                    ux = wallBeamsAt,
                                    uz = key,
                                    nx = -key,
                                    nz = wallBeamsAt,
                                    vl = value,
                                    half = wall.halfLen or 30,
                                }
                            zone.thick, wallBeamsList[value2] =
                                (wall.halfThick or 6) + (config.wallLanePad or 2), zone
                        end
                    end
                end
            end
        end
        return wallBeamsList
    end
    bubbleBoss.wallTimes = function(zone, argument, argument2)
        local value, value2, value3, value4 =
            dangerGeometry.reach or 1.8, config.wallSafeGap or 2.5, argument - zone.cx, argument2 - zone.cz
        local value5, value6, value7 =
            value3 * zone.ux + value4 * zone.uz,
            value3 * zone.nx + value4 * zone.nz,
            zone.half + value + value2
        if abs(value6) >= value7 then
            return nil
        elseif value5 <= -(zone.thick + value + value2) then
            return nil
        end
        return max(value5 - zone.thick - value - value2, 0) / zone.vl,
            (value7 + (config.wallOffPad or 2.5) - abs(value6)) / (config.burstMax or 28),
            value5,
            value6
    end
    bubbleBoss.onWallBeam = function(argument, argument2, argument3, argument4)
        argument4 = argument4 or bubbleBoss.wallBeams()
        local value = config.wallSpare or 0.8
        for index = 1, #argument4, 1 do
            local value2, value3, value4, value5 = bubbleBoss.wallTimes(argument4[index], argument, argument2)
            if value2 then
                if value2 - (argument3 or 0) <= value3 + value then
                    return argument4[index], value2 - (argument3 or 0), value3, value4, value5
                end
            end
        end
        return nil
    end
    bubbleBoss.wallsComing = function(argument, argument2, argument3)
        if config.wallNoToward == false then
            return nil
        end
        argument3 = argument3 or bubbleBoss.wallBeams()
        local value
        for index = 1, #argument3, 1 do
            local value2 = bubbleBoss.wallTimes(argument3[index], argument, argument2)
            if value2 then
                if value2 <= (config.wallTowardT or 3.5) then
                    local value3 = value or {}
                    value3[#value3 + 1] = argument3[index]
                    value = value3
                end
            end
        end
        return value
    end
    bubbleBoss.towardWall = function(argument, argument2, argument3)
        if not argument3 then
            return false
        end
        local value = sqrt(argument * argument + argument2 * argument2)
        if value < 0.001 then
            return false
        end
        for index = 1, #argument3, 1 do
            if
                (argument * argument3[index].ux + argument2 * argument3[index].uz) / value
                < -(config.wallTowardCos or 0.1)
            then
                return argument3[index]
            end
        end
        return false
    end
    bubbleBoss.wallPathSafe = function(vector, argument, argument2, argument3, argument4)
        argument4 = argument4 or bubbleBoss.wallBeams()
        if #argument4 == 0 then
            return true
        end
        local value, value2 = argument.X - vector.X, argument.Z - vector.Z
        local value3, value4, value5, value6 =
            sqrt(value * value + value2 * value2),
            max(argument2 or 16, 4),
            dangerGeometry.reach or 1.8,
            config.wallSafeGap or 2.5
        argument2 = max(1, math.ceil(value3 / 2))
        for index = 0, argument2, 1 do
            argument = index / argument2
            local value7, value8, value9 =
                vector.X + value * argument,
                vector.Z + value2 * argument,
                (argument3 or 0) + value3 * argument / value4
            for index2 = 1, #argument4, 1 do
                index = argument4[index2]
                local value10, value11 = value7 - index.cx, value8 - index.cz
                local value12, value13 =
                    value10 * index.ux + value11 * index.uz - index.vl * value9,
                    value10 * index.nx + value11 * index.nz
                if abs(value12) < index.thick + value5 + value6 then
                    if abs(value13) < index.half + value5 + value6 then
                        return false
                    end
                end
            end
        end
        return true
    end
    bubbleBoss.yellowAt = function(argument, argument2, argument3, argument4)
        if config.rodinYellowAvoid == false then
            return false
        elseif not (context.rodinOrbs()) then
            return false
        end
        local value, value2, value3, value4, value5 =
            dangerGeometry.boxes or {},
            dangerGeometry.halfHeight or 4,
            dangerGeometry.origin and dangerGeometry.origin.Y or 0,
            dangerGeometry.reach or 1.8,
            config.dodgeLead or 1.2
        for index = 1, #value, 1 do
            local value6 = value[index]
            if not value6.moving then
                if not value6.noDraw then
                    if value6.cx then
                        if helper14(value6) >= 2 then
                            index = value6.from or 0
                            if index > argument3 then
                                if index - argument3 <= value5 then
                                    if (value6.untilAt or infinity) >= index then
                                        local value7 = depthOf(value6, argument, value3, argument2, value2)
                                        if value7 then
                                            if value7 ~= -infinity then
                                                if value7 >= -value4 then
                                                    return true
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        if
            not (
                hazardReader.sweepOrbFree ~= nil
                and os.clock() - hazardReader.sweepOrbFree < (config.sweepOrbFreeFor or 1)
            )
        then
            if bubbleBoss.onBlueBeam(argument, argument2, 0, argument4) then
                return true
            end
        end
        return false
    end
    bubbleBoss.bobOrbPathSafe = function(vector, argument, argument2)
        local bobOrbs = bubbleBoss.bobOrbs
        if bobOrbs then
            if #bobOrbs == 0 then
                return true
            end
        else
            return true
        end
        local value, value2 = argument.X - vector.X, argument.Z - vector.Z
        local value3, value4 = sqrt(value * value + value2 * value2), max(argument2 or 16, 4)
        local value5, value6, value7, value8 =
            value3 / value4 + (config.bobOrbAfter or 0.6),
            config.bobOrbKeep or 12,
            config.orbSpeed or 17,
            config.bobOrbStep or 0.1
        argument2 = value6
        for index = 1, #bobOrbs, 1 do
            argument = bobOrbs[index]
            local value9, value10 = argument.x, argument.z
            index = sqrt((vector.X - value9) ^ 2 + (vector.Z - value10) ^ 2)
            value6 = argument.keep or argument2
            value6 = if index < value6 + 2 then index - 2 else value6
            local vector2, value11 =
                config.crystalShield ~= false
                        and argument.homing
                        and argument.colour
                        and context.bobCrystal
                        and context.bobCrystal(argument.colour)
                    or nil,
                (config.crystalShieldR or 6.5) ^ 2
            if value6 > 0 then
                local value12, value13 = value6 * value6, value8
                while value13 <= value5 do
                    if vector2 then
                        if (value9 - vector2.X) ^ 2 + (value10 - vector2.Z) ^ 2 < value11 then
                            break
                        end
                    end
                    if argument.homing then
                        index = value3 > 0.01 and min((value13 - value8) * value4, value3) / value3 or 0
                        local value14, value15 =
                            vector.X + value * index - value9, vector.Z + value2 * index - value10
                        local value16 = sqrt(value14 * value14 + value15 * value15)
                        if value16 > 0.01 then
                            value9, value10 =
                                value9 + value14 / value16 * value7 * value8,
                                value10 + value15 / value16 * value7 * value8
                        end
                    else
                        value9, value10 = value9 + argument.vx * value8, value10 + argument.vz * value8
                    end
                    local value17 = value3 > 0.01 and min(value13 * value4, value3) / value3 or 0
                    local value18, value19 = vector.X + value * value17, vector.Z + value2 * value17
                    if
                        (value18 - value9) * (value18 - value9)
                            + (value19 - value10) * (value19 - value10)
                        < value12
                    then
                        return false
                    end
                    value13 = value13 + value8
                end
            end
        end
        return true
    end
    bubbleBoss.spikeSide = function(argument, vector, zone, spikeGoal)
        if zone then
            if not zone.cx then
                return nil
            end
        else
            return nil
        end
        local dangerAt = context.dangerAt
        local logT = context.logT
        if not dangerAt then
            return nil
        end
        local value = zone.cx
        local value2 = zone.cz
        local value3 = config.spikeSameCast or 10
        local value4 = zone.r or zone.size and zone.size.X * 0.5 or 46
        for index, entry in ipairs(hazardReader.zones or {}) do
            if string.lower(tostring(entry.name or "")):find("spike", 1, true) then
                if entry.cx then
                    if (entry.untilAt or 0) > argument then
                        if (entry.cx - value) ^ 2 + (entry.cz - value2) ^ 2 < value3 * value3 then
                            index = entry.r or entry.size and entry.size.X * 0.5 or 0
                            value4 = if index > value4 then index else value4
                        end
                    end
                end
            end
        end
        local function helper22(zone2)
            if zone2.cx then
                if (zone2.cx - value) ^ 2 + (zone2.cz - value2) ^ 2 >= value3 * value3 then
                    return false
                end
            else
                return false
            end
            return string.lower(tostring(zone2.name or "")):find("spike", 1, true) ~= nil
        end
        local value5 = vector.X
        local value6 = vector.Y
        local value7 = vector.Z
        local value8, value9 = value5 - value, value7 - value2
        local value10, value11, value12 = sqrt(value8 * value8 + value9 * value9), 0, 0
        if value10 > 0.5 then
            value11, value12 = value8 / value10, value9 / value10
        end
        local value13 = value4 + (config.spikeSideOver or 6)
        local value14, value15, value16, value17, spikeSidePick =
            max(value13 - value10, 0),
            max(spikeGoal or 26, 8),
            dangerGeometry.now or argument,
            max((zone.from or argument) - argument, 0),
            bubbleBoss.spikeSidePick
        if spikeSidePick then
            if spikeSidePick.zone ~= zone then
                bubbleBoss.spikeSidePick = nil
                spikeSidePick = nil
            end
        end
        local value18, value19
        if config.spikeSideGoal ~= false then
            spikeGoal = bubbleBoss.spikeGoal
            if not (spikeGoal and spikeGoal.zone == zone) then
                spikeGoal = { zone = zone }
                local orbLead, lastDest = hazardReader.orbLead, runtimeState.lastDest
                if orbLead and orbLead.goal then
                    spikeGoal.x, spikeGoal.z = orbLead.goal.X, orbLead.goal.Z
                    spikeGoal.from = "orb lead"
                elseif lastDest then
                    if lastDest.x then
                        if argument - (lastDest.at or -infinity) <= (config.spikeGoalAge or 4) then
                            spikeGoal.x, spikeGoal.z = lastDest.x, lastDest.z
                            spikeGoal.from = "destination"
                        end
                    end
                end
                bubbleBoss.spikeGoal = spikeGoal
            end
            if spikeGoal.x then
                if (spikeGoal.x - vector.X) ^ 2 + (spikeGoal.z - vector.Z) ^ 2 > 36 then
                    local value20, value21 = spikeGoal.x, spikeGoal.z
                    value18, value19 = value20, value21
                end
            end
        end
        if spikeSidePick then
            if
                (value5 - spikeSidePick.x0) ^ 2 + (value7 - spikeSidePick.z0) ^ 2
                > (config.spikeSideCommit or 6) ^ 2
            then
                return spikeSidePick
            end
        end
        if spikeSidePick then
            if argument - spikeSidePick.at < (config.spikeSideEvery or 0.15) then
                return spikeSidePick
            end
        end
        local value22 = dangerGeometry.reach or 2
        local value23 = config.spikeSideRoomCap or 96
        local function helper23(argument2, argument3, argument4)
            if dangerAt(argument2, value6, argument3, argument4, value22 + value23, 0, helper22) <= 0 then
                return value23
            end
            local value24, value25 = value23, 0
            while value24 - value25 > 8 do
                local value26 = (value25 + value24) * 0.5
                if dangerAt(argument2, value6, argument3, argument4, value22 + value26, 0, helper22) > 0 then
                    value24 = value26
                else
                    value25 = value26
                end
            end
            return value25
        end
        local value27, value28, costs, value29, position, value30 =
            config.spikeSideHeadings or 16,
            config.spikeSideStep or 6,
            {},
            context.bobLine and context.bobLine() or nil
        if config.spikeSideReach ~= false and context.bobPullTo then
            if context.bobPullTo(argument) then
                if context.bobAggroR then
                    spikeGoal = context.BR and context.BR.target
                    if spikeGoal then
                        if spikeGoal.isBoss then
                            if spikeGoal.root then
                                if spikeGoal.root.Parent then
                                    local position2, value31 =
                                        spikeGoal.root.Position, context.bobAggroR(spikeGoal)
                                    position, value30 = position2, value31
                                end
                            end
                        end
                    end
                end
            end
        end
        local value32, cost, spikeSidePick2 = infinity
        for index2 = 0, value27 - 1, 1 do
            spikeGoal = index2 * 2 * 3.141592653589793 / value27
            local value33, value34 = math.cos(spikeGoal), math.sin(spikeGoal)
            local value35 = value8 * value33 + value9 * value34
            local run = -value35 + sqrt(max(value35 * value35 - value10 * value10 + value13 * value13, 0))
            if run <= value14 + (config.spikeSideExtra or 14) then
                local cost2, value36, value37, value38 = value28, 0, 0, 0
                while cost2 < run do
                    value35 = dangerAt(
                        value5 + value33 * cost2,
                        value6,
                        value7 + value34 * cost2,
                        argument + cost2 / value15 - value16,
                        nil,
                        nil,
                        helper22
                    )
                    value36 = if value35 > value36 then value35 else value36
                    value37 += value35
                    value38 += 1
                    cost2 = cost2 + value28
                end
                local value39 = value5 + value33 * run
                local value40 = value7 + value34 * run
                cost2 = argument + run / value15 - value16
                local value41, value42, value43 =
                    dangerAt(value39, value6, value40, cost2, nil, nil, helper22) + 0.8 * dangerAt(
                        value39,
                        value6,
                        value40,
                        cost2 + 0.6,
                        nil,
                        nil,
                        helper22
                    ) + 0.6 * dangerAt(
                        value39,
                        value6,
                        value40,
                        cost2 + 1.2,
                        nil,
                        nil,
                        helper22
                    ) + 0.4 * dangerAt(
                        value39,
                        value6,
                        value40,
                        cost2 + 2,
                        nil,
                        nil,
                        helper22
                    ),
                    run / value15 - value17,
                    helper23(value39, value40, cost2 + 1)
                cost2 = value36 * 3
                    + (value38 > 0 and value37 / value38 or 0)
                    + value41
                    + (run - value14) * (config.spikeSideLenCost or 0.01)
                    + (1 - value43 / value23) * (config.spikeSideRoomCost or 0.6)
                    + (value42 > 0 and value42 * (config.spikeSideLateCost or 1.5) or 0)
                    + (1 - (value33 * value11 + value34 * value12)) * 0.05
                if value18 then
                    value43, value42 = value18 - value5, value19 - value7
                    value41 = sqrt(value43 * value43 + value42 * value42)
                    cost2 = if value41 > 0.5
                        then cost2
                            + (1 - (value33 * value43 + value34 * value42) / value41)
                                * 0.5
                                * (config.spikeSideGoalCost or 1.2)
                        else cost2
                end
                if value29 then
                    value43, value41, value42 = context.bobLinePoint(value39, value40, value29)
                    cost2 = if value42
                        then cost2
                            + min(value42 / (config.spikeSideLineScale or 40), 1.5)
                                * (config.spikeSideLineCost or 0.8)
                        else cost2
                end
                if position then
                    value42 = sqrt((value39 - position.X) ^ 2 + (value40 - position.Z) ^ 2) - value30
                    cost2 = if value42 > 0
                        then cost2
                            + min(value42 / (config.spikeSideReachScale or 20), 1.5)
                                * (config.spikeSideReachCost or 0.6)
                        else cost2
                end
                if cost2 < value32 or spikeSidePick and spikeSidePick.i == index2 then
                    local success, value44 = pcall(function()
                        local value24, value25 =
                            Vector3.new(value39, value6 + 4, value40), Vector3.new(0, -16, 0)
                        return parent:Raycast(value24, value25, raycastParams)
                    end)
                    cost2 = if success then if value44 then cost2 else cost2 + 5 else cost2 + 5
                    success, value42 = pcall(function()
                        local value24, value25 =
                            Vector3.new(value5, value6, value7),
                            Vector3.new(value39 - value5, 0, value40 - value7)
                        return parent:Raycast(value24, value25, raycastParams)
                    end)
                    cost2 = if success then if value42 then cost2 + 5 else cost2 else cost2
                    cost2 = if bubbleBoss.pathBlocked
                        then if bubbleBoss.pathBlocked(
                                vector,
                                Vector3.new(value39, value6, value40),
                                value15
                            )
                            then if tostring(bubbleBoss.blockReason or ""):find("arena", 1, true)
                                then cost2 + 4
                                else cost2
                            else cost2
                        else cost2
                end
                costs[index2 + 1] = cost2
                cost = if spikeSidePick then if spikeSidePick.i == index2 then cost2 else cost else cost
                if cost2 < value32 then
                    spikeSidePick2 = {
                        zone = zone,
                        i = index2,
                        ux = value33,
                        uz = value34,
                        x0 = value5,
                        z0 = value7,
                        at = argument,
                        cost = cost2,
                        run = run,
                    }
                    value32 = cost2
                end
            end
        end
        if spikeSidePick then
            if cost then
                if spikeSidePick2 then
                    if cost <= value32 + (config.spikeSideSwitch or 0.3) then
                        spikeSidePick.at = argument
                        spikeSidePick.cost = cost
                        spikeSidePick.costs = costs
                        return spikeSidePick
                    end
                else
                    spikeSidePick.at = argument
                    spikeSidePick.cost = cost
                    spikeSidePick.costs = costs
                    return spikeSidePick
                end
            end
        end
        if not spikeSidePick2 then
            return nil
        end
        spikeSidePick2.costs = costs
        bubbleBoss.spikeSidePick = spikeSidePick2
        bubbleBoss.spikeSideWhy = ("side %d of %d: cost %.2f, run %.0f (straight %.0f)"):format(
            spikeSidePick2.i,
            value27,
            spikeSidePick2.cost,
            spikeSidePick2.run,
            value14
        ) .. (value18 and " toward the " .. tostring(
            bubbleBoss.spikeGoal and bubbleBoss.spikeGoal.from or "goal"
        ) or "")
        if logT then
            logT("spikes", 1, "Dodge", "spike cast on us - " .. bubbleBoss.spikeSideWhy)
        end
        return spikeSidePick2
    end
    bubbleBoss.spikeBackPoint = function(success, vector)
        local value = hazardReader.orbLead
        local value2 = value and value.ray
        hazardReader.spikeBackWhy = nil
        if value2 then
            if not value2.ux then
                hazardReader.spikeBackWhy = "no ray"
                return nil
            end
        else
            hazardReader.spikeBackWhy = "no ray"
            return nil
        end
        local success2, value3, value4, value5, value6, value7 =
            value2.ux, value2.uz, config.burstMax or 28, config.spikeKeepPad or 6, false, 0
        for index, entry in ipairs(hazardReader.zones or {}) do
            if string.lower(tostring(entry.name or "")):find("spike", 1, true) then
                if entry.cframe then
                    if entry.size then
                        if success <= (entry.untilAt or success) then
                            value, value2, index = true, entry.cframe.Position, entry.size.X * 0.5 + value5
                            local value8, value9 = vector.X - value2.X, vector.Z - value2.Z
                            local value10, value11 =
                                value8 * success2 + value9 * value3,
                                value8 * value8 + value9 * value9 - index * index
                            value8 = if value11 < 0
                                then -value10 + sqrt(max(value10 * value10 - value11, 0))
                                else 0
                            if value8 > value4 * max((entry.from or success) - success, 0) + 1 then
                                hazardReader.spikeBackWhy = ("late: exit %.0f in %.1fs"):format(
                                    value8,
                                    (entry.from or success) - success
                                )
                                return nil
                            end
                            value6, value7 = value, if value8 > value7 then value8 else value7
                        end
                    end
                end
            end
        end
        if not value6 then
            hazardReader.spikeBackWhy = "no spikes"
            return nil
        end
        value = value7 + 4
        local value12 = vector.X + success2 * value
        local value13 = vector.Z + value3 * value
        success2, value5 = pcall(function()
            local value14, value15 = Vector3.new(value12, vector.Y + 4, value13), Vector3.new(0, -16, 0)
            return parent:Raycast(value14, value15, raycastParams)
        end)
        if not (success2 and value5) then
            hazardReader.spikeBackWhy = ("no floor at %.0f"):format(value)
            return nil
        end
        success, value2 = pcall(function()
            local value14, value15 =
                Vector3.new(vector.X, vector.Y, vector.Z),
                Vector3.new(value12 - vector.X, 0, value13 - vector.Z)
            return parent:Raycast(value14, value15, raycastParams)
        end)
        if success then
            if value2 then
                hazardReader.spikeBackWhy = ("wall %s at %.0f"):format(
                    tostring(value2.Instance and value2.Instance.Name),
                    value
                )
                return nil
            end
        end
        if bubbleBoss.bobOrbs then
            if #bubbleBoss.bobOrbs > 0 then
                if
                    not (bubbleBoss.bobOrbPathSafe(vector, Vector3.new(value12, vector.Y, value13), value4))
                then
                    hazardReader.spikeBackWhy = ("orb in the way at %.0f"):format(value)
                    return nil
                end
            end
        end
        hazardReader.spikeBackWhy = ("back %.0f"):format(value)
        return Vector3.new(value12, vector.Y, value13), value
    end
    bubbleBoss.spikeOutrun = function(argument, vector)
        local value = hazardReader.orbLead
        hazardReader.spikeOutrunWhy = nil
        if value then
            if not value.goal then
                return false
            end
        else
            return false
        end
        local value2 = hazardReader.orbSteer
        local value3 = value2
                and value2.p
                and value2.colour == value.colour
                and argument - (value2.at or 0) < 1.5
                and value2.p
            or value.goal
        value2, value = value3.X - vector.X, value3.Z - vector.Z
        value3 = sqrt(value2 * value2 + value * value)
        if value3 < 8 then
            hazardReader.spikeOutrunWhy = "aim close"
            return false
        end
        local value4, value5, value6, value7, value8 =
            value2 / value3, value / value3, config.tweenEscape or 26, config.spikeKeepPad or 6, false
        for index, entry in ipairs(hazardReader.zones or {}) do
            value = string.lower(tostring(entry.name or ""))
            if value:find("spike", 1, true) then
                if entry.cframe then
                    if entry.size then
                        if argument <= (entry.untilAt or argument) then
                            local position, value9, value10 =
                                entry.cframe.Position,
                                entry.size.X * 0.5,
                                max((entry.from or argument) - argument, 0) + (config.spikeKeepLag or 0.35)
                            index = min(value6 * value10, value3)
                            local value11, value12 = vector.X + value4 * index, vector.Z + value5 * index
                            if
                                (value11 - position.X) * (value11 - position.X)
                                    + (value12 - position.Z) * (value12 - position.Z)
                                < (value9 + value7) * (value9 + value7)
                            then
                                hazardReader.spikeOutrunWhy = ("in %s r%.0f at +%.1fs (%.0f along)"):format(
                                    value:sub(1, 12),
                                    value9,
                                    value10,
                                    index
                                )
                                return false
                            end
                            value8 = true
                        end
                    end
                end
            end
        end
        hazardReader.spikeOutrunWhy = value8 and "clear" or "no spikes"
        return value8
    end
    bubbleBoss.orbPathSafe = function(vector, vector2, argument, argument2)
        local value, value2 = vector2.X - vector.X, vector2.Z - vector.Z
        local value3 = sqrt(value * value + value2 * value2)
        if value3 < 0.5 then
            return true
        end
        local value4, value5, value6, value7, value8, value9, value10, value11, value12, value13, value14, value15 =
            max(argument or 16, 4),
            math.clamp(math.ceil(value3 / 2), 1, 80),
            dangerGeometry.reach or 1.8,
            max(
                config.orbSafeGap or 2.5,
                config.orbGapHitbox ~= false and context.playerHitboxW and context.playerHitboxW() or 0
            ),
            config.orbBeamMargin or 1,
            helper40(),
            value / value3,
            value2 / value3,
            math.cos(math.rad(config.orbSameWayDeg or 66)),
            config.orbSameWayNear or 10,
            max(config.orbSafeGapSame or 0.5, config.orbSameWayKeep or 1.5),
            hazardReader.sweepOrbFree ~= nil
                and (sharedValue2 or os.clock()) - hazardReader.sweepOrbFree
                    < (config.sweepOrbFreeFor or 1)
        for index = 1, #value9, 1 do
            argument = value9[index]
            local value16, value17, value18 =
                argument.osp or 0,
                argument.vw + value6 + value8,
                value10 * argument.ux + value11 * argument.uz >= value12
            if value18 then
                if value13 > 0 then
                    local value19, value20 = argument.orbX or argument.ox, argument.orbZ or argument.oz
                    value18 = if sqrt((vector.X - value19) ^ 2 + (vector.Z - value20) ^ 2)
                            < argument.vw + value6 + value13
                        then false
                        else value18
                end
            end
            local value21, value22 =
                argument.vw + value6,
                value18 and value14 or (argument.cone and (config.orbSafeGapCone or 1) or value7)
            index = value21 + value22
            if value15 then
                value21 = dangerGeometry.halfWidth or 1
                local value23, value24 =
                    argument.vw + value21,
                    config.touchdownGap or context.playerHitboxW and context.playerHitboxW()
                index = value23 + (value24 or 2 * value21) + (dangerGeometry.lag or 0)
            end
            value21, value22 = vector.X - argument.ox, vector.Z - argument.oz
            local value25, value26 =
                value21 * argument.ux + value22 * argument.uz,
                abs(value21 * argument.uz - value22 * argument.ux)
            value22, value21 =
                value25 > -value17
                    and value25 < (argument.dL or argument.L) + value17
                    and value26 < value17 + (argument.cone and max(value25, 0) * argument.cone or 0),
                min(index, argument.vw + value6 + (config.orbLeaveGap or 1))
            value25, value26 =
                (if value22 then not value22 else max(config.orbCrossSpare or 0.4, 0)) or 0, false
            for index2 = 0, value5, 1 do
                local value27 = index2 / value5
                local value28, value29 = vector.X + value * value27, vector.Z + value2 * value27
                local value30, value31 = value28 - argument.ox, value29 - argument.oz
                index2, value29 =
                    value30 * argument.ux + value31 * argument.uz,
                    abs(value30 * argument.uz - value31 * argument.ux)
                if index2 > -value17 then
                    if index2 < (argument.dL or argument.L) + value17 then
                        if value29 < value17 + (argument.cone and max(index2, 0) * argument.cone or 0) then
                            value31 = (argument2 or 0) + value3 * value27 / value4 - (argument.t0 or 0)
                            if value31 >= -0.2 - value25 then
                                local value32, value33, value34 =
                                    value16 * max(value31 - value25, 0), value16 * max(value31 + value25, 0)
                                if argument.cone then
                                    value30 = sqrt(index2 * index2 + value29 * value29)
                                    value34 = value30 < value32 and value32 - value30
                                        or value30 > value33 and value30 - value33
                                        or 0
                                else
                                    value28 = index2 < value32 and value32 - index2
                                        or index2 > value33 and index2 - value33
                                        or 0
                                    value34 = sqrt(value28 * value28 + value29 * value29)
                                end
                                if value34 < index then
                                    if value22 then
                                        if value34 < value21 then
                                            return false
                                        end
                                    else
                                        return false
                                    end
                                    value26 = true
                                end
                            end
                        end
                    end
                end
            end
            if value26 then
                index, value16 = vector2.X - argument.ox, vector2.Z - argument.oz
                value25, value22 =
                    index * argument.ux + value16 * argument.uz,
                    abs(index * argument.uz - value16 * argument.ux)
                if not (value25 <= -value17) then
                    if not (value25 >= (argument.dL or argument.L) + value17) then
                        if
                            not (
                                value22
                                >= value17 + (argument.cone and max(value25, 0) * argument.cone or 0)
                            )
                        then
                            return false
                        end
                    end
                end
            end
        end
        return true
    end
    bubbleBoss.orbArrive = function(argument, argument2, argument3)
        argument3 = argument3 or (helper40())
        local value, value2, value3 =
            dangerGeometry.reach or 1.8,
            max(
                config.orbSafeGap or 2.5,
                config.orbGapHitbox ~= false and context.playerHitboxW and context.playerHitboxW() or 0
            ),
            infinity
        for index = 1, #argument3, 1 do
            local value4 = argument3[index]
            local value5, value6, value7, value8 =
                max(value4.osp or 0, 1),
                value4.vw + value + value2,
                argument - value4.ox,
                argument2 - value4.oz
            local value9, value10 =
                value7 * value4.ux + value8 * value4.uz, abs(value7 * value4.uz - value8 * value4.ux)
            index = nil
            if value4.cone then
                index = if value9 > -value6
                    then if value9 < (value4.dL or value4.L) + value6
                        then if value10 < value6 + max(value9, 0) * value4.cone
                            then (value4.t0 or 0)
                                + max(sqrt(value9 * value9 + value10 * value10) - value6, 0) / value5
                            else index
                        else index
                    else index
            else
                if value10 < value6 then
                    if value9 < (value4.dL or value4.L) + value6 then
                        value8 = sqrt(value6 * value6 - value10 * value10)
                        index = if value9 + value8 >= 0
                            then (value4.t0 or 0) + max(value9 - value8, 0) / value5
                            else index
                    end
                end
            end
            value3 = if index then if index < value3 then index else value3 else value3
        end
        return value3
    end
    bubbleBoss.orbCrossIn = function(argument, argument2, argument3, argument4)
        if bubbleBoss.orbPathSafe(argument, argument2, argument3, 0) then
            return 0
        end
        local value, value2 = config.orbCrossStep or 0.15, argument4 or config.orbCrossLook or 2
        argument4 = value
        while argument4 <= value2 + 1.0E-6 do
            if bubbleBoss.orbPathSafe(argument, argument2, argument3, argument4) then
                return argument4
            end
            argument4 += value
        end
        return nil
    end
    bubbleBoss.orbLaneHit = function(argument, argument2, argument3, argument4)
        if config.orbLaneAvoid == false then
            return false
        end
        if hazardReader.sweepOrbFree ~= nil then
            if os.clock() - hazardReader.sweepOrbFree < (config.sweepOrbFreeFor or 1) then
                return false
            end
        end
        if runtimeState.escRedAt ~= nil then
            if os.clock() - runtimeState.escRedAt < 0.25 then
                if config.rodinYellowFreeInRed ~= false then
                    return not bubbleBoss.orbPathSafe(
                        Vector3.new(argument, 0, argument2),
                        Vector3.new(argument3, 0, argument4),
                        config.burstMax or 28
                    )
                end
            end
        end
        local value = helper40()
        if #value == 0 then
            return false
        end
        local value2, value3 = argument3 - argument, argument4 - argument2
        local value4 = max(math.ceil(sqrt(value2 * value2 + value3 * value3) / 4), 1)
        if config.laneCrossAggro ~= false then
            local value5, value6, value7, value8 =
                sqrt(value2 * value2 + value3 * value3), config.laneCrossOrbFar or 0
            for index, entry in ipairs(value) do
                local value9, value10 = entry.orbX or entry.ox, entry.orbZ or entry.oz
                local value11, value12 = argument - value9, argument2 - value10
                value9, index =
                    sqrt(value11 * value11 + value12 * value12),
                    value11 * entry.ux + value12 * entry.uz >= 0 and 1 or -1
                value10, value11 =
                    value5 < 0.5
                        or (value2 * entry.ux + value3 * entry.uz) * index / value5
                            >= -(config.laneCrossTowardCos or 0.2),
                    false
                if value9 >= value6 then
                    if value10 then
                        value12 = if value7 == nil
                            then bubbleBoss.orbPathSafe(
                                Vector3.new(argument, 0, argument2),
                                Vector3.new(argument3, 0, argument4),
                                config.burstMax or 28
                            )
                            else value7
                        value11, value7 = value12, value12
                    end
                end
                if not value11 then
                    value8 = value8 or {}
                    value8[#value8 + 1] = entry
                end
            end
            if not value8 then
                return false
            end
            value = value8
        end
        for index2 = 1, value4, 1 do
            if helper41(value, argument + value2 * index2 / value4, argument2 + value3 * index2 / value4) then
                return true
            end
        end
        return false
    end
    bubbleBoss.detour = function(vector, vector2, argument)
        if bubbleBoss.flipDetour then
            bubbleBoss.flipDetour = nil
            local value, value2, value3 = -sharedValue25, os
            value3, sharedValue25 = value2.clock(), value
            sharedValue26 = value3
            bubbleBoss.dGoal = nil
        end
        if not (bubbleBoss.pathBlocked(vector, vector2, argument)) then
            bubbleBoss.dGoal = nil
            sharedValue27, sharedValue28 = nil, nil
            return nil
        end
        local value4 = bubbleBoss.dGoal
        if value4 then
            if os.clock() - value4.at < config.bubbleCommit then
                if sqrt((value4.p.X - vector.X) ^ 2 + (value4.p.Z - vector.Z) ^ 2) > config.bubbleArrive then
                    if not (bubbleBoss.pathBlocked(vector, value4.p, argument)) then
                        return value4.p, value4.deg
                    end
                end
            end
        end
        bubbleBoss.dGoal = nil
        local value5, value6 = vector2.X - vector.X, vector2.Z - vector.Z
        value4 = sqrt(value5 * value5 + value6 * value6)
        if value4 < 2 then
            sharedValue27, sharedValue28 = nil, nil
            return nil
        end
        local value7, value8, value9 = value5 / value4, value6 / value4, os.clock()
        if sharedValue27 then
            if sharedValue28 then
                if value4 < sharedValue28 - 6 then
                    sharedValue27, sharedValue28 = value9, value4
                end
            end
        else
            sharedValue27, sharedValue28 = value9, value4
        end
        if sharedValue28 then
            if value4 < sharedValue28 then
                sharedValue28 = value4
            end
        end
        value5 = value9 - sharedValue27 > (config.bubbleDetourStuck or 3)
        value6 = min(value4, config.bubbleDetourLeg * (value5 and 2.5 or 1))
        local value10
        if value9 - sharedValue26 < (config.bubbleDetourStick or 4) then
            for index = #sharedValue29, 1, -1 do
                sharedValue29[index] = nil
            end
            for index2, entry in ipairs(sharedValue24) do
                if entry * sharedValue25 > 0 then
                    sharedValue29[#sharedValue29 + 1] = entry
                end
            end
            for index3, entry2 in ipairs(sharedValue24) do
                if entry2 * sharedValue25 <= 0 then
                    sharedValue29[#sharedValue29 + 1] = entry2
                end
            end
            value10 = sharedValue29
        else
            value10 = sharedValue24
        end
        raycastParams.FilterDescendantsInstances = { sharedValue.LocalPlayer.Character, bubbleBoss.folder }
        for index4, entry3 in ipairs(value10) do
            value9 = toRadians(entry3)
            local value11, value12 =
                value7 * cos(value9) - value8 * sin(value9), value7 * sin(value9) + value8 * cos(value9)
            local vector3, raycastResult =
                Vector3.new(vector.X + value11 * value6, vector.Y, vector.Z + value12 * value6),
                parent:Raycast(
                    vector + Vector3.new(0, 2, 0),
                    Vector3.new(value11, 0, value12) * (value6 + 3),
                    raycastParams
                )
            if not raycastResult then
                if not (bubbleBoss.pathBlocked(vector, vector3, argument)) then
                    index4 = sqrt((vector2.X - vector3.X) ^ 2 + (vector2.Z - vector3.Z) ^ 2)
                    value12 = value5 and index4 < value4 - 2 or index4 <= value4 + value6 * 0.5
                    if value12 then
                        bubbleBoss.dGoal = { p = vector3, at = os.clock(), deg = entry3 }
                        local value13, value14, value15 = entry3 >= 0 and 1 or -1, os
                        value15, sharedValue25 = value14.clock(), value13
                        sharedValue26 = value15
                        return vector3, entry3
                    end
                end
            end
        end
        return nil
    end
    bubbleBoss.stop = function()
        helper19()
        for index = #sharedValue22, 1, -1 do
            sharedValue22[index] = nil
        end
        if bubbleBoss.folder then
            pcall(function()
                bubbleBoss.folder:Destroy()
            end)
            bubbleBoss.folder = nil
        end
        bubbleBoss.active = false
        bubbleBoss.primary = nil
        bubbleBoss.dir = nil
        bubbleBoss.lethal = false
        bubbleBoss.goal = nil
        bubbleBoss.dGoal = nil
        bubbleBoss.anchor = nil
    end
    bubbleBoss.status = function()
        return {
            active = bubbleBoss.active,
            lethal = bubbleBoss.lethal,
            threats = bubbleBoss.count,
            warm = bubbleBoss.warmCount,
            warnings = bubbleBoss.warnCount,
            escapes = bubbleBoss.escapes,
            primary = bubbleBoss.primary and bubbleBoss.primary.box.name or nil,
            tti = bubbleBoss.primary and bubbleBoss.primary.tti or nil,
        }
    end
end
