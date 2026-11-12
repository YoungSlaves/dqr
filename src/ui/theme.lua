-- ui/theme.lua -- the single source of colour, size and type.
-- No colour literal exists outside this file: every other module asks the
-- theme.  The two sanctioned semantic hexes (warning/danger) live here too.
return function(context)
    local theme = {}

    -- ---------------------------------------------------------------- palette
    local P = {
        DeepForest = Color3.fromHex("0f2a1d"),
        Moss = Color3.fromHex("2f5d3a"),
        Fern = Color3.fromHex("5b8c3a"),
        LeafLight = Color3.fromHex("a8c66c"),
        Bark = Color3.fromHex("4a3222"),
        Wood = Color3.fromHex("7a5230"),
        Parchment = Color3.fromHex("efe6c8"),
        Firefly = Color3.fromHex("f2d974"),
    }
    local SEMANTIC = {
        warning = Color3.fromHex("e8b84b"),
        danger = Color3.fromHex("cf5b3a"),
    }

    local function dim(color, alpha)
        return color:Lerp(P.DeepForest, alpha)
    end

    theme.palette = P
    theme.deepForest, theme.moss, theme.fern = P.DeepForest, P.Moss, P.Fern
    theme.leafLight, theme.bark, theme.wood = P.LeafLight, P.Bark, P.Wood
    theme.parchment, theme.firefly = P.Parchment, P.Firefly
    theme.warning, theme.danger = SEMANTIC.warning, SEMANTIC.danger

    -- derived (no new hexes)
    theme.text = {
        primary = P.Parchment,
        secondary = P.Parchment, -- 0.30 transparency, applied by the text helper
        muted = P.Parchment, -- 0.50 transparency
        onAccent = P.DeepForest,
        secondaryAlpha = 0.30,
        mutedAlpha = 0.50,
    }
    theme.panelDim = P.Moss -- 0.18 transparency
    theme.panelDimAlpha = 0.18
    theme.rowPlank = P.Wood -- 0.35 transparency
    theme.rowPlankAlpha = 0.35
    theme.scrim = P.DeepForest
    theme.scrimAlpha = 0.55

    -- ---------------------------------------------------------------- metrics
    theme.window = {
        width = 760,
        height = 520,
        minWidth = 600,
        minHeight = 400,
        maxWidth = 1100,
        maxHeight = 780,
    }
    theme.header = 56
    theme.branch = { height = 6, knot = 4, rope = 12 }
    theme.sign = { width = 168, height = 34, radius = 3 }
    theme.rail = { width = 216, tabWidth = 184, tabHeight = 34, ropeRailX = 10 }
    theme.footer = 30
    theme.row = { height = 34, caption = 46, radius = 4 }
    theme.pad = { window = 14, row = 6, group = 8, section = 12 }
    theme.gap = { row = 6, group = 8, section = 12 }
    theme.stroke = { bark = 3, inner = 1, innerInset = 2, innerAlpha = 0.55, hairlineAlpha = 0.6 }
    theme.radius = { plank = 4, stone = 10, sign = 3, chip = 3, pill = 999 }
    theme.touch = 44
    theme.tabRotations = { -0.7, 0.7, -0.7, 0.7, -0.7, 0.7 }
    theme.motion = {
        hover = 0.12,
        tab = 0.18,
        open = 0.32,
        close = 0.16,
        fireflyMin = 1.2,
        fireflyMax = 2.4,
        driftMin = 6,
        driftMax = 10,
        footerPulse = 1.8,
    }
    theme.type = {
        sign = 16,
        tab = 13,
        section = 14,
        sectionDesc = 11,
        row = 13,
        caption = 11,
        button = 13,
        input = 13,
        value = 11,
        footer = 11,
    }

    -- optional decoration assets.  While nil, no ImageLabel is created at all.
    theme.VINE_IMAGE_ID = nil -- TODO: vine sprite asset id
    theme.LEAF_IMAGE_ID = nil -- TODO: leaf sprite asset id

    -- ------------------------------------------------------- legacy aliases
    -- The page bodies (extracted verbatim) still read the old surface names.
    -- Every alias resolves to a Duskwood colour; no hex is introduced.
    theme.TextPrimary = theme.text.primary
    theme.TextSub = dim(P.Parchment, 0.30)
    theme.TextMuted = dim(P.Parchment, 0.50)
    theme.TextOnAccent = theme.text.onAccent
    theme.StatusBad = SEMANTIC.danger
    theme.StatusGood = P.LeafLight
    theme.SurfaceHeader = P.DeepForest
    theme.SurfaceElement = dim(P.Wood, 0.35)
    theme.SurfaceHover = dim(P.Wood, 0.18)
    theme.SurfaceField = P.DeepForest
    theme.SurfaceSection = dim(P.Moss, 0.30)
    theme.SurfaceWell = dim(P.DeepForest, 0.10)
    theme.SurfaceChip = P.Bark
    theme.Hairline = P.Bark
    theme.BodyTop = P.Moss
    theme.BodyMid = P.DeepForest
    theme.BodyBot = P.DeepForest
    theme.BodyTopA = 0.18
    theme.BodyMidA = 0.05
    theme.BodyBotA = 0.05
    theme.SweepSpeed = 0.22
    theme.AccentA = P.Fern
    theme.AccentMid = P.Firefly
    theme.AccentB = P.Fern
    theme.AccentDark = P.Moss
    theme.RadiusSm = 4
    theme.RadiusMd = 4
    theme.RadiusLg = 10
    theme.GapSm = 6
    theme.GapMd = 8
    theme.GapLg = 12
    theme.GapXl = 14
    theme.RowH = 34
    theme.HeaderH = 56

    -- ------------------------------------------------------------ typography
    -- Resolved exactly once, at boot, and cached.  Never per label, never per
    -- frame, never over the network: rbxasset:// is a client-local lookup.
    local candidates = {
        title = {
            family = "rbxasset://fonts/families/Fondamento.json",
            enumName = "Fondamento",
            substitute = Enum.Font.Garamond,
        },
        body = {
            family = "rbxasset://fonts/families/Merriweather.json",
            enumName = "Merriweather",
            substitute = Enum.Font.SourceSans,
        },
    }

    local resolved = {}

    local function resolve(candidate)
        if candidate.family then
            local ok, face = pcall(Font.new, candidate.family)
            if ok and face then
                local holder = Instance.new("Folder")
                local applied = pcall(function()
                    local probe = Instance.new("TextLabel")
                    probe.FontFace = face
                    probe.Text = "Aa"
                    probe.Visible = false
                    probe.Parent = holder
                end)
                holder:Destroy()
                if applied then
                    return { FontFace = face }, "asset"
                end
            end
        end
        if candidate.enumName then
            local okEnum, enumItem = pcall(function()
                return Enum.Font[candidate.enumName]
            end)
            if okEnum and enumItem then
                return { Font = enumItem }, "enum"
            end
        end
        return { Font = candidate.substitute }, "substitute"
    end

    for role, candidate in pairs(candidates) do
        local value, how = resolve(candidate)
        value.path = how
        resolved[role] = value
    end

    theme.fonts = resolved
    theme.fontCandidates = candidates

    if context.log then
        context.log(
            "UI",
            "fonts: title="
                .. tostring(resolved.title.path)
                .. " body="
                .. tostring(resolved.body.path)
        )
    end

    -- apply a cached face to a text object; never sets both Font and FontFace
    function theme.applyFont(object, role)
        local font = resolved[role] or resolved.body
        if font.FontFace then
            object.FontFace = font.FontFace
        else
            object.Font = font.Font
        end
        return object
    end

    context.Theme = theme
end
