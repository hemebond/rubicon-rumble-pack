//ijed This is a collection of features from the RMQ / Schism codebase  

// ===== Summon ==============================================================

// gb, spawns a monster - mostly for summoning spells
// Spawn must have an external precache function (blah_cache)
// which the summoner must call >> in his own spawn function! <<
// to avoid "precaches can only be done in spawn functions"
void(vector ang, vector org, void() spawnfunc, string spawnclass) SpawnMonster =
{
	local entity oldself;
	oldself = self;

	// gb, send totalmonsters update because most clients only check once when connecting
	
	/*total_monsters = total_monsters + 1;

	WriteByte (MSG_BROADCAST,SVC_UPDATESTAT);
    WriteByte (MSG_BROADCAST,STAT_TOTALMONSTERS);
    WriteLong (MSG_BROADCAST,total_monsters);*/
	
	self = spawn();
    	
	self.flags = 0;
	
	//the tarfamily gets smaller as they split
	if (oldself.classname == "monster_tarbaby")	//this check allows the tarbox to not do weird stuff when spawning one
	{
		if (oldself.spawnflags & PARENT)
			self.spawnflags = CHILD;
		else if (oldself.spawnflags & ANCIENT)
			self.spawnflags = PARENT;		
		else
			self.spawnflags = 0;
			
		self.ammo_shells = 1;	//hack so that boxed babies aren't thrown
	}
			
	self.enemy = oldself.enemy;	// FoundTarget() called for summons in blahmonster_start

	//org_z = org_z + 64;	// lift it up a bit, prevent flymonsters banging on the floor
	
	if (oldself.classname == "misc_tarbox")
	{
		if (oldself.spawnflags & PARENT)
			self.spawnflags = PARENT;
		else if (oldself.spawnflags & ANCIENT)
			self.spawnflags = ANCIENT;		
		else if (oldself.spawnflags & CHILD)
			self.spawnflags = CHILD;		
		else
			self.spawnflags = 0;
	}
	
	setorigin (self, org);
	
	self.spawned = TRUE;	// bypass its precaches (summoner must call those)

	self.classname = spawnclass;
	self.angles = ang;	//oldself.angles; //+ '0 180 0';	// face summoner and hopefully enemy
	
	oldself.target = self.target;	//ijed Inherit parent's target to get correct triggering for hordes
	
	spawnfunc();	// sneaky, huh?
	
	// switch back
	self = oldself;
	
	// thanks to PM, wouldn't have figured this out myself
}; 

float(vector tspot) Checkspot =
{
	if (pointcontents(tspot) != CONTENT_EMPTY)
		return FALSE;
	if (pointcontents(tspot + '24 0 0') != CONTENT_EMPTY)
		return FALSE;
	if (pointcontents(tspot - '24 0 0') != CONTENT_EMPTY)
		return FALSE;
	if (pointcontents(tspot + '0 24 0') != CONTENT_EMPTY)
		return FALSE;
	if (pointcontents(tspot - '0 24 0') != CONTENT_EMPTY)
		return FALSE;
	if (pointcontents(tspot + '0 0 32') != CONTENT_EMPTY)
		return FALSE;
	if (pointcontents(tspot - '0 0 12') != CONTENT_EMPTY)
		return FALSE;

	return TRUE;
};

void()	TarGibTouch;


/*
================
M_FireGibs
================
*/
// fire dangerous gibs / stuff in random directions, this came from the schism attack library 

void(vector org, vector dir) launch_gib =
{
	newmis = spawn ();
	newmis.real_owner = newmis.owner = self;
	
	newmis.movetype = MOVETYPE_BOUNCE;
	
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);

	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	
	if (self.classname == "monster_tarbaby")
		newmis.nextthink = time + random()*5;
	else	
		newmis.nextthink = time + 6;
	
	setmodel (newmis, "progs/spike.mdl");
	
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, org);

	if (self.classname == "monster_tarbaby")
	{
		newmis.velocity = dir * 1200 * random();  
		newmis.avelocity_x = random()*600;
		newmis.avelocity_y = random()*600;
		newmis.avelocity_z = random()*600;
	}
	else
		newmis.velocity = dir * 1200;  
};

//fires shrapnel in all directions
void(string gibname, float AttackAmount) M_FireGibs =  
{
	local float AttackCount;	//keep track of how many we fire
	local vector a;				//firing vector
	AttackCount = 0;			//Make sure counter is at 0
	
	dprint("M_FireGibs");
	
	do	//loop until all are fired
	{
		// LA: Somewhat more sane angle calculations
		// Unfortunately, this still has a slightly square pattern, but then so does our shotgun spread...
		a_x = self.angles_x + crandom() * 180;
		a_y = self.angles_y + crandom() * 90;
		a_z = 0;
		makevectors(a);
		
		/*if (self.classname == "monster_zombomb")	//gibs from zombomb - schism only
		{
			launch_gib (self.origin, v_forward);
			newmis.touch = Z_GrenadeTouch;
		}
		else*/ if (self.classname == "monster_tarbaby")	//gibs from tar family
		{
			launch_gib (self.origin, v_forward);
			newmis.touch = TarGibTouch;
		}
		else		//assume super nails
		{
			launch_spike (self.origin, v_forward);
			newmis.touch = superspike_touch;
		}
		
		setmodel (newmis, gibname);	//model set by the firer
		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
		
		AttackCount = AttackCount + 1;	//increase the counter
		
	} while (AttackCount < AttackAmount);	//until all are fired
};

//Supa's random offset function
vector(float offset_amt) RandomOffset =
{
	local vector offset;

	offset_x = crandom() * offset_amt;
	offset_y = crandom() * offset_amt;
	offset_z = crandom() * offset_amt;
	
	return offset;
};

void(string noise)	MonsterIdleSound =	//ijed, play idlesound only if not AMBUSH, can also play it while stood
{
	local float r;
	r = random();
	
	if ((self.enemy == world) && (self.spawnflags & 3))
		return;
	
	if (self.enemy == world)		//quieter if not angry at anyone
	{
		if (r < 0.1)
			sound (self, CHAN_VOICE, noise, 1, ATTN_IDLE);
	}
	else if (r < 0.2)
		sound (self, CHAN_VOICE, noise, 1, ATTN_IDLE);
};

// ===== LIGHT ZERO ==========================================================

// gb, perhaps move this to subs.qc or something

// Custom addition by PM.  Used by lightning strike related spells (magic.qc).
//
// Since much of the level is lit up using lightstyle 0,
// changing it will make much of the level brighter or darker.
// Useful for lightning storm effects.

// Calls 'lightstyle(0, <foo>)'.
void() LightZero_Update =
{
	//    dprint(ftos(lightzero_level)); dprint("\n");
	lightzero_level = floor (lightzero_level);
	
	if (lightzero_level < 5)
	{
		if (lightzero_level < 1)
			lightstyle(LIGHT_ZERO, "a");
		else if (lightzero_level == 1)
			lightstyle(LIGHT_ZERO, "b");
		else if (lightzero_level == 2)
			lightstyle(LIGHT_ZERO, "c");
		else if (lightzero_level == 3)
			lightstyle(LIGHT_ZERO, "d");
		else //if (lightzero_level == 4)
			lightstyle(LIGHT_ZERO, "e");
	}
	else if (lightzero_level < 10)
	{
		if (lightzero_level == 5)
			lightstyle(LIGHT_ZERO, "f");
		else if (lightzero_level == 6)
			lightstyle(LIGHT_ZERO, "g");
		else if (lightzero_level == 7)
			lightstyle(LIGHT_ZERO, "h");
		else if (lightzero_level == 8)
			lightstyle(LIGHT_ZERO, "i");
		else //if (lightzero_level == 9)
			lightstyle(LIGHT_ZERO, "j");
	}
	else if (lightzero_level < 15)
	{
		if (lightzero_level == 10)
			lightstyle(LIGHT_ZERO, "k");
		else if (lightzero_level == 11)
			lightstyle(LIGHT_ZERO, "l");
		else if (lightzero_level == 12)
			lightstyle(LIGHT_ZERO, "m");
		else if (lightzero_level == 13)
			lightstyle(LIGHT_ZERO, "n");
		else //if (lightzero_level == 14)
			lightstyle(LIGHT_ZERO, "o");
	}
	else if (lightzero_level < 20)
	{
		if (lightzero_level == 15)
			lightstyle(LIGHT_ZERO, "p");
		else if (lightzero_level == 16)
			lightstyle(LIGHT_ZERO, "q");
		else if (lightzero_level == 17)
			lightstyle(LIGHT_ZERO, "r");
		else if (lightzero_level == 18)
			lightstyle(LIGHT_ZERO, "s");
		else //if (lightzero_level == 19)
			lightstyle(LIGHT_ZERO, "t");
	}
	else
	{
		if (lightzero_level == 20)
			lightstyle(LIGHT_ZERO, "u");
		else if (lightzero_level == 21)
			lightstyle(LIGHT_ZERO, "v");
		else if (lightzero_level == 22)
			lightstyle(LIGHT_ZERO, "w");
		else if (lightzero_level == 23)
			lightstyle(LIGHT_ZERO, "x");
		else if (lightzero_level == 24)
			lightstyle(LIGHT_ZERO, "y");
		else //if (lightzero_level == 25)
			lightstyle(LIGHT_ZERO, "z");
	}
};

void() LightZero_Go =
{
	if (!lightzero_finished)
		return;

	if (lightzero_finished > time)
	{
		lightzero_level = lightzero_level + lightzero_rate;
		
		if (lightzero_level < LIGHTZERO_MIN)
			lightzero_level = LIGHTZERO_MIN;
		else if (lightzero_level > LIGHTZERO_MAX)
			lightzero_level = LIGHTZERO_MAX;
	}
	else	// restore normal lighting
	{
		if (lightzero_level > LIGHTZERO_NORMAL)
		{   // Was brighter.
			lightzero_level = lightzero_level - 4;
			
			if (lightzero_level < LIGHTZERO_NORMAL)
				lightzero_level = LIGHTZERO_NORMAL;
		}
		else if (lightzero_level < LIGHTZERO_NORMAL)
		{   // Was darker.
			lightzero_level = lightzero_level + 2;
			
			if (lightzero_level > LIGHTZERO_NORMAL)
				lightzero_level = LIGHTZERO_NORMAL;
		}
		
		if (lightzero_level == LIGHTZERO_NORMAL)
			lightzero_finished = 0;     // End it!
	}

	LightZero_Update ();
};

void(float lite, float add, float rate) LightZero_Set =
{
	lightzero_rate = rate;
	
	if (lite == -1)
	{
		if (lightzero_finished)
			lite = lightzero_level;
		else
			lite = LIGHTZERO_NORMAL;
	}
	
	add = time + add;
	
	if (lightzero_finished < add)
		lightzero_finished = add;
	
	if (lightzero_level != lite)
	{
		lightzero_level = lite;
		LightZero_Update ();
	}
};

// ===== FUNC_TOGGLEWALL =====================================================

// func_togglewall from hipnotic.  Particle field stuff made DRS barf so he 
// chucked it.  (note to (DRS) self: Make nicer particle field if needed.)
// Yes, needed, still waiting - gb :-P
// ijed Adding visibility for RRP project so this can be used for debris

void () blocker_touch =
{
	if (other.classname != "player")
		return;

	if ( !self.dmg )
		return;

	if (time < self.attack_finished)
		return;

	self.attack_finished = time + self.wait;

	sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);	// gb
	T_Damage (other, self, self, self.dmg);
};

void () blocker_use =
{
	if ( !self.state )
	{
		self.state = 1;
		setorigin( self, self.origin - '8000 8000 8000' );
		sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
		
		if (self.spawnflags & SEEABLE)
			self.model = self.mdl;
		
	}
	else
	{
		self.state = 0;
		setorigin( self, self.origin + '8000 8000 8000' );
		sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
		
		if (self.spawnflags & SEEABLE)
			self.model = string_null;

	}
};

/*QUAKED func_togglewall (0 .5 .8) ? START_OFF
Creates a invisible wall that can be toggled on and off.

START_OFF 	Doesn't block until triggered.
SEEABLE		You can see the bsp 

"noise"		sound to play when wall is turned off
"noise1"	sound to play when wall is turned on
"noise2"	sound to play when wall is touched 
"dmg"		damage when touched
"wait"		delay between each touch sound/damage
*/

void() func_togglewall =
{
	self.classname = "togglewall";
	self.movetype = MOVETYPE_PUSH;
	self.mdl = self.model;
	setmodel (self, self.model);
	setsize (self, self.mins, self.maxs);
	setorigin (self, self.origin);
	self.touch = blocker_touch;
	self.use = blocker_use;
	
	if (!self.noise)
		self.noise = ("misc/null.wav");
	
	if (!self.noise1)
		self.noise1 = ("misc/null.wav");

	if (!self.noise2)
		self.noise2 = ("misc/null.wav");
	
	if (!self.wait)
		self.wait = 2;	// time between damage/touch sounds

	precache_sound(self.noise);
	precache_sound(self.noise1);
	precache_sound(self.noise2);

	self.solid = SOLID_BSP;
	
	if (self.spawnflags & SEEABLE)
		self.model = self.mdl;
	else
		self.model = string_null;
	
	if (self.spawnflags & START_OFF)
	{
		self.state = 0;
		setorigin(self, self.origin + '8000 8000 8000');
	}
	else
	{
		self.state = 1;
		sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	}
};

/*QUAKED event_meltdown (0 .5 .8) 
Repeatedly plays an alarm sound and kills all players once 
the timer expires.  Can be toggled on/off. Uses the 
ambient/mother voice sound effects

"wait"		Delay before killing all players after triggered
"noise"		alarm sound to play (not looping)
"delay"		time between alarm sounds, 0 is no alarm

*/

void()	meltdown_do;

void() meltdown_think_loop =
{

	dprint ("Meltdown timer ");
	dprint (ftos(self.wait));
	dprint (" seconds remaining\n");
		
	if (self.lip == 0)	//whut?  It shouldn't be on!
	{
		self.think = SUB_Null;
		return;
	}

	//mother lets you know how long is left before catastrophe
	if (self.wait == 300)	//five minutes
	{
		sound (self, CHAN_AUTO, "ambient/mother/countdown5minutes.wav", 1, ATTN_NONE);
		bprint("5 minutes until core meltdown\n");
	}
	else if (self.wait == 240)	//four minutes
	{
		sound (self, CHAN_AUTO, "ambient/mother/countdown4minutes.wav", 1, ATTN_NONE);
		bprint("4 minutes until core meltdown\n");
	}
	else if (self.wait == 180)	//three minutes
	{
		sound (self, CHAN_AUTO, "ambient/mother/countdown3minutes.wav", 1, ATTN_NONE);
		bprint("3 minutes until core meltdown\n");
	}
	else if (self.wait == 120)	//two minutes
	{
		sound (self, CHAN_AUTO, "ambient/mother/countdown2minutes.wav", 1, ATTN_NONE);
		bprint("2 minutes until core meltdown\n");
	}
	else if (self.wait == 60)	//one minute
	{	
		sound (self, CHAN_AUTO, "ambient/mother/countdown1minute.wav", 1, ATTN_NONE);
		bprint("1 minute until core meltdown\n");
	}
	else if (self.wait == 30)	//30 seconds
	{
		sound (self, CHAN_AUTO, "ambient/mother/countdown30seconds.wav", 1, ATTN_NONE);
		bprint("30 seconds until core meltdown\n");
	}
	else if (self.wait == 11)	//ITS THE FINAL COUNTDOWN!
	{
		sound (self, CHAN_AUTO, "ambient/mother/countdown10.wav", 1, ATTN_NONE);
		bprint("10 seconds core meltdown\n");
	}
	else if (self.wait == 10)
	{
		sound (self, CHAN_AUTO, "ambient/mother/countdown9.wav", 1, ATTN_NONE);
		bprint("9 seconds core meltdown\n");
	}
	if (self.wait == 9)		
	{
		sound (self, CHAN_AUTO, "ambient/mother/countdown8.wav", 1, ATTN_NONE);
		bprint("8 seconds until core meltdown\n");
	}
	else if (self.wait == 8)		
	{
		sound (self, CHAN_AUTO, "ambient/mother/countdown7.wav", 1, ATTN_NONE);
		bprint("7 seconds until core meltdown\n");
	}
	else if (self.wait == 7)		
	{
		sound (self, CHAN_AUTO, "ambient/mother/countdown6.wav", 1, ATTN_NONE);
		bprint("6 seconds until core meltdown\n");
	}
	else if (self.wait == 6)		
	{
		sound (self, CHAN_AUTO, "ambient/mother/countdown5.wav", 1, ATTN_NONE);
		bprint("5 seconds until core meltdown\n");
	}
	else if (self.wait == 5)		
	{
		sound (self, CHAN_AUTO, "ambient/mother/countdown4.wav", 1, ATTN_NONE);
		bprint("4 seconds until core meltdown\n");
	}
	else if (self.wait == 4)		
	{
		sound (self, CHAN_AUTO, "ambient/mother/countdown3.wav", 1, ATTN_NONE);
		bprint("3 seconds until core meltdown\n");
	}
	else if (self.wait == 3)		
	{
		sound (self, CHAN_AUTO, "ambient/mother/countdown2.wav", 1, ATTN_NONE);
			bprint("2 seconds until core meltdown\n");
	}
	else if (self.wait == 2)		
	{
		sound (self, CHAN_AUTO, "ambient/mother/countdown1.wav", 1, ATTN_NONE);
		bprint("1 second until core meltdown\n");
	}
	
	/*flickering lights  HOW THE FUCK DO YOU MANAGE THESE VALUES
	if (random() > 0.8)
	{
		bprint("FLICKER!\n");
		//LightZero_Set (1, 0.1, -1);		//modifies light level, level, duration, rate// 20, 0, -4
		LightZero_Set (5, 0.1, 4);
	}*/
	
	//repeating alarm
	if (self.wait2 > 2)
	{
		sound (self, CHAN_AUTO, "ambient/mother/alarm.wav", 1, ATTN_NONE);
		self.wait2 = 0;
	}
	
	//check if time is up
	if (self.wait < 1)
	{
		self.lip = 0;	//turn the counter off
		meltdown_do();	//destroy everything
	}
	
	//reduce the timer by 1 
	self.wait = self.wait - 1;
	
	//up all the control values by 1
	self.wait2 = self.wait2 + 1;
	
	//in one second, repeat this routine
	self.think = meltdown_think_loop;
	self.nextthink = time + 1;
};

void() meltdown_think =		//start or stop the meltdown
{
	if (self.lip == 1)	//it's already on, so stop it
	{
		self.lip = 0;	//mark it as off
		self.think = SUB_Null;	//stop doing stuff
	}
	else	//it's off, so start it
	{
		self.think = meltdown_think_loop;
		self.nextthink = time + 0.1;
		self.lip = 1;	//mark as on
	}
};

void() meltdown_do =
{
	local entity e;
	
	e = find( world, classname, "player");	//find em and
	
	T_Damage (e, self, self, e.health + 666);	//gib em

	//flash
	stuffcmd (e, "bf\n");
	
	//fogoff
	stuffcmd (e, "fog 0\n");
	
	//lightsout
	LightZero_Set (-100, 0, -4);
};

void() event_meltdown =
{
	//precache model assets
	precache_model ("progs/boom.mdl");
	
	//precache sound assets 
	precache_sound ("ambient/mother/countdownstart.wav");
	precache_sound ("ambient/mother/countdown5minutes.wav");
	precache_sound ("ambient/mother/countdown4minutes.wav");
	precache_sound ("ambient/mother/countdown3minutes.wav");
	precache_sound ("ambient/mother/countdown2minutes.wav");
	precache_sound ("ambient/mother/countdown1minute.wav");
	precache_sound ("ambient/mother/countdown30seconds.wav");
	precache_sound ("ambient/mother/countdown10.wav");
	precache_sound ("ambient/mother/countdown9.wav");
	precache_sound ("ambient/mother/countdown8.wav");
	precache_sound ("ambient/mother/countdown7.wav");
	precache_sound ("ambient/mother/countdown6.wav");
	precache_sound ("ambient/mother/countdown5.wav");
	precache_sound ("ambient/mother/countdown4.wav");
	precache_sound ("ambient/mother/countdown3.wav");
	precache_sound ("ambient/mother/countdown2.wav");
	precache_sound ("ambient/mother/countdown1.wav");
	precache_sound ("ambient/mother/alarm.wav");	
	
	//control values 
	self.wait2 = 0;	//alarm 
	
	if (self.lip != 1)
		self.lip = 0;	//is it on or off, default off
		
	if (self.wait == 0)
		self.wait = 300;	//default to five minutes if not set
		
	self.use = meltdown_think;
};

