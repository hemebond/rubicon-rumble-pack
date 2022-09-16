/*
==============================================================================

BLOB

	Modified by ijed to feature the tar family - large versions that split 
	into progressively smaller ones, ending with the original tar baby.
	
	The largest two tar creatures also spit eyeballs and burst into eyeballs
	when killed.
	
	Tar babies themselves now leap less repeatedly and have less than half 
	their previous health.

==============================================================================
*/

$cd id1/models/tarbaby
$origin 0 0 24
$base base

$skin skin

$frame walk1 walk2 walk3 walk4  walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16 walk17 walk18 walk19
$frame walk20 walk21 walk22 walk23 walk24 walk25

$frame run1 run2 run3 run4 run5 run6  run7 run8 run9 run10 run11 run12 run13
$frame run14 run15 run16 run17 run18 run19 run20 run21 run22 run23
$frame run24 run25

$frame jump1 jump2 jump3 jump4 jump5 jump6

$frame fly1 fly2 fly3 fly4

$frame exp

//==============================================================================

void() monster_tarbaby;
void() TarSpitGib;

//==============================================================================

void()	tbaby_stand1	=[	$walk1,		tbaby_stand1	] {ai_stand();};

void()	tbaby_hang1		=[	$walk1,		tbaby_hang1	] {ai_stand();};

void()	tbaby_walk1		=[	$walk1,		tbaby_walk2	] {ai_turn();};
void()	tbaby_walk2		=[	$walk2,		tbaby_walk3	] {ai_turn();};
void()	tbaby_walk3		=[	$walk3,		tbaby_walk4	] {ai_turn();};
void()	tbaby_walk4		=[	$walk4,		tbaby_walk5	] {ai_turn();};
void()	tbaby_walk5		=[	$walk5,		tbaby_walk6	] {ai_turn();};
void()	tbaby_walk6		=[	$walk6,		tbaby_walk7	] {ai_turn();};
void()	tbaby_walk7		=[	$walk7,		tbaby_walk8	] {ai_turn();};
void()	tbaby_walk8		=[	$walk8,		tbaby_walk9	] {ai_turn();};
void()	tbaby_walk9		=[	$walk9,		tbaby_walk10	] {ai_turn();};
void()	tbaby_walk10	=[	$walk10,	tbaby_walk11	] {ai_turn();};
void()	tbaby_walk11	=[	$walk11,	tbaby_walk12	] {ai_walk(2);};
void()	tbaby_walk12	=[	$walk12,	tbaby_walk13	] {ai_walk(2);};
void()	tbaby_walk13	=[	$walk13,	tbaby_walk14	] {ai_walk(2);};
void()	tbaby_walk14	=[	$walk14,	tbaby_walk15	] {ai_walk(2);};
void()	tbaby_walk15	=[	$walk15,	tbaby_walk16	] {ai_walk(2);};
void()	tbaby_walk16	=[	$walk16,	tbaby_walk17	] {ai_walk(2);};
void()	tbaby_walk17	=[	$walk17,	tbaby_walk18	] {ai_walk(2);};
void()	tbaby_walk18	=[	$walk18,	tbaby_walk19	] {ai_walk(2);};
void()	tbaby_walk19	=[	$walk19,	tbaby_walk20	] {ai_walk(2);};
void()	tbaby_walk20	=[	$walk20,	tbaby_walk21	] {ai_walk(2);};
void()	tbaby_walk21	=[	$walk21,	tbaby_walk22	] {ai_walk(2);};
void()	tbaby_walk22	=[	$walk22,	tbaby_walk23	] {ai_walk(2);};
void()	tbaby_walk23	=[	$walk23,	tbaby_walk24	] {ai_walk(2);};
void()	tbaby_walk24	=[	$walk24,	tbaby_walk25	] {ai_walk(2);};
void()	tbaby_walk25	=[	$walk25,	tbaby_walk1	] {ai_walk(2);};

void()	tbaby_run1	=[	$run1,		tbaby_run2	] {ai_face();};
void()	tbaby_run2	=[	$run2,		tbaby_run3	] {ai_face();};
void()	tbaby_run3	=[	$run3,		tbaby_run4	] {ai_face();};
void()	tbaby_run4	=[	$run4,		tbaby_run5	] {ai_face();};
void()	tbaby_run5	=[	$run5,		tbaby_run6	] {ai_face();};
void()	tbaby_run6	=[	$run6,		tbaby_run7	] {ai_face();};
void()	tbaby_run7	=[	$run7,		tbaby_run8	] {ai_face();};
void()	tbaby_run8	=[	$run8,		tbaby_run9	] {ai_face();};
void()	tbaby_run9	=[	$run9,		tbaby_run10	] {ai_face();};
void()	tbaby_run10	=[	$run10,		tbaby_run11	] {ai_face();};
void()	tbaby_run11	=[	$run11,		tbaby_run12	] {ai_run(2);};
void()	tbaby_run12	=[	$run12,		tbaby_run13	] {ai_run(2);};
void()	tbaby_run13	=[	$run13,		tbaby_run14	] {ai_run(2);};
void()	tbaby_run14	=[	$run14,		tbaby_run15	] {ai_run(2);};
void()	tbaby_run15	=[	$run15,		tbaby_run16	] {ai_run(2);};
void()	tbaby_run16	=[	$run16,		tbaby_run17	] {ai_run(2);};
void()	tbaby_run17	=[	$run17,		tbaby_run18	] {ai_run(2);};
void()	tbaby_run18	=[	$run18,		tbaby_run19	] {ai_run(2);};
void()	tbaby_run19	=[	$run19,		tbaby_run20	] {ai_run(2);};
void()	tbaby_run20	=[	$run20,		tbaby_run21	] {ai_run(2);};
void()	tbaby_run21	=[	$run21,		tbaby_run22	] {ai_run(2);};
void()	tbaby_run22	=[	$run22,		tbaby_run23	] {ai_run(2);};
void()	tbaby_run23	=[	$run23,		tbaby_run24	] {ai_run(2);};
void()	tbaby_run24	=[	$run24,		tbaby_run25	] {ai_run(2);};
void()	tbaby_run25	=[	$run25,		tbaby_run1	] {ai_run(2);};

//============================================================================

void()	TarGibTouch =
{
	local float TarGibDamage;
	
	if (other.classname == "monster_tarbaby")
		return;		// don't touch owner or family
	
	TarGibDamage = 5 + 5*random();
	
	//splat sound... sometimes
	if (random() > 0.75)
		sound (self, CHAN_WEAPON, "blob/hit1.wav", 1, ATTN_NORM);
	
	if (other.takedamage == DAMAGE_AIM)
	{
		T_Damage (other, self, self.owner, TarGibDamage);
		self.nextthink = time;
		return;
	}
	
	//if its stopped then remove it
	if (self.velocity == '0 0 0')
		self.nextthink = time;
};

void() TarSpitAttack =	//fire multiple gibs depending on size
{
	local float MultiShot;
	
	if (self.spawnflags & ANCIENT)
		MultiShot = random() * 5 + 3;
	else if (self.spawnflags & PARENT)
		MultiShot = random() * 4 + 2;
	else //assume child, babies never spit
		MultiShot = random() * 3 + 1;
		
	while (MultiShot > 0)	
	{					
		TarSpitGib();	
		MultiShot = MultiShot - 1;	
	}		//end vomit attack
	
	self.attack_finished = time + 2;
};

void() TarSpitGib =
{
	local	entity missile, mpuff;
	
	local vector distancedelta; 
	local vector nozdistancedelta; 
	local vector move;
	local vector shotoffset;
	local float	fly;
	
	if (self.spawnflags & ANCIENT)
		shotoffset = '0 0 16';
	else if (self.spawnflags & PARENT)
		shotoffset = '0 0 14';
	else if (self.spawnflags & CHILD)
		shotoffset = '0 0 12';
	else
		shotoffset = '0 0 8';
	
	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;

	makevectors (self.angles);

	missile.velocity = normalize(self.enemy.origin - self.origin+ shotoffset + RandomOffset(80));
	missile.velocity = missile.velocity * 700;
	
	missile.avelocity_x = random()*600;
	missile.avelocity_y = random()*600;
	missile.avelocity_z = random()*600;
	
	distancedelta = self.enemy.origin - self.origin + shotoffset + RandomOffset(90); //work out distance vector, and give it a bit of random
	nozdistancedelta = distancedelta;  //copy to no height distance vector 
	
	nozdistancedelta_z = 0;  //remove height 
	
	missile.velocity_z = missile.velocity_z + vlen(nozdistancedelta)*0.70; //add extra height for extra distance
	
	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = TarGibTouch;
	
// set missile duration
	missile.nextthink = time + 2 + random();
	missile.think = SUB_Remove;

	setmodel (missile, "progs/gib_tarbaby.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	
	//offset start point so it comes from the 'mouth', this makes it a bit more inaccurate, but hey, that's why they bounce
	setorigin (missile, self.origin + shotoffset);
};

void()	tbaby_jump1;

void()	Tar_JumpTouch =
{
	local	float	ldmg, hdmg;

	ai_face();
	
	self.takedamage = DAMAGE_AIM;		//make it damagable, this is for newly spawned spawn
	
	if (other.classname == "monster_tarbaby")
		return;
	
	if (other.takedamage && other.classname != self.classname)
	{
		if ( vlen(self.velocity) > 350 )
		{
			//fatter family members of the family do more damage
			if (self.spawnflags & ANCIENT)
				hdmg = 40;
			else if (self.spawnflags & PARENT)
				hdmg = 30;
			else if (self.spawnflags & CHILD)
				hdmg = 20;
			else					//BABY
				hdmg = 10;
		
			ldmg = hdmg + 10*random();
			
			T_Damage (other, self, self, ldmg);
			sound (self, CHAN_WEAPON, "blob/hit1.wav", 1, ATTN_NORM);
		}
	}
	else
	{
		if (framecount == self.t_length + 1)		//is it stuck?
		{
			self.think = tbaby_run1;
			droptofloor();
		}	
		
		if (checkbottom(self))
			sound (self, CHAN_WEAPON, "blob/land1.wav", 1, ATTN_NORM);
	}

	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
			//dprint ("popjump\n");
			self.touch = SUB_Null;
			self.think = tbaby_run1;
			self.movetype = MOVETYPE_STEP;
			self.nextthink = time + 0.1;

//			self.velocity_x = (random() - 0.5) * 600;
//			self.velocity_y = (random() - 0.5) * 600;
//			self.velocity_z = 200;
//			self.flags = self.flags - FL_ONGROUND;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	
	//Tarbaby's jump more on higher skills, but even then not constantly as in id1
	if (random() > skill / 5)
		self.think =  tbaby_run1; 
	else
		self.think =  tbaby_jump1;	
		
	self.nextthink = time + 0.1;
};

void()	tbaby_jump5;

void()	tbaby_fly1		=[	$fly1,	tbaby_fly2	] {};
void()	tbaby_fly2		=[	$fly2,	tbaby_fly3	] {};
void()	tbaby_fly3		=[	$fly3,	tbaby_fly4	] {};
void()	tbaby_fly4		=[	$fly4,	tbaby_fly1	] {
self.cnt = self.cnt + 1;
if (self.cnt == 2)
	{
		//dprint ("spawn hop\n");
		//tbaby_jump5 ();
		droptofloor();
		tbaby_run1();
	}
};

void()	tbaby_spit1		=[	$run1,	tbaby_spit2		] {ai_face(); sound (self, CHAN_WEAPON, "blob/shoot1.wav", 1, ATTN_NORM);};
void()	tbaby_spit2		=[	$run2,	tbaby_spit3		] {ai_face();};
void()	tbaby_spit3		=[	$jump1,	tbaby_spit4		] {ai_face();};
void()	tbaby_spit4		=[	$jump2,	tbaby_spit5		] {ai_face();};
void()	tbaby_spit5		=[	$jump3,	tbaby_spit6		] {ai_face(); TarSpitAttack();};
void()	tbaby_spit6		=[	$jump2,	tbaby_spit7		] {ai_face();};
void()	tbaby_spit7		=[	$jump1,	tbaby_run1		] {ai_face();};


void()	tbaby_jump1		=[	$jump1,	tbaby_jump2		] {ai_face();};
void()	tbaby_jump2		=[	$jump2,	tbaby_jump3		] {ai_face();};
void()	tbaby_jump3		=[	$jump3,	tbaby_jump4		] {ai_face();};
void()	tbaby_jump4		=[	$jump4,	tbaby_jump5		] {ai_face();};

void()	tbaby_die1;

void()	tbaby_jump5		=[	$jump5,	tbaby_jump6		]
{
	if (self.health <= 0)
	{
		dprint ("tbaby_jump5: dead\n");
		self.touch = SUB_Null;
		self.think = tbaby_die1;
		return;
	}

	self.movetype = MOVETYPE_BOUNCE;
	self.touch = Tar_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	
	//jump distance is slightly lower for the heavier members of the family
	if (self.spawnflags & ANCIENT)
	{
		self.velocity_z = self.velocity_z + random()*135;
		self.velocity = v_forward * 525 + '0 0 200';
	}
	else if (self.spawnflags & PARENT)
	{
		self.velocity_z = self.velocity_z + random()*140;
		self.velocity = v_forward * 550 + '0 0 200';
	}
	else if (self.spawnflags & CHILD)
	{
		self.velocity_z = self.velocity_z + random()*145;
		self.velocity = v_forward * 575 + '0 0 200';
	}
	else
	{
		self.velocity_z = self.velocity_z + random()*150;
		self.velocity = v_forward * 600 + '0 0 200';
	}
	
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
		
	self.cnt = 0;
};
void()	tbaby_jump6	=[	$jump6,tbaby_fly1	] {};

//=============================================================================

//ijed This is adapted from the RMQ magic summoning code, originally written by Gb

void () tarbaby_split =
{
	local vector tspot, tspot2;
	
	makevectors (self.angles);	
	
	tspot = self.origin + v_right * 36 ;
	tspot2 = self.origin+ v_right * -36 ;

	//ok, create them (if you can)
	if (Checkspot(tspot))
		SpawnMonster (self.angles, tspot, monster_tarbaby, "monster_tarbaby");
	
	if (Checkspot(tspot2))
		SpawnMonster (self.angles, tspot2, monster_tarbaby, "monster_tarbaby");
};

void() TarCheckAttack =
{
	if ((self.spawnflags & ANCIENT)	|| (self.spawnflags & PARENT))
	{
		if (random() > 0.5)
			tbaby_spit1();	//do new spit attack
		else
			tbaby_jump1();	//do oldschool jump attack
	}
	else if (self.spawnflags & CHILD)
	{
		if (random() > 0.25)
			tbaby_spit1();	//do new spit attack
		else
			tbaby_jump1();	//do oldschool jump attack
	}
	else	
		tbaby_jump1();	//do oldschool jump attack
};

//=============================================================================

void()	tbaby_die1	=[	$exp,		tbaby_die2	] {
self.takedamage = DAMAGE_NO;
};
void()	tbaby_die2	=[	$exp,		tbaby_run1	]
{

	sound (self, CHAN_VOICE, "blob/death1.wav", 1, ATTN_NORM);
	
	if (self.spawnflags & ANCIENT) //|| (self.spawnflags & PARENT) || (self.spawnflags & CHILD))
	{
		tarbaby_split();
		M_FireGibs("progs/gib_tarbaby.mdl",24);
	}
	else if (self.spawnflags & PARENT)
	{
		tarbaby_split();
		M_FireGibs("progs/gib_tarbaby.mdl",12);	
	}
	else if (self.spawnflags & CHILD)
	{
		tarbaby_split();
		M_FireGibs("progs/gib_tarbaby.mdl",6);	
	}
	
	if ((self.spawnflags != ANCIENT) || (self.spawnflags != PARENT) || (self.spawnflags != CHILD))	//only baby's cause radial damage on death
		T_RadiusDamage (self, self, 120, world);

	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TAREXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

//=============================================================================

void() tarbaby_cache =
{
	//precache the whole family, if they exist or will do
	
	precache_model2 ("progs/tarbaby.mdl");
	precache_model2 ("progs/gib_tarbaby.mdl");
	
	if (self.spawnflags & CHILD)
	{
		precache_model2 ("progs/tarchild.mdl");
	}	
	else if (self.spawnflags & PARENT)
	{
		precache_model2 ("progs/tarchild.mdl");
		precache_model2 ("progs/tarparent.mdl");
	}
	else if (self.spawnflags & ANCIENT)
	{
		precache_model2 ("progs/tarchild.mdl");
		precache_model2 ("progs/tarparent.mdl");
		precache_model2 ("progs/tarancient.mdl");
	}

	//always need the sounds FIXME add 'heavy' tarfamily sounds
	precache_sound2 ("blob/death1.wav");
	precache_sound2 ("blob/hit1.wav");
	precache_sound2 ("blob/land1.wav");
	precache_sound2 ("blob/sight1.wav");
	precache_sound2 ("blob/shoot1.wav");
	precache_sound2 ("zombie/z_miss.wav");
};

/*QUAKED monster_tarbaby (1 0 0) (-16 -16 -24) (16 16 24) Ambush
*/
void() monster_tarbaby =
{
	self.bloodtype = 2;	//purple

	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	if (!self.spawned)		//this avoids a crash
		tarbaby_cache();
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	
	//which member of the family is it?
	if (self.spawnflags & ANCIENT)
	{
		setmodel (self, "progs/tarancient.mdl");
		self.health = 240;
		setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	}
	else if (self.spawnflags & PARENT)
	{
		setmodel (self, "progs/tarparent.mdl");
		self.health = 120;
		setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	}
	else if (self.spawnflags & CHILD)
	{
		setmodel (self, "progs/tarchild.mdl");
		self.health = 60;
		setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	}
	else
	{
		setmodel (self, "progs/tarbaby.mdl");
		self.health = 30;
		setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	}
	
	//newly spawned? 
	if (self.spawned)
	{
		
		self.angles_y = random()*360;							//face random direction
		
		self.movetype = MOVETYPE_BOUNCE;						//throw it from the origin
		
		self.velocity_z = 300;	//always pop up
		
		if (self.ammo_shells == 1)	//and sideways if coming from another tar creature
		{
			self.velocity_x = -400 + (random() * 800);
			self.velocity_y = -400 + (random() * 800);
		}
		
		self.spawnflags = self.spawnflags + SPAWN_ANGRY;		//make it angry
		self.takedamage = DAMAGE_NO;							//make it invincible
		ai_face();												//face player
		self.touch = SUB_Null;

		total_monsters = total_monsters + 1;
		
		WriteByte (MSG_BROADCAST,SVC_UPDATESTAT);
		WriteByte (MSG_BROADCAST,STAT_TOTALMONSTERS);
		WriteLong (MSG_BROADCAST,total_monsters);

		
		/*WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);		//SPLAT FX
		WriteByte (MSG_BROADCAST, TE_TAREXPLOSION);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);*/
	}
	
	self.th_stand = tbaby_stand1;
	self.th_walk = tbaby_walk1;
	self.th_run = tbaby_run1;
	self.th_missile = TarCheckAttack; //tbaby_jump1;
	self.th_melee = tbaby_jump1;
	self.th_die = tbaby_die1;
		
	walkmonster_start ();
};