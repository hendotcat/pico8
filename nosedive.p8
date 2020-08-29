pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
  init_camera()
  init_clock()
  init_coins()
  init_cave()
  init_level()
  init_gravity()
  init_helicopter()
  init_hitbox()
  init_collision()
  init_rotor()
  init_smoke()
  speed(1)
end

function init_camera()
  camera_position = xy(0, 0)
  camera_velocity = xy(1, 0)
end

function init_cave()
  cave_velocity = xy(1, 0)
  cave_floor = {}
  cave_floor_blur_colors = {}
  cave_floor_blur_heights = {}
  cave_floor_edge_colors = {}
  cave_floor_edge_heights = {}
  cave_roof = {}
  cave_roof_blur_colors = {}
  cave_roof_blur_heights = {}
  cave_roof_edge_colors = {}
  cave_roof_edge_heights = {}

  for x = 0, 127 do
    add(cave_floor, xy(x, 119))
    add(cave_floor_blur_colors, 1)
    add(cave_floor_blur_heights, 0)
    add(cave_floor_edge_colors, 7)
    add(cave_floor_edge_heights, 0)
    add(cave_roof, xy(x, 8))
    add(cave_roof_blur_colors, 1)
    add(cave_roof_blur_heights, 0)
    add(cave_roof_edge_colors, 7)
    add(cave_roof_edge_heights, 0)
  end

end

function init_clock()
  clock_frame = 0
end

function init_coins()
  coins = {}
end

function init_collision()
  collision_point = nil
end

function init_gravity()
  gravity_velocity = xy(0, 0.1)
end

function init_helicopter()
  helicopter_inclination = "hovering"
  helicopter_position = xy(48, 80)
  helicopter_velocity = xy(1, 0)
end

function init_hitbox()
  hitbox_offset = xy(-4, -4)
  hitbox_box = box(helicopter_position + hitbox_offset, xy(8, 8))
end

function init_level()

  level_queue = {
    straight(),
    ubend(),
    straight(),
    ubend(),
  }

  -- level_queue = {
  --   "flat",
  --   "blocks",
  --   "blocks",
  --   "blocks",
  --   "flat",
  --   "ubend",
  --   "ubend",
  --   "ubend",
  --   "ubend",
  --   "flat",
  --   "flat",
  --   "ubend",
  --   "ubend",
  --   "ubend",
  --   "ubend",
  --   "flat",
  -- }

  next_level()

  for x = 1, 128 do
    local level_slice = pump_level()
    local rp = xy(x, level_start_roof + level_slice.roof)
    local fp = xy(x, level_start_floor + level_slice.floor)
    add_cave(x, rp, fp)

    if level_slice.coin ~= nil then
      printh("ADD")
      local cp = xy(x, rp.y + ((fp.y - rp.y) * level_slice.coin))
      printh(cp.x)
      printh(cp.y)
      add(coins, cp)
    end
  end
end

function init_rotor()
  rotor_engaged = false
  rotor_velocity = xy(0, 0)
end

function init_smoke()
  smoke_puffs = {}
end
-->8
function _update60()
  update_clock()
  update_camera()
  update_cave()
  update_level()
  update_coins()
  update_rotor()
  update_helicopter()
  update_hitbox()
  update_collision()
  update_smoke()
end

function update_camera()
  local last_roof = cave_roof[127 - 16].y
  local last_floor = cave_floor[127 - 16].y

  local camera_y1 = camera_position.y
  local camera_y2 = camera_position.y + 127

  local camera_ok = (
    camera_y1 < last_roof
    and camera_y2 > last_floor
  )

  if camera_ok then
  else
    --camera_position.y = cave_roof[127].y - 8
    --camera_position.y += cave_roof[127].y - cave_roof[1].y / 128
    --camera_velocity.y = 0.5
  end

  -- local ideal_camera_depth = ((last_roof + last_floor) / 2) - 64
  -- local camera_offset = camera_position.y - ideal_camera_depth
  -- local camera_wrongness = abs(camera_offset)
  -- local camera_too_wrong = camera_wrongness > 1
  -- local camera_must_move = camera_too_wrong
  -- local camera_can_stabilize = cave_roof[126].y == cave_roof[127].y
  -- local camera_very_close = (
  --   (flr(camera_position.y) == flr(ideal_camera_depth))
  --   or (flr(camera_position.y) == flr(ideal_camera_depth) + 1)
  -- )

  -- if camera_very_close and camera_can_stabilize then
  --   camera_velocity.y = 0
  -- elseif camera_must_move then
  --   local ideal_new_camera_velocity = camera_offset * -1
  --   local camera_velocity_offset = camera_velocity.y - ideal_new_camera_velocity
  --   local camera_velocity_change = abs(camera_velocity_offset)
  --   camera_velocity.y -= camera_velocity_offset / 512
  -- else
  --   camera_velocity.y = 0
  -- end

  --camera_velocity.y = min(3, max(-3, camera_velocity.y))

  camera_position.x += camera_velocity.x
  camera_position.y += camera_velocity.y
  --camera_position.y += camera_velocity.y
  -- camera_position.x = cave_roof[1].x
end

function update_cave()
  for i = 1, 127 do
    local j = min(128, i + cave_velocity.x)
    cave_roof[i].x = cave_roof[j].x
    cave_roof[i].y = cave_roof[j].y
    cave_floor[i].x = cave_floor[j].x
    cave_floor[i].y = cave_floor[j].y
    cave_floor_blur_heights[i] = cave_floor_blur_heights[j]
    cave_floor_edge_heights[i] = cave_floor_edge_heights[j]
    cave_roof_blur_heights[i] = cave_roof_blur_heights[j]
    cave_roof_edge_heights[i] = cave_roof_edge_heights[j]

    if helicopter_position.x - camera_position.x > i then
      cave_roof_edge_colors[i] = 1
      cave_floor_edge_colors[i] = 1
    else
      if helicopter_position.y - cave_roof[i].y - (i/2) < 8 then
        cave_roof_edge_colors[i] = 7
      else
        cave_roof_edge_colors[i] = 1
      end
  
      if cave_floor[i].y - helicopter_position.y - (i/2) < 8 then
        cave_floor_edge_colors[i] = 7
      else
        cave_floor_edge_colors[i] = 1
      end
    end
  end


end

function update_clock()
  clock_frame += 1
end

function update_coins()
  for coin in all(coins) do
    if coin.x < camera_position.x then
      del(coins, coin)
    end
  end
end

function update_collision()
  collision_point = nil

  for i = 1, hitbox_box.size.x do
    local j = hitbox_box.position.x - camera_position.x + (hitbox_box.size.x - i)

    local roof = cave_roof[j]
    if hitbox_box:contains(roof) then
      collision_point = roof
      break
    end

    local floor = cave_floor[j]
    if hitbox_box:contains(floor) then
      collision_point = floor
      break
    end
  end

  if collision_point ~= nil then
    printh("boom")

    camera(camera_position.x, camera_position.y)
    line(
      helicopter_position.x,
      helicopter_position.y,
      collision_point.x,
      collision_point.y,
      8
    )

    local dx = collision_point.x - helicopter_position.x
    local dy = -(collision_point.y - helicopter_position.y)
    local angle = atan2(dx, dy)


    local p = xy(
      helicopter_position.x + 8 * cos(angle),
      helicopter_position.y - 8 * sin(angle)
    )

    -- circ(p.x, p.y, 2, 8)

    if collision_point:below(helicopter_position) then
      helicopter_velocity.y = -2
    else
      helicopter_velocity.y = 2
    end
  end
end

function update_helicopter()
  helicopter_velocity += rotor_velocity + gravity_velocity
  helicopter_velocity.y = mid(-1.5, helicopter_velocity.y, 1.9)
  helicopter_position += helicopter_velocity

  if helicopter_velocity.y > 0 and not rotor_engaged then
    helicopter_inclination = "dropping"
  elseif helicopter_velocity.y < 0 and rotor_engaged then
    helicopter_inclination = "climbing"
  else
    helicopter_inclination = "hovering"
  end
end

function update_hitbox()
  hitbox_box:move(helicopter_position + hitbox_offset)
end

function update_level()
  for i = 1, cave_velocity.x do
    local li = 128 - i + 1
    local lx = cave_roof[128 - i].x + 1
    local level_slice = pump_level()

    local rp = xy(lx, level_start_roof + level_slice.roof)
    local fp = xy(lx, level_start_floor + level_slice.floor)

    add_cave(li, rp, fp)

    if level_slice.coin ~= nil then
      local cp = xy(lx, rp.y + ((fp.y - rp.y) * level_slice.coin))
      add(coins, cp)
    end
  end
end

function update_rotor()
  rotor_engaged = btn(5)
  if rotor_engaged then
    rotor_velocity.y = -0.3
  else
    rotor_velocity.y = 0
  end
end

function update_smoke()
  for i, puff in pairs(smoke_puffs) do
    puff.position.x += puff.velocity.x / 16
    puff.position.y += puff.velocity.y / 8
    puff.age += 1
    if puff.age % 20 == 0 then
      puff.radius -= 1
    end
    if puff.radius < 0 then
      del(smoke_puffs, smoke_puffs[1])
    end
 end

 if clock_frame % 4 == 0 then
    local puff_radius = 0
    if rotor_engaged then
      puff_radius = 1
    end
    add(smoke_puffs, {
      position = helicopter_position - xy(8, 0),
      velocity = helicopter_velocity,
      radius = puff_radius,
      age = 0,
    })
 end
end



-->8
function _draw()
  camera(camera_position.x, camera_position.y)
  draw_cave()
  draw_coins()
  draw_smoke()
  draw_helicopter()
  --draw_hitbox()

  camera(0, 0)
  draw_overlay()
end

function draw_cave()
  local camera_top = camera_position.y - 2
  local camera_bottom = camera_position.y + 128 + 4

  for i = 1, 128 do
    local x = i + camera_position.x - 1
    local roof = cave_roof[i].y
    local floor = cave_floor[i].y

    line(x, roof, x, floor, 0)

    line(x, camera_top, x, roof, 5)
    line(x, roof, x, roof - cave_roof_blur_heights[i], cave_roof_blur_colors[i])
    line(x, roof, x, roof - cave_roof_edge_heights[i], cave_roof_edge_colors[i])

    line(x, floor, x, camera_bottom, 5)
    line(x, floor, x, floor + cave_floor_blur_heights[i], cave_floor_blur_colors[i])
    line(x, floor, x, floor + cave_floor_edge_heights[i], cave_floor_edge_colors[i])
  end
end

function draw_coins()
  for coin in all(coins) do
    spr(64 + loop(clock_frame, 24, 24), coin.x, coin.y)
  end
end

function draw_helicopter()
  local helicopter_sprite_column = ({
    hovering = 1,
    dropping = 2,
    climbing = 3,
  })[helicopter_inclination]

  local helicopter_sprite_x = (helicopter_sprite_column - 1) * 16

  local tail_y_offset = ({
    hovering = 2,
    dropping = 0,
    climbing = 3,
  })[helicopter_inclination]

  sspr(
    helicopter_sprite_x,
    0,
    16,
    8,
    helicopter_position.x - 8,
    helicopter_position.y - 4
  )

  sspr(
    helicopter_sprite_x + 3,
    8 + loop(clock_frame, 32, 8) * 3,
    13,
    3,
    helicopter_position.x - 5,
    helicopter_position.y - 5
  )

  sspr(
    helicopter_sprite_x,
    8 + loop(clock_frame, 8, 8) * 3,
    3, 3,
    helicopter_position.x - 8,
    helicopter_position.y + tail_y_offset - 4
  )
end

function draw_hitbox()
  rect(
    hitbox_box.x1,
    hitbox_box.y1,
    hitbox_box.x2,
    hitbox_box.y2,
    11
  )

  for i = 1, hitbox_box.size.x do
    pset(
      hitbox_box.position.x + i,
      hitbox_box.position.y + hitbox_box.size.y,
      11
    )

    local roof_color = 11
    local floor_color = 11
    if hitbox_box:contains(cave_roof[hitbox_box.position.x - camera_position.x + i]) then
      roof_color = 8
    end
    if hitbox_box:contains(cave_floor[hitbox_box.position.x - camera_position.x + i]) then
      floor_color = 8
    end

    line(
      hitbox_box.position.x + i,
      cave_roof[hitbox_box.position.x - camera_position.x + i].y,
      hitbox_box.position.x + i,
      cave_roof[hitbox_box.position.x - camera_position.x + i].y - 1,
      roof_color
    )

    line(
      hitbox_box.position.x + i,
      cave_floor[hitbox_box.position.x - camera_position.x + i].y,
      hitbox_box.position.x + i,
      cave_floor[hitbox_box.position.x - camera_position.x + i].y + 1,
      floor_color
    )
  end
end

function draw_overlay()
  print(stat(1), 0, 0, 7)
end

function draw_smoke()
  for i, puff in pairs(smoke_puffs) do
    circ(puff.position.x, puff.position.y, puff.radius, 7)
  end
end


-->8
function add_cave(ci, new_roof, new_floor)
  cave_roof[ci] = new_roof
  cave_floor[ci] = new_floor

  local from = max(1, ci - 4)
  local to = min(127, ci + 4)

  for i = from, to do
    local roof = cave_roof[i].y or new_roof.y
    local floor = cave_floor[i].y or new_floor.y

    cave_floor_blur_heights[i] = tminmax(max, {
      floor,
      tgad(cave_floor, i - 1, 1, floor + 2),
      tgad(cave_floor, i - 2, 1, floor + 2),
      tgad(cave_floor, i + 1, 1, floor + 2),
      tgad(cave_floor, i + 2, 1, floor + 2),
    }) - floor

    cave_floor_edge_heights[i] = tminmax(max, {
      floor,
      tgad(cave_floor, i - 1, 0, floor),
      tgad(cave_floor, i + 1, 0, floor),
    }) - floor

    cave_roof_blur_heights[i] = roof - tminmax(min, {
      roof,
      tgad(cave_roof, i - 1, -1, roof),
      tgad(cave_roof, i - 2, -1, roof),
      tgad(cave_roof, i + 1, -1, roof),
      tgad(cave_roof, i + 2, -1, roof),
    })

    cave_roof_edge_heights[i] = roof - tminmax(min, {
      roof,
      tgad(cave_roof, i - 1, 0, roof),
      tgad(cave_roof, i + 1, 0, roof),
    })
  end
end

function speed(n)
  camera_velocity.x = n
  cave_velocity.x = n
  helicopter_velocity.x = n
end

function loop(n, m, o)
  return flr(n % m / flr(m / o))
end

function xy(x, y)
  local p = { x = x or 0, y = y or 0 }
  
  setmetatable(p, {
    __add = function(p1, p2)
      return xy(p1.x + p2.x, p1.y + p2.y)
    end,

    __sub = function(p1, p2)
      return xy(p1.x - p2.x, p1.y - p2.y)
    end,

    __lt = function(p1, p2)
      return p1.x < p2.x and p1.y < p2.y
    end,

    __gt = function(p1, p2)
      return p1.x > p2.x and p1.y > p2.y
    end,
  })

  function p:angle(p2)
    return atan2(p2.x - self.x, -(p2.y - self.y))
  end

  function p:above(p2)
    return self.y < p2.y
  end

  function p:below(p2)
    return self.y > p2.y
  end

  return p
end

function box(position, size)
  local box = {
    position = position,
    size = size,
    x1 = position.x,
    x2 = position.x + size.x,
    y1 = position.y,
    y2 = position.y + size.y,
  }

  function box:move(p)
    self.position = p
    self.x1 = p.x
    self.x2 = p.x + size.x
    self.y1 = p.y
    self.y2 = p.y + size.y
  end

  function box:contains(p)
    return p > self.position and p < self.position + self.size
  end

  return box
end

function tgad(t, g, a, d)
  if t[g] == nil or t[g].y == nil then
    return d
  else
    return t[g].y + a
  end
end

function tminmax(fn, t)
  if #t == 0 then
    return nil
  elseif #t == 1 then
    return t[1]
  else
    local m = t[1]
    for i = 2, #t do
      m = fn(m, t[i])
    end
    return m
  end
end

levels = {
  flat = function()
    camera_velocity.y = 0
    return {
      roof = noise(2),
      floor = noise(2),
    }
  end,

  ubend = function()
    camera_velocity.y = 0.5
    return {
      roof = noise(1) + sinwave(8, 2) + fudge(32) + descend(64),
      floor = noise(1) + sinwave(8, 2) + fudge(-32) + descend(64)
    }
  end,

  blocks = function()
    return {
      roof = squarewave(32, 1) + fudge(8) + noise(8),
      floor = sinwave(16, 1) + fudge(-32) + noise(8),
    }
  end,
}

function next_level()
  printh("next level")
  camera_velocity.y = 0
  level_fn = level_queue[1]
  del(level_queue, level_fn)
  level_distance = 0
  level_progress = 0
  level_start_roof = cave_roof[127].y
  level_start_floor = cave_floor[127].y
  level_object = level_fn()
  level_length = level_object.length
  level_coins = level_object.coins
end

function pump_level()
  if level_progress >= 1 then
    next_level()
  end

  level_distance += 1
  if level_distance == level_length then
    level_progress = 1
  else
    level_progress = level_distance / level_length
  end

  local roof = level_object.roof(level_progress)
  local floor = level_object.floor(level_progress)
  local coin = nil

  if #level_coins > 0 then
    if level_coins[1][1] <= level_progress then
      coin = level_coins[1][2]
      del(level_coins, level_coins[1])
    end
  end

  return {
    roof = roof,
    floor = floor,
    coin = coin,
  }
end

function generator(fn)
  local g = { fn }

  setmetatable(g, {
    __add = function(g1, g2)
      add(g1, g2[1])
      return g1
    end,

    __call = function(_, p)
      local o = 0
      for f in all(g) do
        o += f(p)
      end
      return o
    end,
  })

  return g
end

function flat()
  return generator(function(p)
    return 0
  end)
end

function noise(n)
  return generator(function(p)
    if p == 1 then
      return 0
    else
      return flr(rnd(n)) - n/2
    end
  end)
end

function fudge(n)
  return generator(function(p)
    if p == 1 then
      return 0
    else
      return n
    end
  end)
end

function sinwave(magnitude, frequency)
  return generator(function(p)
    return sin(p * frequency) * magnitude
  end)
end

function squarewave(magnitude, frequency)
  return generator(function(p)
    return max(0, ceil(sin(p * frequency))) * magnitude
  end)
end

function descend(depth)
  return generator(function(p)
    return p * depth
  end)
end

function straight()
  return function()
    return {
      length = 128,
      roof = noise(2),
      floor = noise(2),
      coins = {{ 0.9, 0.5 }},
    }
  end
end

function ubend()
  return function()
    local length = 256
    local descent = 128
    camera_velocity.y = descent / length
    return {
      length = length,
      roof = noise(1) + sinwave(8, 4) + fudge(24) + descend(descent),
      floor = noise(1) + sinwave(8, 4) + fudge(-24) + descend(descent),
      coins = {
        { 0.2, 0.8 },
        { 0.3, 0.2 },
        { 0.45, 0.8 },
        { 0.55, 0.2 },
        { 0.7, 0.8 },
        { 0.8, 0.2 },
        { 0.95, 0.8 },
      },
    }
  end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000050000000300000005000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000003330000003bb000333300000000000003333660000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300003335536600033b3b3b35530000000000333553333000000000000000000000000000000000000000000000000000000000000000000000000000000000
03bb3b3b3bb33330055333333bb3660003003b3b3bb3333000000000000000000000000000000000000000000000000000000000000000000000000000000000
033b333333333330000555333333333003bb33333333555000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555555333355500000005555333330033b55553355000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555500000000000005555500055500005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000000000000006005660000000000600000000000666500000000000000000000000000000000000000000000000000000000000000000000000000000000
06056666666666650600006666600000060000006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600000000000000060000000666665006566660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000000000000605560000000000060000000000666600000000000000000000000000000000000000000000000000000000000000000000000000000000
06055666666666660600006666600000060000006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000000000000600000000666666060556660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600000000000000065660000000000006000000000666500000000000000000000000000000000000000000000000000000000000000000000000000000000
06056666666666650600006666600000060000006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000000000000006000000000666665600566660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000006660000000000000000000000665500000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666556660006666600000666000006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000666655000666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000000000000006005660000000000600000000000666500000000000000000000000000000000000000000000000000000000000000000000000000000000
06056666666666650600006666600000060000006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600000000000000060000000666665006566660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000000000000605560000000000060000000000666600000000000000000000000000000000000000000000000000000000000000000000000000000000
06055666666666660600006666600000060000006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000000000000600000000666666060556660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600000000000000065660000000000006000000000666500000000000000000000000000000000000000000000000000000000000000000000000000000000
06056666666666650600006666600000060000006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000000000000006000000000666665600566660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000006660000000000000000000000665500000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666556660006666600000666000006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000666655000666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05055000005055000005055000005050000005000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900009999000099990000999905009999050099990000999905009999000099990000999900009999000099990000999900009999000099990000999900
09aaaa9009aaaa9009aaaa9009aaaa9009aaaa9509aaaa9509aaaa9009aaaa9509aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa90
09a99a9009a99a9009a99a9009a99a9009a99a9009a99a9509a99a9509a99a9009a99a9509a99a9009a99a9009a99a9009a99a9009a99a9009a99a9009a99a90
09a9aa9009a9aa9009a9aa9009a9aa9009a9aa9009a9aa9009a9aa9509a9aa9509a9aa9009a9aa9509a9aa9009a9aa9009a9aa9009a9aa9009a9aa9009a9aa90
09aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa9509aaaa9509aaaa9009aaaa9509aaaa9009aaaa9009aaaa9009aaaa9009aaaa90
00999900009999000099990000999900009999000099990000999900009999000099990500999905009999000099990500999900009999000099990050999900
00000000000000000000000000000000000000000000000000000000000000000000000000000050000005500000550000055050005505000550500005050000
00000000000000000000000000000000000000000500000005500000005500005555555500000000000000000000000000000000000000000000000000000000
00999900009999000099990000999900509999005099990000999900509999005555555500000000000000000000000000000000000000000000000000000000
09aaaa9009aaaa9009aaaa9059aaaa9059aaaa9009aaaa9059aaaa9009aaaa905555555500000000000000000000000000000000000000000000000000000000
09a99a9009a99a9059a99a9059a99a9009a99a9059a99a9009a99a9009a99a905555555500000000000000000000000000000000000000000000000000000000
09a9aa9059a9aa9059a9aa9009a9aa9059a9aa9009a9aa9009a9aa9009a9aa905555555500000000000000000000000000000000000000000000000000000000
59aaaa9059aaaa9009aaaa9059aaaa9009aaaa9009aaaa9009aaaa9009aaaa905555555500000000000000000000000000000000000000000000000000000000
50999900009999005099990000999900009999000099990000999900009999005555555500000000000000000000000000000000000000000000000000000000
00500000050000000000000000000000000000000000000000000000000000005555555500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07cccc70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7cccccc7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7cccccc7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7cccccc7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7cccccc7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07cccc70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08666680000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
86666668000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
86666668000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
86666668000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
86666668000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08666680000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000006060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01200000097500e750097500e75011750117530e7500e75009753117500e75011750157501575311750117500975315750117501575018750187530c7500c75009753117500c7531175015750157501575315100
012000000c750117500c75011750157501575311750117500c75315750117501575018750187531575015750107531875015750187501c7501c75310750107500c75315750107501575019750197532170021100
01200000157551675013752167551a7501a7500000000000157551675013752167551b7501b7501570015750157550e7001a750157521a7551d7501d7501d7500000000000000000000000000000000000000000
01200000157551675013752167551a7501a7500c0000c000157551675013752167551c7501c750157001575015755157551a7551e7552175021750217502d7000000000000000000000000000000000000000000
010a00000c013006050060500605006150060517615176050c013006160061500605006150060517615176050c013006050060500605006150060500605006050c01300616006150060500615006051761517605
010a00002151300600006000060000600006001760017600095330e531095310e53311530115330e5350e5351d513027000e7001a70009700117000e7001a70009533115310e5311153315530155331153511535
01200000091540e150091500e15011150111530e1500e15009153111500e15011150151501515311150111500915315150111501515018150181530c1500c15009153111500c1531115015150151501515315100
01200002007460c746000070000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004
__music__
00 00424344
00 01424344
00 02424344
00 03424344
03 04054344

