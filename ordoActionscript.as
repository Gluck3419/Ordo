
//———————————————————————————————————————————————————————————————————————————————————————————
//—————————————————————————————————————————CLOCK CODE————————————————————————————————————————
//——————————————————————————————————————————————————————————————————————————————————————————— 

function f_LevelChecks(zone)
{
   if(c.ordo == undefined) //var setup
   {
      c.ordo = false;
      c.ordoSpawned = false;
      c.ordoFleetPower = 1;
   }
   if(level != 44 and level != 39) //anyplace other than wizard castle or insane store
   {
      if(c.ordo == true) //in an ordo fight
      {
        if(c.ordoTimer > 0)
        {
            c.ordoTimer -= 1; //timer before ordo fighters spawn
        }
        if(active_enemies == 0 and c.ordoIsActive) //player won (W) (the player die code, calling f_EndOrdoFight, is written into f_RemovePlayer)
        {
            f_EndOrdoFight(zone)
            c.ordoFleetPower += 1 //increment power when ordo beaten
            c.allyEditor = true;
            f_ChangeLevel("../level39/level39.swf"); //send to ally customization realm
        }
        if(c.ordoSpawned == false)
        {
            f_InitOrdoFight(zone); //setup ordo fight
        }
        else if(c.ordoTimer == 1)
        {
            f_SpawnOrdoFight(zone); //spawn ordo fighters
        }
        f_KillNonOrdos(); //kill any enemies that are in the level for whatever reason
      }
      else
      {
        f_ChangeLevel("../level44/level44.swf")
      }
   }
   else if(level == 44) //wizard castle
   {
      f_ShieldCheck(zone); //player shield controls
      f_TouchOrdoCheck(zone); //check for touching ordo fleet
      f_Magic(zone,zone.magic_regen)
      zone.displayTimer += 1; 
      if(zone.displayTimer % 30 == 0) //the value shown above orb, represents times hit
      {
         var _loc3_ = undefined; //mostly copypaste shit
         if(zone._xscale > 0)
         {
            _loc3_ = zone.x + 15;
         }
         else
         {
            _loc3_ = zone.x - 15;
         }
         var _loc4_ = f_FX(_loc3_,zone.y + zone.body_y - 100,zone.y + 5,"damage_val",100,100);
         zone.u_digit = _loc4_;
         f_ShowVal(_loc4_,zone.health_max - zone.health,color_dark);
      }
      if(zone.y > -1000) //initiate the orb environment
      {
         cinema = true; //no teleporting!! should set to false when loading into new ordo
         zone.x = 500; //to the shadow realm you go
         zone._x = 500;
         zone.y = -3000;
         zone._y = -3000;
         f_SetBottomEdgePosition(-2975);
         f_SetLeftEdgePosition(0);
         f_SetRightEdgePosition(1000);
         f_PlayersStop();
         f_PlayersGo();
         zone.fp_StandAnim = f_Orb; //Orb.
         zone.fp_WalkAnim = f_Orb;
         zone.fp_DashAnim = f_Orb;
         zone.fp_MidAttacc = f_Walk; //fp_MidAttacc call is what i added to the clipaction on the enemy_archerUNUSED animation, forces basic movement control only
         zone.health_max = zone.health = 99999; //cant die
         zone.magic_regen = 0.7 //this is default magic regen at lvl 99
         zone.displayTimer = 0;
         zone.pet._alpha = 0;
         c.timesGlogged = 0; //glogged! (times hit by ordo attack, all players individually affect this variable)
         c.customizationInit = false;
         zone.hud_pt.gotoAndStop("wait")
         zone._xscale = 70;
         zone._yscale = 70;
         zone.speed_x = zone.speed_y = c.ordoFleetPower + 1; //increase player speed the more ordos you kill
         unloadMovie(_root.loader.sky); //haha wheres your sky bitch
         f_GetCameraCoords(main); //probably relevant?
         f_SpawnNexus(500,-4000);
         if(total_enemies < 50)
         {
            f_CreateEnemies(50); //fifty! wow!
         }
         //MAZE SHIT
         if(total_fx < 500)
         {
            f_CreateFX(500,10)
         }
         f_SpawnWall(500,-3500,500,100,color_purple)
      }
   }
   else if(level == 39) //insane store ally customization
   {
      if(c.customizationInit == undefined || c.customizationInit == false)
      {
         f_InitAllyCustomization(zone)
      }
      if(Key.isDown(zone.button_punch1) and Key.isDown(zone.button_punch2) and Key.isDown(zone.button_jump) and Key.isDown(zone.button_projectile))
      {
         f_LeaveAllyEditor(zone)
      }
   }
}
//Controls enemy ai from clock scenario
function f_EnemyChecks(zone)
{
   if(zone == c.nexus)
   {
      f_NexusAI(zone);
   }
   if(zone.ordofleet)
   {
      f_OrdoWalk(zone);
   }
}


//———————————————————————————————————————————————————————————————————————————————————————————
//——————————————————————————————————————ORB REGION CODE——————————————————————————————————————
//——————————————————————————————————————————————————————————————————————————————————————————— 

//player shielding controls while in orb region
function f_ShieldCheck(zone)
{
   if(Key.isDown(zone.button_shield) and zone.magic_current > 0)
   {
      if(!zone.blocking)
      {
         f_ColorSwap(zone,color_verydark);
         zone.oldSpeed = zone.speed_x;
         zone.speed_x = zone.speed_y = zone.speed_x * 0.75;
      }
      f_Magic(zone,-(zone.magic_regen + 1)); //cant hold shield all the time
      zone.blocking = true;
   }
   else if(zone.blocking == true)
   {
      f_ColorSwap(zone,color_bright);
      zone.blocking = false;
      zone.speed_x = zone.speed_y = zone.oldSpeed;
   }
}

//Idle, walk etc animation for ordos
function f_Orb(zone)
{
   zone.gotoAndStop("enemy_archerUNUSED");
}

//Idle, walk etc animation for nexus
function f_Ring(zone)
{
   zone.gotoAndStop("peep");
}

//Spawns nexus (ring thing)
function f_SpawnNexus(x, y)
{
   c.nexus = f_SpawnBarbarian(x,y,1);
   c.nexus.fp_StandAnim = f_Ring; //Ring.
   c.nexus.fp_WalkAnim = f_Ring;
   c.nexus.fp_DashAnim = f_Ring;
   c.nexus.spawnLimit = c.ordoFleetPower + 1;
   c.nexus.spawnTimer = int(30 - Math.ceil(c.ordoFleetPower * 1.75));
   c.nexus.alive = true; 
   c.nexus._xscale = 120;
   c.nexus._yscale = 120;
   f_SetTargets();
   s_Fart2.start(0,0); //this sound is replaced with the c'mere thing (from Bury A Friend cover by The Bass Gang)
}

//Nexus behaviour, spawns ordo fleet based on timer
function f_NexusAI(zone)
{
   c.nexus.invincible_timer = 1; //prevent from doing hit anims when player hits
   zone.spawnTimer -= 1;
   if(zone.spawnTimer <= 0 and active_enemies < zone.spawnLimit)
   {
      f_SpawnOrdoFleet(zone.x,zone.y,c.ordoFleetPower);
      zone.spawnTimer = 180 * c.ordoFleetPower;
   }
}

//Spawns ordo fleet, arranges ai priority for that fleet
function f_SpawnOrdoFleet(x, y, power)
{
   var _loc4_ = f_SpawnBarbarian(x,y,1);
   _loc4_.fp_StandAnim = f_Orb; //Orb
   _loc4_.fp_WalkAnim = f_Orb;
   _loc4_.fp_DashAnim = f_Orb;
   _loc4_.shot_timer = 60; //glog timer
   _loc4_.magic_pow = 500; //is this important i cant tell
   _loc4_.speed = power + 1; //increase speed based on power
   _loc4_.ordofleet = true;
   _loc4_._xscale = 70;
   _loc4_._yscale = 70;
   _loc4_.fp_StandAnim(_loc4_);
   f_ColorSwap(_loc4_,color_bright);
   f_SetTargets();
   _loc4_.temp_priority = _loc4_.priority; //enemies are assigned this priority constantly in f_OrdoWalk to prevent neutral enemies (anim flicker also no top edge)
   _loc4_.u_mod = 0; //makes ai try to go directly to your coords instead of stopping in front
}

//Ordo fleet AI
function f_OrdoWalk(zone)
{
   zone.wait_timer = 1; //make them not do the silly goofy pause
   zone.invincible_timer = 1; //prevent from doing hit anims
   zone.priority = zone.temp_priority; //prevent neutral enemies 
   zone.shot_timer -= 1;
   if(zone.shot_timer <= 10) //the glogging!
   {
      if(zone.shot_timer == 10)
      {
        s_DarkBass.start(0,0); //give player warning that attack will occur
        if(zone.prey)
        {
            f_ColorSwap(zone,color_darkred); //give player warning that attack will occur
        }
      }
      if(zone.shot_timer == 0)
      {
        if(!zone.prey.blocking)
        {
           s_BoneExplode.start(0,0);
           f_Damage(zone.prey,c.ordoFleetPower,DMG_MELEE);
           c.timesGlogged += c.ordoFleetPower; //the hilarious (increase future ordo power if youve been hit)
        }
        zone.shot_timer = 120;
        f_ColorSwap(zone,color_default);
      }
   }
   f_EnemyWalkInit(zone); //normal ai mostly
   f_EnemyWalk(zone);
   f_EnemyClose(zone);
}

//Checks if you have touched an enemy ordo fleet, loads a new level if true
function f_TouchOrdoCheck(zone)
{
   var _loc2_ = zone.x; //this shit is literally just copypasted from f_MeleeCheckHit
   var _loc3_ = zone.y;
   u_point.x = 0;
   u_point.y = 0;
   f_LocalToGame(zone,u_point);
   var _loc4_ = u_point.x;
   var _loc5_ = u_point.y;
   var _loc6_ = zone._width / 2 * (Math.abs(zone._xscale) / 100);
   var _loc7_ = zone._height / 2 * (Math.abs(zone._yscale) / 100);
   var _loc8_ = _loc5_ - _loc7_;
   var _loc9_ = _loc5_ + _loc7_;
   var _loc10_ = _loc4_ - _loc6_;
   var _loc11_ = _loc4_ + _loc6_;
   zone.hit_impact = false;
   zone.hit_x = _loc4_;
   zone.hit_y = _loc5_;
   var _loc12_ = 1;
   while(_loc12_ <= active_enemies)
   {
      var _loc13_ = enemyArrayOb["e" + int(_loc12_)];
      if(_loc13_.active and _loc13_ != c.nexus or _loc13_ == c.nexus and active_enemies == 1) //only can touch nexus if no other enemies, nexus will tp player to whatever final boss will be
      {
        f_MeleeCheckHit(zone,_loc13_,_loc2_,_loc3_,_loc4_,_loc5_,_loc8_,_loc9_,_loc10_,_loc11_);
        if(zone.hit_impact == true and c.ordo == false)
        {
            c.ordo = true;
            if(!insane_mode)
            {
               insane_mode = true; //cant have no normal mode bitches (maybe add 5x rather than 10x difficulty mode for people who wanna enjoy it but aren't gigapiss skilled)
            }
            f_ChangeLevel(f_OrdoLevelDirectory(c.ordoFleetPower)); //get the target level based on ordo power
        }
      }
      _loc12_ += 1;
   }
}

//MAZE SYSTEM CODE

function f_MazeProcgen()
{

}

function f_UpdateWallArray()
{

}

//should only be called in orb realm, might do weird shit if any active enemies have walls
function f_SetWalls()
{
   wallArrayOb = undefined;
   wallArrayOb = new Object();
   active_walls = 0;
   var i = 1;
   while(i <= total_fx + extra_fx)
   {
      var fx = p_game["fx" + int(i)]
      if(fx.haswall)
      {
         active_walls++;
         wallArrayOb["w" + int(active_walls)] = fx;
      }
      i++;
   }
}

function f_SpawnWall(x, y, xscale, yscale, colour)
{
   var wall = f_FX(x,y,y + 1,"wall",xscale,yscale)
   wall.haswall = true;
   f_ColorSwap(wall,colour)
   f_SetWalls();
}

//———————————————————————————————————————————————————————————————————————————————————————————
//———————————————————————————————————SETTING UP ORDO FIGHT———————————————————————————————————
//——————————————————————————————————————————————————————————————————————————————————————————— 

//Returns a target level filepath based on current ordo power
//Also sets up some vars based on that
function f_OrdoLevelDirectory(ordopow)
{
   var level = undefined;
   c.battle_x = 0; //these coords will probably be used for f_TeleportToBattlesite idk, can be moved
   c.battle_y = 0;
   switch(ordopow)
   {
      case 1:
         //c.ordoBoss = "../ebeetle/ebeetle.swf";
         level = "../level20/level20.swf";
         break;
      case 2:
         level = "../level37/level37.swf";
         break;
      default:
        level = "../level39/level39.swf";
   }
   return level;
}

//Kills nonordo enemies, fucks up beefy cutscene on marsh
function f_KillNonOrdos()
{
   var i = 1;
   while(i <= active_enemies)
   {
      var e = loader.game.game["e" + int(i)];
      if(!e.ordoFighter)
      {
        e.health = 0; //ha L imagine dying
        e.gotoAndStop("hitground1")
      }
      i++;
   }
}

//Initates ordo fight, sets up vars and creates enemies
function f_InitOrdoFight(zone)
{
   nowaypoints = true;
   cinema = false; //prevent oob abuse while in combat and also fix certain pets
   c.ordoStrength = (Math.ceil(c.ordoFleetPower * 2.5) + Math.floor(c.timesGlogged * 1.5)); //power formula can be improved - maybe make timesGlogged affect enemy stats instead?
   if(total_enemies < 75)
   {
      f_CreateEnemies(75); //75 enemies threshold is chosen for reasons probably
   }
   f_TeleportToBattlesite(zone,level,c.ordoFleetPower);
   f_SetLeash(zone.x,zone.y);
   c.ordoTimer = 120; //set timer before spawning begins
   c.ordoSpawned = true;
}

//sets up vars for end of ordo fight
function f_EndOrdoFight(zone)
{
    nowaypoints = false;
    c.ordo = false;
    c.ordoIsActive = false;
    c.ordoSpawned = false;
}

//spawns the full ordo fight using while loop
//can be improved; all enemies spawned in single point is cringe (work on this once f_TeleportToBattlesite is coded)
function f_SpawnOrdoFight(zone)
{
   var _loc2_ = 1;
   while(_loc2_ < c.ordoStrength)
   {
      var _loc3_ = f_SpawnOrdo(zone.x + 300,zone.y,c.ordoFleetPower);
      //_loc3_.delay_timer = _loc2_ * 3;
      //_loc3_.gotoAndStop("lightningspawn"); //this may not work in some levels
      _loc3_.gotoAndStop("spawn")
      f_SetTargets();
      _loc2_ += 1;
   }
   if(c.allyArray == undefined)
   {
      f_InitAllyArray();
   }
   f_AddAllyToArray(_loc3_, c.ordoFleetPower - 1) //add to ally array (not unlocked though)
   //if(c.ordoBoss)
   //{
   //   f_CreateOrdoBoss(c.ordoBoss);
   //   kills_goal += 1;
   //   c.ordoBoss = undefined;
   //}
   kills_goal += c.ordoStrength;
}

//Currently in development, later should teleport player to part of level ordofight should occur in (maybe also set leash)
//May be difficult to code cause no waypoints, so could have to grab manual coords
function f_TeleportToBattlesite(zone, level, ordopow)
{
   return undefined;
}

//Spawns a single ordo enemy, type is based on the ordo power and dictates which enemy is spawned
//this will become large
function f_SpawnOrdo(x, y, type)
{
   var _loc4_ = undefined;
   switch(type)
   {
      case 1:
         _loc4_ = f_SpawnFireDemon(x,y,1); //stats here temporary for testing orbroll
         _loc4_.weapon = 83;
         _loc4_.helmet = 33;
         _loc4_.emblem = 18;
         _loc4_.random_dash_roll = 1;
         _loc4_.dash_timer = 60;
         _loc4_.magician = false;
         break;
      case 2:
         _loc4_ = f_SpawnThief(x,y,1);
         break;
      case 3:
         _loc4_ = f_SpawnBear(x,y,1);
         break;
      default:
         _loc4_ = undefined; //uhh could cause problems maybe? change to a spawnfunc later
   }
   if(_loc4_)
   {
      _loc4_.ordoFighter = true; //register that enemy is an ordo-spawn
      c.ordoIsActive = true;
      return _loc4_; //return for modifications
   }
}

//function f_CreateOrdoBoss(filepath, count)
//{
//   var depth = _root.f_GetDepthModAssignment();
//   var ordoboss = p_game.attachMovie("invisObject","e_boss",depth);
//   loadMovie("../ewizard/ewizard.swf",ordoboss);
//   ordoboss.depth_mod = depth;
//   ordoboss.active = false;
//}

//———————————————————————————————————————————————————————————————————————————————————————————
//————————————————————————————————————————ALLY CODE——————————————————————————————————————————
//——————————————————————————————————————————————————————————————————————————————————————————— 

//to make char unlock screen play
//zone.hud_pt.characterunlock = {charid};

function f_InitAllyCustomization(zone)
{
   if(c.allyEditor) //if you entered snow store after killing an ordo
   {
      c.allyArray[c.ordoFleetPower - 1].unlocked = true;
   }
   if(c.customizationInit == false)
   {
      var i = 0
      while(i <= c.allyArray.length)
      {
         if(c.allyArray[i].unlocked == true)
         {
            f_SpawnAlly(i, zone.x + (75 * i),zone.y - 50);
            i++;
         }
      }
      c.customizationInit = true;
   }
}

function f_LeaveAllyEditor(zone)
{
   c.allyEditor = false;
   f_ChangeLevel("../level44/level44.swf");
}

function f_InitAllyArray()
{
   totalAllies = 15;
   c.allyArray = new Array(15);
}

function f_AddAllyToArray(zone, type)
{
   var ally = g;
   ally.OP = 40 + int(type * 1.5); //ordnance points, different attributes with diff stats/buffs will cost diff OP to use on entity
   ally.inUse = true; //ally is used by default, can be set to false in customization menu
   ally.strength = zone.punch_pow_low / 5;
   ally.magic = zone.magic_pow / 5;
   ally.unlocked = false; //unlocked after level beat not level init
   ally.helmet = zone.helmet;
   ally.emblem = zone.emblem;
   ally.shield = zone.shield;
   ally.weapon = zone.weapon;
   ally.flag = zone.flag;
   ally.beefy = zone.beefy;
   ally.resists = zone.resists;
   ally.health_max = zone.health;
   c.allyArray[type] = ally;
}

//jank ahh function
function f_SpawnAlly(type, x, y)
{
   //c.allyArray contains copies of enemy entities from each ordo. f_MakeFriend is used to spawn the actual ally entity and then vars from the ally array are assigned to it
   var allyData = c.allyArray[type]
   var ally = f_MakeFriend(type,x,y)
   //stats
   ally.health_max = allyData.health_max;
   var i = 0;
   while(i < allyData.resists.length)
   {
      ally.resists[i] = allyData.resists[i];
      i++;
   }
   ally.strength = allyData.strength;
   ally.magic = allyData.magic;
   //attributes
   ally.helmet = allyData.helmet;
   ally.emblem = allyData.emblem;
   ally.shield = allyData.shield;
   ally.weapon = allyData.weapon;
   ally.flag = allyData.flag;
   if(allyData.beefy)
   {
      f_MakeEnemyBeefy(ally);
      ally.fp_Character = f_NPCWalk;
      ally.fp_CharacterDefault = f_NPCWalk;
   }
   ally.anti_air = allyData.anti_air;
   //more vars will be added as customization system expands
   return ally;
}

//———————————————————————————————————————————————————————————————————————————————————————————
//————————————————————————————————————————ENEMY CODE—————————————————————————————————————————
//——————————————————————————————————————————————————————————————————————————————————————————— 

//currently unused
function f_Phase(zone)
{
   zone._alpha = 0.5;
   f_ColorSwap(zone,color_purple);
}
