

void() SUB_Null = {};

void() SUB_Remove = {remove(self);};


/*
================
QuakeEd only writes a single float for angles (bad idea), so up and down are
just constant angles.
================
*/
void() SetMovedir =
{
	if (self.angles == '0 -1 0')
		self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0')
		self.movedir = '0 0 -1';
	else
	{
		makevectors (self.angles);
		self.movedir = v_forward;
	}
	
	self.angles = '0 0 0';
};

/*
================
InitTrigger
================
*/
void() InitTrigger =
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	if (self.angles != '0 0 0')
		SetMovedir ();
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);	// set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
};

/*
=============
SUB_CalcMove

calculate self.velocity and self.nextthink to reach dest from
self.origin traveling at speed
===============
*/
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt =
{
local entity	stemp;
	stemp = self;
	self = ent;

	SUB_CalcMove (tdest, tspeed, func);
	self = stemp;
};

void(vector tdest, float tspeed, void() func) SUB_CalcMove =
{
local vector	vdestdelta;
local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");

	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
		
// set destdelta to the vector needed to move
	vdestdelta = tdest - self.origin;
	
// calculate length of vector
	len = vlen (vdestdelta);
	
// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	if (traveltime < 0.1)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
	
// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = vdestdelta * (1/traveltime);	// qcc won't take vec/float	
};

/*
============
After moving, set origin to exact final destination
============
*/
void()  SUB_CalcMoveDone =
{
	setorigin(self, self.finaldest);
	self.velocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1();
};


/*
=============
SUB_CalcAngleMove

calculate self.avelocity and self.nextthink to reach destangle from
self.angles rotating 

The calling function should make sure self.think is valid
===============
*/
void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt =
{
local entity		stemp;
	stemp = self;
	self = ent;
	SUB_CalcAngleMove (destangle, tspeed, func);
	self = stemp;
};

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove =
{
local vector	destdelta;
local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");
		
// set destdelta to the vector needed to move
	destdelta = destangle - self.angles;
	
// calculate length of vector
	len = vlen (destdelta);
	
// divide by speed to get time to reach dest
	traveltime = len / tspeed;

// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.avelocity = destdelta * (1 / traveltime);
	
	self.think1 = func;
	self.finalangle = destangle;
	self.think = SUB_CalcAngleMoveDone;
};

/*
============
After rotating, set angle to exact final angle
============
*/
void() SUB_CalcAngleMoveDone =
{
	self.angles = self.finalangle;
	self.avelocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1();
};


//=============================================================================

void() DelayThink =
{
	activator = self.enemy;
	SUB_UseTargets ();
	remove(self);
};

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any self.message to the activator.

Removes all entities with a targetname that match self.killtarget,
and removes them, so some events can remove other triggers.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function

==============================
*/
void() SUB_UseTargets =
{
	local entity t, stemp, otemp, act;

//
// check for a delay
//
	if (self.delay)
	{
	// create a temp object to fire at a later time
		t = spawn();
		t.classname = "DelayedUse";
		t.nextthink = time + self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		return;
	}
	
	
//
// print the message
//
	if (activator.classname == "player" && self.message != "")
	{
		centerprint (activator, self.message);
		if (!self.noise)
			sound (activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}

//
// kill the killtagets
//
	if (self.killtarget)
	{
		//johnfitz -- fix for "killtarget" prevents "target" from firing
		t = find (world, targetname, self.killtarget);
		while (t)
		{
			remove (t);
			t = find (t, targetname, self.killtarget);
		}
		//johnfitz
	}
	
//
// fire targets
//
	if (self.target)
	{
		act = activator;
		t = world;
		do
		{
			t = find (t, targetname, self.target);
			if (!t)
			{
				return;
			}
			stemp = self;
			otemp = other;
			self = t;
			other = stemp;
			if (self.use != SUB_Null)
			{
				if (self.use)
					self.use ();
			}
			self = stemp;
			other = otemp;
			activator = act;
		} while ( 1 );
	}
	

};


/*

in nightmare mode, all attack_finished times become 0
some monsters refire twice automatically

*/

void(float normal) SUB_AttackFinished =
{
	self.cnt = 0;		// refire count for nightmare
	if (skill != 3)
		self.attack_finished = time + normal;
};

float (entity targ) visible;

void (void() thinkst) SUB_CheckRefire =
{
	if (skill != 3)
		return;
	if (self.cnt == 1)
		return;
	if (!visible (self.enemy))
		return;
	self.cnt = 1;
	self.think = thinkst;
};

// ijed c+p from schism
// extras, gb
// Written by Frank Condello <pox@planetquake.com>
//	
// Modified SUB_CalcMove clone that work with non-push entities,
// and misc reusable functions...

/*
============
SUB_RandomRange

Return a random number between min & max (or min if max is 0)
Just make sure max is greater than min...
============
*/
float(float rmin, float rmax) SUB_RandomRange =
{
	if (!rmax)
		return rmin;
	else
		return rmin + random()*(rmax-rmin);
};

//============================================================================
float lastframe;

/*
============
This is called from PostThink to advance all moving triggers each frame
============
*/
void() SUB_PushFrameMovers =
{
	local entity ent;
	
	// Make sure this only happens once per frame (bots)
	if (lastframe == time) return;	
	lastframe = time;
	
	// Find the first ent
	ent = find(world, fmover, "moving");
	
	while(ent)
	{	
		// Child move
		if (ent.owner)
		{
			// Ignore next frame (done moving)
			if (ent.owner.velocity == '0 0 0') {
				ent.fmover = string_null;
				ent.origin = ent.owner.origin;
				setorigin(ent, ent.origin);
			}
			// Parent is Blocked
			else if ((ent.owner.attack_finished-(0.5-frametime)) > time ) {
				ent.origin = ent.owner.origin;
				setorigin(ent, ent.origin);
			}
			// Lead parent a bit (seems to track better)
			else {
				ent.origin = ent.owner.origin + ent.owner.velocity*frametime;
				setorigin(ent, ent.origin);
			}
		}
		// Independant func_water or func_watertrain
		else if (ent.velocity == '0 0 0') {
			ent.fmover = string_null;// Ignore next frame (done moving)
		}
		// Add move for this frame
		else {
			ent.origin = ent.origin + ent.velocity*frametime;
			setorigin(ent, ent.origin);
		}
		
		// Get the mext one
		ent = find(ent, fmover, "moving");
	}	
};

//============================================================================

void() SUB_fCalcMoveDone =
{
	self.fmover = string_null;
	setorigin(self, self.finaldest);
	self.velocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1) self.think1();
};

/*
=============
SUB_fCalcMove

Just like SUB_CalcMove, sets up fmover for next frame
==============
*/
void(vector tdest, float tspeed, void() func) SUB_fCalcMove =
{
	local vector	vdestdelta;
	local float		len, traveltime;

	if (!tspeed) objerror("No speed is defined!");
	
	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_fCalcMoveDone;
	
	if (tdest == self.origin) {
		self.velocity = '0 0 0';
		self.nextthink = time + 0.1;
		return;
	}
	
	vdestdelta = tdest - self.origin;
	len = vlen(vdestdelta);
	traveltime = len / tspeed;
	
	if (traveltime < 0.1) {
		self.velocity = '0 0 0';
		self.nextthink = time + 0.1;
		return;
	}
	
	self.fmover = "moving";
	self.nextthink = time + traveltime;
	self.velocity = vdestdelta * (1/traveltime);
};
