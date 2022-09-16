/*
==============================================================================

Mr Big

Converted from LowPoly HalfLife2 model - madfox 30juni2012

Modified by ijed for Telefragged mod

==============================================================================
*/

$cd id1/models/mr_big
$origin 0 0 24
$base base
$skin badass3

$frame	skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9 stand10 stand11 stand12

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10 walk11 walk12 walk13 walk14 

$frame watk1 watk2 watk3 watk4 watk5 watk6 watk7 watk8 watk9 watk10 watk11 watk12 watk13 watk14 watk15 watk16 watk17 watk18

$frame run1 run2 run3 run4 run5 run6 run7 run8 

$frame rshot1 rshot2 rshot3 rshot4 rshot5 rshot6 rshot7 rshot8

$frame pain1 pain2 pain3 pain4 pain5 pain6 pain7

$frame paina1 paina2 paina3 paina4

$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9 painb10 painb11 

$frame atk1 atk2 atk3 atk4 atk5 atk6 atk7 atk8 atk9 atk10 atk11 atk12 atk13 atk14 atk15 atk16 atk17 

$frame atka1 atka2 atka3 atka4 atka5 atka6 atka7 atka8 atka9 atka10 atka11 atka12 atka13 atka14 atka15 atka16 

$frame die1 die2 die3 die4 die5 die6 die7 die8 die9 die10 die11 die12 die13 die14 die15 

$frame diet1 diet2 diet3 diet4 diet5 diet6 diet7 diet8 diet9 diet10 diet11 diet12 diet13 diet14 diet15

$frame rjmp1 rjmp2 rjmp3 rjmp4 rjmp5 rjmp6 rjmp7 rjmp8 rjmp9 rjmp10 rjmp11 rjmp12 rjmp13 rjmp14 rjmp15 rjmp16 rjmp17 rjmp18 rjmp19

//==========================================================

void()	Big_JumpTouch;
void()	mr_big_idle_sound;
void()	mr_big_pain_sound;
void()	mr_big_check_refire;
void()	mr_big_throw_dog;
void()	monster_dog;	//Fix for summoning 

//==========================================================

void() big_bullet_touch =
{
	local vector org;
	
	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	sound (self, CHAN_VOICE, "mr_big/hit.wav", 1, ATTN_NORM);
	
	org = self.origin - 8*normalize(self.velocity);

	if (other.health)
	{
		if ((other.classname == "monster_zombie") || (other.classname == "monster_dog"))
			T_Damage (other, self, self.owner, 70);	//Instagib zombies and dogs
		else
			T_Damage (other, self, self.owner, 5);
	}
		
	T_RadiusDamage (self, self, 15, world);		//Additional radial damage 
	
	become_big_bullet_explosion();	//ball explosion effect
};

void(vector org, vector vec) launch_big_bullet =
{
	local float shotspeed;
	
	shotspeed = ((skill * 100) + 600);
	
	vec = normalize(vec);
	
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

	setmodel (newmis, "progs/big_bullet.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

	setorigin (newmis, org);

	newmis.velocity = vec * shotspeed;
	
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 2;
	newmis.think = SUB_Remove;
	newmis.touch = big_bullet_touch;
};

void(float sustained_fire) mr_big_fire =
{
	local vector org, vec;
	local float burstfire;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors (self.angles);
	
	//shots scatter more the longer he's firing, making him more likely to get lucky and wing a dodging enemy
	burstfire = sustained_fire * 10;	
	
	if (burstfire > 40)	//cap the shot dipsersion at maximum 40
		burstfire = 40;
	
	org = self.origin + v_forward * 30 + v_right * 7.5 + '0 0 20';
	
	vec = self.enemy.origin - self.origin + RandomOffset(burstfire);	//do final dispersion calculations
	
	sound (self, CHAN_WEAPON, "mr_big/fire.wav", 1, ATTN_STATIC);
	
	launch_big_bullet(org, vec);
};

//==========================================================
void()	mrbig_stand1	=[	$stand1,	mrbig_stand2	]	{ai_stand(); mr_big_idle_sound();};
void()	mrbig_stand2	=[	$stand2,	mrbig_stand3	]	{ai_stand();};
void()	mrbig_stand3	=[	$stand3,	mrbig_stand4	]	{ai_stand();};
void()	mrbig_stand4	=[	$stand4,	mrbig_stand5	]	{ai_stand();};
void()	mrbig_stand5	=[	$stand5,	mrbig_stand6	]	{ai_stand();};
void()	mrbig_stand6	=[	$stand6,	mrbig_stand7	]	{ai_stand();};
void()	mrbig_stand7	=[	$stand7,	mrbig_stand8	]	{ai_stand();};
void()	mrbig_stand8	=[	$stand8,	mrbig_stand9	]	{ai_stand();};
void()	mrbig_stand9	=[	$stand9,	mrbig_stand10	]	{ai_stand();};
void()	mrbig_stand10	=[	$stand10,	mrbig_stand11	]	{ai_stand();};
void()	mrbig_stand11	=[	$stand11,	mrbig_stand1	]	{ai_stand();};

void()	mrbig_walk1		=[	$walk1,		mrbig_walk2		] {ai_walk(3); mr_big_idle_sound();};
void()	mrbig_walk2		=[	$walk2,		mrbig_walk3		] {ai_walk(4);};
void()	mrbig_walk3		=[	$walk3,		mrbig_walk4		] {ai_walk(5);};
void()	mrbig_walk4		=[	$walk4,		mrbig_walk5		] {ai_walk(6);};
void()	mrbig_walk5		=[	$walk5,		mrbig_walk6		] {ai_walk(5);};
void()	mrbig_walk6		=[	$walk6,		mrbig_walk7		] {ai_walk(4);};
void()	mrbig_walk7		=[	$walk7,		mrbig_walk8		] {ai_walk(3);};
void()	mrbig_walk8		=[	$walk8,		mrbig_walk9		] {ai_walk(3);};
void()	mrbig_walk9		=[	$walk9,		mrbig_walk10	] {ai_walk(4);};
void()	mrbig_walk10	=[	$walk10,	mrbig_walk11	] {ai_walk(5);};
void()	mrbig_walk11	=[	$walk11, 	mrbig_walk12	] {ai_walk(6);};
void()	mrbig_walk12	=[	$walk12,	mrbig_walk13	] {ai_walk(5);};
void()	mrbig_walk13	=[	$walk13,	mrbig_walk14	] {ai_walk(4);};
void()	mrbig_walk14	=[	$walk14,	mrbig_walk1		] {ai_walk(3);};
 
void()	mrbig_run1	=[	$run1,	mrbig_run2	] {ai_run(9);	mr_big_idle_sound();};
void()	mrbig_run2	=[	$run2,	mrbig_run3	] {ai_run(12);};
void()	mrbig_run3	=[	$run3,	mrbig_run4	] {ai_run(9);};
void()	mrbig_run4	=[	$run4,	mrbig_run5	] {ai_run(5);};
void()	mrbig_run5	=[	$run5,	mrbig_run6	] {ai_run(9);};
void()	mrbig_run6	=[	$run6,	mrbig_run7	] {ai_run(12);};
void()	mrbig_run7	=[	$run7,	mrbig_run8	] {ai_run(9);};
void()	mrbig_run8	=[	$run8,	mrbig_run1	] {ai_run(6);};

void()	mrbig_rjmp1	=[	$rjmp1,		mrbig_rjmp2	]	{ai_face();	mr_big_idle_sound();};
void()	mrbig_rjmp2	=[	$rjmp2,		mrbig_rjmp3	]	{ai_face();};
void()	mrbig_rjmp3	=[	$rjmp3,		mrbig_rjmp4	]	{ai_face();};
void()	mrbig_rjmp4	=[	$rjmp4,		mrbig_rjmp5	]	{ai_face();};
void()	mrbig_rjmp5	=[	$rjmp5,		mrbig_rjmp6	]
{
ai_face();

	self.touch = Big_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 200 + '0 0 200';
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
    
};
void()	mrbig_rjmp6		=[	$rjmp6,		mrbig_rjmp7		]	{ai_face();};
void()	mrbig_rjmp7		=[	$rjmp7,		mrbig_rjmp8		]	{ai_face();};
void()	mrbig_rjmp8		=[	$rjmp8,		mrbig_rjmp9		]	{ai_face();};
void()	mrbig_rjmp9		=[	$rjmp9,		mrbig_rjmp10	]	{ai_face();};
void()	mrbig_rjmp10	=[	$rjmp10,	mrbig_rjmp11	]	{ai_face();};
void()	mrbig_rjmp11	=[	$rjmp11,	mrbig_rjmp12	]	{ai_face();};
void()	mrbig_rjmp12	=[	$rjmp12,	mrbig_rjmp13	]	{ai_face();};
void()	mrbig_rjmp13	=[	$rjmp13,	mrbig_rjmp14	]	{ai_face();};
void()	mrbig_rjmp14	=[	$rjmp14,	mrbig_rjmp15	]	{ai_face();};
void()	mrbig_rjmp15	=[	$rjmp15,	mrbig_rjmp16	]	{ai_face();};
void()	mrbig_rjmp16	=[	$rjmp16,	mrbig_rjmp17	]	{ai_face();};
void()	mrbig_rjmp17	=[	$rjmp17,	mrbig_rjmp18	]	{ai_face();};
void()	mrbig_rjmp18	=[	$rjmp18,	mrbig_run1		]	{ai_face();};

void()	mrbig_atka1		=[	$atka1,		mrbig_atka2		]	{ai_face();};
void()	mrbig_atka2		=[	$atka2,		mrbig_atka3		]	{ai_face();};
void()	mrbig_atka3		=[	$atka3,		mrbig_atka4		]	{ai_face();};
void()	mrbig_atka4		=[	$atka4,		mrbig_atka5		]	{ai_face();};
void()	mrbig_atka5		=[	$atka5,		mrbig_atka6		]	{ai_face();	mr_big_fire(self.sustained_fire);};
void()	mrbig_atka6		=[	$atka6,		mrbig_atka7		]	{ai_face(); mr_big_fire(self.sustained_fire);};
void()	mrbig_atka7		=[	$atka5,		mrbig_atka8		]	{ai_face();	mr_big_fire(self.sustained_fire);};
void()	mrbig_atka8		=[	$atka6,		mrbig_atka9		]	{ai_face(); mr_big_fire(self.sustained_fire); mr_big_check_refire();};
void()	mrbig_atka9		=[	$atka4,		mrbig_atka10	]	{ai_face(); self.sustained_fire = 0;};	//stopped firing; reset sustained fire value
void()	mrbig_atka10	=[	$atka3,		mrbig_atka11	]	{ai_face();};
void()	mrbig_atka11	=[	$atka2,		mrbig_atka12	]	{ai_face();};
void()	mrbig_atka12	=[	$atka1,		mrbig_run1		]	{ai_face();};

//throw a dog
void()	mrbig_sdog1	=[	$pain2,	mrbig_sdog2	] {ai_face();};
void()	mrbig_sdog2	=[	$pain3,	mrbig_sdog3	] {ai_face();};
void()	mrbig_sdog3	=[	$pain4,	mrbig_sdog4	] {ai_face(); mr_big_throw_dog(); self.attack_finished = time + 2;};	//don't let him attack for a bit
void()	mrbig_sdog4	=[	$pain5,	mrbig_sdog5	] {ai_face();};
void()	mrbig_sdog5	=[	$pain6,	mrbig_sdog6	] {ai_face();};
void()	mrbig_sdog6	=[	$pain7,	mrbig_run1	] {ai_face();};

void()	mrbig_pain1	=[	$pain1,	mrbig_pain2	] {mr_big_pain_sound();};
void()	mrbig_pain2	=[	$pain2,	mrbig_pain3	] {};
void()	mrbig_pain3	=[	$pain3,	mrbig_pain4	] {};
void()	mrbig_pain4	=[	$pain4,	mrbig_pain5	] {};
void()	mrbig_pain5	=[	$pain5,	mrbig_pain6	] {};
void()	mrbig_pain6	=[	$pain6,	mrbig_pain7	] {};
void()	mrbig_pain7	=[	$pain7,	mrbig_run1	] {};

void()	mrbig_paina1	=[	$paina1,	mrbig_paina2	] {mr_big_pain_sound();};
void()	mrbig_paina2	=[	$paina2,	mrbig_paina3	] {};
void()	mrbig_paina3	=[	$paina3,	mrbig_paina4	] {};
void()	mrbig_paina4	=[	$paina4,	mrbig_run1		] {};

void()	mrbig_painb1	=[	$painb1,	mrbig_painb2	] {mr_big_pain_sound();};
void()	mrbig_painb2	=[	$painb2,	mrbig_painb3	] {};
void()	mrbig_painb3	=[	$painb3,	mrbig_painb4	] {};
void()	mrbig_painb4	=[	$painb4,	mrbig_painb5	] {};
void()	mrbig_painb5	=[	$painb5,	mrbig_painb6	] {};
void()	mrbig_painb6	=[	$painb6,	mrbig_painb7	] {};
void()	mrbig_painb7	=[	$painb7,	mrbig_painb8	] {};
void()	mrbig_painb8	=[	$painb8,	mrbig_painb9	] {};
void()	mrbig_painb9	=[	$painb9,	mrbig_painb10	] {};
void()	mrbig_painb10	=[	$painb10,	mrbig_painb11	] {};
void()	mrbig_painb11	=[	$painb11,	mrbig_run1		] {};

void()	mr_big_check_refire =
{
	if ((visible (self.enemy)) && (self.enemy.health > 0))	//can I see my enemy?  Are they alive?
	{
		//increment sustained fire to make him less accurate because he keeps shooting
		self.sustained_fire = self.sustained_fire + 1;	

		mrbig_atka5();	//loop back to previous frame, continue firing
	}
	else if (self.enemy.health < 0)	//they're dead, so laugh at their pitifil remains
		sound (self, CHAN_VOICE, "mr_big/idle1.wav", 1,  ATTN_NORM);
}; 

void(entity attacker, float damage)	mr_big_choose_pain =
{
	if (random()*20 > damage)
		return;	// didn't flinch
		
	if (self.pain_finished > time)
		return;
		
	local float r;
	r = random();
	
	if (r < 0.25)
	{
		mrbig_pain1 ();
		self.pain_finished = time + 1;
	}
	else if (r < 0.5)
	{
		mrbig_paina1 ();
		self.pain_finished = time + 1;
	}
    else if (r < 0.85)
	{
		mrbig_painb1 ();
		self.pain_finished = time + 1;
	}
};

void()	mrbig_die1	=[	$die1,	mrbig_die2	]	{};
void()	mrbig_die2	=[	$die2,	mrbig_die3	]	{};
void()	mrbig_die3	=[	$die3,	mrbig_die4	]	{self.solid = SOLID_NOT;};
void()	mrbig_die4	=[	$die4,	mrbig_die5	]	{};
void()	mrbig_die5	=[	$die5,	mrbig_die6	]	{};
void()	mrbig_die6	=[	$die6,	mrbig_die7	]	{};
void()	mrbig_die7	=[	$die7,	mrbig_die8	]	{};
void()	mrbig_die8	=[	$die8,	mrbig_die9	]	{};
void()	mrbig_die9	=[	$die9,	mrbig_die10	]	{};
void()	mrbig_die10	=[	$die10,	mrbig_die11	]	{};
void()	mrbig_die11	=[	$die11,	mrbig_die12	]	{};
void()	mrbig_die12	=[	$die12,	mrbig_die13	]	{};
void()	mrbig_die13	=[	$die13,	mrbig_die14	]	{};
void()	mrbig_die14	=[	$die14,	mrbig_die15	]	{};
void()	mrbig_die15	=[	$die15,	mrbig_die15	]	{};

void()	mrbig_diet1		=[	$diet1,		mrbig_diet2		]	{};
void()	mrbig_diet2		=[	$diet2,		mrbig_diet3		]	{};
void()	mrbig_diet3		=[	$diet3,		mrbig_diet4		]	{self.solid = SOLID_NOT;};
void()	mrbig_diet4		=[	$diet4,		mrbig_diet5		]	{};
void()	mrbig_diet5		=[	$diet5,		mrbig_diet6		]	{};
void()	mrbig_diet6		=[	$diet6,		mrbig_diet7		]	{};
void()	mrbig_diet7		=[	$diet7,		mrbig_diet8		]	{};
void()	mrbig_diet8		=[	$diet8,		mrbig_diet9		]	{};
void()	mrbig_diet9		=[	$diet9,		mrbig_diet10	]	{};
void()	mrbig_diet10	=[	$diet10,	mrbig_diet11	]	{};
void()	mrbig_diet11	=[	$diet11,	mrbig_diet12	]	{};
void()	mrbig_diet12	=[	$diet12,	mrbig_diet13	]	{};
void()	mrbig_diet13	=[	$diet13,	mrbig_diet14	]	{};
void()	mrbig_diet14	=[	$diet14,	mrbig_diet15	]	{};
void()	mrbig_diet15	=[	$diet15,	mrbig_diet15	]	{};

void() mr_big_die =
{
	// check for gib
	if (self.health < -50)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/gib1.mdl", self.health);	//FIXME
		ThrowGib ("progs/gib.mdl", self.health);
		ThrowGib ("progs/gib.mdl", self.health);
		ThrowGib ("progs/gib.mdl", self.health);
		return;
	}

	if (random() < 0.5)
		sound (self, CHAN_VOICE, "mr_big/death1.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "mr_big/death2.wav", 1, ATTN_NORM);

	if (random() < 0.5)
		mrbig_die1 ();
	else
		mrbig_diet1 ();
};

void() mr_big_idle_sound =
{
	if (random() < 0.2)
	{
		if (random() < 0.6)
			sound (self, CHAN_VOICE, "mr_big/idle1.wav", 1,  ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "mr_big/idle2.wav", 1,  ATTN_NORM);
	}
};

void() mr_big_pain_sound =
{
	if (random() < 0.5)
		sound (self, CHAN_VOICE, "mr_big/pain1.wav", 1,  ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "mr_big/pain2.wav", 1,  ATTN_NORM);
};

void()	Big_JumpTouch =
{
	local	float	ldmg;

	if (self.health <= 0)
		return;
		
	if (other.takedamage)
	{
		if ( vlen(self.velocity) > 400 )
		{
			ldmg = 40 + 10*random();
//			T_Damage (other, self, self, ldmg);	
		}
	}

	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{
			self.touch = SUB_Null;
			self.think = mrbig_rjmp1;
			self.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.think = mrbig_rjmp18;
	self.nextthink = time + 0.1;
};

void()	mr_big_throw_dog	=
{
	local float TotalDogs;
	
	TotalDogs	=	skill * random();	//throw some dogs, max 3 on skill 3
	
	if (TotalDogs < 1)		
		TotalDogs	=	1;		//throw at least 1 dog
	
	while (TotalDogs > 0)
	{
		SpawnMonster (self.angles, self.origin + '40 0 20', monster_dog, "monster_dog");	//uses schism.qc code
		TotalDogs = TotalDogs - 1;
	}
	
	self.total_spawned = self.total_spawned  + 1;	//increment the counter so he can't spawn infinite dogs	
};	

void()	mr_big_choose_attack =
{
	if ((self.total_spawned <= (skill * 2)) && (random() < (skill / 10)))	//don't spawn more than 0-2-4-6 and spawn probability relative to skill as well
		mrbig_sdog1();	//throw a dog
	else
		mrbig_atka1();	//blaze away
};


/*QUAKED monster_mrbig (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
	
void()	mr_big_cache =
{
	precache_model ("progs/mr_big.mdl");
	precache_model ("progs/h_mr_big.mdl");
	precache_model ("progs/big_bullet.mdl");
	precache_model ("progs/big_bullet_blast.mdl");

    precache_sound ("mr_big/fire.wav");
	precache_sound ("mr_big/hit.wav");

	precache_sound ("mr_big/sight1.wav");
	precache_sound ("mr_big/death1.wav");
	precache_sound ("mr_big/death2.wav");
	precache_sound ("mr_big/idle1.wav");
	precache_sound ("mr_big/idle2.wav");
	precache_sound ("mr_big/pain1.wav");
	precache_sound ("mr_big/pain2.wav");
	precache_sound ("mr_big/taunt1.wav");
};

void()	monster_mr_big	=
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	if (!self.spawned)
		mr_big_cache();

	dog_cache();		//carries round a bag full of dogs
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/mr_big.mdl");

	setsize (self,	VEC_HULL2_MIN,	VEC_HULL2_MAX);	
	self.health	=	500;

	self.th_stand = mrbig_stand1;
	self.th_walk = mrbig_walk1;
	self.th_run = mrbig_run1;
	//self.th_melee = mrbig_melee;
	self.th_pain = mr_big_choose_pain;
	self.th_die = mr_big_die;
    self.th_missile = mr_big_choose_attack;	

	//these floats help control his behaviour
	self.total_spawned = 0;		//summoning dogs
	self.sustained_fire = 0;	//blasting the player
	
	walkmonster_start ();
};
