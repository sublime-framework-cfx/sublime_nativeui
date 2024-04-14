local menu1 = nativeui.CreateMenu:new({
    id = 'menu1:'..nativeui.env,
    banner = false,
    title = 'Menu 1',
    subtitle = 'subtitle',
    name = 'Menu 1 de Test 1', -- name of menu per default is id (util later for tool to see all menu created)
    backgroundColor = {255, 255, 255, 125},
})

local menu2 = nativeui.CreateMenu:new({
    id = 'menu2:'..nativeui.env,
    title = 'Menu 2',
    name = 'Menu 2 de Test 2', -- name of menu per default is id (util later for tool to see all menu created)
    backgroundColor = {255, 255, 255, 125},
    maVarQueJeVeux = 'et ouais morray :)!'
})

function menu1:Opened()
    print(self.id .. ' is opened')
end

function menu1:Closed()
    print(self.id .. ' is closed')
end

function menu1:IsVisible()
    self:Elements(function(Item)
        Item:AddButton('et ouais', nil, nil, {
            onEnter = function(s)
                print('onEnter '..s.id, self.index, self.id, self.title)
            end, onExit = function(s)
                print('onExit '..s.id, self.index)
            end, onSelected = function(s)
                print('onSelected '..s.id, self.index)
            end
        })

        Item:AddButton('Go to Menu 2 Test 2', nil, { animation = { color = {0, 89, 250, 150}}}, {
            onEnter = function(s)
                print('onEnter '..s.id, self.index, self.id, self.title)
            end, onExit = function(s)
                print('onExit '..s.id, self.index)
            end, onSelected = function(s)
                print('onSelected '..s.id, self.index)
            end, onActive = function(s)
                print('onActive '..s.label, self.index)
            end
        }, menu2)

        Item:AddButton('button 3', nil, nil, {
            onEnter = function(s)
                print('onEnter '..s.id, self.index, self.id, self.title)
            end, onExit = function(s)
                print('onExit '..s.id, self.index)
            end
        })

        Item:AddButton('Go to menu1 test 1', 'We trying to open a menu not registered :)', nil, {
            onEnter = function(s)
                print('onEnter '..s.id, self.index, self.id, self.title)
            end, onExit = function(s)
                print('onExit '..s.id, self.index)
            end
        }, 'menu1:test1')
    end--[[, function(Panel)
        ---@todo
    end]])
end

function menu2:Opened()
    self:ResetIndex() -- reset index to 1
    print(self.id .. ' is opened', self.maVarQueJeVeux)
end

function menu2:Closed()
    print(self.id .. ' is closed')
end

function menu2:IsVisible()
    self:Elements(function(Item)
        Item:AddButton(self.maVarQueJeVeux, nil, nil, {
            onEnter = function(s)
                print('onEnter '..s.id, self.index, self.id, self.title)
            end, onExit = function(s)
                print('onExit '..s.id, self.index)
            end, onSelected = function(s)
                self.maVarQueJeVeux = 'et non morray :)!'
            end
        })

        Item:AddButton('Go to Menu 1 Test 1', nil, { animation = { color = {0, 89, 250, 150}}}, {
            onEnter = function(s)
                print('onEnter '..s.id, self.index, self.id, self.title)
            end, onExit = function(s)
                print('onExit '..s.id, self.index)
            end, onSelected = function(s)
                print('onSelected '..s.id, self.index)
            end, onActive = function(s)
                print('onActive '..s.label, self.index)
            end
        }, menu1)

        Item:AddButton('button 3', nil, nil, {
            onEnter = function(s)
                print('onEnter '..s.id, self.index, self.id, self.title)
            end, onExit = function(s)
                print('onExit '..s.id, self.index)
            end
        })

        Item:AddButton('GoBack', nil, nil, {
            onEnter = function(s)
                print('onEnter '..s.id, self.index, self.id, self.title)
            end, onExit = function(s)
                print('onExit '..s.id, self.index)
            end, onSelected = function(s)
                self:Close('GoBack')
                -- or menu1:Open()
                -- or nativeui.OpenMenu('menu1:test2')
                -- or nativeui.OpenLastMenu()
            end
        })
    end--[[, function(Panel)
        ---@todo
    end]])
end

RegisterCommand('mt1', function()
    if menu1:IsOpen() then
        menu1:Close()
    else
        menu1:Open()
    end
end)