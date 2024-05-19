--- Sneaky animation
--- @param menu Menu
--- @param options table
--- @param config table
--- @param data table
--- @param rect DrawProps.rect<{rect: fun(x: float, y: float, w: float, h: float, r: integer, g: integer, b: integer, a: integer): void}>
return function(self, menu, options, config, data, rect)
    local h_top_bottom <const> = data.h * .1

    -- Premier rectangle il va de gauche à droite comme progress-right
    local y1_bottom <const> = data.y + (data.h * .5) - (data.h * .1) * .5
    local startX1 <const> = data.x - (data.w * .5)
    local w1, newX1 = 0, startX1


    -- Deuxième rectangle il va de bas en haut a droite du bouton
    local x2_bottom <const> = data.y + (data.h * .5) + (data.h * .1) * .5
    local startY2 <const> = data.y + (data.h * .5)
    local y2, newY2 = 0, startY2

    -- Troisième rectangle il va de droite à gauche comme progress-left et il est en haut du bouton
    local y3_top <const> = data.y - (data.h * .5) + (data.h * .1) * .5
    local startX3 <const> = data.x + (data.w * .5)
    local w3, newX3 = 0, startX3

    -- Quatrième rectangle il va de haut en bas a gauche du bouton
    local x4_top <const> = data.y - (data.h * .5) - (data.h * .1) * .5
    local startY4 <const> = data.y - (data.h * .5)
    local y4, newY4 = 0, startY4

    local step = 0

    while (self.state == menu.index) and (menu.opened) and not menu.playAnimation do
        if step == 0 then
            if w1 >= data.w then
                step += 1
            end

            rect( -- step 1
                newX1,
                y1_bottom,
                w1,
                h_top_bottom,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            w1 += (data.w * .005)
            newX1 += (data.w * .005) * .5
        elseif step == 1 then
            if y2 >= data.h then
                step += 1
            end

            rect( -- step 1
                data.x,
                y1_bottom,
                data.w,
                h_top_bottom,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            rect( -- step 2
                data.x + (data.w * .5),
                newY2,
                h_top_bottom * .5,
                y2,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            y2 += (data.h * .05)
            newY2 -= (data.h * .05) * .5
        elseif step == 2 then
            if w3 >= data.w then
                step += 1
            end

            rect( -- step 1
                data.x,
                y1_bottom,
                data.w,
                h_top_bottom,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            rect( -- step 2
                data.x + (data.w * .5),
                data.y,
                h_top_bottom * .5,
                data.h,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            rect( -- step 3
                newX3,
                y3_top,
                w3,
                h_top_bottom,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            w3 += (data.w * .005)
            newX3 -= (data.w * .005) * .5
        elseif step == 3 then
            if y4 >= data.h then
                step += 1
            end

            rect( -- step 1
                data.x,
                y1_bottom,
                data.w,
                h_top_bottom,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            rect( -- step 2
                data.x + (data.w * .5),
                data.y,
                h_top_bottom * .5,
                data.h,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            rect( -- step 3
                data.x,
                y3_top,
                data.w,
                h_top_bottom,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            rect( -- step 4
                data.x - (data.w * .5),
                newY4,
                h_top_bottom * .5,
                y4,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            y4 += (data.h * .05)
            newY4 += (data.h * .05) * .5
        elseif step == 4 then
            if w1 <= 0 then
                y2 = data.h
                newY2 = data.y + (data.h * .5) * .5
                step += 1
            end

            rect( -- step 1
                newX1 - .001,
                y1_bottom,
                w1,
                h_top_bottom,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            rect( -- step 2
                data.x + (data.w * .5),
                data.y,
                h_top_bottom * .5,
                data.h,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            rect( -- step 3
                data.x,
                y3_top,
                data.w,
                h_top_bottom,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            rect( -- step 4
                data.x - (data.w * .5),
                newY4,
                h_top_bottom * .5,
                y4,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            w1 -= (data.w * .005)
            newX1 += (data.w * .005) * .5
        elseif step == 5 then
            if y2 < 0 then
                step += 1
            end

            rect( -- step 2
                data.x + (data.w * .5),
                newY2 - .005,
                h_top_bottom * .5,
                y2,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            rect( -- step 3
                data.x,
                y3_top,
                data.w,
                h_top_bottom,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            rect( -- step 4
                data.x - (data.w * .5),
                newY4,
                h_top_bottom * .5,
                y4,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            y2 -= (data.h * .05)
            newY2 -= (data.h * .05) * .5
        elseif step == 6 then
            if w3 <= 0 then
                step += 1
            end

            rect( -- step 3
                newX3,
                y3_top,
                w3 - .002,
                h_top_bottom,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            rect( -- step 4
                data.x - (data.w * .5),
                newY4,
                h_top_bottom * .5,
                y4,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            w3 -= (data.w * .005)
            newX3 -= (data.w * .005) * .5
        elseif step == 7 then
            if y4 <= 0 then
                step += 1
            end

            rect( -- step 4
                data.x - (data.w * .5),
                newY4,
                h_top_bottom * .5,
                y4,
                options?.color?[1] or 255,
                options?.color?[2] or 255,
                options?.color?[3] or 255,
                options?.color?[4] or 150
            )

            y4 -= (data.h * .05)
            newY4 += (data.h * .05) * .5
        end
        
        if step >= 8 then break end

        Wait(0)
    end

    return true
end
