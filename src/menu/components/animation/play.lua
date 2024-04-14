---@experimental

--- Play animation for menu

--- @param _type string | 'open' | 'close'
--- @param menu Menu
--- @param config table
return function(_type, menu, config)
    local id <const> = menu?.animation?.type or 'default'
    local success <const>, anim <const> = pcall(require, '@sublime_nativeui.src.menu.components.animation.'..id)

    if not success then
        error(('Animation Menu [%s] not found!'):format(id), 2)
    end

    menu.x = anim.config[_type].x or menu.x
    menu.y = anim.config[_type].y or menu.y

    CreateThread(function()
        anim[_type](menu, config)
    end)
end