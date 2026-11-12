-- draw/style.lua -- section 8 world-space language.  World visuals keep their
-- meaning; only the values are remapped to Duskwood.  The menu's decoration
-- never leaks here: no fireflies, no vines, no signs.
return function(context)
    local theme = context.Theme
    local P = theme.palette
    local TweenService = context.getService("TweenService")

    local style = {
        hazard = P.LeafLight,
        danger = theme.danger,
        ally = P.LeafLight,
        wall = P.Fern,
        wallTransparency = 0.55,
        wallFill = 0.10,
        range = P.Firefly,
        rangeTransparency = 0.35,
        text = P.Parchment,
        textMuted = P.Parchment,
        plate = P.DeepForest,
        plateAlpha = 0.70,
        hairline = P.Bark,
    }

    function style.round(object, radius)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius or 4)
        corner.Parent = object
        return corner
    end

    function style.hairline(object)
        local stroke = Instance.new("UIStroke")
        stroke.Color = P.Bark
        stroke.Thickness = 1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = object
        return stroke
    end

    function style.pad(object, top, right, bottom, left)
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, top or 1)
        padding.PaddingRight = UDim.new(0, right or 3)
        padding.PaddingBottom = UDim.new(0, bottom or 1)
        padding.PaddingLeft = UDim.new(0, left or 3)
        padding.Parent = object
        return padding
    end

    function style.font(object, role)
        if theme and theme.applyFont then
            theme.applyFont(object, role or "body")
        else
            object.Font = Enum.Font.SourceSans
        end
    end

    -- labels are upper case by spec; names in the plate follow the same rule
    function style.uppercase(label)
        local updating = false
        local function apply()
            if updating then
                return
            end
            local text = tostring(label.Text or "")
            local upper = string.upper(text)
            if upper ~= text then
                updating = true
                label.Text = upper
                updating = false
            end
        end
        apply()
        label:GetPropertyChangedSignal("Text"):Connect(apply)
    end

    function style.applyOutline(box, color, thickness)
        if not box then
            return box
        end
        box.LineThickness = thickness or 1.5
        box.Color3 = color
        box.SurfaceTransparency = 1
        return box
    end

    function style.fade(object, duration, properties)
        local tween = TweenService:Create(
            object,
            TweenInfo.new(duration or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            properties
        )
        tween:Play()
        return tween
    end

    context.drawStyle = style
end
