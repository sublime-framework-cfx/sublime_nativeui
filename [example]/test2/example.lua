local menu = nativeui.CreateMenu:new({
    id = 'menu:example',
    title = 'Example',
    subtitle = 'Select',
    name = 'Menu Example', -- name of menu per default is id (util later for tool to see all menu created)
    data = {
        checked = false,
        index = 1,
        list = {
            { label = 'label 1', value = 'value 1' },
            { label = 'label 2', value = 'value 2' },
            { label = 'label 3', value = 'value 3' },
            { label = 'label 4', value = 'value 4' },
            { label = 'label 5', value = 'value 5' },
            { label = 'label 6', value = 'value 6' },
            { label = 'label 7', value = 'value 7' },
            { label = 'label 8', value = 'value 8' },
            { label = 'label 9', value = 'value 9' },
            { label = 'label 10', value = 'value 10' },
        }
    },
    condition = function()
        return not IsPedFatallyInjured(PlayerPedId()) -- if player is dead menu will be closed automatically
    end
})

local menuSub = menu:AddSubMenu('sub', "Sub")

function menu:IsVisible()
    self:Elements(function(Item)
        Item:AddButton('Mon bouton', 'Ma description', { rightlabel = '→→→' }, {
            onSelected = function(obj)
                print('onSelected ', self.index == obj.id)
            end
        })

        Item:AddSeparator('Mon separator')

        Item:AddCheckbox('Mon checkbox', nil, self.data.checked, nil, {
            onSelected = function(obj, checked)
                self.data.checked = checked
                print('onSelected ', checked)
            end,
            onChecked = function(obj, checked)
                print('onChecked ', checked)
            end, onUnChecked = function(obj, checked)
                print('onUnChecked ', checked)
            end
        })

        Item:AddLine()

        Item:AddList('Mon liste', nil, self.data.index, self.data.list, nil, {
            onSelected = function(obj)
                print('onSelected ', self.data.index, self.data.list[self.data.index])
            end, onListChanged = function(obj, index, item)
                print('onListChanged prev index', self.data.index, 'new index', index)
                self.data.index = index
                print('onListChanged ', index, item.value)
            end
        })

        Item:AddButton('Sub menu', nil, nil, {}, menuSub)
    end)
end

function menuSub:IsVisible()
    self.data = menu.data

    self:Elements(function(Item)
        Item:AddButton('Mon bouton', 'Ma description', { rightlabel = '→→→' }, {
            onSelected = function(obj)
                print('onSelected ', self.index == obj.id)
            end
        })

        Item:AddSeparator('Mon separator')

        Item:AddCheckbox('Mon checkbox', nil, self.data.checked, nil, {
            onSelected = function(obj, checked)
                self.data.checked = checked
                print('onSelected ', checked)
            end,
            onChecked = function(obj, checked)
                print('onChecked ', checked)
            end, onUnChecked = function(obj, checked)
                print('onUnChecked ', checked)
            end
        })

        Item:AddLine()

        Item:AddList('Mon liste', 'Description', self.data.index, self.data.list, nil, {
            onSelected = function(obj)
                print('onSelected ', self.data.index, self.data.list[self.data.index])
            end, onListChanged = function(obj, index, item)
                print('onListChanged prev index', self.data.index, 'new index', index)
                self.data.index = index
                print('onListChanged ', index, item.value)
            end
        })
    end)
end

RegisterCommand('example', function()
    menu:Toggle()
end)

RegisterCommand('condition', function()
    if IsPedFatallyInjured(PlayerPedId()) then
        CreateThread(function()
            DoScreenFadeOut(1000)
            Wait(1000)
            local maxHealth <const> = GetEntityMaxHealth(PlayerPedId())
            local playerCoords <const> = GetEntityCoords(PlayerPedId())
            SetEntityCoordsNoOffset(PlayerPedId(), playerCoords.x, playerCoords.y, playerCoords.z, false, false, false)
            NetworkResurrectLocalPlayer(playerCoords.x, playerCoords.y, playerCoords.z, 0.0, true, false)
            SetEntityInvincible(PlayerPedId(), false)
            SetPlayerInvincible(PlayerId(), false)
            Wait(1000)
            DoScreenFadeIn(1000)
            SetEntityHealth(PlayerPedId(), maxHealth)
        end)
    else
        CreateThread(function()
            DoScreenFadeOut(1000)
            Wait(1000)
            SetEntityHealth(PlayerPedId(), 0)
            Wait(1000)
            DoScreenFadeIn(1000)
        end)
    end
end)


--------------------------------------------------------------------------------------------------------
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
    menu1:Toggle()
end)

--[[
        Items:AddList('Mon button liste', nil, self.data.index, self.data.list, { rightlabel = 'Hello world!' }, {
            onSelected = function()
                print('onSelected ', self.data.index, self.data.list[self.data.index])
            end, onListChanged = function(obj, index, item)
                print('onListChanged ', index, item, obj)
                self.data.index = index
            end
        })

        Items:AddCheckbox('Mon checkbox', nil, self.data.checked, { rightlabel = 'Hello world!' }, {
            onSelected = function(obj, checked)
                print('onSelected ', checked)
            end,
            onChecked = function(obj, checked)
                self.data.checked = checked
                print('onChecked ', checked)
            end, onUnChecked = function(obj, checked)
                self.data.checked = checked
                print('onUnChecked ', checked)
            end
        })

        Items:AddButton('Touches', 'Gérer les animations que vous avez bind', { rightlabel = '→→→' }, {
            onSelected = function()
                print('onSelected ', self.index)
            end
        })
]]