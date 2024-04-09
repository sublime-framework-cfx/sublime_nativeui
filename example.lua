local menu = nativeui.CreateMenu:new({
    id = 'main',
    title = 'Main Menu',
    subtitle = 'subtitle',
    backgroundColor = {255, 255, 255, 125},
    --width = .2,
})

local sub = nativeui.CreateMenu:new({
    parent = 'main',
    id = 'sub',
    title = 'Main Menu',
    backgroundColor = {0, 0, 0, 125},
    --x = .075,
    --y = .1,
    --w = .1,
})

-- local sub = menu:AddSubMenu({
--     id = 'sub',
--     title = 'Sub Menu',
--     subtitle = 'subtitle',
--     backgroundColor = {0, 255, 255, 125},
--     width = .1,
-- })

local isAsync = 'mon button 1'

function menu:Pool(item, panel)
    for i = 1, 100 do
        item:AddButton(self, 'mon button '..i, 'et ouais', nil, {
            onEnter = function(obj, menu)
                print('onEnter '..obj.id, menu.index)
            end, onExit = function(obj, menu)
                print('onExit '..obj.id, menu.index)
            end, onSelected = function(obj, menu)
                print('onSelected '..obj.id, menu.index)
            end
        })

        if i == 5 then
            item:AddButton(self, 'mon button 5', 'et ouais', nil, {
                onEnter = function(obj, menu)
                    print('onEnter '..obj.id, menu.index)
                end, onExit = function(obj, menu)
                    print('onExit '..obj.id, menu.index)
                end, onSelected = function(obj, menu)
                    print('onSelected '..obj.id, menu.index)
                end, onActive = function(obj, menu)
                    print('onActive '..obj.id, menu.index)
                end
            }, sub)
        end
    end
    
end

function sub:Closed()
    print("j'ai fermer mon submenu")
end

function sub:Pool(item)
    item:AddButton(self, 'mon button 3', 'et ouais', nil, {
        onEnter = function(obj, menu)
            print('onEnter '..obj.id, menu.index)
        end, onExit = function(obj, menu)
            print('onExit '..obj.id, menu.index)
        end
    })
    item:AddButton(self, 'mon button 4', 'et ouais', nil, {
        onEnter = function(obj, menu)
            print('onEnter '..obj.id, menu.index)
        end, onExit = function(obj, menu)
            print('onExit '..obj.id, menu.index)
        end
    }, menu)

    for i = 1, 100 do
        item:AddButton(self, 'mon button '..i, 'et ouais', nil, {
            onEnter = function(obj, menu)
                print('onEnter '..obj.id, menu.index)
            end, onExit = function(obj, menu)
                print('onExit '..obj.id, menu.index)
            end
        })
    end
end

RegisterCommand('chi', function()
    sub.index = 2
end)

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