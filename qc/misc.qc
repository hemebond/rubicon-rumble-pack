
/*QUAKED info_null (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for spotlights, etc.
*/
void() info_null =
{
	remove(self);
};

/*QUAKED info_notnull (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for lightning.
*/
void() info_notnull =
{
};

//============================================================================

float START_OFF = 1;

void() light_use =
{
	if (self.spawnflags & START_OFF)
	{
		lightstyle(self.style, "m");
		self.spawnflags = self.spawnflags - START_OFF;
	}
	else
	{
		lightstyle(self.style, "a");
		self.spawnflags = self.spawnflags + START_OFF;
	}
};

/*QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
*/
void() light =
{
	if (!self.targetname)
	{	// inert light
		remove(self);
		return;
	}
	
	if (self.style >= 32)
	{
		self.use = light_use;
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, "a");
		else
			lightstyle(self.style, "m");
	}
};

/*QUAKED light_fluoro (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
Makes steady fluorescent humming sound
*/
void() light_fluoro =
{
	if (self.style >= 32)
	{
		self.use = light_use;
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, "a");
		else
			lightstyle(self.style, "m");
	}
	
	precache_sound ("ambience/fl_hum1.wav");
	ambientsound (self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_fluorospark (0 1 0) (-8 -8 -8) (8 8 8)
Non-displayed light.
Default light value is 300
Default style is 10
Makes sparking, broken fluorescent sound
*/
void() light_fluorospark =
{
	if (!self.style)
		self.style = 10;

	precache_sound ("ambience/buzz1.wav");
	ambientsound (self.origin, "ambience/buzz1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_globe (0 1 0) (-8 -8 -8) (8 8 8)
Sphere globe light.
Default light value is 300
Default style is 0
*/
void() light_globe =
{
	precache_model ("progs/s_light.spr");
	setmodel (self, "progs/s_light.spr");
	makestatic (self);
};

void() FireAmbient =
{
	precache_sound ("ambience/fire1.wav");
// attenuate fast
	ambientsound (self.origin, "ambience/fire1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_torch_small_walltorch (0 .5 0) (-10 -10 -20) (10 10 20)
Short wall torch
Default light value is 200
Default style is 0
*/
void() light_torch_small_walltorch =
{
	precache_model ("progs/flame.mdl");
	setmodel (self, "progs/flame.mdl");
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_large_yellow (0 1 0) (-10 -10 -12) (12 12 18)
Large yellow flame ball
*/
void() light_flame_large_yellow =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	self.frame = 1;
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_small_yellow (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Small yellow flame ball
*/
void() light_flame_small_yellow =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_small_white (0 1 0) (-10 -10 -40) (10 10 40) START_OFF
Small white flame ball
*/
void() light_flame_small_white =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_big (0 1 0) (-16 -16 -16) (16 24 16)
Big yellow flame big
*/
void() light_flame_big =
{
	precache_model ("progs/flamebig.mdl");
	setmodel (self, "progs/flamebig.mdl");
	FireAmbient ();
	makestatic (self);
};

//============================================================================


/*QUAKED misc_fireball (0 .5 .8) (-8 -8 -8) (8 8 8)
Lava Balls
*/

void() fire_fly;
void() fire_touch;
void() misc_fireball =
{
	
	precache_model ("progs/lavaball.mdl");
	self.classname = "fireball";
	self.nextthink = time + (random() * 5);
	self.think = fire_fly;
	if (!self.speed)
		self.speed = 1000;
};

void() fire_fly =
{
local entity	fireball;

	fireball = spawn();
	fireball.solid = SOLID_TRIGGER;
	fireball.movetype = MOVETYPE_TOSS;
	fireball.velocity = '0 0 1000';
	fireball.velocity_x = (random() * 100) - 50;
	fireball.velocity_y = (random() * 100) - 50;
	fireball.velocity_z = self.speed + (random() * 200);
	fireball.classname = "fireball";
	setmodel (fireball, "progs/lavaball.mdl");
	setsize (fireball, '0 0 0', '0 0 0');
	setorigin (fireball, self.origin);
	fireball.nextthink = time + 5;
	fireball.think = SUB_Remove;
	fireball.touch = fire_touch;
	
	self.nextthink = time + (random() * 5) + 3;
	self.think = fire_fly;
};


void() fire_touch =
{
	T_Damage (other, self, self, 20);
	remove(self);
};

//============================================================================

void() barrel_explode =
{
	self.takedamage = DAMAGE_NO;
	self.classname = "explo_box";
	// did say self.owner
	T_RadiusDamage (self, self, 160, world);
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);
	particle (self.origin, '0 0 0', 75, 255);

	self.origin_z = self.origin_z + 32;
	BecomeExplosion ();
};


void() monster_tarbaby;
void() tarbaby_cache;
void(vector ang, vector org, void() spawnfunc, string spawnclass) SpawnMonster;

void() tar_barrel_explode =
{
	self.takedamage = DAMAGE_NO;
	self.classname = "explo_box";

	sound (self, CHAN_VOICE, "blob/death1.wav", 1, ATTN_NORM);

	self.origin_z = self.origin_z + 32;
	
	SpawnMonster (self.angles, self.origin, monster_tarbaby, "monster_tarbaby");
	
	/*WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);		This was confusing
	WriteByte (MSG_BROADCAST, TE_TAREXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	BecomeExplosion ();	*/
	
	self.think = SUB_Remove;
	self.nextthink = time + 0.1;
};

/*QUAKED misc_explobox (0 .5 .8) (0 0 0) (32 32 64)
TESTING THING
*/

void() misc_explobox =
{
	local float	oldz;
	
	self.bloodtype = 1;	//sparks
	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	precache_model ("maps/b_explob.bsp");
	setmodel (self, "maps/b_explob.bsp");
	precache_sound ("weapons/r_exp3.wav");
	self.health = 10;	//ijed, was 20
	self.th_die = barrel_explode;
	self.use = barrel_explode;
	self.takedamage = DAMAGE_AIM;

	self.origin_z = self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor();
	if (oldz - self.origin_z > 250)
	{
		dprint ("explobox fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
};

/*QUAKED misc_explobox2 (0 .5 .8) (0 0 0) (32 32 64)
Smaller exploding box, REGISTERED ONLY
*/

void() misc_explobox2 =
{
	local float	oldz;
	
	self.bloodtype = 1;	//sparks
	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	precache_model2 ("maps/b_exbox2.bsp");
	setmodel (self, "maps/b_exbox2.bsp");
	precache_sound ("weapons/r_exp3.wav");
	self.health = 10; //20; ijed 
	self.th_die = barrel_explode;
	self.use = barrel_explode;
	self.takedamage = DAMAGE_AIM;

	self.origin_z = self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor();
	if (oldz - self.origin_z > 250)
	{
		dprint ("explobox fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
};

/*QUAKED misc_tarbox (0 .5 .8) (0 0 0) (32 32 64)
Spawns a tarbaby
*/

void() misc_tarbox =
{
	local float	oldz;
		
	self.bloodtype = 1;	//sparks

	tarbaby_cache();	//precache tarbaby assets
	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	precache_model2 ("maps/b_tarbox.bsp");
	setmodel (self, "maps/b_tarbox.bsp");
	precache_sound ("blob/death1.wav");
	self.health = 10;
	self.th_die = tar_barrel_explode;
	self.use = tar_barrel_explode;
	self.takedamage = DAMAGE_AIM;

	self.origin_z = self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor();
		
	if (oldz - self.origin_z > 250)
	{
		dprint ("tarbox fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
};

//============================================================================

void(vector org, vector vec) LaunchLaser;
void(vector org, vector vec) FLaunchLaser;

void() spikeshooter_use =
{
	if (self.spawnflags & SPAWNFLAG_LASER) 
	{
		sound (self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
		LaunchLaser (self.origin, self.movedir);
	}
	else if (self.spawnflags & SPAWNFLAG_BLUE_LASER)
	{
		sound (self, CHAN_WEAPON, "floyd/fire.wav", 1, ATTN_NORM);
		FLaunchLaser (self.origin, self.movedir);
	}
	else
	{
		sound (self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
		launch_spike (self.origin, self.movedir);
		newmis.velocity = self.movedir * 500;
		if (self.spawnflags & SPAWNFLAG_SUPERSPIKE)
			newmis.touch = superspike_touch;
	}
};

void() shooter_think =
{
	spikeshooter_use ();
	self.nextthink = time + self.wait;
	newmis.velocity = self.movedir * 500;
};


/*QUAKED trap_spikeshooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
When triggered, fires a spike in the direction set in QuakeEd.
Laser is only for REGISTERED.
*/

void() trap_spikeshooter =
{
	SetMovedir ();
	self.use = spikeshooter_use;
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		precache_model2 ("progs/laser.mdl");
		
		precache_sound2 ("enforcer/enfire.wav");
		precache_sound2 ("enforcer/enfstop.wav");
	}
	else if (self.spawnflags & SPAWNFLAG_BLUE_LASER)
	{
		precache_model ("progs/flaser.mdl");
		
		precache_sound ("floyd/fire.wav");
		precache_sound ("enforcer/enfstop.wav");
	}
	else
		precache_sound ("weapons/spike2.wav");
};


/*QUAKED trap_shooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
Continuously fires spikes.
"wait" time between spike (1.0 default)
"nextthink" delay before firing first spike, so multiple shooters can be stagered.
*/
void() trap_shooter =
{
	trap_spikeshooter ();
	
	if (self.wait == 0)
		self.wait = 1;
	self.nextthink = self.nextthink + self.wait + self.ltime;
	self.think = shooter_think;
};



/*
===============================================================================


===============================================================================
*/


void() make_bubbles;
void() bubble_remove;
void() bubble_bob;

/*QUAKED air_bubbles (0 .5 .8) (-8 -8 -8) (8 8 8)

testing air bubbles
*/

void() air_bubbles =

{
	if (deathmatch)
	{
		remove (self);
		return;
	}
	precache_model ("progs/s_bubble.spr");
	self.nextthink = time + 1;
	self.think = make_bubbles;
};

void() make_bubbles =
{
local entity	bubble;

	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.origin);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + random() + 0.5;
	self.think = make_bubbles;
};

void() bubble_split =
{
local entity	bubble;
	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.origin);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = self.velocity;
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	bubble.frame = 1;
	bubble.cnt = 10;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.frame = 1;
	self.cnt = 10;
	if (self.waterlevel != 3)
		remove (self);
};

void() bubble_remove =
{
	if (other.classname == self.classname)
	{
//		dprint ("bump");
		return;
	}
	remove(self);
};

void() bubble_bob =
{
local float		rnd1, rnd2, rnd3;
local vector	vtmp1, modi;

	self.cnt = self.cnt + 1;
	if (self.cnt == 4)
		bubble_split();
	if (self.cnt == 20)
		remove(self);

	rnd1 = self.velocity_x + (-10 + (random() * 20));
	rnd2 = self.velocity_y + (-10 + (random() * 20));
	rnd3 = self.velocity_z + 10 + random() * 10;

	if (rnd1 > 10)
		rnd1 = 5;
	if (rnd1 < -10)
		rnd1 = -5;
		
	if (rnd2 > 10)
		rnd2 = 5;
	if (rnd2 < -10)
		rnd2 = -5;
		
	if (rnd3 < 10)
		rnd3 = 15;
	if (rnd3 > 30)
		rnd3 = 25;
	
	self.velocity_x = rnd1;
	self.velocity_y = rnd2;
	self.velocity_z = rnd3;
		
	self.nextthink = time + 0.5;
	self.think = bubble_bob;
};

/*~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>
~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~*/

/*QUAKED viewthing (0 .5 .8) (-16 -16 -24) (16 16 40)

Just for the debugging level.  Don't use
*/

void() viewthing =

{
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_BBOX;
	setsize (self, '-16 -16 -24', '16 16 40');
	precache_model ("progs/dread.mdl");
	setmodel (self, "progs/dread.mdl");
};


/*
==============================================================================

SIMPLE BMODELS

==============================================================================
*/

void() func_wall_use =
{	// change to alternate textures
	self.frame = 1 - self.frame;
};

/*QUAKED func_wall (0 .5 .8) ?
This is just a solid wall if not inhibitted
*/
void() func_wall =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};


/*QUAKED func_illusionary (0 .5 .8) ?
A simple entity that looks solid but lets you walk through it.
*/
void() func_illusionary =

{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, self.model);
	makestatic (self);
};

/*QUAKED func_episodegate (0 .5 .8) ? E1 E2 E3 E4
This bmodel will appear if the episode has allready been completed, so players can't reenter it.
*/
void() func_episodegate =

{
	if (!(serverflags & self.spawnflags))
		return;			// can still enter episode

	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

/*QUAKED func_bossgate (0 .5 .8) ?
This bmodel appears unless players have all of the episode sigils.
*/
void() func_bossgate =

{
	if ( (serverflags & 15) == 15)
		return;		// all episodes completed
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

//============================================================================

 //johnfitz -- ambient_general
/*QUAKED ambient_general (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
Plays any looped sound

Keys:

"noise" is the wav file to play

"volume" default 1

"speed" attenuation, default 3
*/
void () ambient_general =
{
	precache_sound (self.noise);
	if (!self.speed)
	{
		self.speed = ATTN_STATIC;
	}
	if (!self.volume)
	{
		self.volume = 0.5;
	}
	ambientsound (self.origin, self.noise, self.volume, self.speed);
	remove(self);
};
//johnfitz

/*QUAKED ambient_suck_wind (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_suck_wind =
{
	precache_sound ("ambience/suck1.wav");
	if (!self.speed)
	{
		self.speed = ATTN_STATIC;
	}
	if (!self.volume)
	{
		self.volume = 1;
	}
	ambientsound (self.origin, "ambience/suck1.wav", self.volume, self.speed);
	remove(self); //johnfitz -- reduce edict usage
};

/*QUAKED ambient_drone (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_drone =
{
	precache_sound ("ambience/drone6.wav");
	if (!self.speed)
	{
		self.speed = ATTN_STATIC;
	}
	if (!self.volume)
	{
		self.volume = 0.5;
	}
	ambientsound (self.origin, "ambience/drone6.wav", self.volume, self.speed);
	remove(self); //johnfitz -- reduce edict usage
};

/*QUAKED ambient_flouro_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_flouro_buzz =
{
	precache_sound ("ambience/buzz1.wav");
	if (!self.speed)
	{
		self.speed = ATTN_STATIC;
	}
	if (!self.volume)
	{
		self.volume = 0.5;
	}
	ambientsound (self.origin, "ambience/buzz1.wav", self.volume, self.speed);
	remove(self); //johnfitz -- reduce edict usage
};
/*QUAKED ambient_drip (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_drip =
{
	precache_sound ("ambience/drip1.wav");
	if (!self.speed)
	{
		self.speed = ATTN_STATIC;
	}
	if (!self.volume)
	{
		self.volume = 0.5;
	}
	ambientsound (self.origin, "ambience/drip1.wav", self.volume, self.speed);
	remove(self); //johnfitz -- reduce edict usage
};
/*QUAKED ambient_comp_hum (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_comp_hum =
{
	precache_sound ("ambience/comp1.wav");
	if (!self.speed)
	{
		self.speed = ATTN_STATIC;
	}
	if (!self.volume)
	{
		self.volume = 1;
	}
	ambientsound (self.origin, "ambience/comp1.wav", self.volume, self.speed);
	remove(self); //johnfitz -- reduce edict usage
};
/*QUAKED ambient_thunder (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_thunder =
{
	precache_sound ("ambience/thunder1.wav");
	if (!self.speed)
	{
		self.speed = ATTN_STATIC;
	}
	if (!self.volume)
	{
		self.volume = 0.5;
	}
	ambientsound (self.origin, "ambience/thunder1.wav", self.volume, self.speed);
	remove(self); //johnfitz -- reduce edict usage
};
/*QUAKED ambient_light_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_light_buzz =
{
	precache_sound ("ambience/fl_hum1.wav");
	if (!self.speed)
	{
		self.speed = ATTN_STATIC;
	}
	if (!self.volume)
	{
		self.volume = 0.5;
	}
	ambientsound (self.origin, "ambience/fl_hum1.wav", self.volume, self.speed);
	remove(self); //johnfitz -- reduce edict usage
};
/*QUAKED ambient_swamp1 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_swamp1 =
{
	precache_sound ("ambience/swamp1.wav");
	if (!self.speed)
	{
		self.speed = ATTN_STATIC;
	}
	if (!self.volume)
	{
		self.volume = 0.5;
	}
	ambientsound (self.origin, "ambience/swamp1.wav", self.volume, self.speed);
	remove(self); //johnfitz -- reduce edict usage
};
/*QUAKED ambient_swamp2 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_swamp2 =
{
	precache_sound ("ambience/swamp2.wav");
	if (!self.speed)
	{
		self.speed = ATTN_STATIC;
	}
	if (!self.volume)
	{
		self.volume = 0.5;
	}
	ambientsound (self.origin, "ambience/swamp2.wav", self.volume, self.speed);
	remove(self); //johnfitz -- reduce edict usage
};

//============================================================================

void() noise_think =
{
	self.nextthink = time + 0.5;
	sound (self, 1, "enforcer/enfire.wav", 1, ATTN_NORM);
	sound (self, 2, "enforcer/enfstop.wav", 1, ATTN_NORM);
	sound (self, 3, "enforcer/sight1.wav", 1, ATTN_NORM);
	sound (self, 4, "enforcer/sight2.wav", 1, ATTN_NORM);
	sound (self, 5, "enforcer/sight3.wav", 1, ATTN_NORM);
	sound (self, 6, "enforcer/sight4.wav", 1, ATTN_NORM);
	sound (self, 7, "enforcer/pain1.wav", 1, ATTN_NORM);
};

/*QUAKED misc_noisemaker (1 0.5 0) (-10 -10 -10) (10 10 10)

For optimzation testing, starts a lot of sounds.
*/

void() misc_noisemaker =

{
	precache_sound2 ("enforcer/enfire.wav");
	precache_sound2 ("enforcer/enfstop.wav");
	precache_sound2 ("enforcer/sight1.wav");
	precache_sound2 ("enforcer/sight2.wav");
	precache_sound2 ("enforcer/sight3.wav");
	precache_sound2 ("enforcer/sight4.wav");
	precache_sound2 ("enforcer/pain1.wav");
	precache_sound2 ("enforcer/pain2.wav");
	precache_sound2 ("enforcer/death1.wav");
	precache_sound2 ("enforcer/idle1.wav");

	self.nextthink = time + 0.1 + random();
	self.think = noise_think;
};

/*QUAKED misc_model (.5 .5 .5) (-8 -8 -8) (8 8 8) ? 
Places a static model.
Static models just hang at the origin.

"model"		Path to the model
"mdl"		Can also be used for path to the model
"frame"		Animation frame
"mangle"	pitch yaw roll (NOT x y z)
*/

void() misc_model =
{
	if (self.model)	// radiant does this
		precache_model (self.model);

	else if (self.mdl)
	{
		precache_model (self.mdl);
		self.model = self.mdl;
	}

	else objerror("mapobject with no model");
	
	setmodel (self, self.model);
	setorigin (self, self.origin);
	
	/*if (!self.mangle)
	{
		if (self.angles)
			self.mangle = self.angles;		//ijed adopt angles if mangle not set
		else
			self.mangle = '0 0 0';			//or default it 
	}
	
	self.angles = self.mangle;*/
	
	makestatic (self);
};

//ijed This handles the various generic model setup functions
void(string mapobject) create_mapobject =
{
	precache_model (mapobject);
	setmodel (self, mapobject);
	setorigin (self, self.origin);	
};

/*QUAKED misc_generator (.5 .5 .5) (-30 -30 -8) (30 30 100) ? */
void() misc_generator =
{
	precache_sound ("ambient/drone.wav");
	ambientsound (self.origin, "ambient/drone.wav", 0.5, ATTN_STATIC);	
	precache_model ("progs/gen3.mdl");
	setmodel (self, "progs/gen3.mdl");
	
	if ((self.angles_y == 0) || (self.angles_y == 180))
		setsize (self, '-32 -90 -52', '32 90 52');
	else
		setsize (self, '-90 -32 -52', '90 32 52');
	
	setorigin (self, self.origin);		
	self.solid = SOLID_BBOX;
	self.takedamage = DAMAGE_NO;
};

/*QUAKED misc_machine (.5 .5 .5) (-30 -30 -0) (30 30 100) ? */
void() misc_machine =
{
	precache_sound ("ambient/motor2.wav");
	precache_model ("progs/gen1.mdl");
	
	ambientsound (self.origin, "ambient/motor2.wav", 0.5, ATTN_STATIC);	
	
	setmodel (self, "progs/gen1.mdl");
	setorigin (self, self.origin);		
		
	if ((self.angles_y == 0) || (self.angles_y == 180))
		setsize (self, '-32 -104 -48', '32 104 48');
	else
		setsize (self, '-104 -32 -48', '104 32 48');
		
	self.solid = SOLID_BBOX;
	self.takedamage = DAMAGE_NO;
};

/*QUAKED misc_portable_generator (.5 .5 .5) (-30 -30 -0) (30 30 100) ? */
void() misc_portable_generator =
{
	precache_sound ("ambient/generator_gas.wav");
	precache_model ("progs/gen2.mdl");
	
	ambientsound (self.origin, "ambient/generator_gas.wav", 0.5, ATTN_STATIC);	
	
	setmodel (self, "progs/gen2.mdl");
	setorigin (self, self.origin);
	
	if ((self.angles_y == 0) || (self.angles_y == 180))
		setsize (self, '-16 -24 -16', '16 24 16');
	else if ((self.angles_y == 90) || (self.angles_y == 270))
		setsize (self, '-24 -16 -16', '24 16 16');
	else	//it's randomly rotated, just set a size that will encompass it no matter what
		setsize (self, '-24 -24 -16', '24 24 16');
	
	self.solid = SOLID_BBOX;
	self.takedamage = DAMAGE_NO;
};

/*QUAKED misc_vent (.5 .5 .5) (-8 -8 -8) (8 8 8) ? 
Large solid model that sits there, playing a noise.

"mangle"	pitch yaw roll
*/
void() misc_vent = 
{
	precache_sound ("ambient/intake.wav");
	precache_model ("progs/heating.mdl");
	
	ambientsound (self.origin, "ambient/intake.wav", 0.5, ATTN_STATIC);	
	
	setmodel (self, "progs/heating.mdl");
	setorigin (self, self.origin);
	
	if ((self.angles_y == 0) || (self.angles_y == 180))
		setsize (self, '-24 -48 -58', '24 48 58');
	else
		setsize (self, '-48 -24 -58', '48 24 58');

	self.solid = SOLID_BBOX;
	self.takedamage = DAMAGE_NO;
};

/*QUAKED misc_vent (.5 .5 .5) (-8 -8 -8) (8 8 8) ? 
Large solid model that sits there, playing a noise.

"mangle"	pitch yaw roll
*/
void() misc_helijet = 
{
	precache_model ("progs/helijet.mdl");
	setmodel (self, "progs/helijet.mdl");
	setorigin (self, self.origin);
	
	if ((self.angles_y == 0) || (self.angles_y == 180))
		setsize (self, '-32 -64 -32', '56 80 40');
	else
		setsize (self, '-64 -32 -32', '80 56 40');

	self.solid = SOLID_BBOX;
	self.takedamage = DAMAGE_NO;
};

/*QUAKED misc_vine (.5 .5 .5) (-8 -8 -8) (8 8 8) ? 
Places a vine model, mesh done by preach (http://tomeofpreach.wordpress.com/).
"mangle"	pitch yaw roll 
*/
void() misc_vine =
{
	precache_model ("progs/vine.mdl");
	setmodel (self, "progs/vine.mdl");
	setorigin (self, self.origin);
	
	if (!self.mangle) self.mangle = '0 0 0';
	self.angles = self.mangle;
	
	makestatic (self);
};

/*QUAKED misc_chain (.5 .5 .5) (-8 -8 -8) (8 8 8) ? 
Places a static screen model, author forgotten...  
five skins
six poses, in three groups of two vertical / horizontal and going up in sizes small/medium/large
"mangle"	pitch yaw roll 
*/
void() misc_chain =
{
	create_mapobject("progs/chain.mdl");
	makestatic (self);
};

/*QUAKED misc_screen_oscill (.5 .5 .5) (-8 -8 -8) (8 8 8) ? 
Places a static screen model, mesh done by preach (http://tomeofpreach.wordpress.com/). 
"mangle"	pitch yaw roll 
*/
void() misc_screen_oscill =
{
	create_mapobject("progs/oscill.mdl");
	makestatic (self);
};

/*QUAKED misc_screen_levels (.5 .5 .5) (-8 -8 -8) (8 8 8) ? 
Places a static screen model, mesh done by preach (http://tomeofpreach.wordpress.com/).
"mangle"	pitch yaw roll 
*/
void() misc_screen_levels =
{
	create_mapobject("progs/levels.mdl");
	makestatic (self);
};

/*QUAKED misc_screen_starfield (.5 .5 .5) (-8 -8 -8) (8 8 8) ? 
Places a static screen model, mesh done by preach (http://tomeofpreach.wordpress.com/).
"mangle"	pitch yaw roll 
*/
void() misc_screen_starfield =
{
	create_mapobject("progs/starfield.mdl");
	makestatic (self);
};

/*QUAKED misc_poster (.5 .5 .5) (-8 -8 -16) (8 8 16) ? 
Places a static screen model, mesh done by preach (http://tomeofpreach.wordpress.com/).
"mangle"	pitch yaw roll 
*/
void() misc_poster =
{
	create_mapobject("progs/poster.mdl");
	makestatic (self);
};

/*QUAKED misc_tree (.5 .5 .5) (-8 -8 -16) (8 8 16) ? 
Places a static screen model, mesh done by preach (http://tomeofpreach.wordpress.com/).
"mangle"	pitch yaw roll 
*/
void() misc_tree =
{
	create_mapobject("progs/tree1.mdl");
	setsize(self, '-8 -8 -16', '8 8 128');
	self.movetype = MOVETYPE_NONE;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_SLIDEBOX;
};

/*QUAKED misc_cable (.5 .5 .5) (-8 -8 -16) (8 8 16) ? 
Places a static screen model, mesh done by preach (http://tomeofpreach.wordpress.com/).
*/
void() misc_cable =
{
	create_mapobject("progs/cable.mdl");
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
};

/*QUAKED misc_coil (.5 .5 .5) (-16 -16 -8) (8 8 192) ? 
Places an animated coil of smoke model, mesh done by preach (http://tomeofpreach.wordpress.com/).
Features 8 skins
*/
void() misc_coil =
{
	create_mapobject("progs/smoke.mdl");
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
};

void()	cascade_go_run1		=	[26,	cascade_go_run2		]	{};
void()	cascade_go_run2		=	[27,	cascade_go_run3		]	{};
void()	cascade_go_run3		=	[28,	cascade_go_run4		]	{};
void()	cascade_go_run4		=	[29,	cascade_go_run5		]	{};
void()	cascade_go_run5		=	[30,	cascade_go_run6		]	{};
void()	cascade_go_run6		=	[31,	cascade_go_run7		]	{};
void()	cascade_go_run7		=	[32,	cascade_go_run8		]	{};
void()	cascade_go_run8		=	[33,	cascade_go_run9		]	{};
void()	cascade_go_run9		=	[34,	cascade_go_run10	]	{};
void()	cascade_go_run10	=	[35,	cascade_go_run11	]	{};
void()	cascade_go_run11	=	[36,	cascade_go_run12	]	{};
void()	cascade_go_run12	=	[37,	cascade_go_run13	]	{};
void()	cascade_go_run13	=	[38,	cascade_go_run14	]	{};
void()	cascade_go_run14	=	[39,	cascade_go_run15	]	{};
void()	cascade_go_run15	=	[40,	cascade_go_run16	]	{};
void()	cascade_go_run16	=	[41,	cascade_go_run17	]	{};
void()	cascade_go_run17	=	[42,	cascade_go_run18	]	{};
void()	cascade_go_run18	=	[43,	cascade_go_run19	]	{};
void()	cascade_go_run19	=	[44,	cascade_go_run20	]	{};
void()	cascade_go_run20	=	[45,	cascade_go_run21	]	{};
void()	cascade_go_run21	=	[46,	cascade_go_run22	]	{};
void()	cascade_go_run22	=	[47,	cascade_go_run23	]	{};
void()	cascade_go_run23	=	[48,	cascade_go_run24	]	{};
void()	cascade_go_run24	=	[49,	cascade_go_run25	]	{};
void()	cascade_go_run25	=	[50,	cascade_go_run26	]	{};
void()	cascade_go_run26	=	[51,	cascade_run1		]	{self.cnt = 1;};

void()	cascade_go_dry1		=	[0,		cascade_go_dry2		]	{};
void()	cascade_go_dry2		=	[1,		cascade_go_dry3		]	{};
void()	cascade_go_dry3		=	[2,		cascade_go_dry4		]	{};
void()	cascade_go_dry4		=	[3,		cascade_go_dry5		]	{};
void()	cascade_go_dry5		=	[4,		cascade_go_dry6		]	{};
void()	cascade_go_dry6		=	[5,		cascade_go_dry7		]	{};
void()	cascade_go_dry7		=	[6,		cascade_go_dry8		]	{};
void()	cascade_go_dry8		=	[7,		cascade_go_dry9		]	{};
void()	cascade_go_dry9		=	[8,		cascade_go_dry10	]	{};
void()	cascade_go_dry10	=	[9,		cascade_go_dry11	]	{};
void()	cascade_go_dry11	=	[10,	cascade_go_dry12	]	{};
void()	cascade_go_dry12	=	[11,	cascade_go_dry13	]	{};
void()	cascade_go_dry13	=	[12,	cascade_go_dry14	]	{};
void()	cascade_go_dry14	=	[13,	cascade_go_dry15	]	{};
void()	cascade_go_dry15	=	[14,	cascade_go_dry16	]	{};
void()	cascade_go_dry16	=	[15,	cascade_dry1		]	{self.cnt = 0;};

void()	cascade_dry1	=	[92,	cascade_dry1	]	{self.nextthink = time + 666;};

void()	cascade_run1	=	[0,		cascade_run2	]	{};
void()	cascade_run2	=	[1,		cascade_run3	]	{};
void()	cascade_run3	=	[2,		cascade_run4	]	{};
void()	cascade_run4	=	[3,		cascade_run5	]	{};
void()	cascade_run5	=	[4,		cascade_run6	]	{};
void()	cascade_run6	=	[5,		cascade_run7	]	{};
void()	cascade_run7	=	[6,		cascade_run8	]	{};
void()	cascade_run8	=	[7,		cascade_run9	]	{};
void()	cascade_run9	=	[8,		cascade_run10	]	{};
void()	cascade_run10	=	[9,		cascade_run11	]	{};
void()	cascade_run11	=	[10,	cascade_run12	]	{};
void()	cascade_run12	=	[11,	cascade_run13	]	{};
void()	cascade_run13	=	[12,	cascade_run14	]	{};
void()	cascade_run14	=	[13,	cascade_run15	]	{};
void()	cascade_run15	=	[14,	cascade_run16	]	{};
void()	cascade_run16	=	[15,	cascade_run17	]	{};
void()	cascade_run17	=	[16,	cascade_run18	]	{};
void()	cascade_run18	=	[17,	cascade_run19	]	{};
void()	cascade_run19	=	[18,	cascade_run20	]	{};
void()	cascade_run20	=	[19,	cascade_run21	]	{};
void()	cascade_run21	=	[20,	cascade_run22	]	{};
void()	cascade_run22	=	[21,	cascade_run23	]	{};
void()	cascade_run23	=	[22,	cascade_run24	]	{};
void()	cascade_run24	=	[23,	cascade_run25	]	{};
void()	cascade_run25	=	[24,	cascade_run26	]	{};
void()	cascade_run26	=	[25,	cascade_run1	]	{};

void() cascade_toggle =
{
	if (self.cnt == 0) 			// it's off; turn it on
	{
		self.think	=	cascade_go_run1;
		self.cnt	=	2;
		self.nextthink = time;	//reset nextthink, just in case
	}
	else if (self.cnt == 1) 	//it's on; turn it off
	{
		self.think	=	cascade_go_dry1;
		self.cnt	=	2;
	}
	else						//already busy; leave it alone
		return;
	
};

/*QUAKED misc_casacade (.5 .5 .5) (-32 -32 -72) (32 32 72) ? 
Places a static screen model, mesh done by preach (http://tomeofpreach.wordpress.com/).
*/
void() misc_cascade =
{
	create_mapobject("progs/waterfall.mdl");
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setsize (self, '-32 -32 -72', '32 32 72');

	/*	
		uses cnt as a controller for its state machine
		0	=	off
		1	=	on
		2	=	transition (turning on or off)
	*/
	
	//use skin to set all other variables
	
	if (!self.skin) 	//defaults to clean blue if not set
		self.skin = 0;

	self.use = cascade_toggle;	//mapper has triggered it
	
	if (self.spawnflags & START_OFF)		//no sound is added if START_OFF
	{
		self.think = cascade_dry1;
		self.cnt = 0;		//set state off
	}
	else
	{
		self.think = cascade_run1;
		self.cnt = 1;		//set state on
		
		if (self.skin == 4)
		{
			precache_sound ("ambient/ne_lava.wav");
			ambientsound (self.origin, "ambient/ne_lava.wav", 0.5, ATTN_STATIC);	
		}
		else
		{
			precache_sound ("ambient/curnt1.wav");
			precache_sound ("ambient/curnt2.wav");
			precache_sound ("ambient/curnt3.wav");
		
			local float ChooseSound;
			ChooseSound = random();
			
			if (ChooseSound < 0.3)
				ambientsound (self.origin, "ambient/curnt1.wav", 0.5, ATTN_STATIC);
			else if (ChooseSound < 0.6)
				ambientsound (self.origin, "ambient/curnt2.wav", 0.5, ATTN_STATIC);
			else
				ambientsound (self.origin, "ambient/curnt3.wav", 0.5, ATTN_STATIC);
		}
	}
};

// DRIPS ====================================================================

void() drip_spawn;
void() drip_pause;

// splash animation (runs at 20fps)
void()	s_splash1	=	[0,	s_splash2] {self.nextthink = time+0.05;};
void()	s_splash2	=	[1,	s_splash3] {self.nextthink = time+0.05;};
void()	s_splash3	=	[2,	s_splash4] {self.nextthink = time+0.05;};
void()	s_splash4	=	[3,	s_splash5] {self.nextthink = time+0.05;};
void()	s_splash5	=	[4,	s_splash6] {self.nextthink = time+0.05;};
void()	s_splash6	=	[5,	SUB_Remove] {self.nextthink = time+0.05;};

void() drip_touch =
{
	local float r;
	
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	setorigin(self, self.origin + '0 0 4');
	
	// play a random drip sound
	if (!(self.spawnflags & SILENT))
	{
		r = rint(random() * 2);
		if (r == 1)
			sound (self, CHAN_AUTO, "misc/drip1.wav", 1, ATTN_STATIC);
		else if (r == 2)
			sound (self, CHAN_AUTO, "misc/drip2.wav", 1, ATTN_STATIC);
		else if (r == 0)
			sound (self, CHAN_AUTO, "misc/drip3.wav", 1, ATTN_STATIC);
	}	
	
	// particle effect - GL quake tends to blur the slpash.spr...
	particle (self.origin, '0 0 0.25', 0, 5);
	
	setmodel (self, "progs/splash.spr");
	s_splash1();
};

// Splash on liquids
void() drip_think =
{
	if (self.attack_finished < time) {
		self.nextthink = -1;
		drip_touch();
		return;
	}
	
	if (pointcontents(self.origin + '0 0 -16') < CONTENT_SOLID) {
		self.nextthink = -1;
		drip_touch();
		return;
	}
	
	self.nextthink = time + 0.1;
};

void() drip_start =
{
	self.use = drip_pause;// next use stops it
	self.nextthink = time + (random() + self.wait);
}

void() drip_pause =
{
	// Wait around for next use
	self.nextthink = -1;
	self.use = drip_start;
}

void() drip_spawn =
{	
	local entity drip;
	
	drip = spawn ();
	drip.solid = SOLID_TRIGGER;
	drip.movetype = MOVETYPE_TOSS;
 	drip.spawnflags = self.spawnflags;
	drip.classname = "drip";
	
	drip.think1 = drip_touch;// So triggers can kill it
	
	// let gravity control the drip
	drip.velocity = VEC_ORIGIN;
	
	setmodel (drip, "progs/drip.spr");
	setsize (drip, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (drip, self.origin);

	drip.touch = drip_touch;
	
	if (self.cnt) {// Check for water
		drip.think = drip_think;
		drip.attack_finished = time + 3;
		drip.nextthink = time + 0.1;
	} else {// trace didn't hit water, so just go away if no touch
		drip.think = SUB_Remove;
		drip.nextthink = time + 3;
	}
	
	self.nextthink = time + (random() + self.wait);
};

/*QUAKED fx_drip (0 .5 .8) (-8 -8 -8) (8 8 8) ? FORCE_START_ON SILENT
Single, continuous drip. Can toggle on/off with multiple triggers.

"wait"			is a seed for the frequency of the drips 0 is pretty quick
"targetname"	can be triggered

Spawnflags:

"FORCE_START_ON"		Start right away even if triggered
"SILENT"		Don't make sound.

NOTE:

Use SILENT when using several drip enties and use an fx_sound triggered at the same time to
provide the sound. If you have too many drip noises playing, they can override more important
sounds in the same area (like plat/door sounds).

*/
void() fx_drip =
{	
	vector spot1, spot2;
	
	precache_model ("progs/drip.spr");
	precache_model ("progs/splash.spr");
	
	if (!(self.spawnflags & SILENT)) {
		precache_sound ("misc/drip1.wav");
		precache_sound ("misc/drip2.wav");
		precache_sound ("misc/drip3.wav");
	}
	
	if (self.wait <= 0) // default frequency to 3 seconds
		self.wait = 3;
	
	// Do a downard trace to see if we hit water to
	// avoid constant pointcontent checks if we can.
	spot1 = self.origin;
	spot2 = self.origin - '0 0 4096';
	traceline (spot1, spot2, TRUE, self);
	if (trace_inwater) self.cnt = TRUE;
	
	self.think = drip_spawn;
	
	if (self.targetname != string_null && !(self.spawnflags & FORCE_START_ON))
		drip_pause();
	else
		drip_start();
};

// CUSTOM SOUNDS ===================================================================

void() sound_pause;
void() sound_play;

void() sound_start =
{
	self.use = sound_pause;// next use stops it
	self.think = sound_play;
	self.nextthink = time + 0.1;
}

void() sound_pause =
{
	// play the shutoff wav if we got one, then hang around until next use
	if (self.noise1 != string_null)
		sound (self, CHAN_VOICE, self.noise1, self.volume, self.distance);
	self.nextthink = -1;
	self.use = sound_start;
};

void() sound_play = 
{
	if (self.state == 0) {// no more repeats - reset & pause
		self.state = self.count;		
		sound_pause();
		return;
	}
	else
		sound (self, CHAN_AUTO, self.noise, self.volume, self.distance);
	
	// reduce repititions by 1 if not infinite
	if (self.count > 0) self.state = self.state - 1;
	
	// Set next play time
	self.nextthink = time + (random()*self.cnt) + self.pausetime;
};

/*QUAKED fx_sound (0 .5 .8) (-8 -8 -8) (8 8 8) ? FORCE_START_ON
Plays any sound with an optional (different) shutoff sound.
Can trigger on/off, repeat, play n times, randomize, all sorts of fun stuff...

"noise"			Path to the sound - example: "misc/mysound.wav"
"noise1"		Path to the shutoff sound. Use "misc/null.wav" to abruptly mute "noise" when toggled off.
				If "noise1" is empty, "noise" is allowed to finish when paused (or continue if it's a looped WAV).
"speed"		Sound attenuation (defaults to ATTN_NORM).
"volume"		Sound volume.
"count"			Number of times to play the sound each time it's triggered (-1 is infinite loop).
"pausetime"		Delay in seconds before playing the next loop (omit or set to 0 if "count" is 1)
"cnt"			Random seed for repeats, this number is multiplied by random() and added to pausetime (0 is no random).
"targetname"	Can be triggered.

Spawnflags:

"FORCE_START_ON" 		Start right away even if triggered

NOTES:

Although you can use looping WAV files with fx_sound, you shouldn't rely on them looping for ever.
Quake will stop playing a sound when it can no longer hear it (well, "see it" is more accurate).
If an fx_sound is playing a looped WAV in this case, it will simply stop playing it. If you want
a sound to loop, it's best to use a non-looping WAV and set it's paustime to the length of the sound.
This won't stop Quake from muting the sound when it's nolonger in range, but at least it will start
up again when it comes back into range (although it starts at the next loop time, so long sounds may
still act weird).

If you need a triggered looping sound (that can't be turned off once started) use fx_ambientsound.

BUGS:

For some reason, Quake refuses to play sounds immediately, so there is a one second delay from
worldspawn to when the sound actually starts.

*/
void() fx_sound =
{
	if (self.noise == string_null)
		objerror ("fx_sound without noise!");
	precache_sound (self.noise);
	
	if (self.noise1 != string_null)
		precache_sound (self.noise1);
	
	// default volume to one if not specified
	if(self.volume <= 0)
		self.volume = 1.0;

	// default attenuation to STATIC if out of range //ijed was defaulting to NORM
	if (!self.speed)
	{
		self.speed = 3;//ATTN_STATIC;
	}
	
	self.distance = self.speed;	//ijed This was missing?  What am I missing...?
	
	// Set infinite repeat if not specified	ijed NO! This made sounds scream
	if (!self.count) self.count = 1;
	
	// Paustime < 0 makes no sense
	if (self.pausetime<0) self.pausetime = 0;
	
	// "state" holds the current number of repeats before pausing
	self.state = self.count;
	
	// Make sure random seed is valid
	if (self.cnt < 0) self.cnt = 0;

	// start sound when triggered
	if (self.targetname != string_null && !(self.spawnflags & FORCE_START_ON)) {
		self.use = sound_start;
	}
	else {// Start immediately
		self.use = sound_pause;// next use stops it
		self.think = sound_play;
		self.nextthink = time + 1.0;// FIXME! - WTF? //ijed no sound can start before the engine has initialised...
	}
};

void()	misc_victim	=
{
	if (self.frame == 0)	//disemboweled
		self.skin = 6;
	else if (self.frame == 1)	//faceless
		self.skin = 7;
	else if (self.frame == 2)	//armless
		self.skin = 2;
	else if (self.frame == 3)	//legless
		self.skin = 3;
	else if (self.frame == 4)	//sat
		self.skin = 7;
	else if (self.frame == 5)	//decap
		self.skin = 1;
	else if (self.frame == 6)	//back bore
		self.skin = 4;
	else if (self.frame == 7)	//side
		self.skin = 8;
	else if (self.frame == 8)	//crucified whole
		self.skin = 5;
	else if (self.frame == 9)	//impaled back
		self.skin = 9;
	else if (self.frame == 10)	//impaled front
		self.skin = 9;	
	else if (self.frame == 11)	//crucified legoff
		self.skin = 10;	
	else if (self.frame == 12)	//crucified headoff
		self.skin = 11;	
	
	create_mapobject("progs/victim.mdl");
	makestatic (self);
};

void()	barrel_explode;
void()	tbaby_die2;
void()	OgreGrenadeExplode;

/*QUAKED fx_explosion (0 .5 .8) (-8 -8 -8) (8 8 8) EXPLOBOX TARBABY 
Creates an explosion, can only be used once

"wait" Applies a delay before the explosion is fired
"targetname" 	Fires the explosion
*/

void() FxExplosionDo =	//vanilla explosion
{
	if (self.spawnflags & BIGBOOM)
		T_RadiusDamage (self, self.owner, 120, world);	
	else
		T_RadiusDamage (self, self.owner, 40, world);	
	
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	
	if (self.spawnflags & BIGBOOM)
		setmodel (self, "progs/boom.mdl");
	else
		setmodel (self, "progs/s_explod.spr");
		
	self.solid = SOLID_NOT;
	s_explode1 ();
};

void() fx_explosion_fire =
{
	if (self.spawnflags & EXPLOBOX)
		barrel_explode();
	else if (self.spawnflags & TARBABY)
		tbaby_die2();
	else 
		FxExplosionDo();	//also bigboom explosion
};

void() fx_explosion_wait =
{
	self.use = SUB_Null;

	self.think = fx_explosion_fire;
	self.nextthink = time + self.wait;
};

void() fx_explosion =  
{
	self.use = fx_explosion_wait;
	
	if (self.spawnflags & EXPLOBOX)  //ijed We need a big explosion vfx
		precache_sound ("weapons/r_exp3.wav");
	else if (self.spawnflags & TARBABY)
		precache_sound2 ("blob/death1.wav");
	else if (self.spawnflags & TARBABY)
		precache_model ("progs/boom.mdl");
};

/*QUAKED fx_beam (0 .5 .8) (-8 -8 -8) (8 8 8) FORCE_START_ON
draws a constant lightning beam between it and target
written by Gb with sound and auto-end added by ijed

"targetname" 	can be triggered
"target"		an info_notnull
"count"			automatically turn off after this amount of time 0 = wait for toggle

"FORCE_START_ON" 		Start right away even if triggerable
*/

void() drawbeam;
void() startdrawbeam;

void() stopbeam =
{
	self.think = SUB_Null;
	self.nextthink = time;
	self.use = startdrawbeam;
	self.cnt = 0;				//reset the timer
};

void() startdrawbeam =
{
	self.think = drawbeam;
	self.nextthink = time;
	self.use = stopbeam;
};

/*void() beginstopbeam =
{
	self.count = 0.2;
};*/

void() drawbeam =
{
	local vector p1, p2;

	p1 = self.origin;
	p2 = self.proxy.origin;

	if (self.t_width < time)	//play the sound once every 0.6 seconds, stripped from weapon.qc
	{
		sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.t_width = time + 0.6;
	}
			
	// compensate for length of bolt
	//p2 = p2 - normalize(p2-p1)*100;

	self.nextthink = time + 0.2;
	self.think = drawbeam;

	WriteByte (MSG_ALL, SVC_TEMPENTITY);
	WriteByte (MSG_ALL, TE_LIGHTNING2);
	WriteEntity (MSG_ALL, self);
	WriteCoord (MSG_ALL, p1_x);
	WriteCoord (MSG_ALL, p1_y);
	WriteCoord (MSG_ALL, p1_z);
	WriteCoord (MSG_ALL, p2_x);
	WriteCoord (MSG_ALL, p2_y);
	WriteCoord (MSG_ALL, p2_z);
	
	LightningDamage (p1, p2, self, 30);
	
	if (self.count > 0)	//auto kill it after this amount of time, 0 is wait for toggle
	{
		self.cnt = self.cnt + 0.2;	//increment this value for every 0.2 seconds it is running
		if (self.cnt >= self.count)	//once it goes over the count value, turn off the beam
		{
			self.think = stopbeam;
			self.nextthink = time;
		}
	}
};

void() fxbeam_scan =	//initialise beam
{
	self.proxy = find (world, targetname, self.target);
	
	if (self.targetname)	//wait until triggered if it has a targetname
	{
		if (self.spawnflags & FORCE_START_ON)
		{
			self.think = drawbeam;
			self.nextthink = time + 0.1;
			self.use = stopbeam;
		}
		else
		{
			self.think = SUB_Null;
			self.use = startdrawbeam;
		}
	}
	else	//always draw the beam if it has no name
	{
		self.think = drawbeam;
		self.nextthink = time + 0.1;
	}	
};

void() fx_beam =
{
	self.think = fxbeam_scan;
	self.nextthink = time + 0.2;
	self.cnt = 0;	//ijed Safety net - this is for the auto-off counter
};


