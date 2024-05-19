local class <const> = require '@sublime_nativeui.src.utils.class'
local animation = class('AnimationMenu')

function animation:open(config)
    CreateThread(function()
        local id <const> = self.menu?.animation?.type or 'default'
        local success <const>, anim <const> = pcall(require, '@sublime_nativeui.src.menu.components.animation.'..self.menu.type..'.'..id)

        if not success then
            error(('Animation Menu [%s] not found!'):format(id), 2)
        end

        self.menu.x = anim.config['open'].x or self.menu.x
        self.menu.y = anim.config['open'].y or self.menu.y

        --print('play?', self.menu.id)
        anim['open'](self.menu, config)
    end)
end

function animation:close(config)
    CreateThread(function()
        local id <const> = self.menu?.animation?.type or 'default'
        local success <const>, anim <const> = pcall(require, '@sublime_nativeui.src.menu.components.animation.'..self.menu.type..'.'..id)
    
        if not success then
            error(('Animation Menu [%s] not found!'):format(id), 2)
        end
    
        --self.menu.x = anim.config['close'].x or self.menu.x
        --self.menu.y = anim.config['close'].y or self.menu.y

        anim.close(self.menu, config)
    end)
end

return animation
