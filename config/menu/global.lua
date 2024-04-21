--[[
    Config for default settings menu used by (CreateMenu.lua)
--]]

return {
    -- Banner & Subtitle
    banner = true, --[[ nil / false if you don't want subtitle ]]
    bannerH = .09,
    subtitle = 'Selected', --[ [nil / false if you don't want subtitle ]]
    subtitleH = .03,
    glare = true,
    background = true,
    maxVisibleItems = 12,
    default = { x = .035, y = .045, w = .225, h = .2 --[[@unknown ]] },
    padding = .0025, -- padding between all elements (banner, subtitle, items, etc...)
    backgroundColor = { 0, 0, 0, 100 }, --[[@as rgba]]
    animation = {
        enabled = true,
        type = 'default',
    },
}