/*==============================================================================

NYARCHON

==============================================================================*/

$cd /raid/quake/id1/models/nyarchon
$origin 0 0 -24
$base base
$skin skin

//==============================================================================
// Animation
//==============================================================================

$frame mesh

$frame idle1 idle2 idle3 idle4 idle5 idle6 idle7 idle8 idle9 idle10 idle11 idle12 idle13 idle14 idle15 idle16 idle17 idle18 idle19 idle20 idle21

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10 walk11 walk12 walk13 walk14 walk15 walk16 walk17 walk18 walk19

$frame run1 run2 run3 run4 run5 run6 run7 run8 run9 run10 run11

$frame runb1 runb2 runb3 runb4 runb5 runb6 runb7 runb8 runb9 runb10 runb11 runb12 runb13

//frame rangeda11 is duplicate but I'm lazy
$frame rangeda1 rangeda2 rangeda3 rangeda4 rangeda5 rangeda6 rangeda7 rangeda8 rangeda9 rangeda10 rangeda11 rangeda12 rangeda13 rangeda14 rangeda15 rangeda16 rangeda17 rangeda18 rangeda19 rangeda20

$frame rangedb1 rangedb2 rangedb3 rangedb4 rangedb5 rangedb6 rangedb7 rangedb8 rangedb9 rangedb10 rangedb11 rangedb12 rangedb13 rangedb14 rangedb15 rangedb16 rangedb17 rangedb18 rangedb19 rangedb20 rangedb21 rangedb22 rangedb23 rangedb24 rangedb25

$frame rangedc1 rangedc2 rangedc3 rangedc4 rangedc5 rangedc6 rangedc7 rangedc8 rangedc9 rangedc10 rangedc11 rangedc12 rangedc13 rangedc14 rangedc15 rangedc16 rangedc17 rangedc18 rangedc19 rangedc20 rangedc21 rangedc22 rangedc23 rangedc24 rangedc25 rangedc26 rangedc27 rangedc28 rangedc29 rangedc30

$frame spellb1 spellb2 spellb3 spellb4 spellb5 spellb6 spellb7 spellb8 spellb9 spellb10 spellb11 spellb12 spellb13 spellb14 spellb15 spellb16 spellb17 spellb18 spellb19 spellb20 spellb21 spellb22 spellb23 spellb24 spellb25 spellb26 spellb27 spellb28 spellb29 spellb30 spellb31 spellb32 spellb33

//==============================================================================
// Prototypes
//==============================================================================

void() nyarchon_Melee;

//==============================================================================
// Definitions
//==============================================================================

//Stand
void() nyarchon_stand1		=[	$idle1,		nyarchon_stand2 ]	{ai_stand();};
void() nyarchon_stand2		=[	$idle2,		nyarchon_stand3 ]	{ai_stand();};
void() nyarchon_stand3		=[	$idle3,		nyarchon_stand4 ]	{ai_stand();};
void() nyarchon_stand4		=[	$idle4,		nyarchon_stand5 ]	{ai_stand();};
void() nyarchon_stand5		=[	$idle5,		nyarchon_stand6 ]	{ai_stand();};
void() nyarchon_stand6		=[	$idle6,		nyarchon_stand7 ]	{ai_stand();};
void() nyarchon_stand7		=[	$idle7,		nyarchon_stand8 ]	{ai_stand();};
void() nyarchon_stand8		=[	$idle8,		nyarchon_stand9 ]	{ai_stand();};
void() nyarchon_stand9		=[	$idle9,		nyarchon_stand10 ]	{ai_stand();};
void() nyarchon_stand10		=[	$idle10,	nyarchon_stand11 ]	{ai_stand();};
void() nyarchon_stand11		=[	$idle11,	nyarchon_stand12 ]	{ai_stand();};
void() nyarchon_stand12		=[	$idle12,	nyarchon_stand13 ]	{ai_stand();};
void() nyarchon_stand13		=[	$idle13,	nyarchon_stand14 ]	{ai_stand();};
void() nyarchon_stand14		=[	$idle14,	nyarchon_stand15 ]	{ai_stand();};
void() nyarchon_stand15		=[	$idle15,	nyarchon_stand16 ]	{ai_stand();};
void() nyarchon_stand16		=[	$idle16,	nyarchon_stand17 ]	{ai_stand();};
void() nyarchon_stand17		=[	$idle17,	nyarchon_stand18 ]	{ai_stand();};
void() nyarchon_stand18		=[	$idle18,	nyarchon_stand19 ]	{ai_stand();};
void() nyarchon_stand19		=[	$idle19,	nyarchon_stand20 ]	{ai_stand();};
void() nyarchon_stand20		=[	$idle20,	nyarchon_stand21 ]	{ai_stand();};
void() nyarchon_stand21		=[	$idle21,	nyarchon_stand1 ]	{ai_stand();};

//Walk
void() nyarchon_walk1	=[	$walk1,  nyarchon_walk2	]	{ai_walk(8);};  //flat values are shit, fix them
void() nyarchon_walk2	=[	$walk2,  nyarchon_walk3	]	{ai_walk(8);};
void() nyarchon_walk3	=[	$walk3,  nyarchon_walk4	]	{ai_walk(8);};
void() nyarchon_walk4	=[	$walk4,  nyarchon_walk5	]	{ai_walk(8);};
void() nyarchon_walk5	=[	$walk5,  nyarchon_walk12	]	{ai_walk(8);};
void() nyarchon_walk6	=[	$walk6,  nyarchon_walk7	]	{ai_walk(8);};
void() nyarchon_walk7	=[	$walk7,  nyarchon_walk8	]	{ai_walk(8);};
void() nyarchon_walk8	=[	$walk8,  nyarchon_walk9	]	{ai_walk(8);};
void() nyarchon_walk9	=[	$walk9,  nyarchon_walk10	]	{ai_walk(8);};
void() nyarchon_walk10	=[	$walk10, nyarchon_walk11	]	{ai_walk(8);};
void() nyarchon_walk11	=[	$walk11, nyarchon_walk12	]	{ai_walk(8);};
void() nyarchon_walk12	=[	$walk12, nyarchon_walk13	]	{ai_walk(8);};
void() nyarchon_walk13	=[	$walk13, nyarchon_walk14	]	{ai_walk(8);};
void() nyarchon_walk14	=[	$walk14, nyarchon_walk15	]	{ai_walk(8);};
void() nyarchon_walk15	=[	$walk15, nyarchon_walk16	]	{ai_walk(8);};
void() nyarchon_walk16	=[	$walk16, nyarchon_walk17	]	{ai_walk(8);};
void() nyarchon_walk17	=[	$walk17, nyarchon_walk18	]	{ai_walk(8);};
void() nyarchon_walk18	=[	$walk18, nyarchon_walk19	]	{ai_walk(8);};
void() nyarchon_walk19	=[	$walk19, nyarchon_walk1	]	{ai_walk(8);};

// Run
void() nyarchon_run1	=[	$run1,	nyarchon_run2		]	{ai_run(16);};
void() nyarchon_run2	=[	$run2,	nyarchon_run3		]	{ai_run(16);};
void() nyarchon_run3	=[	$run3,	nyarchon_run4		]	{ai_run(16);};
void() nyarchon_run4	=[	$run4,	nyarchon_run5		]	{ai_run(16);};
void() nyarchon_run5	=[	$run5,	nyarchon_run6		]	{ai_run(16);};
void() nyarchon_run6	=[	$run6,	nyarchon_run7		]	{ai_run(16);};
void() nyarchon_run7	=[	$run7,	nyarchon_run8		]	{ai_run(16);};
void() nyarchon_run8	=[	$run8,	nyarchon_run9		]	{ai_run(16);};
void() nyarchon_run9	=[	$run9,	nyarchon_run10		]	{ai_run(16);};
void() nyarchon_run10	=[	$run10,	nyarchon_run11		]	{ai_run(16);};
void() nyarchon_run11	=[	$run11,	nyarchon_run1		]	{ai_run(16);};

// Injured Run
void() nyarchon_runb1	=[	$runb1,		nyarchon_runb2			]	{ai_run(8);};	
void() nyarchon_runb2	=[	$runb2,		nyarchon_runb3			]	{ai_run(8);};
void() nyarchon_runb3	=[	$runb3,		nyarchon_runb4			]	{ai_run(8);};
void() nyarchon_runb4	=[	$runb4,		nyarchon_runb5			]	{ai_run(8);};
void() nyarchon_runb5	=[	$runb5,		nyarchon_runb6			]	{ai_run(8);};
void() nyarchon_runb6	=[	$runb6,		nyarchon_runb7			]	{ai_run(8);};
void() nyarchon_runb7	=[	$runb7,		nyarchon_runb8			]	{ai_run(8);};
void() nyarchon_runb8	=[	$runb8,		nyarchon_runb9			]	{ai_run(8);};
void() nyarchon_runb9	=[	$runb9,		nyarchon_runb10		]	{ai_run(8);};
void() nyarchon_runb10	=[	$runb10,	nyarchon_runb11		]	{ai_run(8);};
void() nyarchon_runb11	=[	$runb11,	nyarchon_runb12		]	{ai_run(8);};
void() nyarchon_runb12	=[	$runb12,	nyarchon_runb13		]	{ai_run(8);};
void() nyarchon_runb13	=[	$runb13,	nyarchon_runb1			]	{ai_run(8);};

//Melee #1 Right Handed Claw Swipe
void() nyarchon_meleea1	=[	$rangeda1,	nyarchon_meleea2		]	{};
void() nyarchon_meleea2	=[	$rangeda2,	nyarchon_meleea3		]	{};
void() nyarchon_meleea3	=[	$rangeda3,	nyarchon_meleea4		]	{};
void() nyarchon_meleea4	=[	$rangeda4,	nyarchon_meleea5		]	{ai_charge(0);};
void() nyarchon_meleea5	=[	$rangeda5,	nyarchon_meleea6		]	{ai_charge(3);};
void() nyarchon_meleea6	=[	$rangeda6,	nyarchon_meleea7		]	{ai_charge(4);};
void() nyarchon_meleea7	=[	$rangeda7,	nyarchon_meleea8		]	{ai_charge(5); nyarchon_Melee();};
void() nyarchon_meleea8	=[	$rangeda8,	nyarchon_meleea9		]	{ai_charge(6);};
void() nyarchon_meleea9	=[	$rangeda9,	nyarchon_meleea10		]	{ai_charge(3);};
void() nyarchon_meleea10	=[	$rangeda10,	nyarchon_runb11		]	{ai_charge(1);};

//Melee #2 Left Handed Claw Swipe
void() nyarchon_meleeb1	=[	$rangeda12,	nyarchon_meleeb2		]	{};
void() nyarchon_meleeb2	=[	$rangeda13,	nyarchon_meleeb3		]	{};
void() nyarchon_meleeb3	=[	$rangeda14,	nyarchon_meleeb4		]	{};
void() nyarchon_meleeb4	=[	$rangeda15,	nyarchon_meleeb5		]	{ai_charge(3);};
void() nyarchon_meleeb5	=[	$rangeda16,	nyarchon_meleeb6		]	{ai_charge(4);};
void() nyarchon_meleeb6	=[	$rangeda17,	nyarchon_meleeb7		]	{ai_charge(5); nyarchon_Melee();};
void() nyarchon_meleeb7	=[	$rangeda18,	nyarchon_meleeb8		]	{ai_charge(6);};
void() nyarchon_meleeb8	=[	$rangeda19,	nyarchon_meleeb9		]	{ai_charge(3);};
void() nyarchon_meleeb9	=[	$rangeda20,	nyarchon_runb11			]	{ai_charge(1);};

//Ranged Attack #1
void() nyarchon_rangeda1	=[	$rangeda1,	nyarchon_rangeda2 ]	{ai_face();};
void() nyarchon_rangeda2	=[	$rangeda2,	nyarchon_rangeda3 ]	{ai_face();};
void() nyarchon_rangeda3	=[	$rangeda3,	nyarchon_rangeda4 ]	{ai_face();};
void() nyarchon_rangeda4	=[	$rangeda4,	nyarchon_rangeda5 ]	{ai_face();};
void() nyarchon_rangeda5	=[	$rangeda5,	nyarchon_rangeda6 ]	{ai_face();};
void() nyarchon_rangeda6	=[	$rangeda6,	nyarchon_rangeda7 ]	{ai_face();};
void() nyarchon_rangeda7	=[	$rangeda7,	nyarchon_rangeda8 ]	{ai_face(); M_FireGrenade('0 0 0');};
void() nyarchon_rangeda8	=[	$rangeda8,	nyarchon_rangeda9 ]	{ai_face();};
void() nyarchon_rangeda9	=[	$rangeda9,	nyarchon_rangeda10 ]	{ai_face();};
void() nyarchon_rangeda10	=[	$rangeda10,	nyarchon_rangeda11 ]	{ai_face();};
void() nyarchon_rangeda11	=[	$rangeda11,	nyarchon_rangeda12 ]	{ai_face();};
void() nyarchon_rangeda12	=[	$rangeda12,	nyarchon_rangeda13 ]	{ai_face();};
void() nyarchon_rangeda13	=[	$rangeda13,	nyarchon_rangeda14 ]	{ai_face();};
void() nyarchon_rangeda14	=[	$rangeda14,	nyarchon_rangeda15 ]	{ai_face();};
void() nyarchon_rangeda15	=[	$rangeda15,	nyarchon_rangeda16 ]	{ai_face();};
void() nyarchon_rangeda16	=[	$rangeda16,	nyarchon_rangeda17 ]	{ai_face();};
void() nyarchon_rangeda17	=[	$rangeda17,	nyarchon_rangeda18 ]	{ai_face(); M_FireGrenade('0 0 0');};
void() nyarchon_rangeda18	=[	$rangeda18,	nyarchon_rangeda19 ]	{ai_face();};
void() nyarchon_rangeda19	=[	$rangeda19,	nyarchon_rangeda20 ]	{ai_face();};
void() nyarchon_rangeda20	=[	$rangeda20,	nyarchon_run1		]	{ai_face();};

//Ranged Attack #2
void() nyarchon_rangedb1	=[	$rangedb1,	nyarchon_rangedb2	]	{};
void() nyarchon_rangedb2	=[	$rangedb2,	nyarchon_rangedb3	]	{}; 
void() nyarchon_rangedb3	=[	$rangedb3,	nyarchon_rangedb4	]	{};
void() nyarchon_rangedb4	=[	$rangedb4,	nyarchon_rangedb5	]	{};
void() nyarchon_rangedb5	=[	$rangedb5,	nyarchon_rangedb6 	]	{};
void() nyarchon_rangedb6	=[	$rangedb6,	nyarchon_rangedb7 	]	{};
void() nyarchon_rangedb7	=[	$rangedb7,	nyarchon_rangedb8	]	{HomingMissile(DEATHORB);};
void() nyarchon_rangedb8	=[	$rangedb8,	nyarchon_rangedb9	]	{HomingMissile(DEATHORB);};
void() nyarchon_rangedb9	=[	$rangedb9,	nyarchon_rangedb10	]	{HomingMissile(DEATHORB);};
void() nyarchon_rangedb10	=[	$rangedb10,	nyarchon_rangedb11	]	{HomingMissile(DEATHORB);};
void() nyarchon_rangedb11	=[	$rangedb11,	nyarchon_rangedb12	]	{HomingMissile(DEATHORB);};
void() nyarchon_rangedb12	=[	$rangedb12,	nyarchon_rangedb13	]	{HomingMissile(DEATHORB);};
void() nyarchon_rangedb13	=[	$rangedb13,	nyarchon_rangedb14	]	{HomingMissile(DEATHORB);};
void() nyarchon_rangedb14	=[	$rangedb14,	nyarchon_rangedb15	]	{HomingMissile(DEATHORB);};
void() nyarchon_rangedb15	=[	$rangedb15,	nyarchon_rangedb16	]	{HomingMissile(DEATHORB);};
void() nyarchon_rangedb16	=[	$rangedb16,	nyarchon_rangedb17	]	{HomingMissile(DEATHORB);};
void() nyarchon_rangedb17	=[	$rangedb17,	nyarchon_rangedb18	]	{HomingMissile(DEATHORB);};
void() nyarchon_rangedb18	=[	$rangedb18,	nyarchon_rangedb19	]	{HomingMissile(DEATHORB);};
void() nyarchon_rangedb19	=[	$rangedb19,	nyarchon_rangedb20	]	{HomingMissile(DEATHORB);};
void() nyarchon_rangedb20	=[	$rangedb20,	nyarchon_rangedb21	]	{};
void() nyarchon_rangedb21	=[	$rangedb21,	nyarchon_rangedb22	]	{};
void() nyarchon_rangedb22	=[	$rangedb22,	nyarchon_rangedb23	]	{};
void() nyarchon_rangedb23	=[	$rangedb23,	nyarchon_rangedb24	]	{};
void() nyarchon_rangedb24	=[	$rangedb24,	nyarchon_rangedb25	]	{};
void() nyarchon_rangedb25	=[	$rangedb25,	nyarchon_run1		]	{};

//Ranged3 DeathStrike 
void() nyarchon_rangedc1	=[	$rangedc1,	nyarchon_rangedc2	]	{};
void() nyarchon_rangedc2	=[	$rangedc2,	nyarchon_rangedc3	]	{}; 
void() nyarchon_rangedc3	=[	$rangedc3,	nyarchon_rangedc4	]	{};
void() nyarchon_rangedc4	=[	$rangedc4,	nyarchon_rangedc5	]	{};
void() nyarchon_rangedc5	=[	$rangedc5,	nyarchon_rangedc6	]	{};
void() nyarchon_rangedc6	=[	$rangedc6,	nyarchon_rangedc7	]	{};
void() nyarchon_rangedc7	=[	$rangedc7,	nyarchon_rangedc8 	]	{};
void() nyarchon_rangedc8	=[	$rangedc8,	nyarchon_rangedc9 	]	{};
void() nyarchon_rangedc9	=[	$rangedc9,	nyarchon_rangedc10	]	{};
void() nyarchon_rangedc10	=[	$rangedc10,	nyarchon_rangedc11	]	{};
void() nyarchon_rangedc11	=[	$rangedc11,	nyarchon_rangedc12	]	{};
void() nyarchon_rangedc12	=[	$rangedc12,	nyarchon_rangedc13	]	{};
void() nyarchon_rangedc13	=[	$rangedc13,	nyarchon_rangedc14	]	{};
void() nyarchon_rangedc14	=[	$rangedc14,	nyarchon_rangedc15	]	{};
void() nyarchon_rangedc15	=[	$rangedc15,	nyarchon_rangedc16	]	{};
void() nyarchon_rangedc16	=[	$rangedc16,	nyarchon_rangedc17	]	{};
void() nyarchon_rangedc17	=[	$rangedc17,	nyarchon_rangedc18	]	{};
void() nyarchon_rangedc18	=[	$rangedc18,	nyarchon_rangedc19	]	{};
void() nyarchon_rangedc19	=[	$rangedc19,	nyarchon_rangedc20	]	{};
void() nyarchon_rangedc20	=[	$rangedc20,	nyarchon_rangedc21	]	{};	
void() nyarchon_rangedc21	=[	$rangedc21,	nyarchon_rangedc22	]	{};
void() nyarchon_rangedc22	=[	$rangedc22,	nyarchon_rangedc23	]	{};
void() nyarchon_rangedc23	=[	$rangedc23,	nyarchon_rangedc24	]	{};
void() nyarchon_rangedc24	=[	$rangedc24,	nyarchon_rangedc25	]	{};
void() nyarchon_rangedc25	=[	$rangedc25,	nyarchon_rangedc26	]	{};	
void() nyarchon_rangedc26	=[	$rangedc26,	nyarchon_rangedc27	]	{};
void() nyarchon_rangedc27	=[	$rangedc27,	nyarchon_rangedc28	]	{};
void() nyarchon_rangedc28	=[	$rangedc28,	nyarchon_rangedc29	]	{};
void() nyarchon_rangedc29	=[	$rangedc29,	nyarchon_rangedc30	]	{};
void() nyarchon_rangedc30	=[	$rangedc30,	nyarchon_run1		]	{};

//Regeneration 
void() nyarchon_regenerate1		=[	$spellb1,	nyarchon_regenerate2	]	{};
void() nyarchon_regenerate2		=[	$spellb2,	nyarchon_regenerate3	]	{}; 
void() nyarchon_regenerate3		=[	$spellb3,	nyarchon_regenerate4	]	{};
void() nyarchon_regenerate4		=[	$spellb4,	nyarchon_regenerate5	]	{};
void() nyarchon_regenerate5		=[	$spellb5,	nyarchon_regenerate6	]	{};
void() nyarchon_regenerate6		=[	$spellb6,	nyarchon_regenerate7	]	{};
void() nyarchon_regenerate7		=[	$spellb7,	nyarchon_regenerate8 	]	{};
void() nyarchon_regenerate8		=[	$spellb8,	nyarchon_regenerate9 	]	{};
void() nyarchon_regenerate9		=[	$spellb9,	nyarchon_regenerate10	]	{};
void() nyarchon_regenerate10	=[	$spellb10,	nyarchon_regenerate11	]	{};
void() nyarchon_regenerate11	=[	$spellb11,	nyarchon_regenerate12	]	{};	
void() nyarchon_regenerate12	=[	$spellb12,	nyarchon_regenerate13	]	{};	
void() nyarchon_regenerate13	=[	$spellb13,	nyarchon_regenerate14	]	{};	
void() nyarchon_regenerate14	=[	$spellb14,	nyarchon_regenerate15	]	{};	
void() nyarchon_regenerate15	=[	$spellb15,	nyarchon_regenerate16	]	{};	
void() nyarchon_regenerate16	=[	$spellb16,	nyarchon_regenerate17	]	{};	
void() nyarchon_regenerate17	=[	$spellb17,	nyarchon_regenerate18	]	{};	
void() nyarchon_regenerate18	=[	$spellb18,	nyarchon_regenerate19	]	{};	
void() nyarchon_regenerate19	=[	$spellb19,	nyarchon_regenerate20	]	{};	
void() nyarchon_regenerate20	=[	$spellb20,	nyarchon_regenerate21	]	{};	
void() nyarchon_regenerate21	=[	$spellb21,	nyarchon_regenerate22	]	{};
void() nyarchon_regenerate22	=[	$spellb22,	nyarchon_regenerate23	]	{};
void() nyarchon_regenerate23	=[	$spellb23,	nyarchon_regenerate24	]	{};
void() nyarchon_regenerate24	=[	$spellb24,	nyarchon_regenerate25	]	{};
void() nyarchon_regenerate25	=[	$spellb25,	nyarchon_regenerate26	]	{};
void() nyarchon_regenerate26	=[	$spellb26,	nyarchon_regenerate27	]	{};
void() nyarchon_regenerate27	=[	$spellb27,	nyarchon_regenerate28	]	{};
void() nyarchon_regenerate28	=[	$spellb28,	nyarchon_regenerate29	]	{};
void() nyarchon_regenerate29	=[	$spellb29,	nyarchon_regenerate30	]	{};
void() nyarchon_regenerate30	=[	$spellb30,	nyarchon_regenerate31	]	{};
void() nyarchon_regenerate31	=[	$spellb31,	nyarchon_regenerate32	]	{};
void() nyarchon_regenerate32	=[	$spellb32,	nyarchon_regenerate33	]	{};
void() nyarchon_regenerate33	=[	$spellb33,	nyarchon_run1			]	{};

//Spell3 Summoning -> Fiends or Mirror Images
void() nyarchon_summon1		=[	$rangedc1,	nyarchon_summon2	]	{};
void() nyarchon_summon2		=[	$rangedc2,	nyarchon_summon3	]	{}; 
void() nyarchon_summon3		=[	$rangedc3,	nyarchon_summon4	]	{};
void() nyarchon_summon4		=[	$rangedc4,	nyarchon_summon5	]	{};
void() nyarchon_summon5		=[	$rangedc5,	nyarchon_summon6	]	{};
void() nyarchon_summon6		=[	$rangedc6,	nyarchon_summon7	]	{};
void() nyarchon_summon7		=[	$rangedc7,	nyarchon_summon8 	]	{};
void() nyarchon_summon8		=[	$rangedc8,	nyarchon_summon9 	]	{};
void() nyarchon_summon9		=[	$rangedc9,	nyarchon_summon10	]	{};
void() nyarchon_summon10	=[	$rangedc10,	nyarchon_summon11	]	{};
void() nyarchon_summon11	=[	$rangedc27,	nyarchon_summon12	]	{};
void() nyarchon_summon12	=[	$rangedc28,	nyarchon_summon13	]	{};
void() nyarchon_summon13	=[	$rangedc29,	nyarchon_summon14	]	{};
void() nyarchon_summon14	=[	$rangedc30,	nyarchon_run1		]	{};

//==============================================================================
// Abilities
//==============================================================================

void()	nyarchon_Melee =
{
	local vector	ShoveDir;
	local	float	ldmg;
	local vector	delta, enemyorg;

	ai_face ();
	walkmove (self.ideal_yaw, 12);	// allow a little closing

	// Supa, take breakables into account
	if (self.enemy.solid == SOLID_BSP)	enemyorg = (self.enemy.absmin + self.enemy.absmax) * 0.5;
	else								enemyorg = self.enemy.origin;
	
	delta = enemyorg - self.origin;

// DRAGONS /- - - -
//    if (vlen(delta) > 100)
    if (!InMeleeRange (100))    // Needed for fat dragons.
        return;
//- - - - - - - - -
	if (!CanDamage (self.enemy, self))
		return;

    //sound (self, CHAN_WEAPON, "demon/dhit2.wav", 1, ATTN_NORM);
	ldmg = 20 + 10*random();
	T_Damage (self.enemy, self, self, ldmg, DTH_FIEND_CLAW, FALSE, 3);
	
	ShoveDir = aim (self, 1000);
	
	self.enemy.velocity = self.enemy.velocity + (ShoveDir * 1000) + '0 0 100';	//Shoves the player in the direction that the boss is looking
};


//==============================================================================
// Thinking
//==============================================================================

void() nyarchon_SelectAttack = 
{
	if ((random() * 100) > (self.health*skill))
};

void() nyarchon_Pain =	//limping and escape to be called from here
{
};

void() nyarchon_die1 =	//Placeholder
{
	self.think = SUB_Remove;
	self.nextthink = time + 0.1;
	if (self.classname == "monster_nyarchon_mirror") //ijed All mirrors should be destroyed if the original is.  Need to figure out how.
		bprint ("nyarchon Mirror Image Destroyed\n");
	else
		bprint ("nyarchon Destroyed\n");
};


//==============================================================================

//QUAKED monster_nyarchon (1 0 0) (-64 -64 -0) (64 64 128) Ambush Inert
void() monster_nyarchon =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/nyarchon.mdl");
	precache_model ("progs/deathslither.mdl");
	
	precache_sound ("nyarchon/sight.wav");
	precache_sound ("nyarchon/idle.wav");
	precache_sound ("nyarchon/attack1.wav");
	precache_sound ("nyarchon/attack2.wav");
	precache_sound ("nyarchon/pain.wav");
	precache_sound ("nyarchon/death.wav");
		
	//precache_model ("progs/gib_nyarchon1.mdl");


	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/nyarchon.mdl");

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);

	self.health = 4000;

	self.th_stand		=	nyarchon_stand1;
	self.th_walk		=	nyarchon_walk1;
	self.th_run			=	nyarchon_run1;
	self.th_missile		=	nyarchon_SelectAttack;
	self.th_melee		=	nyarchon_SelectAttack;
	//self.th_pain		=	nyarchon_Pain;
	self.th_die			=	nyarchon_die1;


	walkmonster_start ();
};
