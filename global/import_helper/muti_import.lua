return {
    mytu_import = function(...)
        local modules = {}
        for _, moduleName in ipairs {...} do
            modules[moduleName] = require(moduleName)
        end
        return unpack(modules)
    end
}
