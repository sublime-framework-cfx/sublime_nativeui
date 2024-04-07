return function(self, menu, test, test2)
    menu.size += 1
    --print(test, test2, menu.size)

    return menu.size --[[@as buttonId]] --[[@return integer]]
end