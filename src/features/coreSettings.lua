-- Extracted verbatim from harvardd.lua lines 40-2746; presentation owned elsewhere.
return function(context)
    context.DEV = false
    if context.DEV then
        if getgenv ~= nil then
            pcall(function()
                getgenv().HL_S = context
            end)
        end
    end
    context.NOVIS = not context.DEV
    if not (game:IsLoaded()) then
        game.Loaded:Wait()
    end
    if type(_G.DungeonAutofarmDestruct) == "function" then
        local success, sharedValue = pcall(_G.DungeonAutofarmDestruct)
        if not success then
            warn("[DQ] could not stop the previous copy: " .. tostring(sharedValue))
        end
        task.wait(0.1)
    end
    local players = getService("Players")
    local localPlayer = players.LocalPlayer
    while not localPlayer do
        task.wait(0.1)
        localPlayer = players.LocalPlayer
    end
    local sharedValue2 = game:GetService("Workspace")
    local runService, replicatedStorage, userInputService, pathfindingService, virtualInputManager, httpService =
        getService("RunService"),
        getService("ReplicatedStorage"),
        getService("UserInputService"),
        getService("PathfindingService"),
        getService("VirtualInputManager"),
        getService("HttpService")
    if _G.DungeonAutofarmDestruct then
        pcall(_G.DungeonAutofarmDestruct)
    end
    _G.DungeonAutofarmVersion = "v3.0 c84b"
    local burstMin, burstMaxSpeed = 18, 28
    local config = {
        tweenWalk = 16,
        tweenEscape = 26,
        burstMin = burstMin,
        burstMax = burstMaxSpeed,
        burstMargin = 1.15,
        boostMaxRun = 1.5,
        boostRest = 1.2,
        boostUrgentRun = 2.5,
        boostUrgentRest = 0.8,
        boostDrain = 8,
        boostDebtMax = 12,
        boostDebtStart = 3,
        boostRestMin = 0.4,
        tweenSlam = burstMaxSpeed,
        tweenSprint = burstMaxSpeed,
        policyVersion = 148,
        maxStepHeight = 2.4,
        boostGrace = 1.5,
        boostRelease = 0.45,
        wallsOn = true,
        wallTransparency = 0,
        wallClearView = true,
        watchToFile = true,
        bubbleRadius = 2.8,
        bubbleLookahead = 1,
        bubbleSettle = 0.25,
        bubbleMinWeight = 0.25,
        drawBubble = true,
        drawScan = true,
        bubbleHardAt = 1,
        bubbleSoftCost = 8,
        bubbleTrajLead = 2.4,
        bubbleTrajCost = 14,
        bubbleWarnLead = 1.5,
        missileAxisCost = 1.2,
        missileAxisCap = 30,
        bobSpikeTowardCost = 12,
        bobSpikeTowardCap = 260,
        bobSpikeSideCost = 4,
        bobSpikeSideCap = 120,
        fanCleanFar = 0.4,
        fanCleanExtra = 4,
        fanNearBeat = 14,
        ringSlim = 2.5,
        ringCentre = true,
        ringCentreWeight = 1.3,
        ringCentreCap = 14,
        insideMinRun = 2,
        ringOutCost = 4,
        ringEndCost = 90,
        ringCrossCost = 22,
        insideSlack = 0.5,
        outCost = 2.5,
        goalFloor = 1,
        buffFreeGap = 20,
        buffOrbNear = 26,
        buffFromTool = true,
        buffWaitMax = 1.3,
        buffOnMobEscape = true,
        buffGapWait = true,
        quietLean = 30,
        quietBehindDeg = 80,
        quietFresh = 6,
        quietSoon = 2.5,
        groupWaypoints = true,
        wpLinkRadius = 45,
        wpArrive = 4,
        wpStallFor = 4,
        wpPreRange = 0,
        strikeArrive = 2.5,
        gatherPoints = true,
        gatherGiveUp = 6,
        strikeGiveUp = 3,
        homeArrive = 3,
        ghostWalls = true,
        ghostStallAt = 1.2,
        ghostHalf = 10,
        ghostDraw = true,
        carrotNodes = 6,
        carrotMax = 18,
        carrotEvery = 0.15,
        centreEase = 0.15,
        resetAfterArena = true,
        resetAfterClear = 0,
        resetRespawnGap = 0,
        resetRoomLeave = 150,
        resetRespawnGap = 0,
        resetRoomGroups = 4,
        resetRoomRadius = 170,
        resetAfterBob = true,
        wpPreSpawned = 70,
        drawLanding = true,
        firstCastWait = 1,
        firstCastSlack = 1.5,
        firstCastBothWait = 12,
        firstCastInDisc = false,
        firstCastWaitFit = 1,
        mobPathClear = 10,
        mobKeepOutWeight = 0.35,
        warriorKeepOut = 14,
        spearmanKeepOut = 12,
        warriorKeepOutWeight = 0.7,
        homeIdleFor = 2,
        meleeSwing = true,
        meleeSwingD = 22,
        meleeSwingPace = 10,
        meleeSwingDone = 20,
        meleeEscape = true,
        meleeEscapeAt = 36,
        meleeEscapeHyst = 10,
        meleeAwayD = 22,
        meleeBurst = true,
        casterWhileDodging = true,
        faceTarget = true,
        faceWithin = 25,
        odinV2 = true,
        volleySlotHold = true,
        volleyLive = 7,
        volleyArenaR = 100,
        ringPathCheck = true,
        fieldReach = 45,
        fieldHold = 0.8,
        fieldStep = 3,
        fieldHeadings = 24,
        fieldOrbKeep = 10,
        fieldLineLive = 1.2,
        fieldLaneMargin = 1,
        fieldAnchorWeight = 0.25,
        odinIdleR = 70,
        odinCloseAlways = true,
        odinHoldInReach = true,
        odinBandIn = 50,
        odinBandOut = 87.5,
        odinBandWeight = 0.8,
        fieldReachWeight = 0.6,
        fieldReachWeightReady = 1.8,
        fieldInReachBonus = 30,
        fieldArenaR = 105,
        fieldSpeed = 24,
        ringFlashFrom = 0.9,
        lineHitFrom = 0.45,
        missileBodyKeep = 26,
        fieldLineMargin = 0.5,
        fieldLineHoldWeight = 1,
        missilePassT = 0.9,
        missilePassClear = 1.5,
        ringPosTol = 4,
        ringSettle = 2,
        arrayGrace = 1.2,
        mageRowAhead = 4,
        mageRowLive = 1.05,
        mageHold = true,
        mageHoldClear = 2.5,
        mageHoldLook = 1.2,
        laneStepT = 0.2,
        spikeWallLead = 3,
        missileArray = true,
        missileLanePitch = 15,
        missileLaneWidth = 14,
        missileLaneSlim = 0.5,
        missileLaneFrom = 0,
        missileLaneLive = 5,
        missileLaneStep = 0.6,
        missileFlankAt = 4,
        ringDrawLift = 4,
        ringDrawFill = true,
        meleeRingLethal = false,
        buffSpeedCheck = true,
        buffSpeedOver = 0.5,
        bossBuffWait = 1,
        faceWriteEvery = 0.1,
        firstCastBuffMinCd = 4,
        facePhysics = true,
        orbLowestAngle = true,
        orbLeanWhileLethal = 1,
        orbGoalPull = 0.6,
        orbGoalCap = 20,
        strictGroupOrder = true,
        attackOnlyWithSpeed = false,
        crystalLineClear = 10,
        homeYieldCast = 1,
        faceMinDeg = 12,
        faceEvery = 0.25,
        orbBetweenHold = 0.5,
        mageStandoff = 38,
        mageTail = 0.3,
        mageFirst = true,
        offLineHold = 1,
        wpSkipWhenAggroed = true,
        champWp2AfterSlam = true,
        champWp2AfterReach = true,
        champWpArrive = 6,
        aoeRadius = 40,
        aoeDistance = 39.6,
        aoeDistanceGuess = 40,
        aoeMeasured = true,
        aoeKnown = {
            ["flame shuriken"] = { round = false, x = 50, z = 83, place = 38.5 },
            ["solar beam"] = { round = false, x = 76, z = 76, place = 40 },
            ["gale barrage"] = { round = false, x = 50, z = 83, place = 38.5 },
            ["soul drain"] = { round = true, x = 91, z = 91, place = 39.6 },
            geyser = { round = true, x = 95, z = 95, place = 39.6 },
            ["witches brew"] = { round = true, x = 45, z = 45, place = 17.5 },
        },
        aoeDistAdj = -5,
        aoeRadAdj = 2.5,
        aoeAdjClass = "mage",
        aoeHist = 7,
        aoeSave = true,
        aoeSaveEvery = 8,
        groupFacingsCoarse = 12,
        mageEscapePull = true,
        swingToMages = true,
        swingMageFrom = 70,
        mageEscapePullWeight = 14,
        mageEscapeFrom = 40,
        groupNumbers = true,
        aoeOnTargetTol = 4,
        walkInFrom = 35,
        orbLineClear = 24,
        orbAroundPad = 6,
        orbAroundAhead = 6,
        orbAroundMax = 40,
        orbRoundD = 18,
        orbRoundNeed = 28,
        orbRoundDone = 25,
        orbRoundGain = 1,
        orbRoundLead = 8,
        orbRoundMax = 30,
        orbExitClear = 20,
        orbExitD = 24,
        orbRoundStall = 2.5,
        orbPace = 15,
        castFanSpan = 50,
        castFanStep = 5,
        bubbleReplan = 0.2,
        passThroughSpeed = 8,
        drawProjected = true,
        bubbleScanBudget = 9,
        scanWarnMs = 10,
        lineSpentFor = 2.5,
        lineSpentGain = 70,
        bounceWeight = 1,
        bounceLeadTime = 0.7,
        bounceLaneWeight = 1,
        bouncePad = 5,
        odinReachBonus = 4,
        bubbleDetourStick = 4,
        bubbleDetourStuck = 3,
        bubbleBreachFloor = 3,
        centreBias = 14,
        bubbleAlongBonus = 10,
        pullWeight = 0,
        pullPlanFor = 3,
        radialOutBonus = 16,
        bubbleNoFlip = 2.5,
        bubbleFlipPenalty = 120,
        bubbleTurnCost = 30,
        bubbleStickFor = 1,
        mobSideDodge = true,
        mobSideWeight = 55,
        wallClear = 3,
        sideRoomFull = 30,
        pitWall = true,
        pitWallPad = 10,
        pitWallWeight = 6,
        pitWallCap = 60,
        mobSideCross = 140,
        mobSideBackCost = 18,
        mobSideHold = 3,
        bubbleStickWeight = 6,
        bubbleProbe = 72,
        bubbleOpenWeight = 0.55,
        bubbleCornerBoost = 3,
        bubbleWallPenalty = 3,
        bubbleLead = 0.35,
        spikeAheadStuds = 2,
        spikeAheadFly = 80,
        spikeAheadTime = 0.5,
        spikeAheadTrim = 4,
        warnAheadTime = 0.9,
        warnAheadWeight = 0.55,
        spikeGrowMax = 1.7,
        beamCrossYoung = 0.5,
        beamCrossHold = 0.9,
        bobKeepOutRadius = 68,
        bobKeepOutWeight = 0.7,
        champKeepOutRadius = 28,
        champKeepOutWeight = 0.7,
        expiryGrace = 0.6,
        bubbleDetourLeg = 14,
        bubbleStep = 1,
        bubbleMaxOut = 46,
        bubbleFarOut = 70,
        bubbleCleanExtra = 15,
        cleanTtiFloor = 1.2,
        cleanTtiMargin = 0.15,
        cleanHurryExtra = 0,
        cleanFarTime = 1.8,
        arriveHold = 1,
        bubbleCutPen = 400,
        bubbleHoldHalf = 0.5,
        spikeCrossBan = true,
        spikeCrossHorizon = 2.5,
        scanNodeMax = 320,
        scanNodeEvery = 3,
        insideExtra = 6,
        walkSoftMax = 3,
        leanWhileLethal = 0.25,
        spreadOutSlack = 3,
        roomyMargin = 10,
        seekAlongMax = 8,
        bubbleRays = 48,
        bubbleNearWeight = 4.5,
        bubbleCommit = 0.9,
        bubbleCommitMob = 0.9,
        bubbleArrive = 1.5,
        mobStandoff = 34,
        rangedStandoff = 22,
        meleeMobMaxReach = 16,
        meleeBuffer = 4,
        bossStandoff = 33,
        autoStandoff = true,
        autoStandoffMax = 90,
        aggroHold = 70,
        meleeThreatRange = 45,
        nearThreatRange = 30,
        groupDistCost = 40,
        missileLead = 1.4,
        spikeFieldEarly = 0.3,
        spikeFieldOuterOnly = true,
        buffInterval = 0.6,
        slotSwapReach = 40,
        orbKeepOut = 22,
        orbKeepSlack = 2,
        buffCooldown = 6,
        buffDuration = 5,
        buffRetry = 0.45,
        buffRetryFor = 1.4,
        slotResync = 1.5,
        spikeOutMargin = 6,
        spikeOutRun = 8,
        spikeMaxOut = 92,
        spikeStickCos = 0.35,
        spikeFieldRefresh = 0.6,
        odinLineMin = 62,
        odinLineSlack = 3,
        odinArcLean = 45,
        odinArcHold = 3,
        buffSpells = { "inner focus", "inner rage", "enhanced inner focus", "enhanced inner rage" },
        mageLead = true,
        mageLeadIn = 10,
        mageLead = false,
        rangeMargin = 4,
        probeGiveUp = 1,
        probeStep = 6,
        probeMax = 28,
        targetPriority = "group",
        abilityRangeKnown = 65,
        gatherMobs = true,
        strafe = true,
        castSafe = false,
        castSafeGrace = 0.6,
        ringBandRadius = 81.25,
        ringBandWeight = 0.3,
        ringThickness = 12.5,
        ringThicknessOuter = 17.5,
        groupStepIn = 12,
        bubbleFirstAt = 0.5,
        bubbleFirstSlack = 1,
        bubbleBadCommit = 0.8,
        badReplaceShare = 0.8,
        bubbleReachShare = 0.8,
        bubbleCommitMin = 0.1,
        bubbleMinRun = 6,
        bubbleSoftPick = 10,
        bubbleCrossCost = 14,
        bubbleSoftLook = 1.2,
        bubbleTrimMin = 4,
        bubbleBadSoft = 3,
        slamLean = 30,
        fanLean = 20,
        bobCircleLean = 40,
        bobCircleLeanRange = 110,
        wallLead = 1.2,
        fanRays = 72,
        fanStep = 1.5,
        pathOff = 15,
        pathAge = 1.5,
        wallLaneAhead = 1.4,
        wallLaneHalf = 8,
        wallThickPad = 2,
        wallLanePad = 2,
        wallLaneWeight = 0.3,
        ringIn = 3,
        ringSlack = 3,
        orbDodgeBias = 24,
        bobRingIn = 6,
        fanEarly = 4,
        fanQuiet = 3,
        fanFloorSlowOff = true,
        fanFloorPad = 3,
        fanInnerWeight = 0.6,
        beamRoomTime = 0.45,
        beamRoomNear = 0.3,
        beamRoomSlack = 0.2,
        stepOffSoon = 0.8,
        fanRadius = 108,
        leashRadius = 122,
        hubKeepOut = 60,
        bobHomeSlack = 0,
        orbReflexAt = 14,
        bigBossReach = 14,
        bobHomePull = 1,
        bobHomeLeadShare = 0.6,
        leadViaArrive = 4,
        orbGiveUpPace = 11,
        orbGiveUpSlack = 1.25,
        bobHomeReach = 14,
        bobHomeCap = 30,
        bobCentreBias = 30,
        fanBehindDeg = 0,
        rimLean = 12,
        bubbleLeaveWeight = 12,
        escHold = 1,
        planAtWalkOver = 0.5,
        odinLineHold = 85,
        odinLineLean = 40,
        orbBodyPad = 4,
        orbBlastDelay = 14.1,
        orbBlastRadius = 26,
        orbBlastLead = 2,
        invulnAfterRespawn = 4,
        invulnFloorPad = 5,
        odinRingIn = 4,
        odinEntryLean = 30,
        leadBeamYield = 1.5,
        fanInSlack = 4,
        slamBurstMax = 28,
        bossBackOffIn = 25,
        slamHoldFrom = 10,
        slamLockDeg = 35,
        slamLockWide = 70,
        bossReachIn = 4,
        castJudgeAt = 1.1,
        castCleanFor = 4,
        castMissRun = 3,
        castMissStep = 6,
        castStartAt = 44,
        castMinStand = 14,
        orbPathClear = 20,
        spikeRimRoom = 2.5,
        slamLockFor = 3,
        slamNearWeight = 12,
        dropMin = 4,
        dropNear = 5,
        dropPush = 6,
        leashMargin = 8,
        entranceKeepOut = 45,
        entranceLean = 20,
        bossFire = true,
        bossFireEvery = 0.1,
        bossFireSafe = true,
        bossFaceAlways = true,
        drawGroups = true,
        groupLink = 18,
        behindBonus = 22,
        mageGuideArc = true,
        firstCastWholeStrict = true,
        swingToIdle = true,
        statsEnabled = true,
        statsUrl = "",
        statsKey = "",
        dropArenaY = -40,
        groupFitMargin = 2,
        groupFitStretch = 1.3,
        groupSpreadCost = 9,
        groupWholeBonus = 14,
        groupFirstWhole = true,
        groupFirstWholeWait = 1,
        groupDecideMax = 1,
        groupDecidePit = 0.5,
        firstSpotFor = 3,
        firstSpotBonus = 26,
        groupMerge = true,
        preBossWp = { -576.42, 19.45, 417.02 },
        preBossWpFrom = 200,
        preBossWpArrive = 8,
        groupOrbs = true,
        groupOrbSize = 1.7,
        groupOrbHeight = 5.5,
        groupZoneRadius = 70,
        groupZonePull = 0.5,
        groupZoneCap = 14,
        groupZoneWall = true,
        groupZoneSlack = 2,
        travelBurst = true,
        travelBurstSpeed = 24,
        travelBurstFor = 1.2,
        travelBurstRest = 1.4,
        travelBurstFrom = 20,
        travelBurstPad = 10,
        hbPredict = 14,
        slamRunFor = 2.5,
        slamRunDist = 62,
        slamYieldTti = 1,
        slamClearMargin = 6,
        slamCommit = 2.5,
        slamRunOn = false,
        escapeCommit = 1.5,
        arenaWalkInTo = 80,
        arenaHoldIn = 65,
        arenaCloseToCast = true,
        arenaCastSlack = 4,
        arenaCastFloor = 40,
        arenaHoldOut = 80,
        slamBeatsHold = true,
        entranceTurn = 55,
        wrongCrystalClear = 18,
        spikeAxisCos = 0.8,
        champEntryBox = { -648.8, 363.8, 0.8497, -0.5273, 110.2, 41.9 },
        entrySideDeg = 50,
        orbSpeed = 17,
        wallNear = 30,
        missileAxisRoom = 6,
        ringLive = 1.3,
        champEntryBoxes = {
            { -648.8, 363.8, 0.8497, -0.5273, 110.2, 41.9 },
            { -519.6, 348.8, 0.8915, 0.4529, 74.7, 41.9 },
            { -714.6, 475.6, 0.0149, -0.9999, 74.7, 41.9 },
        },
        champWaypoints = { { -524.28, 18.97, 448 } },
        firstBossNoGo = {
            {
                -651.6504,
                38.8643,
                359.1892,
                0.84967,
                0,
                0.527314,
                0,
                1,
                0,
                -0.527314,
                0,
                0.84967,
                220.456,
                39,
                83.815,
            },
            {
                -502.0589,
                38.8643,
                590.6952,
                -0.84967,
                0,
                -0.527314,
                0,
                1,
                0,
                0.527314,
                0,
                -0.84967,
                220.456,
                39,
                83.815,
            },
            {
                -519.597,
                35.6167,
                348.8487,
                0.891544,
                0,
                -0.452934,
                0,
                1,
                0,
                0.452934,
                0,
                0.891544,
                149.456,
                39,
                83.815,
            },
            {
                -629.9012,
                35.6167,
                602.9568,
                -0.891544,
                0,
                0.452934,
                0,
                1,
                0,
                -0.452934,
                0,
                -0.891544,
                149.456,
                39,
                83.815,
            },
            {
                -716.5795,
                36.8454,
                475.5492,
                0.01488,
                0,
                0.999889,
                0,
                1,
                0,
                -0.999889,
                0,
                0.01488,
                149.456,
                39,
                83.815,
            },
            {
                -436.2773,
                36.8454,
                478.9011,
                -0.01488,
                0,
                -0.999889,
                0,
                1,
                0,
                0.999889,
                0,
                -0.01488,
                149.456,
                39,
                83.815,
            },
        },
        noGoWeight = 1,
        drawNoGo = true,
        drawWaypoints = true,
        drawLeads = true,
        noGoArmIn = 95,
        noGoArmOut = 120,
        noGoDwell = 1.1,
        noGoSafeDwell = 0.15,
        noGoSlamFree = true,
        noGoExitCross = 0.2,
        noGoDepthCost = 2.2,
        noGoFleeShare = 0.3,
        noGoFleeWeight = 0.8,
        noGoEndCost = 45,
        noGoEndSlamShare = 0.33,
        noGoEndSpike = true,
        finishBobKnownReach = true,
        finishBobReachIn = 6,
        finishStandMin = 30,
        bobStandMin = 30,
        autoSell = false,
        sellInterval = 60,
        sellAfterGames = 10,
        bestGearAuto = false,
        bestGearPriority = "Damage",
        bestGearSpells = true,
        bestGearSkills = true,
        bestGearOutOfRun = true,
        autoCandy = false,
        sellKeepLevel = 186,
        sellLobbyOnly = true,
        sellListMax = 40,
        sellCommon = true,
        sellUncommon = true,
        sellRare = true,
        sellEpic = true,
        sellLegendary = false,
        sellUltimate = false,
        sellKeep = {},
        finishBobArc = true,
        finishArcNear = 1,
        finishArcSoft = 10,
        closestOutMult = 4,
        spreadOutMult = 10,
        bigSpikeOutMult = 24,
        hbeamOutMult = 14,
        mobAttackNeedsBuff = true,
        groupFaceTol = 12,
        groupTurnMax = 0.5,
        groupShiftMax = 36,
        groupShiftGain = 1,
        groupShiftFor = 2,
        groupShiftTime = 1.6,
        ringPull = true,
        ringPullBand = 10,
        coverageGrid = true,
        coverageGridStep = 6,
        groupMeleePenalty = 15,
        meleeCastHold = 22,
        meleeCastClosing = 36,
        meleeHoldMax = 1.5,
        meleeStrikeAt = 18,
        finishBobOnly = true,
        finishAtOdin = true,
        probePath = true,
        probeStep = 8,
        probeSteps = 28,
        navHold = 2.5,
        wallSlide = true,
        wallSlideProbe = 4.5,
        attackSkillCdMin = 2,
        ringHazardFrom = 0.7,
        ringCellFlashOnly = true,
        mageKeepOut = 21,
        mageKeepOutWeight = 0.6,
        terrainSweep = 2,
        wallsWaitFor = 180,
        wallLogo = true,
        classProfile = "mage",
        slamTellRun = false,
        slamTellFor = 2.2,
        strikeWaitReady = true,
        strikeWaitOut = 20,
        groupArriveReady = true,
        groupArriveSlack = 0.4,
        groupHoldOut = 12,
        mageRowSlabs = 7,
        resetNearAny = 90,
        lineFiredLog = true,
        wallColor = "2f0e0e",
        noLogos = false,
        resetBelowY = -40,
        resetBelowSettle = 3,
        finishOrbHold = 34,
        buffTickDmg = true,
        finishCountTick = true,
        finishThroughOrb = false,
        finishOrbCast = 14,
        finishDodgeNear = 0.35,
        linesPhaseFor = 2,
        lineFiredAt = 0.85,
        odinCloseOnCast = true,
        orbBlastOnContact = true,
        fieldStickFor = 1,
        fieldStickBonus = 22,
        lineFiredMin = 0.3,
        orbLaneLook = 2.1,
        orbLaneWidth = 22,
        orbLaneCost = 75,
        arrayLanePending = false,
        visuals = false,
        fpsUncap = true,
        renderOff = false,
        slamTellWithin = 95,
        slamTellOut = 104,
        slamTellCooldown = 6,
        meleeEscapeClosing = 4,
        coverageAim = true,
        beamUrgentFor = 0.6,
        logoAnim = true,
        logoAnimSpeed = 0.35,
        logoAnimWidth = 1.4,
        logoAnimStep = 0.05,
        logoDark = "6E0000",
        logoRed = "D50000",
        resetGhostAfter = 20,
        ghostGiveUp = 8,
        missileCellBodyOnly = true,
        missileCellLanes = false,
        missileLaneWeight = 0.5,
        missileCellMargin = 4,
        mageStrafe = true,
        mageStrafeRange = 70,
        mageExit = true,
        mageExitDist = 12,
        mageHoldMeleeAt = 28,
        mageHoldMeleeClosing = 45,
        ledgeGuard = true,
        ledgeDrop = 7,
        buffFreezesWalkSpeed = true,
        buffSpeed = 28,
        pathSkillNodes = 10,
        homeBurstFor = 1.5,
        meleeCastAt = 22,
        meleeBreakAfter = 1.2,
        meleeBreakAt = 20,
        orbBurstAt = 25,
        homeAbortAt = 28,
        finalWpSkillRelease = true,
        gapLock = true,
        gapCrossCost = 60,
        volleyNoBack = true,
        boostLethalFree = true,
        volleyBackCos = 0.5,
        meleeBreakFor = 1,
        respawnJitterFor = 0.5,
        odinLedgeIn = 8,
        beamDance = true,
        beamDanceRange = 45,
        beamDanceLm = 1.5,
        beamLaneHold = 1.6,
        beamDancePark = 1.5,
        beamDanceFor = 5,
        beamDanceAfter = 1.6,
        beamGapWalk = true,
        beamGapStep = 6,
        beamGapMax = 90,
        finishMaxPct = 25,
        orbAttackGapFinish = 25,
        orbAttackKeepFinish = 12,
        castDmgOthers = 150,
        orbFinishFlee = 18,
        waypointFlow = true,
        waypointFirstOnly = true,
        resetLeaveFar = 40,
        ringOrbSlack = 8,
        sceneryBudget = 25,
        sceneryEvery = 0.15,
        fieldCommit = 0.8,
        reflexLaneCost = 60,
        wallsV2 = true,
        lethalForceBurst = true,
        wsDownHold = 0.6,
        orbCastMin = 24,
        slamReflexOwns = true,
        considerBudget = 120,
        pathMinGap = 0.6,
        meleeBurstAt = 20,
        streamBurstN = 300,
        streamBurstFor = 0.6,
        streamUrgentMax = 40,
        streamPathHold = 0.6,
        spikeGrowLive = 2,
        wallStep = true,
        wallStepAhead = 45,
        wallStepBehind = 8,
        wallStepPastEnd = 6,
        detourEvery = 0.3,
        castHoldAfterCriss = 3,
        orbAttack = true,
        orbAttackGap = 34,
        orbAttackDetour = 40,
        orbAttackKeep = 12,
        attackNeedsBuffUp = true,
        buffHolderCheck = true,
        buffHolderGrace = 0.6,
        groupLeadT = 2.5,
        groupStrafeT = 0.9,
        groupStrafeStep = 6,
        mageAxisBanDeg = 35,
        bunchN = 3,
        bunchNear = 30,
        finishCyclesBob = 2,
        finishSwingBob = true,
        castRootTime = 0.7,
        castFaceLock = true,
        castFaceLead = 0.08,
        castFaceHold = 0.45,
        castFaceTol = 1.5,
        closeLead = 1.2,
        slamAwayLean = 35,
        webhook = true,
        webhookUrl = "",
        webhookUser = "Harvard Labs",
        whStarted = true,
        whLootWait = 3,
        whWins = true,
        whRodin = true,
        whRatio = true,
        whDeaths = true,
        whItems = true,
        whGodpot = true,
        whTime = true,
        whDungeon = true,
        whGold = true,
        whWorth = true,
        whInv = true,
        whLevel = true,
        whLate = true,
        whLateAfter = 30,
        whGatherFor = 3,
        whVerdictAfter = 20,
        whPingId = "",
        whPingMin = "off",
        whPingValT3 = true,
        whBagCap = 0,
        groupBrain = true,
        groupFullCover = true,
        groupArriveWithin = 5,
        groupFreshWeight = 2,
        groupRangedWeight = 3,
        groupMinFire = 1,
        groupLocalRadius = 90,
        groupFireOnMelee = 1.2,
        groupFireAnyway = 1,
        groupMeleePenaltyFirst = 2,
        groupDistWeightFirst = 0.08,
        groupRangedScore = 18,
        groupFreshScore = 25,
        groupDriftMax = 14,
        groupShiftMaxFull = 45,
        groupShiftMaxOpen = 70,
        groupShiftTimeOpen = 6,
        groupShiftTimeFull = 6,
        groupShiftForFull = 4,
        groupFullStep = 8,
        groupFullReach = 90,
        groupFullBudget = 240,
        groupExactCover = true,
        groupExactPairs = 700,
        aoeMarker = true,
        groupTurnAt = 0.45,
        groupMeleeKeep = 30,
        groupWalk = 16,
        groupMinGain = 1,
        groupChaserSpeed = 18,
        pocketTrap = true,
        finishRush = true,
        castDmgWindow = 1.6,
        finishFactor = 1,
        finishRushSpeed = 28,
        attackSkillMinCd = 1.4,
        drawSweepPerTick = 12,
        spearStrafe = true,
        spearStrafeRange = 85,
        homeBurst = 26,
        meleeRingWarmInVolley = true,
        meleeRingVolleyWeight = 0.5,
        volleyLiveFor = 1.5,
        slamNoBack = true,
        slamBackCos = 0.2,
        noGoPushMax = 48,
        noGoPushStep = 8,
        noGoLeaveNow = true,
        noGoLeaveClear = 1.5,
        noGoLeaveHold = 0.35,
        crissPad = 0,
        crissAimWindow = 1.4,
        strafeArenaFrom = 400,
        strafeAnchorHold = 1,
        useWaypoints = true,
        bubbleRestale = 0.35,
        groupAnchorWeight = 0.8,
        groupAnchorCap = 8,
        groupSurroundCost = 18,
        groupSurroundMin = 3,
        enemyWalls = true,
        enemyWallRays = 10,
        enemyWallShare = 0.5,
        orbStepIn = true,
        orbStepInSlack = 6,
        orbStepInMargin = 1.2,
        orbSpeed = 17,
        tagFirst = true,
        tagStuckBreak = false,
        tagStuckFor = 8,
        tagStuckMove = 3,
        tagRoomRadius = 150,
        pitRoomRadius = 300,
        pitGroups = true,
        tagPendFor = 2,
        tagCastOnly = true,
        tagHoldMax = 6,
        tagOverOrder = true,
        tagCharger = true,
        tagMark = true,
        tagBonus = 500,
        tagThreatRange = 12,
        tagSwingSlack = 2,
        attackThread = true,
        attackDeadline = 0.5,
        fireOnFullCover = true,
        aoeTrueShape = true,
        firstHitWhole = true,
        firstHitWindow = 1,
        attackStep = 0.05,
        aimStepDeg = 8,
        aoeScanEvery = 0.1,
        drawAoeScan = false,
        aoeScanDrawStep = 15,
        aoeScanLift = 2.4,
        bossBackOff = false,
        respawnRush = 4.5,
        waypointHold = 14,
        waypointLean = 25,
        respawnRushMax = 14,
        respawnRushSpeed = 18,
        respawnInvuln = 4,
        respawnExitBudget = 1.5,
        respawnRushBurst = 28,
        fieldCutSlack = 0.35,
        fieldCloseMinHold = 0.4,
        seekingPad = 6,
        seekStepFrom = 0.85,
        seekStepTo = 1.4,
        seekStepRange = 130,
        seekStepLen = 26,
        seekFollow = 1.2,
        seekExitAt = 20,
        slamRecheck = 0.15,
        retrackMinAge = 1.2,
        orbHoldYield = 24,
        wallStandHalf = 12,
        blinkRunFor = 1.5,
        odinAxisLean = 40,
        orbClear = 40,
        orbCommitAt = 26,
        orbPeelAt = 24,
        orbPeelNear = 12,
        orbBubble = 34,
        orbShieldBonus = 12,
        orbShieldR = 10,
        orbLeadBehind = 10,
        orbLeadMiddle = 0,
        orbStandAt = 0.75,
        orbRay = true,
        orbRayHoldLat = 9,
        orbStepIn = false,
        orbApproachR = 30,
        orbCatchAt = 14,
        orbHandoff = 5,
        orbLockAt = 70,
        orbDetourHold = 0.8,
        orbDetourClear = 0.35,
        orbAheadTime = 0.6,
        orbAheadMax = 24,
        orbAheadKeep = 10,
        orbNoDetour = 18,
        orbSwerve = 12,
        orbSwerveClear = 6,
        orbGoalCost = 2.5,
        orbGoalCap = 120,
        orbCloseCost = 3,
        orbReachSlack = 6,
        spikeFieldHold = 4.5,
        spikeFieldPad = 10,
        bobSpikeNear = 35,
        bobSpikeFwdCost = 6,
        castProbe = 8,
        standoffIn = 4,
        castStagger = true,
        bobSpikeFwdCap = 90,
        noGoBase = 10,
        noGoGrad = 0.9,
        noGoHardAt = 70,
        bobSpikeSide = 30,
        bobSpikeOut = 3,
        sceneryFolders = { Map = true },
        scenerySweep = 2,
        wrongCrystalStep = 18,
        wrongCrystalFor = 1.5,
        wrongCrystalRest = 1,
        bobSpikeLean = 50,
        reachBonus = -20,
        bossDownQuiet = 20,
        arenaSlack = 8,
        arenaEdge = 32,
        arenaEdgeEscape = 8,
        arenaProbe = 45,
        arenaOpenMin = 0.55,
        arenaMinIn = 26,
        orbSprintAt = 45,
        bobHomeSlack = 10,
        attackRange = 12,
        abilityRadius = 74,
        abilityInterval = 0.4,
        autoQ = true,
        autoE = true,
        autoAttack = true,
        clickInterval = 0.25,
        aoeMax = 24,
        softAfter = 4,
        softFactor = 0.3,
        hitLead = 0.28,
        hitTail = 0.22,
        pingMarginMax = 12,
        pingManual = 0,
        dodgeReach = 30,
        dodgeRings = 8,
        dodgeRays = 32,
        dodgeMargin = 0.5,
        dodgeShoulder = 2.3,
        slimShoulder = 1,
        dodgeLead = 1.2,
        dodgeDwell = 1.5,
        dodgeMoveAt = 0.15,
        stepBlockAt = 0.999,
        pathLaneDanger = 0.5,
        laneHorizon = 6,
        dodgeInterval = 0.016666666666666666,
        slimLagShare = 0.2,
        mageMargin = 3,
        mageAlongBonus = 34,
        mageLeaveFrom = 3,
        mageLeaveClear = 10,
        mageLeaveMax = 45,
        mageGapBeat = 12,
        mageGapClear = 1.8,
        missilePocketClear = 4,
        mageCleanFar = 0.5,
        mageCleanExtra = 4,
        mageBurstMax = 28,
        mobCleanExtra = 6,
        retrackEvery = 0.05,
        retrackTurn = 0.99,
        retrackNeedsTelegraph = true,
        spikeHurtFor = 2.5,
        meleeBackOff = 1,
        meleeBandWeight = 0.12,
        doomMargin = 0.2,
        orbCastHold = 18,
        reflexOpenWeight = 0.15,
        reflexPathWeight = 40,
        reachBonusMob = 0,
        reachBonusBoss = -14,
        heightSplit = 6,
        defaultFire = 1.5,
        defaultLive = 0.6,
        velSmooth = 0.45,
        fadeLinger = 0.55,
        projectileLookahead = 1.8,
        spentTransparency = 0.97,
        safeLead = 2.5,
        safeInset = 6,
        aimWindow = 0.5,
        aimReach = 140,
        aimLead = 0.6,
        orbLeadTime = 0.4,
        orbLeadPad = 4,
        learnedHits = {
            firstbossjumpslam = { max = 2.383862, med = 1.903996, min = 1.700513, n = 297 },
            firstbosspassivebeam = { max = 0.932707, med = 0.916811, min = 0.899119, n = 29046 },
            northernmageshot = { max = 0.967941, med = 0.966229, min = 0.949702, n = 45783 },
            northernwarriorlinestrike = { max = 0.650729, med = 0.632641, min = 0.549769, n = 1223 },
            secondbosscrossbeam = { max = 3.4, med = 3, min = 2.6, n = 6 },
            secondbosshorizontalbeam = { max = 1.067306, med = 1.066248, min = 1.064962, n = 7907 },
            secondbossspreadbeam = { max = 1.164996, med = 1.06567, min = 0.914896, n = 7578 },
            spearmanstrikehitbox = { max = 0.833488, med = 0.799809, min = 0.732747, n = 5085 },
            thirdbosslineshot = { max = 0.898927, med = 0.866939, min = 0.84779, n = 161 },
        },
        earlyHits = { thirdbosslineshot = 0.181132 },
        missHits = { firstbossjumpslam = 8, secondbosscriclehitbox = 5.78923, thirdbosslineshot = 3.887672 },
        missHitMax = 8,
        castHold = 0.9,
        streamer = true,
        streamerName = true,
        streamerHealth = true,
        streamerBody = true,
        streamerOthers = false,
        streamerLeaderboard = false,
        streamerChat = true,
        streamerLevel = true,
        streamerWealth = true,
        streamerNameText = "harvard student",
        streamerHealthText = "999,999",
        streamerLevelText = "999",
        streamerGoldText = "999,999",
        streamerGemsText = "999,999",
        streamerXpText = "999,999,999",
    }
    config.streamerBodyColor = Color3.fromHex("5bff9c")
    config.markerScale = 1
    config.drawAoe = true
    config.drawMaxBoxes = 110
    config.drawNearestFirst = true
    config.bobKeepOutFinishWeight = 0.35
    config.warriorHoldAt = 30
    config.warriorOnUsAt = 22
    config.drawHazards = true
    config.drawTarget = true
    config.drawPath = true
    config.drawSpots = true
    config.drawAbility = true
    config.labelHazards = false
    config.labelUnknown = false
    config.showHitboxes = false
    config.hazardTransparency = 0.6
    config.colorFloor = Color3.fromHex("#3cdc78")
    config.colorSoon = Color3.fromHex("#ffdc28")
    config.colorLive = Color3.fromHex("#ff3232")
    config.colorTarget = Color3.fromRGB(255, 255, 255)
    config.colorAbility = Color3.fromRGB(80, 200, 255)
    config.autoQueue = false
    config.autoQueueMap = "Northern Lands"
    config.autoQueueDifficulty = "Nightmare"
    config.autoQueueHardcore = false
    config.autoQueuePrivate = false
    config.autoQueueMinLevel = 0
    config.autoQueueDelay = 8
    config.autoQueueRetry = 25
    config.autoQueueStartDelay = 2
    config.autoQueueReplay = false
    config.autoQueueReplayDelay = 2
    config.autoFarmByPlace = true
    config.autoStartDungeon = false
    config.autoStartDelay = 2
    config.autoStartWalkMax = 60
    config.startTimed = true
    config.startCountdown = 5
    config.preWalkSprint = true
    config.bonusBoss = false
    config.bonusVoteDelay = 2
    config.menuKey = "RightShift"
    config.tickHz = 30
    config.debugPrints = false
    config.autosaveInterval = 10
    config.startCountdown = 5
    config.modDetect = true
    config.modWhitelist = {}
    config.modWaitMin = 10
    config.modWaitMax = 30
    config.whModDetect = true
    config.modKick = true
    config.minimap = true
    config.minimapX = -1
    config.minimapY = -1
    config.minimapSmooth = true
    config.mapAttackOneColor = false
    config.mapAttackColor = Color3.fromRGB(255, 60, 60)
    config.mapAttackRainbow = false
    config.mapViewOpen = false
    config.map3DView = "TOP"
    config.map3DZoom = 1
    config.map3DSwitch = 4
    config.map3DFreePitch = 55
    config.map3DFreeYaw = 0
    config.mapZoomS = 1
    config.mapZoomB = 1
    config.mapBgOpacity = 55
    config.mapFollow = true
    config.mapAnchors = {}
    config.mapKey = "M"
    config.mapBlankScreen = false
    config.mapBg3D = true
    config.mapHealthBars = true
    config.mapNames = true
    config.mapStatsHidden = false
    config.colorTheme = "Crimson"
    config.mapButton = true
    config.whHideName = false
    config.whImages = true
    config.whBest = true
    config.whAccent = true
    config.itemStatsAbbrev = true
    config.upgradeCountAbbrev = true
    config.itemGodpot = true
    config.birdsEyeCam = false
    config.speedCustom = false
    config.speedNormal = 20
    config.speedBurst = 28
    local timing, timingBelow, sharedValue3, sharedValue4 =
        {
            northernmageshot = { first = 0, last = 1.05, exact = true, pad = 2.5, hardFirst = true },
            thirdbosslineshot = { first = 0.6, last = 1, exact = true },
            bonusbosssmallspiralflame = { first = 0, last = 1.15, exact = true, pad = 1 },
            bonusbosslongline = { first = 0.5, last = 5, exact = true, hardFirst = true, long = true },
            bonusbossgroundflame = { first = 0, last = 18.3, exact = true, hardFirst = true, long = true, pad = 2 },
            spearmanstrikehitbox = { pad = 3, first = 0, last = 1.5, hardFirst = true },
            northernwarriorlinestrike = { pad = 8, first = 0, last = 1.5, hardFirst = true },
            northernwarriorcirclestrike = { pad = 8, first = 0, last = 1.5, hardFirst = true },
            firstbosspassivebeam = { first = 0.35, last = 1.35, exact = true, pad = 0, padExact = true },
            firstbossjumpslam = { first = 0, last = 2.4, pad = 0, padExact = true, exact = true, hardFirst = true },
            secondbosscriclehitbox = {
                first = 0,
                long = true,
                last = 12,
                pad = 0,
                padExact = true,
                hardFirst = true,
                precastBox = true,
            },
            largeicespikes = { first = 0, last = 1.6, hardFirst = true },
            mediumicespikes = { first = 0, last = 1.6, hardFirst = true },
            smallicespikes = { first = 0, last = 1.6, hardFirst = true },
            secondbossspinninglaser = { first = 0, last = 1.2, pad = 4, exact = true, hardFirst = true },
            secondbosscrossbeam = { first = 0, last = 1.2, pad = 4, exact = true, hardFirst = true },
            secondbosshorizontalbeam = { first = 0.7, last = 8, pad = 1, slim = 2, exact = true, sweeps = true, linger = true },
            secondbossspreadbeam = { first = 0, last = 1.3, pad = 3, exact = true, hardFirst = true },
            cubepylonshot = { first = 0.8, last = 1.1 },
            silkblast = { first = 3.2, last = 5.8, hardFirst = true, holdLive = true },
            npcmagespikes = { first = 0.8, last = 2.6, hardFirst = true, holdLive = true },
            dracanimageattack = { first = 0, last = 6, hardFirst = true, gs = true, pad = 1 },
            archpriestwavecircles = { first = 0, last = 6, gs = true },
            craggcursedflame = { first = 0, last = 6, gs = true },
            craggpinkline = { first = 0, last = 6, gs = true },
            craggredline = { first = 0, last = 6, gs = true },
            craggxline = { first = 0, last = 6, gs = true },
            craggnightmaregroundslam = { first = 0, last = 8, gs = true },
            craggnightmarelines = { first = 0, last = 8, gs = true },
            vyteluslaserbeam = { first = 0, last = 2.2, gs = true },
            vytelusflamewall = { first = 0, last = 8, sweeps = true, gs = true },
            vyteluspinkcirclemarkers = { first = 0, last = 8, gs = true },
            thirdbossflamewallhitbox = { first = 0, last = 8, sweeps = true, gs = true },
            thirdbossfireballhitbox = { first = 0, last = 2.4, hardFirst = true, gs = true, pad = 3 },
            thirdbossfireballhorizontalhit = { first = 0, last = 2.4, hardFirst = true, gs = true, pad = 2 },
            archpriestsafezones = { first = 2.1, last = 3, goNow = true, gs = true },
            vytelusmemorysafezone = { first = 2, last = 20, goNow = true, gs = true },
        }, {
            thirdbossdualswingline = { first = 0.9, last = 1.8, hardFirst = true, pad = 7, holdLive = true },
            thirdbossspreadline = { first = 1.1, last = 2, hardFirst = true, pad = 3, holdLive = true },
            model = { first = 0.3, last = 1.7, hardFirst = true, holdLive = true },
            cubepylonshot = { first = 0.5, last = 1.4, hardFirst = true, holdLive = true, pad = 3, padExact = true },
            lastbosspylonshot = { first = 0.8, last = 1.7, hardFirst = true, holdLive = true },
            pyramidpylonspreadshot = { first = 0.6, last = 1.5, hardFirst = true, holdLive = true },
            thirdbosscrossshot = { first = 0, last = 1.6, holdLive = true, pad = 1.5, padExact = true },
            thirdbossxshot = { first = 0, last = 1.6, holdLive = true, pad = 4, padExact = true },
            mushroomwizardshot = { first = 0, last = 1.5, holdLive = true, pad = 4 },
            secondbosscheckeredline = { first = 0.7, last = 1.5, hardFirst = true, holdLive = true },
            poisoncircle = { first = 0, last = 7.6, holdLive = true },
            spearmanhitbox = { first = 0, last = 1, holdLive = true, pad = 3 },
            secondbossdirectshot = { first = 0, last = 1.5, holdLive = true, pad = 3, padExact = true },
        }, {
            ["midgardian champion"] = { arenaPull = true, fan = true, spread = true },
            odin = { arenaPull = true, ringBand = true, bigBody = true, bigReach = 0 },
            ["bob the frost giant"] = { orbs = true, home = true, bigBody = true, spread = true },
        }, {}
    local function bossProfile(argument)
        return sharedValue3[string.lower(argument or "")] or sharedValue4
    end
    local sharedValue5 = {}
    sharedValue5.red = Vector3.new(-144, 23, 268)
    sharedValue5.green = Vector3.new(-159, 23, 335)
    sharedValue5.yellow = Vector3.new(-105, 23, 377)
    local sharedValue6 = {}
    local function bobCrystal(argument)
        argument = string.lower(argument or "")
        local pos = sharedValue6[argument]
        if pos then
            if os.clock() - pos.at < 5 then
                return pos.pos
            end
        end
        pos = nil
        local secondBossCrystals = sharedValue2:FindFirstChild("secondBossCrystals", true)
        if secondBossCrystals then
            for index, descendant in ipairs(secondBossCrystals:GetDescendants()) do
                if descendant:IsA("BasePart") and string.lower(descendant.Name):find(argument, 1, true) then
                    pos = descendant.Position
                    break
                end
            end
        end
        pos = pos or sharedValue5[argument]
        sharedValue6[argument] = { at = os.clock(), pos = pos }
        return pos
    end
    local function bobCrystalCentroid()
        local value, value2 = Vector3.zero, 0
        for entry in pairs(sharedValue5) do
            local value3 = bobCrystal(entry)
            if value3 then
                value, value2 = value + value3, value2 + 1
            end
        end
        return value2 > 0 and value / value2 or nil
    end
    local runtimeState =
        { farmEnabled = true, destroyed = false, movementState = "starting", tickMs = 0, moveBoost = false }
    runtimeState.lastQ = -math.huge
    runtimeState.lastE = -math.huge
    runtimeState.lastClick = -math.huge
    local function log(argument, argument2)
        if runtimeState.bugLog then
            pcall(runtimeState.bugLog, argument, argument2)
        end
        if config.debugPrints then
            print(("[DQ %s][%s] %s"):format("v3.0 c84b", argument, argument2))
        end
    end
    local sharedValue7 = {}
    local function logT(argument, argument2, argument3, argument4)
        local now = os.clock()
        if (sharedValue7[argument] or -math.huge) + argument2 > now then
            return
        end
        sharedValue7[argument] = now
        log(argument3, argument4)
    end
    local function setState(argument)
        argument = if runtimeState.touchdownOn
            then if type(argument) == "string"
                then if argument:sub(1, 12) == "RODIN SWEEP:"
                    then "RODIN SWEEP [TOUCHDOWN MODE]:" .. argument:sub(13)
                    else argument
                else argument
            else argument
        argument = if runtimeState.spikeWayAt
            then if type(argument) == "string"
                then if os.clock() - runtimeState.spikeWayAt < 0.3
                    then if runtimeState.spikeWayWhy
                        then argument .. " [spikes: " .. tostring(runtimeState.spikeWayWhy) .. "]"
                        else argument
                    else argument
                else argument
            else argument
        runtimeState.movementState = if runtimeState.lagBackUntil
            then if type(argument) == "string"
                then if os.clock() < runtimeState.lagBackUntil
                    then if config.lagBackLimit ~= false
                        then argument .. (" [lag-back %d: game speed %ds]"):format(
                            runtimeState.lagBackN or 1,
                            math.ceil(runtimeState.lagBackUntil - os.clock())
                        )
                        else argument
                    else argument
                else argument
            else argument
    end
    local function character()
        local character2 = localPlayer.Character
        return character2,
            character2 and (character2:FindFirstChildOfClass("Humanoid")),
            character2 and (character2:FindFirstChild("HumanoidRootPart"))
    end
    local function flatDistance(vector, vector2)
        local value, value2 = vector.X - vector2.X, vector.Z - vector2.Z
        return math.sqrt(value * value + value2 * value2)
    end
    local function visualRoot()
        if runtimeState.visualRoot then
            if runtimeState.visualRoot.Parent then
                return runtimeState.visualRoot
            end
        end
        local dungeonAutofarmVisuals = Instance.new("Folder")
        dungeonAutofarmVisuals.Name = "DungeonAutofarmVisuals"
        dungeonAutofarmVisuals.Parent = sharedValue2
        runtimeState.visualRoot = dungeonAutofarmVisuals
        return dungeonAutofarmVisuals
    end
    local function isOurs(argument)
        if runtimeState.visualRoot ~= nil then
            local visualRoot2 = runtimeState.visualRoot
            if argument:IsDescendantOf(visualRoot2) then
                return true
            end
        end
        if game.PlaceId == 101088859550383 or HLGS == true then
            local spellProjectile = sharedValue2:FindFirstChild("SpellProjectile")
            return spellProjectile ~= nil and argument:IsDescendantOf(spellProjectile)
        end
        return false
    end
    local function raycastParams(argument)
        if not argument then
            if config.perfMemo ~= false then
                local character2, visualRoot2, rcParams =
                    localPlayer.Character, runtimeState.visualRoot, runtimeState.rcParams
                if rcParams then
                    if rcParams.c == character2 then
                        if rcParams.v == visualRoot2 then
                            return rcParams.p
                        end
                    end
                end
            end
        end
        local raycastParams2 = RaycastParams.new()
        raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
        local filterDescendantsInstances = {}
        if localPlayer.Character then
            filterDescendantsInstances[#filterDescendantsInstances + 1] = localPlayer.Character
        end
        if runtimeState.visualRoot then
            filterDescendantsInstances[#filterDescendantsInstances + 1] = runtimeState.visualRoot
        end
        if argument then
            filterDescendantsInstances[#filterDescendantsInstances + 1] = argument
        end
        raycastParams2.FilterDescendantsInstances = filterDescendantsInstances
        raycastParams2.IgnoreWater = true
        pcall(function()
            raycastParams2.RespectCanCollide = true
        end)
        if not argument then
            runtimeState.rcParams =
                { c = localPlayer.Character, v = runtimeState.visualRoot, p = raycastParams2 }
        end
        return raycastParams2
    end
    local function floorY(argument, argument2, argument3, argument4)
        local raycastResult = sharedValue2:Raycast(
            Vector3.new(argument, argument2 + 6, argument3),
            Vector3.new(0, -46, 0),
            argument4
        )
        return raycastResult and raycastResult.Position.Y or nil
    end
    local paths = {
        root = "HarvardLabs",
        configs = "HarvardLabs/configs",
        images = "HarvardLabs/images",
        data = "HarvardLabs/data",
        logs = "HarvardLabs/logs",
    }
    local function ensureFolders()
        if type(makefolder) ~= "function" then
            return false
        end
        local value = { "root", "configs", "images", "data", "logs" }
        for index, entry in ipairs(value) do
            index = paths[entry]
            local success2, value2 = pcall(isfolder, index)
            if success2 then
                if not value2 then
                    pcall(makefolder, index)
                end
            else
                pcall(makefolder, index)
            end
        end
        return true
    end
    pcall(ensureFolders)
    local function pickFile(...)
        if type(isfile) ~= "function" then
            return ...
        end
        for index = 1, select("#", ...), 1 do
            local value = select(index, ...)
            if value then
                local success2, value2 = pcall(isfile, value)
                if success2 then
                    if value2 then
                        return value
                    end
                end
            end
        end
        return nil
    end
    local function readJson(...)
        local value = pickFile(...)
        if not value then
            return nil
        end
        local success2, value2 = pcall(function()
            local value3 = argumentHelpers[108](readfile(value))
            return httpService:JSONDecode(argumentHelpers:unpackValues(value3))
        end)
        if success2 then
            if type(value2) == "table" then
                return value2
            end
        end
        return nil
    end
    local sharedValue8
    local sharedValue9 = false
    local function customLogo()
        if sharedValue9 then
            local value = sharedValue8
            return value
        end
        sharedValue9 = true
        if type(getcustomasset) ~= "function" then
            return nil
        elseif type(isfile) ~= "function" then
            return nil
        end
        local value2 = {
            paths.images .. "/logo.png",
            paths.images .. "/logo.jpg",
            paths.images .. "/logo.jpeg",
            paths.images .. "/logo.webp",
        }
        if type(listfiles) == "function" then
            local success2, value3 = pcall(listfiles, paths.images)
            if success2 and type(value3) == "table" then
                for index, entry in ipairs(value3) do
                    index = string.lower(tostring(entry))
                    if index:sub(-4) == ".png" then
                        value2[#value2 + 1] = entry
                    elseif index:sub(-4) == ".jpg" then
                        value2[#value2 + 1] = entry
                    elseif index:sub(-5) == ".jpeg" then
                        value2[#value2 + 1] = entry
                    elseif index:sub(-5) == ".webp" then
                        value2[#value2 + 1] = entry
                    end
                end
            end
        end
        for index2, entry2 in ipairs(value2) do
            local success3, value4 = pcall(isfile, entry2)
            if success3 then
                if value4 then
                    local success4, value5 = pcall(getcustomasset, entry2)
                    if success4 then
                        if value5 then
                            sharedValue8 = value5
                            index2 = sharedValue8
                            return index2
                        end
                    end
                end
            end
        end
        return nil
    end
    context.PATH = paths
    context.ensureFolders = ensureFolders
    context.pickFile = pickFile
    context.readJson = readJson
    context.customLogo = customLogo
    context.BAKED_WAYPOINTS = {
        {
            group = { -635.7332, 23.7726, 362.8112 },
            home = { -587.4822, 24.8619, 323.1807, -0.82, 0.5724 },
            points = {
                { -751.6782, 22.0165, 285.2727 },
                { -747.4424, 18.9328, 316.0331 },
                { -574.3287, 23.4834, 315.9835 },
            },
            radius = 0.1445,
        },
        {
            group = { -387.7572, 30.4365, 414.1927 },
            home = { -449.9585, 28.3004, 385.9366, 0.9142, 0.4052 },
            points = { { -528.1688, 18.0724, 406.2931 } },
            radius = 2.6201,
        },
        {
            group = { -304.7831, 28.8316, 387.3162 },
            home = { -361.6295, 24.0978, 387.0999, 0.9825, 0.1862 },
            points = { { -415.1133, 24.3085, 395.7014 } },
            radius = 2.2358,
        },
        {
            group = { 80.8132, 23.6123, 200.3593 },
            home = { 25.4795, 18.0687, 190.3941, 0.9637, 0.2669 },
            points = { { -59.407, 18.2168, 241.5568 }, { -35.5636, 18.0469, 155.336 } },
            radius = 6.7782,
        },
        {
            group = { 108.509, 22.3733, 271.6918 },
            home = { 82.7254, 18.0687, 212.2924, 0.3751, 0.927 },
            points = { { 48.148, 18.0687, 204.8653 }, { 58.8611, 18.0687, 225.1028 } },
            radius = 9.1618,
        },
        {
            group = { 233.6151, 23.0974, 226.9834 },
            home = { 164.5145, 18.2168, 219.9937, 0.9995, -0.0314 },
            points = { { 121.6417, 18.2168, 218.5869 } },
            radius = 26.3039,
        },
        {
            group = { 438.0957, -56.7191, 65.6118 },
            home = { 394.0497, -61.4505, 120.4787, 0.6423, -0.7665 },
            points = { { 351.5543, -61.3188, 183.6651 }, { 382.7307, -61.4505, 152.4293 } },
            radius = 0.5466,
        },
        {
            group = { 503.5679, -56.5583, 152.6113 },
            home = { 434.1258, -61.4505, 135.5233, 1, 0.0037 },
            points = { { 403.683, -61.0129, 113.3184 } },
        },
        {
            group = { 485.2402, -56.9707, 215.9171 },
            home = { 432.1574, -61.4505, 178.7617, 0.8292, 0.559 },
            points = { { 412.4349, -61.4505, 145.047 }, { 410.2287, -61.2643, 159.5025 } },
            radius = 0.7998,
        },
        {
            group = { 566.9124, -56.2301, 128.2093 },
            home = { 488.5639, -61.228, 139.4883, 0.9932, -0.1161 },
            points = { { 438.189, -61.228, 139.3943 } },
        },
        {
            group = { 715.1812, 18.7103, 67.2958 },
            home = { 642.9678, 14.4015, 86.2841, 0.9479, -0.3185 },
            points = { { 606.8215, 14.7393, 96.192 } },
        },
        {
            group = { 780.2642, 19.6209, 33.3968 },
            home = { 704.0314, 19.5244, 17.0047, 0.9783, 0.2071 },
            points = { { 640.9563, 19.5126, 15.9233 } },
            radius = 0,
        },
    }
    local sharedValue10, sharedValue11 = paths.configs .. "/release.json", 0
    pcall(function()
        sharedValue11 = tonumber(localPlayer and localPlayer.UserId) or 0
    end)
    local sharedValue12 = paths.configs
        .. "/release_"
        .. (sharedValue11 > 0 and tostring(sharedValue11) or "unknown")
        .. ".json"
    local sharedValue13 = paths.configs .. "/config_v2.json"
    local sharedValue14, sharedValue15, persist =
        paths.configs .. "/settings.json", "HarvardLabs_release.json", {
            "classProfile",
            "classAuto",
            "menuKey",
            "notifications",
            "colorThemeBase",
            "webhook",
            "webhookUrl",
            "webhookUser",
            "whStarted",
            "whHideName",
            "whWins",
            "whRodin",
            "whRatio",
            "whDeaths",
            "whItems",
            "whGodpot",
            "whTime",
            "whDungeon",
            "whGold",
            "whWorth",
            "whInv",
            "whLevel",
            "whLate",
            "whPingId",
            "whPingMin",
            "whPingValT3",
            "whImages",
            "whBest",
            "whAccent",
            "statsEnabled",
            "statsKey",
            "autoSell",
            "sellInterval",
            "sellAfterGames",
            "bestGearAuto",
            "bestGearPriority",
            "bestGearSpells",
            "bestGearSkills",
            "bestGearOutOfRun",
            "autoCandy",
            "sellKeepLevel",
            "sellLobbyOnly",
            "sellCommon",
            "sellUncommon",
            "sellRare",
            "sellEpic",
            "sellLegendary",
            "sellUltimate",
            "sellKeep",
            "autoQueue",
            "autoQueueMap",
            "autoQueueDifficulty",
            "autoQueueHardcore",
            "autoQueuePrivate",
            "autoQueueReplay",
            "autoQueueDelay",
            "autoStartDungeon",
            "bonusBoss",
            "streamer",
            "streamerName",
            "streamerNameText",
            "streamerHealth",
            "streamerHealthText",
            "streamerLevel",
            "streamerLevelText",
            "streamerGoldText",
            "streamerGemsText",
            "streamerXpText",
            "streamerBody",
            "streamerBodyColor",
            "streamerOthers",
            "streamerLeaderboard",
            "streamerChat",
            "streamerWealth",
            "autoAttack",
            "autoE",
            "autoQ",
            "autoStandoff",
            "castSafe",
            "colorFloor",
            "colorLive",
            "colorSoon",
            "debugPrints",
            "drawAbility",
            "drawAoe",
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
            "gatherMobs",
            "hazardTransparency",
            "labelHazards",
            "labelUnknown",
            "markerScale",
            "devTitles",
            "devAoeScan",
            "policyVersion",
            "showHitboxes",
            "strafe",
            "targetPriority",
            "wallClearView",
            "wallsOn",
            "wallTransparency",
            "wallsV2",
            "watchToFile",
            "visuals",
            "drawAoeScan",
            "pingManual",
            "fpsUncap",
            "renderOff",
            "mode1186",
            "role1186",
            "pulseRadius",
            "pulseLead",
            "altFollow",
            "carryName",
            "carryKeepMoving",
            "abilityRadius",
            "abilityRangeKnown",
            "aimReach",
            "aimWindow",
            "aoeDistance",
            "aoeRadius",
            "arenaEdge",
            "arenaMinIn",
            "arenaOpenMin",
            "arenaProbe",
            "arenaSlack",
            "attackRange",
            "bobKeepOutRadius",
            "bossStandoff",
            "bounceWeight",
            "bubbleAlongBonus",
            "bubbleArrive",
            "bubbleBreachFloor",
            "bubbleCommit",
            "bubbleCornerBoost",
            "bubbleDetourLeg",
            "bubbleDetourStick",
            "bubbleDetourStuck",
            "bubbleFlipPenalty",
            "bubbleHardAt",
            "bubbleLead",
            "bubbleLookahead",
            "bubbleMaxOut",
            "bubbleMinWeight",
            "bubbleNearWeight",
            "bubbleNoFlip",
            "bubbleOpenWeight",
            "bubbleProbe",
            "bubbleRadius",
            "bubbleRays",
            "bubbleSettle",
            "bubbleSoftCost",
            "bubbleStep",
            "bubbleTrajCost",
            "bubbleTrajLead",
            "bubbleWallPenalty",
            "bubbleWarnLead",
            "burstMax",
            "champKeepOutRadius",
            "dodgeMargin",
            "dodgeRays",
            "dodgeRings",
            "dodgeShoulder",
            "groupZoneRadius",
            "hbeamOutMult",
            "mageMargin",
            "mobStandoff",
            "orbSprintAt",
            "pingMarginMax",
            "rangeMargin",
            "rangedStandoff",
            "reachBonus",
            "reachBonusBoss",
            "reachBonusMob",
            "ringSlim",
            "safeInset",
            "safeLead",
            "slamNearWeight",
            "spikeAheadStuds",
            "tweenWalk",
            "warriorKeepOut",
            "itemStatsAbbrev",
            "upgradeCountAbbrev",
            "itemGodpot",
            "speedCustom",
            "speedNormal",
            "speedBurst",
            "modDetect",
            "modWhitelist",
            "modWaitMin",
            "modWaitMax",
            "whModDetect",
            "modKick",
            "modLeaveLegendary",
            "modLeaveUltimate",
            "modLeaveValT3",
            "modLeaveEpic",
            "modLeaveValAny",
            "modStillMax",
            "breakOn",
            "breakFarmMin",
            "breakFarmMax",
            "breakRestMin",
            "breakRestMax",
            "loadoutSwap",
            "minimap",
            "minimapX",
            "minimapY",
            "minimapSmooth",
            "mapAttackOneColor",
            "mapAttackColor",
            "mapAttackRainbow",
            "attackRainbowAuto",
            "attackRainbowTheme",
            "mapViewOpen",
            "map3DView",
            "map3DZoom",
            "map3DSwitch",
            "map3DFreePitch",
            "map3DFreeYaw",
            "mapZoomS",
            "mapZoomB",
            "mapBgOpacity",
            "mapFollow",
            "mapAnchors",
            "mapKey",
            "mapBlankScreen",
            "mapBg3D",
            "mapHealthBars",
            "mapNames",
            "colorTheme",
            "mapButton",
            "mapStatsHidden",
        }
    context.attackColourNow = function()
        if config.mapAttackRainbow == true then
            local value = math.floor(
                sharedValue2:GetServerTimeNow() * (config.attackRainbowSpeed or 0.08) % 1 * 90
            ) / 90
            return Color3.fromHSV(value, config.attackRainbowSat or 0.9, 1)
        end
        if config.mapAttackOneColor == true then
            if typeof(config.mapAttackColor) == "Color3" then
                return config.mapAttackColor
            end
        end
        return nil
    end
    local sharedValue16, sharedValue17 = type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
    local sharedValue18 = -math.huge
    local function snapshot()
        local value = { __version = "v3.0 c84b" }
        for index, entry in ipairs(persist) do
            local value2, value3 = config[entry], context.devSaved and context.devSaved[entry]
            value2 = if value3 then value3.v else value2
            value[entry] = typeof(value2) == "Color3" and "#" .. value2:ToHex() or value2
        end
        return value
    end
    local function helper()
        return "\10"
    end
    local function helper2(argument)
        local value = {}
        for entry in pairs(argument) do
            value[#value + 1] = tostring(entry)
        end
        table.sort(value)
        local value2 = { "{" }
        for index, entry2 in ipairs(value) do
            local value3 = argument[entry2]
            local value4 = if type(value3) == "string"
                then httpService:JSONEncode(value3)
                else if type(value3) == "number"
                    then tostring(value3)
                    else if type(value3) == "boolean"
                        then tostring(value3)
                        else httpService:JSONEncode(value3)
            value2[#value2 + 1] = ("  %s: %s%s"):format(
                httpService:JSONEncode(entry2),
                value4,
                index < #value and "," or ""
            )
        end
        value2[#value2 + 1] = "}"
        return table.concat(value2, helper())
    end
    local function saveConfig()
        if not sharedValue16 then
            return false
        end
        if sharedValue12 == sharedValue10 then
            return false
        end
        if runtimeState.configAsk then
            return false
        end
        local overlay1186, value, value2 = runtimeState.overlay1186, {}, {}
        if overlay1186 then
            for key, entry in pairs(overlay1186) do
                value[#value + 1] = key
                value2[#value] = config[key]
                config[key] = entry.v
            end
        end
        local success2, value3 = pcall(helper2, snapshot())
        if overlay1186 then
            for index, entry2 in ipairs(value) do
                config[entry2] = value2[index]
            end
        end
        if success2 then
            if value3 == sharedValue17 then
                return success2
            end
        else
            return success2
        end
        pcall(ensureFolders)
        if pcall(writefile, sharedValue12, value3) then
            sharedValue17 = value3
            return true
        end
        return false
    end
    local sharedValue19, sharedValue20 =
        {
            mage = {
                __version = "4.0.186",
                abilityRadius = 74,
                abilityRangeKnown = 99,
                aimReach = 140,
                aimWindow = 0.5,
                aoeDistance = 0,
                aoeRadius = 38,
                arenaEdge = 32,
                arenaMinIn = 26,
                arenaOpenMin = 0.55,
                arenaProbe = 45,
                arenaSlack = 8,
                attackRange = 13,
                autoAttack = true,
                autoE = true,
                autoFarmByPlace = true,
                autoQ = true,
                autoQueue = false,
                autoQueueDelay = 8,
                autoQueueDifficulty = "Insane",
                autoQueueHardcore = false,
                autoQueueMap = "Northern Lands",
                autoQueuePrivate = true,
                autoQueueReplay = true,
                autoStandoff = true,
                autoStartDungeon = true,
                blink = false,
                blinkMax = 6,
                blinkMobs = false,
                bobKeepOutRadius = 68,
                bonusBoss = false,
                bossStandoff = 33,
                bounceWeight = 1,
                bubbleAlongBonus = 10,
                bubbleArrive = 1.5,
                bubbleBreachFloor = 3,
                bubbleCommit = 0.9,
                bubbleCornerBoost = 3,
                bubbleDetourLeg = 14,
                bubbleDetourStick = 4,
                bubbleDetourStuck = 3,
                bubbleFlipPenalty = 120,
                bubbleHardAt = 1,
                bubbleLead = 0.35,
                bubbleLookahead = 1,
                bubbleMaxOut = 46,
                bubbleMinWeight = 0.25,
                bubbleNearWeight = 4.5,
                bubbleNoFlip = 2.5,
                bubbleOpenWeight = 0.55,
                bubbleProbe = 72,
                bubbleRadius = 2.8,
                bubbleRays = 48,
                bubbleSettle = 0.25,
                bubbleSoftCost = 8,
                bubbleStep = 1,
                bubbleTrajCost = 14,
                bubbleTrajLead = 2.4,
                bubbleWallPenalty = 3,
                bubbleWarnLead = 1.5,
                burstMax = 28,
                castSafe = false,
                champKeepOutRadius = 28,
                colorFloor = "#3cdc78",
                colorLive = "#ff3232",
                colorSoon = "#ffdc28",
                debugPrints = false,
                dodgeMargin = 0.5,
                dodgeRays = 32,
                dodgeRings = 8,
                dodgeShoulder = 2.3,
                drawAbility = true,
                drawAoe = true,
                drawBubble = true,
                drawGroups = true,
                drawHazards = true,
                drawLeads = false,
                drawNoGo = true,
                drawPath = true,
                drawScan = true,
                drawSpots = true,
                drawTarget = true,
                drawWaypoints = true,
                earlyHits = { thirdbosslineshot = 0.225652 },
                gatherMobs = true,
                groupZoneRadius = 70,
                hazardTransparency = 0.6,
                hbeamOutMult = 14,
                labelHazards = false,
                labelUnknown = false,
                learnedHits = {
                    firstbossjumpslam = { max = 2.383862, med = 1.917046, min = 1.700513, n = 374 },
                    firstbosspassivebeam = { max = 0.934149, med = 0.917061, min = 0.900064, n = 44416 },
                    firstbossspinningrockhitbox = { max = 1.081643, med = 0.7479, min = 0.399889, n = 62 },
                    mushroomwizardshot = { max = 1.033082, med = 0.999835, min = 0.950806, n = 10 },
                    northernmageshot = { max = 0.967336, med = 0.950676, min = 0.932844, n = 72111 },
                    northernwarriorlinestrike = { max = 0.665891, med = 0.646336, min = 0.622899, n = 1586 },
                    secondbosscrossbeam = { max = 3.4, med = 3, min = 2.6, n = 6 },
                    secondbossdirectshot = { max = 1.149213, med = 1.115783, min = 1.100242, n = 6 },
                    secondbosshorizontalbeam = { max = 1.06793, med = 1.06624, min = 1.050203, n = 14537 },
                    secondbossspinninglaserhitbox = { max = 1.749232, med = 1.082095, min = 0.433746, n = 38 },
                    secondbossspreadbeam = { max = 1.148447, med = 1.015032, min = 0.882547, n = 14197 },
                    spearmanstrikehitbox = { max = 0.849589, med = 0.816585, min = 0.799658, n = 8135 },
                    thirdbosscrossshot = { max = 1.118023, med = 1.116458, min = 1.100176, n = 78 },
                    thirdbosslineshot = { max = 0.88367, med = 0.882181, min = 0.849534, n = 1192 },
                    thirdbossxshot = { max = 1.034052, med = 1.033776, min = 0.983294, n = 6 },
                },
                mageMargin = 3,
                markerScale = 1,
                menuKey = "RightShift",
                missHits = {
                    firstbossjumpslam = 8,
                    firstbossspinningrock = 5.443984,
                    secondbosscriclehitbox = 5.78923,
                    thirdbosslineshot = 8,
                },
                mobStandoff = 34,
                orbSprintAt = 45,
                pingMarginMax = 12,
                pingManual = 0,
                policyVersion = 148,
                rangeMargin = 4,
                rangedStandoff = 22,
                reachBonus = -20,
                reachBonusBoss = -12,
                reachBonusMob = 4,
                ringSlim = 2.5,
                safeInset = 6,
                safeLead = 2.5,
                showHitboxes = false,
                slamNearWeight = 12,
                spikeAheadStuds = 2,
                strafe = true,
                streamer = true,
                streamerBody = true,
                streamerChat = true,
                streamerHealth = true,
                streamerLeaderboard = true,
                streamerLevel = true,
                streamerName = true,
                streamerOthers = true,
                streamerWealth = true,
                targetPriority = "group",
                tweenWalk = 16,
                wallClearView = true,
                wallTransparency = 0,
                wallsOn = true,
                wallsV2 = true,
                warriorKeepOut = 14,
                watchToFile = true,
            },
            warrior = {
                __version = "4.0.197",
                abilityRadius = 74,
                abilityRangeKnown = 99,
                aimReach = 140,
                aimWindow = 0.5,
                aoeDistance = 0,
                aoeRadius = 41,
                arenaEdge = 32,
                arenaMinIn = 26,
                arenaOpenMin = 0.55,
                arenaProbe = 45,
                arenaSlack = 8,
                attackRange = 13,
                autoAttack = true,
                autoE = true,
                autoFarmByPlace = true,
                autoQ = true,
                autoQueue = true,
                autoQueueDelay = 8,
                autoQueueDifficulty = "Insane",
                autoQueueHardcore = false,
                autoQueueMap = "Northern Lands",
                autoQueuePrivate = true,
                autoQueueReplay = true,
                autoStandoff = true,
                autoStartDungeon = true,
                blink = false,
                blinkMax = 6,
                blinkMobs = false,
                bobKeepOutRadius = 68,
                bonusBoss = false,
                bossStandoff = 33,
                bounceWeight = 1,
                bubbleAlongBonus = 10,
                bubbleArrive = 1.5,
                bubbleBreachFloor = 3,
                bubbleCommit = 0.9,
                bubbleCornerBoost = 3,
                bubbleDetourLeg = 14,
                bubbleDetourStick = 4,
                bubbleDetourStuck = 3,
                bubbleFlipPenalty = 120,
                bubbleHardAt = 1,
                bubbleLead = 0.35,
                bubbleLookahead = 1,
                bubbleMaxOut = 46,
                bubbleMinWeight = 0.25,
                bubbleNearWeight = 4.5,
                bubbleNoFlip = 2.5,
                bubbleOpenWeight = 0.55,
                bubbleProbe = 72,
                bubbleRadius = 2.525,
                bubbleRays = 48,
                bubbleSettle = 0.25,
                bubbleSoftCost = 8,
                bubbleStep = 1,
                bubbleTrajCost = 14,
                bubbleTrajLead = 2.4,
                bubbleWallPenalty = 3,
                bubbleWarnLead = 1.5,
                burstMax = 28,
                castSafe = false,
                champKeepOutRadius = 28,
                colorFloor = "#3cdc78",
                colorLive = "#ff3232",
                colorSoon = "#ffdc28",
                debugPrints = false,
                dodgeMargin = 0.5,
                dodgeRays = 32,
                dodgeRings = 8,
                dodgeShoulder = 2.3,
                drawAbility = true,
                drawAoe = true,
                drawBubble = true,
                drawGroups = true,
                drawHazards = true,
                drawLeads = true,
                drawNoGo = true,
                drawPath = true,
                drawScan = true,
                drawSpots = true,
                drawTarget = true,
                drawWaypoints = true,
                earlyHits = { thirdbosslineshot = 0.225652 },
                gatherMobs = true,
                groupZoneRadius = 70,
                hazardTransparency = 0.6,
                hbeamOutMult = 14,
                labelHazards = false,
                labelUnknown = false,
                learnedHits = {
                    cubepylonshot = { max = 0.875519, med = 0.816077, min = 0.800119, n = 14 },
                    firstbossjumpslam = { max = 2.383862, med = 1.951482, min = 1.700513, n = 385 },
                    firstbosspassivebeam = { max = 0.934713, med = 0.91679, min = 0.885309, n = 43908 },
                    firstbossrighthandshot = { max = 1.164435, med = 1.033007, min = 0.948276, n = 23 },
                    hitboxmodel = { max = 1.050388, med = 1.050089, min = 1.049819, n = 4 },
                    model = { max = 1.015787, med = 1.01487, min = 0.993052, n = 201 },
                    northernmageshot = { max = 0.979396, med = 0.950773, min = 0.937847, n = 67332 },
                    northernwarriorlinestrike = { max = 0.698253, med = 0.649728, min = 0.626725, n = 1536 },
                    secondbosscrossbeam = { max = 3.4, med = 3, min = 2.6, n = 6 },
                    secondbosshorizontalbeam = { max = 1.070407, med = 1.06614, min = 1.049589, n = 14111 },
                    secondbossspreadbeam = { max = 1.180723, med = 1.06393, min = 0.929911, n = 13762 },
                    spearmanstrikehitbox = { max = 0.839526, med = 0.816577, min = 0.731059, n = 7690 },
                    thirdbosslineshot = { max = 0.884654, med = 0.86764, min = 0.813114, n = 939 },
                },
                mageMargin = 1.2,
                markerScale = 1,
                menuKey = "RightShift",
                missHits = { firstbossjumpslam = 8, secondbosscriclehitbox = 5.78923, thirdbosslineshot = 8 },
                mobStandoff = 34,
                orbSprintAt = 45,
                pingMarginMax = 12,
                pingManual = 0,
                policyVersion = 148,
                rangeMargin = 4,
                rangedStandoff = 22,
                reachBonus = -20,
                reachBonusBoss = -11,
                reachBonusMob = 4,
                ringSlim = 2.5,
                safeInset = 6,
                safeLead = 2.5,
                showHitboxes = false,
                slamNearWeight = 12,
                spikeAheadStuds = 2,
                strafe = true,
                streamer = true,
                streamerBody = true,
                streamerChat = true,
                streamerHealth = true,
                streamerLeaderboard = true,
                streamerLevel = true,
                streamerName = true,
                streamerOthers = true,
                streamerWealth = true,
                targetPriority = "group",
                tweenWalk = 16,
                wallClearView = true,
                wallsOn = true,
                wallsV2 = true,
                warriorKeepOut = 14,
                watchToFile = true,
            },
        }, {
            __version = true,
            classProfile = true,
            policyVersion = true,
            menuKey = true,
            mapKey = true,
            debugPrints = true,
            watchToFile = true,
            autoQueue = true,
            autoQueueDifficulty = true,
            autoQueueHardcore = true,
            autoQueueMap = true,
            autoQueuePrivate = true,
            autoQueueReplay = true,
            autoQueueDelay = true,
            autoStartDungeon = true,
            autoFarmByPlace = true,
            bonusBoss = true,
            streamer = true,
            streamerName = true,
            streamerNameText = true,
            streamerHealth = true,
            streamerHealthText = true,
            streamerLevel = true,
            streamerLevelText = true,
            streamerGoldText = true,
            streamerGemsText = true,
            streamerXpText = true,
            streamerBody = true,
            streamerBodyColor = true,
            streamerOthers = true,
            streamerLeaderboard = true,
            streamerChat = true,
            streamerWealth = true,
        }
    context.applyClassProfile = function(classProfile, argument)
        local value = sharedValue19[classProfile]
        if type(value) ~= "table" then
            return false
        end
        local value2 = 0
        for key, entry in pairs(value) do
            if not sharedValue20[key] then
                local value3 = config[key]
                if typeof(value3) == "Color3" and type(entry) == "string" then
                    local success2, value4 = pcall(Color3.fromHex, entry)
                    if success2 then
                        config[key] = value4
                        value2 += 1
                    end
                else
                    if value3 ~= nil then
                        if typeof(entry) == typeof(value3) then
                            config[key] = entry
                            value2 += 1
                        end
                    end
                end
            end
        end
        config.classProfile = classProfile
        if context.applyBurst then
            context.applyBurst(config.burstMax)
        end
        if not argument then
            if context.refreshAll then
                pcall(context.refreshAll)
            end
            saveConfig()
        end
        log("Config", ("class profile %s applied: %d settings"):format(classProfile, value2))
        return true
    end
    local function helper3()
        local value
        local value2, value3 = -1
        local function helper4(argument, argument2)
            local value4 = readJson(argument, nil)
            if type(value4) ~= "table" then
                return
            end
            argument = 0
            for index, entry in ipairs(persist) do
                local value5, value6 = value4[entry], config[entry]
                argument = if value5 ~= nil
                    then if typeof(value6) == "Color3"
                        then if type(value5) == "string"
                            then if string.lower("#" .. value6:ToHex()) == string.lower(value5)
                                then argument
                                else argument + 1
                            else argument + 1
                        else if value5 == value6 then argument else argument + 1
                    else argument
            end
            if argument > value2 then
                value, value2, value3 = value4, argument, argument2
            end
        end
        if type(listfiles) == "function" then
            local success2, value7 = pcall(listfiles, paths.configs)
            if success2 and type(value7) == "table" then
                for index2, entry2 in ipairs(value7) do
                    index2 = string.match(string.gsub(tostring(entry2), "\\", "/"), "([^/]+)$")
                    if index2 then
                        if string.match(index2, "^release_%d+%.json$") then
                            if paths.configs .. "/" .. index2 ~= sharedValue12 then
                                helper4(paths.configs .. "/" .. index2, index2)
                            end
                        end
                    end
                end
            end
        end
        if not value then
            helper4(sharedValue10, "the old shared config")
        end
        if value then
            value.statsKey = nil
        end
        local value8, value9 = value, value3
        return value8, value9
    end
    local function loadConfig(argument)
        if not sharedValue16 then
            return false
        end
        local value, value2, value3 = readJson(sharedValue12, nil), false
        if type(value) ~= "table" then
            value, value3, value2 = {}, "the defaults", true
        else
            value3 = sharedValue12
        end
        if value2 then
            if not argument then
                context.firstRunNoConfig = true
            end
        end
        if value2 then
            if config.configCopyNew ~= false then
                local success2, data, value4 = pcall(helper3)
                if success2 then
                    if type(data) == "table" then
                        local value5
                        if config.configCopyAsk ~= false then
                            context.firstRunSeed = { data = data, name = tostring(value4) }
                            runtimeState.configAsk = true
                            value5 = "the defaults (asking whether to copy " .. tostring(value4) .. ")"
                            value3 = value5
                        else
                            value5 = tostring(value4) .. " (copied: this account had no config of its own)"
                            value, value3 = data, value5
                        end
                    end
                end
            end
        end
        if type(delfile) == "function" and type(isfile) == "function" then
            local value6 =
                { sharedValue10, sharedValue13, sharedValue14, sharedValue15, "DungeonAutofarm6_config.json" }
            for index, entry in ipairs(value6) do
                pcall(function()
                    if isfile(entry) then
                        delfile(entry)
                    end
                end)
            end
        end
        for index2, entry2 in ipairs(persist) do
            local value7, value8 = value[entry2], config[entry2]
            if typeof(value8) == "Color3" and type(value7) == "string" then
                local success3, value9 = pcall(Color3.fromHex, value7)
                if success3 then
                    config[entry2] = value9
                end
            elseif value7 ~= nil then
                if typeof(value7) == typeof(value8) then
                    config[entry2] = value7
                elseif value8 == nil then
                    if type(value7) ~= "table" then
                        config[entry2] = value7
                    end
                end
            end
        end
        config.tweenEscape = 26
        config.tweenSprint = burstMaxSpeed
        config.tweenSlam = burstMaxSpeed
        config.burstMin = burstMin
        config.burstMax = burstMaxSpeed
        if not argument then
            log(
                "Config",
                ("loaded %s for user %s%s"):format(
                    tostring(value3),
                    sharedValue11 > 0 and tostring(sharedValue11) or "unknown",
                    value2 and " (first run on this account - " .. tostring(value3) .. ")" or ""
                )
            )
        end
        if sharedValue16 and sharedValue12 ~= sharedValue10 then
            local value10 = false
            pcall(function()
                value10 = isfile(sharedValue12)
            end)
            if not value10 then
                saveConfig()
            end
        end
        return true
    end
    context.autoClass = function(argument)
        if config.classAuto == false then
            return nil
        elseif not context.applyClassProfile then
            return nil
        end
        local localPlayer2 = getService("Players").LocalPlayer
        local valueObject, value =
            localPlayer2 and (localPlayer2:FindFirstChild("physicalPower")),
            localPlayer2 and (localPlayer2:FindFirstChild("spellPower"))
        local value2, value3 =
            valueObject and tonumber(valueObject.Value) or 0, value and tonumber(value.Value) or 0
        if value2 == value3 then
            return nil
        end
        value = value2 > value3 and "warrior" or "mage"
        if config.classProfile == value then
            return value
        end
        if runtimeState.overlay1186 then
            for key, entry in pairs(runtimeState.overlay1186) do
                config[key] = entry.v
            end
            runtimeState.overlay1186 = nil
            runtimeState.overlayMode = nil
        end
        context.applyClassProfile(value, true)
        saveConfig()
        if not argument then
            if context.refreshAll then
                pcall(context.refreshAll)
            end
        end
        log(
            "Config",
            ("class from the stats: %s (physical power %d, spell power %d)"):format(value, value2, value3)
        )
        return value
    end
    local function autosaveTick(argument)
        if argument - sharedValue18 < config.autosaveInterval then
            return
        end
        sharedValue18 = argument
        saveConfig()
    end
    pcall(function()
        local function helper4(argument)
            if argument == Enum.TeleportState.Started then
                saveConfig()
            elseif argument == Enum.TeleportState.RequestedFromServer then
                saveConfig()
            end
        end
        localPlayer.OnTeleport:Connect(helper4)
    end)
    context.SCRIPT_VERSION = "v3.0 c84b"
    context.SCRIPT_CODENAME = "Groups"
    context.SCRIPT_BUILD_DATE = "19 Oct 2026"
    context.SCRIPT_CHANGELOG = {}
    context.Players = players
    context.LocalPlayer = localPlayer
    context.Workspace = sharedValue2
    context.RunService = runService
    context.ReplicatedStorage = replicatedStorage
    context.HttpService = httpService
    context.UserInputService = userInputService
    context.PathfindingService = pathfindingService
    context.VirtualInputManager = virtualInputManager
    context.CFG = config
    context.RT = runtimeState
    context.TIMING = timing
    context.PROJECTILE_HINTS = {
        "crisscross",
        "spearmanstrike",
        "seekingspike",
        "bigspike",
        "missile",
        "orb",
        "rock",
        "freezepart",
        "shuriken",
        "bomb",
    }
    context.LANE_HARD = { "bigspike" }
    context.TIMING_BELOW = timingBelow
    do
        local sharedValue21 = {}
        for entry3 in pairs(timingBelow) do
            sharedValue21[entry3] = timing[entry3] or false
        end
        context.syncTiming = function()
            local timingBelow2 = context.belowNL ~= nil and context.belowNL() == true
            if runtimeState.timingBelow == timingBelow2 then
                return
            end
            runtimeState.timingBelow = timingBelow2
            for key, entry in pairs(timingBelow) do
                if timingBelow2 then
                    timing[key] = entry
                else
                    timing[key] = sharedValue21[key] or nil
                end
            end
        end
    end
    context.UI = {}
    context.sliderConnections = {}
    context.bossProfile = bossProfile
    context.bobCrystal = bobCrystal
    context.bobCrystalCentroid = bobCrystalCentroid
    context.log = log
    context.logT = logT
    context.setState = setState
    context.character = character
    context.flatDistance = flatDistance
    context.visualRoot = visualRoot
    context.isOurs = isOurs
    context.raycastParams = raycastParams
    context.floorY = floorY
    context.saveConfig = saveConfig
    context.loadConfig = loadConfig
    context.autosaveTick = autosaveTick
    do
        local loadConfig2 = loadConfig
        context.loadConfig = function(...)
            local value = table.pack(loadConfig2(...))
            if context.devVisApply then
                pcall(context.devVisApply, true)
            end
            return table.unpack(value, 1, value.n)
        end
    end
    context.PERSIST = persist
    context.snapshot = snapshot
    context.CFG_DEFAULTS = snapshot()
end
