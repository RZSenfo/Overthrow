
OT_allJobs = [];
{
    private _code = gettext (_x >> "condition");
    private _target = gettext (_x >> "target");
    private _script = gettext (_x >> "script");
    private _repeat = getnumber (_x >> "repeatable");
    private _chance = getnumber (_x >> "chance");

    OT_allJobs pushback [configName _x, _target, compileFinal _code, compileFinal preprocessFileLineNumbers _script, _repeat, _chance];
}foreach("true" configClasses ( configFile >> "CfgOverthrowMissions" ));

while {sleep OT_jobWait;true} do {
    {
        _x call {
            params ["_name","_target","_condition","_code","_repeat","_chance"];
            private _jobdef = _this;

            private _completed = server getVariable "OT_completedJobIds";
            if(isNil "_completed") then {
                server setVariable ["OT_completedJobIds",[],false];
                _completed = server getVariable "OT_completedJobIds";
            };
            private _activeJobs = spawner getVariable ["OT_activeJobIds",[]];

            if(_target == "Global") exitWith {
                private _id = _name;
                if((random 100) < _chance) then {
                    private _numAbandoned = count(server getVariable ["NATOabandoned",[]]);
                    if(([_numAbandoned] call _condition) && !(_id in _completed) && !(_id in _activeJobs)) then {
                        _activeJobs pushback _id;
                        spawner setVariable ["OT_activeJobIds",_activeJobs,false];
                        [_id,_jobdef,[_x]] spawn OT_fnc_assignJob;
                    };
                };
            };

            if(_target == "Town") exitWith {
                if((random 100) < _chance) then {
                    {
                        private _id = format["%1-%2",_name,_x];
                        private _stability = server getVariable [format["stability%1",_x],100];
                        private _loc = server getVariable _x;
                        private _inSpawnDistance = _loc call OT_fnc_inSpawnDistance;
                        if(([_inSpawnDistance,_stability] call _condition) && !(_id in _completed) && !(_id in _activeJobs)) exitWith {
                            private _activeJobs = spawner getVariable ["OT_activeJobIds",[]];
                            _activeJobs pushback _id;
                            spawner setVariable ["OT_activeJobIds",_activeJobs,false];
                            [_id,_jobdef,[_x]] call OT_fnc_assignJob;
                        };                        
                    }foreach(OT_allTowns);
                };
            };

            if(_target == "Faction") exitWith {
                if((random 100) < _chance) then {
                    private _done = false;
                    {
                        _x params ["_cls"];
                        private _pos = server getVariable [format["factionrep%1",_cls],[]];
                        private _town = "";
                        if(count _pos > 0) then {
                            private _standing = server getVariable [format["standing%1",_cls],0];
                            private _inSpawnDistance = _pos call OT_fnc_inSpawnDistance;
                            private _town = _pos call OT_fnc_nearestTown;
                            private _id = format["%1-%2",_name,_cls];

                            if(
                                ([_inSpawnDistance, _standing] call _condition) && !(_id in _completed) && !(_id in _activeJobs)
                            ) then {
                                private _activeJobs = spawner getVariable ["OT_activeJobIds",[]];
                                _activeJobs pushback _id;
                                spawner setVariable ["OT_activeJobIds",_activeJobs,false];
                                [_id,_jobdef,[_cls]] call OT_fnc_assignJob;
                                _done = true;
                            };
                        };
                        if(_done) exitWith {};
                    }foreach(OT_allFactions);
                };
            };
        };
        sleep 0.2;
    }foreach(OT_allJobs);
};
