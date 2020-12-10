pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- nosedive
-- by hen

function _init()
 update_mode = 0
 update_camera = 1
 update_cave = 2
 update_helicopter = 4
 update_rotor = 8
 update_hitbox = 16
 update_debris = 32
 update_coins = 64

 update_enable(update_camera)
 update_enable(update_cave)
 update_enable(update_helicopter)
 update_enable(update_rotor)
 update_enable(update_hitbox)
 update_enable(update_coins)
 update_enable(update_debris)

 draw_mode = 0
 draw_cave = 1
 draw_helicopter = 2
 draw_rotor = 4
 draw_hitbox = 8
 draw_debris = 16
 draw_coins = 32
 draw_debug = 64

 draw_enable(draw_cave)
 draw_enable(draw_helicopter)
 draw_enable(draw_rotor)
 --draw_enable(draw_hitbox)
 draw_enable(draw_coins)
 draw_enable(draw_debris)
 draw_enable(draw_debug)

 clock_frame = 0

 camera_x1 = 1
 camera_y1 = 0
 camera_x2 = camera_x1 + 128
 camera_y2 = camera_y1 + 128
 camera_vx = 1
 camera_vy = 0
 camera_ideal_y1 = camera_y1
 camera_error_y1 = 0
 camera_offset_y1 = 0
 camera_error_count = 0

 cave_slices = fill(128, {8,118})
 cave_x1 = 1
 cave_x2 = cave_x1 + 128
 cave_y1 = cave_slices[127][1]
 cave_y2 = last(cave_slices[127])

 chunk_p = 0
 chunk_x1 = cave_x1
 chunk_x2 = chunk_x1 + 128 * camera_vx
 chunk_queue = {}

 add(chunk_queue, chunk({
  terrain_noise(8),
   terrain_rock(0.4, 0.5) + terrain_static(32) + terrain_circletest(8, -1),
   terrain_rock(0.4, 0.5) + terrain_static(32) + terrain_circletest(8, 1),
  terrain_static(184) + terrain_circletest(64, -1),
 }))

 add(chunk_queue, chunk({
  terrain_noise(8),
  terrain_noise(8) + terrain_static(112),
 }))

 if false then
  add(chunk_queue, chunk({
   terrain_noise(2),
   terrain_rock(0.4, 0.5) + terrain_static(64),
   terrain_rock(0.4, 0.5) + terrain_static(72),
   terrain_noise(2) + terrain_static(112),
  }))

  add(chunk_queue, chunk({
   terrain_noise(2)
   + terrain_descend(128)
   + terrain_sinewave(8, 2),
   terrain_rock(0.4, 0.5) + terrain_static(64) + terrain_descend(128),
   terrain_rock(0.4, 0.5) + terrain_static(72) + terrain_descend(128),
   terrain_noise(2)
   + terrain_descend(128)
   + terrain_sinewave(8, 2)
   + terrain_static(112),
  }))
 end

 coins = {}

 debug_messages = {}
 debug_color = 8

 helicopter_x = 48
 helicopter_y = 80
 helicopter_vx = camera_vx
 helicopter_vy = 0
 helicopter_inclination = "hovering"
 helicopter_gravity = 0.1
 helicopter_min_vy = -1.5
 helicopter_max_vy = 2

 hitbox_x1 = helicopter_x - 4
 hitbox_y1 = helicopter_y - 4
 hitbox_x2 = hitbox_x1 + 8
 hitbox_y2 = hitbox_y1 + 6

 rotor_engaged = false
 rotor_vy = 0
 rotor_power = -0.3

 debris = {}

 rotor_collision_frame = nil
 helicopter_collision_frame = nil

 for x = 48, 64 do
  cave_slices[x] = {
   cave_slices[x][1],
   48,
   64,
   cave_slices[x][2],
  }
 end
end

function _update60()
 clock_frame += 1

 if update(update_camera) then
  if rotor_collision_frame and helicopter_y-64>camera_y1 then
   camera_ideal_y1 = helicopter_y-64
  else
   camera_ideal_y1 = avg({
    cave_slices[32][1] + 1,
    last(cave_slices[32]),
    cave_slices[96][1] + 1,
    last(cave_slices[96]),
   }) - 64
  end

  camera_offset_y1 = camera_y1 - camera_ideal_y1
  camera_error_y1 = abs(camera_offset_y1)

  if camera_error_y1 < 1 then
   camera_error_count = 0
  else
   camera_error_count += 1
  end

  camera_vy = flr(
   camera_offset_y1
   * (camera_error_count / 256)
   * -1
  )

  camera_x1 += camera_vx
  camera_y1 += camera_vy
  camera_x2 = camera_x1 + 128
  camera_y2 = camera_y1 + 128
 end

 if update(update_cave) then
  for i = 1,camera_vx do
   for j = 1, 127 do
    cave_slices[j] = cave_slices[j+1]
   end

   cave_x1 += 1
   cave_x2 = cave_x1 + 128

   if cave_x1 < chunk_x2 then
    chunk_p = (cave_x1 - chunk_x1) / (chunk_x2 - chunk_x1)
   elseif cave_x1 == chunk_x2 then
    chunk_p = 1
   else
    dbg("nxtchunk " .. cave_y2 - cave_y1)

    chunk_p = 0
    chunk_x1 = cave_x1
    chunk_x2 = chunk_x1 + 128 * camera_vx
    cave_y1 = cave_slices[127][1]
    cave_y2 = last(cave_slices[127])

    del(chunk_queue, chunk_queue[1])

    if #chunk_queue < 1 then
     add(chunk_queue, chunk_slope(flrrnd(112)+16))
     
     --add(chunk_queue, chunk({
      --terrain_noise(2),
      --terrain_rock(0.4, 0.5) + terrain_static(64),
      --terrain_rock(0.4, 0.5) + terrain_static(72),
      --terrain_noise(2) + terrain_static(112),
     --}))
    end


   end

   next_slice = chunk_queue[1](chunk_p)

   cave_slices[128] = {}
   for p in all(next_slice) do
    add(
     cave_slices[128],
     cave_y1 + p
    )
   end
  end
 end

 if update(update_rotor) then
  rotor_engaged = btn(5)
  if rotor_engaged then
   rotor_vy = rotor_power
  else
   rotor_vy = 0
  end
 end

 if update(update_helicopter) then
  helicopter_vy += helicopter_gravity
  helicopter_vy += rotor_vy
  helicopter_vy = mid(
   helicopter_min_vy,
   helicopter_vy,
   helicopter_max_vy
  )
  helicopter_x += helicopter_vx
  helicopter_y += helicopter_vy

  if helicopter_vy > 0 and not rotor_engaged then
   helicopter_inclination = "dropping"
  elseif helicopter_vy < 0 and rotor_engaged then
   helicopter_inclination = "climbing"
  else
   helicopter_inclination = "hovering"
  end

 end

 if update(update_hitbox) then
  hitbox_x1 = helicopter_x - 4
  hitbox_y1 = helicopter_y - 4
  hitbox_x2 = hitbox_x1 + 8
  hitbox_y2 = hitbox_y1 + 6

  for x = hitbox_x1,hitbox_x2 do
   local i = x-camera_x1
   local slice = cave_slices[i]
   local roof = slice[1]
   local floor = slice[#slice]
   if hitbox_y2 < roof or hitbox_y2 > floor then
    helicopter_collision()
    goto boom
   elseif hitbox_y1 < roof then
    rotor_collision()
    goto boom
   elseif #slice > 2 then
    for j = 2,#slice-2,2 do
     local rock_y1 = slice[j]
     local rock_y2 = slice[j+1]
     if hitbox_y2 > rock_y2 and hitbox_y1 < rock_y2 then
      rotor_collision()
      goto boom
     elseif hitbox_y1 < rock_y1 and hitbox_y2 > rock_y1 then
      helicopter_collision()
      goto boom
     end
    end
   end

   for coin in all(coins) do
    if coin.hit == nil
     and (coin.x1 < x and coin.x2 > x)
     and not (coin.y2 < hitbox_y1 or coin.y1 > hitbox_y2)
     then
     coin.hit = clock_frame

     for i = 1,8 do
      add(debris, {
       color = choose({9,10}),
       x = coin.x1,
       y = coin.y1,
       vx = helicopter_vx + 1 - rnd(2),
       vy = helicopter_vy - rnd(4),
      })
     end

     goto boom
    end
   end

  end
  ::boom::
 end

 if update(update_debris) then
  for f in all(debris) do
   if not f.stop then
    f.vy += 0.1
    f.vy = mid(-4, f.vy, 4)
    f.x += f.vx
    f.y += f.vy
   end
   local i = flr(f.x) - camera_x1
   if i > 128 or i < 1 then
    f.stop = true
   elseif f.y < cave_slices[i][1] then
    f.stop = true
   elseif f.y > last(cave_slices[i]) then
    f.stop = true
   end
  end
 end

 if update(update_coins) then
  for coin in all(coins) do
   if coin.x2 < camera_x1
    or coin.hit and clock_frame - coin.hit > 16 then
    del(coins, coin)
   end
  end
  while #coins < 2 do
   local x1 = camera_x2 + 8
   local y1 = (cave_slices[128][1] + (
    cave_slices[128][2] - 
    cave_slices[128][1]
   ) / 2) - 5
   if coins[#coins] then
    x1 = coins[#coins].x1 + 64
   end
   local x2 = x1+9
   local y2 = y1+9
   add(coins, {
     x1 = x1,
     y1 = y1,
     x2 = x2,
     y2 = y2,
   })
   x1 += 64
  end
 end

end

function _draw()
 camera(camera_x1, camera_y1)

 cls(0)

 if draw(draw_coins) then
  for coin in all(coins) do
   if coin.hit then
    spr(88 + clock_frame - coin.hit, coin.x1+1, coin.y1+1)
   else
    spr(64 + loop(clock_frame, 24, 24), coin.x1+1, coin.y1+1)
   end
  end
 end

 if draw(draw_cave) then
  local rx1 = camera_x1-1
  local ry1 = cave_slices[1][1]
  local rx2 = camera_x1-1
  local ry2 = cave_slices[1][1]
  local fx1 = camera_x1-1
  local fy1 = cave_slices[1][#cave_slices[1]]
  local fx2 = camera_x1-1
  local fy2 = cave_slices[1][#cave_slices[1]]
  line(rx1, ry1, rx2, ry2, 6)
  line(fx1, fy1, fx2, fy2, 6)
  for i = 1,128 do
   local slice = cave_slices[i]
   local x = camera_x1+i-1
   rx2 = x
   ry2 = slice[1]-1
   fx2 = x
   fy2 = slice[#slice]+1
   line(x, camera_y1-1, x, ry2, 5)
   line(rx1, ry1-2, rx2, ry2-1, 1)
   line(rx1, ry1, rx2, ry2, 7)
   line(x, camera_y2+2, x, fy2, 5)
   line(fx1, fy1+2, fx2, fy2+1, 1)
   line(fx1, fy1, fx2, fy2, 7)
   rx1 = rx2
   ry1 = ry2
   fx1 = fx2
   fy1 = fy2

   if #slice > 2 then
    for j = 2,#slice-2,2 do
     line(
      x,
      slice[j],
      x,
      slice[j+1],
      5
     )
    end
   end
  end
 end

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

 if draw(draw_helicopter) then
  sspr(
   helicopter_sprite_x,
   0,
   16,
   8,
   helicopter_x - 8,
   helicopter_y - 4
  )
 end

 if draw(draw_rotor) then
  sspr(
   helicopter_sprite_x + 3,
   8 + loop(clock_frame, 32, 8) * 3,
   13,
   3,
   helicopter_x - 5,
   helicopter_y - 5
  )
  sspr(
   helicopter_sprite_x,
   8 + loop(clock_frame, 8, 8) * 3,
   3, 3,
   helicopter_x - 8,
   helicopter_y + tail_y_offset - 4
  )
 end

 if draw(draw_hitbox) then
  rect(
   hitbox_x1,
   hitbox_y1,
   hitbox_x2,
   hitbox_y2,
   11
  )

  for x = hitbox_x1,hitbox_x2 do
   local i = x-camera_x1
   pset(x, cave_slices[i][1], 11)
   pset(x, cave_slices[i][#cave_slices[i]], 11)
  end

  for coin in all(coins) do
   rect(
    coin.x1,
    coin.y1,
    coin.x2,
    coin.y2,
    11
   )
  end
 end

 if draw(draw_debris) then
  for f in all(debris) do
   pset(
    f.x,
    f.y,
    f.color
   )
  end
 end

 camera(0, 0)
 if draw(draw_debug) then
  for i,debug_message in pairs(debug_messages) do
    print(debug_message[1], 0, ((i-1)*8)+96, debug_message[2])
  end
 end
end

function rotor_collision()
  dbg("rotor collision")
  rotor_collision_frame = clock_frame

  for i = 1,32 do
   add(debris, {
    color = choose({0,0,0,0,0,0,0,0,0,5,6,6,7,11}),
    x = helicopter_x,
    y = helicopter_y + 4,
    vx = helicopter_vx*-1 + rnd(helicopter_vx*4),
    vy = 0 - rnd(2),
   })
  end

  rotor_engaged = false
  rotor_vy = 0
  helicopter_vy = 2
  helicopter_max_vy = 4
  update_disable(update_rotor)
  update_enable(update_debris)
  draw_disable(draw_rotor)
  draw_disable(draw_hitbox)
  draw_enable(draw_debris)
end

function helicopter_collision()
 dbg("helicopter collision")
 helicopter_collision_frame = clock_frame

 for i = 1,128 do
  add(debris, {
   color = choose({0,0,0,0,0,3,4,11}),
   x = helicopter_x,
   y = helicopter_y,
   vx = helicopter_vx + (-1+rnd(2)),
   vy = 0 - rnd(2),
  })
 end

 rotor_engaged = false
 rotor_vy = 0
 helicopter_vy = 0
 helicopter_vx = 0
 update_disable(update_camera)
 update_disable(update_cave)
 update_disable(update_helicopter)
 update_disable(update_hitbox)
 update_enable(update_debris)
 draw_disable(draw_rotor)
 draw_disable(draw_hitbox)
 draw_disable(draw_helicopter)
 draw_enable(draw_debris)
end

function dbg(message)
 while #debug_messages >= 4 do
  del(debug_messages, debug_messages[1])
 end
 debug_color += 1
 if debug_color > 15 then
  debug_color = 8
 end
 add(debug_messages, { message, debug_color })
end

function update(flag)
 return (update_mode & flag) != 0
end

function update_enable(flag)
 update_mode |= flag
end

function update_disable(flag)
 update_mode &= ~flag
end

function draw(flag)
 return (draw_mode & flag) != 0
end

function draw_enable(flag)
 draw_mode |= flag
end

function draw_disable(flag)
 draw_mode &= ~flag
end

function loop(n, m, o)
 return flr(n % m / flr(m / o))
end

function avg(l)
 local t = 0
 for i in all(l) do
  t += i
 end
 return t / #l
end

function fill(n, v)
 local tbl = {}
 for i = 1,n do
  add(tbl, v)
 end
 return tbl
end

function flrrnd(n)
 return flr(rnd(n))
end

function last(t)
 return t[#t]
end

function chunk(terrains)
 return function(p)
  local values = {}
  local slice = {}
  for t in all(terrains) do
   local v = t(p)
   if v ~= nil then
    add(values, t(p))
   end
  end
  sort(values)
  return values
 end
end

function chunk_slope(height)
 local h = cave_y2 - cave_y1
 local d = (h-height)/2
 dbg(height .. " h: " .. h .. ", d: " .. d)
 return chunk({
  terrain_linear(d, 1),
  terrain_static(h) + terrain_linear(d, -1),
 })
end

function terrain(fn)
 local g = { fn }
 setmetatable(g, {
  __add = function(g1, g2)
   add(g1, g2[1])
   return g1
  end,
  __call = function(_, p)
   local o = 0
   for f in all(g) do
    local v = f(p)
    if v == nil then
     return nil
    else
     o += f(p)
    end
   end
   return o
  end,
 })
 return g
end

function terrain_circletest(r, d)
 return terrain(
  function(p)
   local y = sqrt(r^2 - ((-1+(p*2))*r)^2)
   return y*d - r
  end
 )
end

function terrain_pythagstep(r, d, s)
 return terrain(
  function(p)
   if s == -1 then
    p = 1 - p
   end
   local a = flr(r*p)
   local c = r
   local py = sqrt(c^2 - a^2)
   local y = r - py
   if s == -1 and d == 1 then
    y = py + 0
   elseif s == -1 and d == -1 then
    y = r - r - r + y
   elseif d == -1 then
    y = py - r
   end
   return y
  end
 )
end

function terrain_linear(y, d)
 return terrain(
  function(p)
   return p * y * d
  end
 )
end

function terrain_descend(depth)
 return terrain(
  function(p)
   return p * depth
  end
 )
end

function terrain_fudge(n)
 return terrain(
  function(p)
   if p == 1 then
    return 0
   else
    return n
   end
  end
 )
end

function terrain_sinewave(magnitude, frequency)
 return terrain(
  function(p)
   return sin(p * frequency) * magnitude
  end
 )
end

function terrain_static(y)
 return terrain(
  function(p)
   return y
  end
 )
end

function terrain_rock(from, to)
 return terrain(
  function(p)
   if p > from and p < to then
    return 0
   end
  end
 )
end

function terrain_noise(n)
 return terrain(
  function(p)
   if p == 1 then
    return 0
   else
    return flrrnd(n) - n/2
   end
  end
 )
end

function sort(a)
 for i=1,#a do
  local j = i
  while j > 1 and a[j-1] > a[j] do
   a[j],a[j-1] = a[j-1],a[j]
   j = j - 1
  end
 end
end

function choose(table)
 return table[flrrnd(#table) + 1]
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
00000000000000000000000000000000000000000500000005500000005500000000000000000000000000000000000000000000000000000000000000000000
00999900009999000099990000999900509999005099990000999900509999000099990000999900009999000099990000999900009999000099990000999900
09aaaa9009aaaa9009aaaa9059aaaa9059aaaa9009aaaa9059aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa90
09a99a9009a99a9059a99a9059a99a9009a99a9059a99a9009a99a9009a99a9009a99a9009a99a9009aa9a9009a9aa9009a99a9009a09a9009a00a9009a00a90
09a9aa9059a9aa9059a9aa9009a9aa9059a9aa9009a9aa9009a9aa9009a9aa9009a9aa9009aa9a9009a99a9009a99a9009a0aa9009a0aa9009a0aa9009a00a90
59aaaa9059aaaa9009aaaa9059aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa9009aaaa90
50999900009999005099990000999900009999000099990000999900009999000099990000999900009999000099990000999900009999000099990000999900
00500000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000aaaa0000aaaa00000aa000000aa0000000a00000000a000000000000000000000000000000000000000000000000000000000000000000
00999900009999000a9999a00a0000a00a0000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090aa09009000090a900009aa000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09a00a9009000090a900009aa000000aa000000aa000000aa0000000000000000000000000000000000000000000000000000000000000000000000000000000
09a00a9009000090a900009aa000000aa000000aa000000a0000000a000000000000000000000000000000000000000000000000000000000000000000000000
090aa09009000090a900009aa000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900009999000a9999a00a0000a00a0000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000aaaa0000aaaa00000aa000000aa000000a0000000000000000000000000000000000000000000000000000000000000000000000000000
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
011000000c0430000000000000000000000000000000000024625000000000000000000000000000000000000c043000000000000000000000000000000000002462500000000000000000000000000000000000
__music__
00 00424344
00 01424344
00 02424344
00 03424344
03 04054344
03 08424344

