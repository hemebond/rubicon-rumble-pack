/* ALL MONSTERS SHOULD BE 1 0 0 IN COLOR */

// name =[framenum,	nexttime, nextthink] {code}
// expands to:
// name ()
// {
//		self.frame=framenum;
//		self.nextthink = time + nexttime;
//		self.think = nextthink
//		<code>
// };


/*
================
monster_use

Using a monster makes it angry at the current activator
================
*/
void() monster_use =
{
	if (self.enemy)
		return;
	if (self.health <= 0)
		return;
	if (activator.items & IT_INVISIBILITY)
		return;
	if (activator.flags & FL_NOTARGET)
		return;
	if (activator.classname != "player")
		return;
	
// delay reaction so if the monster is teleported, its sound is still
// heard
	self.enemy = activator;
	self.nextthink = time + 0.1;
	self.think = FoundTarget;
};

/*
================
monster_death_use

When a mosnter dies, it fires all of its targets with the current
enemy as activator.
================
*/
void() monster_death_use =
{
	local entity 	ent, otemp, stemp;

// fall to ground
	if (self.flags & FL_FLY)
		self.flags = self.flags - FL_FLY;
	if (self.flags & FL_SWIM)
		self.flags = self.flags - FL_SWIM;

	if (!self.target)
		return;

	activator = self.enemy;
	SUB_UseTargets ();
};


//============================================================================

void() walkmonster_start_go =
{
local string	stemp;
local entity	etemp;

	self.origin_z = self.origin_z + 1;	// raise off floor a bit
	
	if(!(self.spawnflags & SPAWN_TRIGGERED))	//ijed Don't drop them if they're supposed to spawn midair, let them fall
		droptofloor();
	
	if (!walkmove(0,0))
	{
		dprint ("walkmonster in wall at: ");
		dprint (vtos(self.origin));
		dprint ("\n");
	}
	
	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 20;
	self.view_ofs = '0 0 25';
	self.use = monster_use;
	
	self.flags = self.flags | FL_MONSTER;
	
	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
			self.th_walk ();
		else
			self.pausetime = 99999999;
			self.th_stand ();
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}

//johnfitz -- added monster spawning code from Preach
//http://www.inside3d.com/showtutorial.php?id=171
if(!(self.spawnflags & SPAWN_TRIGGERED))
	// spread think times so they don't all happen at same time
	//self.nextthink = self.nextthink + random()*0.5;
	self.nextthink = time + 0.1 + random()*0.5;			//ijed, original fix by lord smeagol
//johnfitz
};

//johnfitz -- added monster spawning code from Preach
//http://www.inside3d.com/showtutorial.php?id=171
void(vector org) spawn_tfog;
void(vector org, entity death_owner) spawn_tdeath;

void() monster_teleport =
{
	self.solid = self.walkframe;
	self.movetype = self.fly_sound;
	setmodel(self, self.wad);
	setsize (self, self.pos1, self.pos2);

	//telefrag any existing entities
	spawn_tdeath (self.origin, self); 

	//sound and particle effects	
	if(!(self.spawnflags & SPAWN_SILENT))
		spawn_tfog (self.origin);	
	
	if(self.spawnflags & SPAWN_ANGRY)	//ijed This means it'll still shout if autoalerted, despite spawn silent
		FindTarget();
		//SightSound ();	
	
	self.think1();
}
//johnfitz

void() walkmonster_start =
{
//johnfitz -- added monster spawning code from Preach 
//http://www.inside3d.com/showtutorial.php?id=171
//modified by ijed
	if(self.spawnflags & SPAWN_TRIGGERED)
		{
			//PREACH: This monster is to be teleported in

			//store the important info in unused fields
			self.wad = self.model;
			self.pos1 = self.mins;
			self.pos2 = self.maxs;
			self.walkframe = self.solid;
			self.fly_sound = self.movetype;

			//hide the model and make it non-solid
			self.model = "";
			self.solid = SOLID_NOT;
			self.movetype = MOVETYPE_NONE;

			//set up the teleport functions
			self.use = monster_teleport;
			self.think1 = walkmonster_start_go;
			
			total_monsters = total_monsters + 1;
							
			return;
		}
//johnfitz

// delay drop to floor to make sure all doors have been spawned
// spread think times so they don't all happen at same time
	//self.nextthink = self.nextthink + random()*0.5;
	self.nextthink = time + 0.1 + random()*0.5;			//ijed, original fix by lord smeagol
	self.think = walkmonster_start_go;
	
	if (!self.spawned)	//ijed Avoid bumping the counter twice - this is called in the monster
		total_monsters = total_monsters + 1;
};



void() flymonster_start_go =
{
	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 25';
	self.use = monster_use;

	self.flags = self.flags | FL_FLY;
	self.flags = self.flags | FL_MONSTER;

	if (!walkmove(0,0))
	{
		dprint ("flymonster in wall at: ");
		dprint (vtos(self.origin));
		dprint ("\n");
	}

	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
			self.th_walk ();
		else
			self.pausetime = 99999999;
			self.th_stand ();
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}
};

void() flymonster_start =
{
//johnfitz -- added monster spawning code from Preach
//http://www.inside3d.com/showtutorial.php?id=171
	if(self.spawnflags & SPAWN_TRIGGERED)
		{
		//PREACH: This monster is to be teleported in, so hide it
		self.wad = self.model;
		self.pos1 = self.mins;
		self.pos2 = self.maxs;
		self.walkframe = self.solid;
		self.fly_sound = self.movetype;

		self.model = "";
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NONE;
		self.use = monster_teleport;
		self.think1 = flymonster_start_go;
		total_monsters = total_monsters + 1;
		return;
	}
	//johnfitz

// spread think times so they don't all happen at same time
	//self.nextthink = self.nextthink + random()*0.5;
	self.nextthink = time + 0.1 + random()*0.5;			//ijed, original fix by lord smeagol
	self.think = flymonster_start_go;
	total_monsters = total_monsters + 1;
};


void() swimmonster_start_go =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	self.takedamage = DAMAGE_AIM;
	
	//total_monsters = total_monsters + 1; //johnfitz here's that damn fish monster count bug.
	//ijed Hahah, came here looking for the same thing, just in case...

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 10';
	self.use = monster_use;
	
	self.flags = self.flags | FL_SWIM;
	self.flags = self.flags | FL_MONSTER;

	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		self.th_walk ();
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}

// spread think times so they don't all happen at same time
	//self.nextthink = self.nextthink + random()*0.5;		
	self.nextthink = time + 0.1 + random()*0.5;			//ijed, original fix by lord smeagol
};

void() swimmonster_start =
{
// spread think times so they don't all happen at same time
	//self.nextthink = self.nextthink + random()*0.5;
	self.nextthink = time + 0.1 + random()*0.5;			//ijed, original fix by lord smeagol
	self.think = swimmonster_start_go;
	total_monsters = total_monsters + 1;
};


