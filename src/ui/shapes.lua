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
        pcall(function()
            gui.ScreenInsets = Enum.ScreenInsets.None
        end)
        gui.ResetOnSpawn = false
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

    -- Glass sheen: a cool, almost-invisible diagonal wash.  Kept under the old
    -- name because every surface historically asked for grain.
    function shapes.grain(parent, rotation)
        grainCount += 1
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, P.Wood),
            ColorSequenceKeypoint.new(0.46, P.Moss),
            ColorSequenceKeypoint.new(0.54, P.Bark),
            ColorSequenceKeypoint.new(1, P.Wood),
        })
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.38),
            NumberSequenceKeypoint.new(0.46, 0.58),
            NumberSequenceKeypoint.new(0.54, 0.42),
            NumberSequenceKeypoint.new(1, 0.62),
        })
        gradient.Rotation = rotation or 25
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
    -- A single neon rule instead of the old branch.  It reads as a status line
    -- across the top of every window and stays out of the header's hit targets.
    function shapes.branch(parent, width)
        local branch = Instance.new("Frame")
        branch.Name = "SignalLine"
        branch.BackgroundColor3 = P.Fern
        branch.BorderSizePixel = 0
        branch.Size = UDim2.new(0, width, 0, theme.branch.height)
        branch.Parent = parent
        corner(branch, 999)
        local sheen = Instance.new("UIGradient")
        sheen.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, P.Fern),
            ColorSequenceKeypoint.new(0.45, P.LeafLight),
            ColorSequenceKeypoint.new(0.7, P.Hot),
            ColorSequenceKeypoint.new(1, P.Fern),
        })
        sheen.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.15),
            NumberSequenceKeypoint.new(0.7, 0.35),
            NumberSequenceKeypoint.new(1, 0.6),
        })
        sheen.Parent = branch
        for _, at in ipairs({ 0.02, 0.98 }) do
            local node = Instance.new("Frame")
            node.Name = "Node"
            node.BackgroundColor3 = at < 0.5 and P.Fern or P.Hot
            node.BorderSizePixel = 0
            node.AnchorPoint = Vector2.new(0.5, 0.5)
            node.Position = UDim2.new(at, 0, 0.5, 0)
            node.Size = UDim2.fromOffset(theme.branch.knot, theme.branch.knot)
            node.Parent = branch
            corner(node, 999)
        end
        return branch
    end

    function shapes.rope(parent, x, height, thickness)
        -- Retained as an inert spacer: the neon rail no longer hangs from rope.
        local rope = Instance.new("Frame")
        rope.Name = "Rope"
        rope.BackgroundTransparency = 1
        rope.BorderSizePixel = 0
        rope.Position = UDim2.fromOffset(x, 0)
        rope.Size = UDim2.new(0, thickness or 1, 0, height or 0)
        rope.Parent = parent
        return rope
    end

    -- Brand lockup: left-aligned glass capsule, square status mark, product tag.
    function shapes.titleSign(parent, text)
        local sign = Instance.new("Frame")
        sign.Name = "TitleSign"
        sign.BackgroundColor3 = P.Wood
        sign.BackgroundTransparency = 0.06
        sign.BorderSizePixel = 0
        sign.AnchorPoint = Vector2.new(0, 0)
        sign.Position = UDim2.fromOffset(16, 14)
        sign.Size = UDim2.fromOffset(theme.sign.width, theme.sign.height)
        sign.Parent = parent
        corner(sign, theme.sign.radius)
        local sheen = shapes.grain(sign, 18)
        sheen.Transparency = NumberSequence.new(0.7)
        shapes.stroke(sign, P.Bark, 1)
        local inner = shapes.stroke(sign, P.Fern, 1, 0.72)
        inner.Name = "SignalStroke"

        local mark = Instance.new("Frame")
        mark.Name = "Mark"
        mark.BackgroundColor3 = P.LeafLight
        mark.BorderSizePixel = 0
        mark.AnchorPoint = Vector2.new(0, 0.5)
        mark.Position = UDim2.new(0, 12, 0.5, 0)
        mark.Size = UDim2.fromOffset(9, 9)
        mark.Parent = sign
        corner(mark, 3)
        local markGlow = shapes.stroke(mark, P.LeafLight, 1, 0.1)
        markGlow.Name = "Glow"

        local label = Instance.new("TextLabel")
        label.Name = "Title"
        label.BackgroundTransparency = 1
        label.Position = UDim2.fromOffset(30, 0)
        label.Size = UDim2.new(1, -78, 1, 0)
        label.Text = text
        label.TextColor3 = P.Parchment
        label.TextSize = theme.type.sign
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextTruncate = Enum.TextTruncate.AtEnd
        theme.applyFont(label, "title")
        label.Parent = sign

        local mode = Instance.new("TextLabel")
        mode.Name = "Mode"
        mode.BackgroundTransparency = 1
        mode.AnchorPoint = Vector2.new(1, 0.5)
        mode.Position = UDim2.new(1, -10, 0.5, 0)
        mode.Size = UDim2.fromOffset(36, 20)
        mode.Text = "OS"
        mode.TextSize = 9
        mode.TextColor3 = P.Muted
        mode.TextXAlignment = Enum.TextXAlignment.Right
        theme.applyFont(mode, "body")
        mode.Parent = sign
        return sign, label
    end

    -- Sidebar navigation: a flat glass row with a short accent rail.  Kept
    -- intentionally independent of the old rotated hanging-sign geometry.
    function shapes.hangingTab(parent, name, index, label, onClick)
        local holder = shapes.touchTarget(parent, theme.touch)
        holder.Name = "TabTarget_" .. name
        holder.Size = UDim2.new(1, 0, 0, theme.touch)
        holder.Parent = parent

        local ropes = Instance.new("Frame")
        ropes.Name = "Ropes"
        ropes.BackgroundTransparency = 1
        ropes.Size = UDim2.fromOffset(0, 0)
        ropes.Parent = holder
        local leftRope = shapes.rope(ropes, 0, 0, 1)
        local rightRope = shapes.rope(ropes, 0, 0, 1)

        local sign = Instance.new("Frame")
        sign.Name = "Tab"
        sign.BackgroundColor3 = P.Wood
        sign.BackgroundTransparency = 0.24
        sign.BorderSizePixel = 0
        sign.Position = UDim2.fromOffset(9, 4)
        sign.Size = UDim2.new(1, -18, 0, theme.rail.tabHeight)
        sign.ZIndex = 2
        sign.Parent = holder
        corner(sign, theme.radius.sign)
        shapes.stroke(sign, P.Bark, 1)
        local inner = shapes.stroke(sign, P.Fern, 1, 1)
        inner.Name = "Inner"

        local accent = Instance.new("Frame")
        accent.Name = "Accent"
        accent.BackgroundColor3 = P.LeafLight
        accent.BorderSizePixel = 0
        accent.AnchorPoint = Vector2.new(0, 0.5)
        accent.Position = UDim2.new(0, 0, 0.5, 0)
        accent.Size = UDim2.fromOffset(3, 0)
        accent.ZIndex = 4
        accent.Parent = sign
        corner(accent, 999)

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "TabLabel"
        textLabel.BackgroundTransparency = 1
        textLabel.Position = UDim2.fromOffset(18, 0)
        textLabel.Size = UDim2.new(1, -44, 1, 0)
        textLabel.Text = label
        textLabel.TextSize = theme.type.tab
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Center
        textLabel.TextColor3 = P.Muted
        textLabel.ZIndex = 3
        theme.applyFont(textLabel, "title")
        textLabel.Parent = holder

        local dot = Instance.new("Frame")
        dot.Name = "NotchDot"
        dot.BackgroundColor3 = P.Hot
        dot.BorderSizePixel = 0
        dot.AnchorPoint = Vector2.new(1, 0.5)
        dot.Position = UDim2.new(1, -11, 0.5, 0)
        dot.Size = UDim2.fromOffset(5, 5)
        dot.BackgroundTransparency = 1
        dot.ZIndex = 4
        dot.Parent = holder
        corner(dot, 999)

        local state = { active = false }

        local function setHover(hovering)
            if state.active then
                return
            end
            TweenService:Create(
                sign,
                TweenInfo.new(theme.motion.hover, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {
                    BackgroundColor3 = hovering and P.Moss or P.Wood,
                    BackgroundTransparency = hovering and 0.08 or 0.24,
                }
            ):Play()
            TweenService:Create(
                inner,
                TweenInfo.new(theme.motion.hover, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Transparency = hovering and 0.6 or 1 }
            ):Play()
            textLabel.TextColor3 = hovering and P.Parchment or P.Muted
        end

        function state.setActive(active)
            state.active = active
            textLabel.TextColor3 = active and P.Parchment or P.Muted
            inner.Transparency = active and 0.2 or 1
            dot.BackgroundTransparency = active and 0 or 1
            TweenService:Create(
                sign,
                TweenInfo.new(theme.motion.tab, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {
                    BackgroundColor3 = active and P.Moss or P.Wood,
                    BackgroundTransparency = active and 0.02 or 0.24,
                }
            ):Play()
            TweenService:Create(
                accent,
                TweenInfo.new(theme.motion.tab, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = UDim2.fromOffset(3, active and 20 or 0) }
            ):Play()
        end

        holder.MouseEnter:Connect(function()
            setHover(true)
        end)
        holder.MouseLeave:Connect(function()
            setHover(false)
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
            moss = accent,
            setActive = state.setActive,
        }
    end

    --------------------------------------------------------------- window body
    function shapes.stoneWindow(parent)
        local frame = Instance.new("Frame")
        frame.Name = "Window"
        frame.BackgroundColor3 = P.Moss
        frame.BackgroundTransparency = 0.03
        frame.BorderSizePixel = 0
        frame.Size = UDim2.fromScale(1, 1)
        frame.Active = true
        frame.ClipsDescendants = true
        frame.Parent = parent
        corner(frame, theme.radius.stone)
        shapes.stroke(frame, P.Bark, 1)
        local inner = shapes.stroke(frame, P.Fern, 1, 0.77)
        inner.Name = "InnerStroke"
        local wash = Instance.new("Frame")
        wash.Name = "GlassWash"
        wash.BackgroundColor3 = P.Wood
        wash.BackgroundTransparency = 0.82
        wash.BorderSizePixel = 0
        wash.Size = UDim2.fromScale(1, 1)
        wash.Parent = frame
        corner(wash, theme.radius.stone)
        local washGradient = Instance.new("UIGradient")
        washGradient.Color = ColorSequence.new(P.Moss, P.DeepForest)
        washGradient.Rotation = 90
        washGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.38),
            NumberSequenceKeypoint.new(0.45, 0.84),
            NumberSequenceKeypoint.new(1, 0.58),
        })
        washGradient.Parent = wash
        local inset = Instance.new("Frame")
        inset.Name = "InnerFrame"
        inset.BackgroundTransparency = 1
        inset.Position = UDim2.fromOffset(theme.stroke.innerInset, theme.stroke.innerInset)
        inset.Size = UDim2.new(1, -theme.stroke.innerInset * 2, 1, -theme.stroke.innerInset * 2)
        inset.Parent = frame
        corner(inset, theme.radius.stone - 1)
        shapes.stroke(inset, P.LeafLight, 1, 0.65)
        inset.ZIndex = 2
        return frame, inset
    end

    -- One thin spectrum line, replacing the old segmented moss strip.
    function shapes.mossStrip(parent, y, _width, transparency)
        local strip = Instance.new("Frame")
        strip.Name = "SignalStrip"
        strip.BackgroundTransparency = 1
        strip.Position = UDim2.new(0, 0, 0, y)
        strip.Size = UDim2.new(1, 0, 0, 2)
        strip.Parent = parent
        local line = Instance.new("Frame")
        line.Name = "Spectrum"
        line.BackgroundColor3 = P.Fern
        line.BackgroundTransparency = transparency or 0.18
        line.BorderSizePixel = 0
        line.Size = UDim2.fromScale(1, 1)
        line.Parent = strip
        corner(line, 999)
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, P.Fern),
            ColorSequenceKeypoint.new(0.55, P.LeafLight),
            ColorSequenceKeypoint.new(1, P.Hot),
        })
        gradient.Parent = line
        return strip
    end

    ------------------------------------------------------------------ surfaces
    -- Flat glass row with a restrained edge and a cool highlight.
    function shapes.plankRow(parent, index)
        local row = Instance.new("Frame")
        row.Name = "Plank"
        row.BackgroundColor3 = P.Wood
        row.BackgroundTransparency = 0.12
        row.BorderSizePixel = 0
        row.Size = UDim2.new(1, 0, 0, theme.row.height)
        row.Parent = parent
        corner(row, theme.row.radius)
        shapes.stroke(row, P.Bark, 1)
        local sheen = Instance.new("UIGradient")
        sheen.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, P.Wood),
            ColorSequenceKeypoint.new(0.5, P.Moss),
            ColorSequenceKeypoint.new(1, P.Wood),
        })
        sheen.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(0.52, 0.42),
            NumberSequenceKeypoint.new(1, 0.15),
        })
        sheen.Rotation = (index % 2 == 0) and -12 or 12
        sheen.Parent = row
        local bottom = Instance.new("Frame")
        bottom.Name = "BottomEdge"
        bottom.BackgroundColor3 = P.Fern
        bottom.BackgroundTransparency = 0.72
        bottom.BorderSizePixel = 0
        bottom.AnchorPoint = Vector2.new(0, 1)
        bottom.Position = UDim2.new(0, 8, 1, 0)
        bottom.Size = UDim2.new(1, -16, 0, 1)
        bottom.Parent = row
        local accent = Instance.new("Frame")
        accent.Name = "EdgeAccent"
        accent.BackgroundColor3 = P.LeafLight
        accent.BackgroundTransparency = 0.45
        accent.BorderSizePixel = 0
        accent.AnchorPoint = Vector2.new(0, 0.5)
        accent.Position = UDim2.new(0, 0, 0.5, 0)
        accent.Size = UDim2.fromOffset(2, 16)
        accent.Parent = row
        corner(accent, 999)
        return row
    end

    function shapes.leafButton(parent, label, variant, onClick, order)
        local wrapper = shapes.touchTarget(parent, theme.touch)
        wrapper.Name = "LeafButton"
        wrapper.LayoutOrder = order or 1
        wrapper.Size = UDim2.new(0, 0, 1, 0)
        wrapper.AutoButtonColor = false
        wrapper.BackgroundColor3 = P.Wood
        wrapper.BackgroundTransparency = 0.08
        corner(wrapper, theme.radius.sign)
        shapes.stroke(wrapper, P.Bark, 1)

        local primary = variant == "primary" or variant == "accent"
        if primary then
            wrapper.BackgroundColor3 = P.Firefly
            wrapper.BackgroundTransparency = 0
        elseif variant == "danger" then
            wrapper.BackgroundColor3 = P.DeepForest
            shapes.stroke(wrapper, theme.danger, 1)
        end
        local text = Instance.new("TextLabel")
        text.Name = "Label"
        text.BackgroundTransparency = 1
        text.Size = UDim2.fromScale(1, 1)
        text.Text = label or ""
        text.TextSize = theme.type.button
        text.TextColor3 = primary and P.DeepForest or (variant == "danger" and theme.danger or P.Parchment)
        text.TextTruncate = Enum.TextTruncate.AtEnd
        text.ZIndex = 4
        theme.applyFont(text, "title")
        text.Parent = wrapper

        wrapper.MouseEnter:Connect(function()
            TweenService:Create(
                wrapper,
                TweenInfo.new(theme.motion.hover, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { BackgroundTransparency = primary and 0 or 0 }
            ):Play()
        end)
        wrapper.MouseLeave:Connect(function()
            TweenService:Create(
                wrapper,
                TweenInfo.new(theme.motion.hover, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { BackgroundTransparency = primary and 0 or 0.08 }
            ):Play()
        end)
        wrapper.MouseButton1Click:Connect(function()
            if onClick then
                onClick()
            end
        end)
        return wrapper, text
    end

    -- Primary/secondary action: a square glass key with a bright signal edge.
    function shapes.stoneButton(parent, label, order)
        local button = Instance.new("TextButton")
        button.Name = "StoneButton"
        button.AutoButtonColor = false
        button.BorderSizePixel = 0
        button.BackgroundColor3 = P.Wood
        button.BackgroundTransparency = 0.06
        button.Text = ""
        button.Size = UDim2.new(1, 0, 0, 36)
        button.LayoutOrder = order or 1
        button.Parent = parent
        corner(button, theme.radius.sign)
        shapes.stroke(button, P.Bark, 1)
        local text = Instance.new("TextLabel")
        text.Name = "Label"
        text.BackgroundTransparency = 1
        text.Size = UDim2.fromScale(1, 1)
        text.Text = label or ""
        text.TextSize = theme.type.button
        text.TextColor3 = P.Parchment
        text.Parent = button
        theme.applyFont(text, "title")
        button:GetPropertyChangedSignal("Text"):Connect(function()
            if button.Text ~= "" and text.Text ~= button.Text then
                text.Text = button.Text
            end
        end)
        return button, text
    end

    -- toggle: a flat track and a bright knob, with no ornamental ring.
    function shapes.knotToggle(parent, order)
        local track = Instance.new("Frame")
        track.Name = "Track"
        track.BackgroundColor3 = P.Moss
        track.BackgroundTransparency = 0.2
        track.BorderSizePixel = 0
        track.Size = UDim2.fromOffset(36, 18)
        track.LayoutOrder = order or 2
        track.Parent = parent
        pill(track)
        shapes.stroke(track, P.Bark, 1)
        local knob = Instance.new("Frame")
        knob.Name = "Knob"
        knob.BackgroundColor3 = P.Parchment
        knob.BorderSizePixel = 0
        knob.Size = UDim2.fromOffset(14, 14)
        knob.Position = UDim2.fromOffset(1, 2)
        knob.Parent = track
        corner(knob, 999)
        local dot = Instance.new("Frame")
        dot.Name = "Dot"
        dot.BackgroundColor3 = P.Wood
        dot.BorderSizePixel = 0
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.fromScale(0.5, 0.5)
        dot.Size = UDim2.fromOffset(4, 4)
        dot.Parent = knob
        corner(dot, 999)
        local halo = Instance.new("UIStroke")
        halo.Color = P.Fern
        halo.Thickness = 1
        halo.Transparency = 1
        halo.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        halo.Parent = track
        return track, knob, halo
    end

    -- slider: a two-pixel glass groove with a bright signal thumb.
    function shapes.vineSlider(parent, order)
        local track = Instance.new("Frame")
        track.Name = "Track"
        track.BackgroundColor3 = P.Wood
        track.BorderSizePixel = 0
        track.Size = UDim2.new(1, 0, 0, 18)
        track.BackgroundTransparency = 1
        track.LayoutOrder = order or 2
        track.Active = true
        track.Parent = parent
        local groove = Instance.new("Frame")
        groove.Name = "Groove"
        groove.BackgroundColor3 = P.Bark
        groove.BorderSizePixel = 0
        groove.AnchorPoint = Vector2.new(0, 0.5)
        groove.Position = UDim2.new(0, 0, 0.5, 0)
        groove.Size = UDim2.new(1, 0, 0, 2)
        groove.Parent = track
        corner(groove, 999)
        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.BackgroundColor3 = P.LeafLight
        fill.BorderSizePixel = 0
        fill.AnchorPoint = Vector2.new(0, 0.5)
        fill.Position = UDim2.new(0, 0, 0.5, 0)
        fill.Size = UDim2.new(0, 0, 0, 2)
        fill.Parent = track
        corner(fill, 999)
        local thumbHolder = Instance.new("Frame")
        thumbHolder.Name = "ThumbHolder"
        thumbHolder.BackgroundTransparency = 1
        thumbHolder.AnchorPoint = Vector2.new(0, 0.5)
        thumbHolder.Position = UDim2.new(0, 0, 0.5, 0)
        thumbHolder.Size = UDim2.fromOffset(0, 18)
        thumbHolder.Parent = track
        local thumb = Instance.new("Frame")
        thumb.Name = "Thumb"
        thumb.BackgroundColor3 = P.Parchment
        thumb.BorderSizePixel = 0
        thumb.AnchorPoint = Vector2.new(0.5, 0.5)
        thumb.Position = UDim2.fromScale(0, 0.5)
        thumb.Size = UDim2.fromOffset(10, 10)
        thumb.Parent = thumbHolder
        corner(thumb, 999)
        local halo = Instance.new("UIStroke")
        halo.Color = P.Fern
        halo.Thickness = 2
        halo.Transparency = 0.25
        halo.Parent = thumb
        local nubHolder = Instance.new("Frame")
        nubHolder.Name = "NubHolder"
        nubHolder.BackgroundTransparency = 1
        nubHolder.AnchorPoint = Vector2.new(0, 0.5)
        nubHolder.Position = UDim2.new(0, 0, 0.5, 0)
        nubHolder.Size = UDim2.fromOffset(2, 12)
        nubHolder.Parent = track
        return track, fill, thumbHolder, thumb
    end

    function shapes.barkTablet(parent, height, order)
        local tablet = Instance.new("Frame")
        tablet.Name = "Tablet"
        tablet.BackgroundColor3 = P.DeepForest
        tablet.BackgroundTransparency = 0.08
        tablet.BorderSizePixel = 0
        tablet.Size = UDim2.new(1, 0, 0, height or 34)
        tablet.LayoutOrder = order or 1
        tablet.Parent = parent
        corner(tablet, theme.radius.sign)
        shapes.stroke(tablet, P.Bark, 1)
        local sheen = Instance.new("UIGradient")
        sheen.Color = ColorSequence.new(P.Moss, P.Wood)
        sheen.Rotation = 90
        sheen.Transparency = NumberSequence.new(0.42)
        sheen.Parent = tablet
        return tablet
    end

    function shapes.chip(parent, text, order)
        local chip = Instance.new("Frame")
        chip.Name = "Chip"
        chip.BackgroundColor3 = P.Wood
        chip.BackgroundTransparency = 0.08
        chip.BorderSizePixel = 0
        chip.AutomaticSize = Enum.AutomaticSize.X
        chip.Size = UDim2.fromOffset(0, 18)
        chip.LayoutOrder = order or 1
        chip.Parent = parent
        corner(chip, theme.radius.chip)
        shapes.stroke(chip, P.Bark, 1, 0.4)
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.AutomaticSize = Enum.AutomaticSize.X
        label.Size = UDim2.fromOffset(0, 18)
        label.Text = text or ""
        label.TextSize = theme.type.footer
        label.TextColor3 = P.Muted
        theme.applyFont(label, "body")
        label.Parent = chip
        shapes.pad(chip, 0, 8, 0, 8)
        return chip, label
    end

    function shapes.scrollbar(scrollingFrame)
        scrollingFrame.ScrollBarThickness = 4
        scrollingFrame.ScrollBarImageColor3 = P.Fern
        scrollingFrame.ScrollBarImageTransparency = 0.25
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
        halo.BackgroundColor3 = P.Fern
        halo.BackgroundTransparency = 0.9
        halo.BorderSizePixel = 0
        halo.Size = UDim2.fromOffset(14, 14)
        halo.Position = UDim2.fromOffset(fly.origin.X - 4, fly.origin.Y - 4)
        halo.Active = false
        halo.Parent = host
        local haloCorner = Instance.new("UICorner")
        haloCorner.CornerRadius = UDim.new(1, 0)
        haloCorner.Parent = halo

        local dot = Instance.new("Frame")
        dot.Name = "Sparks"
        dot.BackgroundColor3 = P.LeafLight
        dot.BorderSizePixel = 0
        dot.Size = UDim2.fromOffset(3, 3)
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
