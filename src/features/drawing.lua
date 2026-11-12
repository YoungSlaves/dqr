-- Extracted verbatim from harvardd.lua lines 126349-129081; presentation owned elsewhere.
    local config = context.CFG
    local dangerGeometry = context.DG
    local hazardReader = context.RD
    local hazards = context.hazards
    local visualRoot = context.visualRoot
    local runtimeState, sharedValue =
        context.RT,
        { parts = {}, nodes = {}, spots = {}, scan = {}, ring = {}, groups = {}, tags = {}, wallTags = {} }
    sharedValue.lastDraw = -math.huge
    sharedValue.lastSweep = -math.huge
    sharedValue.list = {}
    local function helper()
        if sharedValue.folder then
            if sharedValue.folder.Parent then
                return sharedValue.folder
            end
        end
        sharedValue.folder = Instance.new("Folder")
        sharedValue.folder.Name = "Hazards"
        sharedValue.folder.Parent = visualRoot()
        return sharedValue.folder
    end
    local function helper2(parent, name2, transparency)
        local part = Instance.new("Part")
        part.Name = name2
        part.Anchored = true
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.CastShadow = false
        part.Material = Enum.Material.Neon
        part.Transparency = transparency
        part.Parent = parent
        return part
    end
    local setMetatable, weakKeys = setmetatable, { __mode = "k" }
    local sharedValue2, sharedValue3, sharedValue4, sharedValue5 = setMetatable({}, weakKeys), {}, {}, {}
    local function helper3(argument, argument2, argument3, argument4, argument5, transparency, transform)
        local value = sharedValue2[argument]
        if not value then
            value = {}
            sharedValue2[argument] = value
        end
        if value.sx ~= argument2 or value.sy ~= argument3 or value.sz ~= argument4 then
            argument.Size = Vector3.new(argument2, argument3, argument4)
            value.sx = argument2
            value.sy = argument3
            value.sz = argument4
        end
        if value.col ~= argument5 then
            argument.Color = argument5
            value.col = argument5
        end
        if value.tr ~= transparency then
            argument.Transparency = transparency
            value.tr = transparency
        end
        if value.cf ~= transform then
            value.cf = transform
            if config.drawBulkMove ~= false then
                transparency = sharedValue5[argument]
                if not transparency then
                    transparency = #sharedValue3 + 1
                    sharedValue3[transparency] = argument
                    sharedValue5[argument] = transparency
                end
                sharedValue4[transparency] = transform
            else
                argument.CFrame = transform
            end
        end
    end
    local function helper4()
        local value = #sharedValue3
        if value == 0 then
            return
        end
        if
            not (
                pcall(function()
                    Workspace:BulkMoveTo(sharedValue3, sharedValue4, Enum.BulkMoveMode.FireCFrameChanged)
                end)
            )
        then
            for index = 1, value, 1 do
                local value2 = sharedValue3[index]
                if value2.Parent then
                    value2.CFrame = sharedValue4[index]
                end
            end
        end
        table.clear(sharedValue3)
        table.clear(sharedValue4)
        table.clear(sharedValue5)
    end
    local sharedValue6 = {}
    local function helper5(argument)
        local value = sharedValue6[argument]
        if value then
            return value
        end
        value = { c = {}, s = {}, r = {} }
        local value2 = 6.283185307179586 / argument
        for index = 0, argument - 1, 1 do
            local value3 = index * value2 + value2 / 2
            local value4, value5 = math.cos(value3), math.sin(value3)
            value.c[index], value.s[index], value.r[index] =
                value4, value5, CFrame.new(Vector3.new(0, 0, 0), Vector3.new(-value5, 0, value4))
        end
        sharedValue6[argument] = value
        return value
    end
    local function helper6(argument, lineThickness, color3)
        local value = Instance.new("SelectionBox")
        value.Name = "edge"
        value.LineThickness = lineThickness
        value.SurfaceTransparency = 1
        value.Color3 = color3
        value.Adornee = argument
        value.Parent = argument
        return value
    end
    local function helper7(
        argument,
        argument2,
        argument3,
        argument4,
        argument5,
        argument6,
        argument7,
        argument8,
        argument9,
        argument10,
        argument11
    )
        argument9 = argument9 or math.clamp(math.floor(argument5 * 2.2), 48, 160)
        local value = 6.283185307179586 / argument9
        local value2, value3, value4, value5, value6 =
            2 * argument5 * math.sin(value / 2),
            math.max((argument7 or 0.5) * (config.markerScale or 1), 0.2),
            helper5(argument9),
            argument4.X,
            argument4.Z
        for index = 0, argument9 - 1, 1 do
            argument4, argument7 = value4.c[index], value4.s[index]
            if not (argument10 and argument4 * argument10 + argument7 * argument11 < 0) then
                argument2 += 1
                value = argument[argument2]
                if if value then not value.Parent else not value then
                    value = helper2(helper(), "ring", argument8)
                    value.Shape = Enum.PartType.Block
                    argument[argument2] = value
                end
                helper3(
                    value,
                    value3,
                    value3,
                    value2,
                    argument3,
                    argument8,
                    value4.r[index]
                        + Vector3.new(
                            value5 + argument4 * argument5,
                            argument6,
                            value6 + argument7 * argument5
                        )
                )
            end
        end
        return argument2
    end
    local function helper8(
        argument,
        argument2,
        argument3,
        vector,
        argument4,
        argument5,
        argument6,
        argument7,
        argument8,
        argument9
    )
        local value = (argument4 + argument5) * 0.5
        local value2 = math.clamp(math.floor(value * 1.2), 24, 120)
        local value3 = 6.283185307179586 / value2
        local value4, value5, value6, value7, value8 =
            2 * argument4 * math.sin(value3 / 2) * 1.03,
            math.max(argument4 - argument5, 0.5),
            helper5(value2),
            vector.X,
            vector.Z
        for index = 0, value2 - 1, 1 do
            value3, argument5 = value6.c[index], value6.s[index]
            if not (argument8 and value3 * argument8 + argument5 * argument9 < 0) then
                argument2 += 1
                argument4 = argument[argument2]
                if if argument4 then not argument4.Parent else not argument4 then
                    argument4 = helper2(helper(), "ring", argument7)
                    argument4.Shape = Enum.PartType.Block
                    argument[argument2] = argument4
                end
                helper3(
                    argument4,
                    value5,
                    0.4,
                    value4,
                    argument3,
                    argument7,
                    value6.r[index]
                        + Vector3.new(value7 + value3 * value, argument6, value8 + argument5 * value)
                )
            end
        end
        return argument2
    end
    local function helper9(argument, argument2, argument3, argument4, argument5, argument6)
        local value = argument[argument2]
        if if value then not value.Parent else not value then
            value = helper2(helper(), "node", argument6)
            value.Shape = Enum.PartType.Ball
            argument[argument2] = value
        end
        argument4 = math.max(argument4 * (config.markerScale or 1), 0.55)
        helper3(value, argument4, argument4, argument4, argument3, argument6, CFrame.new(argument5))
    end
    local function helper10(argument, argument2)
        for index = #argument, argument2 + 1, -1 do
            local value = argument[index]
            if
                config.drawKeepSpare ~= false
                and index <= (config.drawSpareMax or 300)
                and typeof(value) == "Instance"
                and value:IsA("BasePart")
                and value.Parent
            then
                local value2 = sharedValue2[value]
                if not (value2 and value2.tr == 1) then
                    value.Transparency = 1
                    if value2 then
                        value2.tr = 1
                    else
                        sharedValue2[value] = { tr = 1 }
                    end
                end
            else
                if value then
                    value:Destroy()
                end
                argument[index] = nil
            end
        end
    end
    -- DQR section 8 label plate: DeepForest @0.70, 4px radius, 1px Bark
    -- hairline, 11px body text with a 1px DeepForest outline.
    local function helper11(parent, textColor3)
        local style = context.drawStyle
        local tag = Instance.new("BillboardGui")
        tag.Name, tag.Size, tag.AlwaysOnTop, tag.MaxDistance, tag.StudsOffsetWorldSpace =
            "tag", UDim2.fromOffset(240, 26), true, 250, Vector3.new(0, 4, 0)
        tag.LightInfluence = 0
        local plate = Instance.new("Frame")
        plate.Name, plate.BackgroundColor3, plate.BackgroundTransparency =
            "plate", style.plate, 0.70
        plate.BorderSizePixel = 0
        plate.Size = UDim2.fromScale(1, 1)
        plate.Parent = tag
        style.round(plate, 4)
        style.hairline(plate)
        local text = Instance.new("TextLabel")
        text.Name, text.Size = "text", UDim2.fromScale(1, 1)
        text.BackgroundTransparency = 1
        text.TextColor3 = textColor3 or style.text
        text.TextStrokeColor3 = style.plate
        text.TextStrokeTransparency = 0
        text.TextScaled = false
        text.TextSize = 11
        text.TextYAlignment = Enum.TextYAlignment.Center
        style.font(text, "body")
        text.Parent = plate
        style.pad(plate, 1, 3, 1, 3)
        style.uppercase(text)
        tag.Parent = parent
        return tag
    end
    local function helper12()
        sharedValue.boxPool = sharedValue.boxPool or {}
        while config.drawBoxPool ~= false and #sharedValue.boxPool > 0 do
            local value = table.remove(sharedValue.boxPool)
            if value then
                if value.Parent then
                    return value
                end
            end
        end
        local value2 = helper2(helper(), "box", config.hazardTransparency)
        helper6(value2, 1.5, config.colorFloor or context.drawStyle.hazard)
        helper11(value2, context.drawStyle.text)
        return value2
    end
    local function helper13(argument)
        if not argument then
            return
        end
        sharedValue.boxPool = sharedValue.boxPool or {}
        if
            config.drawBoxPool ~= false
            and argument.Parent
            and #sharedValue.boxPool < (config.drawBoxPoolMax or 150)
        then
            argument.Transparency = 1
            local value = argument:FindFirstChild("edge")
            if value then
                value.Transparency = 1
            end
            value = argument:FindFirstChild("tag")
            if value then
                value.Enabled = false
            end
            value = { "sight", "sweep" }
            for index, entry in ipairs(value) do
                index = argument:FindFirstChild(entry)
                if index then
                    index:Destroy()
                end
            end
            sharedValue.boxPool[#sharedValue.boxPool + 1] = argument
        else
            argument:Destroy()
        end
    end
    local function helper14(argument, argument2)
        local value = argument:FindFirstChild("sight")
        if not argument2 then
            if value then
                value:Destroy()
            end
            return nil
        end
        if not value then
            value = helper2(argument, "sight", 1)
            helper6(value, 1.5, context.drawStyle.hazard)
        end
        return value
    end
    local function helper15()
        if sharedValue.orbFolder then
            if sharedValue.orbFolder.Parent then
                return sharedValue.orbFolder
            end
        end
        sharedValue.orbFolder = Instance.new("Folder")
        sharedValue.orbFolder.Name = "GroupOrbs"
        sharedValue.orbFolder.Parent = visualRoot()
        return sharedValue.orbFolder
    end
    local function helper16()
        if sharedValue.aoeFolder then
            if sharedValue.aoeFolder.Parent then
                return sharedValue.aoeFolder
            end
        end
        sharedValue.aoeFolder = Instance.new("Folder")
        sharedValue.aoeFolder.Name = "AoEMarker"
        sharedValue.aoeFolder.Parent = visualRoot()
        return sharedValue.aoeFolder
    end
    local function helper17()
        local value = hazardReader.aoeShape
        local value2 = value and value.aoeX
        if if value2 then not value2 else game.PlaceId == 101088859550383 or HLGSF == true then
            if context.gsAttackArea then
                local value3 = context.gsAttackArea()
                value = if value3
                    then {
                        aoeX = value3.x,
                        aoeZ = value3.z or value3.x,
                        aoeRound = value3.round == true,
                        measured = true,
                    }
                    else value
            end
        end
        if not (value and value.aoeX) then
            if type(config.aoeKnown) == "table" then
                if hazardReader.abilitySlots then
                    value2 = value
                    for key, abilitySlot in pairs(hazardReader.abilitySlots) do
                        key = abilitySlot.name and config.aoeKnown[string.lower(tostring(abilitySlot.name))]
                            or nil
                        if key then
                            value2 = { aoeX = key.x, aoeZ = key.z, aoeRound = key.round, measured = true }
                            break
                        end
                    end
                    value = value2
                end
            end
        end
        local value4, value5 = runtimeState.groupPlan, game.Players.LocalPlayer.Character
        local aoeMarker, value6, value7, value8 =
            value5 and (value5:FindFirstChild("HumanoidRootPart")),
            context.aoeLanding and select(1, context.aoeLanding()) or nil
        value2 = context.BR and context.BR.aim or nil
        value2 = if game.PlaceId == 101088859550383 or HLGSF == true
            then if runtimeState.coverFace
                then if os.clock() - (runtimeState.aoeScanAt or 0) < 0.5
                    then runtimeState.coverFace
                    else value2
                else value2
            else value2
        if value2 then
            if aoeMarker then
                local value9, value10 = value2.X - aoeMarker.Position.X, value2.Z - aoeMarker.Position.Z
                value5 = math.sqrt(value9 * value9 + value10 * value10)
                if value5 > 0.5 then
                    local value11, value12 = value9 / value5, value10 / value5
                    value7, value8 = value11, value12
                end
            end
        end
        if not value7 then
            if value4 then
                value2, value5 = nil
                if value4.hfx then
                    value2, value5 = value4.hfx, value4.hfz
                    value7, value8 = value2, value5
                else
                    if value4.a then
                        value2, value5 = math.cos(value4.a), math.sin(value4.a)
                        value7, value8 = value2, value5
                    end
                end
            end
        end
        if not value7 then
            if aoeMarker then
                value4 = aoeMarker.CFrame.LookVector
                value5 = math.sqrt(value4.X * value4.X + value4.Z * value4.Z)
                if value5 > 0.01 then
                    local value13, value14 = value4.X / value5, value4.Z / value5
                    value7, value8 = value13, value14
                end
            end
        end
        if config.aoeMarker == false or not (value and aoeMarker and value6 and value7) then
            if sharedValue.aoeMark then
                sharedValue.aoeMark:Destroy()
                sharedValue.aoeMark = nil
            end
            return
        end
        value2 = aoeMarker.Position
        value4, aoeMarker =
            Vector3.new(value2.X + value7 * value6, value2.Y - 2.4, value2.Z + value8 * value6),
            sharedValue.aoeMark
        if not (aoeMarker and aoeMarker.Parent) then
            aoeMarker = Instance.new("Part")
            aoeMarker.Name = "aoeMarker"
            aoeMarker.Anchored = true
            aoeMarker.CanCollide = false
            aoeMarker.CanQuery = false
            aoeMarker.CanTouch = false
            aoeMarker.CastShadow = false
            aoeMarker.Material = Enum.Material.Neon
            aoeMarker.Transparency = 0.72
            aoeMarker.Color = config.colorAbility or Color3.fromRGB(255, 105, 180)
            aoeMarker.Parent = helper16()
            sharedValue.aoeMark = aoeMarker
        end
        if game.PlaceId == 101088859550383 or HLGSF == true then
            value6, value5 =
                runtimeState.coverN or 0,
                tostring(runtimeState.attackState or ""):find("cooldown", 1, true) ~= nil
            aoeMarker.Color = value6 > 0 and not value5 and Color3.fromRGB(80, 255, 120)
                or value6 > 0 and Color3.fromRGB(255, 220, 80)
                or Color3.fromRGB(150, 150, 160)
            aoeMarker.Transparency = value6 > 0 and 0.6 or 0.8
        end
        if value.aoeRound then
            aoeMarker.Shape, aoeMarker.Size = Enum.PartType.Cylinder, Vector3.new(0.4, value.aoeX, value.aoeX)
            aoeMarker.CFrame = CFrame.new(value4) * CFrame.Angles(0, 0, 1.5707963267948966)
        else
            aoeMarker.Shape, aoeMarker.Size = Enum.PartType.Block, Vector3.new(value.aoeX, 0.4, value.aoeZ)
            aoeMarker.CFrame = CFrame.lookAt(value4, value4 + Vector3.new(value7, 0, value8))
        end
    end
    local function helper18()
        local aoeScan = sharedValue.aoeScan or {}
        sharedValue.aoeScan = aoeScan
        local aoeScan2 = hazardReader.aoeScan
        if
            config.drawAoeScan ~= true
            or not aoeScan2
            or os.clock() - (aoeScan2.at or 0) > 1
            or (game.PlaceId == 101088859550383 or HLGSF == true) and config.gsDrawAoeScan ~= true
        then
            if #aoeScan > 0 then
                for index = #aoeScan, 1, -1 do
                    if aoeScan[index] then
                        aoeScan[index]:Destroy()
                    end
                    aoeScan[index] = nil
                end
            end
            return
        end
        local value, value2, value3 =
            math.max(math.floor((config.aoeScanDrawStep or 15) / math.max(config.aimStepDeg or 5, 1)), 1),
            config.aoeScanLift or 2.4,
            0
        for index2 = 1, #aoeScan2.list, 1 do
            value3 = if aoeScan2.list[index2].n > value3 then aoeScan2.list[index2].n else value3
        end
        local value4 = 0
        local function helper19()
            value4 += 1
            local aoeScan3 = aoeScan[value4]
            if not (aoeScan3 and aoeScan3.Parent) then
                aoeScan3 = Instance.new("Part")
                aoeScan3.Name = "aoeScan"
                aoeScan3.Anchored = true
                aoeScan3.CanCollide = false
                aoeScan3.CanQuery = false
                aoeScan3.CanTouch = false
                aoeScan3.CastShadow = false
                aoeScan3.Material = Enum.Material.Neon
                aoeScan3.Parent = helper16()
                aoeScan[value4] = aoeScan3
            end
            return aoeScan3
        end
        local value5 = aoeScan2.rx ~= nil and aoeScan2.rz ~= nil and config.aoeScanTrueShape ~= false
        for index3 = 1, #aoeScan2.list, 1 do
            local value6 = aoeScan2.list[index3]
            if (index3 - 1) % value == 0 or index3 == aoeScan2.best then
                local value7, value8 = index3 == aoeScan2.best, value3 > 0 and value6.n / value3 or 0
                local color, value9 =
                    value7 and Color3.fromRGB(255, 240, 120) or Color3.fromRGB(
                        60 + math.floor(value8 * 60),
                        90 + math.floor(value8 * 165),
                        140 + math.floor(value8 * 40)
                    ),
                    (aoeScan2.y or 0) - value2 + (value7 and 0.6 or 0)
                if value5 and value6.fx then
                    local value10, value11 = value6.fx, value6.fz
                    local value12, value13, value14, value15, transparency, iterateArray =
                        -value11,
                        aoeScan2.rz * 0.5,
                        aoeScan2.rx * 0.5,
                        value7 and 0.7 or 0.3,
                        value7 and 0.2 or 0.88 - value8 * 0.45,
                        ipairs
                    local value16 = {
                        {
                            value6.x + value10 * value13,
                            value6.z + value11 * value13,
                            value12,
                            value10,
                            aoeScan2.rx,
                        },
                        {
                            value6.x - value10 * value13,
                            value6.z - value11 * value13,
                            value12,
                            value10,
                            aoeScan2.rx,
                        },
                        {
                            value6.x + value12 * value14,
                            value6.z + value10 * value14,
                            value10,
                            value11,
                            aoeScan2.rz,
                        },
                        {
                            value6.x - value12 * value14,
                            value6.z - value10 * value14,
                            value10,
                            value11,
                            aoeScan2.rz,
                        },
                    }
                    for key, entry in iterateArray(value16) do
                        value14 = helper19()
                        value14.Shape = Enum.PartType.Block
                        value14.Size = Vector3.new(value15, 0.2, entry[5] + value15)
                        value14.CFrame = CFrame.lookAt(
                            Vector3.new(entry[1], value9, entry[2]),
                            Vector3.new(entry[1] + entry[3], value9, entry[2] + entry[4])
                        )
                        value14.Color = color
                        value14.Transparency = transparency
                    end
                else
                    local value17 = helper19()
                    value17.Shape = Enum.PartType.Cylinder
                    value17.Size = Vector3.new(0.3, aoeScan2.lr * 2, aoeScan2.lr * 2)
                    value17.CFrame = CFrame.new(value6.x, value9, value6.z)
                        * CFrame.Angles(0, 0, 1.5707963267948966)
                    value17.Transparency = value7 and 0.55 or 0.97 - value8 * 0.12
                    value17.Color = color
                end
            end
        end
        value5, helper19 = #aoeScan, value4 + 1
        for index4 = value5, helper19, -1 do
            if aoeScan[index4] then
                aoeScan[index4]:Destroy()
            end
            aoeScan[index4] = nil
        end
    end
    local function helper20()
        local orbs = sharedValue.orbs or {}
        sharedValue.orbs = orbs
        local value, value2 = config.groupOrbs == false
        if value then
            value2 = value
        else
            local mobGroups = hazardReader.mobGroups
            value2 = (if mobGroups then not mobGroups else not hazardReader.firstCastMobs)
                and not hazardReader.castPending
        end
        if value2 then
            if next(orbs) ~= nil then
                for key, orb in pairs(orbs) do
                    orb:Destroy()
                    orbs[key] = nil
                end
            end
            return
        end
        local value3, value4, value5 = config.groupOrbSize or 1.7, config.groupOrbHeight or 5.5, {}
        for index, entry in ipairs(hazardReader.enemies or {}) do
            index = entry.isBoss
            if
                (if index then not index else entry.root)
                and entry.root.Parent
                and (entry.humanoid == nil or entry.humanoid.Health > 0)
            then
                value, value2 =
                    hazardReader.groupOf and entry.model and hazardReader.groupOf[entry.model] or nil,
                    hazardReader.firstCastMobs
                local value6 = config.tagMark ~= false
                    and entry.model ~= nil
                    and (
                        context.mobTagged ~= nil and context.mobTagged(entry)
                        or value2 ~= nil and value2[entry.model] == true
                    )
                if value then
                    local value7 = value.n
                    value = if value7 then if value7 < 2 then nil else value else nil
                end
                if value or value6 then
                    local groupOrb = orbs[entry.model]
                    if not (groupOrb and groupOrb.Parent) then
                        groupOrb = Instance.new("Part")
                        groupOrb.Name = "groupOrb"
                        groupOrb.Shape = Enum.PartType.Ball
                        groupOrb.Anchored = true
                        groupOrb.CanCollide = false
                        groupOrb.CanQuery = false
                        groupOrb.CanTouch = false
                        groupOrb.CastShadow = false
                        groupOrb.Material = Enum.Material.Neon
                        groupOrb.Parent = helper15()
                        orbs[entry.model] = groupOrb
                    end
                    groupOrb.Size = value6 and Vector3.new(value3 * 1.4, value3 * 1.4, value3 * 1.4)
                        or Vector3.new(value3, value3, value3)
                    groupOrb.Transparency = (value6 or value) and 0 or 1
                    groupOrb.Color = value6 and (config.colorTagged or Color3.fromRGB(60, 255, 110))
                        or value and value.colour
                        or Color3.new(1, 1, 1)
                    groupOrb.CFrame = CFrame.new(entry.root.Position + Vector3.new(0, value4, 0))
                    if config.groupNumbers ~= false then
                        local num = groupOrb:FindFirstChild("num")
                        if not num then
                            num = Instance.new("BillboardGui")
                            num.Name = "num"
                            num.Size = UDim2.fromOffset(80, 26)
                            num.AlwaysOnTop = true
                            num.MaxDistance = 300
                            num.StudsOffsetWorldSpace = Vector3.new(0, 1.6, 0)
                            num.LightInfluence = 0
                            local label = Instance.new("TextLabel")
                            label.Name = "t"
                            label.Size = UDim2.fromScale(1, 1)
                            label.BackgroundTransparency = 1
                            label.TextStrokeTransparency = 0.2
                            label.TextScaled = true
                            label.Font = Enum.Font.GothamBold
                            label.Parent = num
                            num.Parent = groupOrb
                        end
                        local textControl = num:FindFirstChild("t")
                        if textControl then
                            local value8, text = value6 and "TAG"
                            if value8 then
                                text = value8
                            else
                                local toString, value9 = tostring, value and (value.num or value.id)
                                text = toString(value9 or "?")
                            end
                            textControl.Text = text
                            textControl.TextColor3 = value6 and Color3.fromRGB(120, 255, 140)
                                or value and value.colour
                                or Color3.new(1, 1, 1)
                        end
                    end
                    value5[entry.model] = true
                end
            end
        end
        for key2, orb2 in pairs(orbs) do
            if not value5[key2] then
                orb2:Destroy()
                orbs[key2] = nil
            end
        end
    end
    local function helper21()
        if sharedValue.mlFolder then
            if sharedValue.mlFolder.Parent then
                return sharedValue.mlFolder
            end
        end
        sharedValue.mlFolder = Instance.new("Folder")
        sharedValue.mlFolder.Name = "MissileLines"
        sharedValue.mlFolder.Parent = visualRoot()
        return sharedValue.mlFolder
    end
    local function drawMissileLines()
        local mLines = sharedValue.mLines or {}
        sharedValue.mLines = mLines
        local missileLines, value = hazardReader.missileLines, 0
        if config.visuals ~= false then
            if config.drawMissileLines ~= false then
                if missileLines then
                    if missileLines.lines then
                        if os.clock() - (missileLines.at or 0) < (config.missileLineStale or 3) then
                            local value2, arenaCentre, color, value3, value4 =
                                config.missileLaneLen or 600,
                                hazardReader.arenaCentre,
                                config.colorMissileLine or Color3.fromRGB(60, 255, 90),
                                (missileLines.y or 0) - 2.3,
                                value
                            for index, line in ipairs(missileLines.lines) do
                                local value5, value6 =
                                    missileLines.bx + missileLines.nx * line,
                                    missileLines.bz + missileLines.nz * line
                                if arenaCentre then
                                    index = (arenaCentre.X - value5) * missileLines.ax
                                        + (arenaCentre.Z - value6) * missileLines.az
                                    value5, value6 =
                                        value5 + missileLines.ax * index, value6 + missileLines.az * index
                                end
                                value4 += 1
                                index = mLines[value4]
                                if not (index and index.Parent) then
                                    index = Instance.new("Part")
                                    index.Name = "missileLine"
                                    index.Anchored = true
                                    index.CanCollide = false
                                    index.CanQuery = false
                                    index.CanTouch = false
                                    index.CastShadow = false
                                    index.Material = Enum.Material.Neon
                                    index.Parent = helper21()
                                    mLines[value4] = index
                                end
                                local value7 = missileLines.pick ~= nil
                                    and math.abs(line - missileLines.pick) < 0.01
                                local new, value8 =
                                    Vector3.new, value7 and (config.missileLineWidthPick or 0.7)
                                index.Size = new(value8 or (config.missileLineWidth or 0.4), 0.2, value2)
                                index.Color, index.Transparency = color, value7 and 0 or 0.3
                                index.CFrame = CFrame.lookAt(
                                    Vector3.new(value5, value3, value6),
                                    Vector3.new(value5 + missileLines.ax, value3, value6 + missileLines.az)
                                )
                            end
                            value = value4
                        end
                    end
                end
            end
        end
        for index2 = #mLines, value + 1, -1 do
            if mLines[index2] then
                mLines[index2]:Destroy()
            end
            mLines[index2] = nil
        end
    end
    context.drawMissileLines = drawMissileLines
    local function helper22()
        local bLines = sharedValue.bLines or {}
        sharedValue.bLines = bLines
        local value = 0
        if config.visuals ~= false then
            if config.drawBlueRails ~= false then
                if context.PB then
                    if context.PB.boss == "Odin" then
                        if context.OD then
                            if context.OD.blueArcs then
                                local S, S, value2 = context.character()
                                local value3 = value2 and value2.Position.Y - 2.3 or nil
                                local blueRail, color, value4, value5 =
                                    value3 and context.OD.blueArcs(os.clock()) or {},
                                    config.colorBlueRail or Color3.fromRGB(70, 150, 255),
                                    config.blueRailSegments or 18,
                                    value
                                for index, entry in ipairs(blueRail) do
                                    value2 = math.atan2(entry.sz, entry.sx)
                                    for index2 = 0, value4 - 1, 1 do
                                        local value6, value7 =
                                            value2 - 1.5707963267948966 + 3.141592653589793 * index2 / value4,
                                            value2
                                                - 1.5707963267948966
                                                + 3.141592653589793 * (index2 + 1) / value4
                                        local value8, value9, value10, value11 =
                                            entry.cx + math.cos(value6) * entry.r,
                                            entry.cz + math.sin(value6) * entry.r,
                                            entry.cx + math.cos(value7) * entry.r,
                                            entry.cz + math.sin(value7) * entry.r
                                        value7 = math.sqrt((value10 - value8) ^ 2 + (value11 - value9) ^ 2)
                                        if value7 > 0.05 then
                                            value5 += 1
                                            index2 = bLines[value5]
                                            if not (index2 and index2.Parent) then
                                                index2 = Instance.new("Part")
                                                index2.Name = "blueRail"
                                                index2.Anchored = true
                                                index2.CanCollide = false
                                                index2.CanQuery = false
                                                index2.CanTouch = false
                                                index2.CastShadow = false
                                                index2.Material = Enum.Material.Neon
                                                index2.Parent = helper21()
                                                bLines[value5] = index2
                                            end
                                            value6, index = (value8 + value10) * 0.5, (value9 + value11) * 0.5
                                            index2.Size = Vector3.new(
                                                (context.OD.railHalfW and context.OD.railHalfW() or 0.2) * 2,
                                                0.2,
                                                value7 + 0.1
                                            )
                                            index2.Color = color
                                            index2.Transparency = 0.2
                                            index2.CFrame = CFrame.lookAt(
                                                Vector3.new(value6, value3, index),
                                                Vector3.new(value10, value3, value11)
                                            )
                                        end
                                    end
                                end
                                color = context.OD.cross
                                if value3 then
                                    if color then
                                        if os.clock() - (color.at or 0) < 0.5 then
                                            value2 = value5 + 1
                                            blueRail = bLines[value2]
                                            if not (blueRail and blueRail.Parent) then
                                                blueRail = Instance.new("Part")
                                                blueRail.Name = "blueRail"
                                                blueRail.Anchored = true
                                                blueRail.CanCollide = false
                                                blueRail.CanQuery = false
                                                blueRail.CanTouch = false
                                                blueRail.CastShadow = false
                                                blueRail.Material = Enum.Material.Neon
                                                blueRail.Parent = helper21()
                                                bLines[value2] = blueRail
                                            end
                                            blueRail.Size = Vector3.new(0.3, 3, 3)
                                            blueRail.Color = Color3.fromRGB(120, 255, 230)
                                            blueRail.Transparency = 0
                                            blueRail.CFrame = CFrame.new(color.x, value3, color.z)
                                                * CFrame.Angles(0, 0, 1.5707963267948966)
                                            value = value2
                                        else
                                            value = value5
                                        end
                                    else
                                        value = value5
                                    end
                                else
                                    value = value5
                                end
                            end
                        end
                    end
                end
            end
        end
        for index3 = #bLines, value + 1, -1 do
            if bLines[index3] then
                bLines[index3]:Destroy()
            end
            bLines[index3] = nil
        end
    end
    local function helper23()
        local bobRailParts = sharedValue.bobRailParts or {}
        sharedValue.bobRailParts = bobRailParts
        local value, bobLines = 0, hazardReader.bobLines
        if config.visuals ~= false then
            if config.drawMissileLines ~= false then
                if bobLines then
                    if bobLines.lines then
                        if os.clock() - (bobLines.at or 0) < 0.5 then
                            local v, v, value2 = context.character()
                            local value3 = value2 and value2.Position.Y - 2.3 or nil
                            if value3 then
                                local value4, color, value5 =
                                    math.min(bobLines.halfL * 2, config.bobRailDrawLen or 160),
                                    config.colorMissileLine or Color3.fromRGB(60, 255, 90),
                                    value
                                for index, line in ipairs(bobLines.lines) do
                                    value5 += 1
                                    index = bobRailParts[value5]
                                    if not (index and index.Parent) then
                                        index = Instance.new("Part")
                                        index.Name = "bobRail"
                                        index.Anchored = true
                                        index.CanCollide = false
                                        index.CanQuery = false
                                        index.CanTouch = false
                                        index.CastShadow = false
                                        index.Material = Enum.Material.Neon
                                        index.Parent = helper21()
                                        bobRailParts[value5] = index
                                    end
                                    local value6, value7, value8 =
                                        bobLines.pick ~= nil and math.abs(line - bobLines.pick) < 0.01,
                                        bobLines.bx + bobLines.nx * line + bobLines.ax * bobLines.alongMid,
                                        bobLines.bz + bobLines.nz * line + bobLines.az * bobLines.alongMid
                                    index.Size = Vector3.new(value6 and 0.7 or 0.4, 0.2, value4)
                                    index.Color, index.Transparency = color, value6 and 0 or 0.3
                                    index.CFrame = CFrame.lookAt(
                                        Vector3.new(value7, value3, value8),
                                        Vector3.new(value7 + bobLines.ax, value3, value8 + bobLines.az)
                                    )
                                end
                                value = value5
                            end
                        end
                    end
                end
            end
        end
        for index2 = #bobRailParts, value + 1, -1 do
            if bobRailParts[index2] then
                bobRailParts[index2]:Destroy()
            end
            bobRailParts[index2] = nil
        end
    end
    local function helper24()
        local fanParts = sharedValue.fanParts or {}
        sharedValue.fanParts = fanParts
        local value = 0
        if
            config.visuals ~= false
            and config.drawFanBeam ~= false
            and context.PB
            and context.PB.boss == "Odin"
            and context.OD
            and context.OD.fanRedNow
        then
            local v, v, now = context.character()
            local value2 = now and now.Position.Y - 2.3 or nil
            now = os.clock()
            local function helper19(
                argument,
                argument2,
                argument3,
                argument4,
                argument5,
                argument6,
                color,
                transparency
            )
                value += 1
                local fanBeam = fanParts[value]
                if not (fanBeam and fanBeam.Parent) then
                    fanBeam = Instance.new("Part")
                    fanBeam.Name = "fanBeam"
                    fanBeam.Anchored = true
                    fanBeam.CanCollide = false
                    fanBeam.CanQuery = false
                    fanBeam.CanTouch = false
                    fanBeam.CastShadow = false
                    fanBeam.Material = Enum.Material.Neon
                    fanBeam.Parent = helper21()
                    fanParts[value] = fanBeam
                end
                fanBeam.Size = Vector3.new(argument5, 0.2, argument6)
                fanBeam.Color = color
                fanBeam.Transparency = transparency
                fanBeam.CFrame = CFrame.lookAt(
                    Vector3.new(argument, value2, argument2),
                    Vector3.new(argument + argument3, value2, argument2 + argument4)
                )
            end
            if value2 then
                local arenaCentre = hazardReader.arenaCentre
                local value3 = config.odinRuneStand ~= false
                        and arenaCentre
                        and context.OD.runeR
                        and context.OD.runeR()
                    or nil
                if value3 and config.drawRuneRing ~= false then
                    local value4 = config.runeRingSegments or 48
                    for index = 0, value4 - 1, 1 do
                        local value5, value6 =
                            6.283185307179586 * index / value4, 6.283185307179586 * (index + 1) / value4
                        local value7, value8, value9, value10 =
                            arenaCentre.X + math.cos(value5) * value3,
                            arenaCentre.Z + math.sin(value5) * value3,
                            arenaCentre.X + math.cos(value6) * value3,
                            arenaCentre.Z + math.sin(value6) * value3
                        value5 = math.sqrt((value9 - value7) ^ 2 + (value10 - value8) ^ 2)
                        if value5 > 0.05 then
                            helper19(
                                (value7 + value9) * 0.5,
                                (value8 + value10) * 0.5,
                                value9 - value7,
                                value10 - value8,
                                0.3,
                                value5 + 0.1,
                                config.colorRuneRing or Color3.fromRGB(255, 205, 90),
                                0.35
                            )
                        end
                    end
                end
                value3 = context.OD.fanRedNow(now)
                if value3 then
                    helper19(
                        value3.x,
                        value3.z,
                        value3.ax,
                        value3.az,
                        value3.halfW * 2,
                        value3.halfL * 2,
                        config.colorFanRed or Color3.fromRGB(255, 45, 45),
                        0.4
                    )
                end
                value3 = context.OD.fanGreenNow(now)
                if value3 then
                    helper19(
                        value3.x,
                        value3.z,
                        value3.ax,
                        value3.az,
                        value3.halfW * 2,
                        value3.halfL * 2,
                        config.colorFanGreen or Color3.fromRGB(60, 235, 95),
                        0.4
                    )
                end
            end
        end
        local value11, value12 = #fanParts, value + 1
        for index2 = value11, value12, -1 do
            if fanParts[index2] then
                fanParts[index2]:Destroy()
            end
            fanParts[index2] = nil
        end
    end
    local function helper25()
        local orbParts = sharedValue.orbParts or {}
        sharedValue.orbParts = orbParts
        local value = 0
        local value2 = runtimeState.orbitLive
        if
            config.visuals ~= false
            and config.drawOrbit ~= false
            and value2
            and value2.x
            and value2.z
            and value2.R
            and os.clock() - (value2.at or 0) < 0.5
        then
            local n, n, value3 = context.character()
            local value4 = value3 and value3.Position.Y - 2.3 or nil
            if value4 then
                local function helper19()
                    value += 1
                    local orbitRing = orbParts[value]
                    if not (orbitRing and orbitRing.Parent) then
                        orbitRing = Instance.new("Part")
                        orbitRing.Name = "orbitRing"
                        orbitRing.Anchored = true
                        orbitRing.CanCollide = false
                        orbitRing.CanQuery = false
                        orbitRing.CanTouch = false
                        orbitRing.CastShadow = false
                        orbitRing.Material = Enum.Material.Neon
                        orbitRing.Parent = helper21()
                        orbParts[value] = orbitRing
                    end
                    return orbitRing
                end
                local function helper26(
                    argument,
                    argument2,
                    argument3,
                    argument4,
                    argument5,
                    argument6,
                    argument7
                )
                    if argument then
                        if argument2 then
                            if argument3 then
                                if not (argument3 > 0.5) then
                                    return
                                end
                            else
                                return
                            end
                        else
                            return
                        end
                    else
                        return
                    end
                    for index = 0, argument7 - 1, 1 do
                        local value5, value6 =
                            6.283185307179586 * index / argument7, 6.283185307179586 * (index + 1) / argument7
                        local value7, value8, value9, value10 =
                            argument + math.cos(value5) * argument3,
                            argument2 + math.sin(value5) * argument3,
                            argument + math.cos(value6) * argument3,
                            argument2 + math.sin(value6) * argument3
                        helper3(
                            helper19(),
                            argument5,
                            0.2,
                            math.sqrt((value9 - value7) ^ 2 + (value10 - value8) ^ 2) + 0.05,
                            argument4,
                            argument6,
                            CFrame.lookAt(
                                Vector3.new((value7 + value9) * 0.5, value4, (value8 + value10) * 0.5),
                                Vector3.new(value9, value4, value10)
                            )
                        )
                    end
                end
                local value11, value12 =
                    value2.mode == "gather" and Color3.fromRGB(255, 160, 50) or Color3.fromRGB(185, 105, 255),
                    value2.Reff or value2.R
                helper26(value2.x, value2.z, value12, value11, 0.5, 0.1, config.orbitRingSegments or 36)
                if value2.Reff then
                    if value2.Reff < value2.R - 0.5 then
                        helper26(
                            value2.x,
                            value2.z,
                            value2.R,
                            value11,
                            0.25,
                            0.65,
                            config.orbitRingSegments or 36
                        )
                    end
                end
                helper26(value2.x, value2.z, value2.sr, Color3.fromRGB(255, 255, 255), 0.25, 0.5, 24)
                helper26(value2.ax, value2.az, value2.ar, Color3.fromRGB(255, 230, 60), 0.3, 0.25, 24)
                helper3(helper19(), 0.6, 4, 0.6, value11, 0.1, CFrame.new(value2.x, value4 + 2, value2.z))
            end
        end
        local value13, value14 = runtimeState.gsPlanPath, runtimeState.gsFwdPath
        value13 = if value14
            then if value14.pts
                then if os.clock() - (value14.at or 0) < (config.gsFwdDrawHold or 4)
                    then if config.gsFwdDrawOwn ~= false then value14 else value13
                    else value13
                else value13
            else value13
        local value15, value16 = config.visuals ~= false
            and config.drawOrbit ~= false
            and value13
            and value13.pts
        if value15 then
            local now, value17 = os.clock(), value13.at
            local value18, value19 = now - (value17 or 0), value13 == value14 and (config.gsFwdDrawHold or 4)
            value16 = value18 < (value19 or config.orbitDrawHold or 1.5)
        else
            value16 = value15
        end
        if value16 then
            value15 = value13.pts
            value2 = #value15
            for index2 = 1, value2, 1 do
                local vector, vector2 = value15[index2], value15[index2 % #value15 + 1]
                value14 = math.sqrt((vector2.X - vector.X) ^ 2 + (vector2.Z - vector.Z) ^ 2)
                if value14 > 0.05 and not (value13.cut and value13.cut[index2]) then
                    value += 1
                    local orbitRing2 = orbParts[value]
                    if not (orbitRing2 and orbitRing2.Parent) then
                        orbitRing2 = Instance.new("Part")
                        orbitRing2.Name = "orbitRing"
                        orbitRing2.Anchored = true
                        orbitRing2.CanCollide = false
                        orbitRing2.CanQuery = false
                        orbitRing2.CanTouch = false
                        orbitRing2.CastShadow = false
                        orbitRing2.Material = Enum.Material.Neon
                        orbitRing2.Parent = helper21()
                        orbParts[value] = orbitRing2
                    end
                    local value20 = vector.Y - 2.3
                    helper3(
                        orbitRing2,
                        0.5,
                        0.2,
                        value14 + 0.05,
                        Color3.fromRGB(255, 215, 40),
                        0.1,
                        CFrame.lookAt(
                            Vector3.new((vector.X + vector2.X) * 0.5, value20, (vector.Z + vector2.Z) * 0.5),
                            Vector3.new(vector2.X, value20, vector2.Z)
                        )
                    )
                end
            end
            local orbitOutline = value15[1]
                and (
                    value13.wall and config.drawWallLine ~= false
                    or value13.nodes and config.drawWrapNodes ~= false
                )
            if orbitOutline then
                local value21 = value15[1].Y - 2.3
                local function helper27(
                    argument,
                    argument2,
                    argument3,
                    argument4,
                    argument5,
                    argument6,
                    name2,
                    argument7
                )
                    local value5, value6 =
                        argument7 or value21,
                        math.sqrt((argument3 - argument) ^ 2 + (argument4 - argument2) ^ 2)
                    if value6 < 0.05 then
                        return
                    end
                    value += 1
                    argument7 = orbParts[value]
                    if not (argument7 and argument7.Parent) then
                        argument7 = Instance.new("Part")
                        argument7.Anchored = true
                        argument7.CanCollide = false
                        argument7.CanQuery = false
                        argument7.CanTouch = false
                        argument7.CastShadow = false
                        argument7.Material = Enum.Material.Neon
                        argument7.Parent = helper21()
                        orbParts[value] = argument7
                    end
                    if argument7.Name ~= name2 then
                        argument7.Name = name2
                    end
                    helper3(
                        argument7,
                        argument5,
                        0.25,
                        value6 + 0.05,
                        argument6,
                        0.1,
                        CFrame.lookAt(
                            Vector3.new((argument + argument3) * 0.5, value5, (argument2 + argument4) * 0.5),
                            Vector3.new(argument3, value5, argument4)
                        )
                    )
                end
                if value13.wall and config.drawWallLine ~= false then
                    for index3, entry in ipairs(value13.wall) do
                        helper27(
                            entry[1],
                            entry[2],
                            entry[3],
                            entry[4],
                            0.4,
                            Color3.fromRGB(165, 70, 255),
                            "orbitWallLine",
                            entry[5] and entry[5] + 0.7 or nil
                        )
                    end
                end
                if value13.nodes and config.drawWrapNodes ~= false then
                    for index4, node in ipairs(value13.nodes) do
                        helper27(
                            node[1] - 0.8,
                            node[2],
                            node[1] + 0.8,
                            node[2],
                            1.6,
                            Color3.fromRGB(255, 215, 40),
                            "orbitNode"
                        )
                    end
                end
            end
            if value13.outl and config.drawWrapOutlines ~= false and value15[1] then
                local value22, iterateArray, outl = value15[1].Y - 2.3, ipairs, value13.outl
                for key, entry2 in iterateArray(outl) do
                    key = #entry2
                    for index5 = 1, key, 1 do
                        local value23, value24 = entry2[index5], entry2[index5 % #entry2 + 1]
                        index5 = math.sqrt((value24[1] - value23[1]) ^ 2 + (value24[2] - value23[2]) ^ 2)
                        if index5 > 0.05 then
                            value += 1
                            orbitOutline = orbParts[value]
                            if not (orbitOutline and orbitOutline.Parent) then
                                orbitOutline = Instance.new("Part")
                                orbitOutline.Name = "orbitOutline"
                                orbitOutline.Anchored = true
                                orbitOutline.CanCollide = false
                                orbitOutline.CanQuery = false
                                orbitOutline.CanTouch = false
                                orbitOutline.CastShadow = false
                                orbitOutline.Material = Enum.Material.Neon
                                orbitOutline.Parent = helper21()
                                orbParts[value] = orbitOutline
                            end
                            helper3(
                                orbitOutline,
                                0.4,
                                0.2,
                                index5 + 0.05,
                                Color3.fromRGB(165, 70, 255),
                                0.1,
                                CFrame.lookAt(
                                    Vector3.new(
                                        (value23[1] + value24[1]) * 0.5,
                                        value22,
                                        (value23[2] + value24[2]) * 0.5
                                    ),
                                    Vector3.new(value24[1], value22, value24[2])
                                )
                            )
                        end
                    end
                end
            end
            if config.drawOrbitArrow ~= false and value13.i0 and value13.dir and #value15 >= 3 then
                local color = Color3.fromRGB(255, 255, 255)
                local function helper28(vector3, vector4, argument)
                    local value5 = math.sqrt((vector4.X - vector3.X) ^ 2 + (vector4.Z - vector3.Z) ^ 2)
                    if value5 < 0.05 then
                        return
                    end
                    value += 1
                    local orbitArrow = orbParts[value]
                    if not (orbitArrow and orbitArrow.Parent) then
                        orbitArrow = Instance.new("Part")
                        orbitArrow.Name = "orbitArrow"
                        orbitArrow.Anchored = true
                        orbitArrow.CanCollide = false
                        orbitArrow.CanQuery = false
                        orbitArrow.CanTouch = false
                        orbitArrow.CastShadow = false
                        orbitArrow.Material = Enum.Material.Neon
                        orbitArrow.Parent = helper21()
                        orbParts[value] = orbitArrow
                    end
                    local value6 = vector3.Y - 2.05
                    helper3(
                        orbitArrow,
                        argument,
                        0.3,
                        value5 + 0.05,
                        color,
                        0,
                        CFrame.lookAt(
                            Vector3.new((vector3.X + vector4.X) * 0.5, value6, (vector3.Z + vector4.Z) * 0.5),
                            Vector3.new(vector4.X, value6, vector4.Z)
                        )
                    )
                end
                local value25, value26, value27, value28 = value13.i0, 0
                for index6 = 1, #value15, 1 do
                    index6 = (value25 - 1 + value13.dir) % #value15 + 1
                    if value15[value25] then
                        if not value15[index6] then
                            break
                        end
                    else
                        break
                    end
                    if value13.cut then
                        if value13.cut[value13.dir > 0 and value25 or index6] then
                            break
                        end
                    end
                    helper28(value15[value25], value15[index6], 0.9)
                    value26 += math.sqrt(
                        (value15[index6].X - value15[value25].X) ^ 2
                            + (value15[index6].Z - value15[value25].Z) ^ 2
                    )
                    value27, value28 = value15[value25], value15[index6]
                    if value26 >= (config.orbitArrowLen or 16) then
                        value25 = index6
                        break
                    end
                    value25 = index6
                end
                if value27 and value28 then
                    local value29, value30 = value28.X - value27.X, value28.Z - value27.Z
                    orbitOutline = math.sqrt(value29 * value29 + value30 * value30)
                    if orbitOutline > 0.01 then
                        value29 /= orbitOutline
                        value30 /= orbitOutline
                        local value31 = { 1, -1 }
                        for index7, entry3 in ipairs(value31) do
                            index7 = math.rad(150 * entry3)
                            local value32, value33 =
                                value29 * math.cos(index7) - value30 * math.sin(index7),
                                value29 * math.sin(index7) + value30 * math.cos(index7)
                            helper28(
                                value28,
                                Vector3.new(value28.X + value32 * 4.5, value28.Y, value28.Z + value33 * 4.5),
                                0.9
                            )
                        end
                    end
                end
            end
        end
        value2, value15 = #orbParts, value + 1
        for index8 = value2, value15, -1 do
            value16 = orbParts[index8]
            if value16 and value16.Parent and index8 <= (config.orbitPartsKeep or 400) then
                if value16.Transparency < 1 then
                    value16.Transparency = 1
                    value14 = sharedValue2[value16]
                    if value14 then
                        value14.tr = 1
                    end
                end
            else
                if value16 then
                    value16:Destroy()
                end
                orbParts[index8] = nil
            end
        end
    end
    context.DEV_VIS_KEYS = {
        "visuals",
        "showHitboxes",
        "labelHazards",
        "labelUnknown",
        "drawAbility",
        "drawAoe",
        "drawAoeScan",
        "drawBubble",
        "drawGroups",
        "drawHazards",
        "drawLeads",
        "drawNoGo",
        "drawPath",
        "drawScan",
        "drawSpots",
        "drawTarget",
        "drawWaypoints",
        "drawMissileLines",
        "drawBlueRails",
        "drawBlueBeams",
        "drawProjected",
        "drawLanding",
        "groupOrbs",
        "groupNumbers",
        "aoeMarker",
        "ghostDraw",
        "drawFanBeam",
        "drawOrbit",
        "drawOrbitArrow",
    }
    context.DEV_VIS_FILE = "HarvardLabs/data/devvis.json"
    local function helper29()
        if context.devPrefs then
            return context.devPrefs
        end
        local devPrefs = {}
        pcall(function()
            if isfile then
                if isfile(context.DEV_VIS_FILE) then
                    local value = getService("HttpService"):JSONDecode(readfile(context.DEV_VIS_FILE))
                    if type(value) == "table" then
                        devPrefs = value
                    end
                end
            end
        end)
        context.devPrefs = devPrefs
        return devPrefs
    end
    context.devVisOn = false
    if not context.devVisOn then
        context.NOVIS = true
    end
    context.devVisApply = function(argument)
        if not context.devVisOn then
            return
        end
        context.NOVIS = false
        context.devSaved = context.devSaved or {}
        for index, key in ipairs(context.DEV_VIS_KEYS) do
            if argument or context.devSaved[key] == nil then
                context.devSaved[key] = { v = config[key] }
            end
            config[key] = true
            if key == "labelHazards" or key == "labelUnknown" then
                if config.devTitles ~= true then
                    config[key] = false
                end
            end
            if key == "drawAoeScan" then
                if config.devAoeScan ~= true then
                    config[key] = false
                end
            end
            if key == "aoeMarker" or key == "drawAoe" or key == "drawLanding" then
                if config.devAoeScan ~= true then
                    config[key] = false
                end
            end
        end
    end
    context.devVisSet = function(argument, argument2)
        config[argument] = argument2 == true
        if argument == "visuals" then
            if argument2 ~= true then
                if context.clearDrawing then
                    pcall(context.clearDrawing)
                end
            end
        end
    end
    context.devVis = function(argument)
        context.devVisOn = argument ~= false
        if context.devVisOn then
            context.devVisApply(false)
        else
            for key, entry in pairs(context.devSaved or {}) do
                config[key] = entry.v
            end
            context.devSaved = nil
            context.NOVIS = true
            if context.clearDrawing then
                pcall(context.clearDrawing)
            end
        end
        local value = helper29()
        value._on = context.devVisOn
        pcall(function()
            if context.ensureFolders then
                context.ensureFolders()
            end
            writefile(context.DEV_VIS_FILE, getService("HttpService"):JSONEncode(value))
        end)
        return context.devVisOn
    end
    if context.devVisOn then
        pcall(context.devVisApply, true)
    end
    local function helper30(argument)
        if config.aoeMarkerFast ~= false then
            if not context.NOVIS then
                if argument - (sharedValue.lastMark or 0) >= (config.aoeMarkerEvery or 0.1) then
                    sharedValue.lastMark = argument
                    pcall(helper17)
                end
            end
        end
        if argument - sharedValue.lastDraw < (config.drawEvery or 0.15) then
            return
        end
        sharedValue.lastDraw = argument
        if context.NOVIS then
            if sharedValue.folder then
                context.clearDrawing()
            elseif sharedValue.mlFolder then
                context.clearDrawing()
            end
            return
        end
        local function drawTimed(argument2, argument3, ...)
            local now = os.clock()
            pcall(argument3, ...)
            if runtimeState.perf then
                if runtimeState.perf.cur then
                    if context.perfAdd then
                        context.perfAdd(runtimeState.perf.cur.fns, argument2, os.clock() - now)
                    end
                end
            end
        end
        context.drawTimed = drawTimed
        drawTimed = if context.DEV
            then drawTimed
            else function(A, argument2, ...)
                pcall(argument2, ...)
            end
        drawTimed("draw.groupOrb", helper20)
        drawTimed("draw.aoeMarker", helper17)
        drawTimed("draw.aoeScan", helper18)
        drawTimed("draw.missileLine", drawMissileLines)
        drawTimed("draw.blueRail", helper22)
        drawTimed("draw.fanBeam", helper24)
        drawTimed("draw.bobRail", helper23)
        drawTimed("draw.orbitRing", helper25)
        if config.visuals == false then
            if sharedValue.folder then
                context.clearDrawing()
            end
            return
        end
        local value = os.clock()
        if argument - sharedValue.lastSweep > 3 then
            sharedValue.lastSweep = argument
            for index, child in ipairs(visualRoot():GetChildren()) do
                if child.Name ~= "Hazards" then
                    if child.Name ~= "streamer" then
                        if child.Name ~= "GroupOrbs" then
                            if child.Name ~= "AoEMarker" then
                                if child.Name ~= "MissileLines" then
                                    child:Destroy()
                                end
                            end
                        end
                    end
                end
            end
            if sharedValue.folder and sharedValue.folder.Parent then
                local value2 = {}
                for key, part in pairs(sharedValue.parts) do
                    value2[part] = true
                end
                if config.drawSweepKeepOwn ~= false then
                    local iterateArray, value3 =
                        ipairs, {
                            sharedValue.ring,
                            sharedValue.groups,
                            sharedValue.nodes,
                            sharedValue.spots,
                            sharedValue.scan,
                            sharedValue.tags,
                            sharedValue.wallTags,
                            sharedValue.boxPool or {},
                        }
                    for key2, entry in iterateArray(value3) do
                        for key3, entry2 in pairs(entry) do
                            value2[entry2] = true
                        end
                    end
                    if sharedValue.aoe then
                        value2[sharedValue.aoe] = true
                    end
                    if sharedValue.target then
                        value2[sharedValue.target] = true
                    end
                end
                local orphans = {}
                for index2, child2 in ipairs(sharedValue.folder:GetChildren()) do
                    if not value2[child2] then
                        orphans[#orphans + 1] = child2
                    end
                end
                sharedValue.orphans = orphans
                sharedValue.orphanPeak = #orphans
            end
        end
        if sharedValue.orphans and #sharedValue.orphans > 0 then
            for index3 = 1, config.drawSweepPerTick or 12, 1 do
                index3 = table.remove(sharedValue.orphans)
                if not index3 then
                    break
                end
                if index3.Parent then
                    index3:Destroy()
                end
            end
        end
        if runtimeState.perf then
            if runtimeState.perf.cur then
                if context.perfAdd then
                    context.perfAdd(runtimeState.perf.cur.fns, "draw.sweep", os.clock() - value)
                end
            end
        end
        local j, j, visAt = context.character()
        local vector, success, value4 = visAt and visAt.Position, {}, 0
        visAt = os.clock()
        if config.drawHazards then
            local value5, value6 = os.clock(), hazards(argument, sharedValue.list)
            if runtimeState.perf then
                if runtimeState.perf.cur then
                    if context.perfAdd then
                        context.perfAdd(runtimeState.perf.cur.fns, "draw.hazardsRead", os.clock() - value5)
                    end
                end
            end
            if context.gsSpentBoxes then
                drawTimed("draw.gsSpentBoxes", context.gsSpentBoxes, argument, value6)
            end
            if context.gsGreenDraw then
                drawTimed("draw.gsGreenDraw", context.gsGreenDraw, argument, value6)
            end
            if hazardReader.gsLaneGhosts then
                for index4, gsLaneGhost in ipairs(hazardReader.gsLaneGhosts) do
                    value6[#value6 + 1] = gsLaneGhost
                end
            end
            for index5, entry3 in
                ipairs(if vector and config.drawNearestFirst ~= false
                    then if pcall(table.sort, value6, function(zone, zone2)
                            local value7, value8, value9, value10 =
                                zone.moving and zone.ox or zone.cx or 0,
                                zone.moving and zone.oz or zone.cz or 0,
                                zone2.moving and zone2.ox or zone2.cx or 0,
                                zone2.moving and zone2.oz or zone2.cz or 0
                            return (value7 - vector.X) ^ 2 + (value8 - vector.Z) ^ 2
                                < (value9 - vector.X) ^ 2 + (value10 - vector.Z) ^ 2
                        end)
                        then value6
                        else hazards(argument, sharedValue.list)
                    else value6)
            do
                repeat
                    index5, value =
                        entry3.moving and entry3.ox or entry3.cx, entry3.moving and entry3.oz or entry3.cz
                    if
                        value4 < (config.drawMaxBoxes or 110)
                        and argument <= (entry3.untilAt or -math.huge) + 0.05
                        and (
                            not vector
                            or entry3.drawAlways
                            or (index5 - vector.X) ^ 2 + (value - vector.Z) ^ 2 < 16900
                        )
                    then
                        if context.drawSkipBox then
                            if context.drawSkipBox(entry3) then
                                value5 = sharedValue.parts[entry3]
                                if value5 then
                                    helper13(value5)
                                    sharedValue.parts[entry3] = nil
                                end
                                break
                            end
                        end
                        value4 += 1
                        local value11 = sharedValue.parts[entry3]
                        if if value11 then not value11.Parent else not value11 then
                            value11 = helper12()
                            sharedValue.parts[entry3] = value11
                        end
                        success[entry3] = true
                        if
                            entry3.noGo and config.drawNoGo == false
                            or entry3.noDraw
                            or entry3.gsNoDraw
                            or (
                                    entry3.gsTrue
                                    or entry3.gsSq
                                    or context.gsIsBlockBox and context.gsIsBlockBox(entry3)
                                )
                                and config.gsDrawBlocks ~= true
                        then
                            local value12 = sharedValue.parts[entry3]
                            if value12 then
                                helper13(value12)
                                sharedValue.parts[entry3] = nil
                            end
                            break
                        end
                        if config.drawLeads == false then
                            if string.lower(tostring(entry3.name or "")):find("ahead", 1, true) then
                                local value13 = sharedValue.parts[entry3]
                                if value13 then
                                    helper13(value13)
                                    sharedValue.parts[entry3] = nil
                                end
                                break
                            end
                        end
                        local value14 = entry3.warn
                        if value14 == nil then
                            local moving = entry3.moving
                            value14 = if moving then not moving else argument < entry3.from
                        end
                        local drawPlain = entry3.drawPlain
                        if drawPlain == nil then
                            local value15 = string.lower(tostring(entry3.name or ""))
                            drawPlain = (
                                value15:find("crisscross", 1, true)
                                or value15:find("bigspike", 1, true)
                                or value15:find("seeking", 1, true)
                                or value15:find("thirdboss", 1, true) and value15:find("orb", 1, true)
                            )
                                    and true
                                or false
                            entry3.drawPlain = drawPlain
                        end
                        local value16, sweep =
                            helper14(value11, value14 and not drawPlain), value11:FindFirstChild("sweep")
                        if drawPlain then
                            local sweep2 = value11:FindFirstChild("sweep")
                            if sweep2 then
                                sweep2:Destroy()
                                sweep = nil
                            end
                        end
                        local value17 = (
                            entry3.slim and math.min(dangerGeometry.reach, entry3.slim)
                            or dangerGeometry.reach
                        )
                            + (entry3.slim and config.slimShoulder or config.dodgeShoulder)
                        if entry3.moving then
                            local value18 = entry3.offset
                                + entry3.speed * math.max(argument - entry3.pathStart, 0)
                            local value19, value20, value21 =
                                entry3.ox + entry3.dx * value18,
                                entry3.oz + entry3.dz * value18,
                                entry3.ground and vector and vector.Y - 2.4 or entry3.oy - entry3.halfH + 0.6
                            value11.Shape, value11.Size =
                                Enum.PartType.Block,
                                Vector3.new(
                                    (entry3.halfW - (entry3.pad or 0)) * 2,
                                    1,
                                    (entry3.halfL - (entry3.pad or 0)) * 2
                                )
                            value11.CFrame = CFrame.lookAt(
                                Vector3.new(value19, value21, value20),
                                Vector3.new(value19 + entry3.dx, value21, value20 + entry3.dz)
                            )
                            if value16 then
                                value16.Shape, value16.Size =
                                    value11.Shape,
                                    Vector3.new(
                                        value11.Size.X + value17 * 2,
                                        value11.Size.Y,
                                        value11.Size.Z + value17 * 2
                                    )
                            end
                            if entry3.r then
                                value11.Shape, value11.Size =
                                    Enum.PartType.Cylinder,
                                    Vector3.new(
                                        1,
                                        (entry3.r - (entry3.pad or 0)) * 2,
                                        (entry3.r - (entry3.pad or 0)) * 2
                                    )
                                value11.CFrame = CFrame.new(value19, value21, value20)
                                    * CFrame.Angles(0, 0, 1.5707963267948966)
                                if value16 then
                                    value16.Shape, value16.Size =
                                        value11.Shape,
                                        Vector3.new(
                                            1,
                                            value11.Size.Y + value17 * 2,
                                            value11.Size.Z + value17 * 2
                                        )
                                end
                            end
                            if entry3.kind == "part" or drawPlain then
                                if sweep then
                                    sweep:Destroy()
                                end
                            elseif config.drawLeads == false then
                                if sweep then
                                    sweep:Destroy()
                                end
                            else
                                local value22, value23 =
                                    sweep or (helper2(value11, "sweep", 0.88)),
                                    math.min(
                                        math.max(entry3.untilAt - argument, 0),
                                        entry3.horizon or config.laneHorizon
                                    )
                                value18 = math.max(math.min(entry3.speed * value23, 260), 1)
                                value23 = Vector3.new(
                                    value19 + entry3.dx * (entry3.halfL + value18 * 0.5),
                                    value21,
                                    value20 + entry3.dz * (entry3.halfL + value18 * 0.5)
                                )
                                value22.Size, value22.Color =
                                    Vector3.new(entry3.halfW * 2, 0.4, value18), config.colorSoon
                                value22.CFrame =
                                    CFrame.lookAt(value23, value23 + Vector3.new(entry3.dx, 0, entry3.dz))
                            end
                        else
                            local value24, value25 = 0, 0
                            if entry3.kind == "model" then
                                if context.BB then
                                    if context.BB.velocityOf then
                                        value24, value25 = context.BB.velocityOf(entry3, argument)
                                    end
                                end
                            end
                            local value26 = math.sqrt(value24 * value24 + value25 * value25)
                            if value26 > 2 and entry3.cx then
                                if config.drawLeads ~= false then
                                    local value27, value28, value29, value30, value31 =
                                        sweep or (helper2(value11, "sweep", 0.88)),
                                        value24 / value26,
                                        value25 / value26,
                                        math.max(math.min(value26 * (config.bubbleTrajLead or 1.2), 260), 1),
                                        entry3.r or math.min(entry3.ha or 3, entry3.hb or 3)
                                    local value32, value33 =
                                        entry3.r or math.max(
                                            math.abs(value28 * (entry3.ax or 0) + value29 * (entry3.az or 0))
                                                    * (entry3.ha or 0)
                                                + math.abs(
                                                        value28 * (entry3.bx or 0)
                                                            + value29 * (entry3.bz or 0)
                                                    )
                                                    * (entry3.hb or 0),
                                            1
                                        ),
                                        vector and vector.Y - 2.4 or entry3.cy - (entry3.hy or 1) + 0.6
                                    local value34 = Vector3.new(
                                        entry3.cx + value28 * (value32 + value30 * 0.5),
                                        value33,
                                        entry3.cz + value29 * (value32 + value30 * 0.5)
                                    )
                                    value27.Size, value27.Color =
                                        Vector3.new(value31 * 2, 0.4, value30), config.colorSoon
                                    value27.CFrame =
                                        CFrame.lookAt(value34, value34 + Vector3.new(value28, 0, value29))
                                elseif sweep then
                                    sweep:Destroy()
                                end
                            elseif sweep then
                                sweep:Destroy()
                            end
                            if entry3.cyl then
                                value11.Shape, value11.Size, value11.CFrame =
                                    Enum.PartType.Cylinder,
                                    Vector3.new(math.min(entry3.size.X, 1.5), entry3.size.Y, entry3.size.Z),
                                    entry3.cframe
                                if value16 then
                                    value16.Shape, value16.Size =
                                        value11.Shape,
                                        Vector3.new(
                                            value11.Size.X,
                                            value11.Size.Y + value17 * 2,
                                            value11.Size.Z + value17 * 2
                                        )
                                end
                            elseif entry3.round then
                                value11.Shape, value11.Size, value11.CFrame =
                                    Enum.PartType.Cylinder,
                                    Vector3.new(0.6, entry3.size.X, entry3.size.X),
                                    CFrame.new(entry3.cframe.Position) * CFrame.Angles(
                                        0,
                                        0,
                                        1.5707963267948966
                                    )
                                if value16 then
                                    value16.Shape, value16.Size =
                                        value11.Shape,
                                        Vector3.new(
                                            value11.Size.X,
                                            value11.Size.Y + value17 * 2,
                                            value11.Size.Z + value17 * 2
                                        )
                                end
                            elseif entry3.gsSq then
                                value11.Shape, value11.Size, value11.CFrame =
                                    Enum.PartType.Block,
                                    Vector3.new(entry3.size.X, 1.5, entry3.size.Z),
                                    entry3.cframe - Vector3.new(0, 0.4, 0)
                                if value16 then
                                    value16.Shape, value16.Size =
                                        value11.Shape,
                                        Vector3.new(
                                            value11.Size.X + value17 * 2,
                                            value11.Size.Y,
                                            value11.Size.Z + value17 * 2
                                        )
                                end
                            elseif entry3.gsTrue then
                                value11.Shape, value11.Size, value11.CFrame =
                                    Enum.PartType.Block, entry3.size, entry3.cframe
                                if value16 then
                                    value16.Shape, value16.Size =
                                        value11.Shape,
                                        Vector3.new(
                                            value11.Size.X + value17 * 2,
                                            value11.Size.Y,
                                            value11.Size.Z + value17 * 2
                                        )
                                end
                            else
                                value11.Shape, value11.Size, value11.CFrame =
                                    Enum.PartType.Block,
                                    Vector3.new(entry3.size.X, math.min(entry3.size.Y, 1.5), entry3.size.Z),
                                    entry3.cframe - Vector3.new(0, entry3.size.Y * 0.5 - 0.8, 0)
                                if value16 then
                                    value16.Shape, value16.Size =
                                        value11.Shape,
                                        Vector3.new(
                                            value11.Size.X + value17 * 2,
                                            value11.Size.Y,
                                            value11.Size.Z + value17 * 2
                                        )
                                end
                            end
                        end
                        value17 = runtimeState.gsRampTallX or 0
                        if value17 > 0 then
                            if not entry3.gsTrue then
                                if not entry3.gsSq then
                                    local value35 = entry3.moving and entry3.oy or entry3.cy
                                    if value35 then
                                        if value11.Shape == Enum.PartType.Cylinder then
                                            value11.Size =
                                                Vector3.new(value17 * 2, value11.Size.Y, value11.Size.Z)
                                        else
                                            value11.Size =
                                                Vector3.new(value11.Size.X, value17 * 2, value11.Size.Z)
                                        end
                                        value11.CFrame = value11.CFrame
                                            + Vector3.new(0, value35 - value11.Position.Y, 0)
                                    end
                                end
                            end
                        end
                        if value16 then
                            value16.CFrame = value11.CFrame
                        end
                        value17 = string.lower(tostring(entry3.name or ""))
                        value16 = entry3.gsColour
                            or entry3.attack and not (value17:find("secondboss", 1, true) and value17:find(
                                "orb",
                                1,
                                true
                            )) and context.attackColourNow()
                            or entry3.drawColour
                            or (
                                argument >= entry3.from and config.colorLive
                                or (
                                    entry3.from - argument <= config.dodgeLead and config.colorSoon
                                    or config.colorFloor
                                )
                            )
                        if config.hazardBabyBlue ~= false then
                            value16 = context.BABY_BLUE or Color3.fromHex("#89cff0")
                            context.BABY_BLUE = value16
                        end
                        if value11.Color ~= value16 then
                            value11.Color, value11.edge.Color3 = value16, value16
                        end
                        value11.Transparency = entry3.drawTransp
                            or (entry3.weight and 0.85 or config.hazardTransparency)
                        if value11.edge then
                            value17, value16 =
                                value11.edge, entry3.drawTransp and (config.gsGhostEdge or 0.75)
                            value17.Transparency = value16 or 0
                        end
                        value16 = value11.tag
                        value16.Enabled = config.labelHazards and not entry3.drawTransp
                        if value16.Enabled then
                            local text, name2 = value16.text, entry3.name
                            local value36, value37 =
                                name2 or "?",
                                argument > entry3.untilAt and "done"
                                    or (
                                        argument >= entry3.from and "live"
                                        or ("in %.1fs"):format(entry3.from - argument)
                                    )
                            text.Text = ("%s  %s"):format(value36, value37)
                        end
                    end
                until true
            end
        end
        for key4, part2 in pairs(sharedValue.parts) do
            if not success[key4] then
                helper13(part2)
                sharedValue.parts[key4] = nil
            end
        end
        if runtimeState.perf then
            if runtimeState.perf.cur then
                if context.perfAdd then
                    context.perfAdd(runtimeState.perf.cur.fns, "draw.boxes", os.clock() - visAt)
                end
            end
        end
        runtimeState.drawRestAt = os.clock()
        local value38 = 0
        local combatBrain = context.BR
        success, argument = pcall(function()
            if config.drawPath and combatBrain.waypoints then
                local iterateArray2, waypoints = ipairs, combatBrain.waypoints
                for key5, waypoint in iterateArray2(waypoints) do
                    local value7 = key5 == combatBrain.index
                    value38 += 1
                    helper9(
                        sharedValue.nodes,
                        value38,
                        value7 and Color3.fromRGB(120, 200, 255) or Color3.fromRGB(40, 90, 200),
                        value7 and 2.5 or 1.5,
                        waypoint + Vector3.new(0, 1.5, 0),
                        value7 and 0.1 or 0.4
                    )
                end
            end
            local value8 = context.PB
                and context.PB.boss
                and tostring(context.PB.boss):lower():find("champion", 1, true) ~= nil
            value8 = config.drawWaypoints ~= false and config.champWaypoints and value8
            if value8 then
                local iterateArray3, champWaypoints = ipairs, config.champWaypoints
                for key6, champWaypoint in iterateArray3(champWaypoints) do
                    for index6 = 0, 3, 1 do
                        value38 += 1
                        helper9(
                            sharedValue.nodes,
                            value38,
                            Color3.fromRGB(255, 210, 90),
                            2,
                            Vector3.new(champWaypoint[1], champWaypoint[2] + index6 * 3, champWaypoint[3]),
                            0.25
                        )
                    end
                end
            end
            local value9 = config.drawWaypoints ~= false
                and context.waypointSets
                and (
                    game:GetService("Workspace"):FindFirstChild("dungeon")
                    or game:GetService("Workspace"):FindFirstChild("Dungeon")
                )
            if value9 then
                local value10, value39 = context.waypointSets(), context.RT
                local vector2, iterateArray4, value40 =
                    value39 and value39.preWalk and value39.preWalk.active and value39.preWalkPoint or nil,
                    ipairs,
                    value10 or {}
                for key7, entry4 in iterateArray4(value40) do
                    if type(entry4) == "table" then
                        key7 = entry4.group
                        if type(key7) == "table" then
                            if key7[1] then
                                if key7[3] then
                                    value38 += 1
                                    helper9(
                                        sharedValue.nodes,
                                        value38,
                                        Color3.fromRGB(255, 140, 0),
                                        3,
                                        Vector3.new(key7[1], (key7[2] or 0) + 3, key7[3]),
                                        0.2
                                    )
                                end
                            end
                        end
                        value10, value39 = ipairs, entry4.points or {}
                        for key8, entry5 in value10(value39) do
                            if type(entry5) == "table" and entry5[1] and entry5[3] then
                                key8 = vector2 ~= nil
                                    and (vector2.X - entry5[1]) ^ 2 + (vector2.Z - entry5[3]) ^ 2 < 1
                                local value41 = key8 and 3 or 0
                                for index7 = 0, value41, 1 do
                                    value38 += 1
                                    helper9(
                                        sharedValue.nodes,
                                        value38,
                                        Color3.fromRGB(0, 255, 120),
                                        key8 and 2.2 or 2,
                                        Vector3.new(entry5[1], (entry5[2] or 0) + 1.2 + index7 * 3, entry5[3]),
                                        key8 and 0.1 or 0.3
                                    )
                                end
                            end
                        end
                        local iterateArray5, value42 =
                            ipairs, {
                                { entry4.home, Color3.fromRGB(255, 230, 60) },
                                {
                                    entry4.strike,
                                    Color3.fromRGB(255, 80, 220),
                                },
                            }
                        for key9, entry6 in iterateArray5(value42) do
                            local value43, value44 = entry6[1], entry6[2]
                            if type(value43) == "table" then
                                if value43[1] then
                                    if value43[3] then
                                        value38 += 1
                                        helper9(
                                            sharedValue.nodes,
                                            value38,
                                            value44,
                                            2.5,
                                            Vector3.new(value43[1], (value43[2] or 0) + 1.2, value43[3]),
                                            0.2
                                        )
                                        if value43[4] then
                                            if value43[5] then
                                                if
                                                    value43[4] * value43[4] + value43[5] * value43[5] > 0.01
                                                then
                                                    value38 += 1
                                                    helper9(
                                                        sharedValue.nodes,
                                                        value38,
                                                        value44,
                                                        1.4,
                                                        Vector3.new(
                                                            value43[1] + value43[4] * 6,
                                                            (value43[2] or 0) + 1.2,
                                                            value43[3] + value43[5] * 6
                                                        ),
                                                        0.35
                                                    )
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
            helper10(sharedValue.nodes, value38)
            value38 = 0
            if config.drawSpots and dangerGeometry.origin then
                local origin, dodgeMoveAt, iterateArray6, cands =
                    dangerGeometry.origin, config.dodgeMoveAt, ipairs, dangerGeometry.cands
                for key10, cand in iterateArray6(cands) do
                    value38 += 1
                    value9, key10 = nil
                    if cand.blocked then
                        value9, key10 = Color3.fromRGB(120, 122, 132), 0.55
                    else
                        if cand.danger >= 0.999 then
                            local colorLive, value45 = config.colorLive, 0.2
                            value9, key10 = colorLive, value45
                        else
                            local value46, value47
                            if cand.endDanger >= 0.999 then
                                value46, value47 = config.colorLive, 0.2
                                value9, key10 = value46, value47
                            else
                                if cand.padded then
                                    value46, value47 = Color3.fromRGB(255, 140, 0), 0.2
                                    value9, key10 = value46, value47
                                else
                                    if cand.danger >= dodgeMoveAt then
                                        local colorSoon, value48 = config.colorSoon, 0.2
                                        value9, key10 = colorSoon, value48
                                    else
                                        local value49, value50
                                        if cand.endDanger >= dodgeMoveAt then
                                            value49, value50 = config.colorSoon, 0.2
                                            value9, key10 = value49, value50
                                        else
                                            if cand.safe then
                                                value49, value50 = config.colorFloor, 0.2
                                                value9, key10 = value49, value50
                                            else
                                                value49, value50 = config.colorFloor, 0.35
                                                value9, key10 = value49, value50
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    helper9(
                        sharedValue.spots,
                        value38,
                        value9,
                        1.2,
                        cand.valid and Vector3.new(cand.x, cand.y + 0.6, cand.z)
                            or Vector3.new(origin.X + cand.ox, origin.Y - 2.4, origin.Z + cand.oz),
                        key10
                    )
                end
            end
            helper10(sharedValue.spots, value38)
            value38 = 0
            if config.drawScan and context.BB and context.BB.scanNodes and vector then
                local value51, value52 = vector.Y - 2.4
                value9 = config.drawScanMax or 60
                if value9 > 0 then
                    if (context.BB.scanN or 0) > value9 then
                        local value53 = {}
                        for index8 = 1, context.BB.scanN, 1 do
                            local value54 = context.BB.scanNodes[index8]
                            if value54 then
                                value53[#value53 + 1] =
                                    { index8, (value54.x - vector.X) ^ 2 + (value54.z - vector.Z) ^ 2 }
                            end
                        end
                        table.sort(value53, function(argument2, argument3)
                            return argument2[2] < argument3[2]
                        end)
                        local value55 = {}
                        for index9 = 1, math.min(value9, #value53), 1 do
                            value55[value53[index9][1]] = true
                        end
                        value52 = value55
                    end
                end
                local value56 = context.BB.scanN or 0
                for index10 = 1, value56, 1 do
                    local value57 = context.BB.scanNodes[index10]
                    local value58 = value57 and (if value52 then value52[index10] else not value52)
                    if value58 then
                        value38 += 1
                        index10 = value57.v == 0 and config.colorFloor
                            or value57.v == 1 and config.colorSoon
                            or value57.v == 2 and config.colorLive
                            or value57.v == 4 and Color3.fromRGB(255, 140, 0)
                            or Color3.fromRGB(120, 122, 132)
                        helper9(
                            sharedValue.scan,
                            value38,
                            index10,
                            1,
                            Vector3.new(value57.x, value51, value57.z),
                            value57.v == 4 and 0.45 or 0.25
                        )
                    end
                end
                value56 = context.BB.goal
                if value56 then
                    if value56.p then
                        value38 += 1
                        helper9(
                            sharedValue.scan,
                            value38,
                            Color3.fromRGB(80, 160, 255),
                            2.4,
                            Vector3.new(value56.p.X, value51 + 0.6, value56.p.Z),
                            0.1
                        )
                    end
                end
            end
            helper10(sharedValue.scan, value38)
        end)
        if not success then
            context.RT.lastError, context.RT.lastErrorAt = "draw routing: " .. tostring(argument), os.clock()
        end
        value38 = 0
        if config.drawSpots then
            success, value = ipairs, dangerGeometry.cands
            for key11, entry7 in success(value) do
                if entry7.blocked and entry7.blocker and entry7.blocker.Parent and value38 < 8 then
                    value38 += 1
                    value4 = sharedValue.wallTags[value38]
                    if if value4 then not value4.Parent else not value4 then
                        value4 = helper11(helper(), Color3.fromRGB(255, 120, 120))
                        sharedValue.wallTags[value38] = value4
                    end
                    value4.Adornee, value4.Enabled, value4.text.Text =
                        entry7.blocker, true, "wall: " .. entry7.blocker.Name
                end
            end
        end
        helper10(sharedValue.wallTags, value38)
        value38 = 0
        if config.labelUnknown and vector then
            visAt, argument, value4, success = os.clock(), {}, ipairs, hazardReader.spawns
            for key12, entry8 in value4(success) do
                value = entry8.inst
                key12 = value:IsA("BasePart") and value
                    or (value.PrimaryPart or value:FindFirstChildWhichIsA("BasePart"))
                local value59 = key12
                    and key12.Parent
                    and (key12.Position - vector).Magnitude < 80
                    and key12:IsDescendantOf(Workspace)
                if config.labelGone ~= false and value59 and visAt - (entry8.visAt or -1) >= 0.25 then
                    entry8.visAt = visAt
                    local top = value
                    while top.Parent and top.Parent ~= Workspace do
                        top = top.Parent
                    end
                    entry8.top = top
                    local seen = argument[top]
                    if seen == nil then
                        seen = false
                        if top.Parent ~= Workspace then
                            seen = false
                        else
                            if top:IsA("BasePart") then
                                seen = top.Transparency < 0.99
                            else
                                local descendants = top:GetDescendants()
                                if #descendants > (config.gsLabelDescMax or 400) then
                                    seen = true
                                else
                                    for index11, descendant in ipairs(descendants) do
                                        if descendant:IsA("BasePart") and descendant.Transparency < 0.99 then
                                            seen = true
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        argument[top] = seen
                    end
                    entry8.seen = seen
                end
                if
                    value59
                    and not hazardReader.models[value]
                    and not (hazardReader.parts and hazardReader.parts[value])
                    and not (hazardReader.gsIgnored and hazardReader.gsIgnored[value])
                    and not (config.labelGone ~= false and entry8.seen == false)
                then
                    value38 += 1
                    local value60 = sharedValue.tags[value38]
                    if if value60 then not value60.Parent else not value60 then
                        value60 = helper11(helper(), Color3.fromRGB(200, 200, 210))
                        sharedValue.tags[value38] = value60
                    end
                    value60.Adornee = key12
                    value60.Enabled = true
                    local value61 = ""
                    if value:IsA("Model") then
                        local value62 = {}
                        for index12, child3 in ipairs(value:GetChildren()) do
                            if child3:IsA("BasePart") then
                                if #value62 < 3 then
                                    value62[#value62 + 1] = child3.Name
                                end
                            end
                        end
                        value61 = #value62 > 0 and " [" .. table.concat(value62, ", ") .. "]" or ""
                    end
                    value60.text.Text = ("? %s (%s)%s"):format(value.Name, value.ClassName, value61)
                    local top2 = entry8.top
                    if config.labelGone ~= false then
                        if typeof(top2) == "Instance" then
                            if top2 ~= value then
                                local value63 = context.GS_PIECE_NAMES[string.lower(top2.Name)]
                                value60.text.Text = value63 and value63 .. " (piece)"
                                    or ("? %s (%s)"):format(top2.Name, value.Name)
                            end
                        end
                    end
                end
            end
        end
        helper10(sharedValue.tags, value38)
        value38 = 0
        success = context.BR.aim
        if config.drawAbility and vector then
            value = context.abilityReach and context.abilityReach()
                or (
                    hazardReader.abilityRange
                        and math.min(hazardReader.abilityRange, config.autoStandoffMax)
                    or config.abilityRadius
                )
            value38 = helper7(
                sharedValue.ring,
                value38,
                config.colorAbility,
                vector,
                value,
                vector.Y - 2.4,
                0.5,
                0.3
            )
        end
        if config.drawProjected ~= false and vector and context.BB and context.BB.mov then
            value, argument = config.bubbleTrajLead or 1.2, #context.BB.mov
            for index13 = 1, argument, 1 do
                visAt = context.BB.mov[index13]
                if
                    visAt
                    and visAt.moving
                    and (visAt.speed or 0) >= (config.passThroughSpeed or 8)
                    and visAt.ox
                    and visAt.dx
                then
                    local value64, value65, value66 =
                        visAt.ox + visAt.dx * visAt.speed * value,
                        visAt.oz + visAt.dz * visAt.speed * value,
                        visAt.r or math.max(visAt.ha or 3, visAt.hb or 3)
                    value38 = helper7(
                        sharedValue.ring,
                        value38,
                        Color3.fromRGB(80, 255, 120),
                        Vector3.new(value64, vector.Y, value65),
                        value66,
                        vector.Y - 2.2,
                        0.45,
                        0.35
                    )
                end
            end
        end
        if
            config.drawLanding ~= false
            and vector
            and context.aoeLanding
            and not (context.aoeShapeNow ~= nil and select(3, context.aoeShapeNow()) ~= nil)
        then
            visAt, value4 = context.aoeLanding()
            argument = context.character and select(3, context.character()) or nil
            if visAt and value4 and argument then
                value = argument.CFrame.LookVector
                local value67, value68, value69 =
                    Vector3.new(value.X, 0, value.Z),
                    context.BR
                            and (context.BR.aim or context.BR.target and context.BR.target.root and context.BR.target.root.Parent and context.BR.target.root.Position)
                        or nil
                if value68 then
                    local value70, value71 = value68.X - vector.X, value68.Z - vector.Z
                    local value72 = math.sqrt(value70 * value70 + value71 * value71)
                    if value72 > 1 then
                        if value72 <= visAt + (config.faceWithin or 25) + 40 then
                            local value73 = Vector3.new(value70 / value72, 0, value71 / value72)
                            value69 = if context.RT
                                then if context.RT.aoeMode == "target"
                                    then math.min(visAt, value72)
                                    else visAt
                                else visAt
                            value67 = value73
                        else
                            value69 = visAt
                        end
                    else
                        value69 = visAt
                    end
                else
                    value69 = visAt
                end
                if value67.Magnitude > 0.01 then
                    value67 = value67.Unit
                    value68 =
                        Vector3.new(vector.X + value67.X * value69, vector.Y, vector.Z + value67.Z * value69)
                    value38 = helper7(
                        sharedValue.ring,
                        value38,
                        Color3.fromRGB(255, 80, 220),
                        value68,
                        value4,
                        vector.Y - 2.3,
                        0.5,
                        0.25
                    )
                end
            end
        end
        if config.drawHazards and hazardReader.zones then
            value, visAt = ipairs, hazardReader.zones
            for key13, entry9 in value(visAt) do
                argument = config.ringDrawFar or 80
                key13 = vector
                    and entry9.cx
                    and argument > 0
                    and math.sqrt((entry9.cx - vector.X) ^ 2 + (entry9.cz - vector.Z) ^ 2)
                            - (entry9.r or 0)
                        > argument
                if
                    entry9.ring
                    and entry9.r
                    and entry9.cx
                    and (entry9.untilAt or 0) > os.clock()
                    and not key13
                then
                    value4 = Vector3.new(entry9.cx, 0, entry9.cz)
                    if config.ringDrawFill ~= false then
                        local value74 = (entry9.cy or vector and vector.Y - 2.4 or 0)
                            + (config.ringDrawLift or 4)
                        value38 = helper8(
                            sharedValue.ring,
                            value38,
                            config.colorLive,
                            value4,
                            entry9.r,
                            entry9.ring,
                            value74,
                            0.45,
                            entry9.sx,
                            entry9.sz
                        )
                    else
                        local value75 = vector and vector.Y - 2.4 or (entry9.cy or 0)
                        value38 = helper7(
                            sharedValue.ring,
                            value38,
                            config.colorLive,
                            value4,
                            entry9.r,
                            value75,
                            0.6,
                            0.25,
                            nil,
                            entry9.sx,
                            entry9.sz
                        )
                        value38 = helper7(
                            sharedValue.ring,
                            value38,
                            config.colorLive,
                            value4,
                            entry9.ring,
                            value75,
                            0.6,
                            0.45,
                            nil,
                            entry9.sx,
                            entry9.sz
                        )
                    end
                end
            end
        end
        helper10(sharedValue.ring, value38)
        value38 = 0
        if config.drawGroups and hazardReader.mobGroups then
            value4, argument, visAt = context.BR and context.BR.target
            value = math.huge
            if value4 then
                if not value4.isBoss then
                    local value76, value77, value78 = value, argument, visAt
                    for index14, mobGroup in ipairs(hazardReader.mobGroups) do
                        index14 = math.sqrt((value4.x - mobGroup.x) ^ 2 + (value4.z - mobGroup.z) ^ 2)
                        if index14 < value76 then
                            value76, value77, value78 = index14, mobGroup.x, mobGroup.z
                        end
                    end
                    argument, visAt = value77, value78
                end
            end
            local iterateArray7, value79 = ipairs, hazardReader.mobGroups
            for key14, entry10 in iterateArray7(value79) do
                if entry10.n >= 2 then
                    key14 = entry10.r + 8
                    value38 = helper7(
                        sharedValue.groups,
                        value38,
                        Color3.fromRGB(120, 235, 130),
                        Vector3.new(entry10.x, 0, entry10.z),
                        key14,
                        (entry10.y or 0) - 2.4,
                        0.55,
                        0.3
                    )
                end
            end
            if argument then
                value79 = config.groupZoneRadius or 70
                value38 = helper7(
                    sharedValue.groups,
                    value38,
                    Color3.fromRGB(90, 160, 255),
                    Vector3.new(argument, 0, visAt),
                    value79,
                    (vector and vector.Y or 0) - 2.4,
                    0.6,
                    0.25
                )
            end
        end
        helper10(sharedValue.groups, value38)
        value = hazardReader.aoeShape
        if config.drawAoe and vector and success and value then
            value4 = sharedValue.aoe
            if if value4 then not sharedValue.aoe.Parent else not value4 then
                sharedValue.aoe = helper2(helper(), "aoe", 0.7)
                sharedValue.aoe.Color = config.colorAbility
            end
            argument, visAt =
                Vector3.new(success.X - vector.X, 0, success.Z - vector.Z),
                Vector3.new(success.X, success.Y - 2.4, success.Z)
            if value.aoeRound then
                sharedValue.aoe.Shape, sharedValue.aoe.Size =
                    Enum.PartType.Cylinder, Vector3.new(0.4, value.aoeX, value.aoeX)
                sharedValue.aoe.CFrame = CFrame.new(visAt) * CFrame.Angles(0, 0, 1.5707963267948966)
            else
                sharedValue.aoe.Shape, sharedValue.aoe.Size =
                    Enum.PartType.Block, Vector3.new(value.aoeX, 0.4, value.aoeZ)
                sharedValue.aoe.CFrame = argument.Magnitude > 0.5
                        and CFrame.lookAt(visAt, visAt + argument.Unit)
                    or CFrame.new(visAt)
            end
        elseif sharedValue.aoe then
            sharedValue.aoe:Destroy()
            sharedValue.aoe = nil
        end
        if config.drawTarget and dangerGeometry.target then
            success = sharedValue.target
            if if success then not sharedValue.target.Parent else not success then
                sharedValue.target = helper2(helper(), "target", 0.35)
                sharedValue.target.Color, sharedValue.target.Size = config.colorTarget, Vector3.new(2, 5, 2)
            end
            sharedValue.target.CFrame = CFrame.new(dangerGeometry.target + Vector3.new(0, 3, 0))
        elseif sharedValue.target then
            sharedValue.target:Destroy()
            sharedValue.target = nil
        end
    end
    local function clearDrawing()
        if sharedValue.folder then
            sharedValue.folder:Destroy()
        end
        sharedValue.folder = nil
        sharedValue.target = nil
        sharedValue.aoe = nil
        if sharedValue.mlFolder then
            pcall(function()
                sharedValue.mlFolder:Destroy()
            end)
            sharedValue.mlFolder = nil
        end
        if sharedValue.mLines then
            table.clear(sharedValue.mLines)
        end
        table.clear(sharedValue.parts)
        table.clear(sharedValue.nodes)
        table.clear(sharedValue.spots)
        table.clear(sharedValue.ring)
        table.clear(sharedValue.groups)
        table.clear(sharedValue.tags)
        table.clear(sharedValue.wallTags)
        if sharedValue.boxPool then
            table.clear(sharedValue.boxPool)
        end
    end
    context.drawTick = function(argument)
        local success, value = pcall(helper30, argument)
        helper4()
        if not success then
            error(value, 0)
        end
    end
    context.clearDrawing = clearDrawing

return function(context)
end
