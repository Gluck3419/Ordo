function f_UpdateCamera(zone)
{
   f_UpdateScrollZoom(zone);
   if(zone.shake > 0)
   {
      zone.shake -= 1;
      zone.rot = zone.a_shake[zone.shake] * (zone.scale / 100) * zone.shake_intensity;
   }
   var _loc2_ = 1;
   while(_loc2_ <= 4)
   {
      var _loc3_ = loader.game.game["p" + int(_loc2_)];
      if(_loc3_.alive)
      {
         f_LevelChecks(_loc3_);
      }
      _loc2_ += 1;
   }
   _loc2_ = 1;
   while(_loc2_ <= active_enemies)
   {
      _loc3_ = loader.game.game["e" + int(_loc2_)];
      if(_loc3_.alive)
      {
         f_EnemyChecks(_loc3_);
      }
      _loc2_ += 1;
   }
}
function f_EnemyDashInit(zone)
{
   f_EnemyDashSpeed(zone);
   if(zone.x > main.right or zone.x < main.left)
   {
      zone.dash_length = random(30) + 10;
   }
   else
   {
      zone.dash_length = random(15) + 10;
   }
   zone.dashing = true;
   if(random(zone.random_dash_roll) == 0 and !zone.beefy)
   {
      zone.dash_length *= 0.5;
      zone.invincible_timer = zone.dash_length;
      zone.dash_speed_x *= 2;
      zone.dash_speed_y = 0;
      if(zone.ordoFighter)
      {
        zone.gotoAndStop("orbroll");
      }
      else
      {
        zone.gotoAndStop("roll");
      }
   }
   else
   {
      zone.gotoAndStop("dash");
   }
}
function f_WeaponStats(zone, num)
{
   zone.weapon_strength = 0;
   zone.weapon_defense = 0;
   zone.weapon_magic = 0;
   zone.weapon_agility = 0;
   zone.weapon_critical = 0;
   zone.weapon_magic_type = 0;
   zone.weapon_magic_chance = 0;
   if(!zone.e_type)
   {
      switch(num)
      {
         case 85:
            break;
         case 84:
            zone.weapon_strength = 7;
            zone.health_max = 500;
            if(zone.health < zone.health_max)
            {
               zone.health += 2;
            }
            else
            {
               zone.health = zone.health_max;
            }
            break;
         case 83:
            zone.weapon_strength = 6;
            zone.weapon_magic = 5;
            zone.weapon_defense = 7;
            zone.weapon_magic_type = 3;
            zone.weapon_magic_chance = 100;
      }
   }
}
function f_RemovePlayer(zone)
{
   f_RemoveShadow(zone);
   zone.active = false;
   zone.gotoAndStop("blank");
   if(console_version)
   {
      if(zone.human and zone.hud_pt)
      {
         LOGPush(10,0,zone.hud_pt.port);
      }
      zone.hud_pt.gotoAndStop("wait");
      var _loc5_ = false;
      var _loc2_ = 1;
      while(_loc2_ <= active_players)
      {
         var _loc3_ = playerArrayOb["p_pt" + int(_loc2_)];
         if(_loc3_.alive)
         {
            _loc5_ = true;
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      if(!_loc5_)
      {
         f_EndOrdoFight(zone);
         _root.f_ChangeLevel("../level44/level44.swf");
      }
   }
   else
   {
      zone.hud_pt.gotoAndStop("press_start");
      zone.hud_pt.p_type = 0;
      zone.hud_pt.player_pt = undefined;
   }
}
function f_CreatePlayers()
{
   var _loc2_ = 1;
   while(_loc2_ <= 31)
   {
      var _loc3_ = f_GetDepthModAssignment();
      var _loc1_ = p_game.attachMovie("invisObject","p" + int(_loc2_),_loc3_);
      loadMovie("../player/player.swf",_loc1_);
      _loc1_.depth_mod = _loc3_;
      _loc1_.active = false;
      _loc2_ = _loc2_ + 1;
   }
}
function f_NewFriendNum()
{
   var i = 5;
   while(i <= 31)
   {
      var p = loader.game.game["p" + i];
      if(!p.active)
      {
         return i;
      }
      i += 1;
   }
}

