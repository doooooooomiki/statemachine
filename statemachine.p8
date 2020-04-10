pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

local PRESS_UP, PRESS_DOWN, PRESS_X, NO_INPUT = 2, 3, 5, 666

local Standing_State, 
      Falling_State, 
      Jumping_State, 
      Ducking_State = {}, {}, {}, {} -- heroine's state pattern 

local Heroine_States = {} -- object pool for heroine's states

Standing_State.__index = Standing_State

function Standing_State:new()
    return setmetatable({state = "standing"}, self)
end

function Standing_State:handle_input(heroine, input)
    if input == PRESS_X then
        heroine.state = Heroine_States.jumping_state
        heroine.state:enter()
    elseif input == PRESS_DOWN then
        heroine.state = Heroine_States.ducking_state
        heroine.state:enter()
        heroine.w = heroine.ducking_w
        heroine.h = heroine.ducking_h
    end
end

function Standing_State:update(heroine)

end

function Standing_State:enter()

end

Jumping_State.__index = Jumping_State

function Jumping_State:new()
    local o = setmetatable({state = "jumping"}, self)
    o.initial_v = -1
    o.g_acc = 0.03125 -- go up in 32 frames
    return o
end

function Jumping_State:handle_input(heroine, input)
    if input == PRESS_DOWN then
        heroine.state = Heroine_States.standing_state
        heroine.w = heroine.standing_w
        heroine.h = heroine.standing_h
    end 

    if input == PRESS_X then
        
    end
end

function Jumping_State:update(heroine)
    if self.initial_v < 0 then
        self.initial_v += self.g_acc 
        heroine.y += self.initial_v 
    end

    if self.initial_v >= 0 then
        heroine.state = Heroine_States.falling_state
        heroine.state:enter()
    end
end

function Jumping_State:enter()
    self.initial_v = -1 
end

Falling_State.__index = Falling_State

function Falling_State:new()
    local o = setmetatable({state = "falling"}, self)
    o.initial_v = 0
    o.max_fall = 2
    o.g_dcc = 0.125 -- go down in 16 frames
    o.j_buffer = 0
    return o
end

function Falling_State:handle_input(heroine, input)
    if input == PRESS_X then
        self.j_buffer = 8
    end
end

function Falling_State:update(heroine)
    self.initial_v = min(self.initial_v + self.g_dcc, self.max_fall)
    heroine.y += self.initial_v

    if self.j_buffer > 0 then
        self.j_buffer -= 1
    end

    if heroine.y > 64 then 
        heroine.y = 64 
        if self.j_buffer > 0 then
            heroine.state = Heroine_States.jumping_state
        else
            heroine.state = Heroine_States.standing_state
        end
        heroine.state:enter()
    end
end

function Falling_State:enter()
    self.initial_v = 0
end

Ducking_State.__index = Ducking_State

function Ducking_State:new()
    return setmetatable({state = "ducking"}, self)
end

function Ducking_State:handle_input(heroine, input)
     if input == PRESS_UP then
        heroine.state = Heroine_States.standing_state
        heroine.w = heroine.standing_w
        heroine.h = heroine.standing_h
    end
end

function Ducking_State:update(heroine)

end

function Ducking_State:enter()

end

Heroine_States.standing_state = Standing_State:new()
Heroine_States.jumping_state = Jumping_State:new()
Heroine_States.falling_state = Falling_State:new()
Heroine_States.ducking_state = Ducking_State:new()

local Heroine = {}
Heroine.__index = Heroine

function Heroine:new(x, y)
    local o = setmetatable({}, self)
    o.state = Heroine_States.standing_state
    o.x, o.y = x, y
    o.w, o.h = 8, 8 
    o.standing_w, o.standing_h = 8, 8
    o.ducking_w, o.ducking_h = 12, 4
    o.jumping_w, o.jumping_h = 6, 10 
    o.c = 9
    return o
end

function Heroine:handle_input(input) 
    self.state:handle_input(self, input)
end

function Heroine:update()
    self.state:update(self)
end

function Heroine:draw()
    rectfill(self.x, self.y, self.x + self.w, self.y + self.h, self.c)
end

function _init()
    cls()
    heroine = Heroine:new(64, 64)
end

function _update60()
    if btnp(PRESS_UP) then 
        heroine:handle_input(PRESS_UP)
    elseif btnp(PRESS_DOWN) then
        heroine:handle_input(PRESS_DOWN)
    elseif btnp(PRESS_X) then
        heroine:handle_input(PRESS_X)
    else
        heroine:handle_input(NO_INPUT)
    end

    heroine:update()
end

function _draw()
    cls()
    rectfill(50, 48, 100, 75, 14)
    heroine:draw()
    rectfill(50, 73, 100, 75, 3)
    print(heroine.state.state)
end


__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
