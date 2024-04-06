local menu = nativeui:new({
    id = 'main',
    title = 'Main Menu',
    subtitle = 'subtitle',
    backgroundColor = {255, 255, 255, 125},
    width = .2,
})

local sub = menu:AddSubMenu({
    id = 'sub',
    title = 'Sub Menu',
    subtitle = 'subtitle',
    backgroundColor = {0, 255, 255, 125},
    width = .1,
})

local isAsync = 'mon button 1'

function menu:pool(item)
    item:AddButton(isAsync, 'et ouais')
    local button2 = item:AddButton('mon button 2', 'et ouais')

    if IsControlJustPressed(0, 38) then -- E
        print('here?')
        sub:Open()
    end
end

function sub:pool(item)
    item:AddButton('mon button 3', 'et ouais')
    item:AddButton('mon button 4', 'et ouais')
    print('here?')
end

RegisterCommand('isA', function()
    if isAsync == 'mon button 1' then
        isAsync = 'mon button 11'
    else
        isAsync = 'mon button 1'
    end
end)

RegisterCommand('suop', function()
    if menu:isOpen() then
        menu:Close()
    else
        menu:Open()
    end
end)

RegisterCommand('cco', function()
    nativeui.CloseAll()
end)