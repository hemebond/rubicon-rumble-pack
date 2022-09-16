/*
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software Foundation,
Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/


void() plat_center_touch;
void() plat_outside_touch;
void() plat_trigger_use;
void() plat_go_up;
void() plat_go_down;
void() plat_crush;

float PLAT_LOW_TRIGGER = 1;

void() plat_spawn_inside_trigger =
{
	local entity	trigger;
	local vector	tmin, tmax;

//
// middle trigger
//	
	trigger = spawn();
	trigger.touch = plat_center_touch;
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.enemy = self;
	
	tmin = self.mins + '25 25 0';
	tmax = self.maxs - '25 25 -8';
	tmin_z = tmax_z - (self.pos1_z - self.pos2_z + 8);
	if (self.spawnflags & PLAT_LOW_TRIGGER)
		tmax_z = tmin_z + 8;
	
	if (self.size_x <= 50)
	{
		tmin_x = (self.mins_x + self.maxs_x) / 2;
		tmax_x = tmin_x + 1;
	}
	if (self.size_y <= 50)
	{
		tmin_y = (self.mins_y + self.maxs_y) / 2;
		tmax_y = tmin_y + 1;
	}
	
	setsize (trigger, tmin, tmax);
};

void() plat_hit_top =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_TOP;
	self.think = plat_go_down;
	self.nextthink = self.ltime + self.wait;	// gb, was hardcoded 3
};

void() plat_hit_bottom =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_BOTTOM;
};

void() plat_go_down =
{
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos2, self.speed, plat_hit_bottom);
};

void() plat_go_up =
{
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.state = STATE_UP;
	SUB_CalcMove (self.pos1, self.speed, plat_hit_top);
};

void() plat_center_touch =
{
	if (!(other.classname == "player")) //|| other.flags & FL_MONSTER))	// gb
		return;
		
	if (other.health <= 0)
		return;

	self = self.enemy;
	if (self.state == STATE_BOTTOM)
		plat_go_up ();
	else if (self.state == STATE_TOP)
		self.nextthink = self.ltime + 1;	// delay going down
};

void() plat_outside_touch =
{
	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;
		
//dprint ("plat_outside_touch\n");
	self = self.enemy;
	if (self.state == STATE_TOP)
		plat_go_down ();
};

void() plat_trigger_use =
{
	if (self.think)
		return;		// allready activated
	plat_go_down();
};


void() plat_crush =
{
//dprint ("plat_crush\n");

//	other.deathtype = "squish";	// QIP
	T_Damage (other, self, self, 1); 
	
	if (self.state == STATE_UP)
		plat_go_down ();
	else if (self.state == STATE_DOWN)
		plat_go_up ();
	else
		objerror ("plat_crush: bad self.state\n");
};

void() plat_use =
{
	self.use = SUB_Null;
	if (self.state != STATE_UP)
		objerror ("plat_use: not in up state");
	plat_go_down();
};


/*QUAKED func_plat (0 .5 .8) ? PLAT_LOW_TRIGGER
speed	default 150

Plats are always drawn in the extended position, so they will light correctly.

If the plat is the target of another trigger or button, it will start out disabled in the extended position until it is trigger, when it will lower and become a normal plat.

If the "height" key is set, that will determine the amount the plat moves, instead of being implicitly determined by the model's height.
Set "sounds" to one of the following:
1) base fast
2) chain slow

wait	seconds to wait before going back down
*/

void() func_plat =
{
	local entity t;

	if (!self.t_length)
		self.t_length = 80;
	if (!self.t_width)
		self.t_width = 10;

	if (self.sounds == 0)
		self.sounds = 2;
	// FIX THIS TO LOAD A GENERIC PLAT SOUND

	if (self.sounds == 1)
	{
		precache_sound ("plats/plat1.wav");
		precache_sound ("plats/plat2.wav");
		self.noise = "plats/plat1.wav";
		self.noise1 = "plats/plat2.wav";
	}

	if (self.sounds == 2)
	{
		precache_sound ("plats/medplat1.wav");
		precache_sound ("plats/medplat2.wav");
		self.noise = "plats/medplat1.wav";
		self.noise1 = "plats/medplat2.wav";
	}


	self.mangle = self.angles;
	self.angles = '0 0 0';

	self.classname = "plat";
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin (self, self.origin);	
	setmodel (self, self.model);
	setsize (self, self.mins , self.maxs);

	self.blocked = plat_crush;
	
	if (!self.speed)
		self.speed = 150;

	if (!self.wait)
		self.wait = 3;
	
	// pos1 is the top position, pos2 is the bottom
	self.pos1 = self.origin;
	self.pos2 = self.origin;
	
	if (self.height)
		self.pos2_z = self.origin_z - self.height;
	else
		self.pos2_z = self.origin_z - self.size_z + 8;

	self.use = plat_trigger_use;

	plat_spawn_inside_trigger ();	// the "start moving" trigger	

	if (self.targetname)
	{
		self.state = STATE_UP;
		self.use = plat_use;
	}
	else
	{
		setorigin (self, self.pos2);
		self.state = STATE_BOTTOM;
	}
};

// ===========================================================================
// path_corner was moved here from ai.qc, since it's used by func_train ======
// legacy map support... - gb

// MOVETARGET CODE

// The angle of the movetarget effects standing and bowing direction, but has no effect on movement, which always heads to the next target.

// targetname 	must be present.  The name of this movetarget.
// target	next spot to move to.  If not present, stop here for good.
// pausetime	number of seconds to spend standing or bowing for path_stand or path_bow


void() pe_self_setup=
{
	local entity tmpent;

	if (self.target)	// gb, path_corners are allowed to have no target set
		tmpent = find(world, targetname, self.target);
	
	if(!tmpent)
		dprint ("path_corner cannot find its target\n");
//		objerror ("path entity without target");
	else
		self.goalentity = tmpent;

	self.think = SUB_Null;
};

// gb, CUSTENTS (c) 1997 Carl Glave
// Carl Glave's code may not be used as a basis for COMMERCIAL works
// Called by all path entities at startup (path_corner, too)
void() path_entity_setup=
{
	self.nextthink = time + 0.2;
	self.think = pe_self_setup;
};

// path_corner's touch function
void() t_movetarget =
{
	local entity	temp;

	if (other.movetarget != self)
		return;

	if (other.flags & FL_MONSTER)	// gb, ignore trains etc.
	{
		if (other.enemy)
			return;		// fighting, not following a path
		
		temp = self;
		self = other;
		other = temp;

		// ogre? Play chainsaw drag sound
		if (self.classname == "monster_ogre" && (random() < 0.5))	// gb
			sound (self, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);

		//dprint ("t_movetarget\n");

		// point them in the right direction
		self.goalentity = self.movetarget = find (world, targetname, other.target);
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	
		if (!self.movetarget)
		{
			self.pausetime = time + 999999;
			self.th_stand ();
			return;
		}
	}
};


/*QUAKED path_corner (0 1 1) (-8 -8 -8) (8 8 8)
Used as patrol points for monsters or func_trains.

func_train is "dumb" on it's own, these entities really control the train.
Used for func_watertrain as well.

"speed"			Forward speed from this waypoint to the next (-1 is warp to next waypoint)
"wait"			Time to pause at this waypoint when moving forward (-1 is wait for re-trigger, 0 is no pause)

"noise" 		Override train's start/travel noise from this waypoint to the next when moving forward

"noise1"		Override train's stop noise at this waypoint when moving forward (or between this waypoint and the next) 

"event"			Targetname of entity to fire when the train hits this point when moving forward

"speed2"		Reverse speed from this waypoint to the previous in (-1 is warp to previous)
"wait2"			Time to pause at this waypoint when moving in reverse (-1 is wait for re-trigger, 0 is no pause)

"noise2" 		Override train's start/travel noise from this waypoint to the previous when moving in reverse

"noise3"		Override train's stop noise at this waypoint when moving in reverse (or between this waypoint to the previous)

"event2"		Targetname of entity to fire when the train hits this point when moving in reverse

"targetname"		This waypoint's name
"target"		Name of the next waypoint

"ignore_block"		Sets train to ignore being blocked - hack

NOTES:

Always use unique sets of path_corners for func_train and func_watertrain.
(This may break some exotic maps, gb)

The waypoints are linked with one another and can only work with one train at a time.

Speed propagates from waypoint to waypoint (if it's not set, the last speed is used).
The first waypoint can also simply use the train's "speed" if set.

If the reverse speed/event are not set, the forward direction speed/event are used.
Reverse sounds default to the train's sounds if they are not set. (This only matters
for trains that can go in reverse of course).
*/

void() path_corner =
{
	// train stuff ------
	
	if (!self.targetname)
		objerror ("path_corner: no targetname");	// monster_movetarget
	
	if (self.wait < -1)
		self.wait = -1;
	
	if (self.speed < -1)
		self.speed = -1;
	
	if (self.noise)
		precache_sound(self.noise);
	
	if (self.noise1)
		precache_sound(self.noise1);
	
	// Set defaults for train reverse direction
	if (self.wait2 < -1)
		self.wait2 = -1;
	
	if (self.speed2 < -1)
		self.speed2 = -1;
	
	if (!self.speed2 && self.speed)
		self.speed2 = self.speed;
	
	if (!self.event2 && self.event != string_null)
		self.event2 = self.event;
	
	if (self.noise2)
		precache_sound(self.noise2);
	
	if (self.noise3)
		precache_sound(self.noise3);
	
	self.classname = "path_corner";	// trains check this
	
	// train stuff end ---------------
	
	// path entity self setup
	path_entity_setup();	// sets goalentity a little bit later, so we know that all path_corners have spawned
	
	self.solid = SOLID_TRIGGER;	// so it can have a touch function
	self.movetype = MOVETYPE_NONE;


	self.touch = t_movetarget;	// point monsters to next target

	setsize (self, '-8 -8 -8', '8 8 8');
	
};

// gb, Extras legacy

void() train_ext_waypoint =
{
	path_corner();
};


// func_train begin ========================================================

/*
	Written by Frank Condello <pox@planetquake.com>
	
	func_train_ext can have certain "children" objects that tag along,
	can change direction, or stop/resume at any time.
	
	These use "smart" waypoints and trigger relays that actually control most
	aspects of the train, but a simple train can still be setup by ignoring
	extra options.
	
	The last waypoint does not need a target. The train will either
	auto-reverse (if set) or wait for manual reverse/move triggers.	
*/

float FORWARD = 0;
float REVERSE = 1;

float ALLOWPAUSE = 2;		// Triggers start/stop the train
float ALLOWCHANGEDIR = 4;	// Changedir triggers reverse direction
float AUTOREVERSE = 8;		// Reverse direction at endpoints
float BLOCKREVERSE = 16;	// Reverse direction if blocked
float STARTREVERSE = 32;	// Start in reverse

float FREEMOVE = 0;		// Not at an endpoint (can move either way)
float RIGHTWAY = 1;		// At an endpoint, and direction leads away (can move)
float WRONGWAY = 2;		// At an endpoint, but direction leads into endpoint (can't move)

.entity next, previous, child;

/*
=============
train_ext_linkchild

Saves a list of child objects (parent.child.child.child...etc.).
Always call this on frame 2 to ensure the train has spawned.
NOTE: I've given up on solid children - too many tracking/blocking issues
==============
*/

void() train_ext_linkchild =
{
	local entity parent;
	
	// Find the parent train
	parent = find (world, targetname, self.target);
	
	if (parent.classname != "train_ext")
		objerror ("train_ext_linkchild: target is not a func_train_ext");

	// Set the train as this ent's owner
	self.owner = parent;
	
	// Copy off any other children
	if (parent.child)
		self.child = parent.child;
	
	// Make this ent a child
	parent.child = self;

	// Set start position
	self.origin = self.owner.origin;	// Supa *SIGH* bmodel org issues
	setorigin (self, self.origin);
};

// func_train movement functions ============================================

void() train_ext_next;
void() train_ext_previous;
void() train_ext_init;
void() train_ext_wait;
void() train_ext_use;

// play the stop sound
void() train_ext_playstopsound =
{
	local entity cchain;
	
	// noise3 = noise1, see train_ext_next
	sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
	
	//play child sounds	
	if (!self.cshift)
	{
		cchain = self.child;
		
		while(cchain)
		{	
			if (cchain.cshift)// func_watertrain
				if (cchain.noise1)
					sound (cchain, CHAN_VOICE, cchain.noise1, 1, ATTN_NORM);	
			cchain = cchain.child;
		}
	}
};

// play the travel sound
void() train_ext_playtravelsound =
{
	local entity cchain;
	
	// noise2 = noise, see train_ext_next
	sound (self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	
	// play child sounds
	if (!self.cshift)
	{
		cchain = self.child;
		
		while(cchain)
		{	
			if (cchain.cshift)// func_watertrain
				if (cchain.noise)
					sound (cchain, CHAN_VOICE, cchain.noise, 1, ATTN_NORM);	
			
			cchain = cchain.child;
		}
	}
};

// play the reverse direction sound
void() train_ext_playchangedirsound = // Doesn't mute CHAN_VOICE
{
	local entity cchain;
	
	if (self.noise4)
		sound (self, CHAN_BODY, self.noise4, 1, ATTN_NORM);
	
	// play child sounds
	if (!self.cshift)
	{
		cchain = self.child;
		
		while(cchain)
		{
			if (cchain.cshift)// func_watertrain
				if (cchain.noise4)
					sound (cchain, CHAN_BODY, cchain.noise4, 1, ATTN_NORM);	
			
			cchain = cchain.child;
		}
	}
};

// play the wrong way sound
void() train_ext_playwrongwaysound =
{
	local entity cchain;
	
	if (self.noise5)
		sound (self, CHAN_VOICE, self.noise5, 1, ATTN_NORM);
	
	// play child sounds
	if (!self.cshift)
	{
		cchain = self.child;
		
		while(cchain)
		{
			if (cchain.cshift)// func_watertrain
				if (cchain.noise5)
					sound (cchain, CHAN_VOICE, cchain.noise5, 1, ATTN_NORM);	
			cchain = cchain.child;
		}
	}
};

.float ignore_block;	// gb, don't squish things, don't autoreverse - e1m3rq reverse oubliette

// blocked, do damage and reverse direction if allowed 
void() train_ext_blocked =
{
	local entity cchain;
	
	if (time < self.attack_finished)
		return;
	
	if (self.ignore_block)	// ouch, ouch, ouch - gb
		return;
	
	self.attack_finished = time + 0.5;
	
	T_Damage (other, self, self, 1); 
	
	// Change direction
	if (self.spawnflags & BLOCKREVERSE && self.deadflag == FREEMOVE)
	{
		if (self.state == REVERSE)
		{
			self.state = FORWARD;
			train_ext_next();
		}
		else
		{
			self.state = REVERSE;
			train_ext_previous();
		}
	}
};

// Move!
void() train_ext_move =
{
	local entity cchain;
	
	// Warp to next waypoint
	if (self.speed == -1)
	{
		setorigin (self, self.dest - self.mins);
		self.nextthink = self.ltime + 0.001;
	}
	else	// Move to next waypoint
	{		
		train_ext_playtravelsound();
		
		if (self.cshift)	// independant func_watertrain
			SUB_fCalcMove (self.dest - self.mins, self.speed, self.think);
		
		else
			SUB_CalcMove (self.dest - self.mins, self.speed, self.think);
	}
	
	// Update children
	if (!self.cshift)	// func_watertrain can't have children
	{
		cchain = self.child;
		
		while(cchain)
		{
			if (self.speed == -1)
				setorigin (cchain, self.dest - self.mins);
			else 
				cchain.fmover = "moving"; // SUB_PushFrameMovers takes care of child moves

			cchain = cchain.child;
		}
	}
};

// go in the other direction!
void() train_ext_changedir =
{	
	train_ext_playchangedirsound();
	
	// Change direction	
	if (self.state == REVERSE)
	{
		self.state = FORWARD;
		self.think = train_ext_next;
	}
	
	else
	{
		self.state = REVERSE;
		self.think = train_ext_previous;
	}
	
	if (self.deadflag == WRONGWAY)
	{
		self.deadflag = RIGHTWAY;
		//dprint("RIGHTWAY - train_ext_changedir\n");
	}
	
	else if (self.deadflag == RIGHTWAY)
	{
		self.deadflag = WRONGWAY;
		//dprint("WRONGWAY - train_ext_changedir\n");
	}
};

// go forwards!
void() train_ext_goforward =
{
	// Can't move this way
	if (self.deadflag == RIGHTWAY && self.state == REVERSE)
	{
		train_ext_playwrongwaysound();
		return;
	}
	
	if (self.state == REVERSE)
		train_ext_changedir();
	
	else if (self.velocity != '0 0 0')
		return;		// already moving this way
	
	// Start moving
	train_ext_next();
};

// go backwards!
void() train_ext_goreverse =
{
	// Can't move this way
	if (self.deadflag == RIGHTWAY && self.state == FORWARD)
	{
		train_ext_playwrongwaysound();
		return;
	}
	
	if (self.state == FORWARD)
		train_ext_changedir();
	
	else if (self.velocity != '0 0 0')
		return;		// already moving this way
	
	// Start moving
	train_ext_previous();
};

// Reached the end, wait for orders
void() train_ext_atend =
{		
	self.enemy = activator;
	
	// If we're stuck at the end and get a changdir, next use can move
	if (other.classname == "t_changedir")
	{
		if (self.spawnflags & ALLOWCHANGEDIR)
		{
			self.use = train_ext_use;
			train_ext_changedir();	
		}
		return;
	}
	
	else if (other.classname == "t_stop")
		return;		// already stopped
	
	else if (other.classname == "t_forward")
	{
		self.use = train_ext_use;
		train_ext_goforward();
	}
	
	else if (other.classname == "t_reverse")
	{
		self.use = train_ext_use;
		train_ext_goreverse();
	}
	
	else	// Trying to move beyond last point
	 	train_ext_playwrongwaysound();
};

// react to any triggers we hit
void() train_ext_use =
{
	local entity cchain;
	
	if (self.think == train_ext_init)
		return;
	
	self.enemy = activator;
	
	//	
	// Changedir trigger
	//

	if (other.classname == "t_changedir")
	{
		if (self.spawnflags & ALLOWCHANGEDIR)
		{
			train_ext_changedir();
			
			// already moving?! Just change direction
			if (self.velocity != '0 0 0')
			{
				if (self.state == REVERSE)
				{
					train_ext_previous();
				}
				else
				{
					train_ext_next();
				}
			}
			
			// hmm, facing wrong way (can't move)
			else if (self.deadflag == WRONGWAY)
			{
				self.use = train_ext_atend;	// that's it, I quit
			}
			
			// change the goal to next waypoint in the other direction
			else
			{
				if (self.state == REVERSE)
				{
					self.goalentity = self.goalentity.next;
				}
				else
				{
					self.goalentity = self.goalentity.previous;
				}
			}
		}
		
		return;
	}
	
	//
	// Move Trigger
	//
	
	// forwards?
	else if (other.classname == "t_forward")
	{
		train_ext_goforward();
		return;
	}
	
	// backwards?
	else if (other.classname == "t_reverse")
	{
		train_ext_goreverse();
		return;
	}
	
	// Moving - stop it (ignore go relays)
	else if ((self.velocity != '0 0 0') && (other.classname != "t_go"))
	{
		if (self.spawnflags & ALLOWPAUSE)
		{			
			train_ext_playstopsound();
			
			// Stop the train where ever it may be
			self.velocity = '0 0 0';
			
			if (!self.cshift)
			{
				// Stop children
				cchain = self.child;
				
				while(cchain)
				{
					cchain.velocity = '0 0 0';
					cchain = cchain.child;
				}
			}

			self.nextthink = -1;
			self.deadflag = FREEMOVE;
			
			// Change the goal to next waypoint in the other direction
			if (self.state == REVERSE)
			{
				self.goalentity = self.goalentity.next;
			}
			else
			{
				self.goalentity = self.goalentity.previous;
			}
		}
		
		return;
	}
	
	// Stopped - start it back up (ignore stop relays)
	else if (other.classname != "t_stop")
	{	
		if (self.state == REVERSE)
			train_ext_previous();
		else
			train_ext_next();
	}
};

// check if we can move
void() train_ext_checkeventstate =
{
	local string	temp;

	// Check if it's *at* the waypoint since it can start/stop inbetween
	if (self.origin == (self.goalentity.origin - self.mins))
	{
		// Fire events at this waypoint
		if (self.event)
		{
			activator = self.enemy;
			temp = self.target;
			self.target = self.event;
			SUB_UseTargets();
			self.target = temp;
		}
		
		/*		
		dprint("FIRE EVENT AT: ");
		dprint(self.goalentity.targetname);
		dprint(" : ");
		dprint(self.event);
		dprint("\n\n");
		*/

		// This the end of the line?
		if (self.goalentity == self.aiment)
		{
			// reverse direction?
			if (self.spawnflags & AUTOREVERSE && self.deadflag != WRONGWAY)
			{
				train_ext_playchangedirsound();
				
				self.deadflag = RIGHTWAY;
				
				//dprint("RIGHTWAY - train_ext_checkeventstate\n");
				
				if (self.state == FORWARD)
					self.state = REVERSE;
				else
					self.state = FORWARD;
			}
			
			// Trying to move beyond last point?
			else if (self.deadflag == WRONGWAY)
			{
				train_ext_playwrongwaysound();
			}
			
			// just stop
			else
			{
				train_ext_playstopsound();
				self.deadflag = WRONGWAY;
				//dprint("WRONGWAY - train_ext_checkeventstate\n");
				self.use = train_ext_atend;
			}
		}
		
		// Not the end yet?  
		else
		{
			if (self.deadflag == RIGHTWAY)
			{
				self.deadflag = FREEMOVE;	// fine, let's go
				//dprint("FREEMOVE - train_ext_checkeventstate\n");
			}
		}
	}
};

// do the waiting at current waypoint
void() train_ext_wait =
{
	local entity cchain;
	
	if (self.think == train_ext_init)
		return;
	
	// trigger events
	if (self.state == REVERSE)
	{
		self.event = self.goalentity.event2;
		self.aiment = self.goalentity.previous;
		self.think = train_ext_previous;
	}
	
	else
	{
		self.event = self.goalentity.event;
		self.aiment = self.goalentity.next;
		self.think = train_ext_next;
	}
	
	// check if we can move
	train_ext_checkeventstate();
	
	if (self.wait)
	{

		train_ext_playstopsound();
		
		if (self.wait != -1)
		{
			if (!self.cshift)
				self.nextthink = self.ltime + self.wait;
			else
				self.nextthink = time + self.wait;
		}
		
	}
	
	else
		objerror ("func_train_ext: Waiting without wait time!");
};

// get the previous waypoint (reverse) and move there
void() train_ext_previous =
{
	if (self.think == train_ext_init)
		return;

	/*
	dprint("FROM:");
	dprint(self.goalentity.targetname);
	dprint(" TO:");
	dprint(self.goalentity.previous.targetname);
	dprint(" nextwait:");
	dprint(ftos(self.goalentity.previous.wait2));
	dprint("\n");
	*/
	
	// Trigger events	
	self.event = self.goalentity.event2;
	self.aiment = self.goalentity.previous;
	
	// check if we can move
	train_ext_checkeventstate();

	// check if waypoint alters ignore_block
	if (self.goalentity.ignore_block != self.ignore_block)
		self.ignore_block = self.goalentity.ignore_block;

	// Current speed
	if (self.goalentity.speed2)
		self.speed = self.goalentity.speed2;
	
	// Save out the current sound overrides
	if (self.goalentity.noise2)
		self.noise2 = self.goalentity.noise2;
	
	else
		self.noise2 = self.noise;
	
	if (self.goalentity.noise3)
		self.noise3 = self.goalentity.noise3;
	
	else
		self.noise3 = self.noise1;
	
	// Get the next waypoint
	self.goalentity = self.goalentity.previous;
	
	// Save out the destination for this move
	self.dest = self.goalentity.origin;
	
	// Save the wait for the upcoming waypoint
	self.wait = self.goalentity.wait2;

	// Decide what to do after the move
	self.nextthink = -1;
	
	if (self.wait)
		self.think = train_ext_wait;
	
	else if (self.state == REVERSE)
		self.think = train_ext_previous;
	
	else
		self.think = train_ext_next;
		
	train_ext_move();
};

// get the next waypoint (forward) and move there
void() train_ext_next =
{
	if (self.think == train_ext_init)
		return;

	/*
	dprint("FROM:");
	dprint(self.goalentity.targetname);
	dprint(" TO:");
	dprint(self.goalentity.next.targetname);
	dprint(" nextwait:");
	dprint(ftos(self.goalentity.next.wait));
	dprint("\n");
	*/
	
	// Trigger events
	self.event = self.goalentity.event;
	self.aiment = self.goalentity.next;
	
	// check if we can move
	train_ext_checkeventstate();
	
	// check if waypoint alters ignore_block
	if (self.goalentity.ignore_block != self.ignore_block)
		self.ignore_block = self.goalentity.ignore_block;

	// Current speed
	if (self.goalentity.speed)
		self.speed = self.goalentity.speed;
	
	// Save out the current sound overrides
	if (self.goalentity.noise)
		self.noise2 = self.goalentity.noise;
	else
		self.noise2 = self.noise;
	
	if (self.goalentity.noise1)
		self.noise3 = self.goalentity.noise1;
	else
		self.noise3 = self.noise1;
	
	// Get the next waypoint
	self.goalentity = self.goalentity.next;
	
	// Save out the destination for this move
	self.dest = self.goalentity.origin;
	
	// Save the wait for the upcoming waypoint
	self.wait = self.goalentity.wait;
	
	// Decide what to do after the move
	self.nextthink = -1;
	
	if (self.wait)
		self.think = train_ext_wait;
	
	else if (self.state == REVERSE)
		self.think = train_ext_previous;
	
	else
		self.think = train_ext_next;
		
	train_ext_move();
};

.float linked;	// Supa, don't link waypoints more than once

// Find and link waypoints, and set the train up
void() train_ext_init =
{
	local entity way, stemp, wtemp, lastent, cchain;
	
	// Find the first waypoint
	way = find (world, targetname, self.target);
	
	// Be strict about this
	if (way.classname != "path_corner")
		 objerror ("train_ext_init: illegal target type");
	
	// First waypoint requires speed & target (or else we aint moving!)
	if (!way.target)
		objerror ("train_ext_init: first waypoint requires target");
	
	if (!way.speed)
		way.speed = self.speed;	// copy train's speed
	
	if (!way.speed)
		objerror ("train_ext_init: first waypoint or train requires speed");
	
	wtemp = way;// Save the first waypoint
	stemp = self;// Save the train
	
	lastent = self;	// Supa, need to save last ent linked in order to make a proper linked list
	
	// Link all the waypoints 
	while	(way			&&
			 !way.linked	&&
			 way != stemp	)	// Supa, don't try to assign to world, please :(
	{	
		if (way.classname != "path_corner")
			objerror ("train_ext_init: illegal target type");
		
		// Supa, argh argh argh, needed for legacy loop paths
		if (way.target)
			way.next = find (world, targetname, way.target);

		lastent.next = way;
		way.previous = lastent;
		
		way.linked = TRUE;
		
		if (!way.speed)
			way.speed = lastent.speed;
		
//		self = way;	// temporarily switch self to the waypoint
		
		// On a non-looped path, "event" can hold an alternate start position
		if (stemp.event)
		{
			if (stemp.event == self.targetname)
				stemp.goalentity = way;
		}
		
		lastent = way;	// Supa, don't forget to link the waypoint to the _Actual_ previous waypoint and not just the train..
		
		// Last waypoint doesn't need a target (train will stop/reverse here)
		if (!way.target)
		{
			way.next = way;	// so train_next knows to stop
			wtemp.previous = wtemp;	// so train_previous knows to stop
			way = stemp;		// break
		}
		else if (way.next == wtemp)
		{		// Stop when we hit the first waypoint again (loop)
			wtemp.previous = way;	// connect the first waypoint to the last
			way = stemp;		// break
		}
		else way = find(world, targetname, way.target); 		// Get the next target, Supa changed from way to world - link *all* targets, going through the ent list again if you have to
	}
		
	self = stemp;	// switch self back to the train
	
	// Prep goalentity so it points to start position
	if (!self.goalentity)
		self.goalentity = wtemp;
	
	// Position the train at it's first waypoint
	setorigin (self, self.goalentity.origin - self.mins);
	
	// Supa, update childorgs now because DP is Special when it comes to bmodel orgs and fitz refuses to cooperate
	if (!self.cshift)	// func_watertrain can't have children
	{
		cchain = self.child;
		
		while(cchain)
		{
			cchain.fmover = "moving"; // SUB_PushFrameMovers takes care of child moves

			cchain = cchain.child;
		}
	}
	
	// Start it up...
	self.nextthink = -1;
	self.think = train_ext_next;
		
	// Get direction for first move
	if (self.spawnflags & STARTREVERSE)
		self.state = REVERSE;
	else
		self.state = FORWARD;
	
	// Decide if we're facing a good way to start
	if (self.goalentity == self.next)	// at first waypoint
	{
		if (self.state == REVERSE)
		{
			// endpoint - can't move
			if (self.goalentity.previous == self.goalentity)
			{
				self.deadflag = WRONGWAY;
				self.use = train_ext_atend;
			}
		}
		else
			self.deadflag = RIGHTWAY;

	}
	else if (self.goalentity.next == self.goalentity)	// at last waypoint
	{		
		if (self.state == FORWARD)
		{	
			// have to be in reverse to allow move here
			self.deadflag = WRONGWAY;
			self.use = train_ext_atend;
		}
		else
			self.deadflag = RIGHTWAY;
	}
	else	// somewhere in the middle
		self.deadflag = FREEMOVE;
	
	// self.velocity = '0 0 0';
	
	if (self.spawnflags & FORCE_START_ON)
		self.nextthink = self.ltime + time + 0.1;
};

// precache sounds
void() train_ext_precachenoise =
{
	if (self.sounds == 1)	// legacy support
	{
		self.noise = "plats/train1.wav";
		self.noise1 = "plats/train2.wav";
	}

	if (!self.noise)	// travel sound
		self.noise = "misc/null.wav";
	
	if (!self.noise1)	// stop sound
		self.noise1 = "misc/null.wav";
	
	if (self.noise4)	// change dir sound
		precache_sound(self.noise4);
	
	if (self.noise5)	// wrong way sound
		precache_sound(self.noise5);
	
	else
		self.noise5 = self.noise1;
	
	precache_sound(self.noise);
	precache_sound(self.noise1);
};

/*QUAKED func_train (0 .5 .8) ? FORCE_START_ON ALLOWPAUSE ALLOWCHANGEDIR AUTOREVERSE BLOCKREVERSE STARTREVERSE
Trains are moving platforms that players can ride.
The targets origin specifies the min point of the train at each corner.
The train spawns at the first target it is pointing at.
If the train is the target of a button or trigger, it will not begin moving until activated.

"speed"			Speed of the train (can be overridden by waypoints), default 100
"dmg"			amonut of damage to inflict when blocked
"sounds"		1 = enables standard id sounds for noise and noise1
"noise" 		Start/travel noise (can be overridden by waypoints)
"noise1"		Stop noise (can be overridden by waypoints)
"noise4"		Noise to make when changing directions (DON'T USE A LOOPED WAV!!)
"noise5"		Noise to make when trying to go wrong way at end of path (uses "noise1" if not set)

"target"		First waypoint or start position
"event"			Start at this waypoint (since you MUST use the first waypoint as the "target" on a non-looped path)
"targetname" 	can be triggered and/or targeted by child objects

Spawnflags:

"FORCE_START_ON"		Start the train immediately, even if targeted.
"ALLOWPAUSE"		Re-Triggering will pause/resume the train at any point along it's path.
"ALLOWCHANGEDIR"	Lets a changedir trigger reverse the train's direction at any time

"AUTOREVERSE"		Train automatically reverses direction when it hits the last/first waypoint
			(only makes sense if last waypoint has no target). It will NOT auto-reverse on
			spawn if facing the wrong way (which is possible and valid).

"BLOCKREVERSE"		Reverses train direction when blocked (after inflicting damage)
			Don't use this on trains with non-looped paths without some way of getting it
			back to the forward direction (AUTOREVERSE or ALLOWCHANGEDIR). Else it'll
			get stuck when it reaches the start point again.

"STARTREVERSE"		Start in reverse

NOTES:

A train without a targetname will start immediately (doesn't need "FORCE_START_ON" to be set)
but it can not be stopped, and can not have children objects.

If your waypoints are not looped (i.e. the last point doesn't target the first), the train MUST
target the first waypoint. Use the "event" target to have the train spanw at a different point
along it's path ("event" is ignored if it's not on the same path.).

If you have a train on a non looped waypoint path, and AUTOREVERSE is not set, the train will stop
at the last waypoint. If ALLOWCHANGEDIR is set, and the train gets a t_changerdir trigger, you will
then be able to re-trigger movement in the reverse direction. Otherwise re-triggering will just
produce the wrong-way sound.
*/
// pox
void() func_train =
{
	if (!self.target)
		objerror ("func_train without a target");
	
	if (!self.dmg)
		self.dmg = 2;
	
	if (self.speed < -1)
		self.speed = -1;
	
	if (!self.speed)
		self.speed = 100;	// legacy support
	
	train_ext_precachenoise();
	
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.blocked = train_ext_blocked;
	self.classname = "train_ext";
	setmodel (self, self.model);
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);
	
	// set start flag if not triggered
	if (!self.targetname)
		self.spawnflags = self.spawnflags | FORCE_START_ON;
	
	self.use = train_ext_use;
	
	// start trains on the second frame, to make sure their targets have had a chance to spawn
	self.nextthink = self.ltime + 0.25;	// wait for path_corners to setup first
	self.think = train_ext_init;
};


// misc_teleporttrain, uses func_train subroutines =======================

/*QUAKED misc_teleporttrain (0 .5 .8) (-8 -8 -8) (8 8 8)
This is used for the final boss
*/
void() misc_teleporttrain =
{	
	if (!self.speed)
		self.speed = 100;
	if (!self.target)
		objerror ("func_train without a target");

	self.cnt = 1;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_PUSH;
	self.blocked = train_ext_blocked;
	self.use = train_ext_use;
	self.avelocity = '100 200 300';

	self.noise = ("misc/null.wav");
	precache_sound ("misc/null.wav");
	self.noise1 = ("misc/null.wav");
	precache_sound ("misc/null.wav");

	precache_model2 ("progs/teleport.mdl");
	setmodel (self, "progs/teleport.mdl");
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);

	// start trains on the second frame, to make sure their targets have had
	// a chance to spawn
	self.nextthink = self.ltime + 0.25;
	
	self.think = train_ext_init;
};

