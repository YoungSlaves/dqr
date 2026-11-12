-- ui/window.lua -- the Duskwood shell: branch + hanging sign header, hanging
-- sign tab rail, bark-framed stone window, footer, fireflies, notifications.
--
-- Replaces the old inline chrome that lived in interfaceMainLoop.  It returns
-- the same table surface the pages were written against (pages/order/page/
-- menuPage/selectTab/toast/notify/setShown/isShown/finish/sections/onClose), so
-- every page body still runs untouched.
return function(context)
    local theme = context.Theme
    local shapes = context.shapes
    local prim = context.primitives
    local P = theme.palette
    local config = context.CFG
    local runtimeState = context.RT
    local localPlayer = context.LocalPlayer
    local userInputService = context.UserInputService
    local runService = context.RunService
    local TweenService = context.getService("TweenService")
    local players = context.getService("Players")

    local version = tostring(context.SCRIPT_VERSION or "?")
    local WINDOW_FILE = "HarvardLabs/configs/menu_window.json"

    local TABS = {
        { id = "Farm", name = "Farm Settings", desc = "The loop, the class, and the master switch." },
        { id = "AltFarm", name = "Parties & Runs", desc = "Every run starts here, from a party - even a party of one." },
        { id = "ModDetect", name = "Mod Detection", desc = "Strangers in your runs and big drops: what every account does about them." },
        { id = "AutoSell", name = "Auto Sell", desc = "Sell what drops, keep what matters." },
        { id = "Webhook", name = "Webhook", desc = "Post a summary of every run to a Discord channel." },
        { id = "Visuals", name = "Visuals", desc = "Theme, notifications, screen, minimap, item cards, streamer mode." },
    }

    local function viewport()
        local camera = workspace.CurrentCamera
        return camera and camera.ViewportSize or Vector2.new(1920, 1080)
    end

    local function readSavedSize()
        local ok, value = pcall(function()
            return context.HttpService:JSONDecode(readfile(WINDOW_FILE))
        end)
        if ok and type(value) == "table" then
            local entry = value[context.COMPACT == true and "phone" or "pc"]
            if type(entry) == "table" then
                return tonumber(entry.w), tonumber(entry.h), value
            end
        end
        return nil, nil, {}
    end

    local function writeSavedSize(width, height)
        local _, _, blob = readSavedSize()
        blob[context.COMPACT == true and "phone" or "pc"] = { w = width, h = height }
        pcall(function()
            writefile(WINDOW_FILE, context.HttpService:JSONEncode(blob))
        end)
    end

    function context.UI.buildShell(gui)
        gui = gui or context.UI.menuGui()
        prim.ensureTip(gui)
        shapes.spawnFireflies(8)

        local shell = { pages = {}, order = {}, sections = context.sectionReg or {} }
        context.sectionReg = shell.sections

        local connections = {}
        local function bind(signal, callback)
            local connection = signal:Connect(callback)
            connections[#connections + 1] = connection
            table.insert(context.sliderConnections, connection)
            return connection
        end

        local screen = viewport()
        local savedW, savedH = readSavedSize()
        local width = math.clamp(savedW or theme.window.width, theme.window.minWidth, theme.window.maxWidth)
        local height = math.clamp(savedH or theme.window.height, theme.window.minHeight, theme.window.maxHeight)
        local body, shown, fading, minimized
        local footerFlies = {}

        ------------------------------------------------------------------ window
        local holder = Instance.new("Frame")
        holder.Name = "DQRWindow"
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.fromOffset(width, height)
        holder.Position = UDim2.fromOffset(
            math.floor((screen.X - width) / 2),
            math.floor((screen.Y - height) / 2)
        )
        holder.Visible = false
        holder.ZIndex = tonumber(config.menuZ) or 20
        holder:SetAttribute("hlWin", true)
        holder.Parent = gui
        shell.holder = holder

        local uiScale = Instance.new("UIScale")
        uiScale.Parent = holder

        local window, innerFrame = shapes.stoneWindow(holder)
        window.Size = UDim2.fromScale(1, 1)
        shell.root = window

        shapes.decorateWindow(window)

        local header = Instance.new("Frame")
        header.Name = "Header"
        header.BackgroundTransparency = 1
        header.Size = UDim2.new(1, 0, 0, theme.header)
        header.Active = true
        header.ZIndex = 3
        header.Parent = window

        shapes.branch(header, width)
        local sign, signLabel = shapes.titleSign(header, "Harvard Labs")
        signLabel.Text = "Harvard Labs"
        shapes.decorateSign(sign)

        -- version chip pinned to the branch's right end, not to the sign
        local versionChip = shapes.chip(header, "v" .. version, 1)
        versionChip.AnchorPoint = Vector2.new(1, 0)
        versionChip.Position = UDim2.new(1, -14, 0, -8)
        versionChip.BackgroundTransparency = 0.2

        -- window buttons: leaf buttons on non-rotated 44x44 wrappers
        local buttonHost = Instance.new("Frame")
        buttonHost.Name = "WindowButtons"
        buttonHost.BackgroundTransparency = 1
        buttonHost.AnchorPoint = Vector2.new(1, 0.5)
        buttonHost.Position = UDim2.new(1, -8, 0, 44)
        buttonHost.Size = UDim2.fromOffset(132, 44)
        buttonHost.Parent = header
        prim.hlist(buttonHost, 0)

        shown, fading, minimized = false, false, false
        local maximized = false
        local restoreW, restoreH = width, height
        local basePosition = holder.Position
        local dragOffset

        local function applySize()
            holder.Size = UDim2.fromOffset(width, height)
        end

        local function minimizeButton()
            minimized = not minimized
            TweenService:Create(
                holder,
                TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = UDim2.fromOffset(width, minimized and (theme.header + theme.footer) or height) }
            ):Play()
            body.Visible = not minimized
            shapes.pauseFireflies(minimized or not shown)
        end

        local function maximizeButton()
            maximized = not maximized
            minimized = false
            body.Visible = true
            if maximized then
                restoreW, restoreH = width, height
                local screenSize = viewport()
                width = math.clamp(math.floor(screenSize.X - 48), theme.window.minWidth, theme.window.maxWidth)
                height = math.clamp(math.floor(screenSize.Y - 48), theme.window.minHeight, theme.window.maxHeight)
            else
                width, height = restoreW, restoreH
            end
            applySize()
            writeSavedSize(width, height)
        end

        local function closeButtonAction()
            if shell.onClose then
                shell.onClose()
            end
        end

        -- modal catcher: keeps clicks inside the window from reaching the world
        local freeMouse = Instance.new("TextButton")
        freeMouse.Name = "FreeMouse"
        freeMouse.Modal = true
        freeMouse.Text = ""
        freeMouse.BackgroundTransparency = 1
        freeMouse.Size = UDim2.fromOffset(0, 0)
        freeMouse.Parent = window

        for index, spec in ipairs({
            {
                name = "Minimize",
                handler = minimizeButton,
                hint = "Fold the window up to its header.",
            },
            {
                name = "Maximize",
                handler = maximizeButton,
                hint = "Make the window as big as the screen allows, or back to the size it was.",
            },
            {
                name = "Close",
                handler = closeButtonAction,
                hint = "Close the menu. The menu key opens it again.",
            },
        }) do
            local target = shapes.touchTarget(buttonHost, 44)
            target.Name = spec.name
            target.Size = UDim2.fromOffset(44, 44)
            local leaf = shapes.rotatedSquare(target, 26, index == 3 and P.Bark or P.Moss, P.Bark)
            local glyph = Instance.new("Frame")
            glyph.Name = "Glyph"
            glyph.BackgroundColor3 = index == 3 and P.Parchment or P.LeafLight
            glyph.BorderSizePixel = 0
            glyph.AnchorPoint = Vector2.new(0.5, 0.5)
            glyph.Position = UDim2.fromScale(0.5, 0.5)
            if index == 1 then
                glyph.Size = UDim2.fromOffset(12, 2)
            elseif index == 2 then
                glyph.Size = UDim2.fromOffset(10, 10)
                glyph.BackgroundTransparency = 1
                shapes.stroke(glyph, P.LeafLight, 2)
            else
                glyph.Size = UDim2.fromOffset(10, 2)
                glyph.Rotation = 45
            end
            glyph.Parent = target
            target.MouseButton1Click:Connect(spec.handler)
            prim.tip(target, spec.hint)
        end

        -- resize grip: bottom-right leaf, drag to resize within the clamp
        local grip = shapes.touchTarget(window, 30)
        grip.Name = "Resize"
        grip.AnchorPoint = Vector2.new(1, 1)
        grip.Position = UDim2.new(1, -4, 1, -4)
        grip.Size = UDim2.fromOffset(30, 30)
        grip.ZIndex = 65
        shapes.rotatedSquare(grip, 16, P.Moss, P.Bark)
        prim.tip(grip, "Drag to resize the window.")
        local resizing, resizeStart, resizeSize
        grip.InputBegan:Connect(function(input)
            if
                input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                resizing = true
                resizeStart = input.Position
                resizeSize = Vector2.new(width, height)
            end
        end)
        bind(userInputService.InputChanged, function(input)
            if
                resizing
                and (
                    input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                )
            then
                local delta = input.Position - resizeStart
                local scale = uiScale.Scale > 0 and uiScale.Scale or 1
                width = math.clamp(
                    math.floor(resizeSize.X + delta.X / scale),
                    theme.window.minWidth,
                    math.min(theme.window.maxWidth, math.max(theme.window.minWidth, viewport().X - 24))
                )
                height = math.clamp(
                    math.floor(resizeSize.Y + delta.Y / scale),
                    theme.window.minHeight,
                    math.min(theme.window.maxHeight, math.max(theme.window.minHeight, viewport().Y - 24))
                )
                applySize()
            end
        end)
        bind(userInputService.InputEnded, function(input)
            if
                input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                if resizing then
                    resizing = false
                    writeSavedSize(width, height)
                end
            end
        end)

        -- drag by the branch
        bind(header.InputBegan, function(input)
            if
                input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                dragOffset = Vector2.new(input.Position.X, input.Position.Y) - holder.AbsolutePosition
            end
        end)
        bind(userInputService.InputChanged, function(input)
            if
                dragOffset
                and (
                    input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                )
            then
                holder.Position = UDim2.fromOffset(
                    math.floor(input.Position.X - dragOffset.X),
                    math.floor(input.Position.Y - dragOffset.Y)
                )
            end
        end)
        bind(userInputService.InputEnded, function(input)
            if
                input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                if dragOffset then
                    basePosition = holder.Position
                    dragOffset = nil
                end
            end
        end)

        ------------------------------------------------------------------ body
        local headerBottom = theme.header + 4
        body = Instance.new("Frame")
        body.Name = "Body"
        body.BackgroundTransparency = 1
        body.Position = UDim2.fromOffset(0, headerBottom)
        body.Size = UDim2.new(1, 0, 1, -(headerBottom + theme.footer))
        body.Parent = window

        local rail = Instance.new("Frame")
        rail.Name = "Rail"
        rail.BackgroundColor3 = P.Wood
        rail.BackgroundTransparency = 1 - theme.rowPlankAlpha
        rail.BorderSizePixel = 0
        rail.Size = UDim2.fromOffset(theme.rail.width, 1)
        rail.Size = UDim2.new(0, theme.rail.width, 1, 0)
        rail.Parent = body
        shapes.grain(rail, 8)

        local divider = Instance.new("Frame")
        divider.Name = "Divider"
        divider.BackgroundColor3 = P.Bark
        divider.BorderSizePixel = 0
        divider.Position = UDim2.fromOffset(theme.rail.width, 0)
        divider.Size = UDim2.new(0, 1, 1, 0)
        divider.Parent = body

        local content = Instance.new("Frame")
        content.Name = "Content"
        content.BackgroundColor3 = P.DeepForest
        content.BackgroundTransparency = 0
        content.BorderSizePixel = 0
        content.Position = UDim2.fromOffset(theme.rail.width + 1, 0)
        content.Size = UDim2.new(1, -(theme.rail.width + 1), 1, 0)
        content.ClipDescendants = true
        content.Parent = body
        local contentLayout = Instance.new("UIGradient")
        contentLayout.Color = ColorSequence.new(P.Moss, P.DeepForest)
        contentLayout.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.18),
            NumberSequenceKeypoint.new(1, 0.05),
        })
        contentLayout.Rotation = 90
        contentLayout.Parent = content

        shapes.mossStrip(content, 0, width - theme.rail.width - 1, 0.25)

        local pageTitle = prim.text(content, {
            role = "section",
            text = "",
            position = UDim2.fromOffset(theme.pad.window, 12),
            size2 = UDim2.new(1, -theme.pad.window * 2, 0, 20),
        })
        local pageDesc = prim.text(content, {
            role = "sectionDesc",
            text = "",
            position = UDim2.fromOffset(theme.pad.window, 32),
            size2 = UDim2.new(1, -theme.pad.window * 2, 0, 16),
            wrapped = true,
            yAlign = Enum.TextYAlignment.Top,
            transparency = 0.30,
        })
        local pageRule = Instance.new("Frame")
        pageRule.Name = "Rule"
        pageRule.BackgroundColor3 = P.Bark
        pageRule.BackgroundTransparency = 0.3
        pageRule.BorderSizePixel = 0
        pageRule.Position = UDim2.fromOffset(theme.pad.window, 54)
        pageRule.Size = UDim2.new(1, -theme.pad.window * 2, 0, 1)
        pageRule.Parent = content

        local pageHost = Instance.new("Frame")
        pageHost.Name = "Pages"
        pageHost.BackgroundTransparency = 1
        pageHost.Position = UDim2.fromOffset(0, 56)
        pageHost.Size = UDim2.new(1, 0, 1, -56)
        pageHost.Parent = content

        ------------------------------------------------------------------ rail
        local searchTablet = shapes.barkTablet(rail, 34, 1)
        searchTablet.Position = UDim2.fromOffset(10, 10)
        searchTablet.Size = UDim2.new(1, -20, 0, 34)
        local searchIcon = shapes.rotatedSquare(searchTablet, 8, P.Bark, nil)
        searchIcon.Position = UDim2.fromOffset(16, 17)
        local searchBox = Instance.new("TextBox")
        searchBox.Name = "Search"
        searchBox.BackgroundTransparency = 1
        searchBox.Position = UDim2.fromOffset(30, 0)
        searchBox.Size = UDim2.new(1, -38, 1, 0)
        searchBox.Text = ""
        searchBox.PlaceholderText = "Search settings"
        searchBox.PlaceholderColor3 = P.Parchment
        searchBox.TextColor3 = P.Parchment
        searchBox.TextSize = theme.type.caption
        searchBox.ClearTextOnFocus = false
        searchBox.TextXAlignment = Enum.TextXAlignment.Left
        theme.applyFont(searchBox, "body")
        searchBox.Parent = searchTablet

        local ropeRail = Instance.new("Frame")
        ropeRail.Name = "RopeRail"
        ropeRail.BackgroundColor3 = P.Bark
        ropeRail.BorderSizePixel = 0
        ropeRail.Position = UDim2.fromOffset(theme.rail.ropeRailX, 58)
        ropeRail.Size = UDim2.new(0, 2, 1, -150)
        ropeRail.Parent = rail

        local tabStrip = Instance.new("Frame")
        tabStrip.Name = "Tabs"
        tabStrip.BackgroundTransparency = 1
        tabStrip.Position = UDim2.fromOffset(0, 56)
        tabStrip.Size = UDim2.new(1, 0, 1, -96)
        tabStrip.Parent = rail
        prim.vlist(tabStrip, 2)

        local tabs = {}
        local activeTab
        local function selectTab(id, instant)
            if activeTab == id then
                return
            end
            activeTab = id
            for key, entry in pairs(tabs) do
                entry.setActive(key == id)
            end
            for key, page in pairs(shell.pages) do
                page.frame.Visible = key == id
            end
            local tab = shell.pages[id] and shell.pages[id].tab
            if tab then
                pageTitle.Text = tab.name
                pageDesc.Text = tab.desc or ""
            end
            if not instant then
                pageTitle.TextTransparency = 0
                pageDesc.TextTransparency = 0.30
                TweenService:Create(
                    pageTitle,
                    TweenInfo.new(theme.motion.tab, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                    { TextTransparency = 0 }
                ):Play()
            end
        end
        shell.selectTab = selectTab

        local function tabClicked(id)
            selectTab(id, false)
        end
        for index, tab in ipairs(TABS) do
            local entry = shapes.hangingTab(tabStrip, tab.id, index, tab.name, tabClicked)
            tabs[tab.id] = entry
        end

        -- account line + status dot (8px inset)
        local accountLine = prim.text(rail, {
            role = "footer",
            text = localPlayer and localPlayer.Name or "",
            position = UDim2.new(0, 12, 1, -44),
            size2 = UDim2.new(1, -24, 0, 14),
            truncate = Enum.TextTruncate.AtEnd,
        })
        local statusDot = Instance.new("Frame")
        statusDot.Name = "StatusDot"
        statusDot.BackgroundColor3 = P.LeafLight
        statusDot.BorderSizePixel = 0
        statusDot.Position = UDim2.new(0, 12, 1, -26)
        statusDot.Size = UDim2.fromOffset(7, 7)
        statusDot.Parent = rail
        local statusCorner = Instance.new("UICorner")
        statusCorner.CornerRadius = UDim.new(1, 0)
        statusCorner.Parent = statusDot
        function shell.setStatus(kind)
            statusDot.BackgroundColor3 = (kind == "warning" and theme.warning)
                or (kind == "danger" and theme.danger)
                or P.LeafLight
        end

        ------------------------------------------------------------------ footer
        local footer = Instance.new("Frame")
        footer.Name = "Footer"
        footer.BackgroundColor3 = P.Bark
        footer.BorderSizePixel = 0
        footer.AnchorPoint = Vector2.new(0, 1)
        footer.Position = UDim2.new(0, 0, 1, 0)
        footer.Size = UDim2.new(1, 0, 0, theme.footer)
        footer.Parent = window
        local footerHairline = Instance.new("Frame")
        footerHairline.Name = "Hairline"
        footerHairline.BackgroundColor3 = P.Wood
        footerHairline.BorderSizePixel = 0
        footerHairline.Size = UDim2.new(1, 0, 0, 1)
        footerHairline.Parent = footer

        local kbd = Instance.new("Frame")
        kbd.Name = "Keys"
        kbd.BackgroundTransparency = 1
        kbd.Position = UDim2.fromOffset(10, 0)
        kbd.Size = UDim2.new(0, 200, 1, 0)
        kbd.Parent = footer
        prim.hlist(kbd, 6)
        for index, text in ipairs({ tostring(config.menuKey or "RightShift"), "Escape" }) do
            local chip = shapes.chip(kbd, text, index)
            chip.BackgroundTransparency = 0.15
        end

        local buildChip = shapes.chip(footer, "v" .. version, 1)
        buildChip.AnchorPoint = Vector2.new(1, 0.5)
        buildChip.Position = UDim2.new(1, -96, 0.5, 0)
        local saveChip, saveLabel = shapes.chip(footer, "saved", 2)
        saveChip.AnchorPoint = Vector2.new(1, 0.5)
        saveChip.Position = UDim2.new(1, -10, 0.5, 0)
        local saveDot = Instance.new("Frame")
        saveDot.Name = "SaveDot"
        saveDot.BackgroundColor3 = P.LeafLight
        saveDot.BorderSizePixel = 0
        saveDot.Size = UDim2.fromOffset(6, 6)
        saveDot.Position = UDim2.fromOffset(4, 5)
        saveDot.Parent = saveChip
        local saveDotCorner = Instance.new("UICorner")
        saveDotCorner.CornerRadius = UDim.new(1, 0)
        saveDotCorner.Parent = saveDot
        shapes.pad(saveChip, 0, 14, 0, 6)

        for _, at in ipairs({ 0.06, 0.94 }) do
            local fly = Instance.new("Frame")
            fly.Name = "FooterFly"
            fly.BackgroundColor3 = P.Firefly
            fly.BorderSizePixel = 0
            fly.AnchorPoint = Vector2.new(0.5, 0.5)
            fly.Position = UDim2.new(at, 0, 0.5, 0)
            fly.Size = UDim2.fromOffset(6, 6)
            fly.Parent = footer
            local flyCorner = Instance.new("UICorner")
            flyCorner.CornerRadius = UDim.new(1, 0)
            flyCorner.Parent = fly
            local tween = TweenService:Create(
                fly,
                TweenInfo.new(theme.motion.footerPulse / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                { BackgroundTransparency = 0 }
            )
            tween:Play()
            table.insert(footerFlies, tween)
        end

        function shell.setSaveState(state)
            local unsaved = state == "unsaved"
            saveLabel.Text = unsaved and "unsaved" or "saved"
            saveDot.BackgroundColor3 = unsaved and theme.warning or P.LeafLight
        end

        -- offline notice: persistent for the session, exempt from toast timeouts
        local offlineNote
        if context.DQR and context.DQR.offline == true then
            saveLabel.Text = "offline · cached v" .. tostring(context.DQR.version)
            saveDot.BackgroundColor3 = theme.warning
            offlineNote = prim.text(window, {
                role = "footer",
                text = "offline · cached v" .. tostring(context.DQR.version),
                transparency = 0.30,
                position = UDim2.new(0, 0, 1, -50),
                size2 = UDim2.new(1, 0, 0, 14),
                xAlign = Enum.TextXAlignment.Center,
            })
            offlineNote.ZIndex = 12
        end
        function shell.setLive(version)
            saveLabel.Text = "live v" .. tostring(version)
            saveDot.BackgroundColor3 = P.LeafLight
            if offlineNote then
                offlineNote:Destroy()
                offlineNote = nil
            end
        end

        --------------------------------------------------------------- pages
        local function newBody()
            local frame = Instance.new("Frame")
            frame.Name = "Page"
            frame.BackgroundTransparency = 1
            frame.Size = UDim2.fromScale(1, 1)
            frame.Visible = false
            frame.Parent = pageHost
            local scrolling = Instance.new("ScrollingFrame")
            scrolling.Name = "Body"
            scrolling.Size = UDim2.fromScale(1, 1)
            scrolling.BackgroundTransparency = 1
            scrolling.BorderSizePixel = 0
            scrolling.CanvasSize = UDim2.new()
            scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
            scrolling.ScrollingDirection = Enum.ScrollingDirection.Y
            scrolling.Parent = frame
            shapes.scrollbar(scrolling)
            shapes.pad(scrolling, 12, 18, 24, 18)
            prim.vlist(scrolling, 10)
            return frame, scrolling
        end

        local function addPage(name, title, desc)
            local order = #shell.order + 1
            local tab = { id = name, name = title or name, desc = desc or "" }
            local frame, scrolling = newBody()
            shell.pages[name] = { frame = frame, body = scrolling, tab = tab }
            shell.order[order] = name
            return shell.pages[name]
        end

        for _, tab in ipairs(TABS) do
            addPage(tab.id, tab.name, tab.desc)
        end

        function shell.page(name, title, desc)
            local page = shell.pages[name]
            if not page then
                page = addPage(name, title, desc)
            elseif desc and desc ~= "" then
                page.tab.desc = desc
            end
            return {
                frame = page.frame,
                body = page.body,
                title = pageTitle,
                header = header,
                fit = function() end,
                isPinned = function()
                    return false
                end,
                setPinned = function() end,
            }
        end

        function shell.menuPage(name)
            local page = shell.pages[name]
            return page and page.frame or nil
        end

        function shell.menuButton(onClick)
            local target = shapes.touchTarget(gui, 52)
            target.Name = "MobileMenuButton"
            target.AnchorPoint = Vector2.new(0, 0.5)
            target.Position = UDim2.new(0, 14, 0.35, 0)
            target.Size = UDim2.fromOffset(52, 52)
            local diamond = shapes.rotatedSquare(target, 34, P.Moss, P.Bark)
            target.MouseButton1Click:Connect(onClick)
            return target
        end

        ------------------------------------------------------------------ toast
        local toast = Instance.new("TextLabel")
        toast.Name = "Toast"
        toast.AnchorPoint = Vector2.new(0.5, 1)
        toast.Position = UDim2.new(0.5, 0, 1, -34)
        toast.Size = UDim2.fromOffset(0, 28)
        toast.AutomaticSize = Enum.AutomaticSize.X
        toast.BackgroundColor3 = P.Wood
        toast.BorderSizePixel = 0
        toast.TextColor3 = P.Parchment
        toast.TextSize = theme.type.caption
        toast.Text = ""
        toast.Visible = false
        toast.ZIndex = 70
        theme.applyFont(toast, "body")
        toast.Parent = window
        shapes.corner(toast, theme.radius.plank)
        shapes.stroke(toast, P.Bark, 2)
        shapes.pad(toast, 0, 14, 0, 14)
        local toastToken = 0
        function shell.toast(text)
            toastToken += 1
            local token = toastToken
            toast.Text = tostring(text or "")
            toast.Visible = true
            toast.TextTransparency = 1
            toast.BackgroundTransparency = 0
            TweenService:Create(
                toast,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { TextTransparency = 0 }
            ):Play()
            task.delay(2.4, function()
                if token ~= toastToken then
                    return
                end
                TweenService:Create(
                    toast,
                    TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    { TextTransparency = 1 }
                ):Play()
                task.delay(0.26, function()
                    if token == toastToken then
                        toast.Visible = false
                    end
                end)
            end)
        end

        ------------------------------------------------------------ notifications
        local notifyHost = Instance.new("Frame")
        notifyHost.Name = "HLNotifications"
        notifyHost.AnchorPoint = Vector2.new(1, 1)
        notifyHost.Position = UDim2.new(1, -16, 1, -16)
        notifyHost.Size = UDim2.fromOffset(312, 520)
        notifyHost.BackgroundTransparency = 1
        notifyHost.ZIndex = 80
        notifyHost.Parent = gui
        local notifyLayout = Instance.new("UIListLayout")
        notifyLayout.FillDirection = Enum.FillDirection.Vertical
        notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        notifyLayout.Padding = UDim.new(0, 8)
        notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
        notifyLayout.Parent = notifyHost

        local KINDS = {
            info = { color = P.LeafLight },
            party = { color = P.LeafLight },
            run = { color = P.Fern },
            sell = { color = P.Wood },
            success = { color = P.LeafLight },
            warning = { color = theme.warning },
            error = { color = theme.danger },
            drop = { color = P.Firefly },
            dropUltimate = { color = theme.danger },
        }
        local live, recent = {}, {}

        local function kitButton(parent, text, onClick)
            local button = shapes.stoneButton(parent, text, 1)
            button.Size = UDim2.fromOffset(104, 26)
            if onClick then
                button.MouseButton1Click:Connect(function()
                    pcall(onClick)
                end)
            end
            return button
        end

        local function dismiss(card)
            if card.gone then
                return
            end
            card.gone = true
            TweenService:Create(
                card.group,
                TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { GroupTransparency = 1, Position = UDim2.fromOffset(300, 0) }
            ):Play()
            task.delay(0.26, function()
                card.slot:Destroy()
            end)
            for index, entry in ipairs(live) do
                if entry == card then
                    table.remove(live, index)
                    break
                end
            end
        end

        local function notify(kind, title, body, duration, options)
            if config.notifications == false or runtimeState.destroyed then
                return
            end
            title, body = tostring(title or ""), tostring(body or "")
            options = type(options) == "table" and options or {}
            local key = title .. "|" .. body
            if not options.sticky then
                if recent[key] and os.clock() - recent[key] < 4 then
                    return
                end
            end
            recent[key] = os.clock()
            duration = duration or 5
            local appearance = KINDS[kind] or KINDS.info
            local cardHeight = options.button and 100 or 66
            local slot = Instance.new("Frame")
            slot.Name = "Notification"
            slot.Size = UDim2.fromOffset(300, 0)
            slot.BackgroundTransparency = 1
            slot.LayoutOrder = -math.floor(os.clock() * 1000) % 2000000000
            slot.Parent = notifyHost
            local group = Instance.new("CanvasGroup")
            group.Name = "Card"
            group.Size = UDim2.fromOffset(300, cardHeight)
            group.Position = UDim2.fromOffset(330, 0)
            group.BackgroundColor3 = P.Wood
            group.BackgroundTransparency = 0.15
            group.BorderSizePixel = 0
            group.GroupTransparency = 1
            group.Parent = slot
            shapes.corner(group, theme.radius.plank)
            shapes.stroke(group, P.Bark, 2)
            shapes.grain(group, 90)
            local strip = Instance.new("Frame")
            strip.Name = "Kind"
            strip.BackgroundColor3 = appearance.color
            strip.BorderSizePixel = 0
            strip.Size = UDim2.new(0, 4, 1, 0)
            strip.Parent = group
            local titleLabel = prim.text(group, {
                role = "rowLabel",
                text = title,
                position = UDim2.fromOffset(16, 11),
                size2 = UDim2.new(1, -72, 0, 18),
                truncate = Enum.TextTruncate.AtEnd,
            })
            local bodyLabel = prim.text(group, {
                role = "captionSub",
                text = body,
                position = UDim2.fromOffset(16, 30),
                size2 = UDim2.new(1, -72, 0, 28),
                wrapped = true,
                yAlign = Enum.TextYAlignment.Top,
            })
            local dot = shapes.rotatedSquare(group, 14, appearance.color, P.Bark)
            dot.Position = UDim2.new(1, -26, 0, 26)
            local hit = shapes.touchTarget(group, 44)
            hit.Size = UDim2.fromScale(1, 1)
            local record = { slot = slot, group = group, sticky = options.sticky == true }
            live[#live + 1] = record
            while #live > 5 do
                dismiss(live[1])
            end
            hit.MouseButton1Click:Connect(function()
                dismiss(record)
            end)
            record.set = function(a, b)
                if a ~= nil then
                    titleLabel.Text = tostring(a)
                end
                if b ~= nil then
                    bodyLabel.Text = tostring(b)
                end
            end
            record.close = function()
                dismiss(record)
            end
            if options.button then
                local action = kitButton(group, tostring(options.button.text or "OK"), options.button.onClick)
                action.Position = UDim2.fromOffset(14, 60)
                action.Size = UDim2.fromOffset(104, 26)
                record.button = action
            end
            TweenService:Create(slot, TweenInfo.new(0.22, Enum.EasingStyle.Quad), { Size = UDim2.fromOffset(300, cardHeight) })
                :Play()
            TweenService:Create(
                group,
                TweenInfo.new(0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 }
            ):Play()
            if not record.sticky then
                task.delay(duration, function()
                    dismiss(record)
                end)
            end
            return record
        end

        function context.notify(...)
            return (pcall(notify, ...))
        end

        function context.notifyCard(...)
            local ok, value = pcall(notify, ...)
            if ok then
                return value
            end
            return nil
        end

        shell.notify = notify
        function shell.notifyExamples()
            local examples = {
                { "party", "Queued", "Northern Lands, Insane." },
                { "run", "Run started", "Northern Lands, Insane." },
                { "warning", "Mod in the run", "Every account stands still until the run ends, then back to the lobby." },
                { "success", "Run won", "4:12. Replaying with the party." },
                { "drop", "Legendary drop", "Mjolnir" },
                { "sell", "Auto sell", "Sold 23 items." },
                { "info", "Autofarm off", "In the lobby - it switches back on in the next dungeon." },
                { "error", "Run lost", "Back to the lobby to make the party again." },
            }
            for index, entry in ipairs(examples) do
                task.delay((index - 1) * 0.9, function()
                    notify(entry[1], entry[2], entry[3])
                end)
            end
        end

        ------------------------------------------------- webhook event notices
        -- these bindings lived in the old shell; same events, same strings
        do
            local webhooks = context.WH
            if webhooks then
                local rarities = { legendary = true, ultimate = true, epic = true }
                local function wrap(name, fn)
                    local original = webhooks[name]
                    if type(original) ~= "function" then
                        return
                    end
                    webhooks[name] = function(...)
                        pcall(fn, ...)
                        return original(...)
                    end
                end
                wrap("start", function(dungeon, difficulty)
                    notify(
                        "run",
                        "Run started",
                        ("%s, %s."):format(tostring(dungeon or "Dungeon"), tostring(difficulty or ""))
                    )
                end)
                wrap("finish", function(won)
                    local run = webhooks.run
                    local seconds = run and run.at and webhooks.runSecs(run) or nil
                    local clock = seconds
                            and ("%d:%02d"):format(math.floor(seconds / 60), seconds % 60)
                        or ""
                    if won == false then
                        notify(
                            "error",
                            "Run lost",
                            (clock ~= "" and clock .. ". " or "") .. "Back to the party."
                        )
                    else
                        notify(
                            "success",
                            "Run won",
                            (clock ~= "" and clock .. ". " or "") .. tostring(run and run.dungeon or "")
                        )
                    end
                end)
                wrap("item", function(itemName, rarity)
                    if rarity and rarities[string.lower(tostring(rarity))] then
                        notify(
                            string.lower(tostring(rarity)) == "ultimate" and "dropUltimate" or "drop",
                            tostring(rarity) .. " drop",
                            tostring(itemName)
                        )
                    end
                end)
                wrap("rodinClear", function()
                    notify("success", "Rodin cleared", "The bonus boss is down.")
                end)
                wrap("rodinFail", function()
                    notify("error", "Rodin failed", "The bonus boss got away.")
                end)
            end
        end
        for _, page in pairs(shell.pages) do
            page.notify = notify
            page.notifyExamples = shell.notifyExamples
        end

        ------------------------------------------------------------- welcome card
        do
            local farmBody = shell.pages.Farm and shell.pages.Farm.body
            if farmBody then
                local welcome = Instance.new("Frame")
                welcome.Name = "Welcome"
                welcome.LayoutOrder = -100
                welcome.Size = UDim2.new(1, 0, 0, 0)
                welcome.AutomaticSize = Enum.AutomaticSize.Y
                welcome.BackgroundTransparency = 1
                welcome.Parent = farmBody
                local card = Instance.new("Frame")
                card.Name = "Trailhead"
                card.Size = UDim2.new(1, 0, 0, 0)
                card.AutomaticSize = Enum.AutomaticSize.Y
                card.BackgroundColor3 = P.DeepForest
                card.BackgroundTransparency = 0.55
                card.BorderSizePixel = 0
                card.Parent = welcome
                shapes.corner(card, theme.radius.stone)
                shapes.stroke(card, P.Bark, 2)
                shapes.mossStrip(card, 0, 200, 0.25)
                shapes.pad(card, 12, 14, 14, 14)
                prim.vlist(card, 8)

                local hello = Instance.new("Frame")
                hello.Name = "Hello"
                hello.Size = UDim2.new(1, 0, 0, 22)
                hello.BackgroundTransparency = 1
                hello.Parent = card
                prim.hlist(hello, 0)
                local welcomeLabel = prim.text(hello, { role = "rowLabel", text = "Welcome, ", layoutOrder = 1, size2 = UDim2.fromOffset(0, 20) })
                welcomeLabel.AutomaticSize = Enum.AutomaticSize.X
                local nameLabel = prim.text(hello, { role = "section", text = "", layoutOrder = 2, size2 = UDim2.fromOffset(0, 20) })
                nameLabel.AutomaticSize = Enum.AutomaticSize.X
                local dotLabel = prim.text(hello, { role = "rowLabel", text = ".", layoutOrder = 3, size2 = UDim2.fromOffset(0, 20) })
                dotLabel.AutomaticSize = Enum.AutomaticSize.X

                local meta = Instance.new("Frame")
                meta.Name = "Meta"
                meta.Size = UDim2.new(1, 0, 0, 20)
                meta.BackgroundTransparency = 1
                meta.Parent = card
                prim.hlist(meta, 0)
                for index, spec in ipairs({
                    { "Version: ", "rowLabel" },
                    { version, "section" },
                    { "      Level: ", "rowLabel" },
                    { "-", "section" },
                }) do
                    local label = prim.text(meta, { role = spec[2], text = spec[1], layoutOrder = index, size2 = UDim2.fromOffset(0, 20) })
                    label.AutomaticSize = Enum.AutomaticSize.X
                            if index == 4 then
                        label.Name = "Level"
                    end
                end

                local rule = Instance.new("Frame")
                rule.Size = UDim2.new(1, 0, 0, 1)
                rule.BackgroundColor3 = P.Bark
                rule.BorderSizePixel = 0
                rule.Parent = card

                local account = Instance.new("Frame")
                account.Size = UDim2.new(1, 0, 0, 74)
                account.BackgroundTransparency = 1
                account.Parent = card
                local avatar = Instance.new("ImageLabel")
                avatar.Name = "Avatar"
                avatar.Size = UDim2.fromOffset(72, 72)
                avatar.BackgroundColor3 = P.DeepForest
                avatar.Image = ""
                avatar.Parent = account
                shapes.corner(avatar, theme.radius.plank)
                shapes.stroke(avatar, P.Bark, 2)
                task.spawn(function()
                    local ok, image = pcall(function()
                        return players:GetUserThumbnailAsync(
                            localPlayer.UserId,
                            Enum.ThumbnailType.HeadShot,
                            Enum.ThumbnailSize.Size150x150
                        )
                    end)
                    if ok and avatar.Parent then
                        avatar.Image = image
                    end
                end)
                local column = Instance.new("Frame")
                column.Position = UDim2.fromOffset(88, 2)
                column.Size = UDim2.new(1, -88, 1, -2)
                column.BackgroundTransparency = 1
                column.Parent = account
                prim.vlist(column, 2)
                local handleLabel = prim.text(column, { role = "rowLabel", text = "", layoutOrder = 1, size2 = UDim2.new(1, 0, 0, 20) })
                local goldLabel = prim.text(column, { role = "rowCaption", text = "", layoutOrder = 2, size2 = UDim2.new(1, 0, 0, 20) })
                local statusLabel = prim.text(column, { role = "rowCaption", text = "", layoutOrder = 3, size2 = UDim2.new(1, 0, 0, 20) })

                local function leaderstat(name)
                    local value
                    pcall(function()
                        value = localPlayer.leaderstats[name].Value
                    end)
                    return value
                end
                local function comma(number)
                    local text = tostring(math.floor((tonumber(number) or 0) + 0.5))
                    while true do
                        local replaced
                        text, replaced = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
                        if replaced == 0 then
                            break
                        end
                    end
                    return text
                end
                local function refreshWelcome()
                    local streamer = config.streamer == true
                    local shown = localPlayer.DisplayName ~= "" and localPlayer.DisplayName or localPlayer.Name
                    shown = streamer and tostring(config.streamerNameText or "") or shown
                    nameLabel.Text = shown
                    nameLabel.Visible = shown ~= ""
                    dotLabel.Visible = shown ~= ""
                    meta.Level.Text = streamer and "XXX" or tostring(leaderstat("Level") or "-")
                    handleLabel.Text = streamer and (shown ~= "" and "@" .. shown or "") or "@" .. localPlayer.Name
                    handleLabel.Visible = handleLabel.Text ~= ""
                    local gold = leaderstat("Gold")
                    goldLabel.Text = "Gold: "
                        .. (
                            streamer and config.streamerGoldText and config.streamerGoldText ~= "" and tostring(
                                config.streamerGoldText
                            ) or (gold and comma(gold) or "-")
                        )
                    local status = "idle"
                    pcall(function()
                        status = tostring(context.LB and context.LB.status or (runtimeState.farmEnabled and "running" or "idle"))
                    end)
                    statusLabel.Text = "Status: " .. status
                    avatar.ImageTransparency = streamer and 1 or 0
                end
                refreshWelcome()
                shell.refreshWelcome = refreshWelcome
                task.spawn(function()
                    while true do
                        if runtimeState.destroyed or not welcome.Parent then
                            break
                        end
                        task.wait(1)
                        pcall(refreshWelcome)
                    end
                end)
            end
        end

        ---------------------------------------------------------------- search
        local overlay = Instance.new("Frame")
        overlay.Name = "Overlay"
        overlay.Size = UDim2.fromScale(1, 1)
        overlay.BackgroundTransparency = 1
        overlay.ZIndex = 50
        overlay.Visible = false
        overlay.Parent = window
        local overlayDismiss = shapes.touchTarget(overlay, 1)
        overlayDismiss.Size = UDim2.fromScale(1, 1)
        overlayDismiss.ZIndex = 50

        local searchResults = {}
        local function collectControls()
            local found, seen = {}, {}
            for _, name in ipairs(shell.order) do
                local page = shell.pages[name]
                for _, descendant in ipairs(page.body:GetDescendants()) do
                    local textObject, frame
                    if
                        descendant:IsA("Frame")
                        and (
                            descendant.Name == "Row"
                            or descendant.Name == "Slider"
                            or descendant.Name == "RangeSlider"
                            or descendant.Name == "ListInput"
                        )
                    then
                        local label = descendant:FindFirstChildWhichIsA("TextLabel")
                        if label and label.Text ~= "" then
                            textObject, frame = label.Text, descendant
                        end
                    elseif descendant:IsA("TextButton") and descendant.Name == "LeafButton" then
                        local label = descendant:FindFirstChild("Label")
                        if label and label.Text ~= "" then
                            textObject, frame = label.Text, descendant
                        end
                    end
                    if textObject and frame then
                        local key = name .. "|" .. textObject
                        if not seen[key] then
                            seen[key] = true
                            found[#found + 1] = {
                                label = textObject,
                                frame = frame,
                                page = name,
                                tab = page.tab,
                                hint = context.tipTextOf and context.tipTextOf(frame) or "",
                            }
                        end
                    end
                end
            end
            return found
        end

        local function closeOverlay()
            for _, child in ipairs(overlay:GetChildren()) do
                if child ~= overlayDismiss then
                    child:Destroy()
                end
            end
            overlay.Visible = false
        end
        overlayDismiss.MouseButton1Click:Connect(closeOverlay)

        local function flash(frame)
            local glow = Instance.new("Frame")
            glow.Name = "Flash"
            glow.BackgroundTransparency = 1
            glow.Size = UDim2.fromScale(1, 1)
            glow.ZIndex = 60
            glow.Parent = window
            shapes.corner(glow, theme.radius.plank)
            local ring = shapes.stroke(glow, P.Firefly, 2)
            local function follow()
                if not frame.Parent then
                    return
                end
                glow.Position = frame.AbsolutePosition - window.AbsolutePosition
                glow.Size = UDim2.fromOffset(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
            end
            follow()
            local connection = runService.RenderStepped:Connect(follow)
            TweenService:Create(ring, TweenInfo.new(1.1, Enum.EasingStyle.Quad), { Transparency = 1 }):Play()
            task.delay(1.2, function()
                connection:Disconnect()
                glow:Destroy()
            end)
        end

        local function jumpTo(entry)
            closeOverlay()
            selectTab(entry.page, true)
            task.defer(function()
                local parent = entry.frame.Parent
                while parent and parent ~= shell.pages[entry.page].body do
                    local section = shell.sections[parent]
                    if section and not section.isOpen() then
                        section.setOpen(true)
                    end
                    parent = parent.Parent
                end
                task.wait(0.35)
                local body = shell.pages[entry.page].body
                if entry.frame.Parent then
                    local y = (entry.frame.AbsolutePosition.Y - body.AbsolutePosition.Y) + body.CanvasPosition.Y - 18
                    TweenService:Create(
                        body,
                        TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { CanvasPosition = Vector2.new(0, math.max(0, y)) }
                    ):Play()
                    task.delay(0.3, function()
                        if entry.frame.Parent then
                            flash(entry.frame)
                        end
                    end)
                end
            end)
        end

        local function renderSearch(withScroll)
            closeOverlay()
            local query = string.lower(searchBox.Text):gsub("^%s+", ""):gsub("%s+$", "")
            local matches, list = collectControls(), {}
            if query == "" then
                local priority = { ["Enable Autofarm"] = 1, ["Run this party"] = 2, ["Send to Discord"] = 3, Enabled = 4 }
                for _, entry in ipairs(matches) do
                    if priority[entry.label] then
                        if entry.label == "Enabled" then
                            if entry.page == "AutoSell" then
                                list[#list + 1] = entry
                            end
                        else
                            list[#list + 1] = entry
                        end
                    end
                end
                table.sort(list, function(a, b)
                    return priority[a.label] < priority[b.label]
                end)
            else
                for _, entry in ipairs(matches) do
                    local label = string.lower(entry.label)
                    local score = label:sub(1, #query) == query and 3
                        or label:find(query, 1, true) and 2
                        or string.lower(entry.hint or ""):find(query, 1, true) and 1
                        or 0
                    if score > 0 then
                        list[#list + 1] = { e = entry, s = score }
                    end
                end
                table.sort(list, function(a, b)
                    if a.s ~= b.s then
                        return a.s > b.s
                    end
                    return a.e.label < b.e.label
                end)
                for index, item in ipairs(list) do
                    list[index] = item.e
                end
            end
            searchResults = list
            overlay.Visible = true
            local panel = Instance.new("Frame")
            panel.Name = "Results"
            panel.Position = UDim2.fromOffset(theme.rail.width - 8, 48)
            panel.Size = UDim2.new(0, 260, 0, 0)
            panel.AutomaticSize = Enum.AutomaticSize.Y
            panel.BackgroundColor3 = P.Wood
            panel.BackgroundTransparency = 1 - theme.rowPlankAlpha
            panel.BorderSizePixel = 0
            panel.ZIndex = 51
            panel.Parent = overlay
            shapes.corner(panel, theme.radius.plank)
            shapes.stroke(panel, P.Bark, 2)
            shapes.grain(panel, 8)
            shapes.pad(panel, 4)
            prim.vlist(panel, 2)
            local heading = prim.text(panel, {
                role = "captionKey",
                text = query == ""
                    and "Most used"
                    or (#list == 0 and "Nothing called that." or #list .. (#list == 1 and " option" or " options")),
                layoutOrder = 0,
                size2 = UDim2.new(1, 0, 0, 20),
            })
            heading.ZIndex = 52
            for index = 1, math.min(#list, 8) do
                local entry = list[index]
                local option = Instance.new("TextButton")
                option.Name = "Result"
                option.BackgroundColor3 = index == 1 and P.Fern or P.Wood
                option.BackgroundTransparency = index == 1 and 0.2 or 0.35
                option.BorderSizePixel = 0
                option.Size = UDim2.new(1, 0, 0, 30)
                option.LayoutOrder = index
                option.Text = ""
                option.ZIndex = 52
                option.Parent = panel
                shapes.corner(option, theme.radius.plank)
                local label = prim.text(option, {
                    role = "rowLabel",
                    text = entry.label,
                    position = UDim2.fromOffset(10, 0),
                    size2 = UDim2.new(1, -120, 1, 0),
                    truncate = Enum.TextTruncate.AtEnd,
                    zIndex = 53,
                })
                label.TextColor3 = index == 1 and P.LeafLight or P.Parchment
                local tag = prim.text(option, {
                    role = "captionSub",
                    text = entry.tab.name,
                    position = UDim2.new(1, -112, 0, 0),
                    size2 = UDim2.fromOffset(104, 30),
                    xAlign = Enum.TextXAlignment.Right,
                    zIndex = 53,
                })
                option.MouseEnter:Connect(function()
                    option.BackgroundColor3 = P.Fern
                    label.TextColor3 = P.LeafLight
                end)
                option.MouseLeave:Connect(function()
                    option.BackgroundColor3 = index == 1 and P.Fern or P.Wood
                    label.TextColor3 = index == 1 and P.LeafLight or P.Parchment
                end)
                option.MouseButton1Click:Connect(function()
                    jumpTo(entry)
                end)
            end
        end

        bind(searchBox.Focused, function()
            if not shown then
                task.defer(function()
                    pcall(function()
                        searchBox:ReleaseFocus()
                    end)
                end)
                return
            end
            renderSearch(true)
        end)
        bind(searchBox:GetPropertyChangedSignal("Text"), function()
            if searchBox:IsFocused() then
                renderSearch(false)
            end
        end)
        bind(searchBox.FocusLost, function(enterPressed)
            if enterPressed and searchResults[1] then
                jumpTo(searchResults[1])
                return
            end
            task.delay(0.35, function()
                if not searchBox:IsFocused() then
                    closeOverlay()
                end
            end)
        end)

        -------------------------------------------------------------- open/close
        local function fadeIn()
            fading = true
            holder.Visible = true
            local sprout = Instance.new("UIScale")
            sprout.Scale = 0.9
            sprout.Parent = window
            TweenService:Create(
                holder,
                TweenInfo.new(theme.motion.open, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Size = UDim2.fromOffset(width, minimized and (theme.header + theme.footer) or height) }
            ):Play()
            TweenService:Create(
                sprout,
                TweenInfo.new(theme.motion.open, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Scale = 1 }
            ):Play()
            task.delay(theme.motion.open, function()
                if sprout.Parent then
                    sprout:Destroy()
                end
                fading = false
            end)
            shapes.pauseFireflies(false)
        end

        local function fadeOut(onDone)
            if fading then
                return
            end
            fading = true
            local shade = Instance.new("CanvasGroup")
            shade.Name = "Fader"
            shade.Size = UDim2.fromScale(1, 1)
            shade.BackgroundTransparency = 1
            shade.GroupTransparency = 0
            shade.Parent = holder
            window.Parent = shade
            TweenService:Create(
                shade,
                TweenInfo.new(theme.motion.close, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
                { GroupTransparency = 1 }
            ):Play()
            task.delay(theme.motion.close, function()
                window.Parent = holder
                shade:Destroy()
                holder.Visible = false
                fading = false
                if onDone then
                    onDone()
                end
            end)
        end

        function shell.isShown()
            return shown
        end

        function shell.setShown(value)
            value = value == true
            if value == shown then
                return
            end
            shown = value
            if value then
                closeOverlay()
                fadeIn()
                if not activeTab then
                    selectTab(shell.order[1], true)
                end
            else
                closeOverlay()
                prim.hideTip()
                pcall(function()
                    local focused = userInputService:GetFocusedTextBox()
                    if focused and holder:IsAncestorOf(focused) then
                        focused:ReleaseFocus()
                    end
                end)
                shapes.pauseFireflies(true)
                fadeOut()
            end
        end

        function shell.finish()
            if not activeTab then
                selectTab(shell.order[1], true)
            end
        end

        shell.tw = function(object, duration, properties)
            local tween = TweenService:Create(object, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad), properties)
            tween:Play()
            return tween
        end
        shell.twd = shell.tw

        function shell.teardown()
            shapes.clearFireflies()
            shapes.pauseFireflies(true)
            for _, tween in ipairs(footerFlies) do
                pcall(function()
                    tween:Cancel()
                end)
            end
            for _, connection in ipairs(connections) do
                pcall(function()
                    connection:Disconnect()
                end)
            end
            table.clear(connections)
            for _, card in ipairs(live) do
                pcall(function()
                    card.slot:Destroy()
                end)
            end
            table.clear(live)
            prim.hideTip()
            closeOverlay()
            if holder.Parent then
                holder:Destroy()
            end
            if notifyHost.Parent then
                notifyHost:Destroy()
            end
            shapes.destroyGuis()
        end

        context.UI.teardown = shell.teardown

        -- fireflies pause with the window; resume only when it is shown
        shapes.pauseFireflies(true)
        if signLabel then
            signLabel.Text = "Harvard Labs"
        end
        return shell
    end
end
