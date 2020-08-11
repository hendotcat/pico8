pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
dark=false

function _update()
  if btnp(4) or btnp(5) then
    dark = not dark
  end
end

function _draw()
		palt(0, true)
		palt(11, false)
  if dark then
    cls(1)
    --pal(1, 12)
    --pal(1, 1)
    --pal(8, 8)
    --pal(12, 12)
    --pal(15, 12)
    palt(11, true)
  else
    cls(7)
    --pal(1, 12)
    --pal(8, 8)
    --pal(11, 1)
    --pal(12, 12)
    --pal(15, 12)
  end
  sspr(
    0, 0, 128, 64,
    0, 32, 128, 64
  )
  
  if dark then
    sspr(
      0, 103, 50, 25,
      76, 31, 50, 25
    )
  else
    sspr(
      0, 71, 50, 25,
      76, 31, 50, 25
    )
  end
end

__gfx__
00000000888888888880000000008888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888888880000000008888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000888888880000000000008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000008888880000000000008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000008888880000000000008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000008888880000000000008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000008888880000000000008888888800888800008888888800008888000008888000000000000000000000000000000000000000000000000000000
00000000000008888880000000000008888888800888800008888888800008888000008888000000000000000000000000000000000000000000000000000000
00000000000008888880000000000008888888800888800888888888888008888000008888000000000000000000000000000000000000000000000000000000
00000000000008888880000000000008888888800888800888888888888008888000008888000000000000000000000000000000000000000000000000000000
00000000000008888880000000000000088888800008800008800000000000088000008888000000000000000000000000000000000000000000000000000000
00888888888888888880000000000000088888800008800008800000000000088000008888000000000000000000000000000000000000000000000000000000
00888888888888888888888888888888888888800888800888888888888008888888888888000000000000000000000000000000000000000000000000000000
00008888888888888888888888888888888888800888800888800888888008888888888888000000000000000000000000000000000000000000000000000000
00000000000008888888888888888888888888800888800888800888888008888880008888000000000000000000000000000000000000000000000000000000
00000000000008888888888888888888888888800888800888800888888008888880008888000000000000000000000000000000000000000000000000000000
00000000000008888888888888888888888888800888800888800008888008888000008888000000000000000000000000000000000000000000000000000000
00000000088888888888888888888888888888800888800888800008888008888000008888000000000000000000000000000000000000000000000000000000
00000000088888800000000008888888888888000888800888800008888008888000008888000000000000000000000000000000000000000000000000000000
00000000088888800000000008888888888888000888800888800008888008888000008888000000000000000000000000000000000000000000000000000000
00000000088888800000000000008888888888000888800888800008888008888000008888000000000000000000000000000000000000000000000000000000
00000000088888800000000000008888888888000888800888800008888008888000008888000000000000000000000000000000000000000000000000000000
00000000088880000000000000000088888888000888800008888888800008888000008888000000000000000000000000000000000000000000000000000000
00000000088880000000000000000088888880000888800008888888800008888000008888000000000000000000000000000000000000000000000000000000
00000000088880000000000000000088888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088880000000000000000088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088880000000000000000088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088880000000000000000088888000000000000000000000000000000000000088000000000008800000000000000000000000000000000000000000
00000000088000000000000000088888800000000000000000000000000000000000000088000000000008800000000000000000000000000000000000000000
00000000088000000000000000088888800000000888800000008800008888888800008888000000000888800000000088888888888880088880000000088000
00000000088000000000000000088888800000000888800000008800008888888800008888000000000888800000000088888888888880088880000000088000
00000000000000000000000000088888800000000888800000888800888888888888008888000000000888800000000088888888888880088880000088888000
00000000000000000000000000088880000000000888800000888800888800008888008888000000000888800000000088888888888880088880000088888000
00000000000000000000000000088880000000000008800000888800008800008888000088000000000008800000000000880000000000000880000088888000
00000000000000000000000000088880000000000008800000888800008800008888000088000000000008800000000000880000000000000880000088888000
00000000000000000000000000088880000000000888800000888800888800008888008888000000000888800000000088888888888000088888888888000000
00000000000000000000000000088880000000000888800000888800888800008888008888000000000888800000000088888888888000088888888888000000
00000000000000000000000000088000000000000888800000888800888888888888008888000000000888800000000088888888000000000888888888000000
00000000000000000000000000088000000000000888800000888800888888888888008888000000000888800000000088888888000000000888888888000000
00000000000000000000000000000000000000000888888000888800888888000888008888000000000888800000000088880000000000000888888800000000
00000000000000000000000000000000000000000888888000888800888888000888008888000000000888800000000088880000000000000000888800000000
00000000000000000000000000000000000000000888888888888800888800000888008888000000000888800000000088880000000000000000888800000000
00000000000000000000000000000000000000000008888888888800888800000888008888000000000888800000000088880000000000000000888800000000
00000000000000000000000000000000000000000008888888880000888800000888008888000000000888800000000088880000000000000000888800000000
00000000000000000000000000000000000000000008888888880000888800000888008888888888800888888888880088888888888880000000888800000000
00000000000000000000000000000000000000000000088888000000888800000888008888888888800888888888880088888888888880000000888800000000
00000000000000000000000000000000000000000000088888000000888800000888008888888880000888888888000088888888888880000000888800000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000ccc00cc0000ccc000000000ccc000cccccccccc000ccccccc000ccccccccccc000000000ccc00000
00000000000000000000000000000000000000000cccccccccc0ccc0000ccc00cccccccccc00ccccccccccc00cccccccc00cccccccccccc00cccccccccc00000
00000000000000000000000000000000000000000cc000000000ccc0000ccc0ccc000000000cc000ccc00000cc00000000cc00cc0000ccc0ccc0000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000cc000000000ccc0000ccc0ccc00000000000000ccc00000cccccc0000cc00cc0000ccc0ccc0000000000000
00000000000000000000000000000000000000000cccccccccc0ccc0000ccc0ccccccccccc000000ccc00000cccccc0000cc00cc0000ccc0ccccccccccc00000
000000000000000000000000000000000000000000000000ccc0cccccccccc000000000ccc000000ccc00000cc00000000cc00cc0000ccc000000000ccc00000
00000000000000000000000000000000000000000cc00000ccc00000000ccc0ccc00000ccc000000ccc00000cc00000cc0cc00cc0000ccc0ccc00000ccc00000
00000000000000000000000000000000000000000cc00000ccc00000000ccc0ccc00000ccc000000ccc00000cc0000ccc0cc00cc0000ccc0ccc00000ccc00000
00000000000000000000000000000000000000000cccccccccc0ccccccccc00ccccccccccc000000ccc00000ccccccccc0cc00000000ccc0ccccccccccc00000
00000000000000000000000000000000000000000ccccccccc00ccccccccc00cccccccccc0000000cc000000cccccccc00cc00000000ccc0cccccccccc000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc000000000000000000
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
00000000000000000008080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000088880808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008080880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000055555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000055555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000005cc5cc5cc50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000055555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000dddddddddcc5cc50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000660000dd66d6d66d5555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000660000dd55ddd55dcc5cc50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000660000dddddddddd5555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000066666666dd66d6d66dcc5cddddddd55000005555500000000000000000000000000000000000000000000000000000000000000000000000000000000000
000666666666dd55ddd55d2222d66d66d055555550d0555550000000000000000000000000000000000000000000000000000000000000000000000000000000
000666666666dddddddddd2662d55d55d000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000666666666dd66d6d66d2222ddddddd000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000663666666dd55ddd55d2662d66d66d66666666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006333366dddddddddddd2222d55d55d1c175c1c1c1716000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006333336d666666666666666dddddddccc75cccccc711600000000000000000000000000000000000000000000000000000000000000000000000000000000
00063333365111151111511115d66d66d777777777777cc600000000000000000000000000000000000000000000000000000000000000000000000000000000
000664333651d1151d1151d115d55d55dcccccccccccccd000000000000000000000000000000000000000000000000000000000000000000000000000000000
000664646654d4454d4454d445ddddddd55555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000
00333333333333333333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000002020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd000000000000000002020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd000000000000000022220202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dd000000000000002020220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dd0dd000000000066666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000dd000000000066666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ddddd000000000061161161160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ddddd000000000066666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000dd5000005555555551161160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000055000055115151156666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000055000055dd555dd51161160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000055000055555555556666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005555555555115151151161ddddddd55000005555500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055555555555dd555dd52222d11d11d055555550d0555550000000000000000000000000000000000000000000000000000000000000000000000000000000
00055555555555555555552112d55d55d000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055555555555115151152222ddddddd000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055355555555dd555dd52112d11d11d000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00053333555555555555552222d55d55d000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00053333355555555555555555ddddddd000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00053333355dddd5dddd5dddd5d11d11d000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055433355d6dd5d6dd5d6dd5d55d55d000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055454555565555655556555ddddddd55555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000
00333333333333333333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000
