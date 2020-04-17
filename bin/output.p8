pico-8 cartridge // http://www.pico-8.com
version 20
__lua__
--neon
--by luca harris

--palette
for i=1,7 do
 pal(i,({
  8,11,10,140,14,12,7,
 })[i],1)
end

--list of points
local ps=nil

--interporlate between items
--in a table.
--t - a table
--i - index into t
function smooth(t,i)
 local n=#t
 local i0=flr(i)
 local t0=t[min(n,i0)]
 local a,b
 if type(t0)=="table" then
  a=t0[1]
  b=t0[2]
 else
	 a=t0
	 b=i<n and t[i0+1] or t0
	 if type(b)=="table" then
	  b=b[1]
	 end
	end
	
	local k=i-i0
	return a*(1-k)+b*k
end

--alternating scanline cls
function scan_clear()
 local f=frame%2
 
 for j=0,127 do
  local i=0x6000+j*64
  if j%2==f then
   memset(i,0,64)
  end
 end
end

--music stuff
beat_table={
 1,1,1,2,
 2,2,3,3,
 3,3,4,4,
 4,5,5,6,
}

beat_int_table={
 4,1,{0.5,0},4,
 1,{0.5,0},4,2,
 1,{0,2},2,6,
 {2,1},5.2,{2,0},{4.7,0},
}

--state
local ch1l=-1
local ch1h=0
local ptn0=-1
local rotation=0
frame=0
clear_mode=0

--init!
function _init()
 music(0)
end

--pattern handlers
--ptn 0
function ptn_0(p)
 p.spy=0
 p.spx=0
 p.spw=17
 p.sph=8
 p.spd=5
 p.speed=7
 p.int=(ch1h%4)*(ch1h/32)*1.2
 p.scale=6+ch1h/8
end

--ptn 1-2
function ptn_1(p)
 p.spy=16
 p.spx=0
 p.spw=42
 p.sph=15
	
 if ptn==1 then
  local k=ch1h%4
  p.int=-0.5-k*0.9
  p.scale=8.5+k*1.5
 else
	 local k=smooth(beat_int_table,1+ch1h%16)
  p.int=k*0.8
  p.scale=3+beat_table[1+ch1%16]*2.5
 end
end

--ptn 3-4
function ptn_3(p)
 p.spy=0
 p.spx=48
 p.spw=26
 p.sph=8
 p.spd=5
 
 local bop=ch1c and ({
  1,0,0,1,
  0,0,1,0,
  0,0,1,1,
  0,1,0,1,
 })[1+ch1%16]==1
 if(bop)ptn3t=1
	
	if ptn==3 then
	 p.speed=bop and 100 or 11
	 p.scale=9+ptn3t*2
  p.int=ptn3t*4+0.2
	else
	 p.speed=3+ptn3t*25+ch1h*0.45
	 p.int=ch1h/7+ptn3t*2.5
	 p.scale=8+ptn3t*2
	end
 
 ptn3t*=0.74
end

--ptn 5-8
function ptn_5(p)
 p.spy=16
 p.spx=48
 p.spw=48
 p.sph=16
 local k=(4-ch1h%4)
 
 if ptn<7 then
  p.speed=ch1c and ch1==0 and 100 or 6+k*1
 end
	
	if ptn==5 then
	 p.int=-k
	 p.scale=12+k*1
	elseif ptn==6 then
	 p.int=-2-k
	 p.scale=18-k*2
	 p.speed=10
	elseif ptn==7 then
	 local k2=ch1h%8<4 and k or 4-k
	 p.int=1+k2*0.8
	 p.scale=4+k2*3
	else
	 p.int=5-k*1.12+ch1h*0.04
	 p.scale=10+k*0.7+ch1h*0.2
	 p.speed=7+ch1h*0.7
	end
end

--ptn 9-10
function ptn_9(p)
	p.spy=0
	p.spx=80
	p.spw=33
	p.sph=16
	
	local k=smooth(beat_int_table,1+ch1h%16)
	p.speed=10
	if ptn==9 then
	 p.int=0.2+k*0.7
	 p.scale=4+beat_table[1+ch1%16]*2.3
	else
	 p.scale=11
	 p.int=0.2+k*0.8
	 p.speed=7+k*4.2
	end
end

--ptn 11-12
function ptn_11(p)
 local which=(beat_table[1+ch1%16]-1)%4
 
 ptn13_last=ptn13_last or -1
 local bop=which!=ptn13_last
 if(bop)nptn=true
 
 local d=({
  {16,0,42,15,3},
  {0,48,26,8,5},
  {16,48,48,16,3},
  {0,80,33,16,3},
 })[1+which]
 
 p.spy=d[1]
 p.spx=d[2]
 p.spw=d[3]
 p.sph=d[4]
 p.spd=d[5]
 
 local k=smooth(beat_int_table,1+ch1h%16)
 if ptn==11 then
  local k2=0.1+k*1.5
  p.int=-k2
	 p.speed=8
	 p.scale=13+k2/2
 else
  local kc=(ch1h/32)^2
  local k2=0.1+kc*1.2+(4-ch1h%4)*(1+kc*0.7)
  p.int=k2
	 p.speed=8+kc*24
	 p.scale=10+kc*10
	end
end

--ptn 13-16
function ptn_13(p)
 p.spy=0
 p.spx=0
 p.spw=17
 p.sph=8
 p.spd=6
 p.speed=9
 
 local k=(4-ch1h%4)
 local k2=(2-ch1h%2)
 local prog=(ptn-13)*32+ch1h
 local progt=prog/128
 p.speed=1.2+progt*8.5
 p.scale=3+progt*10
 p.int=1-progt*1.2+k*(progt*progt)
 if ptn==16 then
  p.int+=k2*ch1h*0.02
 end
end

--draw!
function _draw()
	--get music state
	ptn=stat(24)
	nptn=ptn0!=ptn
	ptn0=ptn
	ch1=stat(20)
	ch1c=ch1!=ch1l
	if ch1c then
	 ch1h=ch1
	 ch1l=ch1
	else
	 ch1h+=0.25
	end
	
	--swap clear mode everytime
	--we reach the last pattern
	if nptn and ptn==13 then
	 clear_mode=(clear_mode+1)%2
	end
	
	if clear_mode==0 then
	 cls()
	else
	 scan_clear()
	end
	
	--graphics parameters
	local p={
	 spx=0,
		spy=0,
		spw=16,
	 sph=16,
		spd=3,
		int=0,
		scale=14,
		speed=6,
	}
	
	--pattern handlers
	if ptn==0 then
	 ptn_0(p)
	elseif ptn<=2 then
	 ptn_1(p)
	elseif ptn<=4 then
	 ptn_3(p)
	elseif ptn<=8 then
	 ptn_5(p)
	elseif ptn<=10 then
	 ptn_9(p)
 elseif ptn<=12 then
	 ptn_11(p)
	else
	 ptn_13(p)
	end
	
	--get locals from params
	local spx=p.spx
	local spy=p.spy
	local spw=p.spw
	local sph=p.sph
	local spd=p.spd
	local int=p.int
	local scale=p.scale
	local speed=p.speed
	
	--main
	--load points
	if nptn then
	 ps={}
		for y=0,sph-1 do
		for x=0,spw-1 do
		 local c=sget(spx+x,spy+y)
		 if c>0 then
		  add(ps,{x=x,y=y,c=c})
		 end
		end
		end
	end
	
	--normalize params
	int=int/100
	rotation+=speed/900
	
	--precalc constants
	local js={}
	for i=0,2 do
	 js[i]=0.27+int*i
	end
	local is={[0]=4,2,1}
	local yc=sph/2
	local ky=scale/sph
	local kx=0.5/spw
	
	--draw points
	for pi=1,#ps do
	 local p=ps[pi]
	 local x=p.x
	 local y=p.y
	 local c=p.c
	 local q=0.07+(-x*kx+rotation)%0.5
	 if q<0.42 then
		 local sq=sin(q)
		 for a=0,spd-1 do
		 	local x2=cos(q+a/(spd/kx))*scale
			 for b=0,spd-1 do
			  local y2=(y+b/spd-yc)*ky
					for i=0,2 do
					 local k=.5+sq*js[i]
				  local u=64+x2/k
				  local v=64+y2/k
				  pset(u,v,bor(is[i],pget(u,v)))
					end
				end
			end
		end
	end
	
 frame+=1
 
 --debug
	--?stat(1),0,0,7
end
__gfx__
00777700007707700000000000000000000000000000000007700077007777777077707770000000077700000007770070070000700070000000000000000000
07000070070070070000000000000000000000000000000070077700707000007070707070000000070070000070070007007007000070700000000000000000
70000007070070070000000000000000000000000000000070000000707070707070707070880880070007777700070000000000000070070000000000000000
70700707070000070000000000000000000000000000000007070707007070707070777070888880007000000000700007777777000070000000000000000000
70000007070707070000000000000000000000000000000007000007007000007070000070088800007077000770700007007007000070000000000000000000
70077007070707070000000000000000000000000000000007007007007777777070707070008000007000000000700007777777077777770000000000000000
07000070070000070000000000000000000000000000000000700070000000000070000070000000070007000700070007007007000070000000000000000000
00777700007777700000000000000000000000000000000000077700007777777077777770000000700000000000007007777777000070000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000070000000000000070000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000007077777777700707000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000077700000007770000000000000707000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000700000007000007777777000707000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000070777070000007000007000707000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000070070070000007000007007000700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000007000700000007777777007000700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000777000000007000007070000070000000000000000
70707070707070707070707070707070707070707070000007777777770000000000000000000000000000007000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000700000007777777770000000700000070077777007000000000000000000000000000000000
07777000007000007777777777700777000000700000000077777777777000000000070077777777777007070007070000000000000000000000000000000000
07007000007000000000070000007000707777777700000070000700007000000000700000700000700000070007000000000000000000000000000000000000
07007007777777000077777770000070007000000700000070770707707000000007000000070007000000077777000000000000000000000000000000000000
07007007007007000070070070007777700000000000000070000700007000000070000000070007000007070007070000000000000000000000000000000000
07007007007007000070070070007000707777777000000070770707707000000700000077777777777070070007007000000000000000000000000000000000
07777007007007000077777770007777707000007000000070000700007077777777777000000000000000077777000000000000000000000000000000000000
07007077777777700070070070007000707777777000000000000000000000000700000007777777770000000700000000000000000000000000000000000000
07007000007000007070070070707777707000000000000007777777770000000700000007000000070007777777770000000000000000000000000000000000
07007000070700007077777770707000007777777700000007000700070000000700000007000000070000000700000000000000000000000000000000000000
07007000700070007000000000707007007000000700000007777777770000000700000007777777770000007770000000000000000000000000000000000000
07777007000007007777777777707770707777777700000007000700070000000700000007000000070000070707000000000000000000000000000000000000
00000000000000000000000000000000000000000000000007777777770000000700000007000000070000700700700000000000000000000000000000000000
70707070707070707070707070707070707070707070000000000700000700077000000007777777770007000700070000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000077777000000000000007000000070000000700000000000000000000000000000000000000
__label__
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000fff000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000fff000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000fff000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000f0ff000000000f0ffbcfc000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000f0ff00000ff0fff0ffff000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000f0ff0000000000000bcfc0ff0fff0f000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000f0ff000000000f0ffbcfc0ff0f0000fff0000000000000ff000000000000000000000000000000
0000000000000000000000000000000000000000000000000000bbc0ff00000cbfcaa8bbbb00ff0ffff000000ff0f000ffff0000000000000000000000000000
000000000000000000000000000000ff00000000000fff000000bbb00000000bb0baa8bbbbb0bbbbcff000000ff0fbbbffff0000000000000000000000000000
000000000000000000000000000000ff0000000ff0f00000000000f0ff00000cbfcaa8b000b0bbbbb000000bbcf0fbbbbffff000000000000000000000000000
000000000000000000000000000000000bcfff0ff0ffff000000ba78ff00000e8fe8888aaaa8bbbbcff000fbcc088bbbbbfff000000000000000000000000000
000000000000000000000000000000ffffffff0f000ffcbb00000888bbb00007af788888888888abcff000f0ff0888aabbbff000000000000000000000000000
0000000000000000000000000000fffffcb8ee0ccbcbb00000000888bbb0000aa0a8888888888880fff0aa7bcc0888ee7bbcf000000000000000000000000000
000000000000000000000000000ffffffcc777bcbbbbbbbb00000000baa80007af700000000088abb000aaa0000008eee7ccf000000000000000000000000000
00000000000000000000000000fffffcbbbaaabbbbaaaaaa8800000008880007af700000000088abcfe8aaa0000bbbc7e7ccf000000000000000000000000000
00000000000000000000000000fffccbbbba77a788888888880000000888000aa0a00000000088abcfe88000088bbbc777cff000000000000000000000000000
00000000000000000000000000ffcbbaaaa8ee87aa888888880000000000000e8fe0fff0ff0feeaccfe88000088aaa777ccff000000000000000000000000000
00000000000000000000000000ffcbaa8888888aaa8880000000000000000007af70fff0ff0f88abb0000000088aaaaaabbcf000000000000000000000000000
00000000000000000000000000ffcba888eef00bbb888000000000000000000cbfcbb0bbbbb077accff00000088aaaee7abcf000000000000000000000000000
00000000000000000000000000fffba880fffbbb00888000000000000000000aa0abcfcbccbf778ffff00000088bbbfeeabcf000000000000000000000000000
000000000000000000000000000ffcb880fffbbb00000000000000f0ff000007af7aa8aaaa8888abcff00000088bbbfee7cff000000000000000000000000000
000000000000000000000000000fffba80fffbba88000000000000f0ff00000e8fe8888888a8aaabb00000f0fe8bbbc77ccff000000000000000000000000000
000000000000000000000000000fffbb888000088800000000000000bbb0000aa0a88888888888abcff0bbc0fe8baa777ccff000000000000000000000000000
000000000000000000000000000fffbb88effbba88000000000000f0c7a80007af700000000088abcfe8abb0088baa777abcf000000000000000000000000000
000000000000000000000000000fffbb88effbba880fff0000f0ff00baa80007af700000000088abcfe880f0fe8bbaeeeabcf000000000000000000000000000
000000000000000000000000000fffbceeeffcb7e8f00bbb0000bbb008880007af700000000088abb088abb00eebcb088abff000000000000000000000000000
00000000000000000000000000ffffccaa7cccb77a777e8888f0c7a80000000aa0a0000000008880fff0000bb7ebcbfeeccff000000000000000000000000000
00000000000000000000000000ffcc7777aa77a77a7777aa88f0fe880000000e8fe00000000088abcff0888bba8baa777ccff000000000000000000000000000
00000000000000000000000000ffcc7777777aaaaaaaaaaa8800baa800000007af70fff0ff0feeaccff0888bb7eb7a7777ccf000000000000000000000000000
00000000000000000000000000ffbbaa8888888888000000000000000000000aa0aaa8aaaaa8aaabb0008880088baa777abcf000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000007af7a7e7a77ae77accff00000088bbbfeebbff000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000007af7a7e7a77ae77accff00000088bbbfeebbff000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088000088bbff000000000000000000000000000
00000000000000000000000000ffcc77777777a77a7aa88000000000000000000000008a7c0f0000000000000000000000000000000000000000000000000000
00000000000000000000000000ffcc77777777a77a7aa88000000000000000000000008a7c0f0000000000000000000000000000000000000000000000000000
00000000000000000000000000ffcce7ccccccbccb7aa88000000000000000000000008a7c0f000000000000000888aaaabcf000000000000000000000000000
00000000000000000000000000ffbb880000000ff0cba88000000000baaa8aaaa0aaa8aaaaa8aaaaaaa7acc0ff088aaa77ccf000000000000000000000000000
00000000000000000000000000ffbb880000000000bba880000000f0c7a7ea77af7a7e7a77ae77a7777aabb000088aaa77ccf000000000000000000000000000
00000000000000000000000000ffbb880000000ff0cba880000000f0fe8ee8ee8fe8eee8eeae77a77777acc0ff088bbaeccff000000000000000000000000000
00000000000000000000000000ffbb880000000ff0cba880000000f0ccbb0bbbb0bbcf7a7c0fff0fffff0ff0ff088bbaecbff000000000000000000000000000
00000000000000000000000000ffbb880000000ff0f0888000000000000ff0ff0ff0008aab0000000000000000088aaae7bcf000000000000000000000000000
00000000000000000000000000ffbbaa8888888888bba88000000000000000000000008a7c0f00000000000000088aaa77bcf000000000000000000000000000
00000000000000000000000000ffccaaaaaaaaa7e87aa88000000000000000000008888a778e00000000000000088aaa7cccf000000000000000000000000000
00000000000000000000000000ffcc7777aaa8877a7aa8800000000000000000000aa8aaaaa8bb000000000000088aaaaccff000000000000000000000000000
00000000000000000000000000ffcce7ccccccbccb7aa880000000000000000000088888eeaebb000000000000088bbae7cff000000000000000000000000000
00000000000000000000000000ffccee00fffcbcbbbba8800000000000000008808bcf7a7c0fee8f0000000000088bbae7bcf000000000000000000000000000
00000000000000000000000000ffbb8efffff00ff0cba8800000000000000008808bcf7a7cbf778f0000000000088aaa77bcf000000000000000000000000000
00000000000000000000000000ffbb880000ff0ff0f08880000000000000000bb0b0008aab00eeacb000000000088aaa7cbcf000000000000000000000000000
00000000000000000000000000ffbb880000000ff0cba880000000000000000aa0a0ffea7c0f00baa800000000088aaa7ccff000000000000000000000000000
00000000000000000000000000ffbb888888000000bba880000000000000888f0ff0000bcc0f00ba7ef0000000000bba77cff000000000000000000000000000
00000000000000000000000000ffbbaa8888888ee8cba880000000000000888bb0b00088ef0f0008e7cb000000000bbbe7ccf000000000000000000000000000
00000000000000000000000000ffcbaaaaa8888ee87aa88000000000000b8aaf0ff0008aab000000fc7a800000000000eeccf000000000000000000000000000
00000000000000000000000000ffccaabbbaaaa7e87aa88000000000088a0bbf0ff0008a7c0f00000ba78ff00000000000bcf000000000000000000000000000
00000000000000000000000000ffccfcbbbbb00ccb7aa88000000000088a0bb00000008a7c0f0000008eacc000000000000ff000000000000000000000000000
00000000000000000000000000ffccffff0bbbbbbbbba88000000000baaef0f00000008aab0000000000bbb00000000000000000000000000000000000000000
00000000000000000000000000fffffffffffcbccbf0888000000000000ff0f00000008a7c0f0000000fbcc0ff00000000000000000000000000000000000000
000000000000000000000000000000fffffff00ff0cba88000000000bbbff0f000000088ef0f0000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000ffff0ff0cbb00000000000bbb000000000008a7c0f0000000000f0ff00000000000000000000000000000000000000
000000000000000000000000000000000000ff0f00bbb000000000f0ff0000000000000bbb000000000000f0ff00000000000000000000000000000000000000
000000000000000000000000000000000000000ff0cbb000000000f0ff0000000000000bcc0f0000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000ff0f00000000000f0ff0000000000000bcc0f0000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000ff0f00000000000000000000000000000ff0f0000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000ff0f00000000000000000000000000000ff0f0000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000ff0f0000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
010400061835018240182401824018240182402420018200003000030000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
010401062434018140181401814018140181402410018100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001d8401d8311d8211d8111d8111d8151d8401d8311d8211d8111d8111d8151d8401d8311d8211d8111d8111d8121d8121d815208412284122842228422281122815228402283122821228112284022811
010800001b8401b8411b8211b8111b8111b8151b8401b8411b8211b8111b8111b8151b8401b8411b8211b8111b8111b8121b8121b815248412684126842268422681126815278402784127821278112684026811
011000001d8401d8211d8251d8421d8211d8251d8401d8211d8211d8252283122842228152284022845228111d8401d8211d8251d8421d8211d8251d8401d8211d8211d82522831228422281520840208451f845
011000001b8401b8211b8251b8421b8211b8251b8401b8211b8211b8252683126842268152684026845268211b8401b8211b8251b8421b8211b8251b8401b8211b8211b825268312684226815268402684526821
01100008221101b11022110271102e1101b110221101b1101b11022110271102e1101b110221101b110221102460022100271002e10030600221001b100221003060022100271002e10037600221003c6053c600
01100008181101f110271102b110181101f110181101f110271002710027100271002b1002b1002b1002b100181001810018100181001f1001f1001f1001f100181001810018100181001f1001f1001f1001f100
011000000c60513605186051f6052b6032b6032b6032b6030000000000000000000000000006050260500605006250261500615026150462506615086150a6150c62513615186151f615246132b6133761337613
010800101806307023246151f6052461530605246150c604180630c615246152b6052461530605246150c60400000000000000000000000000000000000000000c60513605186051f6052b6032b6032b6032b603
011000001b8401b8211b8251b8421b8211b8251b8401b8211b8211b8252683126842268152684026845268211b8401b8211b8251b8421b8211b8251b8401b8211b8211b825268312684226815278402784526845
010800201862503145031400314503140031450f1400f1452d6350314503140031450f1400f1450f1400f1451862503145031400314503140031450f1400f1452d635031450f1400f14503140031450f1400f145
010800201862500145001400014500140001450c1400c1452d6350014500140001450c1400c1450c1400c1451862500145001400014500140001450c1400c1452d635001450c1400c14500140001450c1400c145
0108002018625081450814008145081400814514140141452d6350814508140081451414014145141401414518625081450814008145081400814514140141452d63508145141401414508140081451414014145
01080020186250a1450a1400a1450a1400a14516140161452d6350a1450a1400a14516140161451614016145186250a1450a1400a1450a1400a14516140161452d6350a14516140161450a1400a1451614016145
010800200714007145071400714507140071451314013145071400714507140071451314013145131401314507140071450714007145071400714513140131450714007145071400714513140131451314013145
0104002018625001200011100115001300012100111001150c1300c1210c1110c115071300712107111071152b625001200011100115001300012100111001150c1300c1210c1110c11503130031210311103115
011000200c6101b11022110271102e1101b110221101b1101f6101b11022110271102e1101b110221101b110246101b1102211027110306101b110221101b110306101b1102211027110376101b1103c6153c610
011000002e9202e9222e9222e9220090000900009000090000900009000090000900279202792029920299202e92000900009002e92000900009002e9202e9203092130922309223092200900009000090000900
011000003292032922329223292200900009000090000900009000090000900309203092030920339213392200900009000090032920009000090032920329200090000900009003292000900329253292000900
011000002e9202e9222e9222e922009002e9000c9000c900009002e9000c9002992029925009002b920009002c9202b9202b92027920279222792224902249002c9202b9202b9202792027920299202b9202b925
011000002c9202b9202b92027920279200090024920009002792000900009000090029920299202c921009002c92000900009002c92000900009002e920009002e9202e9222e9222e9222e9122e9122e9122e915
010800101802307003246151f6052461530605246150c604180230c605246152b6052461530605246150c60400000000000000000000000000000000000000000c60513605186051f6052b6032b6032b6032b603
01100000221202712029120221202711029110221102711022120271202912022120271102911022110271100c610261202712022120186202711022110261102462026120271202212030610271103c6153c610
011000001b8401b8211b8251b8421b8211b8251b8401b8211b8211b8252683126842268152684026845268211b8401b8211b8251b8421b8211b8251b8401b8211b8211b825268312684226805268002683126832
011000000000026100268212682500000261002682126825000002610026811268150000026100268142680500000000002680426805000000000026804268050000000000000000000000000000000000000000
011000001b11022110271102e1101b110221101b110221101b11022110271102e1101b110221101b110221101b11022110271102e1101b110221101b110221102211022110221102211022110221102212122131
01080010186250a1050a1000a1050a1000a10516100161052d6350a1050a1000a10516100161051610016105186050a1050a1000a1050a1000a10516100161052d6050a1050a1000a10516100161051610016105
0110000003530035300353003530035210352003520035200351103510035100351003515035000350003500035000a5000f50016500035000a5000f50016500035000a5000f50016500035000a5000f50016500
0110000000520075200c5201352000520075200c5201352000520075200c5201352000520075200c5201352000520075200c5201352000520075200c5201352000520075200c5201352000520075200c52013520
0108002013043000000060500000216050960000604000002461500000000000000013043000000e003000000e0030000000000000000e0030000000000000002461500000000000000000000000000000000000
011000001d5401d5211d5251d5421d5211d5251d5401d5211d5211d5252253122532225152254022545225111d5401d5211d5251d5421d5211d5251d5401d5211d5211d52522531225322251520540205451f545
011000001b5401b5211b5251b5421b5211b5251b5401b5211b5211b5252653126532265152654026545265111b5401b5211b5251b5421b5211b5251b5401b5211b5211b525265312653226515265402654526545
0110000000615030140301003010076150301403010030100c61503024030200302013615030240302003020186150303403030030301f615030340303003030246150304403040030402b615030440304003040
01100000306100c60130600246100c60100000006100060122532225011d50222522225010000022512225011d5321d5011d5021d5221d501000001d5121d50122532225011d5022252222501000002251222501
011000001b5321b5011b5021b5221b501010001b5121b50126532265012650226522265010900026512265011b5321b5011b5021b5221b501010001b5121b5012653226501265022652226501090002651226501
0110000007610076150c6050e600076000c6010e6010c605076000c60100600006050060000600006000060500604006000060100605306043060500000000000000000000000000000000000000000000000000
__music__
00 0c0a4c54
01 080a0d0f
00 090a0d10
00 080a0d0f
00 0e150d10
00 08160d0f
00 09170d10
00 08180d0f
00 0e190d10
00 080a0d11
00 090a0d12
00 080a0d11
00 1c151a12
00 1d0a2820
00 230a6263
00 240a6264
02 250a0c24

