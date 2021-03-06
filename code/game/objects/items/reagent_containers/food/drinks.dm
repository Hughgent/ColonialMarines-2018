////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_container/food/drinks
	name = "drink"
	desc = "yummy"
	icon = 'icons/obj/items/drinks.dmi'
	icon_state = null
	container_type = OPENCONTAINER_NOUNIT
	var/gulp_size = 5 //This is now officially broken ... need to think of a nice way to fix it.
	possible_transfer_amounts = list(5,10,25)
	volume = 50

/obj/item/reagent_container/food/drinks/on_reagent_change()
	if (gulp_size < 5) gulp_size = 5
	else gulp_size = max(round(reagents.total_volume / 5), 5)

/obj/item/reagent_container/food/drinks/attack_self(mob/user as mob)
	return

/obj/item/reagent_container/food/drinks/attack(mob/M as mob, mob/user as mob, def_zone)
	var/datum/reagents/R = src.reagents
	var/fillevel = gulp_size

	if(!R.total_volume || !R)
		to_chat(user, "<span class='warning'>The [src.name] is empty!</span>")
		return FALSE

	if(M == user)

		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.species.flags & IS_SYNTHETIC)
				to_chat(H, "<span class='warning'>You have a monitor for a head, where do you think you're going to put that?</span>")
				return

		to_chat(M,"<span class='notice'>You swallow a gulp from \the [src].</span>")
		if(reagents.total_volume)
			reagents.reaction(M, INGEST)
			reagents.trans_to(M, gulp_size)

		playsound(M.loc,'sound/items/drink.ogg', 15, 1)
		return TRUE
	else if(istype(M,/mob/living/carbon/human))

		var/mob/living/carbon/human/H = M
		if(H.species.flags & IS_SYNTHETIC)
			to_chat(H, "<span class='warning'>They have a monitor for a head, where do you think you're going to put that?</span>")
			return

		for(var/mob/O in viewers(world.view, user))
			O.show_message("<span class='warning'>[user] attempts to feed [M] [src].</span>", 1)
		if(!do_mob(user, M, 30, BUSY_ICON_FRIENDLY))
			return
		for(var/mob/O in viewers(world.view, user))
			O.show_message("<span class='warning'>[user] feeds [M] [src].</span>", 1)

		var/rgt_list_text = get_reagent_list_text()

		log_combat(user, M, "fed", src, "Reagents: [rgt_list_text]")
		msg_admin_attack("[key_name(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[usr.x];Y=[usr.y];Z=[usr.z]'>JMP</a>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[usr]'>FLW</a>) fed [key_name(M)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[M]'>FLW</a>) with [src.name] Reagents: [rgt_list_text] (INTENT: [uppertext(user.a_intent)])")

		if(reagents.total_volume)
			reagents.reaction(M, INGEST)
			reagents.trans_to(M, gulp_size)

		if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
			var/mob/living/silicon/robot/bro = user
			bro.cell.use(30)
			var/refill = R.get_master_reagent_id()
			spawn(600)
				R.add_reagent(refill, fillevel)

		playsound(M.loc,'sound/items/drink.ogg', 15, 1)
		return TRUE

	return FALSE


/obj/item/reagent_container/food/drinks/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return

	if(target.is_refillable())
		if(!is_drainable())
			to_chat(user, "<span class='notice'>[src]'s tab isn't open!</span>")
			return
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty.</span>")
			return
		if(target.reagents.holder_full())
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return

		var/datum/reagent/refill
		var/datum/reagent/refillName
		if(isrobot(user))
			refill = reagents.get_master_reagent_id()
			refillName = reagents.get_master_reagent_name()

		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the solution to [target].</span>")

		if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
			var/mob/living/silicon/robot/bro = user
			var/chargeAmount = max(30,4*trans)
			bro.cell.use(chargeAmount)
			to_chat(user, "Now synthesizing [trans] units of [refillName]...")


			spawn(300)
				reagents.add_reagent(refill, trans)
				to_chat(user, "Cyborg [src] refilled.")

	else if(target.is_drainable()) //A dispenser Transfer FROM it TO us.
		if(!is_refillable())
			to_chat(user, "<span class='notice'>[src]'s tab isn't open!</span>")
			return
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty.</span>")
			return
		if(reagents.holder_full())
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

	return ..()

////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_container/food/drinks/golden_cup
	desc = "You're winner!"
	name = "golden cup"
	icon_state = "golden_cup"
	item_state = "" //nope :(
	w_class = 4
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = null
	volume = 150
	flags_atom = CONDUCT

/obj/item/reagent_container/food/drinks/golden_cup/tournament_26_06_2011
	desc = "A golden cup. It will be presented to a winner of tournament 26 june and name of the winner will be graved on it."


///////////////////////////////////////////////Drinks
//Notes by Darem: Drinks are simply containers that start preloaded. Unlike condiments, the contents can be ingested directly
//	rather then having to add it to something else first. They should only contain liquids. They have a default container size of 50.
//	Formatting is the same as food.

/obj/item/reagent_container/food/drinks/milk
	name = "Space Milk"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	item_state = "carton"
	center_of_mass = list("x"=16, "y"=9)
	list_reagents = list("milk" = 50)

/* Flour is no longer a reagent
/obj/item/reagent_container/food/drinks/flour
	name = "flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon = 'icons/obj/items/food.dmi'
	icon_state = "flour"
	item_state = "flour"
	center_of_mass = list(x=-10, y=-10)
	list_reagents = list("flour" = 30)
*/

/obj/item/reagent_container/food/drinks/soymilk
	name = "soy milk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon_state = "soymilk"
	item_state = "carton"
	center_of_mass = list("x"=16, "y"=9)
	list_reagents = list("soymilk" = 50)

/obj/item/reagent_container/food/drinks/coffee
	name = "\improper Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	center_of_mass = list("x"=15, "y"=10)
	list_reagents = list("coffee" = 30)

/obj/item/reagent_container/food/drinks/tea
	name = "\improper Duke Purple Tea"
	desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
	icon_state = "teacup"
	item_state = "coffee"
	center_of_mass = list("x"=16, "y"=14)
	list_reagents = list("tea" = 30)

/obj/item/reagent_container/food/drinks/ice
	name = "ice cup"
	desc = "Careful, cold ice, do not chew."
	icon_state = "coffee"
	center_of_mass = list("x"=15, "y"=10)
	list_reagents = list("ice" = 30)

/obj/item/reagent_container/food/drinks/h_chocolate
	name = "\improper Dutch hot coco"
	desc = "Made in Space South America."
	icon_state = "hot_coco"
	item_state = "coffee"
	center_of_mass = list("x"=15, "y"=13)
	list_reagents = list("hot_coco" = 30)

/obj/item/reagent_container/food/drinks/dry_ramen
	name = "cup ramen"
	desc = "Just add 10ml water, self heats! A taste that reminds you of your school years."
	icon_state = "ramen"
	center_of_mass = list("x"=16, "y"=11)
	list_reagents = list("dry_ramen" = 30)

/obj/item/reagent_container/food/drinks/sillycup
	name = "paper cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	possible_transfer_amounts = null
	volume = 10
	center_of_mass = list("x"=16, "y"=12)

/obj/item/reagent_container/food/drinks/sillycup/on_reagent_change()
	if(reagents.total_volume)
		icon_state = "water_cup"
	else
		icon_state = "water_cup_e"


//////////////////////////drinkingglass and shaker//
//Note by Darem: This code handles the mixing of drinks. New drinks go in three places: In Chemistry-Reagents.dm (for the drink
//	itself), in Chemistry-Recipes.dm (for the reaction that changes the components into the drink), and here (for the drinking glass
//	icon states.

/obj/item/reagent_container/food/drinks/shaker
	name = "shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	amount_per_transfer_from_this = 10
	volume = 100
	center_of_mass = list("x"=17, "y"=10)

/obj/item/reagent_container/food/drinks/flask
	name = "metal flask"
	desc = "A metal flask with a decent liquid capacity."
	icon_state = "flask"
	volume = 60
	center_of_mass = list("x"=17, "y"=8)

/obj/item/reagent_container/food/drinks/flask/marine
	name = "\improper USCM flask"
	desc = "A metal flask embossed with the USCM logo and probably filled with a slurry of water, motor oil, and medicinal alcohol."
	icon_state = "flask_uscm"
	center_of_mass = list("x"=17, "y"=8)
	list_reagents = list("water" = 51, "hooch" = 9)

/obj/item/reagent_container/food/drinks/flask/detflask
	name = "detective's flask"
	desc = "A metal flask with a leather band and golden badge belonging to the detective."
	icon_state = "detflask"
	center_of_mass = list("x"=17, "y"=8)
	list_reagents = list("whiskey" = 30)

/obj/item/reagent_container/food/drinks/flask/barflask
	name = "flask"
	desc = "For those who can't be bothered to hang out at the bar to drink."
	icon_state = "barflask"
	center_of_mass = list("x"=17, "y"=7)

/obj/item/reagent_container/food/drinks/flask/vacuumflask
	name = "vacuum flask"
	desc = "Keeping your drinks at the perfect temperature since 1892."
	icon_state = "vacuumflask"
	center_of_mass = list("x"=15, "y"=4)

/obj/item/reagent_container/food/drinks/britcup
	name = "cup"
	desc = "A cup with the British flag emblazoned on it. The sight of it irritates you."
	icon_state = "britcup"
	volume = 30
	center_of_mass = list("x"=15, "y"=13)
