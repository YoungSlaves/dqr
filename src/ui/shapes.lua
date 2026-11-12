-- ui/shapes.lua -- every shape construction in the build.
--
-- This is the only module that creates the three ScreenGuis, every rotated
-- frame, every wood-grain UIGradient and every firefly.  Sections and widgets
-- compose these helpers; they never build a rotated shape inline.
--
-- Roblox reality this file is written against:
--   * UICorner has one radius for all four corners.  A leaf/diamond is a
--     rotated square with CornerRadius = UDim.new(0.5, 0); a notch is a square
--     patch over a corner; nothing here fakes per-corner radii.
--   * a rotated GuiObject hit-tests rotated but has a larger bounds box, so
--     every rotated decoration sits inside a non-rotated >=44x44 wrapper that
--     owns the click.
--   * ZIndex orders descendants inside ONE ScreenGui.  Ordering between GUIs is
--     DisplayOrder, hence the three-GUI model below.
return function(context)
    local theme = context.Theme
    local P = theme.palette
    local TweenService = context.getService("TweenService")
    local runService = context.RunService

    local shapes = {}
    local grainCount = 0
    local rotatedCount = 0
    local guisCreated = 0
    local fireflies = {}
    local guis = {}

    ------------------------------------------------------------------ gui model
    -- Fixed layers.  Exactly three, all Sibling, IgnoreGuiInset, ResetOnSpawn
    -- false.  Loading and menu share DisplayOrder 50 because they never coexist.
    local LAYERS = {
        ambient = { name = "DQRAmbient", order = 40, active = false },
        menu = { name = "DQRRoot", order = 50, active = true },
        loading = { name = "DQRLoading", order = 50, active = false },
    }

    local function parentForGui()
        local ok, holder = pcall(function()
            if type(gethui) == "function" then
                return gethui()
            end
            return nil
        end)
        if ok and holder then
            return holder
        end
        local player = context.LocalPlayer
        if player then
            local playerGui = player:FindFirstChildOfClass("PlayerGui")
            if playerGui then
                return playerGui
            end
        end
        return context.getService("CoreGui")
    end

    function shapes.ensureGui(layer)
        local spec = LAYERS[layer]
        assert(spec, "unknown gui layer: " .. tostring(layer))
        local existing = guis[layer]
        if existing and existing.Parent then
            return existing
        end
        local gui = Instance.new("ScreenGui")
        gui.Name = spec.name
        gui.DisplayOrder = spec.order
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn = false
        gui.Active = spec.active
        gui.Parent = parentForGui()
        guis[layer] = gui
        guisCreated += 1
        return gui
    end

    function shapes.gui(layer)
        return guis[layer]
    end

    function shapes.menuGui()
        return shapes.ensureGui("menu")
    end

    function shapes.destroyGuis()
        -- teardown order is a hard rule: menu, then ambient, then loading
        for _, layer in ipairs({ "menu", "ambient", "loading" }) do
            local gui = guis[layer]
            if gui and gui.Parent then
                pcall(function()
                    gui:Destroy()
                end)
            end
            guis[layer] = nil
        end
    end

    function shapes.assertTeardown()
        for _, layer in ipairs({ "ambient", "menu", "loading" }) do
            local gui = guis[layer]
            assert(gui == nil or gui.Parent == nil, "gui still parented: " .. layer)
        end
        assert(#fireflies == 0, "fireflies still alive: " .. #fireflies)
    end

    ---------------------------------------------------------------- primitives
    local function corner(parent, radius)
        local object = Instance.new("UICorner")
        object.CornerRadius = UDim.new(0, radius or theme.radius.plank)
        if typeof(radius) == "UDim" then
            object.CornerRadius = radius
        end
        object.Parent = parent
        return object
    end
    shapes.corner = corner

    local function pill(parent)
        local object = Instance.new("UICorner")
        object.CornerRadius = UDim.new(1, 0)
        object.Parent = parent
        return object
    end

    function shapes.stroke(parent, color, thickness, transparency)
        local object = Instance.new("UIStroke")
        object.Color = color or P.Bark
        object.Thickness = thickness or theme.stroke.bark
        object.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        if transparency then
            object.Transparency = transparency
        end
        object.Parent = parent
        return object
    end

    function shapes.pad(parent, all, right, bottom, left)
        local object = Instance.new("UIPadding")
        object.PaddingTop = UDim.new(0, all or 0)
        object.PaddingRight = UDim.new(0, right or all or 0)
        object.PaddingBottom = UDim.new(0, bottom or all or 0)
        object.PaddingLeft = UDim.new(0, left or right or all or 0)
        object.Parent = parent
        return object
    end

    -- Wood grain: one UIGradient per face, never shared.  Four colour keypoints.
    function shapes.grain(parent, rotation)
        grainCount += 1
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, P.Bark),
            ColorSequenceKeypoint.new(0.35, P.Wood),
            ColorSequenceKeypoint.new(0.7, P.Bark),
            ColorSequenceKeypoint.new(1, P.Wood),
        })
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.55),
            NumberSequenceKeypoint.new(0.35, 0.35),
            NumberSequenceKeypoint.new(0.7, 0.5),
            NumberSequenceKeypoint.new(1, 0.3),
        })
        gradient.Rotation = rotation or 90
        gradient.Parent = parent
        return gradient
    end

    function shapes.grainCount()
        return grainCount
    end

    function shapes.rotatedCount()
        return rotatedCount
    end

    function shapes.guiCount()
        return guisCreated
    end

    -- rotated square: leaf / diamond / knot end
    function shapes.rotatedSquare(parent, size, fill, strokeColor, swatch)
        rotatedCount += 1
        local object = Instance.new("Frame")
        object.Name = "Leaf"
        object.AnchorPoint = Vector2.new(0.5, 0.5)
        object.Position = UDim2.fromScale(0.5, 0.5)
        object.Size = UDim2.fromOffset(size, size)
        object.Rotation = 45
        object.BorderSizePixel = 0
        object.BackgroundColor3 = fill
        if swatch then
            object.BackgroundTransparency = swatch
        end
        object.Parent = parent
        local objectCorner = Instance.new("UICorner")
        objectCorner.CornerRadius = UDim.new(0.5, 0)
        objectCorner.Parent = object
        if strokeColor then
            local objectStroke = Instance.new("UIStroke")
            objectStroke.Color = strokeColor
            objectStroke.Thickness = 2
            objectStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            objectStroke.Parent = object
        end
        return object
    end

    -- the one non-rotated click target: 44x44
    function shapes.touchTarget(parent, size)
        local wrapper = Instance.new("TextButton")
        wrapper.Name = "TouchTarget"
        wrapper.Text = ""
        wrapper.AutoButtonColor = false
        wrapper.BackgroundTransparency = 1
        wrapper.BorderSizePixel = 0
        wrapper.Size = UDim2.fromOffset(size or theme.touch, size or theme.touch)
        wrapper.Parent = parent
        return wrapper
    end

    ------------------------------------------------------------- window chrome
    -- Branch: 6px bark plank + two darker knots.
    function shapes.branch(parent, width)
        local branch = Instance.new("Frame")
        branch.Name = "Branch"
        branch.BackgroundColor3 = P.Bark
        branch.BorderSizePixel = 0
        branch.Size = UDim2.new(0, width, 0, theme.branch.height)
        branch.Parent = parent
        for _, at in ipairs({ 0.18, 0.82 }) do
            local knot = Instance.new("Frame")
            knot.Name = "Knot"
            knot.BackgroundColor3 = P.DeepForest
            knot.BorderSizePixel = 0
            knot.AnchorPoint = Vector2.new(0.5, 0.5)
            knot.Position = UDim2.new(at, 0, 0.5, 0)
            knot.Size = UDim2.fromOffset(theme.branch.knot, theme.branch.knot)
            knot.Parent = branch
            local knotCorner = Instance.new("UICorner")
            knotCorner.CornerRadius = UDim.new(0.5, 0)
            knotCorner.Parent = knot
        end
        return branch
    end

    function shapes.rope(parent, x, height, thickness)
        local rope = Instance.new("Frame")
        rope.Name = "Rope"
        rope.BackgroundColor3 = P.Bark
        rope.BorderSizePixel = 0
        rope.Position = UDim2.fromOffset(x, 0)
        rope.Size = UDim2.new(0, thickness or 2, 0, height or theme.branch.rope)
        rope.Parent = parent
        return rope
    end

    -- Hanging title sign: 168x34 wood plank, grain, 3px bark stroke, leaf nub.
    function shapes.titleSign(parent, text)
        local sign = Instance.new("Frame")
        sign.Name = "TitleSign"
        sign.BackgroundColor3 = P.Wood
        sign.BorderSizePixel = 0
        sign.AnchorPoint = Vector2.new(0.5, 0)
        sign.Position = UDim2.new(0.5, 0, 0, theme.branch.height + theme.branch.rope)
        sign.Size = UDim2.fromOffset(theme.sign.width, theme.sign.height)
        sign.Rotation = -1
        sign.Parent = parent
        corner(sign, theme.sign.radius)
        shapes.grain(sign, 90)
        shapes.stroke(sign, P.Bark, 3)
        local label = Instance.new("TextLabel")
        label.Name = "Title"
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromScale(1, 1)
        label.Text = text
        label.TextColor3 = P.Parchment
        label.TextSize = theme.type.sign
        theme.applyFont(label, "title")
        label.Parent = sign
        -- the leaf nub overlaps the right edge by 6px
        local nubHolder = Instance.new("Frame")
        nubHolder.Name = "Nub"
        nubHolder.BackgroundTransparency = 1
        nubHolder.AnchorPoint = Vector2.new(1, 0.5)
        nubHolder.Position = UDim2.new(1, 6, 0.5, 0)
        nubHolder.Size = UDim2.fromOffset(14, 14)
        nubHolder.Parent = sign
        shapes.rotatedSquare(nubHolder, 14, P.LeafLight, nil)
        return sign, label
    end

    -- Hanging sign tab: two ropes from the rail, a 184x34 plank, ±0.7 rotation.
    function shapes.hangingTab(parent, name, index, label, onClick)
        local holder = shapes.touchTarget(parent, theme.touch)
        holder.Name = "TabTarget_" .. name
        holder.Size = UDim2.new(1, 0, 0, theme.touch)
        holder.Parent = parent

        local ropes = Instance.new("Frame")
        ropes.Name = "Ropes"
        ropes.BackgroundTransparency = 1
        ropes.Position = UDim2.fromOffset(theme.rail.ropeRailX + 2, 0)
        ropes.Size = UDim2.new(0, 16, 0, theme.touch)
        ropes.Parent = holder

        local leftRope = shapes.rope(ropes, 0, 4, 2)
        local rightRope = shapes.rope(ropes, 8, 4, 2)

        local sign = Instance.new("Frame")
        sign.Name = "Tab"
        sign.BackgroundColor3 = P.Wood
        sign.BorderSizePixel = 0
        sign.Position = UDim2.fromOffset(18, 8)
        sign.Size = UDim2.fromOffset(theme.rail.tabWidth, theme.rail.tabHeight)
        sign.Rotation = theme.tabRotations[((index - 1) % #theme.tabRotations) + 1]
        sign.ZIndex = 2
        sign.Parent = holder
        corner(sign, theme.radius.sign)
        shapes.grain(sign, 90)
        local border = shapes.stroke(sign, P.Bark, 2)

        local inner = Instance.new("UIStroke")
        inner.Name = "Inner"
        inner.Color = P.Firefly
        inner.Thickness = 1
        inner.Transparency = 1
        inner.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        inner.Parent = sign

        -- label lives OUTSIDE the rotated sign: rotation must not tilt text
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "TabLabel"
        textLabel.BackgroundTransparency = 1
        textLabel.Position = UDim2.fromOffset(28, 8)
        textLabel.Size = UDim2.fromOffset(theme.rail.tabWidth - 12, theme.rail.tabHeight)
        textLabel.Text = label
        textLabel.TextSize = theme.type.tab
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Center
        textLabel.TextColor3 = P.Parchment
        textLabel.ZIndex = 3
        theme.applyFont(textLabel, "title")
        textLabel.Parent = holder

        local dot = Instance.new("Frame")
        dot.Name = "NotchDot"
        dot.BackgroundColor3 = P.Firefly
        dot.BorderSizePixel = 0
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.fromOffset(24, 25)
        dot.Size = UDim2.fromOffset(10, 10)
        dot.BackgroundTransparency = 1
        dot.ZIndex = 4
        dot.Parent = holder
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot

        local moss = Instance.new("Frame")
        moss.Name = "Moss"
        moss.BackgroundColor3 = P.Fern
        moss.BorderSizePixel = 0
        moss.AnchorPoint = Vector2.new(0, 1)
        moss.Position = UDim2.new(0, 8, 1, -2)
        moss.Size = UDim2.new(0, 0, 0, 8)
        moss.ZIndex = 4
        moss.Parent = sign
        corner(moss, 1)

        local state = { active = false }
        local function setRope(length)
            local tween = TweenService:Create(
                leftRope,
                TweenInfo.new(theme.motion.tab, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { Size = UDim2.new(0, 2, 0, length) }
            )
            tween:Play()
            TweenService:Create(
                rightRope,
                TweenInfo.new(theme.motion.tab, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { Size = UDim2.new(0, 2, 0, length) }
            ):Play()
            TweenService:Create(
                sign,
                TweenInfo.new(theme.motion.tab, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { Position = UDim2.fromOffset(18, length + 4) }
            ):Play()
            TweenService:Create(
                textLabel,
                TweenInfo.new(theme.motion.tab, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { Position = UDim2.fromOffset(28, length + 4) }
            ):Play()
        end

        local function setHover(hovering)
            local goal = hovering and 0 or 1
            TweenService:Create(
                inner,
                TweenInfo.new(theme.motion.hover, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Transparency = goal }
            ):Play()
            setRope(hovering and 6 or 4)
        end

        function state.setActive(active)
            state.active = active
            textLabel.TextColor3 = active and P.LeafLight or P.Parchment
            border.Color = active and P.Bark or P.Bark
            inner.Transparency = active and 0 or 1
            dot.BackgroundTransparency = active and 0 or 1
            setRope(active and 10 or 4)
            TweenService:Create(
                moss,
                TweenInfo.new(theme.motion.tab, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { Size = UDim2.new(0, active and 64 or 0, 0, 8) }
            ):Play()
        end

        holder.MouseEnter:Connect(function()
            if not state.active then
                setHover(true)
            end
        end)
        holder.MouseLeave:Connect(function()
            if not state.active then
                setHover(false)
            end
        end)
        holder.MouseButton1Click:Connect(function()
            if onClick then
                onClick(name)
            end
        end)

        return {
            holder = holder,
            sign = sign,
            ropes = ropes,
            leftRope = leftRope,
            rightRope = rightRope,
            label = textLabel,
            dot = dot,
            moss = moss,
            setActive = state.setActive,
        }
    end

    --------------------------------------------------------------- window body
    function shapes.stoneWindow(parent)
        local frame = Instance.new("Frame")
        frame.Name = "Window"
        frame.BackgroundColor3 = P.DeepForest
        frame.BorderSizePixel = 0
        frame.Size = UDim2.fromScale(1, 1)
        frame.Active = true
        frame.ClipsDescendants = true
        frame.Parent = parent
        corner(frame, theme.radius.stone)
        shapes.stroke(frame, P.Bark, theme.stroke.bark)
        local inner = shapes.stroke(frame, P.LeafLight, theme.stroke.inner, 1 - theme.stroke.innerAlpha)
        inner.Name = "InnerStroke"
        -- inset 2px: the stroke object has no inset, so a second frame carries it
        local inset = Instance.new("Frame")
        inset.Name = "InnerFrame"
        inset.BackgroundTransparency = 1
        inset.Position = UDim2.fromOffset(theme.stroke.innerInset, theme.stroke.innerInset)
        inset.Size = UDim2.new(1, -theme.stroke.innerInset * 2, 1, -theme.stroke.innerInset * 2)
        inset.Parent = frame
        corner(inset, theme.radius.stone - 2)
        shapes.stroke(inset, P.LeafLight, 1, 0.45)
        local wash = Instance.new("Frame")
        wash.Name = "MossWash"
        wash.BackgroundColor3 = P.Moss
        wash.BackgroundTransparency = 1 - theme.panelDimAlpha
        wash.BorderSizePixel = 0
        wash.Size = UDim2.fromScale(1, 1)
        wash.Parent = frame
        corner(wash, theme.radius.stone)
        inset.ZIndex = 2
        return frame, inset
    end

    -- segmented moss strip; 3 segments, 1px gaps
    function shapes.mossStrip(parent, y, width, transparency)
        local strip = Instance.new("Frame")
        strip.Name = "MossStrip"
        strip.BackgroundTransparency = 1
        strip.Position = UDim2.new(0, 0, 0, y)
        strip.Size = UDim2.new(1, 0, 0, 4)
        strip.Parent = parent
        local count, gap = 3, 1
        for index = 1, count do
            local segment = Instance.new("Frame")
            segment.Name = "Segment" .. index
            segment.BackgroundColor3 = P.Fern
            segment.BackgroundTransparency = transparency or 0.25
            segment.BorderSizePixel = 0
            segment.Position = UDim2.new(0, (index - 1) * ((width - gap * (count - 1)) / count + gap), 0, 0)
            segment.Size = UDim2.new(0, (width - gap * (count - 1)) / count, 0, 4)
            segment.Parent = strip
            corner(segment, 1)
        end
        return strip
    end

    ------------------------------------------------------------------ surfaces
    -- Plank row card: own grain, 2px bark bottom edge, 1px top hairline,
    -- deterministic rotation ((index*7)%3-1)*0.6.
    function shapes.plankRow(parent, index)
        local row = Instance.new("Frame")
        row.Name = "Row"
        row.BackgroundColor3 = P.Wood
        row.BackgroundTransparency = 1 - theme.rowPlankAlpha
        row.BorderSizePixel = 0
        row.Size = UDim2.new(1, 0, 0, theme.row.height)
        row.Rotation = ((index * 7) % 3 - 1) * 0.6
        row.Parent = parent
        corner(row, theme.row.radius)
        shapes.grain(row, 90)
        local bottom = Instance.new("Frame")
        bottom.Name = "BottomEdge"
        bottom.BackgroundColor3 = P.Bark
        bottom.BorderSizePixel = 0
        bottom.AnchorPoint = Vector2.new(0, 1)
        bottom.Position = UDim2.new(0, 0, 1, 0)
        bottom.Size = UDim2.new(1, 0, 0, 2)
        bottom.Parent = row
        local top = Instance.new("Frame")
        top.Name = "TopHairline"
        top.BackgroundColor3 = P.Bark
        top.BackgroundTransparency = 1 - theme.stroke.hairlineAlpha
        top.BorderSizePixel = 0
        top.Size = UDim2.new(1, 0, 0, 1)
        top.Parent = row
        return row
    end

    function shapes.leafButton(parent, label, variant, onClick, order)
        local wrapper = shapes.touchTarget(parent, theme.touch)
        wrapper.Name = "LeafButton"
        wrapper.LayoutOrder = order or 1
        wrapper.Size = UDim2.new(0, 0, 1, 0)

        local diamondHolder = Instance.new("Frame")
        diamondHolder.Name = "DiamondHolder"
        diamondHolder.BackgroundTransparency = 1
        diamondHolder.AnchorPoint = Vector2.new(0.5, 0.5)
        diamondHolder.Position = UDim2.fromScale(0.5, 0.5)
        diamondHolder.Size = UDim2.fromOffset(44, 44)
        diamondHolder.Parent = wrapper

        local primary = variant == "primary" or variant == "accent"
        local fill = primary and P.Firefly or P.Fern
        local diamond = shapes.rotatedSquare(diamondHolder, 32, fill, P.Bark)
        local vein = Instance.new("Frame")
        vein.Name = "Vein"
        vein.AnchorPoint = Vector2.new(0.5, 0.5)
        vein.Position = UDim2.fromScale(0.5, 0.5)
        vein.Size = UDim2.fromOffset(20, 20)
        vein.BackgroundColor3 = P.LeafLight
        vein.BackgroundTransparency = 0.65
        vein.BorderSizePixel = 0
        vein.Rotation = 45
        vein.Parent = diamondHolder
        local veinCorner = Instance.new("UICorner")
        veinCorner.CornerRadius = UDim.new(0.5, 0)
        veinCorner.Parent = vein

        -- text is a non-rotated sibling, never inside the diamond
        local text = Instance.new("TextLabel")
        text.Name = "Label"
        text.BackgroundTransparency = 1
        text.Size = UDim2.fromScale(1, 1)
        text.Text = label or ""
        text.TextSize = theme.type.button
        text.TextColor3 = primary and P.DeepForest or P.Parchment
        text.TextTruncate = Enum.TextTruncate.AtEnd
        text.ZIndex = 4
        theme.applyFont(text, "title")
        text.Parent = wrapper

        local halo = Instance.new("UIStroke")
        halo.Color = P.Firefly
        halo.Thickness = 1
        halo.Transparency = 1
        halo.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        halo.Parent = diamond

        wrapper.MouseEnter:Connect(function()
            TweenService:Create(
                halo,
                TweenInfo.new(theme.motion.hover, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Transparency = 0 }
            ):Play()
        end)
        wrapper.MouseLeave:Connect(function()
            TweenService:Create(
                halo,
                TweenInfo.new(theme.motion.hover, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Transparency = 1 }
            ):Play()
        end)
        wrapper.MouseButton1Click:Connect(function()
            if onClick then
                onClick()
            end
        end)
        return wrapper, text
    end

    -- secondary: 34px mossy stone pill with darker bottom inset
    function shapes.stoneButton(parent, label, order)
        local button = Instance.new("TextButton")
        button.Name = "StoneButton"
        button.AutoButtonColor = false
        button.BorderSizePixel = 0
        button.BackgroundColor3 = P.Moss
        button.Text = ""
        button.Size = UDim2.new(1, 0, 0, 34)
        button.LayoutOrder = order or 1
        button.Parent = parent
        pill(button)
        shapes.stroke(button, P.Bark, 3)
        local lip = Instance.new("Frame")
        lip.Name = "Lip"
        lip.BackgroundColor3 = P.Bark
        lip.BackgroundTransparency = 0.5
        lip.BorderSizePixel = 0
        lip.AnchorPoint = Vector2.new(0, 1)
        lip.Position = UDim2.new(0, 0, 1, -3)
        lip.Size = UDim2.new(1, 0, 0, 3)
        lip.Parent = button
        local text = Instance.new("TextLabel")
        text.Name = "Label"
        text.BackgroundTransparency = 1
        text.Size = UDim2.fromScale(1, 1)
        text.Text = label or ""
        text.TextSize = theme.type.button
        text.TextColor3 = P.Parchment
        text.Parent = button
        theme.applyFont(text, "body")
        -- the page code writes .Text on the button after it is built
        button:GetPropertyChangedSignal("Text"):Connect(function()
            if button.Text ~= "" and text.Text ~= button.Text then
                text.Text = button.Text
            end
        end)
        return button, text
    end

    -- toggle: knot track + parchment knob with wood ring
    function shapes.knotToggle(parent, order)
        local track = Instance.new("Frame")
        track.Name = "Track"
        track.BackgroundColor3 = P.Moss
        track.BackgroundTransparency = 0.4
        track.BorderSizePixel = 0
        track.Size = UDim2.fromOffset(36, 18)
        track.LayoutOrder = order or 2
        track.Parent = parent
        pill(track)
        shapes.stroke(track, P.Bark, 2)
        local knob = Instance.new("Frame")
        knob.Name = "Knob"
        knob.BackgroundColor3 = P.Parchment
        knob.BorderSizePixel = 0
        knob.Size = UDim2.fromOffset(14, 14)
        knob.Position = UDim2.fromOffset(1, 2)
        knob.Parent = track
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob
        local ring = Instance.new("Frame")
        ring.Name = "Ring"
        ring.BackgroundColor3 = P.Wood
        ring.BorderSizePixel = 0
        ring.AnchorPoint = Vector2.new(0.5, 0.5)
        ring.Position = UDim2.fromScale(0.5, 0.5)
        ring.Size = UDim2.fromOffset(7, 7)
        ring.Parent = knob
        local ringCorner = Instance.new("UICorner")
        ringCorner.CornerRadius = UDim.new(1, 0)
        ringCorner.Parent = ring
        local halo = Instance.new("UIStroke")
        halo.Color = P.Firefly
        halo.Thickness = 1
        halo.Transparency = 1
        halo.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        halo.Parent = track
        return track, knob, halo
    end

    -- slider: vine track, firefly thumb, leaf nub at the fill end
    function shapes.vineSlider(parent, order)
        local track = Instance.new("Frame")
        track.Name = "Track"
        track.BackgroundColor3 = P.Bark
        track.BorderSizePixel = 0
        track.Size = UDim2.new(1, 0, 0, 18)
        track.BackgroundTransparency = 0
        track.LayoutOrder = order or 2
        track.Active = true
        track.Parent = parent
        local groove = Instance.new("Frame")
        groove.Name = "Groove"
        groove.BackgroundColor3 = P.Bark
        groove.BorderSizePixel = 0
        groove.AnchorPoint = Vector2.new(0, 0.5)
        groove.Position = UDim2.new(0, 0, 0.5, 0)
        groove.Size = UDim2.new(1, 0, 0, 4)
        groove.Parent = track
        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.BackgroundColor3 = P.Fern
        fill.BorderSizePixel = 0
        fill.AnchorPoint = Vector2.new(0, 0.5)
        fill.Position = UDim2.new(0, 0, 0.5, 0)
        fill.Size = UDim2.new(0, 0, 0, 4)
        fill.Parent = track
        local thumbHolder = Instance.new("Frame")
        thumbHolder.Name = "ThumbHolder"
        thumbHolder.BackgroundTransparency = 1
        thumbHolder.AnchorPoint = Vector2.new(0, 0.5)
        thumbHolder.Position = UDim2.new(0, 0, 0.5, 0)
        thumbHolder.Size = UDim2.fromOffset(0, 18)
        thumbHolder.Parent = track
        local thumb = Instance.new("Frame")
        thumb.Name = "Thumb"
        thumb.BackgroundColor3 = P.Firefly
        thumb.BorderSizePixel = 0
        thumb.AnchorPoint = Vector2.new(0.5, 0.5)
        thumb.Position = UDim2.fromScale(0, 0.5)
        thumb.Size = UDim2.fromOffset(12, 12)
        thumb.Parent = thumbHolder
        local thumbCorner = Instance.new("UICorner")
        thumbCorner.CornerRadius = UDim.new(1, 0)
        thumbCorner.Parent = thumb
        local halo = Instance.new("UIStroke")
        halo.Color = P.Firefly
        halo.Thickness = 1
        halo.Transparency = 0.6
        halo.Parent = thumb
        local nubHolder = Instance.new("Frame")
        nubHolder.Name = "NubHolder"
        nubHolder.BackgroundTransparency = 1
        nubHolder.AnchorPoint = Vector2.new(0, 0.5)
        nubHolder.Position = UDim2.new(0, 0, 0.5, 0)
        nubHolder.Size = UDim2.fromOffset(2, 12)
        nubHolder.Parent = track
        shapes.rotatedSquare(nubHolder, 8, P.LeafLight, nil, 0.2)
        return track, fill, thumbHolder, thumb
    end

    function shapes.barkTablet(parent, height, order)
        local tablet = Instance.new("Frame")
        tablet.Name = "Tablet"
        tablet.BackgroundColor3 = P.DeepForest
        tablet.BorderSizePixel = 0
        tablet.Size = UDim2.new(1, 0, 0, height or 34)
        tablet.LayoutOrder = order or 1
        tablet.Parent = parent
        corner(tablet, theme.radius.plank)
        shapes.stroke(tablet, P.Bark, 2)
        return tablet
    end

    function shapes.chip(parent, text, order)
        local chip = Instance.new("Frame")
        chip.Name = "Chip"
        chip.BackgroundColor3 = P.Bark
        chip.BorderSizePixel = 0
        chip.AutomaticSize = Enum.AutomaticSize.X
        chip.Size = UDim2.fromOffset(0, 16)
        chip.LayoutOrder = order or 1
        chip.Parent = parent
        corner(chip, theme.radius.chip)
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.AutomaticSize = Enum.AutomaticSize.X
        label.Size = UDim2.fromOffset(0, 16)
        label.Text = text or ""
        label.TextSize = theme.type.footer
        label.TextColor3 = P.Parchment
        theme.applyFont(label, "body")
        label.Parent = chip
        shapes.pad(chip, 0, 6, 0, 6)
        return chip, label
    end

    function shapes.scrollbar(scrollingFrame)
        scrollingFrame.ScrollBarThickness = 6
        scrollingFrame.ScrollBarImageColor3 = P.Bark
        scrollingFrame.ScrollBarImageTransparency = 0
        scrollingFrame.BorderSizePixel = 0
        pcall(function()
            scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.None
        end)
        return scrollingFrame
    end

    ---------------------------------------------------------------- fireflies
    local ambientPaused = false

    local function spawnFirefly(host, index)
        local fly = {}
        fly.origin = Vector2.new(
            40 + ((index * 137) % math.max(1, math.floor(host.AbsoluteSize.X - 80))),
            40 + ((index * 89) % math.max(1, math.floor(host.AbsoluteSize.Y - 80)))
        )
        local halo = Instance.new("Frame")
        halo.Name = "FireflyHalo"
        halo.BackgroundColor3 = P.Firefly
        halo.BackgroundTransparency = 0.88
        halo.BorderSizePixel = 0
        halo.Size = UDim2.fromOffset(14, 14)
        halo.Position = UDim2.fromOffset(fly.origin.X - 4, fly.origin.Y - 4)
        halo.Active = false
        halo.Parent = host
        local haloCorner = Instance.new("UICorner")
        haloCorner.CornerRadius = UDim.new(1, 0)
        haloCorner.Parent = halo

        local dot = Instance.new("Frame")
        dot.Name = "Firefly"
        dot.BackgroundColor3 = P.Firefly
        dot.BorderSizePixel = 0
        dot.Size = UDim2.fromOffset(6, 6)
        dot.Position = UDim2.fromOffset(0, 0)
        dot.Active = false
        dot.Parent = halo
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot

        pcall(function()
            halo.Interactable = false
            dot.Interactable = false
        end)
        fly.halo, fly.dot = halo, dot
        fly.tweens = {}

        local function drift()
            if fly.dead or ambientPaused then
                return
            end
            local dx = math.random(-110, 110)
            local dy = math.random(-110, 110)
            local duration = theme.motion.driftMin + math.random() * (theme.motion.driftMax - theme.motion.driftMin)
            local tween = TweenService:Create(
                halo,
                TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { Position = UDim2.fromOffset(fly.origin.X + dx, fly.origin.Y + dy) }
            )
            tween:Play()
            table.insert(fly.tweens, tween)
            tween.Completed:Connect(function()
                if fly.dead then
                    return
                end
                drift()
            end)
        end

        local function pulse()
            if fly.dead or ambientPaused then
                return
            end
            local duration = theme.motion.fireflyMin
                + math.random() * (theme.motion.fireflyMax - theme.motion.fireflyMin)
            local tween = TweenService:Create(
                halo,
                TweenInfo.new(duration / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { BackgroundTransparency = 1 }
            )
            tween:Play()
            table.insert(fly.tweens, tween)
            tween.Completed:Connect(function()
                if fly.dead then
                    return
                end
                local back = TweenService:Create(
                    halo,
                    TweenInfo.new(theme.motion.fireflyMax / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    { BackgroundTransparency = 0.88 }
                )
                back:Play()
                table.insert(fly.tweens, back)
                back.Completed:Connect(function()
                    if fly.dead then
                        return
                    end
                    pulse()
                end)
            end)
        end

        fly.stop = function()
            fly.dead = true
            for _, tween in ipairs(fly.tweens) do
                pcall(function()
                    tween:Cancel()
                end)
            end
            fly.tweens = {}
            if halo.Parent then
                halo:Destroy()
            end
        end
        fly.pause = function()
            for _, tween in ipairs(fly.tweens) do
                pcall(function()
                    tween:Pause()
                end)
            end
        end
        fly.resume = function()
            for _, tween in ipairs(fly.tweens) do
                pcall(function()
                    tween:Play()
                end)
            end
        end

        task.defer(function()
            if fly.dead then
                return
            end
            drift()
            pulse()
        end)
        table.insert(fireflies, fly)
        return fly
    end

    function shapes.spawnFireflies(count)
        local gui = shapes.ensureGui("ambient")
        local host = gui:FindFirstChild("AmbientLayer")
        if not host then
            host = Instance.new("Frame")
            host.Name = "AmbientLayer"
            host.BackgroundTransparency = 1
            host.Size = UDim2.fromScale(1, 1)
            host.Active = false
            pcall(function()
                host.Interactable = false
            end)
            host.Parent = gui
        end
        local total = math.clamp(count or 8, 0, 8)
        for index = 1, total do
            spawnFirefly(host, index)
        end
        return total
    end

    function shapes.pauseFireflies(paused)
        ambientPaused = paused == true
        for _, fly in ipairs(fireflies) do
            if paused then
                fly.pause()
            else
                fly.resume()
            end
        end
    end

    function shapes.clearFireflies()
        for index = #fireflies, 1, -1 do
            local fly = fireflies[index]
            fly.stop()
            fireflies[index] = nil
        end
    end

    function shapes.fireflyCount()
        return #fireflies
    end

    function shapes.activeFireflyTweens()
        local live = 0
        for _, fly in ipairs(fireflies) do
            for _, tween in ipairs(fly.tweens) do
                if tween.PlaybackState == Enum.PlaybackState.Playing then
                    live += 1
                end
            end
        end
        return live
    end

    --------------------------------------------------------------- decoration
    -- Vines/leaves are created only when an id exists; nil creates nothing.
    function shapes.decorateWindow(frame)
        if theme.VINE_IMAGE_ID == nil then
            return nil
        end
        local vine = Instance.new("ImageLabel")
        vine.Name = "Vine"
        vine.BackgroundTransparency = 1
        vine.Image = theme.VINE_IMAGE_ID
        vine.ImageColor3 = P.Fern
        vine.ScaleType = Enum.ScaleType.Fit
        vine.Size = UDim2.fromOffset(24, 120)
        vine.Position = UDim2.fromOffset(-8, 120)
        vine.Parent = frame
        return vine
    end

    function shapes.decorateSign(sign)
        if theme.LEAF_IMAGE_ID == nil then
            return nil
        end
        local leaf = Instance.new("ImageLabel")
        leaf.Name = "Leaf"
        leaf.BackgroundTransparency = 1
        leaf.Image = theme.LEAF_IMAGE_ID
        leaf.ImageColor3 = P.Fern
        leaf.ScaleType = Enum.ScaleType.Fit
        leaf.Size = UDim2.fromOffset(16, 16)
        leaf.Position = UDim2.fromOffset(-6, -6)
        leaf.Parent = sign
        return leaf
    end

    context.shapes = shapes
    context.UI = context.UI or {}
    context.UI.menuGui = shapes.menuGui
    context.UI.assertTeardown = shapes.assertTeardown
end
