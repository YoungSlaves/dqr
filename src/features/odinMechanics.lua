-- Extracted verbatim from harvardd.lua lines 36828-40294; presentation owned elsewhere.
return function(context)
    local config = context.CFG
    local hazardReader = context.RD
    local workspace = game:GetService("Workspace")
    local sqrt = math.sqrt
    local floor = math.floor
    local abs = math.abs
    local infinity = math.huge
    local max = math.max
    local min, odinMechanics, setMetatable, weakKeys = math.min, {}, setmetatable, { __mode = "k" }
    odinMechanics.sets = setMetatable({}, weakKeys)
    odinMechanics.setList = {}
    odinMechanics.orbs = {}
    odinMechanics.orbList = {}
    odinMechanics.missiles = {}
    odinMechanics.missileList = {}
    odinMechanics.arrays = {}
    odinMechanics.lines = {}
    odinMechanics.lineList = {}
    odinMechanics.lastTick = 0
    context.OD = odinMechanics
    local function helper(part)
        local value = max(part.Size.X, part.Size.Z) * 0.5
        if value < 10 then
            return nil
        end
        local value2 = part.CFrame.LookVector
        local value3, value4 = value2.X, value2.Z
        value2 = sqrt(value3 * value3 + value4 * value4)
        if value2 < 0.01 then
            return nil
        end
        value3 /= value2
        value4 /= value2
        value2 = part.Position
        return value2.X - value3 * (value / 2),
            value2.Z - value4 * (value / 2),
            value,
            value - (value >= 100 and (config.ringThicknessOuter or 17.5) or (config.ringThickness or 12.5)),
            value3,
            value4,
            value2.Y
    end
    odinMechanics.noteRingSet = function(model, spawn)
        local value = odinMechanics.sets[model]
        if value then
            return value
        end
        value = { model = model, spawn = spawn, boxed = {}, parts = {}, bands = {}, n = 0, centre = nil }
        odinMechanics.sets[model] = value
        odinMechanics.setList[#odinMechanics.setList + 1] = value
        if context.logT then
            context.logT("rings", 2, "Odin", "ring set seen")
        end
        return value
    end
    local function helper2(argument, madeAt)
        local value = config.ringLive or 1.3
        if not argument.centreX then
            local value2 = argument.model:FindFirstChild("center") or argument.model:FindFirstChild("Center")
            if value2 then
                if value2:IsA("BasePart") then
                    argument.centreX, argument.centreZ = value2.Position.X, value2.Position.Z
                end
            end
        end
        for index, child in ipairs(argument.model:GetChildren()) do
            if child:IsA("BasePart") then
                if not argument.boxed[child] then
                    index = string.lower(child.Name)
                    if index == "ring" then
                        local value3, centreZ, value4, inner, value5, value6, value7 = helper(child)
                        if value3 and argument.centreX then
                            local value8, value9 =
                                child.Position.X - argument.centreX, child.Position.Z - argument.centreZ
                            local value10 = sqrt(value8 * value8 + value9 * value9)
                            if value10 > 1 then
                                value5, value6 = value8 / value10, value9 / value10
                            end
                            value3, centreZ = argument.centreX, argument.centreZ
                        else
                            local arenaCentre = hazardReader.arenaCentre
                            value3 = value3
                                and (
                                    if arenaCentre
                                        then if abs(
                                                sqrt(
                                                    (child.Position.X - arenaCentre.X) ^ 2
                                                        + (child.Position.Z - arenaCentre.Z) ^ 2
                                                )
                                                    - value4 / 2
                                            )
                                                > (config.ringPosTol or 4)
                                            then nil
                                            else value3
                                        else value3
                                )
                        end
                        if value3 then
                            argument.boxed[child] = true
                            argument.parts[#argument.parts + 1] = child
                            argument.bands[#argument.bands + 1] = {
                                cx = value3,
                                cz = centreZ,
                                R = value4,
                                inner = inner,
                                sx = value5,
                                sz = value6,
                            }
                            argument.n = argument.n + 1
                            if context.addZone then
                                context.addZone({
                                    name = "ring arc",
                                    kind = "zone",
                                    bubbleKeep = true,
                                    slim = config.ringSlim,
                                    tight = true,
                                    cframe = CFrame.new(value3, value7, centreZ),
                                    size = Vector3.new(
                                        (value4 + (config.ringPad or 0)) * 2,
                                        12,
                                        (value4 + (config.ringPad or 0)) * 2
                                    ),
                                    round = true,
                                    ring = inner - (config.ringPad or 0),
                                    sx = value5,
                                    sz = value6,
                                    from = argument.spawn,
                                    untilAt = argument.spawn + value,
                                    exact = true,
                                    madeAt = madeAt,
                                    model = argument.model,
                                })
                            end
                        end
                    elseif index == "center" then
                        argument.boxed[child] = true
                        argument.centre = child
                        local position, value11 =
                            child.Position, max(child.Size.X, child.Size.Y, child.Size.Z)
                        argument.centreR, argument.centreX, argument.centreZ =
                            value11 * 0.5, position.X, position.Z
                        if context.addZone then
                            context.addZone({
                                name = "ring centre",
                                kind = "zone",
                                bubbleKeep = true,
                                cframe = CFrame.new(position.X, position.Y, position.Z),
                                size = Vector3.new(value11, 12, value11),
                                round = true,
                                from = argument.spawn,
                                untilAt = argument.spawn + value,
                                exact = true,
                                madeAt = madeAt,
                                model = argument.model,
                            })
                        end
                    end
                end
            end
        end
    end
    local function helper3(argument)
        if config.ringInvulnFree == false then
            return false
        elseif hazardReader.charAt == nil then
            return false
        end
        return argument.spawn + (config.ringLive or 1.3)
            <= hazardReader.charAt + (config.invulnAfterRespawn or 4) - (config.ringInvulnMargin or 0.2)
    end
    local function helper4(argument, argument2, argument3, argument4)
        if helper3(argument) then
            return false
        end
        argument4 = (argument4 or 0) + (config.ringPad or 0)
        local bands = argument.bands
        for index = 1, #bands, 1 do
            local zone = bands[index]
            local value, value2 = argument2 - zone.cx, argument3 - zone.cz
            if value * zone.sx + value2 * zone.sz >= -argument4 then
                index = sqrt(value * value + value2 * value2)
                if index >= zone.inner - argument4 then
                    if index <= zone.R + argument4 then
                        return true, zone.R
                    end
                end
            end
        end
        if argument.centreR then
            local value3, value4 = argument2 - argument.centreX, argument3 - argument.centreZ
            if sqrt(value3 * value3 + value4 * value4) <= argument.centreR + argument4 then
                return true, 0
            end
        end
        return false
    end
    odinMechanics.ringClear = function(argument, argument2, argument3)
        local value, value2 = config.ringLive or 1.3
        for index = 1, #odinMechanics.setList, 1 do
            local value3 = odinMechanics.setList[index]
            index = argument3 - value3.spawn
            if index >= -0.05 then
                if index <= value then
                    if value3.model.Parent then
                        if not (helper3(value3)) then
                            local bands, value4 = value3.bands, value2
                            for index2 = 1, #bands, 1 do
                                local zone = bands[index2]
                                local value5, value6 = argument - zone.cx, argument2 - zone.cz
                                if value5 * zone.sx + value6 * zone.sz >= 0 then
                                    index2 = sqrt(value5 * value5 + value6 * value6)
                                    local value7 = if index2 < zone.inner
                                        then zone.inner - index2
                                        else if index2 > zone.R then index2 - zone.R else 0
                                    value4 = if value4 == nil
                                        then value7
                                        else if value7 < value4 then value7 else value4
                                end
                            end
                            value2 = value4
                        end
                    end
                end
            end
        end
        return value2
    end
    odinMechanics.inRingBand = function(argument, argument2, argument3, argument4)
        argument4 = argument4 or 0
        local value = config.ringLive or 1.3
        for index = 1, #odinMechanics.setList, 1 do
            local value2 = odinMechanics.setList[index]
            index = argument3 - value2.spawn
            if index >= -0.05 then
                if index <= value then
                    if value2.model.Parent then
                        local value3, value4 = helper4(value2, argument, argument2, argument4)
                        if value3 then
                            return true, value2, value4
                        end
                    end
                end
            end
        end
        return false
    end
    odinMechanics.ignoreSets = {}
    odinMechanics.ignoreLines = {}
    local function helper5(argument, argument2, argument3, argument4)
        local value, value2 = config.ringLive or 1.3, config.ringFlashFrom or 0.9
        for index = 1, #odinMechanics.setList, 1 do
            local value3 = odinMechanics.setList[index]
            index = argument3 - value3.spawn
            if index >= value2 then
                if index <= value then
                    if value3.model.Parent then
                        if helper4(value3, argument, argument2, argument4) then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end
    odinMechanics.pathCrossesRing = function(argument, argument2, argument3, argument4, argument5, argument6)
        if #odinMechanics.setList == 0 then
            return false
        end
        local value, value2 = argument3 - argument, argument4 - argument2
        argument3 = sqrt(value * value + value2 * value2)
        if argument3 < 1 then
            return false
        end
        local value3, value4 = config.ringSlim or 2.5, max(2, math.ceil(argument3 / 2))
        argument6 = argument6 or argument5
        for index = 1, value4, 1 do
            argument4 = index / value4
            index, argument3 = argument + value * argument4, argument2 + value2 * argument4
            if
                odinMechanics.inRingBand(
                    index,
                    argument3,
                    argument5 + (argument6 - argument5) * argument4,
                    value3
                )
            then
                return true
            end
            if odinMechanics.inRingBand(index, argument3, argument5, value3) then
                return true
            end
        end
        return false
    end
    local function helper6(argument, argument2, part, spawn)
        local value, position = argument2[part], part.Position
        local value2 = value
        if not value2 then
            value = {
                part = part,
                x = position.X,
                z = position.Z,
                vx = 0,
                vz = 0,
                t = spawn,
                spawn = spawn,
                hasV = false,
            }
            argument2[part] = value
            argument[#argument + 1] = value
            return value
        end
        value = spawn - value2.t
        if value > 0.02 then
            argument, argument2, part =
                (position.X - value2.x) / value, (position.Z - value2.z) / value, false
            if value2.hasV then
                if config.orbBounce ~= false then
                    local value3 = value2.vx * argument + value2.vz * argument2
                    part = value3 < 0
                        or value3 * value3
                            < 0.5 * (value2.vx * value2.vx + value2.vz * value2.vz) * (argument * argument + argument2 * argument2)
                end
            end
            if value2.hasV then
                if part then
                    value2.vx = argument
                    value2.vz = argument2
                    value2.hasV = true
                else
                    value2.vx, value2.vz = value2.vx * 0.5 + argument * 0.5, value2.vz * 0.5 + argument2 * 0.5
                end
            else
                value2.vx = argument
                value2.vz = argument2
                value2.hasV = true
            end
            value2.x, value2.z = position.X, position.Z
            value2.t = spawn
        end
        return value2
    end
    local function helper7(argument, argument2, argument3, argument4)
        for index = #argument, 1, -1 do
            local value = argument[index]
            local parent = value.part.Parent
            if
                (if parent then argument3 - value.spawn > argument4 else not parent)
                or value.part:IsA("BasePart") and value.part.Transparency >= 1
            then
                argument2[value.part] = nil
                table.remove(argument, index)
            end
        end
    end
    local function helper8()
        local arenaCentre = hazardReader.arenaCentre
        if not arenaCentre then
            odinMechanics.arrays = {}
            return
        end
        local arrays = {}
        for index = 1, #odinMechanics.missileList, 1 do
            local value = odinMechanics.missileList[index]
            local value2, value3 = value.vx, value.vz
            index = sqrt(value2 * value2 + value3 * value3)
            if index < 20 then
                local lookVector = value.part.CFrame.LookVector
                value2, value3 = lookVector.X, lookVector.Z
                index = sqrt(value2 * value2 + value3 * value3)
                if index > 0.01 then
                    if (arenaCentre.X - value.x) * value2 + (arenaCentre.Z - value.z) * value3 < 0 then
                        local value4, value5 = -value2, -value3
                        value2, value3 = value4, value5
                    end
                end
            end
            if index > 0.01 then
                value2 /= index
                value3 /= index
                local value6 = math.atan2(value2, value3)
                local value7
                for index2, array in ipairs(arrays) do
                    if
                        abs((value6 - array.yaw + 3.141592653589793) % 6.283185307179586 - 3.141592653589793)
                        < 0.13962634015954636
                    then
                        value7 = array
                        break
                    end
                end
                if not value7 then
                    value7 = {
                        yaw = value6,
                        lx = value2,
                        lz = value3,
                        nx = -value3,
                        nz = value2,
                        at = value.spawn,
                        n = 0,
                        maxAlong = -infinity,
                        pending = 0,
                        lastSpawn = value.spawn,
                    }
                    arrays[#arrays + 1] = value7
                end
                value7.n = value7.n + 1
                if value.spawn < value7.at then
                    value7.at = value.spawn
                end
                if value.spawn > value7.lastSpawn then
                    value7.lastSpawn = value.spawn
                end
                value6 = (value.x - arenaCentre.X) * value7.lx + (value.z - arenaCentre.Z) * value7.lz
                if value6 > value7.maxAlong then
                    value7.maxAlong = value6
                end
                if value6 < 30 then
                    value7.pending = value7.pending + 1
                end
            end
        end
        odinMechanics.arrays = arrays
    end
    odinMechanics.lineSeenAt = odinMechanics.lineSeenAt or {}
    if not odinMechanics.lineSeenConn then
        odinMechanics.lineSeenConn = workspace.ChildAdded:Connect(function(argument)
            if argument.Name == "thirdBossLineShot" then
                if argument:IsA("Model") then
                    odinMechanics.lineSeenAt[argument] = os.clock()
                end
            end
        end)
    end
    odinMechanics.WATCH = {
        thirdBossMultiRings = true,
        thirdBossBouncingOrb = true,
        thirdBossMissile = true,
        thirdBossLineShot = true,
    }
    odinMechanics.watchList = function(argument)
        if config.perfMemo == false then
            return workspace:GetChildren()
        end
        local value = odinMechanics.watchSet
        if
            if value
                then argument - (odinMechanics.watchFullAt or -math.huge) > (config.odWatchFull or 2)
                else not value
        then
            local watchSet, watchSet2 = odinMechanics.watchSet
            if watchSet then
                watchSet2 = watchSet
            else
                local setMetatable2, weakKeys2 = setmetatable, { __mode = "k" }
                watchSet2 = setMetatable2({}, weakKeys2)
            end
            odinMechanics.watchSet = watchSet2
            odinMechanics.watchFullAt = argument
            for index, child in ipairs(workspace:GetChildren()) do
                if odinMechanics.WATCH[child.Name] then
                    odinMechanics.watchSet[child] = true
                end
            end
        end
        if not odinMechanics.watchConn then
            odinMechanics.watchConn = workspace.ChildAdded:Connect(function(argument2)
                if context.RT then
                    if context.RT.destroyed then
                        if odinMechanics.watchConn then
                            odinMechanics.watchConn:Disconnect()
                            odinMechanics.watchConn = nil
                        end
                        return
                    end
                end
                if odinMechanics.watchSet then
                    if odinMechanics.WATCH[argument2.Name] then
                        odinMechanics.watchSet[argument2] = true
                    end
                end
            end)
        end
        argument, value = odinMechanics.watchArr or {}, 0
        for entry in pairs(odinMechanics.watchSet) do
            if entry.Parent == workspace then
                value += 1
                argument[value] = entry
            else
                odinMechanics.watchSet[entry] = nil
            end
        end
        for index2 = value + 1, #argument, 1 do
            argument[index2] = nil
        end
        odinMechanics.watchArr = argument
        return argument
    end
    odinMechanics.tick = function(argument)
        odinMechanics.lastTick = argument
        local f = argument - (odinMechanics.prevTick or argument)
        odinMechanics.prevTick = argument
        local ringLive = config.ringLive
        for index, entry in ipairs(odinMechanics.watchList(argument)) do
            index = entry.Name
            if index == "thirdBossMultiRings" then
                local value = odinMechanics.noteRingSet(entry, argument)
                if value.n < 7 then
                    if argument - value.spawn < 2 then
                        helper2(value, argument)
                    end
                end
                if argument - value.spawn < (config.ringSettle or 2) then
                    for index2 = 1, #value.parts, 1 do
                        local value2 = value.parts[index2]
                        if value2.Parent then
                            local value3, value4, value5, inner, value6, value7 = helper(value2)
                            local zone = value.bands[index2]
                            if value3 then
                                if zone then
                                    zone.cx = value3
                                    zone.cz = value4
                                    zone.R = value5
                                    zone.inner = inner
                                    zone.sx = value6
                                    zone.sz = value7
                                end
                            end
                        end
                    end
                end
            elseif index == "thirdBossBouncingOrb" and entry:IsA("BasePart") then
                helper6(odinMechanics.orbList, odinMechanics.orbs, entry, argument)
            elseif index == "thirdBossMissile" and entry:IsA("BasePart") then
                if entry.Transparency < 1 then
                    helper6(odinMechanics.missileList, odinMechanics.missiles, entry, argument)
                end
            elseif index == "thirdBossLineShot" then
                if entry:IsA("Model") then
                    if not odinMechanics.lines[entry] then
                        local part = entry:FindFirstChild("hitBox")
                            or entry:FindFirstChild("HitBox")
                            or entry:FindFirstChild("precast")
                        if part then
                            if part:IsA("BasePart") then
                                local value8 = {
                                    model = entry,
                                    part = part,
                                    spawn = odinMechanics.lineSeenAt and odinMechanics.lineSeenAt[entry]
                                        or argument,
                                }
                                if odinMechanics.lineSeenAt then
                                    odinMechanics.lineSeenAt[entry] = nil
                                end
                                odinMechanics.lines[entry] = value8
                                odinMechanics.lineList[#odinMechanics.lineList + 1] = value8
                                if config.odinFirstBeamOnly ~= false then
                                    local ignoredModels, ignoredModels2 = odinMechanics.ignoredModels
                                    if ignoredModels then
                                        ignoredModels2 = ignoredModels
                                    else
                                        local setMetatable2, weakKeys2 = setmetatable, { __mode = "k" }
                                        ignoredModels2 = setMetatable2({}, weakKeys2)
                                    end
                                    odinMechanics.ignoredModels = ignoredModels2
                                    if
                                        value8.spawn - (odinMechanics.lastLineAt or -infinity)
                                        > (config.odinFanQuiet or 2)
                                    then
                                        odinMechanics.fan = { first = value8, startAt = value8.spawn }
                                        odinMechanics.central = value8
                                        odinMechanics.fanGreen = nil
                                        context.logT("odin", 1, "Odin", "fan: first beam - red")
                                    else
                                        value8.ignored = true
                                        odinMechanics.ignoredModels[entry] = true
                                    end
                                    odinMechanics.lastLineAt =
                                        math.max(odinMechanics.lastLineAt or -infinity, value8.spawn)
                                elseif odinMechanics.central == nil then
                                    odinMechanics.central = value8
                                end
                            end
                        end
                    end
                end
            end
        end
        for index3 = #odinMechanics.setList, 1, -1 do
            local value9 = odinMechanics.setList[index3]
            local parent = value9.model.Parent
            if if parent then argument - value9.spawn > 25 else not parent then
                odinMechanics.sets[value9.model] = nil
                table.remove(odinMechanics.setList, index3)
            end
        end
        helper7(odinMechanics.orbList, odinMechanics.orbs, argument, 40)
        helper7(odinMechanics.missileList, odinMechanics.missiles, argument, 12)
        for index4 = 1, #odinMechanics.lineList, 1 do
            local value10 = odinMechanics.lineList[index4]
            if not value10.firedAt then
                if value10.model then
                    if value10.model.Parent then
                        index4 = value10.model:FindFirstChild("precast")
                        local sig = index4 and floor(index4.Transparency * 100 + 0.5) or -1
                        if value10.sig == nil then
                            value10.sig = sig
                        elseif sig ~= value10.sig then
                            local value11 = argument - value10.spawn
                            if value11 >= (config.lineFiredMin or 0.3) then
                                value10.firedAt = argument
                                if value10 == odinMechanics.central then
                                    if odinMechanics.noteGreen then
                                        pcall(odinMechanics.noteGreen, value10, argument)
                                    end
                                end
                                odinMechanics.firedAges = odinMechanics.firedAges or {}
                                odinMechanics.firedAges[#odinMechanics.firedAges + 1] = value11
                                if #odinMechanics.firedAges > 40 then
                                    table.remove(odinMechanics.firedAges, 1)
                                end
                                if config.lineFiredLog ~= false then
                                    context.logT(
                                        "odin",
                                        1,
                                        "Odin",
                                        ("line shot fired at age %.2f (precast %d -> %d)"):format(
                                            value11,
                                            value10.sig,
                                            sig
                                        )
                                    )
                                end
                            end
                            value10.sig = sig
                        end
                    end
                end
            end
        end
        for index5 = 1, #odinMechanics.lineList, 1 do
            local value12 = odinMechanics.lineList[index5]
            if not value12.firedAt then
                if not value12.ignored then
                    index5 = hazardReader.models and hazardReader.models[value12.model]
                    if index5 and (index5.detonatedAt or index5.fired) then
                        if argument - value12.spawn >= (config.lineFiredMin or 0.3) then
                            value12.firedAt = argument
                            if value12 == odinMechanics.central then
                                if odinMechanics.noteGreen then
                                    pcall(odinMechanics.noteGreen, value12, argument)
                                end
                            end
                        end
                    end
                end
            end
        end
        for index6 = #odinMechanics.lineList, 1, -1 do
            local value13 = odinMechanics.lineList[index6]
            if not value13.model.Parent then
                if not value13.goneAt then
                    value13.goneAt = argument
                end
            end
            if
                value13.goneAt and argument > value13.goneAt + (config.beamHitTail or 0.2)
                or argument - value13.spawn > 6
            then
                odinMechanics.lines[value13.model] = nil
                if odinMechanics.danceSide then
                    odinMechanics.danceSide[value13.model] = nil
                end
                if odinMechanics.central == value13 then
                    odinMechanics.central = nil
                end
                table.remove(odinMechanics.lineList, index6)
            end
        end
        helper8()
    end
    local function helper9(argument, argument2, argument3, argument4, argument5)
        local arenaCentre = hazardReader.arenaCentre
        if not arenaCentre then
            return false
        end
        local value, value2 = config.missileLanePitch or 15, (config.missileLaneWidth or 10) * 0.5
        for index = 1, argument5 and 0 or #odinMechanics.missileList, 1 do
            local value3 = odinMechanics.missileList[index]
            index = sqrt(value3.vx * value3.vx + value3.vz * value3.vz)
            if index > 20 then
                local value4, value5, value6, value7 =
                    value3.vx / index, value3.vz / index, argument - value3.x, argument2 - value3.z
                local value8 = value6 * value4 + value7 * value5
                if value8 > -(config.missileBodyKeep or 20) then
                    if abs(-value5 * value6 + value4 * value7) <= value2 + argument4 then
                        if value8 / index <= argument3 - value3.t + 2.5 then
                            return true
                        end
                    end
                end
            end
        end
        for index2, array in ipairs(odinMechanics.arrays) do
            index2, argument5 =
                argument3 - array.at,
                config.arrayLanePending == true and array.pending > 0
                    or argument3 - array.lastSpawn < (config.arrayGrace or 1.2)
                        and argument3 >= array.lastSpawn - 0.1
            if index2 <= (config.volleyLive or 7) then
                if argument5 then
                    local value9 = (argument - arenaCentre.X) * array.nx
                        + (argument2 - arenaCentre.Z) * array.nz
                    if abs(value9) <= 120 + value2 + argument4 then
                        if abs(value9 - floor(value9 / value + 0.5) * value) <= value2 + argument4 then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end
    local function helper10(argument, argument2, argument3, argument4, argument5, argument6)
        local value = config.fieldLineLive or 1.2
        argument5 = argument5 or -0.05
        for index = 1, #odinMechanics.lineList, 1 do
            local value2 = odinMechanics.lineList[index]
            local value3, value4, value5 = argument3 - value2.spawn, config.odinAllLanes == false
            if value4 then
                index = config.odinCentralBeam ~= false and odinMechanics.central ~= nil
                value5 = if index then value2 == odinMechanics.central else not index
            else
                value5 = value4
            end
            index, value4 =
                (value5 or config.odinAllLanes ~= false)
                    and not (value2.ignored and config.odinFirstBeamOnly ~= false),
                value2.part.Parent ~= nil
                    or value2.goneAt ~= nil and argument3 <= value2.goneAt + (config.beamHitTail or 0.2)
            if index then
                if value3 >= argument5 then
                    if value3 <= value + (value2.goneAt and (config.beamHitTail or 0.2) or 0) then
                        if value4 then
                            if not (argument6 and odinMechanics.ignoreLines[value2]) then
                                local transform, value6 = value2.part.CFrame, value2.part.Size
                                local value7, lookVector, value8 =
                                    transform.Position, transform.LookVector, transform.RightVector
                                local value9, value10, value11, value12, value13, value14, value15, value16 =
                                    argument - value7.X,
                                    argument2 - value7.Z,
                                    max(value6.Z, value6.X) * 0.5,
                                    min(value6.Z, value6.X) * 0.5
                                if value6.Z >= value6.X then
                                    value13, value14, value15, value16 =
                                        lookVector.X, lookVector.Z, value8.X, value8.Z
                                else
                                    value13, value14, value15, value16 =
                                        value8.X, value8.Z, lookVector.X, lookVector.Z
                                end
                                value5, value8 =
                                    sqrt(value13 * value13 + value14 * value14),
                                    sqrt(value15 * value15 + value16 * value16)
                                if value5 > 0.01 then
                                    if value8 > 0.01 then
                                        value7, value6 =
                                            (value9 * value13 + value10 * value14) / value5,
                                            (value9 * value15 + value10 * value16) / value8
                                        if abs(value7) <= value11 + argument4 then
                                            if abs(value6) <= value12 + argument4 then
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
        return false
    end
    local function helper11(argument)
        if argument.bT ~= argument.t then
            argument.bT = argument.t
            argument.bH, argument.bX, argument.bZ, argument.bVX, argument.bVZ =
                context.orbBounce(argument.x, argument.z, argument.vx, argument.vz)
            argument.bS = argument.bH and sqrt(argument.bVX * argument.bVX + argument.bVZ * argument.bVZ) or 0
        end
        return argument.bH
    end
    local function odinLanes(laneAt)
        if config.odinOrbLanes == false then
            return nil
        elseif context.rodinOrbs then
            if context.rodinOrbs() then
                if context.BB then
                    if not context.BB.blueBeams then
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
        if odinMechanics.laneAt == laneAt then
            return odinMechanics.laneMap
        end
        local laneMap = {}
        for index, entry in ipairs((context.BB.blueBeamsFull or context.BB.blueBeams)()) do
            if entry.orb then
                if not entry.cone then
                    index = entry.osp
                    if index then
                        if index > 1 then
                            local value = laneMap[entry.orb]
                            if not value then
                                value = {}
                                laneMap[entry.orb] = value
                            end
                            value[#value + 1] = entry
                        end
                    end
                end
            end
        end
        odinMechanics.laneAt = laneAt
        odinMechanics.laneMap = laneMap
        return laneMap
    end
    odinMechanics.odinLanes = odinLanes
    local function lanePos(argument, argument2)
        for index = 1, #argument, 1 do
            local value = argument[index]
            index = (argument2 - (value.t0 or 0)) * value.osp
            if index >= 0 then
                if index <= (value.dL or value.L) then
                    return value.ox + value.ux * index, value.oz + value.uz * index
                end
            end
        end
        return nil
    end
    odinMechanics.lanePos = lanePos
    local function helper12(argument, argument2, argument3, argument4, argument5, argument6)
        local value, value2, value3 =
            (config.fieldOrbKeep or 10) + argument5, odinLanes(argument4), hazardReader.orbBlastAt
        local value4 = if argument6
            then value3 ~= nil and abs(argument3 - value3) < 0.5
            else value3 ~= nil
                and value3 - argument3 < (config.orbBlastLead or 2) + 0.3
                and argument3 < value3 + 0.8
        value4 = if config.orbBlastOnContact ~= false then false else value4
        argument6 = (config.orbBlastRadius or 26) + argument5 + 2
        for index = 1, #odinMechanics.orbList, 1 do
            value3 = odinMechanics.orbList[index]
            index = max(argument3 - value3.t, 0)
            local value5, value6, value7, value8, value9, value10 =
                value3.x + value3.vx * index, value3.z + value3.vz * index, 0, value2 and value2[value3.part]
            local value11 = value6
            if value8 then
                value9, value6 = lanePos(value8, argument3 - argument4)
            else
                value6 = value10
            end
            if value9 then
                value5 = value9
            else
                value8 = helper11(value3)
                if value8 then
                    if index > value8 then
                        value10 = index - value8
                        local value12, value13, value14 =
                            value3.bX + value3.bVX * value10,
                            value3.bZ + value3.bVZ * value10,
                            math.min(
                                value10 * value3.bS * (config.orbScatter or 0.27),
                                config.orbScatterMax or 10
                            )
                        value5, value6, value7 = value12, value13, value14
                    else
                        value6 = value11
                    end
                else
                    value6 = value11
                end
            end
            value8, value11 = argument - value5, argument2 - value6
            value10 = sqrt(value8 * value8 + value11 * value11)
            if value10 <= value + value7 then
                return true
            end
            if value4 then
                if value10 <= argument6 then
                    return true
                end
            end
        end
        argument6 = hazardReader.zones
        for index2 = 1, #argument6, 1 do
            value2 = argument6[index2]
            if value2.name == "orb explosion" then
                if value2.r then
                    if (value2.from or 0) <= argument3 + 0.3 then
                        if (value2.untilAt or infinity) >= argument3 then
                            value, argument4 = argument - value2.cx, argument2 - value2.cz
                            if sqrt(value * value + argument4 * argument4) <= value2.r + argument5 then
                                return true
                            end
                        end
                    end
                end
            end
        end
        return false
    end
    local function orbLaneCost(argument, argument2)
        if #odinMechanics.orbList == 0 then
            return 0
        end
        local value, value2, value3, value4 =
            config.orbLaneLook or 1.8, config.orbLaneWidth or 18, config.orbLaneCost or 45, 0
        for index = 1, #odinMechanics.orbList, 1 do
            local value5 = odinMechanics.orbList[index]
            index = sqrt((value5.vx or 0) ^ 2 + (value5.vz or 0) ^ 2)
            if index > 6 then
                local value6, value7, value8, value9 =
                    value5.vx / index, value5.vz / index, argument - value5.x, argument2 - value5.z
                local value10 = value8 * value6 + value9 * value7
                if value10 > -8 then
                    if value10 <= index * value then
                        local value11 = abs(-value7 * value8 + value6 * value9)
                        value4 = if value11 <= value2
                            then value4 + value3 * (1 - value11 / value2)
                            else value4
                    end
                end
                value10 = helper11(value5)
                if value10 then
                    if value10 < value then
                        if value5.bS > 6 then
                            value9, value8, value6, value7 =
                                value5.bVX / value5.bS,
                                value5.bVZ / value5.bS,
                                argument - value5.bX,
                                argument2 - value5.bZ
                            local value12 = value6 * value9 + value7 * value8
                            if value12 > -8 then
                                if value12 <= value5.bS * (value - value10) then
                                    local value13 = abs(-value8 * value6 + value9 * value7)
                                    value4 = if value13 <= value2
                                        then value4 + value3 * (1 - value13 / value2)
                                        else value4
                                end
                            end
                        end
                    end
                end
            end
        end
        return value4
    end
    odinMechanics.orbLaneCost = orbLaneCost
    local function helper13(argument, argument2, argument3)
        local arenaCentre = hazardReader.arenaCentre
        if not arenaCentre then
            return false
        end
        local value, value2 = argument - arenaCentre.X, argument2 - arenaCentre.Z
        argument2 = sqrt(value * value + value2 * value2)
        if argument2 <= (config.fieldArenaR or 105) then
            return false
        end
        return argument3 == nil or argument2 > argument3 - 1
    end
    local function helper14(argument, argument2, argument3, argument4)
        if context.rodinMissiles and context.rodinMissiles() then
            local value, value2 = (config.missileLaneHalf or 5) + argument4, 16 + argument4
            for index = 1, #odinMechanics.missileList, 1 do
                local value3 = odinMechanics.missileList[index]
                index = sqrt(value3.vx * value3.vx + value3.vz * value3.vz)
                if index > 1 then
                    local value4 = max(argument3 - value3.t, 0)
                    local value5, value6, value7, value8 =
                        value3.x + value3.vx * value4,
                        value3.z + value3.vz * value4,
                        value3.vx / index,
                        value3.vz / index
                    local value9, value10 = argument - value5, argument2 - value6
                    if abs(value9 * value7 + value10 * value8) <= value2 then
                        if abs(-value8 * value9 + value7 * value10) <= value then
                            return true
                        end
                    end
                end
            end
            return false
        end
        local value11 = (config.missileBodyKeep or 20) + argument4
        for index2 = 1, #odinMechanics.missileList, 1 do
            argument4 = odinMechanics.missileList[index2]
            index2 = max(argument3 - argument4.t, 0)
            local value12, value13 = argument4.x + argument4.vx * index2, argument4.z + argument4.vz * index2
            local value14, value15 = argument - value12, argument2 - value13
            if value14 * value14 + value15 * value15 <= value11 * value11 then
                return true
            end
        end
        return false
    end
    local function ringLethalAt(argument, argument2, argument3, argument4)
        local value, value2 = config.ringLive or 1.3, config.ringHazardFrom or 0.7
        for index = 1, #odinMechanics.setList, 1 do
            local value3 = odinMechanics.setList[index]
            index = argument3 - value3.spawn
            if index >= value2 then
                if index <= value then
                    if value3.model.Parent then
                        if helper4(value3, argument, argument2, argument4) then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end
    odinMechanics.ringLethalAt = ringLethalAt
    local function hazardAt(argument, argument2, argument3, argument4, argument5)
        if config.ringCellFlashOnly ~= false then
            if ringLethalAt(argument, argument2, argument3, argument5) then
                return "ring"
            end
        elseif odinMechanics.inRingBand(argument, argument2, argument3, argument5) then
            return "ring"
        end
        if config.missileCellBodyOnly ~= false then
            if helper14(argument, argument2, argument3, argument5 + (config.missileCellMargin or 4)) then
                return "missile"
            elseif config.missileCellLanes == true then
                if helper9(argument, argument2, argument3, argument5, true) then
                    return "missile"
                end
            end
        elseif helper9(argument, argument2, argument3, argument5) then
            return "missile"
        end
        if
            helper10(
                argument,
                argument2,
                argument3,
                argument5 + (config.fieldLineMargin or 3),
                (config.lineHitFrom or 0.65) - 0.2
            )
        then
            return "line"
        end
        if helper12(argument, argument2, argument3, argument4, argument5) then
            return "orb"
        end
        return nil
    end
    odinMechanics.hazardAt = hazardAt
    local function pathHazardAt(argument, argument2, argument3, argument4, argument5)
        if helper5(argument, argument2, argument3, argument5) then
            return "ring"
        end
        if helper14(argument, argument2, argument3, argument5) then
            return "missile"
        end
        if
            helper10(
                argument,
                argument2,
                argument3,
                argument5 + (config.fieldLineMargin or 3.5),
                config.lineHitFrom or 0.65,
                true
            )
        then
            return "line"
        end
        if helper12(argument, argument2, argument3, argument4, argument5, true) then
            return "orb"
        end
        return nil
    end
    odinMechanics.pathHazardAt = pathHazardAt
    odinMechanics.ringsActive = function(argument)
        local value = config.ringLive or 1.3
        for index = 1, #odinMechanics.setList, 1 do
            local value2 = odinMechanics.setList[index]
            if argument - value2.spawn <= value + (config.blueRailHold or 0.3) then
                if value2.model.Parent then
                    if #value2.bands > 0 then
                        if not (helper3(value2)) then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end
    odinMechanics.blueArcs = function(argument)
        local value, value2, value3 =
            config.ringLive or 1.3, {}, (config.fieldArenaR or 105) - (config.blueRailWallGap or 4)
        for index = 1, #odinMechanics.setList, 1 do
            local set = odinMechanics.setList[index]
            index = argument - set.spawn
            if
                index >= -0.05
                and index <= value + (config.blueRailHold or 0.3)
                and set.model.Parent
                and #set.bands > 0
                and not helper3(set)
            then
                local value4 = {}
                for index2, band in ipairs(set.bands) do
                    index2 = nil
                    for index3, entry in ipairs(value4) do
                        if entry.sx * band.sx + entry.sz * band.sz > 0.9 then
                            index2 = entry
                            break
                        end
                    end
                    if not index2 then
                        index2 = { sx = band.sx, sz = band.sz, cx = band.cx, cz = band.cz, list = {} }
                        value4[#value4 + 1] = index2
                    end
                    index2.list[#index2.list + 1] = band
                end
                for index4, entry2 in ipairs(value4) do
                    table.sort(entry2.list, function(argument2, argument3)
                        return argument2.R < argument3.R
                    end)
                    index4 = set.centreR or 0
                    for index5, entry3 in ipairs(entry2.list) do
                        if entry3.inner - index4 >= (config.blueRailMinGap or 6) then
                            value2[#value2 + 1] = {
                                cx = entry2.cx,
                                cz = entry2.cz,
                                r = (index4 + entry3.inner) * 0.5,
                                sx = entry2.sx,
                                sz = entry2.sz,
                                set = set,
                            }
                        end
                        index4 = max(index4, entry3.R)
                    end
                    if value3 - index4 >= (config.blueRailMinGap or 6) then
                        value2[#value2 + 1] = {
                            cx = entry2.cx,
                            cz = entry2.cz,
                            r = (index4 + value3) * 0.5,
                            sx = entry2.sx,
                            sz = entry2.sz,
                            set = set,
                        }
                    end
                end
            end
        end
        return value2
    end
    local function helper15(argument, argument2, argument3, argument4, argument5)
        local value = { 0, 0.25, 0.5, 0.75, 1 }
        for index, entry in ipairs(value) do
            index = argument3 + entry
            if ringLethalAt(argument, argument2, index, argument5) then
                return false
            elseif
                helper10(
                    argument,
                    argument2,
                    index,
                    argument5 + (config.fieldLineMargin or 3),
                    (config.lineHitFrom or 0.65) - 0.2
                )
            then
                return false
            elseif helper12(argument, argument2, index, argument4, argument5) then
                return false
            elseif helper14(argument, argument2, index, argument5) then
                return false
            end
        end
        return true
    end
    local function helper16(
        argument,
        argument2,
        argument3,
        argument4,
        argument5,
        argument6,
        argument7,
        argument8
    )
        local value, value2 = argument3 - argument, argument4 - argument2
        argument3 = sqrt(value * value + value2 * value2)
        argument4 = max(1, math.ceil(argument3 / 2))
        for index = 1, argument4, 1 do
            local value3 = index / argument4
            local value4, value5, value6 =
                argument + value * value3,
                argument2 + value2 * value3,
                argument5 + argument3 * value3 / argument6
            if
                ringLethalAt(value4, value5, value6, argument7)
                or helper14(value4, value5, value6, 1)
                or (
                    if argument8
                        then not argument8
                        else helper12(value4, value5, value6, argument5, argument7, true)
                )
            then
                return false
            elseif
                helper10(
                    value4,
                    value5,
                    value6,
                    argument7 + (config.fieldLineMargin or 3),
                    (config.lineHitFrom or 0.65) - 0.2
                )
            then
                return false
            end
        end
        return true
    end
    odinMechanics.railHalfW = function()
        return (config.blueRailWidth or 0.4) * 0.5 + (config.blueRailWiden or 1)
    end
    odinMechanics.bluePlan = function(argument, vector)
        local value = odinMechanics.blueArcs(argument)
        if #value == 0 then
            return nil
        end
        local speed, value2, value3, value4, value5, value6, value7 =
            config.burstMax or 28, config.odinCrossM or 2, odinMechanics.railHalfW(), vector.X, vector.Z
        if
            config.odinRailYellow ~= false
            and context.BB
            and context.BB.blueBeams
            and context.BB.onBlueBeam
            and context.rodinOrbs
            and context.rodinOrbs()
        then
            local success, value8 = pcall(context.BB.blueBeams)
            if success then
                if type(value8) == "table" then
                    value6 = if #value8 > 0 then value8 else value6
                end
            end
            value7 = value6
        else
            value7 = value6
        end
        local value9 = config.odinRailYellowPad or 0.5
        local function helper17(argument2, argument3)
            return value7 ~= nil and context.BB.onBlueBeam(argument2, argument3, value9, value7) ~= nil
        end
        local value10, value11 = helper17(value4, value5), {}
        for index, entry in ipairs(value) do
            local off, lim = value4 - entry.cx, value5 - entry.cz
            index = sqrt(off * off + lim * lim)
            local value12, mid =
                index > 0.01 and math.atan2(lim, off) or math.atan2(entry.sz, entry.sx),
                math.atan2(entry.sz, entry.sx)
            off, lim =
                (value12 - mid + 3.141592653589793) % 6.283185307179586 - 3.141592653589793,
                1.5707963267948966 - (config.blueRailHalfIn or 2) / entry.r
            off = math.clamp(off, -lim, lim)
            value12 = abs(index - entry.r) <= value3 and index or entry.r
            local value13, value14 =
                entry.cx + math.cos(mid + off) * value12, entry.cz + math.sin(mid + off) * value12
            local value15, value16 =
                #value11 + 1,
                { a = entry, mid = mid, off = off, lim = lim, rr = value12, x = value13, z = value14 }
            value16.d, value11[value15] = sqrt((value13 - value4) ^ 2 + (value14 - value5) ^ 2), value16
        end
        value = config.odinRanks ~= false and context.odinRankOff ~= nil and (config.odinRankRailWeight or 3)
            or 0
        for index2, entry2 in ipairs(value11) do
            entry2.rank = entry2.d + (value > 0 and context.odinRankOff(entry2.a.r) * value or 0)
        end
        table.sort(value11, function(argument2, argument3)
            return argument2.rank < argument3.rank
        end)
        value = {}
        for index3 = 1, value7 and 2 or 1, 1 do
            local value17 = value7 ~= nil and index3 == 1
            for index4, entry3 in ipairs(value11) do
                local zone, value18, value19, value20 =
                    entry3.a, entry3.d <= (config.odinCrossHold or 1.5), { entry3.rr }, ipairs
                index3 = { zone.r, zone.r - value3, zone.r + value3 }
                for key, entry4 in value20(index3) do
                    key = false
                    for index5, entry5 in ipairs(value19) do
                        if abs(entry5 - entry4) < 0.05 then
                            key = true
                            break
                        end
                    end
                    if not key then
                        value19[#value19 + 1] = entry4
                    end
                end
                local value21, value22 =
                    (config.blueSlideStep or 3) / zone.r, (config.blueSlideFar or 60) / zone.r
                for index6 = 0, math.floor(value22 / value21), 1 do
                    for index7, entry6 in ipairs(index6 == 0 and { 1 } or { 1, -1 }) do
                        index7 = entry3.off + entry6 * index6 * value21
                        if index7 >= -entry3.lim and index7 <= entry3.lim then
                            for index8, entry7 in ipairs(value19) do
                                local value23, value24, value25 =
                                    zone.cx + math.cos(entry3.mid + index7) * entry7,
                                    zone.cz + math.sin(entry3.mid + index7) * entry7,
                                    entry3.d + index6 * value21 * zone.r + abs(entry7 - entry3.rr)
                                if not (value17 and (helper17(value23, value24))) then
                                    value20 = ((index4 * 1000 + index6) * 2 + (entry6 > 0 and 0 or 1)) * 8
                                        + index8
                                    local value26 = value[value20]
                                    if value26 == nil then
                                        value26 = helper15(
                                            value23,
                                            value24,
                                            argument + value25 / speed,
                                            argument,
                                            value2
                                        )
                                        value[value20] = value26
                                    end
                                    if value26 then
                                        if index6 == 0 then
                                            if index8 == 1 then
                                                if value18 then
                                                    odinMechanics.cross =
                                                        { x = value23, z = value24, at = argument }
                                                    return {
                                                        move = false,
                                                        label = value10
                                                                and not value17
                                                                and ("ODIN RINGS: on the blue rail (r%.0f) in a blue orb's yellow - nowhere on the rails off it, holding on the rail"):format(
                                                                    zone.r
                                                                )
                                                            or ("ODIN RINGS: on the blue rail (r%.0f), holding"):format(
                                                                zone.r
                                                            ),
                                                    }
                                                end
                                            end
                                        end
                                        local value27, value28, value29
                                        if value18 then
                                            local value30
                                            if index6 > 0 then
                                                local value31 = entry3.off
                                                    + entry6
                                                        * math.min(
                                                            index6 * value21,
                                                            (config.blueSlideLead or 4) / zone.r
                                                        )
                                                local value32, value33, value34, value35, value36 =
                                                    zone.cx + math.cos(entry3.mid + value31) * entry7,
                                                    zone.cz + math.sin(entry3.mid + value31) * entry7,
                                                    value4,
                                                    value5,
                                                    argument
                                                value30 = true
                                                for index9 = 1, index6, 1 do
                                                    value31 = entry3.off + entry6 * index9 * value21
                                                    local value37, value38, value39 =
                                                        zone.cx + math.cos(entry3.mid + value31) * entry7,
                                                        zone.cz + math.sin(entry3.mid + value31) * entry7,
                                                        argument + index9 * value21 * zone.r / speed
                                                    if
                                                        not (
                                                            helper16(
                                                                value34,
                                                                value35,
                                                                value37,
                                                                value38,
                                                                value36,
                                                                speed,
                                                                value2,
                                                                not value17
                                                            )
                                                        )
                                                    then
                                                        value30 = false
                                                        break
                                                    end
                                                    value34, value35, value36 = value37, value38, value39
                                                end
                                                value27, value28, value29 = value32, value33, value30
                                            else
                                                value30 = helper16(
                                                    value4,
                                                    value5,
                                                    value23,
                                                    value24,
                                                    argument,
                                                    speed,
                                                    value2
                                                )
                                                value27, value28, value29 = value23, value24, value30
                                            end
                                        else
                                            local value40 = helper16(
                                                value4,
                                                value5,
                                                value23,
                                                value24,
                                                argument,
                                                speed,
                                                value2
                                            )
                                            value27, value28, value29 = value23, value24, value40
                                        end
                                        if value29 then
                                            odinMechanics.cross = { x = value23, z = value24, at = argument }
                                            local label = if value10 and value17
                                                then ("ODIN RINGS: off the blue orb's yellow, along the blue rail (r%.0f), %.0f studs"):format(
                                                    zone.r,
                                                    value25
                                                )
                                                else if value18
                                                    then ("ODIN RINGS: sliding along the blue rail (r%.0f) to a clear spot, %.0f studs"):format(
                                                        zone.r,
                                                        index6 * value21 * zone.r
                                                    )
                                                    else ("ODIN RINGS: onto the blue rail (r%.0f), %.0f studs"):format(
                                                        zone.r,
                                                        entry3.d
                                                    )
                                            return {
                                                move = true,
                                                point = Vector3.new(value27, vector.Y, value28),
                                                speed = speed,
                                                label = label,
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
        return nil
    end
    odinMechanics.crossPlan = function(argument, vector, argument2)
        if argument2 then
            if argument2.lines then
                if not (#argument2.lines > 0) then
                    return nil
                end
            else
                return nil
            end
        else
            return nil
        end
        local value = odinMechanics.blueArcs(argument)
        if #value == 0 then
            return nil
        end
        local speed, value2, value3, value4, value5 =
            config.burstMax or 28, config.odinCrossM or 2, config.blueRailHalfIn or 2, infinity
        for index, line in ipairs(argument2.lines) do
            local value6, value7 = argument2.bx + argument2.nx * line, argument2.bz + argument2.nz * line
            for index2, entry in ipairs(value) do
                index2, index = value6 - entry.cx, value7 - entry.cz
                local value8 = index2 * argument2.ax + index * argument2.az
                local value9 = value8 * value8 - (index2 * index2 + index * index - entry.r * entry.r)
                if value9 >= 0 then
                    local value10, iterateArray = sqrt(value9), ipairs
                    index2 = { -value8 - value10, -value8 + value10 }
                    for key, entry2 in iterateArray(index2) do
                        value10, key = value6 + argument2.ax * entry2, value7 + argument2.az * entry2
                        if (value10 - entry.cx) * entry.sx + (key - entry.cz) * entry.sz >= value3 then
                            local value11, value12 = value10 - vector.X, key - vector.Z
                            entry2 = sqrt(value11 * value11 + value12 * value12)
                            local value13 = entry2
                                + (
                                    argument2.pick ~= nil and abs(line - argument2.pick) < 0.01 and 0
                                    or (config.odinCrossOtherLine or 6)
                                )
                            value13 = if config.odinRanks ~= false
                                then if context.odinRankOff
                                    then value13 + context.odinRankOff(entry.r) * (config.odinRankRailWeight or 3)
                                    else value13
                                else value13
                            if value13 < value4 then
                                local value14, value15, value16 =
                                    argument + entry2 / speed, { 0, 0.25, 0.5, 0.75, 1, 1.5 }, true
                                for index3, entry3 in ipairs(value15) do
                                    index3 = value14 + entry3
                                    if
                                        ringLethalAt(value10, key, index3, value2)
                                        or helper10(
                                            value10,
                                            key,
                                            index3,
                                            value2 + (config.fieldLineMargin or 3),
                                            (config.lineHitFrom or 0.65) - 0.2
                                        )
                                        or helper12(value10, key, index3, argument, value2)
                                    then
                                        value16 = false
                                        break
                                    end
                                end
                                if value16 then
                                    value14 = max(1, math.ceil(entry2 / 2))
                                    for index4 = 1, value14, 1 do
                                        value15 = index4 / value14
                                        local value17, value18, value19 =
                                            vector.X + value11 * value15,
                                            vector.Z + value12 * value15,
                                            argument + entry2 * value15 / speed
                                        if
                                            ringLethalAt(value17, value18, value19, value2)
                                            or helper14(value17, value18, value19, 1)
                                            or helper12(value17, value18, value19, argument, value2, true)
                                        then
                                            value16 = false
                                            break
                                        end
                                    end
                                    if value16 then
                                        local value20 =
                                            { x = value10, z = key, d = entry2, r = entry.r, line = line }
                                        value4, value5 = value13, value20
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        if not value5 then
            return nil
        end
        odinMechanics.cross = { x = value5.x, z = value5.z, at = argument }
        if value5.d <= (config.odinCrossHold or 1.5) then
            return {
                move = false,
                label = ("ODIN RINGS + MISSILES: holding where the green rail crosses the blue rail (r%.0f)"):format(
                    value5.r
                ),
            }
        end
        return {
            move = true,
            point = Vector3.new(value5.x, vector.Y, value5.z),
            speed = speed,
            label = ("ODIN RINGS + MISSILES: to where the green rail crosses the blue rail (r%.0f, %.0f studs)"):format(
                value5.r,
                value5.d
            ),
        }
    end
    local function helper18(argument)
        local value = config.ringLive or 1.3
        for index = 1, #odinMechanics.setList, 1 do
            if argument - odinMechanics.setList[index].spawn <= value + 0.2 then
                return true
            end
        end
        for index2, array in ipairs(odinMechanics.arrays) do
            if argument - array.at <= (config.volleyLive or 7) then
                if array.pending > 0 then
                    return true
                elseif argument - array.lastSpawn < (config.arrayGrace or 1.2) then
                    return true
                end
            end
        end
        for index3 = 1, #odinMechanics.lineList, 1 do
            if argument - odinMechanics.lineList[index3].spawn <= (config.fieldLineLive or 1.2) + 0.1 then
                if not odinMechanics.lineList[index3].ignored then
                    return true
                end
            end
        end
        if #odinMechanics.orbList > 0 then
            return true
        end
        return false
    end
    local function helper19(goneAt, vector, argument, argument2)
        local central = odinMechanics.central
        if central and central.model then
            if central.model.Parent then
                if central.part then
                    if not central.part.Parent then
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
        local value, value2 = goneAt - (central.spawn or goneAt), central.model:FindFirstChild("precast")
        local value3 = value2 and (value2:IsA("BasePart"))
        local value4 = if value3 then value2.Transparency >= 0.99 else not value3
        if
            value > (config.fieldLineLive or 1.2) + (config.centralBeamGrace or 0.2)
            or value4 and value >= (config.lineFiredMin or 0.3)
        then
            if not central.goneAt then
                central.goneAt = goneAt
                if config.lineFiredLog ~= false then
                    context.logT(
                        "odin",
                        1,
                        "Odin",
                        ("central beam gone at age %.2f (%s) - task over"):format(
                            value,
                            value4 and "telegraph off screen" or "live time over"
                        )
                    )
                end
            end
            return nil
        end
        local value5 = vector.X
        local value6 = vector.Z
        value, value4 = central.part.CFrame, central.part.Size
        local position = value.Position
        local value7, value8, value9, value10, value11, value12, value13, value14 =
            value.LookVector, value.RightVector, max(value4.Z, value4.X) * 0.5, min(value4.Z, value4.X) * 0.5
        if value4.Z >= value4.X then
            value11 = value7.X
            value12 = value7.Z
            value13 = value8.X
            value14 = value8.Z
        else
            value11 = value8.X
            value12 = value8.Z
            value13 = value7.X
            value14 = value7.Z
        end
        value4, value2 =
            sqrt(value11 * value11 + value12 * value12), sqrt(value13 * value13 + value14 * value14)
        if value4 < 0.01 then
            return nil
        elseif value2 < 0.01 then
            return nil
        end
        local value15 = value11 / value4
        local value16 = value12 / value4
        local value17 = value13 / value2
        local value18 = value14 / value2
        value8, value7 = value5 - position.X, value6 - position.Z
        value3, value2 = value8 * value15 + value7 * value16, value8 * value17 + value7 * value18
        local value19 = max(-value9 + 4, min(value9 - 4, value3))
        local function helper17(argument3)
            return position.X + value15 * value19 + value17 * argument3,
                position.Z + value16 * value19 + value18 * argument3
        end
        local function helper20(argument3, argument4, argument5)
            for index = 1, #odinMechanics.lineList, 1 do
                local value20 = odinMechanics.lineList[index]
                if value20 ~= central then
                    if not value20.ignored then
                        if value20.part then
                            if value20.part.Parent then
                                if argument5 - value20.spawn >= -0.05 then
                                    if argument5 - value20.spawn <= (config.fieldLineLive or 1.2) then
                                        local value21, value22 = value20.part.CFrame, value20.part.Size
                                        local position2, value23, rightVector, value24, value25, value26, value27, value28, value29 =
                                            value21.Position,
                                            value21.LookVector,
                                            value21.RightVector,
                                            max(value22.Z, value22.X) * 0.5,
                                            min(value22.Z, value22.X) * 0.5
                                        if value22.Z >= value22.X then
                                            value26, value27, value28, value29 =
                                                value23.X, value23.Z, rightVector.X, rightVector.Z
                                        else
                                            value26, value27, value28, value29 =
                                                rightVector.X, rightVector.Z, value23.X, value23.Z
                                        end
                                        value22, value23 =
                                            sqrt(value26 * value26 + value27 * value27),
                                            sqrt(value28 * value28 + value29 * value29)
                                        if value22 > 0.01 then
                                            if value23 > 0.01 then
                                                index, value21 =
                                                    argument3 - position2.X, argument4 - position2.Z
                                                if
                                                    abs((index * value26 + value21 * value27) / value22)
                                                    <= value24 + argument
                                                then
                                                    if
                                                        abs((index * value28 + value21 * value29) / value23)
                                                        <= value25
                                                            + argument
                                                            + (config.centralOtherLaneM or 3)
                                                    then
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
            return false
        end
        local function helper21(argument3, argument4)
            local value20 = { 0, 0.3, 0.6 }
            for index, entry in ipairs(value20) do
                index = goneAt + entry
                if odinMechanics.inRingBand(argument3, argument4, index, argument) then
                    return true
                elseif helper12(argument3, argument4, index, goneAt, argument) then
                    return true
                elseif helper9(argument3, argument4, index, argument) then
                    return true
                elseif helper13(argument3, argument4, argument2) then
                    return true
                end
                if config.odinAllLanes ~= false then
                    if helper20(argument3, argument4, index) then
                        return true
                    end
                end
            end
            return false
        end
        if central.firedAt ~= nil then
            value9, value4 = helper17(0)
            if abs(value2) <= (config.centralBeamOn or 2.5) then
                if not (config.odinAllLanes ~= false and helper21(value5, value6)) then
                    odinMechanics.last = { hold = true }
                    return { move = false, label = "CENTRAL BEAM: on the spent footprint, holding" }
                end
            end
            if helper21(value9, value4) then
                return nil
            end
            odinMechanics.last = { x = value9, z = value4, at = goneAt }
            return {
                move = true,
                urgent = true,
                point = Vector3.new(value9, vector.Y, value4),
                speed = config.burstMax or 28,
                label = ("CENTRAL BEAM: back onto the footprint (lat %.1f)"):format(value2),
            }
        end
        value = value10
            + (
                config.centralBeamPark
                or (context.DG and context.DG.reach or 1.8) + (config.centralBeamParkM or 1)
            )
        local function helper22(argument3, argument4)
            if config.centralBeamWay == false then
                return false
            end
            local value20, value21, value22 = config.burstMax or 28, argument3 - value5, argument4 - value6
            argument3 = sqrt(value21 * value21 + value22 * value22)
            argument4 = max(1, math.ceil(argument3 / 2))
            for index = 1, argument4, 1 do
                local value23 = index / argument4
                local value24, value25, value26 =
                    value5 + value21 * value23,
                    value6 + value22 * value23,
                    goneAt + argument3 * value23 / value20
                if ringLethalAt(value24, value25, value26, argument) then
                    return true
                elseif helper14(value24, value25, value26, 1) then
                    return true
                end
            end
            return false
        end
        value9 = value2 >= 0 and 1 or -1
        value3, value8 = helper17(value9 * value)
        if helper21(value3, value8) or helper22(value3, value8) then
            value10, value7 = helper17(-value9 * value)
            if helper21(value10, value7) then
                return nil
            elseif helper22(value10, value7) then
                return nil
            end
            value9, value3, value8 = -value9, value10, value7
        end
        helper17 = config.centralBeamNear == false or abs(value2) <= value + (config.centralBeamParkBand or 2)
        if abs(value2) >= value - (config.centralBeamHoldIn or 0.5) then
            if helper17 then
                if value2 >= 0 == (value9 >= 0) then
                    if not (config.odinAllLanes ~= false and helper21(value5, value6)) then
                        odinMechanics.last = { hold = true }
                        return {
                            move = false,
                            label = ("CENTRAL BEAM: parked beside the beam (lat %.1f), holding"):format(
                                value2
                            ),
                        }
                    end
                end
            end
        end
        odinMechanics.last = { x = value3, z = value8, at = goneAt }
        return {
            move = true,
            urgent = true,
            point = Vector3.new(value3, vector.Y, value8),
            speed = config.burstMax or 28,
            label = ("CENTRAL BEAM: park beside the beam (lat %.1f -> %.0f)"):format(value2, value9 * value),
        }
    end
    odinMechanics.runeR = function()
        if config.odinRuneR then
            return config.odinRuneR
        end
        local arenaCentre = hazardReader.arenaCentre
        if not arenaCentre then
            return nil
        end
        if odinMechanics.runeAt then
            if os.clock() - odinMechanics.runeAt < 30 then
                if odinMechanics.runeV then
                    return odinMechanics.runeV
                end
            end
        end
        odinMechanics.runeAt = os.clock()
        local value, value2 = 0, 0
        pcall(function()
            local value3 = workspace:FindFirstChild("bossRoomRunes")
            if not value3 then
                return
            end
            local iterateArray, value4 = ipairs, argumentHelpers[108](value3:GetDescendants())
            for key, entry in iterateArray(argumentHelpers:unpackValues(value4)) do
                value3 = entry:IsA("BasePart")
                        and sqrt(
                            (entry.Position.X - arenaCentre.X) ^ 2 + (entry.Position.Z - arenaCentre.Z) ^ 2
                        )
                    or 0
                if entry:IsA("BasePart") and value3 > 20 then
                    key = nil
                    if config.odinRuneAt == "outer" then
                        local value5 = { -1, 1 }
                        key = 0
                        for index, entry2 in ipairs(value5) do
                            index = { -1, 1 }
                            for index2, entry3 in ipairs(index) do
                                index2 = { -1, 1 }
                                for index3, entry4 in ipairs(index2) do
                                    index3 = entry.CFrame:PointToWorldSpace(
                                        Vector3.new(
                                            entry2 * entry.Size.X * 0.5,
                                            entry3 * entry.Size.Y * 0.5,
                                            entry4 * entry.Size.Z * 0.5
                                        )
                                    )
                                    entry4 =
                                        sqrt((index3.X - arenaCentre.X) ^ 2 + (index3.Z - arenaCentre.Z) ^ 2)
                                    key = if entry4 > key then entry4 else key
                                end
                            end
                        end
                    else
                        key = value3
                    end
                    local value6, value7 = value + key, value2 + 1
                    value, value2 = value6, value7
                end
            end
        end)
        local runeV = value2 > 0 and value / value2
            or (config.odinRuneFallback or (config.odinRuneAt == "outer" and 62 or 56))
        odinMechanics.runeV = runeV
        return odinMechanics.runeV
    end
    local function lineGeom(argument)
        if argument then
            if not argument.Parent then
                return nil
            end
        else
            return nil
        end
        local transform, size = argument.CFrame, argument.Size
        local value, value2, value3, value4, value5, value6 = transform.LookVector, transform.RightVector
        if size.Z >= size.X then
            value3, value4, value5, value6 = value.X, value.Z, value2.X, value2.Z
        else
            value3, value4, value5, value6 = value2.X, value2.Z, value.X, value.Z
        end
        argument, value = sqrt(value3 * value3 + value4 * value4), sqrt(value5 * value5 + value6 * value6)
        if argument < 0.01 then
            return nil
        elseif value < 0.01 then
            return nil
        end
        value2 = transform.Position
        return {
            x = value2.X,
            y = value2.Y,
            z = value2.Z,
            ax = value3 / argument,
            az = value4 / argument,
            sx = value5 / value,
            sz = value6 / value,
            halfL = max(size.Z, size.X) * 0.5,
            halfW = min(size.Z, size.X) * 0.5,
        }
    end
    odinMechanics.lineGeom = lineGeom
    odinMechanics.noteGreen = function(argument, firedAt)
        local fanGreen = lineGeom(argument.part)
        if not fanGreen then
            return
        end
        fanGreen.model, fanGreen.spawn = argument.model, argument.spawn
        fanGreen.firedAt = firedAt
        odinMechanics.fanGreen = fanGreen
        fanGreen = hazardReader.models and hazardReader.models[argument.model]
        if fanGreen then
            fanGreen.long, fanGreen.detonatedAt = false, fanGreen.detonatedAt or firedAt
            fanGreen.untilAt = math.min(fanGreen.untilAt or firedAt, firedAt)
            for index, entry in ipairs(hazardReader.zones or {}) do
                if entry.model == argument.model then
                    entry.untilAt = math.min(entry.untilAt, firedAt)
                end
            end
            hazardReader.boxGen = (hazardReader.boxGen or 0) + 1
        end
        context.logT("odin", 1, "Odin", "fan: first beam detonated - green")
    end
    context.odinIgnoreLine = function(argument)
        if config.odinFirstBeamOnly == false then
            return false
        elseif argument then
        else
            return false
        end
        if odinMechanics.ignoredModels then
            if odinMechanics.ignoredModels[argument] then
                return true
            end
        end
        local value = odinMechanics.lines[argument]
        if value then
            return value.ignored == true
        end
        return odinMechanics.lastLineAt ~= nil
            and os.clock() - odinMechanics.lastLineAt <= (config.odinFanQuiet or 2)
    end
    local function fanDissolve(argument, argument2)
        argument.done, argument.doneAt = true, os.clock()
        if argument.first then
            argument.first.ignored = true
        end
        odinMechanics.fanGreen = nil
        odinMechanics.central = nil
        odinMechanics.fanActiveAt = nil
        context.logT("odin", 1, "Odin", "fan: " .. argument2 .. " - back to normal")
    end
    odinMechanics.fanDissolve = fanDissolve
    local function helper23(argument, argument2)
        local value = config.fieldLineLive or 1.2
        for index = 1, #odinMechanics.lineList, 1 do
            local value2 = odinMechanics.lineList[index]
            if value2.model ~= argument.model then
                if value2.spawn >= argument.spawn - 0.05 then
                    if argument2 - value2.spawn <= value + (config.odinFanTail or 0.3) then
                        return true
                    end
                end
            end
        end
        return false
    end
    odinMechanics.fanGreenNow = function(argument)
        local fanGreen = odinMechanics.fanGreen
        if not fanGreen then
            return nil
        end
        if config.odinFirstBeamOnly ~= false then
            local fan = odinMechanics.fan
            if fan then
                if fan.done then
                    odinMechanics.fanGreen = nil
                    return nil
                elseif fan.first then
                    if fan.first.model ~= fanGreen.model then
                        odinMechanics.fanGreen = nil
                        return nil
                    end
                else
                    odinMechanics.fanGreen = nil
                    return nil
                end
            else
                odinMechanics.fanGreen = nil
                return nil
            end
            return fanGreen
        end
        if argument - fanGreen.firedAt > (config.odinFanGreenMax or 6) then
            odinMechanics.fanGreen = nil
            return nil
        end
        if argument - fanGreen.firedAt > (config.odinFanGreenMin or 0.8) then
            if not (helper23(fanGreen, argument)) then
                odinMechanics.fanGreen = nil
                return nil
            end
        end
        return fanGreen
    end
    odinMechanics.fanRedNow = function(argument)
        local central = odinMechanics.central
        if central then
            if central.part then
                if central.model then
                    if central.model.Parent then
                        if central.firedAt then
                            return nil
                        elseif central.goneAt then
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
        if config.odinFirstBeamOnly ~= false then
            if odinMechanics.fan then
                if odinMechanics.fan.done then
                    return nil
                elseif odinMechanics.fan.first ~= central then
                    return nil
                end
            else
                return nil
            end
        end
        if
            argument - (central.spawn or argument)
            > (config.fieldLineLive or 1.2) + (config.centralBeamGrace or 0.2)
        then
            return nil
        end
        return lineGeom(central.part)
    end
    local function helper24(argument, argument2, argument3, argument4, argument5, argument6)
        local value, value2 = config.fieldLineLive or 1.2, { 0, 0.3, 0.6 }
        for index, entry in ipairs(value2) do
            index = argument3 + entry
            if odinMechanics.inRingBand(argument, argument2, index, argument4) then
                return true
            elseif helper12(argument, argument2, index, argument3, argument4) then
                return true
            elseif helper9(argument, argument2, index, argument4) then
                return true
            elseif helper13(argument, argument2, argument5) then
                return true
            end
            for index2 = 1, #odinMechanics.lineList, 1 do
                entry = odinMechanics.lineList[index2]
                if entry.model ~= argument6 then
                    if not entry.ignored then
                        if index - entry.spawn >= -0.05 then
                            if index - entry.spawn <= value then
                                index2 = lineGeom(entry.part)
                                if index2 then
                                    local value3, value4 = argument - index2.x, argument2 - index2.z
                                    if
                                        abs(value3 * index2.ax + value4 * index2.az)
                                        <= index2.halfL + argument4
                                    then
                                        if
                                            abs(value3 * index2.sx + value4 * index2.sz)
                                            <= index2.halfW + argument4 + (config.centralOtherLaneM or 3)
                                        then
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
    local function helper25(argument, vector, argument2, argument3)
        local value = odinMechanics.fanGreenNow(argument)
        if not value then
            return nil
        end
        local value2, value3 = vector.X, vector.Z
        local value4, value5 = value2 - value.x, value3 - value.z
        local value6, value7 = value4 * value.ax + value5 * value.az, value4 * value.sx + value5 * value.sz
        value4 = max(-value.halfL + 4, min(value.halfL - 4, value6))
        local value8, value9 = value.x + value.ax * value4, value.z + value.az * value4
        if helper24(value8, value9, argument, argument2, argument3, value.model) then
            return nil
        end
        if abs(value7) <= (config.centralBeamOn or 2.5) then
            if abs(value6 - value4) <= 2 then
                odinMechanics.last = { hold = true }
                return {
                    move = false,
                    label = ("ODIN FAN: in the green (the spent first beam), holding until the fan is over (%.1fs)"):format(
                        argument - value.firedAt
                    ),
                }
            end
        end
        odinMechanics.last = { x = value8, z = value9, at = argument }
        return {
            move = true,
            urgent = true,
            point = Vector3.new(value8, vector.Y, value9),
            speed = config.burstMax or 28,
            label = ("ODIN FAN: into the green (the spent first beam), %.0f studs"):format(
                sqrt((value8 - value2) ^ 2 + (value9 - value3) ^ 2)
            ),
        }
    end
    odinMechanics.fanPlan = function(fanActiveAt, vector)
        if fanActiveAt - odinMechanics.lastTick > 1 then
            return nil
        elseif config.odinCentralBeam == false then
            return nil
        end
        local value, fan = config.odinFirstBeamOnly ~= false, odinMechanics.fan
        if value then
            if fan then
                if fan.done then
                    return nil
                elseif not fan.first then
                    return nil
                end
            else
                return nil
            end
            if fan.first.firedAt then
                if fanActiveAt - fan.first.firedAt > (config.odinFanMax or 4) then
                    fanDissolve(fan, "the green not reached in time")
                    return nil
                end
            end
            if not fan.first.firedAt then
                if fan.first.goneAt then
                    fanDissolve(fan, "the first beam went without detonating")
                    return nil
                elseif fanActiveAt - fan.first.spawn > (config.fieldLineLive or 1.2) + 1 then
                    fanDissolve(fan, "the first beam went without detonating")
                    return nil
                end
            end
        end
        local value2, value3 = config.fieldLaneMargin or 1, hazardReader.arenaCentre
        local value4 = value3 and sqrt((vector.X - value3.X) ^ 2 + (vector.Z - value3.Z) ^ 2) or nil
        value3 = helper19(fanActiveAt, vector, value2, value4)
        if value3 then
            local central = odinMechanics.central
            value3.label = value3.label:gsub(
                "^CENTRAL BEAM",
                central and central.firedAt and "ODIN FAN [GREEN]" or "ODIN FAN [RED]"
            )
        else
            value3 = (helper25(fanActiveAt, vector, value2, value4))
        end
        value4 = odinMechanics.fanGreen
        if value then
            if value3 then
                if value4 then
                    if
                        abs((vector.X - value4.x) * value4.sx + (vector.Z - value4.z) * value4.sz)
                        <= (config.centralBeamOn or 2.5) + 0.5
                    then
                        fan.inGreenAt = fan.inGreenAt or fanActiveAt
                    end
                    if fan.inGreenAt then
                        value2 = (config.odinGreenHold or 1) - (fanActiveAt - fan.inGreenAt)
                        if value2 <= 0 then
                            fanDissolve(fan, ("%.1fs in the green"):format(config.odinGreenHold or 1))
                            return nil
                        end
                        value3.label = value3.label .. (" - back to normal in %.1fs"):format(value2)
                    end
                end
            end
        end
        if value3 then
            odinMechanics.fanActiveAt = fanActiveAt
        end
        return value3
    end
    context.odinFanPinned = function(argument)
        return odinMechanics.fanActiveAt ~= nil and argument - odinMechanics.fanActiveAt < 0.3
    end
    odinMechanics.plan = function(firedAt, vector)
        if firedAt - odinMechanics.lastTick > 1 then
            return nil
        end
        local value = vector.X
        local value2 = vector.Z
        if not (helper18(firedAt)) then
            local arenaCentre, value3, value4 =
                hazardReader.arenaCentre, context.readyDamageCasts and context.readyDamageCasts() or 0, 0
            if context.attackReady then
                local value5, value6 = context.attackReady()
                value4 = if value5 then value4 else value6 or 0
            end
            local value7, value8, value9 =
                value3 >= 1 or value4 <= (config.closeLead or 1.2),
                arenaCentre and sqrt((value - arenaCentre.X) ^ 2 + (value2 - arenaCentre.Z) ^ 2) or nil,
                config.odinRuneStand ~= false and arenaCentre ~= nil and odinMechanics.runeR() or nil
            local value10, value11 =
                value9 ~= nil and value8 ~= nil and abs(value8 - value9) > (config.odinRuneBand or 4) + 2,
                config.odinRanks ~= false and context.odinRankOff ~= nil and arenaCentre ~= nil
            if value11 then
                value10 = value8 ~= nil and context.odinRankOff(value8) > (config.odinRankSlack or 1)
                value9 = nil
            end
            if arenaCentre and value8 then
                if
                    (if value7 then not value7 else value8 < (config.odinIdleR or 88) - 6)
                    and value9 == nil
                    and not value11
                then
                elseif value10 then
                else
                    odinMechanics.last = nil
                    return nil
                end
            else
                odinMechanics.last = nil
                return nil
            end
        end
        local speed = config.fieldSpeed or 24
        local value12 = config.fieldHold or 0.8
        local value13 = config.fieldLaneMargin or 1
        local arenaCentre2 = hazardReader.arenaCentre
        local value14 = arenaCentre2 and sqrt((value - arenaCentre2.X) ^ 2 + (value2 - arenaCentre2.Z) ^ 2)
            or nil
        local value15, ignoreLines, value16, value17, value18, value19, value20 =
            (config.missileLaneWidth or 10) * 0.5, config.missilePassT or 0.9, config.missilePassClear or 1.5
        for index = 1, #odinMechanics.missileList, 1 do
            local value21 = odinMechanics.missileList[index]
            index = sqrt(value21.vx * value21.vx + value21.vz * value21.vz)
            if index > 20 then
                local value22, value23, value24, value25 =
                    value21.vx / index, value21.vz / index, value - value21.x, value2 - value21.z
                local value26 = value24 * value22 + value25 * value23
                local value27 = value26 / index - max(firedAt - value21.t, 0)
                if value26 > -15 then
                    if value27 <= ignoreLines then
                        local value28 = -value23 * value24 + value22 * value25
                        if abs(value28) < value15 + value16 then
                            if value17 then
                                if abs(value28) < abs(value18) then
                                    local value29 = { value22, value23 }
                                    value17, value18, value19 = value21, value28, value29
                                end
                            else
                                local value30 = { value22, value23 }
                                value17, value18, value19 = value21, value28, value30
                            end
                        else
                            value20 = value21
                        end
                    end
                end
            end
        end
        ignoreLines = false
        if value17 or value20 then
            local value31 = { 0, 0.3, 0.6, 0.9 }
            for index2, entry in ipairs(value31) do
                index2 = firedAt + entry
                if
                    odinMechanics.inRingBand(value, value2, index2, value13)
                    or helper10(value, value2, index2, value13 + (config.fieldLineMargin or 3.5))
                    or helper12(value, value2, index2, firedAt, value13)
                then
                    ignoreLines = true
                    break
                end
            end
            if ignoreLines then
                local value32, value33
                value20, value17 = value33, value32
            end
        end
        if value17 then
            local value34, value35 = value18 >= 0 and 1 or -1, value15 + value16 + 1 - abs(value18)
            local value36, value37 =
                value + -value19[2] * value34 * value35, value2 + value19[1] * value34 * value35
            if
                odinMechanics.inRingBand(value36, value37, firedAt, value13)
                or odinMechanics.inRingBand(value36, value37, firedAt + 0.6, value13)
            then
                ignoreLines = value15 + value16 + 1 + abs(value18)
                local value38, value39 =
                    value + -value19[2] * -value34 * ignoreLines, value2 + value19[1] * -value34 * ignoreLines
                if not (odinMechanics.inRingBand(value38, value39, firedAt, value13)) then
                    if not (odinMechanics.inRingBand(value38, value39, firedAt + 0.6, value13)) then
                        local value40 = -value34
                        value34, value35 = value40, ignoreLines
                    end
                end
            end
            value37, value36 = -value19[2] * value34, value19[1] * value34
            odinMechanics.last =
                { x = value + value37 * value35, z = value2 + value36 * value35, at = firedAt }
            return {
                move = true,
                point = Vector3.new(value + value37 * value35, vector.Y, value2 + value36 * value35),
                speed = speed,
                label = ("MISSILE PATH: %.1f off its line, stepping %.0f out"):format(value18, value35),
            }
        elseif value20 then
            odinMechanics.last = { hold = true }
            return { move = false, label = "MISSILE PASSING: beside its line, feet locked" }
        end
        odinMechanics.ignoreSets = {}
        odinMechanics.ignoreLines = {}
        for index3 = 1, #odinMechanics.setList, 1 do
            value16 = odinMechanics.setList[index3]
            if value16.model.Parent then
                if helper4(value16, value, value2, value13) then
                    odinMechanics.ignoreSets[value16] = true
                end
            end
        end
        value15, ignoreLines = value13 + (config.fieldLineMargin or 3.5), {}
        for index4 = 1, #odinMechanics.lineList, 1 do
            value16 = odinMechanics.lineList[index4]
            local transform, size = value16.part.CFrame, value16.part.Size
            if value16.part.Parent then
                local position, value41, value42 =
                    transform.Position, transform.LookVector, transform.RightVector
                local value43, value44, value45, value46, value47, value48, value49, value50 =
                    value - position.X,
                    value2 - position.Z,
                    max(size.Z, size.X) * 0.5,
                    min(size.Z, size.X) * 0.5
                if size.Z >= size.X then
                    value47, value48, value49, value50 = value41.X, value41.Z, value42.X, value42.Z
                else
                    value47, value48, value49, value50 = value42.X, value42.Z, value41.X, value41.Z
                end
                value42, value41 =
                    sqrt(value47 * value47 + value48 * value48), sqrt(value49 * value49 + value50 * value50)
                if value42 > 0.01 then
                    if value41 > 0.01 then
                        if abs((value43 * value47 + value44 * value48) / value42) <= value45 + value15 then
                            if
                                abs((value43 * value49 + value44 * value50) / value41)
                                <= value46 + value15
                            then
                                ignoreLines[value16] = true
                            end
                        end
                    end
                end
            end
        end
        odinMechanics.ignoreLines = ignoreLines
        odinMechanics.danceIgnore = nil
        if config.odinCentralBeam ~= false then
            ignoreLines = helper19(firedAt, vector, value13, value14)
            if ignoreLines then
                return ignoreLines
            end
        end
        if config.beamDance ~= false and config.odinCentralBeam == false and #odinMechanics.lineList > 0 then
            local danceIgnore, value51 =
                config.beamDanceRange or 30, config.beamDanceLm or config.fieldLineMargin or 3.5
            value15 = config.lineFiredAt or 0.65
            local function laneMem(argument)
                if not argument.part.Parent then
                    return nil
                end
                local value52, size2 = argument.part.CFrame, argument.part.Size
                local position2, value53, rightVector, halfL, halfW, value54, value55, value56, value57 =
                    value52.Position,
                    value52.LookVector,
                    value52.RightVector,
                    max(size2.Z, size2.X) * 0.5,
                    min(size2.Z, size2.X) * 0.5
                if size2.Z >= size2.X then
                    value54, value55, value56, value57 = value53.X, value53.Z, rightVector.X, rightVector.Z
                else
                    value54, value55, value56, value57 = rightVector.X, rightVector.Z, value53.X, value53.Z
                end
                value52, value53 =
                    sqrt(value54 * value54 + value55 * value55), sqrt(value56 * value56 + value57 * value57)
                if value52 <= 0.01 then
                    return nil
                elseif value53 <= 0.01 then
                    return nil
                end
                value54 /= value52
                value55 /= value52
                value56 /= value53
                value57 /= value53
                value53, argument = value - position2.X, value2 - position2.Z
                return {
                    p = position2,
                    ax = value54,
                    az = value55,
                    sx = value56,
                    sz = value57,
                    halfL = halfL,
                    halfW = halfW,
                    along = value53 * value54 + argument * value55,
                    lat = value53 * value56 + argument * value57,
                }
            end
            local value58, value59
            value16 = odinMechanics.dance
                and odinMechanics.dance.model
                and odinMechanics.lines[odinMechanics.dance.model]
            if value16 and firedAt - value16.spawn <= (config.beamDanceFor or 3.2) then
                ignoreLines = laneMem(value16)
                if
                    ignoreLines
                    and abs(ignoreLines.along) <= ignoreLines.halfL - 4
                    and abs(ignoreLines.lat) <= danceIgnore + 8
                then
                    value58, value59 = value16, ignoreLines
                end
            end
            if not value58 then
                local value60 = #odinMechanics.lineList
                for index5 = 1, value60, 1 do
                    local value61 = odinMechanics.lineList[index5]
                    index5 = firedAt - value61.spawn
                    if index5 <= (config.beamDanceFor or 3.2) and index5 < value15 + 0.3 then
                        local value62 = laneMem(value61)
                        if
                            value62
                            and abs(value62.along) <= value62.halfL - 4
                            and abs(value62.lat) <= danceIgnore
                            and (not value58 or value61.spawn < value58.spawn)
                        then
                            value58, value59 = value61, value62
                        end
                    end
                end
            end
            if value58 then
                odinMechanics.laneMem = odinMechanics.laneMem or {}
                laneMem = odinMechanics.laneMem
                if laneMem.model ~= value58.model then
                    laneMem.firedAt = nil
                end
                laneMem.model = value58.model
                laneMem.at = firedAt
                laneMem.ox, laneMem.oz = value59.p.X, value59.p.Z
                laneMem.ax, laneMem.az, laneMem.sx, laneMem.sz =
                    value59.ax, value59.az, value59.sx, value59.sz
                laneMem.halfL, laneMem.halfW = value59.halfL, value59.halfW
                danceIgnore = {}
                for index6 = 1, #odinMechanics.lineList, 1 do
                    local value63 = odinMechanics.lineList[index6]
                    if value63 ~= value58 then
                        if value63.spawn >= value58.spawn - 0.05 then
                            if value63.model then
                                danceIgnore[value63.model] = true
                            end
                        end
                    end
                end
                odinMechanics.danceIgnore = danceIgnore
                local value64, value65 =
                    firedAt - value58.spawn, value59.halfW + value51 + (config.beamDancePark or 1.5)
                local function helper17(argument)
                    return value59.p.X + value59.ax * value59.along + value59.sx * argument,
                        value59.p.Z + value59.az * value59.along + value59.sz * argument
                end
                local value66 = abs(value59.lat) < value59.halfW + 1
                local function helper20(argument, argument2, argument3, argument4)
                    if odinMechanics.inRingBand(argument, argument2, argument3, value13) then
                        return "ring"
                    end
                    if value66 then
                        if not argument4 then
                            return nil
                        end
                    end
                    if helper9(argument, argument2, argument3, value13) then
                        return "missile"
                    end
                    if helper12(argument, argument2, argument3, firedAt, value13) then
                        return "orb"
                    end
                    local ignoreLines2, ignoreLines3 = odinMechanics.ignoreLines, {}
                    for index7 = 1, #odinMechanics.lineList, 1 do
                        local value52 = odinMechanics.lineList[index7]
                        if value52 == value58 then
                            if argument4 then
                                ignoreLines3[value52] = true
                            end
                        elseif value52.spawn >= value58.spawn - 0.05 then
                            ignoreLines3[value52] = true
                        end
                    end
                    odinMechanics.ignoreLines = ignoreLines3
                    ignoreLines3 = helper10(
                        argument,
                        argument2,
                        argument3,
                        value13 + value51,
                        (config.lineHitFrom or 0.65) - 0.2,
                        true
                    )
                    odinMechanics.ignoreLines = ignoreLines2
                    if ignoreLines3 then
                        return "line"
                    end
                    return nil
                end
                local value67 = hazardReader.models[value58.model]
                local value68 = value58.firedAt ~= nil
                    or value67 ~= nil and (value67.detonatedAt ~= nil or value67.fired == true)
                if value68 then
                    if odinMechanics.laneMem then
                        if odinMechanics.laneMem.model == value58.model then
                            if not odinMechanics.laneMem.firedAt then
                                odinMechanics.laneMem.firedAt = firedAt
                            end
                        end
                    end
                end
                local value69, phase, value70
                if value64 < value15 and not value68 then
                    odinMechanics.danceSide = odinMechanics.danceSide or {}
                    value67 = odinMechanics.danceSide[value58.model]
                    if not value67 then
                        local side = value59.lat >= 0 and 1 or -1
                        side = if odinMechanics.dance and odinMechanics.dance.model == value58.model
                            then if odinMechanics.dance.side then odinMechanics.dance.side else side
                            else side
                        local value71, value72 = helper17(side * value65)
                        if
                            helper20(value71, value72, firedAt + 0.3, false)
                            or helper13(value71, value72, value14)
                        then
                            local value73, value74 = helper17(-side * value65)
                            side = if helper20(value73, value74, firedAt + 0.3, false)
                                then side
                                else if helper13(value73, value74, value14) then side else -side
                        end
                        value67 = { side = side }
                        odinMechanics.danceSide[value58.model] = value67
                    end
                    value69, phase, value70 = value67.side * value65, "beside", false
                else
                    value69, phase, value70 = 0, "in the lane of", true
                end
                value68, value67 = helper17(value69)
                value65 = sqrt((value68 - value) ^ 2 + (value67 - value2) ^ 2)
                local urgent, value75 = firedAt + value65 / speed, true
                if value65 > 2 then
                    value75 = if odinMechanics.pathCrossesRing
                        then if odinMechanics.pathCrossesRing(
                                value,
                                value2,
                                value68,
                                value67,
                                firedAt,
                                urgent
                            )
                            then false
                            else value75
                        else value75
                    if value75 then
                        local value76 = max(2, math.ceil(value65 / 4))
                        for index8 = 1, value76, 1 do
                            local value77 = index8 / value76
                            if
                                helper20(
                                    value + (value68 - value) * value77,
                                    value2 + (value67 - value2) * value77,
                                    firedAt + (urgent - firedAt) * value77,
                                    value70
                                )
                            then
                                value75 = false
                                break
                            end
                        end
                    end
                end
                local value78 = value75
                    and not helper20(value68, value67, urgent, value70)
                    and not helper20(value68, value67, urgent + 0.5, value70)
                    and not helper13(value68, value67, value14)
                if if value78 then not value78 else config.beamGapWalk ~= false then
                    local value79, value80, value81, value82 =
                        config.beamGapStep or 6, config.beamGapMax or 90
                    for index9 = 1, math.ceil(value80 / value79), 1 do
                        urgent = { 1, -1 }
                        for index10, entry2 in ipairs(urgent) do
                            index10 = value59.lat + entry2 * index9 * value79
                            local value83, value84 = helper17(index10)
                            if
                                config.beamGapMustClear == false
                                or abs(index10) >= value59.halfW + value51
                            then
                                if not (helper13(value83, value84, value14)) then
                                    entry2 = sqrt((value83 - value) ^ 2 + (value84 - value2) ^ 2)
                                    local value85 = firedAt + entry2 / speed
                                    if not (helper20(value83, value84, value85, value70)) then
                                        if not (helper20(value83, value84, value85 + 0.5, value70)) then
                                            local value86 = true
                                            if
                                                odinMechanics.pathCrossesRing
                                                and odinMechanics.pathCrossesRing(
                                                    value,
                                                    value2,
                                                    value83,
                                                    value84,
                                                    firedAt,
                                                    value85
                                                )
                                            then
                                                value86 = false
                                            else
                                                local value87 = max(2, math.ceil(entry2 / 4))
                                                for index11 = 1, value87, 1 do
                                                    local value88 = index11 / value87
                                                    if
                                                        helper20(
                                                            value + (value83 - value) * value88,
                                                            value2 + (value84 - value2) * value88,
                                                            firedAt + (value85 - firedAt) * value88,
                                                            value70
                                                        )
                                                    then
                                                        value86 = false
                                                        break
                                                    end
                                                end
                                            end
                                            local value89 = if config.beamGapNoCross ~= false
                                                then if index10
                                                        < 0
                                                        ~= (value59.lat < 0)
                                                    then entry2 + (config.beamGapCrossCost or 24)
                                                    else entry2
                                                else entry2
                                            if
                                                value86
                                                and (if value81 then value89 < value82 else not value81)
                                            then
                                                local value90 = { x = value83, z = value84, lat = index10 }
                                                value81, value82 = value90, value89
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        if value81 then
                            break
                        end
                    end
                    if value81 then
                        odinMechanics.dance = {
                            model = value58.model,
                            spawn = value58.spawn,
                            at = firedAt,
                            phase = "across",
                            lat = value59.lat,
                            side = odinMechanics.dance and odinMechanics.dance.side,
                        }
                        odinMechanics.last = { x = value81.x, z = value81.z, at = firedAt }
                        return {
                            move = true,
                            urgent = true,
                            point = Vector3.new(value81.x, vector.Y, value81.z),
                            speed = config.burstMax or 28,
                            label = ("BEAM DANCE: no park - across to a gap %.0f studs (lat %.1f -> %.1f)"):format(
                                value82,
                                value59.lat,
                                value81.lat
                            ),
                        }
                    end
                end
                if value78 then
                    odinMechanics.dance = {
                        model = value58.model,
                        spawn = value58.spawn,
                        at = firedAt,
                        phase = phase,
                        lat = value59.lat,
                        side = (if value70 then not value70 else value69 >= 0 and 1 or -1)
                            or odinMechanics.dance and odinMechanics.dance.side,
                    }
                    if value65 <= 1.5 then
                        odinMechanics.last = { hold = true }
                        return {
                            move = false,
                            label = ("BEAM DANCE: %s the beam (lat %.1f, age %.1f), holding"):format(
                                phase,
                                value59.lat,
                                value64
                            ),
                        }
                    end
                    odinMechanics.last = { x = value68, z = value67, at = firedAt }
                    urgent = value66 or value70 or value64 < (config.beamUrgentFor or 0.6)
                    return {
                        move = true,
                        urgent = urgent,
                        point = Vector3.new(value68, vector.Y, value67),
                        speed = urgent and (config.burstMax or 28) or speed,
                        label = ("BEAM DANCE: %s the beam, %.0f to go (lat %.1f, age %.1f)"):format(
                            phase,
                            value65,
                            value59.lat,
                            value64
                        ),
                    }
                end
            elseif
                odinMechanics.laneMem
                and odinMechanics.laneMem.firedAt
                and firedAt - odinMechanics.laneMem.firedAt < (config.beamLaneHold or 1.6)
                and firedAt - (odinMechanics.laneMem.at or 0) < (config.beamLaneHold or 1.6) + 0.5
            then
                local laneMem2 = odinMechanics.laneMem
                local value91, value92 = value - laneMem2.ox, value2 - laneMem2.oz
                local value93, value94 =
                    value91 * laneMem2.ax + value92 * laneMem2.az,
                    value91 * laneMem2.sx + value92 * laneMem2.sz
                if abs(value93) <= laneMem2.halfL - 4 then
                    local value95, value96, value97 =
                        laneMem2.ox + laneMem2.ax * value93, laneMem2.oz + laneMem2.az * value93, abs(value94)
                    if not (odinMechanics.inRingBand(value95, value96, firedAt + 0.2, value13)) then
                        if not (helper9(value95, value96, firedAt + 0.2, value13)) then
                            if not (helper12(value95, value96, firedAt + 0.2, firedAt, value13)) then
                                if not (helper13(value95, value96, value14)) then
                                    if value97 <= 2 then
                                        odinMechanics.last = { hold = true }
                                        return {
                                            move = false,
                                            label = ("BEAM LANE: standing in the spent beam (%.1fs left)"):format(
                                                (config.beamLaneHold or 1.6) - (firedAt - laneMem2.firedAt)
                                            ),
                                        }
                                    end
                                    odinMechanics.last = { x = value95, z = value96, at = firedAt }
                                    return {
                                        move = true,
                                        urgent = true,
                                        point = Vector3.new(value95, vector.Y, value96),
                                        speed = config.burstMax or 28,
                                        label = ("BEAM LANE: back into the spent beam, %.0f to go"):format(
                                            value97
                                        ),
                                    }
                                end
                            end
                        end
                    end
                end
            elseif odinMechanics.dance then
                if firedAt - (odinMechanics.dance.at or 0) > (config.beamDanceAfter or 1.6) then
                    odinMechanics.dance = nil
                end
            end
        end
        local value98
        value15, ignoreLines, value16 = ipairs, { 0, 0.25, 0.5, value12, value12 + 0.4 }
        for key, ignoreLine in value15(ignoreLines) do
            key = hazardAt(value, value2, firedAt + ignoreLine, firedAt, value13)
            if key then
                value98 = ignoreLine
                value16 = key
                break
            end
        end
        local value99, value100, value101 =
            hazardReader.odinEntry,
            context.BR
                    and context.BR.target
                    and context.BR.target.isBoss
                    and context.BR.target.root
                    and context.BR.target.root.Parent
                    and context.BR.target.root.Position
                or nil,
            (context.abilityReach and context.abilityReach() or 77) - 6
        local label, value102, value103 =
            value100 and sqrt((value - value100.X) ^ 2 + (value2 - value100.Z) ^ 2) or nil,
            false,
            context.PB and context.PB.phase == "lines"
                or #odinMechanics.lineList > 0
                    and firedAt - odinMechanics.lineList[#odinMechanics.lineList].spawn < (config.linesPhaseFor or 2)
        value103 = if config.odinFirstBeamOnly ~= false
            then odinMechanics.central ~= nil
                and not odinMechanics.central.firedAt
                and not odinMechanics.central.ignored
            else value103
        local value104, value105, value106, value107 =
            config.odinLineHold or 85, false, context.readyDamageCasts and context.readyDamageCasts()
        if value106 then
            value107 = value106
        else
            value15 = context.attackReady
            value107 = (if value15 then context.attackReady() else not value15) and 1 or 0
        end
        ignoreLines = 0
        if context.attackReady then
            value15, value106 = context.attackReady()
            ignoreLines = if value15 then ignoreLines else value106 or 0
        end
        value106 = context.attackAllowedBySkill
        local value108, value109, value110, value111, value112 =
            (if value106 then context.attackAllowedBySkill(firedAt) else not value106) and value107 >= 1,
            value107 >= 1 or ignoreLines <= (config.closeLead or 1.2),
            config.odinIdleR or 88,
            config.odinRuneStand ~= false and arenaCentre2 ~= nil and odinMechanics.runeR() or nil,
            config.odinRuneBand or 4
        value111 = if value111 and value100
            then if abs(
                    sqrt((value100.X - arenaCentre2.X) ^ 2 + (value100.Z - arenaCentre2.Z) ^ 2) - value111
                ) > value101 - 4
                then nil
                else value111
            else value111
        value107 = config.odinRanks ~= false and arenaCentre2 ~= nil and context.odinRankOff ~= nil
        value111 = if value107 then nil else value111
        value15 = false
        if not value16 then
            if value111 and value14 and abs(value14 - value111) > value112 then
                value15 = true
            else
                if value107 and value14 and context.odinRankOff(value14) > (config.odinRankSlack or 1) then
                    value15 = true
                else
                    if
                        value14 and value14 > (config.odinBandOut or 87.5) + (config.odinLedgeIn or 8)
                        or label and label > (config.odinBandOut or 87.5) + (config.odinLedgeIn or 8) + 12
                    then
                        value102 = true
                    else
                        if
                            value100
                            and label
                            and label > value101 + 2
                            and (if value103
                                then value108 and config.odinCloseOnCast ~= false
                                else not value103)
                            and (value109 or config.odinCloseAlways ~= false)
                        then
                            value102 = true
                        else
                            if
                                value100
                                and label
                                and label <= value101 + 2
                                and config.odinHoldInReach ~= false
                            then
                                odinMechanics.last = { hold = true }
                                return {
                                    move = false,
                                    label = ("ODIN FIELD: in reach of Odin (%.0f, reach %.0f) on clear ground - holding for the cast%s"):format(
                                        label,
                                        value101,
                                        value108 and "" or (" (%.1fs)"):format(ignoreLines)
                                    ),
                                }
                            elseif
                                value14
                                and not value108
                                and value14 < value110 - 6
                                and not value111
                                and not value107
                            then
                                value105 = true
                            else
                                odinMechanics.last = { hold = true }
                                return {
                                    move = false,
                                    label = ("ODIN FIELD: clear here for %.1fs%s, standing%s%s"):format(
                                        value12 + 0.4,
                                        odinMechanics.state and " (" .. odinMechanics.state() .. ")" or "",
                                        label and (" - Odin %.0f"):format(label) or "",
                                        value108 and "" or " (skill first)"
                                    ),
                                }
                            end
                        end
                    end
                end
            end
        end
        local value113, value114, value115 =
            config.missileLanePitch or 15,
            config.gapLock ~= false
                and arenaCentre2 ~= nil
                and #odinMechanics.orbList > 0
                and #odinMechanics.arrays > 0,
            config.fieldHeadings or 24
        local value116 = config.fieldStep or 3
        value106 = config.fieldReach or 45
        local value117 = math.ceil(value106 / value116)
        ignoreLines = odinMechanics.commit
        local speed2, value118, value119, value120, value121, value122, value123 = ignoreLines ~= nil
            and firedAt - (ignoreLines.at or 0) < (config.fieldCommit or 0.8)
            and value16 ~= nil
        value106, value109 = 0
        for index12 = 0, value115 - 1, 1 do
            local value124 = index12 * (6.283185307179586 / value115)
            local value125, value126 = math.cos(value124), math.sin(value124)
            if not (speed2 and value125 * ignoreLines.ux + value126 * ignoreLines.uz < -0.2) then
                index12, value124 = infinity, 0
                for index13 = 1, value117, 1 do
                    local value127 = index13 * value116
                    if value127 > index12 then
                        break
                    end
                    local value128, value129, value130 =
                        value + value125 * value127, value2 + value126 * value127, firedAt + value127 / speed
                    if helper13(value128, value129, value14) then
                        break
                    end
                    if pathHazardAt(value128, value129, value130, firedAt, value13) then
                        index12 = value127
                        break
                    end
                    local value131, value132, when, value133 = ipairs, { 0.25, 0.5, value12, value12 + 0.4 }
                    index13 = true
                    for key2, entry3 in value131(value132) do
                        key2 = hazardAt(value128, value129, value130 + entry3, firedAt, value13)
                        if key2 then
                            if not when then
                                when, value133 = entry3, key2
                            end
                            index13 = if key2 ~= "orb" then false else index13
                        end
                    end
                    value130 = nil
                    if value114 then
                        value130 = value127
                        for index14, array in ipairs(odinMechanics.arrays) do
                            if
                                firedAt - array.at <= (config.volleyLive or 7)
                                and (
                                    array.pending > 0
                                    or firedAt - array.lastSpawn < (config.arrayGrace or 1.2)
                                )
                            then
                                if
                                    floor(
                                        (
                                            (value - arenaCentre2.X) * array.nx
                                            + (value2 - arenaCentre2.Z) * array.nz
                                        )
                                            / value113
                                    )
                                    ~= floor(
                                        (
                                            (value128 - arenaCentre2.X) * array.nx
                                            + (value129 - arenaCentre2.Z) * array.nz
                                        )
                                            / value113
                                    )
                                then
                                    value130 += config.gapCrossCost or 60
                                    break
                                end
                            end
                        end
                    else
                        value130 = value127
                    end
                    value130 += orbLaneCost(value128, value129)
                    if type(config.odinMateSpread) == "number" then
                        if context.otherRoots then
                            value131, value132 = config.odinMateSpread or 45, value130
                            for index15, entry4 in ipairs(context.otherRoots()) do
                                index15 = sqrt(
                                    (value128 - entry4.Position.X) ^ 2 + (value129 - entry4.Position.Z) ^ 2
                                )
                                value132 = if index15 < value131
                                    then value132 + (value131 - index15) * (config.odinMateWeight or 1.5)
                                    else value132
                            end
                            value130 = value132
                        end
                    end
                    value130 = if value99
                        then value130 + (config.fieldAnchorWeight or 0.25) * sqrt(
                            (value128 - value99.X) ^ 2 + (value129 - value99.Z) ^ 2
                        )
                        else value130
                    if arenaCentre2 then
                        value131 = sqrt((value128 - arenaCentre2.X) ^ 2 + (value129 - arenaCentre2.Z) ^ 2)
                        if value107 then
                            value130 += context.odinRankOff(value131) * (config.odinRankWeight or 2)
                        else
                            if value111 then
                                value132 = abs(value131 - value111) - value112
                                value130 = if value132 > 0
                                    then value130 + value132 * (config.odinRuneWeight or 2)
                                    else value130
                            else
                                local value134, value135 = config.odinBandIn or 50, config.odinBandOut or 87.5
                                value130 = if value131 < value134
                                    then value130 + (value134 - value131) * (config.odinBandWeight or 0.8)
                                    else if value131 > value135
                                        then value130 + (value131 - value135) * (config.odinBandWeight or 0.8)
                                        else value130
                            end
                        end
                    end
                    value132 = false
                    if value105 and arenaCentre2 then
                        value131 = sqrt((value128 - arenaCentre2.X) ^ 2 + (value129 - arenaCentre2.Z) ^ 2)
                        value132 = if value131 <= value14 + 2 then true else value132
                        value130 = abs(value131 - value110) * 2 + value127 * 0.3
                    end
                    if value15 and arenaCentre2 then
                        value131 = sqrt((value128 - arenaCentre2.X) ^ 2 + (value129 - arenaCentre2.Z) ^ 2)
                        if value107 then
                            value132 = if context.odinRankOff(value131)
                                    >= context.odinRankOff(value14) - 0.5
                                then true
                                else value132
                            value130 = context.odinRankOff(value131) * 2 + value127 * 0.3
                        else
                            value132 = if abs(value131 - value111) >= abs(value14 - value111) - 1
                                then true
                                else value132
                            value130 = abs(value131 - value111) * 2 + value127 * 0.3
                        end
                        value130 = if value100
                            then if value108
                                then value130 + max(
                                    sqrt((value128 - value100.X) ^ 2 + (value129 - value100.Z) ^ 2) - value101,
                                    0
                                ) * 2
                                else value130
                            else value130
                    end
                    if value100 and not value105 and not value15 then
                        value131 = sqrt((value128 - value100.X) ^ 2 + (value129 - value100.Z) ^ 2)
                        if value102 then
                            value132, value130 =
                                if value131 >= label - 3 then true else value132,
                                max(value131 - value101, 0) * 2 + value127 * 0.3
                            if value111 and arenaCentre2 then
                                local value136 = abs(
                                    sqrt((value128 - arenaCentre2.X) ^ 2 + (value129 - arenaCentre2.Z) ^ 2)
                                        - value111
                                ) - value112
                                value130 = if value136 > 0 then value130 + value136 * 2 else value130
                            else
                                value130 = if value107
                                    then if arenaCentre2
                                        then value130 + context.odinRankOff(
                                            sqrt(
                                                (value128 - arenaCentre2.X) ^ 2
                                                    + (value129 - arenaCentre2.Z) ^ 2
                                            )
                                        ) * 2
                                        else value130
                                    else value130
                            end
                        else
                            local value137 = value108 and (config.fieldReachWeightReady or 1.8)
                                or (config.fieldReachWeight or 0.6)
                            value130 = if value131 > value101
                                then value130 + value137 * (value131 - value101)
                                else if value108
                                    then value130 - (config.fieldInReachBonus or 30)
                                    else value130
                        end
                        value130 = if value131 < 20 then value130 + (20 - value131) * 2 else value130
                        value130 = if value103
                                and value131 < value104
                                and not value111
                            then if value107
                                then value130
                                else value130 + (value104 - value131) * (config.fieldLineHoldWeight or 1)
                            else value130
                    end
                    if not value132 then
                        if when then
                            local value138, value139 =
                                -when * 30 + value130 * 0.2,
                                value133 == "ring" and (config.fieldRingFirstCost or 150)
                            value131 = value138
                                + (value139 or 0)
                                + (value133 == "orb" and when <= 0.25 and 60 or 0)
                            if odinMechanics.last and odinMechanics.last.x then
                                if firedAt - (odinMechanics.last.at or 0) < (config.fieldStickFor or 1) then
                                    value139 = sqrt(
                                        (value128 - odinMechanics.last.x) ^ 2
                                            + (value129 - odinMechanics.last.z) ^ 2
                                    )
                                    value131 -= max((config.fieldStickBonus or 22) - value139 * 0.6, 0)
                                end
                            end
                            if if value120 then value131 < value121 else not value120 then
                                value120, value121 =
                                    { x = value128, z = value129, d = value127, when = when }, value131
                            end
                            value122 = if index13
                                    and (if value122 then value127 < value122.d else not value122)
                                then { x = value128, z = value129, d = value127, when = when }
                                else value122
                            value138 = value133 ~= "ring"
                                and (if value123 then value127 < value123.d else not value123)
                            value123 = if value138
                                then { x = value128, z = value129, d = value127, when = when }
                                else value123
                        else
                            if config.ringCentre ~= false then
                                local value140 = odinMechanics.ringClear(value128, value129, firedAt)
                                value130 = if value140
                                    then value130
                                        - min(value140, config.ringCentreCap or 14)
                                            * (config.ringCentreWeight or 1.3)
                                    else value130
                            end
                            if if value118 then value130 < value119 else not value118 then
                                value118, value119 = { x = value128, z = value129, d = value127 }, value130
                            end
                        end
                    end
                    value124 = value127
                end
                if value124 > value106 then
                    value109 =
                        { x = value + value125 * value124, z = value2 + value126 * value124, d = value124 }
                    value106 = value124
                end
            end
        end
        if value15 then
            if not value118 then
                odinMechanics.last = { hold = true }
                if value107 then
                    return {
                        move = false,
                        label = ("ODIN FIELD: off the 4th / 5th ring (%.0f from the middle), no clear way onto it - standing"):format(
                            value14
                        ),
                    }
                end
                return {
                    move = false,
                    label = ("ODIN FIELD: off the rune ring (%.0f from the middle, ring %.0f), no clear way onto it - standing"):format(
                        value14,
                        value111
                    ),
                }
            end
            odinMechanics.last = { x = value118.x, z = value118.z, at = firedAt }
            value113 = arenaCentre2
                    and sqrt((value118.x - arenaCentre2.X) ^ 2 + (value118.z - arenaCentre2.Z) ^ 2)
                or 0
            if value107 then
                return {
                    move = true,
                    point = Vector3.new(value118.x, vector.Y, value118.z),
                    speed = context.walkSpeedNow and context.walkSpeedNow() or 16,
                    label = ("ODIN FIELD: onto the 4th / 5th ring %.0f -> %.0f from the middle via a clear cell %.0f studs"):format(
                        value14,
                        value113,
                        value118.d
                    ),
                }
            end
            return {
                move = true,
                point = Vector3.new(value118.x, vector.Y, value118.z),
                speed = context.walkSpeedNow and context.walkSpeedNow() or 16,
                label = ("ODIN FIELD: onto the rune ring %.0f -> %.0f from the middle (ring %.0f) via a clear cell %.0f studs"):format(
                    value14,
                    value113,
                    value111,
                    value118.d
                ),
            }
        end
        if value105 then
            if not value118 then
                odinMechanics.last = { hold = true }
                return {
                    move = false,
                    label = ("ODIN FIELD: clear here (%.0f from the middle), no clear way out to %.0f - standing"):format(
                        value14,
                        value110
                    ),
                }
            end
            odinMechanics.last = { x = value118.x, z = value118.z, at = firedAt }
            return {
                move = true,
                point = Vector3.new(value118.x, vector.Y, value118.z),
                speed = context.walkSpeedNow and context.walkSpeedNow() or 16,
                label = ("ODIN FIELD: idle, backing out %.0f -> %.0f from the middle via a clear cell %.0f studs"):format(
                    value14,
                    value110,
                    value118.d
                ),
            }
        end
        if value102 then
            if not value118 then
                value107 = value120
                        and value120.when
                        and value120.when > (config.fieldCloseMinHold or 0.4)
                        and value120
                    or nil
                value107 = if (if value107 then not value107 else value109) and value106 >= 6
                    then value109
                    else value107
                if not value107 then
                    odinMechanics.last = { hold = true }
                    return {
                        move = false,
                        label = ("ODIN FIELD: clear here, Odin %.0f out of reach, no clear way in - standing"):format(
                            label
                        ),
                    }
                end
                odinMechanics.last = { x = value107.x, z = value107.z, at = firedAt }
                return {
                    move = true,
                    point = Vector3.new(value107.x, vector.Y, value107.z),
                    speed = config.fieldSpeed or 24,
                    label = ("ODIN FIELD: closing on Odin (%.0f, reach %.0f), best of a bad lot - cell %.0f studs holds %.1fs"):format(
                        label,
                        value101,
                        value107.d,
                        value107.when or 9.9
                    ),
                }
            end
            odinMechanics.last = { x = value118.x, z = value118.z, at = firedAt }
            return {
                move = true,
                point = Vector3.new(value118.x, vector.Y, value118.z),
                speed = config.fieldSpeed or 24,
                label = ("ODIN FIELD: clear, closing on Odin (%.0f, reach %.0f) via a clear cell %.0f studs"):format(
                    label,
                    value101,
                    value118.d
                ),
            }
        end
        value112, value104, label = value122
            or (value123 ~= nil and (value123.when or 0) > value98 and value123 or nil)
        if
            value16 == "ring"
            and value112
            and (
                (if value118 then value118.d > value112.d + (config.ringOrbSlack or 8) else not value118)
                or value118.d / speed > value98 and value118.d > value112.d
            )
        then
            value104, label =
                value112,
                ("ODIN FIELD: ring here in %.1fs -> through the %s, cell %.0f studs (rings first)"):format(
                    value98,
                    value112 == value122 and "orbs" or "rest",
                    value112.d
                )
        else
            if value118 then
                value104, label =
                    value118,
                    ("ODIN FIELD: %s here in %.1fs -> clear cell %.0f studs"):format(
                        value16,
                        value98,
                        value118.d
                    )
            else
                if value120 then
                    value104, label =
                        value120,
                        ("ODIN FIELD: %s here in %.1fs -> nothing clean, cell %.0f studs holds %.1fs"):format(
                            value16,
                            value98,
                            value120.d,
                            value120.when
                        )
                else
                    if value109 and value106 >= 6 then
                        value104, label =
                            value109,
                            ("ODIN FIELD: %s here in %.1fs -> nothing fits, longest clear run %.0f studs"):format(
                                value16,
                                value98,
                                value106
                            )
                    else
                        local function helper21(argument)
                            local value52, value53
                            for index7 = 0, value115 - 1, 1 do
                                local value54 = index7 * (6.283185307179586 / value115)
                                local value55, value56 = math.cos(value54), math.sin(value54)
                                for index16 = 1, value117, 1 do
                                    value54 = index16 * value116
                                    index7, index16 = value + value55 * value54, value2 + value56 * value54
                                    if helper13(index7, index16, value14) then
                                        break
                                    end
                                    local value57 = firedAt + value54 / speed
                                    if argument then
                                        if pathHazardAt(index7, index16, value57, firedAt, value13) then
                                            break
                                        end
                                    end
                                    local value141, value142, when2, value143 =
                                        ipairs, { 0, 0.25, 0.5, value12, value12 + 0.4 }, infinity
                                    for key3, entry5 in value141(value142) do
                                        key3 = hazardAt(index7, index16, value57 + entry5, firedAt, value13)
                                        if key3 then
                                            when2, value143 = entry5, key3
                                            break
                                        end
                                    end
                                    value142 = value54 / speed
                                        <= (value98 or 0) + (config.fieldCutSlack or 0.35)
                                    value141 = value54 - math.min(when2, 3) * 8 + (value142 and 0 or 1000000)
                                    value141 = if value143 == "orb"
                                        then if when2 <= 0.25 then infinity else value141
                                        else value141
                                    if
                                        value141 < infinity
                                        and (if value52 then value141 < value53 else not value52)
                                    then
                                        value52, value53 =
                                            { x = index7, z = index16, d = value54, when = when2 }, value141
                                    end
                                end
                            end
                            return value52, value53
                        end
                        value99, value110, value100 = helper21(true), false
                        if value99 then
                            value100 = value99
                        else
                            value100, value110 = (helper21(false)), true
                        end
                        value107, value101 =
                            config.fieldMoveGain or 0.25, value110 and (config.fieldUncheckedGain or 0.5)
                        value114, value108 =
                            value107 + (value101 or 0),
                            config.fieldMoveWhenHit ~= false and value98 <= (config.fieldHitNow or 0.05)
                        if
                            value100
                            and (value100.when >= value98 + value114 or value108 and value100.when > value98)
                        then
                            label = ("ODIN FIELD: %s here in %.1fs -> every path cut, cell %.0f studs clear for %.1fs"):format(
                                value16,
                                value98,
                                value100.d,
                                value100.when == infinity and 9.9 or value100.when
                            )
                        else
                            if value100 and config.fieldNoWayOutStand ~= true then
                                label = ("ODIN FIELD: %s here in %.1fs -> nothing better, taking the best going: cell %.0f studs, clear for %.1fs"):format(
                                    value16,
                                    value98,
                                    value100.d,
                                    value100.when == infinity and 9.9 or value100.when
                                )
                            else
                                odinMechanics.last = { none = true }
                                return {
                                    move = false,
                                    label = ("ODIN FIELD: %s here in %.1fs and nowhere at all to go - standing"):format(
                                        value16,
                                        value98
                                    ),
                                }
                            end
                        end
                        value104 = value100
                    end
                end
            end
        end
        odinMechanics.last = { x = value104.x, z = value104.z, at = firedAt }
        value108, value107 = value104.x - value, value104.z - value2
        value110 = sqrt(value108 * value108 + value107 * value107)
        if value110 > 1 then
            odinMechanics.commit = { ux = value108 / value110, uz = value107 / value110, at = firedAt }
        end
        value106 = value98 <= 0.5
        speed2 = (value16 == "ring" or value106) and (config.burstMax or 28)
            or (context.walkSpeedNow and context.walkSpeedNow() or speed)
        return {
            move = true,
            urgent = value106 or value16 == "ring",
            point = Vector3.new(value104.x, vector.Y, value104.z),
            speed = speed2,
            label = label,
        }
    end
    odinMechanics.state = function()
        local value, value2, value3, value4 =
            #odinMechanics.setList, #odinMechanics.arrays, #odinMechanics.lineList, #odinMechanics.orbList
        return ("sets %d arrays %d lines %d orbs %d"):format(value, value2, value3, value4)
    end
    odinMechanics.clearFor = function(vector, argument, argument2)
        if argument - odinMechanics.lastTick > 1 then
            return false
        end
        local value, value2, value3, iterateArray, value4 =
            vector.X,
            vector.Z,
            (config.fieldLaneMargin or 1) + 0.5,
            ipairs,
            { 0, argument2 * 0.5, argument2, argument2 + 0.3 }
        for key, entry in iterateArray(value4) do
            if hazardAt(value, value2, argument + entry, argument, value3) then
                return false
            end
        end
        return true
    end
end
