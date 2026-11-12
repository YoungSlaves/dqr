-- Shared services and Lua helpers.
-- This is the only place the executor environment is touched for services.
-- Every feature module gets `getService` / `argumentHelpers` from here via the
-- module environment set up by dqr.lua, so no body had to be rewritten.
return function(context)
    local serviceCache = {}

    local function getService(name)
        local service = serviceCache[name]
        if not service then
            service = game:GetService(name)
            if type(cloneref) == "function" then
                service = cloneref(service)
            end
            serviceCache[name] = service
        end
        return service
    end

    local argumentHelpers = { [108] = table.pack, [66] = unpack, [58] = table.move }
    argumentHelpers.unpackValues = function(helpers, values)
        return helpers[66](values, 1, values.n)
    end
    argumentHelpers.appendValues = function(helpers, destination, offset, ...)
        local packedValues = helpers[108](...)
        helpers[58](packedValues, 1, packedValues.n, offset + 1, destination)
    end
    argumentHelpers.appendPackedValues = function(_helpers, destination, offset, values)
        for index = 1, values.n, 1 do
            destination[offset + index] = values[index]
        end
        destination.n = offset + values.n
    end

    context.getService = getService
    context.argumentHelpers = argumentHelpers
    context.services = serviceCache
end
