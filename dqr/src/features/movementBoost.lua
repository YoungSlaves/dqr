-- Extracted verbatim from harvardd.lua lines 7739-7841; presentation owned elsewhere.
    local config, runtimeState = context.CFG, context.RT
    local localPlayer, config2 =
        context.LocalPlayer, { TargetSpeed = 24, MinSpeed = 18, MaxSpeed = 26, FallbackSpeed = 16 }
    local sharedValue = localPlayer.Character
    local sharedValue2, sharedValue3, sharedValue4, moverHeading =
        sharedValue and (sharedValue:FindFirstChildOfClass("Humanoid")), false
    local function helper()
        if sharedValue then
            if sharedValue.Parent then
                if sharedValue2 then
                    if sharedValue2.Parent then
                        return true
                    end
                end
            end
        end
        sharedValue = localPlayer.Character
        sharedValue2 = sharedValue and sharedValue:FindFirstChildOfClass("Humanoid")
        local value = sharedValue2
        return value ~= nil
    end
    local function steer(moverHeading2)
        moverHeading = moverHeading2
        runtimeState.moverHeading = moverHeading2
    end
    local sharedValue5 = config2.TargetSpeed
    local function helper2(argument)
        if not (helper()) then
            local value = sharedValue5
            return value
        end
        local locomotionSpeed =
            math.clamp(tonumber(argument) or config2.TargetSpeed, config2.MinSpeed, config2.MaxSpeed)
        if sharedValue3 then
            if math.abs(locomotionSpeed - sharedValue5) >= 2 then
                sharedValue5 = locomotionSpeed
            end
            if sharedValue2.WalkSpeed ~= sharedValue5 then
                sharedValue2.WalkSpeed = sharedValue5
            end
            runtimeState.locomotionSpeed = sharedValue5
            argument = sharedValue5
            return argument
        end
        sharedValue3, sharedValue5 = true, locomotionSpeed
        sharedValue4 = sharedValue2.WalkSpeed > 0 and sharedValue2.WalkSpeed or nil
        sharedValue2.WalkSpeed = sharedValue5
        locomotionSpeed = nil
        locomotionSpeed, runtimeState.locomotion = sharedValue5, true
        runtimeState.locomotionSpeed = locomotionSpeed
        argument = sharedValue5
        return argument
    end
    local function off()
        moverHeading = nil
        runtimeState.moverHeading = nil
        if not sharedValue3 then
            return
        end
        sharedValue3 = false
        runtimeState.locomotion = false
        runtimeState.locomotionSpeed = nil
        if helper() then
            local humanoid = sharedValue2
            humanoid.WalkSpeed = sharedValue4 or config2.FallbackSpeed
        end
        sharedValue4 = nil
    end
    local connection = localPlayer.CharacterAdded:Connect(function(argument)
        sharedValue = argument
        sharedValue2, sharedValue3, sharedValue4, moverHeading =
            argument:FindFirstChildOfClass("Humanoid"), false, nil, nil
        runtimeState.moverHeading = nil
        runtimeState.locomotion = false
        runtimeState.locomotionSpeed = nil
    end)
    local function stop()
        off()
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
    context.LC = {
        on = helper2,
        off = off,
        steer = steer,
        stop = stop,
        CONFIG = config2,
        active = function()
            return false
        end,
        boosted = function()
            local value = sharedValue3
            return value
        end,
        speed = function()
            local value = sharedValue3 and sharedValue5 or nil
            return value
        end,
    }

return function(context)
end
