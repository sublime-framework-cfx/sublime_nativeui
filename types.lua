------------------------------------------------------------------------
-- [nativeui] 
------------------------------------------------------------------------
-- main

---@class REGISTERED_MENU_PROPS
---@field [string]: { id: string, env: string, type: string }


-- nativeui.RegisterMenu(menu)
---@class RegisterMenuProps
---@field id string
---@field env string
---@field type string
---@field name string

-- init


------------------------------------------------------------------------
-- [utils]
------------------------------------------------------------------------

--draw
---@class DrawProps
---@field rect fun(x: float, y: float, w: float, h: float, r: integer, g: integer, b: integer, a: integer): void
---@field text fun(text: string, x: float, y: float, font: integer, scale: float, r: integer, g: integer, b: integer, a: integer, alignment: string | number, dropShadow: boolean, outline: boolean, wordWrap: number): void
---@field measureStringWidth fun(str: string, font: number, scale: number): number
---@field scaleformMovie fun(handle: number, x: float, y: float, w: float, h: float, r: integer, g: integer, b: integer, a: integer, unk?: number): void


------------------------------------------------------------------------