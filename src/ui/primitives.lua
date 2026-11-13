-- ui/primitives.lua -- text, layout, tooltips, hover.  No shapes, no colours:
-- everything is asked of ui/theme.lua and ui/shapes.lua.
return function(context)
    local theme = context.Theme
    local shapes = context.shapes
    local P = theme.palette
    local TweenService = context.getService("TweenService")
    local userInputService = context.UserInputService
    local runService = context.RunService

    local prim = {}

    ---------------------------------------------------------------- typography
    local ROLES = {
        title = { role = "title", size = theme.type.sign, color = P.Parchment, transparency = 0 },
        tab = { role = "title", size = theme.type.tab, color = P.Parchment, transparency = 0 },
        section = { role = "title", size = theme.type.section, color = P.LeafLight, transparency = 0 },
        sectionDesc = { role = "body", size = theme.type.sectionDesc, color = P.Muted, transparency = 0 },
        rowLabel = { role = "body", size = theme.type.row, color = P.Parchment, transparency = 0 },
        rowCaption = { role = "body", size = theme.type.caption, color = P.Muted, transparency = 0 },
        captionKey = { role = "body", size = theme.type.caption, color = P.Muted, transparency = 0.18 },
        captionSub = { role = "body", size = theme.type.caption, color = P.Muted, transparency = 0 },
        captionStat = { role = "body", size = theme.type.caption, color = P.Muted, transparency = 0.12 },
        button = { role = "title", size = theme.type.button, color = P.Parchment, transparency = 0 },
        buttonAccent = { role = "title", size = theme.type.button, color = P.DeepForest, transparency = 0 },
        input = { role = "body", size = theme.type.input, color = P.Parchment, transparency = 0 },
        value = { role = "body", size = theme.type.value, color = P.Parchment, transparency = 0.30 },
        footer = { role = "body", size = theme.type.footer, color = P.Parchment, transparency = 0.50 },
        windowTitle = { role = "title", size = 16, color = P.Parchment, transparency = 0 },
        windowChip = { role = "title", size = 16, color = P.Parchment, transparency = 0 },
        rowButton = { role = "title", size = theme.type.button, color = P.DeepForest, transparency = 0 },
        rowEntry = { role = "body", size = theme.type.input, color = P.Parchment, transparency = 0 },
        rowStat = { role = "body", size = 14, color = P.Parchment, transparency = 0 },
        monoValue = { role = "body", size = 11, color = P.DeepForest, transparency = 0 },
        monoMeta = { role = "body", size = 10, color = P.Parchment, transparency = 0.50 },
        monoStat = { role = "body", size = 13, color = P.Parchment, transparency = 0.30 },
    }
    prim.roles = ROLES

    -- legacy signature (object, "sans"|"mono"|"title", weight): weight is ignored,
    -- hierarchy comes from size and colour only.
    function prim.setFont(object, family, _weight)
        local role = family == "title" and "title" or "body"
        theme.applyFont(object, role)
        return object
    end

    function prim.text(parent, spec)
        local appearance = ROLES[spec.role or "rowLabel"] or ROLES.rowLabel
        local label = Instance.new("TextLabel")
        label.Name = spec.name or "Text"
        label.BackgroundTransparency = 1
        label.Text = spec.text or ""
        label.TextSize = spec.size or appearance.size
        label.TextColor3 = spec.color or appearance.color
        label.TextTransparency = spec.transparency or appearance.transparency
        label.TextXAlignment = spec.xAlign or Enum.TextXAlignment.Left
        label.TextYAlignment = spec.yAlign or Enum.TextYAlignment.Center
        label.TextWrapped = spec.wrapped or false
        label.TextTruncate = spec.truncate or Enum.TextTruncate.None
        label.Size = spec.size2 or UDim2.new(1, 0, 1, 0)
        label.Position = spec.position or UDim2.fromOffset(0, 0)
        if spec.layoutOrder then
            label.LayoutOrder = spec.layoutOrder
        end
        if spec.zIndex then
            label.ZIndex = spec.zIndex
        end
        if spec.automaticSize then
            label.AutomaticSize = spec.automaticSize
        end
        theme.applyFont(label, spec.font or appearance.role)
        label.Parent = parent
        return label
    end

    function prim.icon(parent, name, size, color, zIndex)
        -- Icons shipped with the original build are catalogue ids looked up
        -- client-side (rbxassetid://), never fetched.  Named icons only.
        local image = Instance.new("ImageLabel")
        image.Name = "Icon_" .. tostring(name)
        image.BackgroundTransparency = 1
        image.BorderSizePixel = 0
        image.Image = ""
        image.ImageColor3 = color or P.Parchment
        image.ScaleType = Enum.ScaleType.Fit
        image.Size = UDim2.fromOffset(size or 16, size or 16)
        if zIndex then
            image.ZIndex = zIndex
        end
        image.Parent = parent
        return image
    end

    ---------------------------------------------------------------- layout
    function prim.vlist(parent, padding)
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.Padding = UDim.new(0, padding or theme.gap.row)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = parent
        return layout
    end

    function prim.hlist(parent, padding)
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, padding or theme.gap.group)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = parent
        return layout
    end

    function prim.flexFill(object, reserved, yScale, yOffset)
        if not object then
            return false
        end
        object.Size = UDim2.new(1, -reserved, yScale or 1, yOffset or 0)
        return true
    end

    ---------------------------------------------------------------- interaction
    function prim.hoverStroke(target, strokeObject, fromAlpha, toAlpha)
        target.MouseEnter:Connect(function()
            TweenService:Create(
                strokeObject,
                TweenInfo.new(theme.motion.hover, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Transparency = toAlpha or 0.4 }
            ):Play()
        end)
        target.MouseLeave:Connect(function()
            TweenService:Create(
                strokeObject,
                TweenInfo.new(theme.motion.hover, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Transparency = fromAlpha or 1 }
            ):Play()
        end)
    end

    function prim.pressable(button)
        if button:FindFirstChildOfClass("UIScale") then
            return
        end
        local scale = Instance.new("UIScale")
        scale.Parent = button
        button.MouseButton1Down:Connect(function()
            TweenService:Create(scale, TweenInfo.new(0.08, Enum.EasingStyle.Quad), { Scale = 0.96 }):Play()
        end)
        local function release()
            TweenService:Create(
                scale,
                TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Scale = 1 }
            ):Play()
        end
        button.MouseButton1Up:Connect(release)
        button.MouseLeave:Connect(release)
    end

    ------------------------------------------------------------------ tooltips
    local tipState = { frame = nil, label = nil, target = nil, showAt = nil, conn = nil, host = nil }
    local tipText = {}
    prim.tipText = tipText

    function prim.ensureTip(host)
        if host then
            tipState.host = host
        end
    end

    local function hideTip()
        tipState.target = nil
        if tipState.frame then
            tipState.frame.Visible = false
        end
    end
    prim.hideTip = hideTip

    local function buildTip()
        if tipState.frame and tipState.frame.Parent then
            return
        end
        local host = tipState.host
        if not host then
            return
        end
        local frame = Instance.new("Frame")
        frame.Name = "Tooltip"
        frame.BackgroundColor3 = P.DeepForest
        frame.BackgroundTransparency = 0.02
        frame.BorderSizePixel = 0
        frame.Visible = false
        frame.ZIndex = 500
        frame.AutomaticSize = Enum.AutomaticSize.XY
        frame.Size = UDim2.fromOffset(0, 0)
        frame.Parent = host
        shapes.corner(frame, theme.radius.sign)
        shapes.stroke(frame, P.Fern, 1, 0.25)
        shapes.pad(frame, 7, 9, 7, 9)
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.AutomaticSize = Enum.AutomaticSize.XY
        label.Size = UDim2.fromOffset(0, 0)
        label.TextWrapped = true
        label.TextSize = theme.type.caption
        label.TextColor3 = P.Parchment
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.ZIndex = 501
        theme.applyFont(label, "body")
        label.Parent = frame
        local constraint = Instance.new("UISizeConstraint")
        constraint.MaxSize = Vector2.new(240, math.huge)
        constraint.Parent = label
        tipState.frame, tipState.label = frame, label
        if tipState.conn then
            tipState.conn:Disconnect()
        end
        tipState.conn = runService.RenderStepped:Connect(function()
            if not tipState.target then
                return
            end
            if not tipState.frame.Visible then
                if os.clock() < tipState.showAt then
                    return
                end
                tipState.frame.Visible = true
            end
            local mouse = userInputService:GetMouseLocation()
            local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
            local width, height = frame.AbsoluteSize.X, frame.AbsoluteSize.Y
            local x = mouse.X + 16 + width > viewport.X and mouse.X - 16 - width or mouse.X + 16
            local y = mouse.Y + 18 + height > viewport.Y and mouse.Y - 12 - height or mouse.Y + 18
            frame.Position = UDim2.fromOffset(x, y)
        end)
    end

    function prim.tip(target, text)
        if not text or text == "" then
            return target
        end
        tipText[target] = text
        target.Destroying:Connect(function()
            tipText[target] = nil
        end)
        target.MouseEnter:Connect(function()
            buildTip()
            if not tipState.frame then
                return
            end
            tipState.target = target
            tipState.showAt = os.clock() + 0.45
            tipState.frame.Visible = false
            tipState.label.Text = text
        end)
        target.MouseLeave:Connect(function()
            if tipState.target == target then
                hideTip()
            end
        end)
        target.AncestryChanged:Connect(function()
            if not target:IsDescendantOf(game) and tipState.target == target then
                hideTip()
            end
        end)
        return target
    end

    context.primitives = prim
end
