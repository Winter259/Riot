// RIOT functions v0.1
#define RIOT_DEAD_CIV_LIMIT 3
#define RIOT_VERSION 0.1
#define RIOT_START_DELAY 4

RIOT_Init =
{
  RIOT_DeadCivCount = 0;
  RIOT_CivHostile = false;
  waitUntil
  {
    sleep 2;
    hull_isInitialized;
  };
  waitUntil
  {
    sleep 2;
    adm_isInitialized;
  };
  sleep RIOT_START_DELAY; // waits for civs to spawn
  [] call RIOT_InitAllCivs;
  [] call RIOT_AssignEH_DeadCivCountCheck;
  hint format ["RIOT Functions version %1 succesfully compiled",RIOT_VERSION];
  [-1, {hint format _this;}, ["RIOT Functions version %1 succesfully compiled",RIOT_VERSION]] call CBA_fnc_globalExecute;
};

RIOT_InitAllCivs =
{
 {
    _x call RIOT_InitCiv;
  } forEach allUnits;
};

RIOT_InitCiv =
{
  // Unit is passed as the only parameter
  _this allowFleeing 0;
  _this setSkill 0.2;
  _this call RIOT_Assign_DeadCivEH;
};

RIOT_IsCiv =
{
  private "_civilian";
  if ((side _this == civilian) && (_this isKindOf "Man")) then
  {
    _civilian = true;
  }
  else
  {
    _civilian = false;
  };
  _civilian;
};

RIOT_Assign_DeadCivEH =
{
  // Unit is passed as the only parameter
  if (_this call RIOT_IsCiv) then
  {
    _this addMPEventHandler  ["mpkilled",
      {
        RIOT_DeadCiv = true;
        publicVariableServer "RIOT_DeadCiv";
      }
    ];
  };
};

RIOT_AssignEH_DeadCivCountCheck =
{
  "RIOT_DeadCiv" addPublicVariableEventHandler {
    diag_log format ["RIOT: A civilian was killed!"];
    RIOT_DeadCivCount = RIOT_DeadCivCount + 1;
    diag_log format ["RIOT: New Dead Civ Count: %1",RIOT_DeadCivCount];
    [-1, {hint format _this;}, ["DEBUG: Dead Civ Count: %1",RIOT_DeadCivCount]] call CBA_fnc_globalExecute;
    hint format ["DEBUG: Dead Civ Count: %1",RIOT_DeadCivCount];
    if (((RIOT_DeadCivCount / 2) >= RIOT_DEAD_CIV_LIMIT) && (!RIOT_CivHostile)) then // hacky fix: div by 2 since EH triggers twice per civ for some reason.
    {
       [] spawn RIOT_MakeCivsHostile;
    };
  };
};

RIOT_MakeCivsHostile =
{
  // Current Civ Dead Count is the only parameter
  RIOT_CivHostile = true;
  publicVariable "RIOT_CivHostile";
  hint format ["DEBUG: CIVILIANS TURNING HOSTILE!"];
  [-1, {hint format _this;}, ["DEBUG: CIVILIANS TURNING HOSTILE!"]] call CBA_fnc_globalExecute;
  // Make Civs unfriendly to blufor
  civilian setFriend [west, 0];
  // Assign all Civilian units gear
  {
    if (_x call RIOT_IsCiv) then
    {
     _x call RIOT_AssignCivGear;
      hint format ["DEBUG: Assigned gear to %1",_x];
      [-1, {hint format _this;}, ["DEBUG: Assigned gear to %1",_x]] call CBA_fnc_globalExecute;
      sleep 0.5;
    };
  } forEach allUnits;  
};

RIOT_AssignCivGear =
{
  for "_i" from 0 to 4 do
  {
    _this addMagazine "64Rnd_9x19_Bizon";
  };
  _this addWeapon "bizon";
};