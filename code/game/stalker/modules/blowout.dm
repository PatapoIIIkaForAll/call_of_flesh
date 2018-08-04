#define BLOWOUTLOW		1
#define BLOWOUTNORMAL	2
#define BLOWOUTHIGH		3

var/datum/subsystem/blowout/StalkerBlowout
var/global/isblowout = 0

/mob/living/carbon/human
	var/inshelter = 0

datum/subsystem/blowout
	name = "Blowouts"
	priority = 1
	var/blowoutphase = 0
	var/average_cooldown = 27000
	var/cooldownreal = 0
	var/lasttime = 0
	var/starttime = 0
	var/blowout_duration = 1200
	var/list/ambient = list('sound/stalker/blowout/blowout_amb_01.ogg', 'sound/stalker/blowout/blowout_amb_02.ogg',
						'sound/stalker/blowout/blowout_amb_03.ogg', 'sound/stalker/blowout/blowout_amb_04.ogg',
						'sound/stalker/blowout/blowout_amb_05.ogg', 'sound/stalker/blowout/blowout_amb_06.ogg',
						'sound/stalker/blowout/blowout_amb_07.ogg', 'sound/stalker/blowout/blowout_amb_08.ogg')

	var/list/rumble = list('sound/stalker/blowout/blowout_ambient_rumble_01.ogg', 'sound/stalker/blowout/blowout_ambient_rumble_02.ogg',
							'sound/stalker/blowout/blowout_ambient_rumble_03.ogg', 'sound/stalker/blowout/blowout_ambient_rumble_04.ogg')

	var/list/wave = list('sound/stalker/blowout/blowout_wave_01.ogg', 'sound/stalker/blowout/blowout_wave_02.ogg',
						'sound/stalker/blowout/blowout_wave_03.ogg')

	var/list/boom = list('sound/stalker/blowout/blowout_boom_01.ogg', 'sound/stalker/blowout/blowout_boom_02.ogg',
						'sound/stalker/blowout/blowout_boom_03.ogg')

	var/list/lightning = list('sound/stalker/blowout/blowout_lightning_01.ogg', 'sound/stalker/blowout/blowout_lightning_02.ogg',
								'sound/stalker/blowout/blowout_lightning_03.ogg', 'sound/stalker/blowout/blowout_lightning_04.ogg',
								'sound/stalker/blowout/blowout_lightning_05.ogg', 'sound/stalker/blowout/blowout_flare_01.ogg',
								'sound/stalker/blowout/blowout_flare_02.ogg', 'sound/stalker/blowout/blowout_flare_03.ogg',
								'sound/stalker/blowout/blowout_flare_04.ogg')

	var/list/wind = list('sound/stalker/blowout/blowout_wind_01.ogg', 'sound/stalker/blowout/blowout_wind_02.ogg',
							'sound/stalker/blowout/blowout_wind_03.ogg')

datum/subsystem/blowout/New()
	NEW_SS_GLOBAL(StalkerBlowout)
	cooldownreal = rand(average_cooldown * 0.7, average_cooldown * 1.3)

datum/subsystem/blowout/fire()
	if(world.time <= lasttime + cooldownreal)
		return

	if(starttime)
		if(600 + blowout_duration + starttime < world.time)
			AfterBlowout()
			return

		ProcessBlowout()

		if((320 + blowout_duration + starttime) < world.time)
			if(blowoutphase == 2)
				StopBlowout()
				BlowoutDealDamage()
			if(MC_TICK_CHECK)
				return
			BlowoutClean()
			if(MC_TICK_CHECK)
				return
			BlowoutGib()
			if(MC_TICK_CHECK)
				return
			return

		if((blowout_duration + starttime) < world.time)
			if(blowoutphase == 1)
				PreStopBlowout()
			return

	if(!isblowout)
		StartBlowout()
		return


datum/subsystem/blowout/proc/StartBlowout()
	isblowout = 1
	blowoutphase = 1
	starttime = world.time

	add_lenta_message(null, "0", "Sidorovich", "Loners", "ATTENTION, STALKERS! Blowout is starting! Find a shelter quick!")
	world << sound('sound/stalker/blowout/blowout_begin_02.ogg', wait = 0, channel = 17, volume = 50)
	world << sound('sound/stalker/blowout/blowout_siren.ogg', wait = 0, channel = 18, volume = 60)

datum/subsystem/blowout/proc/PreStopBlowout()
	blowoutphase = 2
	world << sound('sound/stalker/blowout/blowout_particle_wave.ogg', wait = 0, channel = 17, volume = 70)

datum/subsystem/blowout/proc/BlowoutClean()
	for(var/obj/item/ammo_casing/AC in ACs)
		qdel(AC)
		if(MC_TICK_CHECK)
			return

datum/subsystem/blowout/proc/BlowoutGib()
	for(var/mob/living/L)
		if(L.stat == DEAD)
			L.gib()

			if(MC_TICK_CHECK)
				return


datum/subsystem/blowout/proc/BlowoutDealDamage()
	for(var/mob/living/carbon/human/H)
		if(istype(get_area(H), /area/stalker/blowout))

			H.radiation += 600
			H.apply_damage(75, BURN)

datum/subsystem/blowout/proc/StopBlowout()

	if(blowoutphase == 2)

		world << sound('sound/stalker/blowout/blowout_impact_02.ogg', wait = 0, channel = 17, volume = 70)
		world << sound('sound/stalker/blowout/blowout_outro.ogg', wait = 0, channel = 18, volume = 70)

	blowoutphase = 3

	for(var/obj/item/weapon/artifact/A)

		if(A.invisibility > 30)

			PlaceInPool(A)
			CHECK_TICK

	for(var/obj/anomaly/An in anomalies)

		An.SpawnArtifact()
		CHECK_TICK

datum/subsystem/blowout/proc/AfterBlowout()

	cooldownreal = rand(average_cooldown * 0.7, average_cooldown * 1.3)
	isblowout = 0
	lasttime = world.time
	starttime = 0

	world << sound(null, wait = 0, channel = 19, volume = 70)
	world << sound(null, wait = 0, channel = 20, volume = 70)
	world << sound(null, wait = 0, channel = 21, volume = 70)
	world << sound(null, wait = 0, channel = 22, volume = 70)
	world << sound(null, wait = 0, channel = 23, volume = 70)
	world << sound(null, wait = 0, channel = 24, volume = 70)

	////Deleting old stalker profiles////
	//for(var/datum/data/record/sk in data_core.stalkers)
	//	if(sk.fields["lastlogin"] + 27000 < world.time)
	//		data_core.stalkers -= sk
	/////////////////////////////////////

	//������� �����
	global_lentahtml = ""
	for(var/obj/item/device/stalker_pda/KPK in KPKs)
		KPK.lentahtml = ""

	add_lenta_message(null, "0", "Sidorovich", "Loners", "Blowout is over! Leave the shelter.")

datum/subsystem/blowout/proc/ProcessBlowout()
	if(isblowout)
		for(var/mob/living/carbon/human/H)
			if(istype(get_area(H), /area/stalker/blowout))
				switch(blowoutphase)
					if(1)
						shake_camera(H, 1, 1)
					if(2)
						shake_camera(H, 2, 1)
					if(3)
						shake_camera(H, 10, 1)

	if(prob(20))
		var/a = pick(StalkerBlowout.ambient)
		world << sound(a, wait = 1, channel = 19, volume = 70)

	if(prob(30))
		var/a = pick(StalkerBlowout.wave)
		world << sound(a, wait = 1, channel = 20, volume = 70)

	if(prob(20))
		var/a = pick(StalkerBlowout.wind)
		world << sound(a, wait = 1, channel = 21, volume = 70)

	if(prob(30))
		var/a = pick(StalkerBlowout.rumble)
		world << sound(a, wait = 1, channel = 22, volume = 70)

	if(prob(50))
		var/a = pick(StalkerBlowout.boom)
		world << sound(a, wait = 1, channel = 23, volume = 70)

	if(prob(50))
		var/a = pick(StalkerBlowout.lightning)
		world << sound(a, wait = 1, channel = 24, volume = 70)