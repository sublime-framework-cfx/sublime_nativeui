local menu = nativeui.CreateMenu:new({
    id = 'main',
    title = 'Main Menu',
    subtitle = 'subtitle',
    backgroundColor = {255, 255, 255, 125},
    width = .2,
})

local sub = nativeui.CreateMenu:new({
    parent = 'main',
    id = 'sub',
    title = 'Main Menu',
    subtitle = 'subtitle',
    backgroundColor = {0, 255, 255, 125},
    width = .1,
})

-- local sub = menu:AddSubMenu({
--     id = 'sub',
--     title = 'Sub Menu',
--     subtitle = 'subtitle',
--     backgroundColor = {0, 255, 255, 125},
--     width = .1,
-- })

local isAsync = 'mon button 1'

function menu:pool(item, panel)
    item:AddButton(self, isAsync, 'et ouais')
    local button2 = item:AddButton(self, 'mon button 2', 'et ouais', sub)

    -- panel:Slider(self, button2, 'mon slider', 0, 100, 50, 1, 'et ouais')
    -- panel:Slider(self, button2, 'mon slider 2', 0, 100, 50, 1, 'et ouais')

    if IsControlJustPressed(0, 38) then -- E
        print('here?')
        sub:Open()
    end
end

function sub:pool(item)
    item:AddButton(self, 'mon button 3', 'et ouais')
    item:AddButton(self, 'mon button 4', 'et ouais')
    --print('here?')
end

RegisterCommand('oplast', function()
    nativeui.OpenLastMenu()
end)

RegisterCommand('isA', function()
    if isAsync == 'mon button 1' then
        isAsync = 'mon button 11'
    else
        isAsync = 'mon button 1'
    end
end)

RegisterCommand('suop', function()
    if menu:IsOpen() then
        menu:Close()
    else
        menu:Open()
    end
end)

RegisterCommand('cco', function()
    nativeui.CloseMenu()
end)