local sublimeui = nativeui.CreateMenu:new({
    id = 'sublimeui_menu',
    title = 'sublime ui',
    subtitle = 'Tout les menu créer!',
    name = 'Menu manager', -- name of menu per default is id (util later for tool to see all menu created)
    menus = {},
    canPrint = false,
    currentReg = 1,
})

function sublimeui:Opened()
    print(self.id .. ' is opened')
    local menus = nativeui.GetAllMenus()
    local ordered = {}
    for _, v in pairs(menus) do
        ordered[#ordered + 1] = v
    end
    table.sort(ordered, function(a, b)
        return a.name < b.name
    end)
    self.menus = ordered
end

function sublimeui:Closed()
    print(self.id .. ' is closed')
    self.canPrint = false
end

local reg <const> = {
    '~g~',
    '~b~',
    '~r~',
    '~y~',
    '~p~',
    '~o~',
    '~c~',
    '~m~',
    '~u~',
}

function sublimeui:IsVisible()
    local buttons = {}

    self:Elements(function(Item)
        buttons = {}
        for i = 1, #self.menus do
            local m <const> = self.menus[i]
            if m.id ~= self.id then
                local desc <const> = 'Press to open '..m.name..'\nInfo:\n'..'- id: '..m.id..'\n'..'- env: '..m.env..'\n'..'- name: '..m.name..'\n'..'- type: '..m.type
                buttons[i] = Item:AddButton(m.name, desc, nil, {}, m.id)
            else
                local desc <const> = 'This menu\n'..'- id: '..m.id..'\n'..'- env: '..m.env..'\n'..'- name: '..m.name..'\n'..'- type: '..m.type
                buttons[i] = Item:AddButton(reg[self.currentReg]..m.name, desc, {}, {
                    onSelected = function()
                        self.currentReg = math.random(#reg)
                    end
                })
            end
        end
    end, function(Panel) ---@todo
        if not self.canPrint then
            self.canPrint = true
            local info = {}
            for i = 1, #buttons do
                local b <const> = buttons[i]
                info[b.id] = {
                    'id = '..b.id,
                    'label = '..b.label,
                    'description = '..b.description,
                }
            end

            print(json.encode(info, { indent = true }))
        end
    end)
end

RegisterCommand('sublimeui_test', function()
    if sublimeui:IsOpen() then
        sublimeui:Close()
    else
        sublimeui:Open()
    end
end)

local test_100 = nativeui.CreateMenu:new({
    id = 'test_100',
    title = '100',
    subtitle = 'test',
    name = 'Test 100 buttons',
})

function test_100:Opened()
    self:ResetIndex()
end

function test_100:IsVisible()
    self:Elements(function(Items)
        for i = 1, 100 do
            Items:AddButton('button '..i, 'description '..i, nil, {})
        end
    end)
end

local test = nativeui.CreateMenu:new({
    id = 'test_1000',
    title = '1000',
    subtitle = 'test',
    name = 'Test 1000 buttons',
})

function test:Opened()
    self:ResetIndex()
end

function test:IsVisible()
    self:Elements(function(Items)
        for i = 1, 1000 do
            Items:AddButton('button '..i, 'description '..i, nil, {})
        end
    end)
end