poke(0x5F2D, 1) -- mouse support
size = 128
matrix = {}
agents = {}
particles = {}
particle_lines = {}
exp_circles = {}
hall = {}
dist = 1 -- distance between agents
min_x = 0 + dist
min_y = 0 + dist
max_x = size - dist
max_y = 100
change_dir_chance = 0.1 -- percent
hit_distance = 3
home_size = 4
home_radius = home_size \ 2
cycle_count = 1
time_cycle = 100
in_cycle = true
max_ap = 5
curr_ap = 5
ap_limit = 30 
et_mouse_over = false
snatch_radius = 3
snatch_chance = 0.1 -- percent
game_over = false
buttons_disabled = false