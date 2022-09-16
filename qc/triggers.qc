
entity stemp, otemp, s, old;


void() trigger_reactivate =
{
	self.solid = SOLID_TRIGGER;
};

//=============================================================================

float	SPAWNFLAG_NOMESSAGE = 1;
float	SPAWNFLAG_NOTOUCH = 1;
//float	NO_TELEFRAG = 2;  ijed This was never here, it's in defs
//float	ONLY_TELEFRAG = 4; ijed As above

// the wait time has passed, so set back up for another activation
void() multi_wait =
{
	if (self.max_health)
	{
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
	}
};


// the trigger was just touched/killed/used
// self.enemy should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
void() multi_trigger =
{
	if (self.nextthink > time)
	{
		return;		// allready been triggered
	}

	if (self.classname == "trigger_secret")
	{
		if (self.enemy.classname != "player")
			return;
		found_secrets = found_secrets + 1;
		WriteByte (MSG_ALL, SVC_FOUNDSECRET);
	}
	else if (self.classname == "trigger_checkpoint")	// ijed: Supa, checkpoint support
	{
		if (self.enemy.classname != "player")
			return;
		
		self.enemy.hit_checkpoint = TRUE;
		stuffcmd (self.enemy, "save quick\n");	// 20111215 Supa checkpoints write to quick save slot
	}

	if (self.noise)
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

// don't trigger again until reset
	self.takedamage = DAMAGE_NO;

	activator = self.enemy;
	
	SUB_UseTargets();

	if (self.wait > 0)	
	{
		self.think = multi_wait;
		self.nextthink = time + self.wait;
	}
	else
	{	// we can't just remove (self) here, because this is a touch function
		// called wheil C code is looping through area links...
		self.touch = SUB_Null;
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}
};

void() multi_killed =
{
	if (self.is_waiting)	// Supa, restore health and do nothing if we're still waiting to be activated
	{
		self.health		= self.max_health;	// nyah nyah~!
		self.takedamage	= DAMAGE_YES;
		self.solid		= SOLID_BBOX;
		
		return;
	}
	
	self.enemy = damage_attacker;
	multi_trigger();
};

void() multi_use =
{
	if (self.is_waiting)	// Supa, if this trigger is waiting to be activated we'll tell it to get ready!
	{
		self.is_waiting = FALSE;	// Get ready!
		
		return;	// Must be used or triggered again to do anything
	}

	self.enemy = activator;
	multi_trigger();
};

void() multi_touch =
{
	if (other.classname != "player")
		return;
	
	if (self.is_waiting)	// Supa, is this trigger waiting to be activated?
		return;
		
	if ((self.spawnflags & NO_TELEFRAG) && (other.telefragged == 1))  //set as no telefrag and the touching player is, so do nothing
		return;
		
	if ((self.spawnflags & ONLY_TELEFRAG) && (other.telefragged == 0))  //set as telefrag only and the touching player isn't, so do nothing
		return;
	
// if the trigger has an angles field, check player's facing direction
	if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}
	
	self.enemy = other;
	multi_trigger ();
};

/*QUAKED trigger_multiple (.5 .5 .5) ? notouch
Variable sized repeatable trigger.  Must be targeted at one or more entities.  If "health" is set, the trigger must be killed to activate each time.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay!
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
"is_waiting" : If set to 1, this trigger will do nothing until another trigger activates it
*/
void() trigger_multiple =
{
	if (self.is_waiting)
	{
		dprint("Spawned a waiting ");
		dprint(self.classname);
		dprint(" with targetname ");
		dprint(self.targetname);
		dprint(" and target ");
		dprint(self.target);
		dprint("\n");
	}
	
	if (self.sounds == 1)
	{
		precache_sound ("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}
	else if (self.sounds == 3)
	{
		precache_sound ("misc/trigger1.wav");
		self.noise = "misc/trigger1.wav";
	}
	
	if (!self.wait)
		self.wait = 0.2;
	self.use = multi_use;

	InitTrigger ();

	if (self.health)
	{
		if (self.spawnflags & SPAWNFLAG_NOTOUCH)
			objerror ("health and notouch don't make sense\n");
		self.max_health = self.health;
		self.th_die = multi_killed;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin (self, self.origin);	// make sure it links into the world
	}
	else
	{
		if ( !(self.spawnflags & SPAWNFLAG_NOTOUCH) )
		{
			self.touch = multi_touch;
		}
	}
};


/*QUAKED trigger_once (.5 .5 .5) ? notouch
Variable sized trigger. Triggers once, then removes itself.  You must set the key "target" to the name of another object in the level that has a matching
"targetname".  If "health" is set, the trigger must be killed to activate.
If notouch is set, the trigger is only fired by other entities, not by touching.
if "killtarget" is set, any objects that have a matching "target" will be removed when the trigger is fired.
if "angle" is set, the trigger will only fire when someone is facing the direction of the angle.  Use "360" for an angle of 0.
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
"is_waiting" : If set to 1, this trigger will do nothing until another trigger activates it
*/
void() trigger_once =
{
	self.wait = -1;
	trigger_multiple();
};

//=============================================================================

/*QUAKED trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/
void() trigger_relay =
{
	self.use = SUB_UseTargets;
};


//=============================================================================

/*QUAKED trigger_secret (.5 .5 .5) ?
secret counter trigger
sounds
1)	secret
2)	beep beep
3)
4)
set "message" to text string
*/
void() trigger_secret =
{
	total_secrets = total_secrets + 1;
	self.wait = -1;
	if (!self.message)
		self.message = "You found a secret area!";
	if (!self.sounds)
		self.sounds = 1;
	
	if (self.sounds == 1)
	{
		precache_sound ("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}
	
	trigger_multiple ();
};

//=============================================================================

// Supa, checkpoint support

/*QUAKED trigger_checkpoint (.5 .5 .5) ?
single use trigger, saves checkpoint.sav on touch and the player will automatically load that save on death
*/
void() trigger_checkpoint =
{
	self.wait = -1;
	
	trigger_multiple ();
};

//=============================================================================

void() counter_use =
{
	local string junk;

	self.count = self.count - 1;
	if (self.count < 0)
		return;
	
	if (self.count != 0)
	{
		if (activator.classname == "player"
		&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		{
			if (self.count >= 4)
				centerprint (activator, "There are more to go...");
			else if (self.count == 3)
				centerprint (activator, "Only 3 more to go...");
			else if (self.count == 2)
				centerprint (activator, "Only 2 more to go...");
			else
				centerprint (activator, "Only 1 more to go...");
		}
		return;
	}
	
	if (activator.classname == "player"
	&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		centerprint(activator, "Sequence completed!");
	self.enemy = activator;
	multi_trigger ();
};

/*QUAKED trigger_counter (.5 .5 .5) (-8 -8 -8) (8 8 8) nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
void() trigger_counter =
{
	self.wait = -1;
	if (!self.count)
		self.count = 2;

	self.use = counter_use;
};


/*
==============================================================================

TELEPORT TRIGGERS

==============================================================================
*/

float	PLAYER_ONLY	= 1;
//float	SILENT = 2; went to defs

void() play_teleport =
{
	local	float v;
	local	string tmpstr;

	v = random() * 5;
	if (v < 1)
		tmpstr = "misc/r_tele1.wav";
	else if (v < 2)
		tmpstr = "misc/r_tele2.wav";
	else if (v < 3)
		tmpstr = "misc/r_tele3.wav";
	else if (v < 4)
		tmpstr = "misc/r_tele4.wav";
	else
		tmpstr = "misc/r_tele5.wav";

	sound (self, CHAN_VOICE, tmpstr, 1, ATTN_NORM);
	remove (self);
};

void(vector org) spawn_tfog =
{
	s = spawn ();
	s.origin = org;
	s.nextthink = time + 0.2;
	s.think = play_teleport;

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TELEPORT);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
};


void() tdeath_touch =
{
	if (other == self.owner)
		return;

// frag anyone who teleports in on top of an invincible player
	if (other.classname == "player")
	{
		if (other.invincible_finished > time)
			self.classname = "teledeath2";
		if (self.owner.classname != "player")
		{	// other monsters explode themselves
			T_Damage (self.owner, self, self, 50000);
			return;
		}
		
	}

	if (other.health)
	{
		T_Damage (other, self, self, 50000);
	}
};


void(vector org, entity death_owner) spawn_tdeath =
{
local entity	death;

	death = spawn();
	death.classname = "teledeath";
	death.movetype = MOVETYPE_NONE;
	death.solid = SOLID_TRIGGER;
	death.angles = '0 0 0';
	setsize (death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
	setorigin (death, org);
	death.touch = tdeath_touch;
	death.nextthink = time + 0.2;
	death.think = SUB_Remove;
	death.owner = death_owner;
	
	force_retouch = 2;		// make sure even still objects get hit
};

void() teleport_touch =
{
local entity	t;
local vector	org;

	if (self.targetname)
	{
		if (self.nextthink < time)
		{
			return;		// not fired yet
		}
	}

	if (self.spawnflags & PLAYER_ONLY)
	{
		if (other.classname != "player")
			return;
	}

	if (self.is_waiting == TRUE)	// Supa, is this trigger waiting to be activated?
		return;
	
	if (self.is_waiting != -1)	// Special case
	if (self.targetname)
	{
		if (self.nextthink < time)
		{
			return;		// not fired yet
		}
	}

// only teleport living creatures
	if (other.health <= 0 || other.solid != SOLID_SLIDEBOX)
		return;

	SUB_UseTargets ();

// put a tfog where the player was
	spawn_tfog (other.origin);

	t = find (world, targetname, self.target);
	if (!t)
		objerror ("couldn't find target");
		
// spawn a tfog flash in front of the destination
	makevectors (t.mangle);
	org = t.origin + 32 * v_forward;

	spawn_tfog (org);
	spawn_tdeath(t.origin, other);

// move the player and lock him down for a little while
	if (!other.health)
	{
		other.origin = t.origin;
		other.velocity = (v_forward * other.velocity_x) + (v_forward * other.velocity_y);
		return;
	}

	setorigin (other, t.origin);
	other.angles = t.mangle;
	if (other.classname == "player")
	{
		other.fixangle = 1;		// turn this way immediately
		other.teleport_time = time + 0.7;
		if (other.flags & FL_ONGROUND)
			other.flags = other.flags - FL_ONGROUND;
		other.velocity = v_forward * 300;
	}
	other.flags = other.flags - other.flags & FL_ONGROUND;
};

/*QUAKED info_teleport_destination (.5 .5 .5) (-8 -8 -8) (8 8 32)
This is the destination marker for a teleporter.  It should have a "targetname" field with the same value as a teleporter's "target" field.
*/
void() info_teleport_destination =
{
// this does nothing, just serves as a target spot
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.model = "";
	self.origin = self.origin + '0 0 27';
	if (!self.targetname)
		objerror ("no targetname");
};

void() teleport_use =
{
	if (self.is_waiting)	// Supa, if this trigger is waiting to be activated we'll tell it to get ready!
	{
		self.is_waiting = -1;	// Special case to tell teleport_touch to ignore the usual targetname->nextthink check
		
		return;	// Must be used or triggered again to do anything
	}
	
	self.nextthink = time + 0.2;
	force_retouch = 2;		// make sure even still objects get hit
	self.think = SUB_Null;
};

/*QUAKED trigger_teleport (.5 .5 .5) ? PLAYER_ONLY SILENT
Any object touching this will be transported to the corresponding info_teleport_destination entity. You must set the "target" field, and create an object with a "targetname" field that matches.

If the trigger_teleport has a targetname, it will only teleport entities when it has been fired.
"is_waiting" : If set to 1, this trigger will do nothing until another trigger activates it
*/
void() trigger_teleport =
{
	local vector o;

	InitTrigger ();
	self.touch = teleport_touch;
	// find the destination 
	if (!self.target)
		objerror ("no target");
	self.use = teleport_use;

	if (self.is_waiting)
	{
		dprint("Spawned a waiting trigger_teleport with targetname ");
		dprint(self.targetname);
		dprint(" and target ");
		dprint(self.target);
		dprint("\n");
	}
	
	if (!(self.spawnflags & SILENT))
	{
		precache_sound ("ambience/hum1.wav");
		o = (self.mins + self.maxs)*0.5;
		ambientsound (o, "ambience/hum1.wav",0.5 , ATTN_STATIC);
	}
};

/*
==============================================================================

trigger_setskill

==============================================================================
*/

void() trigger_skill_touch =
{
	if (other.classname != "player")
		return;
		
	cvar_set ("skill", self.message);
};

//johnfitz -- make it targetable
void() trigger_skill_use =
{
	if (activator.classname != "player")
		return;
		
	cvar_set ("skill", self.message);
};
//johnfitz

/*QUAKED trigger_setskill (.5 .5 .5) ?
sets skill level to the value of "message".
Only used on start map.
*/
void() trigger_setskill =
{
	InitTrigger ();
	self.touch = trigger_skill_touch;
	self.use = trigger_skill_use; //johnfitz -- make it targetable
};


/*
==============================================================================

ONLY REGISTERED TRIGGERS

==============================================================================
*/

void() trigger_onlyregistered_touch =
{
	if (other.classname != "player")
		return;
	if (self.attack_finished > time)
		return;

	self.attack_finished = time + 2;
	if (cvar("registered"))
	{
		self.message = "";
		SUB_UseTargets ();
		remove (self);
	}
	else
	{
		if (self.message != "")
		{
			centerprint (other, self.message);
			sound (other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
		}
	}
};

/*QUAKED trigger_onlyregistered (.5 .5 .5) ?
Only fires if playing the registered version, otherwise prints the message
*/
void() trigger_onlyregistered =
{
	precache_sound ("misc/talk.wav");
	InitTrigger ();
	self.touch = trigger_onlyregistered_touch;
};

//============================================================================

void() hurt_on =
{
	self.solid = SOLID_TRIGGER;
	self.nextthink = -1;
};

void() hurt_touch =
{
	if (self.is_waiting) return;
	
	if (other.takedamage)
	{
		self.solid = SOLID_NOT;
		T_Damage (other, self, self, self.dmg);
		self.think = hurt_on;
		self.nextthink = time + 1;
	}

	return;
};

void() trigger_hurt_use =      
{
  self.is_waiting = !self.is_waiting;
}

/*QUAKED trigger_hurt (.5 .5 .5) ?
Any object touching this will be hurt
set dmg to damage amount
defalt dmg = 5
*/
void() trigger_hurt =
{
	InitTrigger ();
	self.touch = hurt_touch;
	if (!self.dmg)
		self.dmg = 5;
	
	if (self.targetname) 
	{
		self.is_waiting = TRUE;
		self.use = trigger_hurt_use;
	}
	else self.is_waiting = FALSE;
		
};

//============================================================================

float PUSH_ONCE = 1;

void() trigger_push_touch =
{
	if (self.is_waiting) return;
	if (other.classname == "grenade")
		other.velocity = self.speed * self.movedir * 10;
	else if (other.health > 0)
	{
		//ijed Telefrag checks, these are used for mischief, mainly
		if ((self.spawnflags & NO_TELEFRAG) && (other.telefragged == 1))  //set as no telefrag and the touching player is, so do nothing
			return;
		
		if ((self.spawnflags & ONLY_TELEFRAG) && (other.telefragged == 0))  //set as telefrag only and the touching player isn't, so do nothing
			return;

	
		other.velocity = self.speed * self.movedir * 10;
		if (other.classname == "player")
		{
			if (other.fly_sound < time)
			{
				other.fly_sound = time + 1.5;
				sound (other, CHAN_AUTO, "ambience/windfly.wav", 1, ATTN_NORM);
			}
		}
	}
	if (self.spawnflags & PUSH_ONCE)
		remove(self);
};

void() trigger_push_use =      
{
  self.is_waiting = !self.is_waiting;
}

/*QUAKED trigger_push (.5 .5 .5) ? PUSH_ONCE
Pushes the player
*/
void() trigger_push =
{
	InitTrigger ();
	precache_sound ("ambience/windfly.wav");
	self.touch = trigger_push_touch;
	if (self.targetname) 
	{               // digs 31.03.2012
		self.is_waiting = TRUE;
		self.use = trigger_push_use;
	}
	else self.is_waiting = FALSE;
	
	if (!self.speed)
		self.speed = 1000;
};

//============================================================================

void() trigger_monsterjump_touch =
{
	if ( other.flags & (FL_MONSTER | FL_FLY | FL_SWIM) != FL_MONSTER )
		return;
	
	if (self.spawnflags & ONLY_MELEE)   //treats dreadnought as a melee monster
	{
		if ((other.classname == "monster_shalrath") || //nothing that's only ranged
			(other.classname == "monster_enforcer") ||
			(other.classname == "monster_army") ||
			(other.classname == "monster_zombie") ||
			(other.classname == "monster_floyd") ||
			(other.classname == "monster_mr_big") ||
			(other.classname == "monster_hunter") ||
			(other.classname == "monster_ogre_marksman"))	//Another difference for these 
				return;
	} 

	if (self.spawnflags & ONLY_ENRAGED)  //monsters at 50% health or less in order to jump
	{
		if (other.health > (other.health / 2))
			return;
		else if (other.classname == "monster_zombie")  //undead are never angry:  low blood preassure
			return;
	}
	
// set XY even if not on ground, so the jump will clear lips
	other.velocity_x = self.movedir_x * self.speed;
	other.velocity_y = self.movedir_y * self.speed;
	
	if ( !(other.flags & FL_ONGROUND) )
		return;
	
	//other.SightSound ();  TESTME
	
	other.flags = other.flags - FL_ONGROUND;

	other.velocity_z = self.height;
};

/*QUAKED trigger_monsterjump (.5 .5 .5) ONLY_ENRAGED ONLY_MELEE
Walking monsters that touch this will jump in the direction of the trigger's angle
"speed" default to 200, the speed thrown forward
"height" default to 200, the speed thrown upwards
*/
void() trigger_monsterjump =
{
	if (!self.speed)
		self.speed = 200;
	if (!self.height)
		self.height = 200;
	if (self.angles == '0 0 0')
		self.angles = '0 360 0';
	InitTrigger ();
	self.touch = trigger_monsterjump_touch;
};

void()	trigger_telefrag_touch =
{
	if (other.classname != "player")
		return;
	
	if (self.spawnflags & MEDBAY)
	{
		if (other.telefragged == 1)	//it's a medbay and being touching by a telefragged player
		{
			StopTelefrag(other);
			
			activator = other;
		
			SUB_UseTargets();
			
			//some effects
			particle (self.origin, '0 0 40', 220, 200);
			sound(other, CHAN_ITEM, "items/r_item2.wav", 1, ATTN_NORM);
			
			self.touch = SUB_Null;
			self.think = SUB_Remove;
			self.nextthink = time;
		}
		else					//it's a medbay being touched by a healthy player, do nothin
			return;
	}
	else if (other.telefragged == 0)	//it's a telefragger and being touched by a healthy player
	{
		StartTelefrag(other);
		
		activator = other;
	
		SUB_UseTargets();
		
		self.touch = SUB_Null;
		self.think = SUB_Remove;
		self.nextthink = time;
	}
};

//ijed Telefrag trigger code
void()	trigger_telefrag =
{
	if (self.spawnflags & MEDBAY)				
		precache_sound("items/r_item2.wav");

	InitTrigger ();
	self.touch = trigger_telefrag_touch;
};

// The following written by Frank Condello <pox@planetquake.com>
// Licensed under the GPL

/*QUAKED trigger_changedir (.5 .5 .5) (-8 -8 -8) (8 8 8) ?
Causes func_train_ext and func_watertrain to change directions if ALLOWCHANGEDIR is
set, or reverses the spin of func_emitter and func_emitter_volume. If the target is
moving, it continues in opposite direction, if the target is stopped, it will move
in opposite direction on the next movement trigger.
*/

void() trigger_changedir =
{
	self.classname = "t_changedir";
	self.use = SUB_UseTargets;
};


/*QUAKED trigger_forward (.5 .5 .5) (-8 -8 -8) (8 8 8) ?
Causes func_train_ext and func_watertrain to move forward. It automatically changes
direction if going the wrong way. Direction changes are made regardless if ALLOWCHANGEDIR
is set or not.  It will also cause func_emitter and func_emitter_volume with avelocity
to spin in the forward direction. This trigger will start motion if the target is stopped,
but will never stop it.
*/

void() trigger_forward =
{
	self.classname = "t_forward";
	self.use = SUB_UseTargets;
};

/*QUAKED trigger_reverse (.5 .5 .5) (-8 -8 -8) (8 8 8) ?
Causes func_train_ext and func_watertrain to move in reverse. It automatically changes
direction if going the wrong way. Direction changes are made regardless if ALLOWCHANGEDIR
is set or not. It will also cause func_emitter and func_emitter_volume with avelocity
to spin in the reverse direction. This trigger will start motion if the target is stopped,
but will never stop it.
*/

void() trigger_reverse =
{
	self.classname = "t_reverse";
	self.use = SUB_UseTargets;
};


/*QUAKED trigger_stop (.5 .5 .5) (-8 -8 -8) (8 8 8) ?
Causes func_train_ext and func_watertrain to stop, or func_emitter and func_emitter_volume
with avelocity to stop rotating. If the target is already stopped, this trigger is ignored.
*/

void() trigger_stop =
{
	self.classname = "t_stop";
	self.use = SUB_UseTargets;
};


/*QUAKED trigger_go (.5 .5 .5) (-8 -8 -8) (8 8 8) ?
Causes func_train_ext and func_watertrain to start moving, or func_emitter and func_emitter_volume
with avelocity to start rotating. If the target is already moving, this trigger is ignored.
*/

void() trigger_go =
{
	self.classname = "t_go";
	self.use = SUB_UseTargets;
};

// gb, hipnotic
// Supa 2010-08-22 auto-terminate commands
// Supa 2011-05-24 wait, localcmd, really? ... seriously?
void() trigger_command_use =
{
	if (self.message)
	{
		stuffcmd(activator, self.message);
		stuffcmd(activator, "\n");
	}
};

void() trigger_command_touch =
{
	if (other.classname != "player")
		return;
	
	if (self.is_waiting)	// Supa, is this trigger waiting to be activated?
		return;
	
// if the trigger has an angles field, check player's facing direction
	if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}

	activator = other;
	trigger_command_use ();
};

/*QUAKED trigger_command (.5 .5 .5) (-10 -10 -8) (10 10 8)
 When triggered, stuffs a command into the console to allow map
 designers to set server variables.

 "message" is the command to send to the console.
*/
// Supa 2011-05-24 wtf, Hipnotic, how the _fuck_ can you get _paid_ for writing THIS?! ... De-broke trigger_command for the most part by, oh, I don't know, maybe making sure it doesn't try to send commands to the SERVER and not triggering on MONSTER TOUCH FFS WTF *AUUUUUUGH*

void() trigger_command =
{
	InitTrigger();
	self.use	= trigger_command_use;
	self.touch	= trigger_command_touch;
	self.think	= SUB_Null;
};

// gb, from Chapters source, by Necros
void() trigger_void_touch =
{
	if (other.takedamage)
	{		
		T_Damage (other, self, self, other.health + 1);
		
		if (other.flags & FL_MONSTER)
			remove(other);
	}

	if (other.classname == "gib" ||
	other.classname == "grenade" ||
	other.classname == "spike" ||
	other.classname == "missile")
		remove(other);	
	
	if (other.flags & FL_ITEM)
		remove(other);

	//force_retouch = 2;
};

/*QUAKED trigger_void (.5 .5 .5) ?
Use this for a 'void' area.  removes monsters, gibs, ammo, etc...  also kills player.
*/
void() trigger_void =
{
	InitTrigger ();
	self.touch = trigger_void_touch;
};

// ===== TRIGGER_SHAKE =======================================================

float VIEWONLY = 1;

void() shake_think =
{
	if (self.attack_finished < time)	// Done
	{
		self.nextthink = -1;
		
		if (self.noise1)
			sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
			
		return;
	}
	
	local	entity plyr;
	
	// Shake all players in the effect radius...
	
	plyr = findradius(self.origin, self.count);
	
	while(plyr)
	{
		if (plyr.flags & FL_CLIENT)
		{	
			local float	d;
			
			// Scale effect by distance
			d = vlen(self.origin - plyr.origin);
			d = (self.count - d)/self.count;
			
			if (d > 0)
			{
				// shake up the view
				plyr.punchangle_x = -1 * (random() + (0.025*self.dmg*d));
				
				// push the player around
				if (plyr.flags & FL_ONGROUND && !(self.spawnflags & VIEWONLY))
				{
					d = self.dmg*d;
					plyr.velocity_x = plyr.velocity_x + (random()*d*2 - d);
					plyr.velocity_y = plyr.velocity_y + (random()*d*2 - d);
					plyr.velocity_z = plyr.velocity_z + (random()*d);// always push up
				}	
			}
		}
		
		plyr = plyr.chain;
	}
	
	// keep going
	self.nextthink = time + 0.1;
};

void() shake_use =
{
	if (self.attack_finished > time) return;// already active

	// Start...
	
	if (self.noise)
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	
	self.attack_finished = time + self.wait;
	self.nextthink = time + 0.1;
};

/*QUAKED trigger_shake (.5 .5 .5) (-8 -8 -8) (8 8 8) VIEWONLY
Earthquake trigger - shakes players in it's radius when active.
Strength of tremor is greatest at the centre.

"dmg"			Strength at center (default is 120)
"wait"			Duration of shake (default is 1)
"count"			Affect radius (defalt is 200)
"noise"			Noise to play when starting to shake
"noise1"		Noise to play when stopping
"targetname"	Must be triggered

Spawnflags:
"VIEWONLY"		Shakes the view, but player movement is not affected

*/
void() trigger_shake =
{	
	if (!self.targetname) objerror("trigger_shake without name");

	if (self.noise) precache_sound (self.noise);
	if (self.noise1) precache_sound (self.noise1);
	
	if (!self.dmg) self.dmg = 120;
	if (self.count <= 0) self.count = 200;
	if (self.wait <= 0) self.wait = 1.0;
	
	setorigin(self, self.origin);
	
	self.nextthink = -1;
	self.think = shake_think;
	self.use = shake_use;
};
