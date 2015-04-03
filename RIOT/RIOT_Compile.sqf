RIOT_DeadCiv = false; // move to a client init later on

if (isServer) then
{
  call compile preProcessFileLineNumbers "RIOT\RIOT_Functions.sqf";
  [] call RIOT_Init;
};

// Put:
// null = [] execVM "RIOT\RIOT_Compile.sqf";
// in your init.sqf