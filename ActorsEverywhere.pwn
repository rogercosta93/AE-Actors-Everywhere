/*
		Actors Everywhere

		# Version: 0.1
		# Author: Roger Costa "NikO"

		This filterscript add actors in San Andreas, according current
		time of you server, or add statics actors, staying setted in
		same positions everytime. 1 actor can be created during the day,
		afternoon, night and dawn. You define the positions and animations
		for each time, and when the server time is passing the actors
		are deleted automaticaly and created automaticaly too.
		
		------------------------------------------------------------------
		Types to Create Actor in AE_ACTORS_CREATE_TYPE define:

		0 - Actors they are created and remain the same position;
		1 -   ''    ''  ''    ''  and change positions according time
		    Ex:
		    Time 09:00 - Actor in Beach
		    Time 15:00 - Actor in House
        ------------------------------------------------------------------

*/

// Includes
#include <a_samp>

// Defines
#define AE_MAX_ACTORS                          	7
#define AE_MAX_OBJECTS                          12
#define AE_ACTORS_CREATE_TYPE 					0        // Standard is 0

#define AE_USE_GIVE_ACTOR_DMG                   1        // if 1 call OnGiveDamageActor if actor not invulnerable
#define AE_USE_RESPAWN_ACTOR                    1        // if 1, after shoot, actor execute anims and respawn to early position in TIME that you choose below
#define AE_TIME_RESPAWN_ACTOR                   5000     // Time to respawn actor after shooted, if actor not invulnerable (in ms)

// Dont change, but not specially effect, more for script organization
#define AE_TIME_DAY                             1
#define AE_TIME_AFTERNOON                       2
#define AE_TIME_NIGHT                           3
#define AE_TIME_DAWN                            4

// You change according your server
#define AE_HOURS_DAY                          	7 .. 13
#define AE_HOURS_AFTERNOON                    	14 .. 18
#define AE_HOURS_NIGHT                        	19 .. 23
#define AE_HOURS_DAWN                        	0 .. 6

#define AE_DEBUG                                1 		// 1 actived, 0 disabled

#define AE_USE_STREAMER                         1

#if AE_USE_STREAMER == 1
    #tryinclude <streamer>
#endif


enum ACTORS_INFOS_ENUM
{
	// Name of Actor, useless in the moment
	NAME[24],

	// Positions
	Float:POSITIONS_STANDARD[4],
	Float:POSITIONS_DAY[4],
	Float:POSITIONS_AFTERNOON[4],
	Float:POSITIONS_NIGHT[4],
	Float:POSITIONS_DAWN[4],

	// Skins - If set skin -1 = random skin
	SKIN_STANDARD,
	SKIN_DAY,
	SKIN_AFTERNOON,
	SKIN_NIGHT,
	SKIN_DAWN,

	// Animations
	ANIM_LIB_STANDARD[32], ANIM_NAME_STANDARD[32], ANIM_LOOP_STANDARD,
	ANIM_LIB_DAY[32], ANIM_NAME_DAY[32], ANIM_LOOP_DAY,
	ANIM_LIB_AFTERNOON[32], ANIM_NAME_AFTERNOON[32], ANIM_LOOP_AFTERNOON,
	ANIM_LIB_NIGHT[32], ANIM_NAME_NIGHT[32], ANIM_LOOP_NIGHT,
	ANIM_LIB_DAWN[32], ANIM_NAME_DAWN[32], ANIM_LOOP_DAWN,

	bool:INVULNERABLE,
	VIRTUALWORLD,
	INTERIORID,
}

enum AE_OBJECTS_ENUM
{
    OBJECT_ID,
    Float:OBJECT_POS[3],
    Float:OBJECT_ROT[3],
}

new ACTORS_INFO[AE_MAX_ACTORS][ACTORS_INFOS_ENUM] =
{
	// LOS SANTOS ACTORS

	// CEMITERY ACTORS (AE_ACTORS_CREATE_TYPE == 1, ARE CREATED ONLY "DAY" OR STANDARD POSITION IF AE_ACTORS_CREATE_TYPE == 0)
	// # ACTOR 1
	{
		"CJ",
		{852.2451,-1085.1626,24.2969,285.3400},
		{852.2451,-1085.1626,24.2969,285.3400},
		{0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0},
		0,		0,  	0,  	0,  	0,
		"PED",		"endchat_03", 1,
		"PED",		"endchat_03", 1,
		"NONE",		"NONE", 0,
		"NONE",		"NONE", 0,
		"NONE",		"NONE", 0,
        false
	},
	// # ACTOR 2
	{
		"Sweet",
		{886.0898,-1075.6869,24.2969,181.4619},
		{886.0898,-1075.6869,24.2969,181.4619},
		{0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0},
		270,		270,  	 0,  	 0,  	 0,
		"OTB", 		"wtchrace_cmon", 1,
		"OTB", 		"wtchrace_cmon", 1,
		"NONE",		"NONE", 0,
		"NONE",		"NONE", 0,
		"NONE",		"NONE", 0,
		true
	},
	// # ACTOR 3
	{
		"Kendl",
		{887.1324,-1075.7382,24.2969,165.9121},
		{887.1324,-1075.7382,24.2969,165.9121},
		{0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0},
		65,		65,  	0,  	0,  	0,
		"PED", 		"IDLE_tired", 1,
		"PED", 		"IDLE_tired", 1,
		"NONE",		"NONE", 0,
		"NONE",		"NONE", 0,
		"NONE",		"NONE", 0,
		true
	},
	// # ACTOR 4
	{
		"Ryder",
		{884.8588,-1075.8167,24.2969,183.9686},
		{884.8588,-1075.8167,24.2969,183.9686},
		{0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0},
		271,		271,  	0,  	0,  	0,
		"OTB", 		"wtchrace_lose", 1,
		"OTB", 		"wtchrace_lose", 1,
		"NONE",		"NONE", 0,
		"NONE",		"NONE", 0,
		"NONE",		"NONE", 0,
		true
	},

	// HOMELESS (AE_ACTORS_CREATE_TYPE == 1, ARE CREATED ONLY "DAWN" OR STANDARD POSITION IF AE_ACTORS_CREATE_TYPE == 0)
	// # ACTOR 5
	{
		"Mendigo 1",
		{1610.3655,-1525.3424,13.6156,59.6464},
		{0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0},
		{1610.3655,-1525.3424,13.6156,59.6464},
		78,		271,  	55,  	56,  	78,
		"CRACK", 			"crckidle1", 1,
		"NONE", 			"NONE", 0,
		"NONE", 			"NONE", 0,
		"NONE", 			"NONE", 0,
		"CRACK", 			"crckidle1", 1,
	 	true
	},
	// # ACTOR 6
	{
		"Mendigo 2",
		{1611.0665,-1525.5786,14.0651,51.3551},
		{0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0},
		{1611.0665,-1525.5786,14.0651,51.3551},
		77,		271,  	55,  	56,  	77,
		"CRACK", 			"crckidle2", 1,
		"NONE", 			"NONE", 0,
		"NONE", 			"NONE", 0,
		"NONE", 			"NONE", 0,
		"CRACK", 			"crckidle2", 1,
	 	true
	},
	// # ACTOR 7
	{
		"Mendigo 3",
		{1607.0974,-1523.8680,14.0648,240.6115},
		{0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0},
		{1607.0974,-1523.8680,14.0648,240.6115},
		134,		271,  	55,  	56,  	134,
		"CRACK", 			"crckdeth2", 1,
		"NONE", 			"NONE", 0,
		"NONE", 			"NONE", 0,
		"NONE", 			"NONE", 0,
		"CRACK", 			"crckdeth2", 1,
	 	true
	}
};

new OBJECTS_INFO[AE_MAX_OBJECTS][AE_OBJECTS_ENUM] =
{
    // Objects used in example "Cemitery Actors'
    {   19339,  {885.963928, -1077.381713, 23.673976}, {0.000000, 0.000000, 0.000000}   },
    {   869,    {885.875915, -1077.318115, 23.620748}, {0.400000, -0.400000, -24.300003}   },
    // Objects used in example 'Homeless Actors'
    {   19632,  {1609.0063470,-1524.8005370,12.6506800}, {0.0000000,0.0000000,0.0000000}    },
    {   1728,   {1611.4613030,-1525.0843500,12.5722550}, {0.0000000,0.0000000,-116.3000180} },
    {   1728,   {1606.6767570,-1524.3824460,12.5722550}, {0.0000000,0.0000000,63.4999270}   },
    {   19632,  {1609.0968010,-1524.9692380,12.6506800}, {0.0000000,0.0000000,48.7999800}   },
    {   19632,  {1609.2636710,-1524.7806390,12.6506800}, {0.0000000,0.0000000,113.5999600}  },
    {   19836,  {1610.6063230,-1526.8380120,13.0760900}, {0.0000000,0.0000000,0.0000000}    },
    {   910,    {1608.3912350,-1527.8549800,13.8544120}, {0.0000000,0.0000000,-170.5999750} },
    {   2670,   {1608.4865720,-1526.6530760,12.7041530}, {0.0000000,0.0000000,0.0000000}    },
    {   2677,   {1610.2906490,-1523.6174310,12.8823190}, {0.0000000,0.0000000,0.0000000}    },
    {   1349,   {1611.9851070,-1523.2956540,13.1444040}, {1.1999990,0.0000000,179.6999510}  }
};

new AE_ACTOR_CREATE[AE_MAX_ACTORS] = {-1, ...};     // Used to create actors
new bool:AE_ACTOR_SHOOTED[AE_MAX_ACTORS];
new AE_OBJECT_CREATE[AE_MAX_OBJECTS] = {-1, ...};   // Used to create objects
new AE_TIME_STATE;      							// Used to check hour
new AE_HOUR;            							// Used to get server time (in gamemode, or other script) with CallRemoteFunction
new AE_LOOP;            							// Used in create actors loop


// Callbacks

public OnFilterScriptInit()
{
    
    // Creating objects, if used..
    for(new i = 0; i < sizeof(OBJECTS_INFO); i++)
    {
        #if AE_USE_STREAMER == 1
            AE_OBJECT_CREATE[i] = CreateDynamicObject(OBJECTS_INFO[i][OBJECT_ID],
                                                      OBJECTS_INFO[i][OBJECT_POS][0],
                                                      OBJECTS_INFO[i][OBJECT_POS][1],
                                                      OBJECTS_INFO[i][OBJECT_POS][2],
                                                      OBJECTS_INFO[i][OBJECT_ROT][0],
                                                      OBJECTS_INFO[i][OBJECT_ROT][1],
                                                      OBJECTS_INFO[i][OBJECT_ROT][2],
                                                      -1, -1, -1,
                                                      STREAMER_OBJECT_SD,
                                                      STREAMER_OBJECT_DD);
        #elseif AE_USE_STREAMER == 0
            AE_OBJECT_CREATE[i] = CreateObject(OBJECTS_INFO[i][OBJECT_ID],
                                               OBJECTS_INFO[i][OBJECT_POS][0],
                                               OBJECTS_INFO[i][OBJECT_POS][1],
                                               OBJECTS_INFO[i][OBJECT_POS][2],
                                               OBJECTS_INFO[i][OBJECT_ROT][0],
                                               OBJECTS_INFO[i][OBJECT_ROT][1],
                                               OBJECTS_INFO[i][OBJECT_ROT][2],
                                               25);
        #endif
    }

    // Creating actors
    #if AE_ACTORS_CREATE_TYPE == 0
        SetTimer("AE_CreateStaticActors", 1000*5, false);
    #elseif AE_ACTORS_CREATE_TYPE == 1
        SetTimer("AE_CheckTimeForActors", 1000*5, true);
	#else
        #error "Define AE_ACTORS_CREATE_TYPE between 0 and 1. Read top of Script."
    #endif
	
	print("\nActors Everywhere Loaded.\nAuthor: Roger Costa ''NikO''");
	return 1;
}

public OnFilterScriptExit()
{
    for(new i = 0; i < AE_LOOP; i++)
    {
	    if(IsValidActor(AE_ACTOR_CREATE[i]) && AE_ACTOR_CREATE[i] != -1)
	    {
			#if AE_DEBUG == 1
                printf("<AE_DEBUG> Actors Deleted: AE_ACTOR_CREATE[%d] / ID in-game: %d", i, AE_ACTOR_CREATE[i]);
			#endif
	        DestroyActor(AE_ACTOR_CREATE[i]);
			AE_ACTOR_CREATE[i] = -1;
		}
	}
	
    for(new i = 0; i < sizeof(OBJECTS_INFO); i++)
    {
        #if AE_USE_STREAMER == 1
            if(IsValidDynamicObject(AE_OBJECT_CREATE[i]))
                DestroyDynamicObject(AE_OBJECT_CREATE[i]);
		#elseif AE_USE_STREAMER == 0
            if(IsValidObject(AE_OBJECT_CREATE[i]))
                DestroyObject(AE_OBJECT_CREATE[i]);
		#endif
	}
	
	print("\nActors Everywhere Unloaded - There all actors\ncreated with FS are deleted.");
	return 1;
}

forward AE_CreateStaticActors();
public AE_CreateStaticActors()
{
    if(sizeof(ACTORS_INFO) <= (MAX_ACTORS - GetActorPoolSize())) AE_LOOP = sizeof(ACTORS_INFO);
    else AE_LOOP = MAX_ACTORS - GetActorPoolSize();
    
	for(new i = 0; i < AE_LOOP; i++)
	{
	    if(ACTORS_INFO[i][SKIN_STANDARD] == -1) ACTORS_INFO[i][SKIN_STANDARD] = random(311);
	    AE_ACTOR_CREATE[i] =  CreateActor(ACTORS_INFO[i][SKIN_STANDARD],
										ACTORS_INFO[i][POSITIONS_STANDARD][0], 	// Position X
										ACTORS_INFO[i][POSITIONS_STANDARD][1],  // Position Y
										ACTORS_INFO[i][POSITIONS_STANDARD][2],  // Position Z
										ACTORS_INFO[i][POSITIONS_STANDARD][3]); // Facing Angle (Rotation)
		ApplyActorAnimation(AE_ACTOR_CREATE[i], ACTORS_INFO[i][ANIM_LIB_STANDARD], ACTORS_INFO[i][ANIM_NAME_STANDARD], ACTORS_INFO[i][ANIM_LOOP_STANDARD], 1, 0, 0, 0, 0);
		SetActorInvulnerable(AE_ACTOR_CREATE[i], ACTORS_INFO[i][INVULNERABLE]);   // Invulnerabity
		#if AE_DEBUG == 1
		  printf("<AE_DEBUG> Actor Created: AE_ACTOR_CREATE[%d] / Actor ID in-game: %d", i, AE_ACTOR_CREATE[i]);
		#endif
	}
}

forward AE_CheckTimeForActors();
public AE_CheckTimeForActors()
{
    AE_HOUR = CallRemoteFunction("ReturnTime", "d", 1); // This "PUBLIC_NAME_RETUNING_HOUR" has to return HOUR
    switch(AE_HOUR)
    {
        case AE_HOURS_DAWN: 	// Dawn
        {
            if(AE_TIME_STATE != AE_TIME_DAWN)
            {
                AE_TIME_STATE = AE_TIME_DAWN;

 				for(new i = 0; i < AE_LOOP; i++)
				{
				    if(IsValidActor(AE_ACTOR_CREATE[i]) && AE_ACTOR_CREATE[i] != -1)
				    {
						#if AE_DEBUG == 1
						  printf("<AE_DEBUG> Actors Deleted: AE_ACTOR_CREATE[%d] / ID in-game: %d", i, AE_ACTOR_CREATE[i]);
						#endif
				        DestroyActor(AE_ACTOR_CREATE[i]);
						AE_ACTOR_CREATE[i] = -1;
					}
                }

                if(sizeof(ACTORS_INFO) <= (MAX_ACTORS - GetActorPoolSize())) AE_LOOP = sizeof(ACTORS_INFO);
                else AE_LOOP = MAX_ACTORS - GetActorPoolSize();

				for(new i = 0; i < AE_LOOP; i++)
				{
					if(ACTORS_INFO[i][POSITIONS_DAWN][0] != 0.0)
					{
	                    if(ACTORS_INFO[i][SKIN_DAWN] == -1) 	ACTORS_INFO[i][SKIN_DAWN] = random(311);
						AE_ACTOR_CREATE[i] =  CreateActor(ACTORS_INFO[i][SKIN_DAWN],
														  ACTORS_INFO[i][POSITIONS_DAWN][0], 	// Position X
														  ACTORS_INFO[i][POSITIONS_DAWN][1],  // Position Y
														  ACTORS_INFO[i][POSITIONS_DAWN][2],  // Position Z
														  ACTORS_INFO[i][POSITIONS_DAWN][3]); // Facing Angle (Rotation)

						ApplyActorAnimation(AE_ACTOR_CREATE[i], ACTORS_INFO[i][ANIM_LIB_DAWN], ACTORS_INFO[i][ANIM_NAME_DAWN], 4.1, ACTORS_INFO[i][ANIM_LOOP_DAWN], 0, 0, 0, 0);
						SetActorInvulnerable(AE_ACTOR_CREATE[i], ACTORS_INFO[i][INVULNERABLE]);
						
						#if AE_DEBUG == 1
						  printf("<AE_DEBUG> Actor Created: AE_ACTOR_CREATE[%d] / Actor ID in-game: %d", i, AE_ACTOR_CREATE[i]);
						#endif
					}
				}
				print("\n- AE: Actors Dawn Created!\n");
			}
		}
		case AE_HOURS_DAY: 	// Day
		{
            if(AE_TIME_STATE != AE_TIME_DAY)
            {
                AE_TIME_STATE = AE_TIME_DAY;
 				for(new i = 0; i < AE_LOOP; i++)
				{
				    if(IsValidActor(AE_ACTOR_CREATE[i]) && AE_ACTOR_CREATE[i] != -1)
				    {
						#if AE_DEBUG == 1
						  printf("<AE_DEBUG> Actors Deleted: AE_ACTOR_CREATE[%d] / ID in-game: %d", i, AE_ACTOR_CREATE[i]);
						#endif
				        DestroyActor(AE_ACTOR_CREATE[i]);
						AE_ACTOR_CREATE[i] = -1;
					}
                }

                if(sizeof(ACTORS_INFO) <= (MAX_ACTORS - GetActorPoolSize())) AE_LOOP = sizeof(ACTORS_INFO);
                else AE_LOOP = MAX_ACTORS - GetActorPoolSize();

				for(new i = 0; i < AE_LOOP; i++)
				{
					if(ACTORS_INFO[i][POSITIONS_DAY][0] != 0.0)
					{
                    	if(ACTORS_INFO[i][SKIN_DAY] == -1) ACTORS_INFO[i][SKIN_DAY] = random(311);
						AE_ACTOR_CREATE[i] =  CreateActor(ACTORS_INFO[i][SKIN_DAY],
														  ACTORS_INFO[i][POSITIONS_DAY][0], 	// Position X
														  ACTORS_INFO[i][POSITIONS_DAY][1],  // Position Y
														  ACTORS_INFO[i][POSITIONS_DAY][2],  // Position Z
														  ACTORS_INFO[i][POSITIONS_DAY][3]); // Facing Angle (Rotation)

						ApplyActorAnimation(AE_ACTOR_CREATE[i], ACTORS_INFO[i][ANIM_LIB_DAY], ACTORS_INFO[i][ANIM_NAME_DAY], 4.1, ACTORS_INFO[i][ANIM_LOOP_DAY], 0, 0, 0, 0);
						SetActorInvulnerable(AE_ACTOR_CREATE[i], ACTORS_INFO[i][INVULNERABLE]);
						
						#if AE_DEBUG == 1
						  printf("<AE_DEBUG> Actor Created: AE_ACTOR_CREATE[%d] / Actor ID in-game: %d", i, AE_ACTOR_CREATE[i]);
						#endif
					}
				}
				print("\n- AE: Actors Day Created!\n");
			}
		}
		case AE_HOURS_AFTERNOON: 	// Afternoon
		{
            if(AE_TIME_STATE != AE_TIME_AFTERNOON)
            {
                AE_TIME_STATE = AE_TIME_AFTERNOON;
 				for(new i = 0; i < AE_LOOP; i++)
				{
				    if(IsValidActor(AE_ACTOR_CREATE[i]) && AE_ACTOR_CREATE[i] != -1)
				    {
						#if AE_DEBUG == 1
						  printf("<AE_DEBUG> Actors Deleted: AE_ACTOR_CREATE[%d] / ID in-game: %d", i, AE_ACTOR_CREATE[i]);
						#endif
				        DestroyActor(AE_ACTOR_CREATE[i]);
						AE_ACTOR_CREATE[i] = -1;
					}
                }

                if(sizeof(ACTORS_INFO) <= (MAX_ACTORS - GetActorPoolSize())) AE_LOOP = sizeof(ACTORS_INFO);
                else AE_LOOP = MAX_ACTORS - GetActorPoolSize();

				for(new i = 0; i < AE_LOOP; i++)
				{
					if(ACTORS_INFO[i][POSITIONS_AFTERNOON][0] != 0.0)
					{
	                    if(ACTORS_INFO[i][SKIN_AFTERNOON] == -1) ACTORS_INFO[i][SKIN_AFTERNOON] = random(311);
						AE_ACTOR_CREATE[i] =  CreateActor(ACTORS_INFO[i][SKIN_AFTERNOON],
														  ACTORS_INFO[i][POSITIONS_AFTERNOON][0], 	// Position X
														  ACTORS_INFO[i][POSITIONS_AFTERNOON][1],  // Position Y
														  ACTORS_INFO[i][POSITIONS_AFTERNOON][2],  // Position Z
														  ACTORS_INFO[i][POSITIONS_AFTERNOON][3]); // Facing Angle (Rotation)

						ApplyActorAnimation(AE_ACTOR_CREATE[i], ACTORS_INFO[i][ANIM_LIB_AFTERNOON], ACTORS_INFO[i][ANIM_NAME_AFTERNOON], 4.1, ACTORS_INFO[i][ANIM_LOOP_AFTERNOON], 0, 0, 0, 0);
						SetActorInvulnerable(AE_ACTOR_CREATE[i], ACTORS_INFO[i][INVULNERABLE]);
						
						#if AE_DEBUG == 1
						  printf("<AE_DEBUG> Actor Created: AE_ACTOR_CREATE[%d] / Actor ID in-game: %d", i, AE_ACTOR_CREATE[i]);
						#endif
					}
				}
				print("\n- AE: Actors Afternoon Created!\n");
			}
		}
		case AE_HOURS_NIGHT:  // Night
		{
            if(AE_TIME_STATE != AE_TIME_NIGHT)
            {
                AE_TIME_STATE = AE_TIME_NIGHT;
 				for(new i = 0; i < AE_LOOP; i++)
				{
				    if(IsValidActor(AE_ACTOR_CREATE[i]) && AE_ACTOR_CREATE[i] != -1)
				    {
						#if AE_DEBUG == 1
						  printf("<AE_DEBUG> Actors Deleted: AE_ACTOR_CREATE[%d] / ID in-game: %d", i, AE_ACTOR_CREATE[i]);
						#endif
				        DestroyActor(AE_ACTOR_CREATE[i]);
						AE_ACTOR_CREATE[i] = -1;
					}
                }

                if(sizeof(ACTORS_INFO) <= (MAX_ACTORS - GetActorPoolSize())) AE_LOOP = sizeof(ACTORS_INFO);
                else AE_LOOP = MAX_ACTORS - GetActorPoolSize();

				for(new i = 0; i < AE_LOOP; i++)
				{
					if(ACTORS_INFO[i][POSITIONS_NIGHT][0] != 0.0)
					{
                    	if(ACTORS_INFO[i][SKIN_NIGHT] == -1) ACTORS_INFO[i][SKIN_NIGHT] = random(311);
						AE_ACTOR_CREATE[i] =  CreateActor(ACTORS_INFO[i][SKIN_NIGHT],
														  ACTORS_INFO[i][POSITIONS_NIGHT][0], 	// Position X
														  ACTORS_INFO[i][POSITIONS_NIGHT][1],  // Position Y
														  ACTORS_INFO[i][POSITIONS_NIGHT][2],  // Position Z
														  ACTORS_INFO[i][POSITIONS_NIGHT][3]); // Facing Angle (Rotation)

						ApplyActorAnimation(AE_ACTOR_CREATE[i], ACTORS_INFO[i][ANIM_LIB_NIGHT], ACTORS_INFO[i][ANIM_NAME_NIGHT], 4.1, ACTORS_INFO[i][ANIM_LOOP_NIGHT], 0, 0, 0, 0);
						SetActorInvulnerable(AE_ACTOR_CREATE[i], ACTORS_INFO[i][INVULNERABLE]);
						
						#if AE_DEBUG == 1
					       printf("<AE_DEBUG> Actor Created: AE_ACTOR_CREATE[%d] / Actor ID in-game: %d", i, AE_ACTOR_CREATE[i]);
						#endif
					}
				}
				print("\n- AE: Actors Night Created!\n");
			}
		}
	}
}

public OnActorStreamIn(actorid, forplayerid)
{
    for(new i = 0; i < AE_LOOP; i++)
    {
        if(actorid == AE_ACTOR_CREATE[i])
        {
        	#if AE_ACTORS_CREATE_TYPE == 0
        	    SetActorPos(actorid, ACTORS_INFO[i][POSITIONS_STANDARD][0], ACTORS_INFO[i][POSITIONS_STANDARD][1], ACTORS_INFO[i][POSITIONS_STANDARD][2]);
        	    SetActorFacingAngle(actorid, ACTORS_INFO[i][POSITIONS_STANDARD][3]);
        	    ApplyActorAnimation(actorid, ACTORS_INFO[i][ANIM_LIB_STANDARD], ACTORS_INFO[i][ANIM_NAME_STANDARD], 4.1, ACTORS_INFO[i][ANIM_LOOP_STANDARD], 0, 0, 0, 0);
        	    
            #elseif AE_ACTORS_CREATE_TYPE == 1
    			switch(AE_HOUR)
    			{
        			case AE_HOURS_DAWN: 	// Dawn
        			{
    	        	    SetActorPos(actorid, ACTORS_INFO[i][POSITIONS_DAWN][0], ACTORS_INFO[i][POSITIONS_DAWN][1], ACTORS_INFO[i][POSITIONS_DAWN][2]);
    	        	    SetActorFacingAngle(actorid, ACTORS_INFO[i][POSITIONS_DAWN][3]);
    	        	    ApplyActorAnimation(actorid, ACTORS_INFO[i][ANIM_LIB_DAWN], ACTORS_INFO[i][ANIM_NAME_DAWN], 4.1, ACTORS_INFO[i][ANIM_LOOP_DAWN], 0, 0, 0, 0);
    				}
        			case AE_HOURS_DAY: 	// Day
        			{
    	        	    SetActorPos(actorid, ACTORS_INFO[i][POSITIONS_DAY][0], ACTORS_INFO[i][POSITIONS_DAY][1], ACTORS_INFO[i][POSITIONS_DAY][2]);
    	        	    SetActorFacingAngle(actorid, ACTORS_INFO[i][POSITIONS_DAY][3]);
    	        	    ApplyActorAnimation(actorid, ACTORS_INFO[i][ANIM_LIB_DAY], ACTORS_INFO[i][ANIM_NAME_DAY], 4.1, ACTORS_INFO[i][ANIM_LOOP_DAY], 0, 0, 0, 0);
    				}
        			case AE_HOURS_AFTERNOON: 	// Afternoon
        			{
    	        	    SetActorPos(actorid, ACTORS_INFO[i][POSITIONS_AFTERNOON][0], ACTORS_INFO[i][POSITIONS_AFTERNOON][1], ACTORS_INFO[i][POSITIONS_AFTERNOON][2]);
    	        	    SetActorFacingAngle(actorid, ACTORS_INFO[i][POSITIONS_AFTERNOON][3]);
    	        	    ApplyActorAnimation(actorid, ACTORS_INFO[i][ANIM_LIB_AFTERNOON], ACTORS_INFO[i][ANIM_NAME_AFTERNOON], 4.1, ACTORS_INFO[i][ANIM_LOOP_AFTERNOON], 0, 0, 0, 0);
    				}
        			case AE_HOURS_NIGHT: 	// Night
        			{
    	        	    SetActorPos(actorid, ACTORS_INFO[i][POSITIONS_NIGHT][0], ACTORS_INFO[i][POSITIONS_NIGHT][1], ACTORS_INFO[i][POSITIONS_NIGHT][2]);
    	        	    SetActorFacingAngle(actorid, ACTORS_INFO[i][POSITIONS_NIGHT][3]);
    	        	    ApplyActorAnimation(actorid, ACTORS_INFO[i][ANIM_LIB_NIGHT], ACTORS_INFO[i][ANIM_NAME_NIGHT], 4.1, ACTORS_INFO[i][ANIM_LOOP_NIGHT], 0, 0, 0, 0);
    				}
    			}
            #endif

            AE_ACTOR_SHOOTED[i] = false;

		    #if AE_DEBUG == 1
    	        new str[80];
    		    format(str, sizeof str, "<AE_DEBUG> Actor %s (id-game:%d) is now streamed in for you.", ACTORS_INFO[i][NAME], actorid);
    		    SendClientMessage(forplayerid, 0xFFFFFFFF, str);
			#endif
			
		    break;
		}
	}
    return 1;
}

public OnPlayerGiveDamageActor(playerid, damaged_actorid, Float:amount, weaponid, bodypart)
{
    if(damaged_actorid != INVALID_ACTOR_ID && IsValidActor(damaged_actorid))
    {
        #if AE_USE_GIVE_ACTOR_DMG == 1
            for(new i = 0; i < AE_LOOP; i++)
            {
                if(damaged_actorid == AE_ACTOR_CREATE[i] && !AE_ACTOR_SHOOTED[i])
                {
                    static Float:ACTOR_ANGLE, Float:PLAYERID_ANGLE,
                           RESULT;

                    AE_ACTOR_SHOOTED[i] = true;

                    GetPlayerFacingAngle(playerid, PLAYERID_ANGLE);
                    GetActorFacingAngle(damaged_actorid, ACTOR_ANGLE);
                    ClearActorAnimations(damaged_actorid);

                    // Small script for detect shoot in face, chest and torso, from the front
                    // or from behind. I using playerid & actor angles and compared
                    // if boths they are looking
                    RESULT = floatround(ACTOR_ANGLE) - floatround(PLAYERID_ANGLE);
            		if(RESULT >= 135 && RESULT <= 225 || RESULT >= -135 && RESULT <= -225)
            		{
            		    if(bodypart == 4) // Shoot in chest
                            ApplyActorAnimation(damaged_actorid, "PED", "KO_shot_stom", 4.1, 0, 1, 1, 1, 0);
            			else if(bodypart == 9) // Shoot in Head
                            ApplyActorAnimation(damaged_actorid, "PED", "KO_shot_face", 4.1, 0, 1, 1, 1, 0);
            			else if(bodypart == 3) // Shoot in Torso
                            ApplyActorAnimation(damaged_actorid, "PED", "KO_shot_front", 4.1, 0, 1, 1, 1, 0);
            		}
            		else if(RESULT >= -45 && RESULT <= 45)
            		{
            			if(bodypart == 9) // Shoot in head (back)
                            ApplyActorAnimation(damaged_actorid, "FINALE", "FIN_Land_Die", 4.1, 0, 1, 1, 1, 0);
            			else if(bodypart == 3) // Shoot in torso (back)
                            ApplyActorAnimation(damaged_actorid, "PED", "KO_skid_back", 4.1, 0, 1, 1, 1, 0);
            		}
                    else ApplyActorAnimation(damaged_actorid, "PED", "KO_skid_back", 4.1, 0, 1, 1, 1, 0);
                    #if AE_USE_RESPAWN_ACTOR == 0
                        SetTimerEx("AE_RespawnActor", AE_TIME_RESPAWN_ACTOR, false, "dd", AE_ACTOR_CREATE[i], i);
                    #endif
                    break;
                }
            }
        #endif
    }
    return 1;
}

forward AE_RespawnActor(actorid, var_id);
public AE_RespawnActor(actorid, var_id)
{
	#if AE_ACTORS_CREATE_TYPE == 0
    SetActorPos(actorid, ACTORS_INFO[var_id][POSITIONS_STANDARD][0], ACTORS_INFO[var_id][POSITIONS_STANDARD][1], ACTORS_INFO[var_id][POSITIONS_STANDARD][2]);
    SetActorFacingAngle(actorid, ACTORS_INFO[var_id][POSITIONS_STANDARD][3]);
    ApplyActorAnimation(actorid, ACTORS_INFO[var_id][ANIM_LIB_STANDARD], ACTORS_INFO[var_id][ANIM_NAME_STANDARD], 4.1, 1, 0, 0, 0, 0);

    #elseif AE_ACTORS_CREATE_TYPE == 1
	switch(AE_HOUR)
	{
		case AE_HOURS_DAWN: // Dawn
		{
    	    SetActorPos(actorid, ACTORS_INFO[var_id][POSITIONS_DAWN][0], ACTORS_INFO[var_id][POSITIONS_DAWN][1], ACTORS_INFO[var_id][POSITIONS_DAWN][2]);
    	    SetActorFacingAngle(actorid, ACTORS_INFO[var_id][POSITIONS_DAWN][3]);
    	    ApplyActorAnimation(actorid, ACTORS_INFO[var_id][ANIM_LIB_DAWN], ACTORS_INFO[var_id][ANIM_NAME_DAWN], 4.1, 1, 0, 0, 0, 0);
		}
		case AE_HOURS_DAY: 	// Day
		{
    	    SetActorPos(actorid, ACTORS_INFO[var_id][POSITIONS_DAY][0], ACTORS_INFO[var_id][POSITIONS_DAY][1], ACTORS_INFO[var_id][POSITIONS_DAY][2]);
    	    SetActorFacingAngle(actorid, ACTORS_INFO[var_id][POSITIONS_DAY][3]);
    	    ApplyActorAnimation(actorid, ACTORS_INFO[var_id][ANIM_LIB_DAY], ACTORS_INFO[var_id][ANIM_NAME_DAY], 4.1, 1, 0, 0, 0, 0);
		}
		case AE_HOURS_AFTERNOON: // Afternoon
		{
    	    SetActorPos(actorid, ACTORS_INFO[var_id][POSITIONS_AFTERNOON][0], ACTORS_INFO[var_id][POSITIONS_AFTERNOON][1], ACTORS_INFO[var_id][POSITIONS_AFTERNOON][2]);
    	    SetActorFacingAngle(actorid, ACTORS_INFO[var_id][POSITIONS_AFTERNOON][3]);
    	    ApplyActorAnimation(actorid, ACTORS_INFO[var_id][ANIM_LIB_AFTERNOON], ACTORS_INFO[var_id][ANIM_NAME_AFTERNOON], 4.1, 1, 0, 0, 0, 0);
		}
		case AE_HOURS_NIGHT: // Night
		{
    	    SetActorPos(actorid, ACTORS_INFO[var_id][POSITIONS_NIGHT][0], ACTORS_INFO[var_id][POSITIONS_NIGHT][1], ACTORS_INFO[var_id][POSITIONS_NIGHT][2]);
    	    SetActorFacingAngle(actorid, ACTORS_INFO[var_id][POSITIONS_NIGHT][3]);
    	    ApplyActorAnimation(actorid, ACTORS_INFO[var_id][ANIM_LIB_NIGHT], ACTORS_INFO[var_id][ANIM_NAME_NIGHT], 4.1, 1, 0, 0, 0, 0);
		}
	}
    AE_ACTOR_SHOOTED[var_id] = false;
    #endif
}
