/datum/antagonist/changeling
	id = MODE_CHANGELING
	role_text = "Changeling"
	role_text_plural = "Changelings"
	bantype = "changeling"
	feedback_tag = "changeling_objective"
	restricted_jobs = list("AI", "Cyborg", "Head of Security", "Captain", "Chief Engineer", "Research Director", "Chief Medical Officer", "Executive Officer", "Operations Manager", "Merchant")

	protected_jobs = list("Security Officer", "Security Cadet", "Warden", "Investigator")
	restricted_species = list(
		SPECIES_IPC,
		SPECIES_IPC_SHELL,
		SPECIES_IPC_G1,
		SPECIES_IPC_G2,
		SPECIES_IPC_XION,
		SPECIES_IPC_ZENGHU,
		SPECIES_IPC_BISHOP
	)
	required_age = 10

	welcome_text = "Use say \"#g message\" to communicate with your fellow changelings. Remember: you get all of their absorbed DNA if you perform a Full DNA Extraction them."
	antag_sound = 'sound/effects/antag_notice/ling_alert.ogg'
	flags = ANTAG_SUSPICIOUS | ANTAG_RANDSPAWN | ANTAG_VOTABLE
	antaghud_indicator = "hudchangeling"

	faction = "Changeling"

/datum/antagonist/changeling/get_special_objective_text(var/datum/mind/player)
	var/datum/changeling/changeling = player.antag_datums[MODE_CHANGELING]
	return "<br><b>Changeling ID:</b> [changeling.changelingID].<br><b>Genomes Absorbed:</b> [changeling.absorbedcount]"

/datum/antagonist/changeling/update_antag_mob(var/datum/mind/player)
	..()
	player.current.make_changeling()

/datum/antagonist/changeling/create_objectives(var/datum/mind/changeling)
	if(!..())
		return

	//OBJECTIVES - Always absorb 5 genomes, plus random traitor objectives.
	//If they have two objectives as well as absorb, they must survive rather than escape
	//No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	//If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone

	var/datum/objective/absorb/absorb_objective = new
	absorb_objective.owner = changeling
	absorb_objective.gen_amount_goal(2, 3)
	changeling.objectives += absorb_objective

	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = changeling
	kill_objective.find_target()
	changeling.objectives += kill_objective

	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = changeling
	steal_objective.find_target()
	changeling.objectives += steal_objective

	switch(rand(1,100))
		if(1 to 80)
			if (!(locate(/datum/objective/escape) in changeling.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = changeling
				changeling.objectives += escape_objective
		else
			if (!(locate(/datum/objective/survive) in changeling.objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = changeling
				changeling.objectives += survive_objective
	return

/datum/antagonist/changeling/can_become_antag(var/datum/mind/player, var/ignore_role)
	if(..())
		if(player.current)
			if(ishuman(player.current))
				var/mob/living/carbon/human/H = player.current
				if(H.isSynthetic())
					return 0
				if(H.species.flags & NO_SCAN)
					return 0
				return 1
			else if(isnewplayer(player.current))
				if(player.current.client && player.current.client.prefs)
					var/datum/species/S = all_species[player.current.client.prefs.species]
					if(S && (S.flags & NO_SCAN))
						return 0
					if(player.current.client.prefs.organ_data["torso"] == "cyborg") // Full synthetic.
						return 0
					return 1
 	return 0

/datum/antagonist/changeling/remove_antagonist(var/datum/mind/player, var/show_message = TRUE, var/implanted)
	. = ..()
	if(.)
		remove_verb(player.current, /datum/changeling/proc/EvolutionMenu)
		for(var/datum/power/changeling/P in powerinstances)
			remove_verb(player.current, P.verbpath)

/datum/antagonist/changeling/is_obvious_antag(datum/mind/player)
	if(istype(player.current, /mob/living/simple_animal/hostile/lesser_changeling))
		return TRUE
	return FALSE
