-- assign same random material across all group members
-- assign a different random material to each individual member of the same group
-- assign same random material to objects based on their distance from each other
-- define source materials by defining material editor slot ranges 1-2 to 1-24
-- i.e. you use this script to apply a random material to hundreds of /groups of objects/

/*
for n = 1 to 24 do 
(
tMat = StandardMaterial()
tMat.name = "mat_" + n as string
tMat.diffuse = random black white
setMeditMaterial n tMat
)
*/

/*
for i = 1 to 100 do sphere pos: (random [-300,-300,-300] [300,300,300]) radius:(random 2 20)
*/

try(destroydialog ::radMat)catch()
sObj = undefined
rollout radMat "" width:96 height:162
(
	checkbutton rm_chk_mode "node" pos:[16,96] width:64 height:16 toolTip:"assign same material to all group members?"
	label rm_lbl_top "radMat" pos:[33,5] width:80 height:18
	button rm_btn_exe "assign" pos:[24,120] width:48 height:16 toolTip:"confirm operation"
	spinner rm_spn_rng_top "" pos:[48,24] width:40 height:16 range:[1,24,2] type:#integer
	spinner rm_spn_rng_btm "" pos:[8,24] width:40 height:16 range:[1,24,1] type:#integer
	label rm_lbl_bottom "@101craft" pos:[24,141] width:54 height:17
	spinner rm_spn_distance "" pos:[24,48] width:64 height:16 enabled:false range:[-1e+006,1e+006,0]
	checkbutton rm_ckb_distance "•" pos:[8,48] width:16 height:16 toolTip:"defined distance between objects"
	pickbutton rm_pck_selection "undefined" pos:[8,72] width:64 height:16
	button rm_btn_selection "•" pos:[72,72] width:16 height:16 toolTip:"reset selection"
	
	on rm_chk_mode changed state do
	(
		if state == true then rm_chk_mode.text = "group"
		else rm_chk_mode.text = "node"
	)
	on rm_btn_exe pressed do
	(
			if rm_ckb_distance.state == true do
			(
				-- assign random materials to objects within distance from a set object
				if sObj != undefined do
				(
				sObj.material = groupmaterial
					for o in objects do
					(
						if rm_spn_distance.value > 0 then
						(
							if distance o.pos sObj.pos < rm_spn_distance.value do
							(	
								try
								(
								groupmaterial = meditmaterials [random rm_spn_rng_btm.value rm_spn_rng_top.value]
								o.material = groupmaterial
								)
								catch()
							)
						)
						else if rm_spn_distance.value < 0 then
						(
							if distance o.pos sObj.pos > rm_spn_distance.value*-1 do
							(	
								try
								(
								groupmaterial = meditmaterials [random rm_spn_rng_btm.value rm_spn_rng_top.value]
								o.material = groupmaterial
								)
								catch()
							)
						)
					)
				)
				
				-- assign random materials / same materials to objects within distance from each other
				if sObj == undefined do
				(
					oArr = objects as array
					for o = 1 to oArr.count do 
					(
						groupmaterial = meditmaterials [random rm_spn_rng_btm.value rm_spn_rng_top.value]
						nArr = objects as array
						deleteItem nArr o
						
						-- proceed only if objects are closer to each other than set value
						if rm_spn_distance.value > 0 then 
						(
							for n = 1 to nArr.count where (distance oArr[o] nArr[n] < rm_spn_distance.value) do
							(
								try(oArr[o].material = groupmaterial)catch()
								-- deleteItem nArr n
							)
						)
						
						-- proceed only if objects are farther from each other than set value
						else if rm_spn_distance.value < 0 then
						(
							for n = 1 to nArr.count where (distance oArr[o] nArr[n] > rm_spn_distance.value * -1) do 
							(
							try(oArr[o].material = groupmaterial)catch()
							)
						)
					)
				)
			)
			
		-- per group basis
		if rm_chk_mode.state == true do
		(	
			-- manage selected object groups only
			if selection.count > 0 do
			(
				for p in selection as array where isgrouphead p do
				(
				groupmaterial = meditmaterials [random rm_spn_rng_btm.value rm_spn_rng_top.value]
				for c in p where isgroupmember c do c.material = groupmaterial
				)
			)
		)
		-- per node basis
		if rm_chk_mode.state == false do for n in selection do n.material = meditmaterials [random rm_spn_rng_btm.value rm_spn_rng_top.value]
	)
	on rm_spn_rng_btm changed val do
	(
	vDiff = rm_spn_rng_top.value - rm_spn_rng_btm.value
	if  vDiff < 0 do rm_spn_rng_top.value = rm_spn_rng_btm.value
	)

	on rm_spn_rng_top changed val do
	(
	vDiff = rm_spn_rng_btm.value - rm_spn_rng_top.value
	if  vDiff > 0 do rm_spn_rng_btm.value = rm_spn_rng_top.value
	)

	on rm_ckb_distance changed state do
	(
		case state of
		(
			true: rm_spn_distance.enabled = true
			false: rm_spn_distance.enabled = false
		)
	)
	on rm_pck_selection picked obj do
	(
	global sObj = obj
	rm_pck_selection.text = sObj.name
	)
	on rm_btn_selection pressed  do
	(
	sObj = undefined
	rm_pck_selection.text = sObj as string
	)
)
createdialog radMat
