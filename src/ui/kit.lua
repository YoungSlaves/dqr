-- ui/kit.lua -- the widget kit the six pages are written against.
--
-- Same table surface the old uiLibrary exposed (Theme/setFont/corner/stroke/
-- pad/vlist/hlist/label/caption/toggle/slider/...): the page bodies run
-- unchanged, but every widget is now a Duskwood construction from
-- ui/shapes.lua.  No UIGradient, rotated frame or ScreenGui is created here.
return function(context)
    local theme = context.Theme
    local shapes = context.shapes
    local prim = context.primitives
    local P = theme.palette
    local TweenService = context.getService("TweenService")
    local userInputService = context.UserInputService

    local kit = {}
    local sectionReg = context.sectionReg or {}
    context.sectionReg = sectionReg

    local rowIndex = setmetatable({}, { __mode = "k" })

    local function nextRowIndex(parent)
        local n = (rowIndex[parent] or 0) + 1
        rowIndex[parent] = n
        return n
    end

    ---------------------------------------------------------------- glue api
    kit.Theme = theme
    kit.setFont = prim.setFont
    kit.corner = shapes.corner
    kit.stroke = shapes.stroke
    kit.pad = shapes.pad
    kit.vlist = prim.vlist
    kit.hlist = prim.hlist
    kit.flexFill = prim.flexFill
    kit.icon = prim.icon
    kit.tip = prim.tip
    kit.ensureTip = prim.ensureTip
    kit.hideTip = prim.hideTip
    kit.pressable = prim.pressable

    function kit.label(parent, text, role, order)
        return prim.text(parent, {
            role = role or "rowLabel",
            text = text or "",
            layoutOrder = order or 1,
        })
    end

    function kit.caption(parent, text, order)
        local label = prim.text(parent, {
            role = "captionSub",
            text = text or "",
            layoutOrder = order or 1,
            wrapped = true,
            yAlign = Enum.TextYAlignment.Top,
        })
        label.AutomaticSize = Enum.AutomaticSize.Y
        label.Size = UDim2.new(1, 0, 0, 0)
        return label
    end

    -- moss shading only; never an accent gradient
    function kit.accentGradient(parent, rotation)
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, P.Moss),
            ColorSequenceKeypoint.new(0.5, P.Fern),
            ColorSequenceKeypoint.new(1, P.LeafLight),
        })
        gradient.Rotation = rotation or 0
        gradient.Parent = parent
        return gradient
    end

    -- the old moving accent band is gone (no accent gradients); the call sites
    -- keep working, the band is a still moss strip.
    function kit.accentSweep(parent)
        local strip = Instance.new("Frame")
        strip.Name = "MossSheen"
        strip.BackgroundColor3 = P.Fern
        strip.BackgroundTransparency = 0.55
        strip.BorderSizePixel = 0
        strip.Size = UDim2.new(1, 0, 1, 0)
        strip.Parent = parent
        return strip
    end

    function kit.stopSweeps() end

    function kit.bodyGradient(parent)
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, P.Moss),
            ColorSequenceKeypoint.new(0.45, P.DeepForest),
            ColorSequenceKeypoint.new(1, P.DeepForest),
        })
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.18),
            NumberSequenceKeypoint.new(0.45, 0.05),
            NumberSequenceKeypoint.new(1, 0.05),
        })
        gradient.Rotation = 90
        gradient.Parent = parent
        return gradient
    end

    function kit.shadow(parent)
        -- a static, very soft bark halo; no shadow tweens
        local halo = Instance.new("Frame")
        halo.Name = "Halo"
        halo.BackgroundColor3 = P.DeepForest
        halo.BackgroundTransparency = 0.82
        halo.BorderSizePixel = 0
        halo.Position = UDim2.fromOffset(-6, -6)
        halo.Size = UDim2.new(1, 12, 1, 12)
        halo.Parent = parent
        shapes.corner(halo, theme.radius.stone + 6)
        return halo
    end

    function kit.chevron(parent)
        local holder = Instance.new("Frame")
        holder.Name = "Chevron"
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.fromOffset(16, 16)
        holder.LayoutOrder = 99
        holder.Parent = parent
        local diamond = shapes.rotatedSquare(holder, 12, P.Bark, nil)
        return {
            frame = holder,
            setOpen = function(open)
                TweenService:Create(
                    diamond,
                    TweenInfo.new(theme.motion.hover, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { Rotation = open and 225 or 45, BackgroundColor3 = open and P.Fern or P.Bark }
                ):Play()
            end,
        }
    end

    ---------------------------------------------------------------- row shell
    -- Plank row: own grain + deterministic rotation + firefly hover stroke.
    function kit.row(parent, label, order, reserved, height)
        local index = nextRowIndex(parent)
        local row = shapes.plankRow(parent, index)
        row.Size = UDim2.new(1, 0, 0, height or theme.row.height)
        row.LayoutOrder = order or 1

        -- The plank's bottom edge and top hairline are decoration, not content.
        -- Keep them outside the horizontal list layout; otherwise their full-row
        -- widths push every label and control off the right side of the row.
        local card = Instance.new("Frame")
        card.Name = "Row"
        card.BackgroundTransparency = 1
        card.BorderSizePixel = 0
        card.Size = UDim2.fromScale(1, 1)
        card.Parent = row
        shapes.pad(card, 0, theme.gap.section, 0, theme.gap.section)
        local layout = prim.hlist(card, theme.gap.group)
        local text = prim.text(card, {
            role = "rowLabel",
            text = label or "",
            layoutOrder = 1,
            truncate = Enum.TextTruncate.AtEnd,
        })
        text.Size = UDim2.new(1, -(reserved or 24), 1, 0)

        local hover = Instance.new("UIStroke")
        hover.Color = P.Firefly
        hover.Thickness = 1
        hover.Transparency = 1
        hover.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        hover.Parent = row
        card.MouseEnter:Connect(function()
            TweenService:Create(
                hover,
                TweenInfo.new(theme.motion.hover, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Transparency = 0.4 }
            ):Play()
        end)
        card.MouseLeave:Connect(function()
            TweenService:Create(
                hover,
                TweenInfo.new(theme.motion.hover, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Transparency = 1 }
            ):Play()
        end)
        return card, text, layout
    end

    function kit.hoverable(card, clickable)
        if not clickable then
            return nil
        end
        card.Active = true
        return {
            onClick = function(callback)
                card.InputBegan:Connect(function(input)
                    if
                        input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch
                    then
                        callback()
                    end
                end)
            end,
        }
    end

    function kit.tipTextOf(target)
        return prim.tipText[target]
    end

    ---------------------------------------------------------------- toggle
    function kit.toggle(parent, label, getter, setter, order, tooltip)
        local card = kit.row(parent, label, order, 64, theme.row.caption)
        local track, knob, halo = shapes.knotToggle(card, 2)
        local first = true
        local function render()
            local enabled = getter() and true or false
            track.BackgroundColor3 = enabled and P.Fern or P.Moss
            track.BackgroundTransparency = enabled and 0 or 0.4
            halo.Transparency = enabled and 0.55 or 1
            local position = UDim2.fromOffset(enabled and 19 or 1, 2)
            if first then
                knob.Position = position
            else
                TweenService:Create(
                    knob,
                    TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                    { Position = position }
                ):Play()
            end
            first = false
        end
        render()
        local hit = shapes.touchTarget(card, 44)
        hit.Size = UDim2.fromOffset(44, 44)
        hit.AnchorPoint = Vector2.new(1, 0.5)
        hit.Position = UDim2.new(1, 0, 0.5, 0)
        hit.MouseButton1Click:Connect(function()
            setter(not getter())
            render()
        end)
        prim.tip(hit, tooltip)
        prim.tip(card, tooltip)
        return { row = card, render = render }
    end

    ---------------------------------------------------------------- slider
    local function roundValue(value, step, allowFloat)
        value = math.clamp(value, -math.huge, math.huge)
        if step then
            return math.floor(value / step + 0.5) * step
        elseif allowFloat then
            return math.floor(value * 10 + 0.5) / 10
        end
        return math.floor(value + 0.5)
    end

    local function formatValue(value, allowFloat, step)
        if step then
            local text = string.format("%.3f", value):gsub("0+$", ""):gsub("%.$", "")
            return text
        end
        if allowFloat then
            return string.format("%.1f", value)
        end
        return tostring(math.floor(value + 0.5))
    end

    local function numericBox(parent, width, order)
        local box = Instance.new("TextBox")
        box.Name = "Number"
        box.BackgroundColor3 = P.DeepForest
        box.BorderSizePixel = 0
        box.Size = UDim2.fromOffset(width, 26)
        box.LayoutOrder = order
        box.TextSize = 12
        box.ClearTextOnFocus = false
        box.TextColor3 = P.Parchment
        box.TextXAlignment = Enum.TextXAlignment.Center
        prim.setFont(box, "body")
        box.Parent = parent
        shapes.corner(box, theme.radius.plank)
        shapes.stroke(box, P.Bark, 2)
        return box
    end

    local function parseNumber(box)
        return tonumber((string.gsub(box.Text, "[^%d%.%-]", "")))
    end

    local function compactSlider(parent, label, desc, min, max, allowFloat, getter, setter, order, tooltip, step)
        local card = kit.row(parent, label, order, 176, 136)
        local box = numericBox(card, 80, 2)
        local suffix = prim.text(card, { role = "captionSub", text = tostring(desc or ""), layoutOrder = 3 })
        suffix.Size = UDim2.fromOffset(40, 26)
        local function render()
            box.Text = formatValue(tonumber(getter()) or min, allowFloat, step)
        end
        box.FocusLost:Connect(function()
            local value = parseNumber(box)
            if value then
                setter(math.clamp(roundValue(value, step, allowFloat), min, max))
            end
            render()
        end)
        render()
        prim.tip(card, tooltip)
        return { holder = card, render = render }
    end

    function kit.slider(parent, label, desc, min, max, allowFloat, getter, setter, order, tooltip, step)
        if context.COMPACT == true then
            return compactSlider(parent, label, desc, min, max, allowFloat, getter, setter, order, tooltip, step)
        end
        local holder = Instance.new("Frame")
        holder.Name = "Slider"
        holder.BackgroundTransparency = 1
        holder.AutomaticSize = Enum.AutomaticSize.Y
        holder.Size = UDim2.new(1, 0, 0, 0)
        holder.LayoutOrder = order or 1
        holder.Parent = parent
        prim.vlist(holder, 4)

        local head = Instance.new("Frame")
        head.Name = "Head"
        head.BackgroundTransparency = 1
        head.AutomaticSize = Enum.AutomaticSize.Y
        head.Size = UDim2.new(1, 0, 0, 0)
        head.LayoutOrder = 1
        head.Parent = holder
        prim.vlist(head, 1)
        local title = prim.text(head, { role = "rowLabel", text = label, layoutOrder = 1 })
        title.Size = UDim2.new(1, -64, 0, 18)
        local valueLabel = prim.text(head, { role = "value", text = "", layoutOrder = 2 })
        valueLabel.Size = UDim2.new(0, 64, 0, 18)
        valueLabel.Position = UDim2.new(1, -64, 0, 0)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        if desc and desc ~= "" then
            local caption = prim.text(head, { role = "captionSub", text = desc, layoutOrder = 3 })
            caption.Size = UDim2.new(1, 0, 0, 12)
        end

        local track, fill, thumbHolder, thumb = shapes.vineSlider(holder, 2)
        local function positionThumb(alpha)
            fill.Size = UDim2.new(alpha, 0, 0, 4)
            thumbHolder.Position = UDim2.new(alpha, 0, 0.5, 0)
        end
        local function render()
            local value = tonumber(getter()) or min
            local alpha = math.clamp((value - min) / math.max(max - min, 1e-9), 0, 1)
            positionThumb(alpha)
            valueLabel.Text = formatValue(value, allowFloat, step)
        end
        render()

        local dragging = false
        local function apply(x)
            if track.AbsoluteSize.X <= 0 then
                return
            end
            local alpha = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            setter(math.clamp(roundValue(min + (max - min) * alpha, step, allowFloat), min, max))
            render()
        end
        track.InputBegan:Connect(function(input)
            if
                input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                dragging = true
                apply(input.Position.X)
            end
        end)
        table.insert(
            context.sliderConnections,
            userInputService.InputChanged:Connect(function(input)
                if
                    dragging
                    and (
                        input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch
                    )
                then
                    apply(input.Position.X)
                end
            end)
        )
        table.insert(
            context.sliderConnections,
            userInputService.InputEnded:Connect(function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch
                then
                    dragging = false
                end
            end)
        )
        prim.tip(holder, tooltip)
        return { holder = holder, render = render }
    end

    ---------------------------------------------------------------- range
    function kit.rangeSlider(parent, label, desc, min, max, getter, setter, order, tooltip, suffix)
        if context.COMPACT == true then
            local card = kit.row(parent, label, order, 200, 200)
            local low = numericBox(card, 58, 2)
            local to = prim.text(card, { role = "captionSub", text = "to", layoutOrder = 3 })
            to.Size = UDim2.fromOffset(16, 26)
            to.TextXAlignment = Enum.TextXAlignment.Center
            local high = numericBox(card, 58, 4)
            local function render()
                local a, b = getter()
                low.Text = formatValue(tonumber(a) or min, false, nil)
                high.Text = formatValue(tonumber(b) or max, false, nil)
            end
            local function commit()
                local a, b = getter()
                local x = roundValue(parseNumber(low) or tonumber(a) or min, nil, false)
                local y = roundValue(parseNumber(high) or tonumber(b) or max, nil, false)
                x, y = math.clamp(x, min, max), math.clamp(y, min, max)
                if x > y then
                    x, y = y, x
                end
                setter(x, y)
                render()
            end
            low.FocusLost:Connect(commit)
            high.FocusLost:Connect(commit)
            render()
            prim.tip(card, tooltip)
            return { holder = card, render = render }
        end

        local holder = Instance.new("Frame")
        holder.Name = "RangeSlider"
        holder.BackgroundTransparency = 1
        holder.AutomaticSize = Enum.AutomaticSize.Y
        holder.Size = UDim2.new(1, 0, 0, 0)
        holder.LayoutOrder = order or 1
        holder.Parent = parent
        prim.vlist(holder, 4)

        local top = Instance.new("Frame")
        top.Name = "Top"
        top.BackgroundTransparency = 1
        top.Size = UDim2.new(1, 0, 0, 18)
        top.LayoutOrder = 1
        top.Parent = holder
        local title = prim.text(top, { role = "rowLabel", text = label, layoutOrder = 1 })
        title.Size = UDim2.new(1, -96, 1, 0)
        local valueLabel = prim.text(top, { role = "value", text = "", layoutOrder = 2 })
        valueLabel.Size = UDim2.new(0, 96, 1, 0)
        valueLabel.Position = UDim2.new(1, -96, 0, 0)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        if desc and desc ~= "" then
            local caption = prim.text(holder, { role = "captionSub", text = desc, layoutOrder = 2 })
            caption.Size = UDim2.new(1, 0, 0, 12)
        end

        local track, fill, _thumbHolder, _thumb = shapes.vineSlider(holder, 3)
        local lowMarker = Instance.new("Frame")
        lowMarker.Name = "Low"
        lowMarker.BackgroundColor3 = P.Firefly
        lowMarker.AnchorPoint = Vector2.new(0.5, 0.5)
        lowMarker.Size = UDim2.fromOffset(10, 18)
        lowMarker.ZIndex = 3
        lowMarker.Parent = track
        shapes.corner(lowMarker, 4)
        local highMarker = lowMarker:Clone()
        highMarker.Name = "High"
        highMarker.Parent = track

        local span = math.max(max - min, 1)
        local function pair()
            local a, b = getter()
            a = math.clamp(math.floor((tonumber(a) or min) + 0.5), min, max)
            b = math.clamp(math.floor((tonumber(b) or max) + 0.5), min, max)
            if b < a then
                a, b = b, a
            end
            return a, b
        end
        local function render()
            local a, b = pair()
            local alphaLow, alphaHigh = (a - min) / span, (b - min) / span
            fill.Position = UDim2.fromScale(alphaLow, 0.5)
            fill.Size = UDim2.new(alphaHigh - alphaLow, 0, 0, 4)
            lowMarker.Position = UDim2.fromScale(alphaLow, 0.5)
            highMarker.Position = UDim2.fromScale(alphaHigh, 0.5)
            valueLabel.Text = a == b and tostring(a) .. (suffix and " " .. suffix or "")
                or ("%d - %d"):format(a, b) .. (suffix and " " .. suffix or "")
        end
        render()

        local dragging
        local function valueAt(x)
            local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
            return math.floor(min + (max - min) * alpha + 0.5)
        end
        local function apply(x)
            if not dragging or track.AbsoluteSize.X <= 0 then
                return
            end
            local value = valueAt(x)
            local a, b = pair()
            if dragging == "both" then
                if value > b then
                    dragging = "hi"
                elseif value < a then
                    dragging = "lo"
                else
                    return
                end
            end
            if dragging == "lo" then
                a = math.min(value, b)
            else
                b = math.max(value, a)
            end
            setter(a, b)
            render()
        end
        track.InputBegan:Connect(function(input)
            if
                (input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch)
                and track.AbsoluteSize.X > 0
            then
                local value = valueAt(input.Position.X)
                local a, b = pair()
                dragging = if a == b and value == a
                    then "both"
                    else if value <= a then "lo" else if value >= b then "hi" else value - a <= b - value and "lo" or "hi"
                apply(input.Position.X)
            end
        end)
        table.insert(
            context.sliderConnections,
            userInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                then
                    apply(input.Position.X)
                end
            end)
        )
        table.insert(
            context.sliderConnections,
            userInputService.InputEnded:Connect(function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch
                then
                    dragging = nil
                end
            end)
        )
        prim.tip(holder, tooltip)
        return { holder = holder, render = render }
    end

    ---------------------------------------------------------------- inputs
    function kit.dropdown(parent, label, options, getter, setter, order, tooltip)
        local holder = Instance.new("Frame")
        holder.Name = "Dropdown"
        holder.BackgroundTransparency = 1
        holder.AutomaticSize = Enum.AutomaticSize.Y
        holder.Size = UDim2.new(1, 0, 0, 0)
        holder.LayoutOrder = order or 1
        holder.Parent = parent
        prim.vlist(holder, 4)

        local card = kit.row(holder, label, 1, 160, 150)
        local value = prim.text(card, { role = "captionKey", text = "", layoutOrder = 2 })
        value.Size = UDim2.fromOffset(118, 20)
        value.TextXAlignment = Enum.TextXAlignment.Right
        value.TextTruncate = Enum.TextTruncate.AtEnd
        local chevron = kit.chevron(card)
        local pressTarget = shapes.touchTarget(card, 44)
        pressTarget.AnchorPoint = Vector2.new(1, 0.5)
        pressTarget.Position = UDim2.new(1, 0, 0.5, 0)
        pressTarget.Size = UDim2.fromOffset(44, 44)

        local menu = Instance.new("Frame")
        menu.Name = "Menu"
        menu.BackgroundColor3 = P.Wood
        menu.BackgroundTransparency = 1 - theme.rowPlankAlpha
        menu.BorderSizePixel = 0
        menu.AutomaticSize = Enum.AutomaticSize.Y
        menu.Size = UDim2.new(1, 0, 0, 0)
        menu.Visible = false
        menu.LayoutOrder = 2
        menu.Parent = holder
        shapes.corner(menu, theme.radius.plank)
        shapes.stroke(menu, P.Bark, 2)
        shapes.grain(menu, 8)
        shapes.pad(menu, 4)
        local scrolling = Instance.new("ScrollingFrame")
        scrolling.Name = "Rows"
        scrolling.BackgroundTransparency = 1
        scrolling.BorderSizePixel = 0
        scrolling.Size = UDim2.new(1, 0, 0, 0)
        scrolling.AutomaticSize = Enum.AutomaticSize.Y
        scrolling.CanvasSize = UDim2.new()
        scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrolling.ScrollingDirection = Enum.ScrollingDirection.Y
        scrolling.ScrollBarThickness = 6
        scrolling.ScrollBarImageColor3 = P.Bark
        scrolling.Parent = menu
        local constraint = Instance.new("UISizeConstraint")
        constraint.MaxSize = Vector2.new(math.huge, 240)
        constraint.Parent = scrolling
        prim.vlist(scrolling, 2)

        local entries = {}
        local open = false
        local function setOpen(visible)
            open = visible
            chevron.setOpen(visible)
            menu.Visible = visible
        end
        local function render()
            local current = getter()
            value.Text = tostring(current)
            for key, entry in pairs(entries) do
                local selected = key == current
                entry.BackgroundColor3 = selected and P.Fern or P.Wood
                entry.TextColor3 = selected and P.LeafLight or P.Parchment
            end
        end
        for index, option in ipairs(options) do
            local button = Instance.new("TextButton")
            button.Name = tostring(option.value)
            button.BackgroundColor3 = P.Wood
            button.BackgroundTransparency = 0.25
            button.BorderSizePixel = 0
            button.Size = UDim2.new(1, 0, 0, 30)
            button.Text = option.label or tostring(option.value)
            button.TextSize = 12
            button.TextColor3 = P.Parchment
            button.LayoutOrder = index
            prim.setFont(button, "body")
            button.Parent = scrolling
            shapes.corner(button, theme.radius.plank)
            button.MouseEnter:Connect(function()
                button.BackgroundTransparency = 0
            end)
            button.MouseLeave:Connect(function()
                button.BackgroundTransparency = 0.25
            end)
            button.MouseButton1Click:Connect(function()
                setter(option.value)
                setOpen(false)
                render()
            end)
            entries[option.value] = button
        end
        render()
        pressTarget.MouseButton1Click:Connect(function()
            setOpen(not open)
        end)
        prim.tip(pressTarget, tooltip)
        return { holder = holder, render = render }
    end

    function kit.textInput(parent, label, getter, setter, order, tooltip, placeholder)
        local card = kit.row(parent, label, order, 200, 196)
        local input = Instance.new("TextBox")
        input.Name = "Input"
        input.BackgroundColor3 = P.DeepForest
        input.BorderSizePixel = 0
        input.Size = UDim2.fromOffset(180, 26)
        input.LayoutOrder = 2
        input.Text = tostring(getter() or "")
        input.PlaceholderText = placeholder or "empty = hidden"
        input.PlaceholderColor3 = P.Parchment
        input.TextColor3 = P.Parchment
        input.TextSize = 12
        input.ClearTextOnFocus = false
        input.TextXAlignment = Enum.TextXAlignment.Left
        input.TextTruncate = Enum.TextTruncate.AtEnd
        prim.setFont(input, "body")
        input.Parent = card
        shapes.corner(input, theme.radius.plank)
        shapes.stroke(input, P.Bark, 2)
        shapes.pad(input, 0, 8, 0, 8)
        local focusStroke = shapes.stroke(input, P.Firefly, 1, 1)
        local function render()
            input.Text = tostring(getter() or "")
        end
        input.Focused:Connect(function()
            focusStroke.Transparency = 0
        end)
        input.FocusLost:Connect(function()
            focusStroke.Transparency = 1
            setter(input.Text)
        end)
        prim.tip(card, tooltip)
        return { row = card, render = render, box = input }
    end

    ---------------------------------------------------------------- list input
    function kit.listInput(parent, label, desc, getter, setter, order, placeholder, tooltip, maxRows)
        local rowHeight, gap, inset = 26, 4, 4
        local limit = maxRows or 5
        local holder = Instance.new("Frame")
        holder.Name = "ListInput"
        holder.BackgroundTransparency = 1
        holder.AutomaticSize = Enum.AutomaticSize.Y
        holder.Size = UDim2.new(1, 0, 0, 0)
        holder.LayoutOrder = order or 1
        holder.Parent = parent
        prim.vlist(holder, 4)
        local head = Instance.new("Frame")
        head.Name = "Head"
        head.BackgroundTransparency = 1
        head.AutomaticSize = Enum.AutomaticSize.Y
        head.Size = UDim2.new(1, 0, 0, 0)
        head.LayoutOrder = 1
        head.Parent = holder
        prim.vlist(head, 1)
        local title = prim.text(head, { role = "rowLabel", text = label, layoutOrder = 1 })
        title.Size = UDim2.new(1, 0, 0, 18)
        if desc and desc ~= "" then
            local caption = prim.text(head, { role = "captionSub", text = desc, layoutOrder = 2 })
            caption.Size = UDim2.new(1, 0, 0, 12)
        end

        local list = Instance.new("ScrollingFrame")
        list.Name = "List"
        list.BackgroundColor3 = P.DeepForest
        list.BorderSizePixel = 0
        list.LayoutOrder = 2
        list.Size = UDim2.new(1, 0, 0, 34)
        list.CanvasSize = UDim2.new()
        list.AutomaticCanvasSize = Enum.AutomaticSize.Y
        list.ScrollingDirection = Enum.ScrollingDirection.Y
        list.Parent = holder
        shapes.corner(list, theme.radius.plank)
        shapes.stroke(list, P.Bark, 2)
        shapes.scrollbar(list)
        shapes.pad(list, inset)
        prim.vlist(list, gap)

        local entries, rendering = {}, false
        local function clean(value)
            return (tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", ""))
        end
        local function fit()
            local count = math.clamp(#entries, 1, limit)
            list.Size = UDim2.new(1, 0, 0, inset * 2 + count * rowHeight + (count - 1) * gap)
        end
        local function commit()
            if rendering then
                return
            end
            local values = {}
            for _, entry in ipairs(entries) do
                local value = clean(entry.Text)
                if value ~= "" then
                    values[#values + 1] = value
                end
            end
            setter(values)
        end
        local function addEntry(text)
            local entry = Instance.new("TextBox")
            entry.Name = "Entry"
            entry.BackgroundColor3 = P.Wood
            entry.BackgroundTransparency = 0.35
            entry.BorderSizePixel = 0
            entry.Size = UDim2.new(1, 0, 0, rowHeight)
            entry.LayoutOrder = #entries + 1
            entry.Text = text or ""
            entry.PlaceholderText = placeholder or "Add a name"
            entry.PlaceholderColor3 = P.Parchment
            entry.TextColor3 = P.Parchment
            entry.TextSize = 12
            entry.ClearTextOnFocus = false
            entry.TextXAlignment = Enum.TextXAlignment.Left
            prim.setFont(entry, "body")
            entry.Parent = list
            shapes.corner(entry, theme.radius.plank)
            shapes.pad(entry, 0, 8, 0, 8)
            entries[#entries + 1] = entry
            entry:GetPropertyChangedSignal("Text"):Connect(function()
                if rendering then
                    return
                end
                if entries[#entries] == entry and clean(entry.Text) ~= "" then
                    addEntry("")
                    fit()
                    task.defer(function()
                        if list.Parent then
                            list.CanvasPosition =
                                Vector2.new(0, math.max(0, list.AbsoluteCanvasSize.Y - list.AbsoluteWindowSize.Y))
                        end
                    end)
                end
                commit()
            end)
            entry.FocusLost:Connect(function()
                if rendering then
                    return
                end
                for index = #entries - 1, 1, -1 do
                    local candidate = entries[index]
                    if clean(candidate.Text) == "" then
                        table.remove(entries, index)
                        candidate:Destroy()
                    end
                end
                if #entries == 0 or clean(entries[#entries].Text) ~= "" then
                    addEntry("")
                end
                fit()
                commit()
            end)
            return entry
        end
        local function render()
            rendering = true
            for _, entry in ipairs(entries) do
                entry:Destroy()
            end
            table.clear(entries)
            local values = getter()
            if type(values) == "table" then
                for _, value in ipairs(values) do
                    local text = clean(value)
                    if text ~= "" then
                        addEntry(text)
                    end
                end
            end
            addEntry("")
            rendering = false
            fit()
        end
        render()
        prim.tip(holder, tooltip)
        return {
            holder = holder,
            render = render,
            toBottom = function()
                task.defer(function()
                    if list.Parent then
                        list.CanvasPosition =
                            Vector2.new(0, math.max(0, list.AbsoluteCanvasSize.Y - list.AbsoluteWindowSize.Y))
                    end
                end)
            end,
        }
    end

    ---------------------------------------------------------------- colour
    function kit.colorRow(parent, label, getter, setter, order, tooltip)
        local holder = Instance.new("Frame")
        holder.Name = "Color"
        holder.BackgroundTransparency = 1
        holder.AutomaticSize = Enum.AutomaticSize.Y
        holder.Size = UDim2.new(1, 0, 0, 0)
        holder.LayoutOrder = order or 1
        holder.Parent = parent
        prim.vlist(holder, 4)
        local card = kit.row(holder, label, 1, nil, 54)
        local swatch = Instance.new("Frame")
        swatch.Name = "Swatch"
        swatch.BackgroundColor3 = getter()
        swatch.BorderSizePixel = 0
        swatch.Size = UDim2.fromOffset(46, 22)
        swatch.LayoutOrder = 2
        swatch.Parent = card
        shapes.corner(swatch, theme.radius.plank)
        shapes.stroke(swatch, P.Bark, 2)

        local picker = Instance.new("Frame")
        picker.Name = "Picker"
        picker.BackgroundTransparency = 1
        picker.Size = UDim2.new(1, 0, 0, 140)
        picker.Visible = false
        picker.LayoutOrder = 2
        picker.Parent = holder
        prim.hlist(picker, theme.gap.group)

        local sv = Instance.new("Frame")
        sv.Name = "SV"
        sv.BackgroundColor3 = P.LeafLight
        sv.BorderSizePixel = 0
        sv.Size = UDim2.new(1, -22, 1, 0)
        sv.Active = true
        sv.LayoutOrder = 1
        sv.Parent = picker
        shapes.corner(sv, theme.radius.plank)
        prim.flexFill(sv, 22)
        local saturation = Instance.new("UIGradient")
        saturation.Rotation = 0
        saturation.Parent = sv
        local shade = Instance.new("Frame")
        shade.Name = "Shade"
        shade.BackgroundColor3 = P.DeepForest
        shade.BorderSizePixel = 0
        shade.Size = UDim2.fromScale(1, 1)
        shade.Parent = sv
        shapes.corner(shade, theme.radius.plank)
        local valueGradient = Instance.new("UIGradient")
        valueGradient.Rotation = 90
        valueGradient.Transparency =
            NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
        valueGradient.Parent = shade
        local cursor = Instance.new("Frame")
        cursor.Name = "Cursor"
        cursor.BackgroundTransparency = 1
        cursor.AnchorPoint = Vector2.new(0.5, 0.5)
        cursor.Size = UDim2.fromOffset(12, 12)
        cursor.ZIndex = 4
        cursor.Parent = sv
        shapes.corner(cursor, 6)
        shapes.stroke(cursor, P.Parchment, 2)

        local hue = Instance.new("Frame")
        hue.Name = "Hue"
        hue.BackgroundColor3 = P.Fern
        hue.BorderSizePixel = 0
        hue.Size = UDim2.new(0, 14, 1, 0)
        hue.Active = true
        hue.LayoutOrder = 2
        hue.Parent = picker
        shapes.corner(hue, theme.radius.plank)
        local hueGradient = Instance.new("UIGradient")
        hueGradient.Rotation = 90
        hueGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        })
        hueGradient.Parent = hue
        local marker = Instance.new("Frame")
        marker.Name = "Marker"
        marker.BackgroundColor3 = P.Parchment
        marker.BorderSizePixel = 0
        marker.AnchorPoint = Vector2.new(0.5, 0.5)
        marker.Size = UDim2.fromOffset(20, 3)
        marker.Position = UDim2.new(0.5, 0, 0, 0)
        marker.ZIndex = 4
        marker.Parent = hue
        shapes.corner(marker, 2)

        local h, s, v = getter():ToHSV()
        local function render()
            local color = Color3.fromHSV(h, s, v)
            swatch.BackgroundColor3 = color
            saturation.Color = ColorSequence.new(P.LeafLight, Color3.fromHSV(h, 1, 1))
            cursor.Position = UDim2.fromScale(s, 1 - v)
            marker.Position = UDim2.new(0.5, 0, h, 0)
            setter(color)
        end
        render()
        local draggingSV, draggingHue = false, false
        sv.InputBegan:Connect(function(input)
            if
                (input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch)
                and sv.AbsoluteSize.X > 0
            then
                draggingSV = true
                s = math.clamp((input.Position.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((input.Position.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
                render()
            end
        end)
        hue.InputBegan:Connect(function(input)
            if
                (input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch)
                and hue.AbsoluteSize.Y > 0
            then
                draggingHue = true
                h = math.clamp((input.Position.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 1)
                render()
            end
        end)
        table.insert(
            context.sliderConnections,
            userInputService.InputChanged:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseMovement
                    and input.UserInputType ~= Enum.UserInputType.Touch
                then
                    return
                end
                if draggingSV and sv.AbsoluteSize.X > 0 then
                    s = math.clamp((input.Position.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((input.Position.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
                    render()
                end
                if draggingHue and hue.AbsoluteSize.Y > 0 then
                    h = math.clamp((input.Position.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 1)
                    render()
                end
            end)
        )
        table.insert(
            context.sliderConnections,
            userInputService.InputEnded:Connect(function()
                draggingSV, draggingHue = false, false
            end)
        )
        local press = shapes.touchTarget(card, 44)
        press.AnchorPoint = Vector2.new(1, 0.5)
        press.Position = UDim2.new(1, 0, 0.5, 0)
        press.MouseButton1Click:Connect(function()
            picker.Visible = not picker.Visible
        end)
        prim.tip(card, tooltip)
        return { holder = holder, render = render }
    end

    function kit.colorWheel(parent, label, getter, setter, order, tooltip)
        local holder = Instance.new("Frame")
        holder.Name = "ColorWheel"
        holder.BackgroundTransparency = 1
        holder.AutomaticSize = Enum.AutomaticSize.Y
        holder.Size = UDim2.new(1, 0, 0, 0)
        holder.LayoutOrder = order or 1
        holder.Parent = parent
        prim.vlist(holder, 4)
        local card = kit.row(holder, label, 1, nil, 54)
        local swatch = Instance.new("Frame")
        swatch.Name = "Swatch"
        swatch.BorderSizePixel = 0
        swatch.Size = UDim2.fromOffset(46, 22)
        swatch.LayoutOrder = 2
        swatch.Parent = card
        shapes.corner(swatch, theme.radius.plank)
        shapes.stroke(swatch, P.Bark, 2)

        local picker = Instance.new("Frame")
        picker.Name = "Picker"
        picker.BackgroundTransparency = 1
        picker.Size = UDim2.new(1, 0, 0, 180)
        picker.Visible = false
        picker.LayoutOrder = 2
        picker.Parent = holder
        local wheel = Instance.new("Frame")
        wheel.Name = "Wheel"
        wheel.BackgroundTransparency = 1
        wheel.AnchorPoint = Vector2.new(0.5, 0)
        wheel.Position = UDim2.new(0.5, 0, 0, 0)
        wheel.Size = UDim2.fromOffset(150, 150)
        wheel.Active = true
        wheel.Parent = picker
        for index = 0, 35 do
            local spoke = Instance.new("Frame")
            spoke.Name = "Spoke"
            spoke.BorderSizePixel = 0
            spoke.BackgroundColor3 = P.Parchment
            spoke.AnchorPoint = Vector2.new(0.5, 0.5)
            spoke.Position = UDim2.fromScale(0.5, 0.5)
            spoke.Size = UDim2.fromOffset(150, 10)
            spoke.Rotation = index * 360 / 72
            spoke.Parent = wheel
            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV((index + 36) % 72 / 72, 1, 1)),
                ColorSequenceKeypoint.new(0.5, P.Parchment),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(index / 72, 1, 1)),
            })
            gradient.Parent = spoke
        end
        local shade = Instance.new("Frame")
        shade.Name = "Shade"
        shade.BorderSizePixel = 0
        shade.BackgroundColor3 = P.DeepForest
        shade.Size = UDim2.fromScale(1, 1)
        shade.ZIndex = 3
        shade.Parent = wheel
        shapes.corner(shade, 150)
        local rim = Instance.new("Frame")
        rim.Name = "Rim"
        rim.BackgroundTransparency = 1
        rim.Size = UDim2.fromScale(1, 1)
        rim.ZIndex = 4
        rim.Parent = wheel
        shapes.corner(rim, 150)
        shapes.stroke(rim, P.Bark, 2)
        local cursor = Instance.new("Frame")
        cursor.Name = "Cursor"
        cursor.BackgroundTransparency = 1
        cursor.AnchorPoint = Vector2.new(0.5, 0.5)
        cursor.Size = UDim2.fromOffset(12, 12)
        cursor.ZIndex = 5
        cursor.Parent = wheel
        shapes.corner(cursor, 6)
        shapes.stroke(cursor, P.Parchment, 2)
        local brightness = Instance.new("Frame")
        brightness.Name = "Brightness"
        brightness.BorderSizePixel = 0
        brightness.BackgroundColor3 = P.Parchment
        brightness.AnchorPoint = Vector2.new(0.5, 0)
        brightness.Position = UDim2.new(0.5, 0, 0, 162)
        brightness.Size = UDim2.fromOffset(150, 12)
        brightness.Active = true
        brightness.Parent = picker
        shapes.corner(brightness, theme.radius.plank)
        shapes.stroke(brightness, P.Bark, 1)
        local brightnessGradient = Instance.new("UIGradient")
        brightnessGradient.Parent = brightness
        local marker = Instance.new("Frame")
        marker.Name = "Marker"
        marker.BackgroundColor3 = P.Firefly
        marker.BorderSizePixel = 0
        marker.AnchorPoint = Vector2.new(0.5, 0.5)
        marker.Size = UDim2.fromOffset(4, 18)
        marker.ZIndex = 4
        marker.Parent = brightness
        shapes.corner(marker, 2)

        local h, s, v = getter():ToHSV()
        local function render(increment)
            local color = Color3.fromHSV(h, s, v)
            swatch.BackgroundColor3 = color
            shade.BackgroundTransparency = v
            local angle = h * 2 * math.pi
            cursor.Position = UDim2.fromScale(0.5 + math.cos(angle) * s * 0.5, 0.5 + math.sin(angle) * s * 0.5)
            brightnessGradient.Color = ColorSequence.new(P.DeepForest, Color3.fromHSV(h, s, 1))
            marker.Position = UDim2.new(v, 0, 0.5, 0)
            if increment ~= nil then
                setter(color)
            end
            return color
        end
        render()
        local draggingWheel, draggingBrightness = false, false
        wheel.InputBegan:Connect(function(input)
            if
                (input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch)
                and wheel.AbsoluteSize.X > 0
            then
                draggingWheel = true
                local center = wheel.AbsolutePosition + wheel.AbsoluteSize * 0.5
                local dx, dy = input.Position.X - center.X, input.Position.Y - center.Y
                h = math.atan2(dy, dx) / (2 * math.pi) % 1
                s = math.clamp(math.sqrt(dx * dx + dy * dy) / (wheel.AbsoluteSize.X * 0.5), 0, 1)
                render(1)
            end
        end)
        brightness.InputBegan:Connect(function(input)
            if
                (input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch)
                and brightness.AbsoluteSize.X > 0
            then
                draggingBrightness = true
                v = math.clamp((input.Position.X - brightness.AbsolutePosition.X) / brightness.AbsoluteSize.X, 0, 1)
                render(1)
            end
        end)
        table.insert(
            context.sliderConnections,
            userInputService.InputChanged:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseMovement
                    and input.UserInputType ~= Enum.UserInputType.Touch
                then
                    return
                end
                if draggingWheel and wheel.AbsoluteSize.X > 0 then
                    local center = wheel.AbsolutePosition + wheel.AbsoluteSize * 0.5
                    local dx, dy = input.Position.X - center.X, input.Position.Y - center.Y
                    h = math.atan2(dy, dx) / (2 * math.pi) % 1
                    s = math.clamp(math.sqrt(dx * dx + dy * dy) / (wheel.AbsoluteSize.X * 0.5), 0, 1)
                    render(1)
                end
                if draggingBrightness and brightness.AbsoluteSize.X > 0 then
                    v = math.clamp(
                        (input.Position.X - brightness.AbsolutePosition.X) / brightness.AbsoluteSize.X,
                        0,
                        1
                    )
                    render(1)
                end
            end)
        )
        table.insert(
            context.sliderConnections,
            userInputService.InputEnded:Connect(function()
                draggingWheel, draggingBrightness = false, false
            end)
        )
        local press = shapes.touchTarget(card, 44)
        press.AnchorPoint = Vector2.new(1, 0.5)
        press.Position = UDim2.new(1, 0, 0.5, 0)
        press.MouseButton1Click:Connect(function()
            picker.Visible = not picker.Visible
        end)
        prim.tip(card, tooltip)
        return { holder = holder, render = render }
    end

    ---------------------------------------------------------------- buttons
    function kit.button(parent, text, variant, onClick, order, tooltip)
        local button, label = shapes.stoneButton(parent, text, order)
        if variant == "primary" or variant == "accent" then
            button.BackgroundColor3 = P.Firefly
            label.TextColor3 = P.DeepForest
        elseif variant == "danger" then
            button.BackgroundColor3 = P.Bark
            label.TextColor3 = P.Parchment
            shapes.stroke(button, theme.danger, 2)
        end
        if onClick then
            button.MouseButton1Click:Connect(onClick)
        end
        prim.pressable(button)
        prim.tip(button, tooltip)
        return button
    end

    function kit.buttonRow(parent, order)
        local buttons = Instance.new("Frame")
        buttons.Name = "Buttons"
        buttons.BackgroundTransparency = 1
        buttons.Size = UDim2.new(1, 0, 0, theme.touch)
        buttons.LayoutOrder = order or 1
        buttons.Parent = parent
        prim.hlist(buttons, theme.gap.group)
        local count, list = 0, {}
        return {
            frame = buttons,
            add = function(text, variant, onClick, tooltip)
                count += 1
                local button = shapes.leafButton(buttons, text, variant, onClick, count)
                button.Size = UDim2.new(0, 0, 1, 0)
                if text and #tostring(text) > 0 then
                    local label = button:FindFirstChild("Label")
                    if label then
                        label.Text = tostring(text)
                    end
                end
                prim.tip(button, tooltip)
                list[count] = button
                for index, entry in ipairs(list) do
                    entry.Size = UDim2.new(1 / count, -(theme.gap.group * (count - 1)) / count, 1, 0)
                    entry.Visible = true
                    local label = entry:FindFirstChild("Label")
                    if label then
                        label.Visible = count <= 2 or #list == 1
                    end
                    if label and count > 2 then
                        label.TextScaled = true
                        label.TextSize = 10
                    end
                end
                return button
            end,
        }
    end

    ---------------------------------------------------------------- section
    function kit.section(parent, title, order, desc)
        local section = Instance.new("Frame")
        section.Name = "Section"
        section.BackgroundTransparency = 1
        section.AutomaticSize = Enum.AutomaticSize.Y
        section.Size = UDim2.new(1, 0, 0, 0)
        section.LayoutOrder = order or 1
        section.Parent = parent
        prim.vlist(section, theme.gap.row)

        local head = Instance.new("TextButton")
        head.Name = "SectionHead"
        head.AutoButtonColor = false
        head.BackgroundColor3 = P.Wood
        head.BackgroundTransparency = 0.35
        head.BorderSizePixel = 0
        head.Size = UDim2.new(1, 0, 0, 30)
        head.Text = ""
        head.LayoutOrder = 1
        head.Parent = section
        shapes.corner(head, theme.radius.plank)
        shapes.grain(head, 90)
        local headStroke = shapes.stroke(head, P.Bark, 2)
        local titleLabel = prim.text(head, {
            role = "section",
            text = title,
            position = UDim2.fromOffset(12, 0),
            size2 = UDim2.new(1, -48, 1, 0),
        })
        local chevron = kit.chevron(head)
        chevron.frame.AnchorPoint = Vector2.new(1, 0.5)
        chevron.frame.Position = UDim2.new(1, -12, 0.5, 0)

        local content = Instance.new("Frame")
        content.Name = "Content"
        content.BackgroundColor3 = P.DeepForest
        content.BackgroundTransparency = 0.55
        content.BorderSizePixel = 0
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.Size = UDim2.new(1, 0, 0, 0)
        content.Visible = false
        content.LayoutOrder = 2
        content.Parent = section
        shapes.corner(content, theme.radius.stone)
        shapes.stroke(content, P.Bark, 2)
        shapes.pad(content, theme.gap.row, theme.gap.row, theme.gap.row, theme.gap.row)
        prim.vlist(content, theme.gap.row)

        if desc and desc ~= "" then
            local description = prim.text(content, {
                role = "sectionDesc",
                text = desc,
                layoutOrder = -1000,
                wrapped = true,
                yAlign = Enum.TextYAlignment.Top,
                transparency = 0.30,
            })
            description.AutomaticSize = Enum.AutomaticSize.Y
            description.Size = UDim2.new(1, 0, 0, 0)
            shapes.pad(description, 2, 4, 2, 4)
        end

        local open = false
        local function setOpen(value, instant)
            value = value == true
            if value == open and not instant then
                return
            end
            open = value
            chevron.setOpen(open)
            titleLabel.TextColor3 = open and P.LeafLight or P.Parchment
            headStroke.Transparency = open and 0.2 or 1
            content.Visible = open
        end
        setOpen(false, true)
        head.MouseButton1Click:Connect(function()
            setOpen(not open)
        end)
        prim.tip(head, desc)

        sectionReg[section] = {
            head = head,
            content = content,
            setOpen = setOpen,
            isOpen = function()
                return open
            end,
        }
        return {
            holder = section,
            content = content,
            setOpen = function(value, instant)
                if not value then
                    setOpen(false, instant)
                end
            end,
            isOpen = function()
                return open
            end,
        }
    end

    ---------------------------------------------------------------- windows
    -- Generic bark-framed window used by the bug-report sub views.  No pin, no
    -- accent bar: branch + hanging sign + stone body + footer strip.
    function kit.window(parent, options)
        options = options or {}
        local frame = shapes.stoneWindow(parent)
        frame.Name = options.name or "Window"
        frame.Size = UDim2.fromOffset(options.width or 420, options.height or 460)
        frame.Position = options.position or UDim2.fromOffset(60, 60)
        frame.Visible = options.visible ~= false
        frame.Active = true
        frame.ClipsDescendants = true
        frame:SetAttribute("hlWin", true)

        local header = Instance.new("Frame")
        header.Name = "Header"
        header.BackgroundTransparency = 1
        header.Size = UDim2.new(1, 0, 0, theme.header)
        header.Active = true
        header.Parent = frame
        shapes.branch(header, frame.Size.X.Offset)
        shapes.titleSign(header, options.title or "Window")
        prim.vlist(frame, 0)

        local body = Instance.new("ScrollingFrame")
        body.Name = "Body"
        body.BackgroundTransparency = 1
        body.BorderSizePixel = 0
        body.Position = UDim2.fromOffset(0, theme.header)
        body.Size = UDim2.new(1, 0, 1, -(theme.header + theme.footer))
        body.CanvasSize = UDim2.new()
        body.AutomaticCanvasSize = Enum.AutomaticSize.Y
        body.ScrollingDirection = Enum.ScrollingDirection.Y
        body.Parent = frame
        shapes.scrollbar(body)
        shapes.pad(body, 12, 12, 12, 12)
        prim.vlist(body, theme.gap.row)
        return {
            frame = frame,
            header = header,
            body = body,
            fit = function() end,
            isPinned = function()
                return false
            end,
            setPinned = function() end,
        }
    end

    function kit.makeDraggable(handle, frame)
        local dragging, start, origin = false, nil, nil
        handle.InputBegan:Connect(function(input)
            if
                input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                dragging, start, origin = true, input.Position, frame.Position
            end
        end)
        handle.InputEnded:Connect(function()
            dragging = false
        end)
        table.insert(
            context.sliderConnections,
            userInputService.InputChanged:Connect(function(input)
                if
                    dragging
                    and (
                        input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch
                    )
                then
                    local delta = input.Position - start
                    frame.Position = UDim2.new(
                        origin.X.Scale,
                        origin.X.Offset + delta.X,
                        origin.Y.Scale,
                        origin.Y.Offset + delta.Y
                    )
                end
            end)
        )
    end

    -- the old uiLibrary exported this; the colour picker and window drag use it
    local guiService = context.getService("GuiService")
    local inputService = context.UserInputService
    local function windowOf(object)
        local value = object
        while value and not (value.GetAttribute and value:GetAttribute("hlWin")) do
            value = value.Parent
        end
        return value
    end
    local function orderOf(object)
        local parent = object.Parent
        return object.ZIndex * 100000 + (parent and table.find(parent:GetChildren(), object) or 0)
    end
    local function pointer(input)
        if input and input.UserInputType == Enum.UserInputType.Touch then
            local inset = guiService:GetGuiInset()
            return input.Position.X + inset.X, input.Position.Y + inset.Y
        end
        local location = inputService:GetMouseLocation()
        return location.X, location.Y
    end
    local function topWindowAt(x, y, parent)
        local best, bestOrder
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible and child:GetAttribute("hlWin") then
                local pos, size = child.AbsolutePosition, child.AbsoluteSize
                if x >= pos.X and y >= pos.Y and x <= pos.X + size.X and y <= pos.Y + size.Y then
                    local order = orderOf(child)
                    if not best or order > bestOrder then
                        best, bestOrder = child, order
                    end
                end
            end
        end
        return best
    end
    local function pressOnTop(object, input)
        local win = windowOf(object)
        if not win or not win.Parent then
            return true
        end
        local x, y = pointer(input)
        local hit = topWindowAt(x, y, win.Parent)
        return hit == nil or hit == win
    end
    kit.pressOnTop = pressOnTop
    context.pressOnTop = pressOnTop

    context.tipTextOf = kit.tipTextOf
    context.UIKit = kit
end
