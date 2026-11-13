-- ui/theme.lua -- the single source of colour, size and type.
-- No colour literal exists outside this file: every other module asks the
-- theme.  The two sanctioned semantic hexes (warning/danger) live here too.
return function(context)
    local theme = {}

    -- ---------------------------------------------------------------- palette
    local P = {
        DeepForest = Color3.fromHex("070b12"),
        Moss = Color3.fromHex("0d1624"),
        Fern = Color3.fromHex("55c8ff"),
        LeafLight = Color3.fromHex("75f2c7"),
        Bark = Color3.fromHex("24384f"),
        Wood = Color3.fromHex("111e30"),
        Parchment = Color3.fromHex("eaf7ff"),
        Firefly = Color3.fromHex("c8ff6a"),
        Hot = Color3.fromHex("ff6fd8"),
        Muted = Color3.fromHex("8fa7be"),
    }
    local SEMANTIC = {
        warning = Color3.fromHex("ffc857"),
        danger = Color3.fromHex("ff6b7a"),
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
        secondary = P.Muted,
        muted = P.Muted,
        onAccent = P.DeepForest,
        secondaryAlpha = 0.10,
        mutedAlpha = 0.35,
    }
    theme.panelDim = P.Wood -- 0.10 transparency
    theme.panelDimAlpha = 0.10
    theme.rowPlank = P.Wood -- 0.12 transparency
    theme.rowPlankAlpha = 0.12
    theme.scrim = P.DeepForest
    theme.scrimAlpha = 0.68
    theme.accent = P.LeafLight
    theme.accentCool = P.Fern
    theme.accentHot = P.Hot
    theme.line = P.Bark
    theme.surface = P.Wood

    -- ---------------------------------------------------------------- metrics
    theme.window = {
        width = 920,
        height = 600,
        minWidth = 720,
        minHeight = 500,
        maxWidth = 1280,
        maxHeight = 900,
    }
    theme.header = 68
    theme.branch = { height = 2, knot = 3, rope = 0 }
    theme.sign = { width = 196, height = 36, radius = 9 }
    theme.rail = { width = 214, tabWidth = 194, tabHeight = 40, ropeRailX = 0 }
    theme.footer = 34
    theme.row = { height = 38, caption = 50, radius = 8 }
    theme.pad = { window = 18, row = 7, group = 9, section = 14 }
    theme.gap = { row = 7, group = 9, section = 14 }
    theme.stroke = { bark = 1, inner = 1, innerInset = 1, innerAlpha = 0.82, hairlineAlpha = 0.45 }
    theme.radius = { plank = 8, stone = 15, sign = 9, chip = 999, pill = 999 }
    theme.touch = 46
    theme.tabRotations = { 0, 0, 0, 0, 0, 0 }
    theme.motion = {
        hover = 0.15,
        tab = 0.22,
        open = 0.34,
        close = 0.18,
        fireflyMin = 1.8,
        fireflyMax = 3.2,
        driftMin = 4,
        driftMax = 7,
        footerPulse = 2.4,
    }
    theme.type = {
        sign = 18,
        tab = 13,
        section = 16,
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
    theme.TextSub = P.Muted
    theme.TextMuted = dim(P.Muted, 0.22)
    theme.TextOnAccent = theme.text.onAccent
    theme.StatusBad = SEMANTIC.danger
    theme.StatusGood = P.LeafLight
    theme.SurfaceHeader = P.DeepForest
    theme.SurfaceElement = dim(P.Wood, 0.10)
    theme.SurfaceHover = dim(P.Wood, 0.02)
    theme.SurfaceField = P.Moss
    theme.SurfaceSection = dim(P.Moss, 0.06)
    theme.SurfaceWell = dim(P.DeepForest, 0.04)
    theme.SurfaceChip = P.Wood
    theme.Hairline = P.Bark
    theme.BodyTop = P.Wood
    theme.BodyMid = P.Moss
    theme.BodyBot = P.DeepForest
    theme.BodyTopA = 0.04
    theme.BodyMidA = 0.02
    theme.BodyBotA = 0.02
    theme.SweepSpeed = 0.22
    theme.AccentA = P.Fern
    theme.AccentMid = P.Firefly
    theme.AccentB = P.LeafLight
    theme.AccentDark = P.Moss
    theme.RadiusSm = 8
    theme.RadiusMd = 10
    theme.RadiusLg = 15
    theme.GapSm = 7
    theme.GapMd = 9
    theme.GapLg = 14
    theme.GapXl = 18
    theme.RowH = 38
    theme.HeaderH = 68

    -- ------------------------------------------------------------ typography
    -- Resolved exactly once, at boot, and cached.  Never per label, never per
    -- frame, never over the network: rbxasset:// is a client-local lookup.
    local candidates = {
        title = {
            family = "rbxasset://fonts/families/GothamBlack.json",
            enumName = "GothamBlack",
            substitute = Enum.Font.Garamond,
        },
        body = {
            family = "rbxasset://fonts/families/Gotham.json",
            enumName = "Gotham",
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
