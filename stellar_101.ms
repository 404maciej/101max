-- parametric model of a solar system

global root = undefined
global elements = #()
global planets = #()
global rad = 0

fn tone arr =
(
	for a = 1 to arr.count do 
	(
	-- mat = Arch___Design__mi()
	mat = standard()
	mat.name = "m_" + arr[a] as string
	c = color (255-a*10.625 as integer) (0+a*10.625 as integer) 255 0
	mat.diffuse = c
	arr[a].material = mat
	)
)

fn kill arr =
(
	for a = 1 to arr.count do delete arr[a]
)

fn origin child parent =
(
	child.parent = parent
)

fn procreate x y z size circles circle_gap orbits orbit_gap ceiling sun =
(
	root = undefined
	elements = #()
	planets = #()
	rad = 0
	-- root
	root = circle radius:(size*circles*circle_gap*1.5) pos:[x,y,z] name: "stellar_root"
	append elements root
	
	-- base circles
	for c = 1 to circles do
	(
		rnd = random 0.1 3.0
		rad = rnd+size*c*circle_gap
		clone = circle radius:rad pos:[x,y,z] steps:32 name: ("stellar_base_" + c as string)
		m = sweep current_built_in_shape: 2
		addModifier clone m
		classof clone
		m[4].length = 1.5
		m[4].width = 1.5 * c
		origin clone root
		append elements clone
	)
	
	-- base links
	links = random 3 6
	for l = 1 to links do
	(
		rot = (360 / links) * l
		clone = box pos:[x,y,z] rotation:(eulerangles 0 90 0) length: 1.5 width: 0.75 height: rad name: ("stellar_link_" + l as string)
		rotate clone (angleAxis rot [0, 0, 1])
		origin clone root
		append elements clone
	)	
	
	-- base hemisphere
	s = sphere radius:(0.5 * sun) smooth:on segs:32 pos:[x,y,z] hemisphere:0.5 name: "stellar_base"
	origin s root
	append elements s

	-- rod cylinder base
	b = cylinder pos:[x,y,z] radius:2.0 smooth:on heightsegs:1 capsegs:1 sides:16 height: ((0.5 * sun) + 0.1) name: "stellar_rod_base"
	origin b s
	append elements b
	
	-- rod cylinder
	r = cylinder pos:[x,y,z] radius:(b.radius * 0.75) smooth:on heightsegs:1 capsegs:1 sides:16 height: ceiling name: "stellar_rod"
	origin r b
	append elements r

	-- sun sphere
	s = sphere radius:sun smooth:on segs:32 pos:[x,y,ceiling] name: "stellar_core"
	origin s r
	append elements s
	
	-- rod cylinder base
	c = cylinder pos:[x,y,ceiling-(sun+0.1)] radius:(b.radius * 1.25) smooth:on heightsegs:1 capsegs:1 sides:16 height: (2*sun + 0.2) name: "stellar_rod_sun"
	origin c s
	append elements c
	
	--orbits
	for o = 1 to orbits do
	(
		-- orbit roots / dummies
		d = dummy pos:[x,y,ceiling] name: ("stellar_orbit_root_" + o as string)
		origin d s
		append planets d
		append elements d
		rnd = random 0.5 10.0
		rim = rnd+(sun*2)+o*orbit_gap
		
		-- orbits
		orbit = circle radius:rim pos:[x,y,ceiling] steps:32 name: ("stellar_orbit_" + o as string)
		m = sweep current_built_in_shape: 4
		addModifier orbit m
		classof orbit
		m[4].radius = 1.5
		origin orbit d
		append elements orbit
		
		-- planets
		rnd = random 5.0 (sun-(sun*0.25)) 
		p = sphere radius:rnd smooth:on segs:32 pos:[rim,y,ceiling] name: ("stellar_orbit_planet_" + o as string)
		origin p d
		append elements p
		
		-- orbit holders
		c = cylinder pos:[ceiling,y,z] rotation: (eulerangles 0 90 0) radius:(r.radius * 0.5) smooth:on heightsegs:1 capsegs:1 sides:16 height: (rim) name: ("stellar_orbit_holder_" + o as string)
		origin c d
		append elements c
		
		-- set orbit rotation
		r1 = random -120 120
		r2 = random -30 30
		rotate d (angleAxis r1 [0, 0, 1])
		rotate d (angleAxis r2 [0, 1, 0])
	)
	
	c = cylinder pos:[x,y,ceiling] radius:(r.radius * 0.75) smooth:on heightsegs:1 capsegs:1 sides:16 height: (ceiling*0.25) name: "stellar_holder"
	origin c s
	append elements c
	
	tone elements
)

try(destroydialog ::stellar)catch()
rollout stellar "" width:112 height:160
(
	spinner spn_size "" pos:[8,8] width:48 height:16 range:[1,10,5] type:#integer
	spinner spn_sun "" pos:[8,24] width:48 height:16 range:[1,50,20] type:#float
	spinner spn_ceiling "" pos:[56,24] width:48 height:16 range:[10,1000,200] type:#float
	spinner spn_circles "" pos:[56,56] width:48 height:16 range:[1,5,3] type:#integer
	spinner spn_c_gap "" pos:[8,56] width:48 height:16 range:[0.1,10,3] type:#float
	spinner spn_orbits "" pos:[56,72] width:48 height:16 range:[1,20,5] type:#integer
	spinner spn_o_gap "" pos:[8,72] width:48 height:16 range:[0.1,50,20] type:#float
	button btn_create "procreate" pos:[16,128] width:80 height:24
	checkbutton chk_kill "annihilate" pos:[8,96] width:96 height:24 state:true
	button btn_next "" pos:[96,128] width:8 height:24
	button btn_last "" pos:[8,128] width:8 height:24

	on btn_create pressed do
	(
		procreate 0.0 0.0 0.0 spn_size.value spn_circles.value spn_c_gap.value spn_orbits.value spn_o_gap.value spn_ceiling.value spn_sun.value
		select root
	)
	on btn_next pressed do
	(
		if chk_kill.state == true do kill elements
		procreate 0.0 0.0 0.0 spn_size.value spn_circles.value spn_c_gap.value spn_orbits.value spn_o_gap.value spn_ceiling.value spn_sun.value
		select root
	)
	on btn_last pressed do
	(
		if chk_kill.state == true do kill elements
		procreate 0.0 0.0 0.0 spn_size.value spn_circles.value spn_c_gap.value spn_orbits.value spn_o_gap.value spn_ceiling.value spn_sun.value
		select root
	)
)

createdialog stellar()