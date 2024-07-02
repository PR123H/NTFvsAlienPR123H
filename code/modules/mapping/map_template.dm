/datum/map_template
	var/name = "Default Template Name"
	var/width = 0
	var/height = 0
	var/mappath = null
	var/loaded = 0 // Times loaded this round
	var/datum/parsed_map/cached_map
	var/keep_cached_map = FALSE

/datum/map_template/New(path = null, rename = null, cache = FALSE)
	if(path)
		mappath = path
	if(mappath)
		preload_size(mappath, cache)
	if(rename)
		name = rename

/datum/map_template/proc/preload_size(path, cache = FALSE)
	var/datum/parsed_map/parsed = new(file(path))
	var/bounds = parsed?.bounds
	if(bounds)
		width = bounds[MAP_MAXX] // Assumes all templates are rectangular, have a single Z level, and begin at 1,1,1
		height = bounds[MAP_MAXY]
		if(cache)
			cached_map = parsed
	return bounds

/datum/parsed_map/proc/initTemplateBounds()
	var/list/obj/machinery/atmospherics/atmos_machines = list()
	var/list/obj/structure/cable/cables = list()
	var/list/atom/atoms = list()
	var/list/area/areas = list()

	var/list/turfs = block(	locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]),
							locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ]))
	for(var/L in turfs)
		var/turf/B = L
		atoms += B
		areas |= B.loc
		for(var/A in B)
			atoms += A
			if(istype(A, /obj/structure/cable))
				cables += A
				continue
			if(istype(A, /obj/machinery/atmospherics))
				atmos_machines += A
	for(var/area/area AS in areas) //areas are init'd when the first turf is generated, some somethings in init are not done correctly
		area.update_base_lighting()
		area.reg_in_areas_in_z()
	SSatoms.InitializeAtoms(atoms)
	SSmachines.setup_template_powernets(cables)

/datum/map_template/proc/load_new_z(minimap = TRUE, list/traits = list(ZTRAIT_AWAY = TRUE))
	var/x = round((world.maxx - width)/2)
	var/y = round((world.maxy - height)/2)

	var/datum/space_level/level = SSmapping.add_new_zlevel(name, traits)
	var/datum/parsed_map/parsed = load_map(file(mappath), x, y, level.z_value, no_changeturf=(SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop=TRUE)
	var/list/bounds = parsed.bounds
	if(!bounds)
		return FALSE

	repopulate_sorted_areas()

	//initialize things that are normally initialized after map load
	parsed.initTemplateBounds()
	SSmodularmapping.load_modular_maps() //must be run after initTemplateBounds so markers have an actual loc
	SSweather.load_late_z(level.z_value)
	SSair.setup_atmos_machinery()
	SSair.setup_pipenets()
	smooth_zlevel(level.z_value)
	if(minimap)
		SSminimaps.load_new_z(null, level)
	log_game("Z-level [name] loaded at at [x],[y],[world.maxz]")

	return level

/datum/map_template/proc/load(turf/T, centered, delete)
	if(centered)
		T = locate(T.x - round(width/2) , T.y - round(height/2) , T.z)
	if(!T)
		return
	if(T.x + width > world.maxx)
		return
	if(T.y + height > world.maxy)
		return

	// Accept cached maps, but don't save them automatically - we don't want
	// ruins clogging up memory for the whole round.
	var/datum/parsed_map/parsed = cached_map || new(file(mappath))
	cached_map = keep_cached_map ? parsed : null
	if(!parsed.load(T.x, T.y, T.z, cropMap = TRUE, no_changeturf = (SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop = TRUE, delete = delete))
		return
	var/list/bounds = parsed.bounds
	if(!bounds)
		return

	//initialize things that are normally initialized after map load
	parsed.initTemplateBounds()

	log_game("[name] loaded at at [T.x],[T.y],[T.z]")
	return bounds

/datum/map_template/proc/get_affected_turfs(turf/T, centered = FALSE)
	var/turf/placement = T
	if(centered)
		var/turf/corner = locate(placement.x - round(width/2), placement.y - round(height/2), placement.z)
		if(corner)
			placement = corner
	return block(placement, locate(placement.x+width-1, placement.y+height-1, placement.z))


//for your ever biggening badminnery kevinz000
//❤ - Cyberboss
/proc/load_new_z_level(file, name, minimap = TRUE, list/traits = list())
	var/datum/map_template/template = new(file, name)
	return template.load_new_z(minimap, traits)
