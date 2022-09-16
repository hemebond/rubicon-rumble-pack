/*
Random object spawning
======================

This is the file that does the bulk of the work for making this happen.

The bulk of the work is done by ProcessGroup() on the first frame after the spawning,
so precaching on that frame is a no-no, but as it's the frame before players
enter the world, makestatic() is still safe, and probably ambient() as well.

To make this work, you need to add hooks to the code to each entity you want to use
with this, and likely also splitting the spawn function into two parts.
See the additional files r_items.qc and r_soldier.qc for examples.
Hooks can probably be added to any desired entity.

Suggested compile order: after subs.qc, but before any spawn functions

LA - April/May 2009
*/

.string group; // Random group to be a part of. The intention is for this to be
				// seperate from the "loyalty group", as it allows you to
				// scatter monsters from a group around the map, without them
				// all waking up when you kill the first one.
				// You may want to rename this variable...
.float groupcount; // For objects, set this to 1 to use its location as well
					// May be desireable to rever the log on this.
.entity nextobject; // Two seperate linked lists are used so that they can be
.entity nextlocation; // traversed independently of each other.
.vector grouporigin; // Backups of current positions, necessary if you have
.vector groupangles; // objects being used as locations.
.string grouptarget;	//ijed This allows entities that arrive at a given location to adopt its target
.void() go; // The second half of the object's spawn function,
			// to be called when the object is selected.
.vector originhack; // Used to correctly mix things that have their origins in
					// unusual places, such as ammo boxes.

void() ProcessGroup =
{
	local entity headobject, headlocation;
	local entity pointobject, pointlocation; // current list pointers
	local entity e, oself;
	local float r, i;
	local float numobjects, numlocations;
	local string process_string;

	//ijed Improved crash message for groupleaders without a group
	if (self.group == string_null)
	{
		dprint ("Groupleader without group at: ");
		dprint (vtos (self.origin));
		dprint ("\n");
	}
	else
	{
		dprint("Groupleader for group ");
		dprint(self.group);
		dprint(" is searching...\n");
	}
		
	e = find(world, group, self.group);

	while (e != world)
	{
		if (e.classname != "info_groupleader")
		{
			if (e.classname != "info_location")		// If an object
			{
				if (!numobjects)	// if first item in list, set everything up
				{
					headobject = e;
					e.nextobject = world;
					numobjects = 1;
				}
				else
				{
					numobjects = numobjects + 1;
					r = random() * numobjects; // number of steps down the chain to insert
					r = floor(r); // avoid potential compiler bug
					
					if (r == numobjects		||
						r == numobjects - 1	)	// become new head
					{
						e.nextobject = headobject;
						headobject = e;
					}
					else
					{
						pointobject = headobject;

						while (r)
						{
							pointobject = pointobject.nextobject; // STEP
							r = r - 1;
						} // at this point, we have walked the list r times

						e.nextobject = pointobject.nextobject;
						pointobject.nextobject = e;
					}
				}
			} // end object add loop

			if (e.groupcount ==  1)	// If a location
			{
				if (!numlocations)	 // if first item in list, set everything up
				{
					headlocation = e;
					e.nextlocation = world;
					numlocations = 1;
				}
				else
				{
					numlocations = numlocations + 1;
					r = random() * numlocations; // number of steps down the chain to insert
					r = floor(r); // avoid potential compiler bug

					if (r == numlocations		||
						r == numlocations - 1	)	 // become new head
					{
						e.nextlocation = headlocation;
						headlocation = e;
					}
					else
					{
						pointlocation = headlocation;

						while (r)
						{
							pointlocation = pointlocation.nextlocation; // STEP
							r = r - 1;
						} // at this point, we have walked the list r times
						
						e.nextlocation = pointlocation.nextlocation;
						pointlocation.nextlocation = e;
					}
				}
			} // end location add loop
		}

		e = find(e, group, self.group);
	} // end list building

	// create entities
	i = self.groupcount;
	if (!i) i = numobjects;
	i = floor(i);
	dprint("Found ");
	process_string = ftos(numobjects);
	dprint (process_string);
	dprint(" objects and ");
	process_string = ftos(numlocations);
	dprint (process_string);
	dprint(" locations; Attempting to select ");
	process_string = ftos(self.groupcount);
	dprint (process_string);
	dprint(" of them\n");

	pointobject = headobject;
	pointlocation = headlocation;

	while (	i > 0						&&
			pointobject		!= world	&&
			pointlocation	!= world	)
	{
		pointobject.origin = pointlocation.grouporigin - pointobject.originhack;
		pointobject.angles = pointlocation.groupangles;
		
		if (pointlocation.target != string_null)
				pointobject.target = pointlocation.grouptarget;

		
		oself = self;
		self = pointobject;
		
		if (!self.go)
		{
			dprint("\b ERROR:");
			dprint(" object at ");
			dprint (vtos(self.origin));
			dprint(" cannot be randomised \n");
		}
		
		self.go(); // FIXME: Don't crash horribly if this isn't available -> ijed: See above...
		self = oself;
		
		if (pointlocation.classname == "info_location")	// cleanup as we go, if we can
		{
			pointlocation.think = SUB_Remove;
			pointlocation.nextthink = time;
		}
		
		pointobject = pointobject.nextobject;
		pointlocation = pointlocation.nextlocation;
		
		i = i - 1;
	}

	// cleanup
	while (pointobject != world)
	{
		pointobject.think = SUB_Remove;
		pointobject.nextthink = time;
		pointobject = pointobject.nextobject;
	}
	
	while (pointlocation != world)
	{
		if (pointlocation.classname == "info_location") // not safe to remove otherwise
		{
			pointlocation.think = SUB_Remove;
			pointlocation.nextthink = time;
		}
		
		pointlocation = pointlocation.nextlocation;
	}
	
	self.think = SUB_Remove; // and finally
	self.nextthink = time;
};

float() CheckGroup =
{
	if (self.group != "")	 // This is where the fun begins...
	{
		if (self.groupcount == 1)	 // This is a location as well
		{
			self.grouporigin = self.origin + self.originhack;
			self.groupangles = self.angles;
			
			if (self.target != string_null)			//ijed
				self.grouptarget = self.target;
		}
		return 1;
	}
	return 0;
};

/*QUAKED info_location (1 0.8 0) (-16 -16 -8) (16 16 8)
A possible location for random groups.
Set origin and angle. Removed when no longer needed.
ijed: now sets target as well

group: Which group it belongs to
*/
void() info_location =
{
	self.grouporigin = self.origin;
	self.groupangles = self.angles;	
	
	if (self.target != string_null)			//ijed
		self.grouptarget = self.target;
	
	if (self.targetname != string_null)		//ijed
		self.targetname = string_null;		//do not allow it to have a targetname
	
	if (self.group == string_null)		//ijed
	{
		dprint("\b ERROR:");
		dprint("info_location at ");
		dprint (vtos(self.origin));
		dprint(" has no group set\n");
	}
	
	if (self.targetname != string_null)		//ijed
	{
		dprint("\b ERROR:");
		dprint("info_location at ");
		dprint (vtos(self.origin));
		dprint(" has a targetname\n");
	}
	
	self.groupcount = 1; // Bit of a hack, but it simplifies the logic later on
};

/*QUAKED info_groupleader (1 0.8 0) (-8 -8 -16) (8 8 16)
Controlling entity for a random group.
Entity is removed soon after the map is loaded, so don't rely on its presistance for any entity hacks.

group: Which group it controls
groupcount: How many objects from the group to use
*/
void() info_groupleader =
{
	if (self.group == string_null)		//ijed
	{
		dprint("\b ERROR:");
		dprint("info_groupleader at ");
		dprint (vtos(self.origin));
		dprint(" has no group set\n");
	}
	
	if (self.targetname != string_null)		//ijed
	{
		dprint("\b ERROR:");
		dprint("info_groupleader at ");
		dprint (vtos(self.origin));
		dprint(" has a targetname\n");
	}
	
//	if (time < 0.5)	// Supa AUUUUUUGH DON'T CORRUPT THE FUCKING ENTITY LIST IN SP !!!!!!!111
//	{
		self.nextthink = time + random() * 10; // next frame
		self.think = ProcessGroup;
//	}
};

