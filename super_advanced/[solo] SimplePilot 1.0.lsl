// SoloFlight
// by Solo Mornington

// This script is based on the HC-1 flight script by illume Skallagrimson
// but VERY HEAVILY MODIFIED. :-)

// we only have a position for the sit target, no rotation. it is assumed that
// this script is in the root prim of a zero-rotation object.
vector gSitTarget = <0,0,0.65>;
string gSitText = "Board"; // Text to show in the pie menu for sitting

string gAnimationName; // this will be the first animation in inventory
string gLoopSound = "mechanical flap"; // the sound to loop during flying.
key gPilot = NULL_KEY; // who's flying? (distinct from passengers)

// these are values for the vehicle motors
// they'd more properly be state-scope variable for state flying.
// https://jira.secondlife.com/browse/SVC-3297
vector linear;
vector angular;
float water_offset = 0.6;

// Defining the Parameters of the normal driving camera.
// This will let us follow behind with a loose camera.
list gDriveCam =[
        CAMERA_ACTIVE, TRUE,
        CAMERA_BEHINDNESS_ANGLE, 0.0,
        CAMERA_BEHINDNESS_LAG, 0.5,
        CAMERA_DISTANCE, 6.0,
        CAMERA_PITCH, 10.0,
        CAMERA_FOCUS_LAG, 0.05,
        CAMERA_FOCUS_LOCKED, FALSE,
        CAMERA_FOCUS_THRESHOLD, 0.0,
        CAMERA_POSITION_LAG, 0.5,
        CAMERA_POSITION_LOCKED, FALSE,
        CAMERA_POSITION_THRESHOLD, 0.0,
        CAMERA_FOCUS_OFFSET, <0,0,0>];

// lists of which prims are legs and wings, so we can do special effects
list gWingPrims;
list gLegPrims;

setVehicle()
{
    llCollisionSound("", 0.0);
    llSetVehicleType(VEHICLE_TYPE_AIRPLANE);
    // linear friction
    llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <100.0, 100.0, 100.0>);
    // uniform angular friction
    llSetVehicleFloatParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, 1.0);
    // linear motor
    llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <0.0, 0.0, 0.0>);
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, .5);
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE, 1.0);
    // angular motor
    llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, <0.0, 0.0, 0.0>);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_TIMESCALE, .2);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE, 2.0);
    // hover
    llSetVehicleFloatParam(VEHICLE_HOVER_HEIGHT, 0.0);
    llSetVehicleFloatParam(VEHICLE_HOVER_EFFICIENCY, 0.0);
    llSetVehicleFloatParam(VEHICLE_HOVER_TIMESCALE, 350.0);
    llSetVehicleFloatParam(VEHICLE_BUOYANCY, 0.981);
    // linear deflection
    llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, 0.5);
    llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_TIMESCALE, 1.0);
    // angular deflection
    llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, 0.25);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, 100.0);
    // vertical attractor
    llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 0.75);
    llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 1.0);
    // banking
    llSetVehicleFloatParam(VEHICLE_BANKING_EFFICIENCY, 0.0);
    llSetVehicleFloatParam(VEHICLE_BANKING_MIX, 1.0);
    llSetVehicleFloatParam(VEHICLE_BANKING_TIMESCALE, 360.0);
    // default rotation of local frame
    llSetVehicleRotationParam(VEHICLE_REFERENCE_FRAME, <0.0, 0.0, 0.0, 1.0>);
    // removed vehicle flags
    llRemoveVehicleFlags(VEHICLE_FLAG_NO_DEFLECTION_UP 
                        | VEHICLE_FLAG_HOVER_WATER_ONLY 
                        | VEHICLE_FLAG_HOVER_TERRAIN_ONLY 
                        | VEHICLE_FLAG_HOVER_UP_ONLY 
                        | VEHICLE_FLAG_LIMIT_MOTOR_UP 
                        | VEHICLE_FLAG_LIMIT_ROLL_ONLY);
    // set vehicle flags
    llSetVehicleFlags(VEHICLE_FLAG_HOVER_GLOBAL_HEIGHT);
}

loadLegAndWingPrims()
{
    gWingPrims = [];
    gLegPrims = [];
    integer i;
    list params;
    // use llGetObjectPrimCount() so we don't include seated avatars.
    integer count = llGetObjectPrimCount(llGetKey());
    for (i=1; i<=count; ++i)
    {
        params = llGetLinkPrimitiveParams(i, [PRIM_DESC]);
        string desc = llList2String(params, 0);
        if (desc == "leg") gLegPrims += [i];
        if (desc == "wing") gWingPrims += [i];
    }
}

newAnimationCheck()
{
    // we might have a new animation in inventory
    // and if we do, stop the old one and play the new one.
    if (gPilot != NULL_KEY)
    {
        llStopAnimation(gAnimationName);
        gAnimationName = llGetInventoryName(INVENTORY_ANIMATION, 0);
        llStartAnimation(gAnimationName);
        return;
    }
    gAnimationName = llGetInventoryName(INVENTORY_ANIMATION, 0);
}

primAlpha(list prims, float alpha)
{
    // primAlpha function sets the prims in the list to alpha alpha.
    integer i;
    integer count = llGetListLength(prims);
    for (i=0; i<count; ++i)
    {
        llSetLinkAlpha(llList2Integer(prims, i), alpha, ALL_SIDES);
    }
}

wingFlapAlpha()
{
    integer i;
    integer count = llGetListLength(gWingPrims);
    for (i=0; i<count; ++i)
    {
        if (llFrand(1.0) > 0.5)
            llSetLinkAlpha(llList2Integer(gWingPrims, i), 0.7, ALL_SIDES);
        else
            llSetLinkAlpha(llList2Integer(gWingPrims, i), 0.3, ALL_SIDES);
    }
}

default
{
	// 'default' is not a very descriptive state name, is it?
	// So we'll do some init and go to a state with a nice name, like
	// 'atRest'.
    state_entry()
    {
        // load up the exception prims
        loadLegAndWingPrims();
        // some basic initializations
        gPilot = NULL_KEY;
        newAnimationCheck();
        llSitTarget(gSitTarget, ZERO_ROTATION);
        llSetSitText(gSitText);
        state atRest;
    }
}

state atRest
{
    // state atRest is the state we should be in when the vehicle is at rest
    // just sitting there, as in we just rezzed it, or the avatar stood up from it.
    // mainly this state is responsible for going to the flying state when
    // the owner sits on the vehicle and we get all our necessary permissions.
    state_entry()
    {
        gPilot = NULL_KEY;
        // hide the wings and show the legs
        primAlpha(gWingPrims, 0.0);
        primAlpha(gLegPrims, 1.0);
        // turn off vehicle stuff.
        llSetStatus(STATUS_PHYSICS, FALSE);
        // TODO: make the vehicle right itself.
        // let the whole object know we're at rest.
        llMessageLinked(LINK_SET, 0, "flying", NULL_KEY);
    }
    
    changed(integer what)
    {
        // Whenever an av sits on or stands up from an object, it is treated as if it
        // were being linked or unlinked.
        // Unfortunately, there are a whole bunch of other things that cause CHANGED_LINK
        // as well, so we have to allow for them.
        // Things that can cause CHANGED_LINK: 1) linking in new prims, 2) unlinking prims
        // 3) avatars sitting, 4) avatars unsitting
        if (what & CHANGED_LINK)
        {
            // are there *any* seated avatars?
            if (llGetNumberOfPrims() != llGetObjectPrimCount(llGetKey()))
            {
                // we have seated avs, so let's find the sit target one
                key agent = llAvatarOnSitTarget();
                // same as the owner?
                if (agent == llGetOwner())
                {
                    // store pilot key...
                    gPilot = agent;
                    // ask politely for permission do to stuff.
                    // These will be automatically granted.
                    llRequestPermissions(agent,
                        PERMISSION_TRIGGER_ANIMATION | 
                        PERMISSION_TAKE_CONTROLS | 
                        PERMISSION_CONTROL_CAMERA);
                }
                else
                // sit target agent is not the owner
                {
                    llUnSit(agent);
                    llWhisper(0,"Only the owner can drive this vehicle.");
                }
            }
            else
            // there are no seated avatars...
            {
                if (gPilot != NULL_KEY)
                {
                    // since there are no seated avs, but we still know about 
                    // the pilot, they must have just stood up.
                    // we need to release controls and do other cleanup
                    llReleaseControls();
                    llClearCameraParams();
                    llStopAnimation(gAnimationName);
                    gPilot = NULL_KEY;
                }
            }
        }
        if (what & CHANGED_INVENTORY)
        {
            // someone might have dropped in a new animation
            newAnimationCheck();
        }
    }
    
    run_time_permissions(integer perm)
    {
        // to be correct, we really should check the perms and make sure we
        // got the ones we need. but this will usually work:
        if (perm) state flying;
    }
    
    on_rez(integer foo) { state default; }
}

state flying
{
    // state flying assumes we have permission to take controls, run animations,
    // and control the camera.
    state_entry()
    {
        // hide the legs, show the wings...
        primAlpha(gLegPrims, 0.0);
        wingFlapAlpha();
        // play the flying sound
        llLoopSound(gLoopSound, 1.0);
        llSetTimerEvent(0.05);
        llTakeControls( CONTROL_FWD |
            CONTROL_BACK |
            CONTROL_LEFT |
            CONTROL_RIGHT |
            CONTROL_ROT_LEFT |
            CONTROL_ROT_RIGHT |
            CONTROL_UP |
            CONTROL_DOWN |
            CONTROL_LBUTTON,
            TRUE, FALSE);
        setVehicle();
        llSetCameraParams(gDriveCam);
        llStartAnimation(gAnimationName);
        vector current_pos = llGetPos();
        llSetVehicleFloatParam(VEHICLE_HOVER_HEIGHT, current_pos.z);
        llSetStatus(STATUS_PHYSICS, TRUE);
        // let the rest of the object know we're flying
        llMessageLinked(LINK_SET, 0, "flying", NULL_KEY);
    }

    changed(integer what)
    {
        // Whenever an av sits on or stands up from an object, it is treated as if it
        // were being linked or unlinked.
        // Unfortunately, there are a whole bunch of other things that cause CHANGED_LINK
        // as well, so we have to allow for them.
        // Things that can cause CHANGED_LINK: 1) linking in new prims, 2) unlinking prims
        // 3) avatars sitting, 4) avatars unsitting
        if (what & CHANGED_LINK)
        {
            // are there *any* seated avatars?
            if (llGetNumberOfPrims() == llGetObjectPrimCount(llGetKey()))
            {
                // there are no seated avatars...
                if (gPilot != NULL_KEY)
                {
                    // since there are no seated avs, but we still know about 
                    // the pilot, they must have just stood up, so let's rest.
                    state atRest;
                }
            }
        }
        if (what & CHANGED_INVENTORY)
        {
            newAnimationCheck();
        }
    }
    
    // The control event is what we get when the user mashed down the keys
    // we asked about in llTakeControls().
    control(key id, integer levels, integer edges)
    {
        if(llGetStatus(STATUS_PHYSICS)!=TRUE)
            llSetStatus(STATUS_PHYSICS, TRUE);
            
        if ((edges & levels & CONTROL_UP)) {
            linear.z += 12.0;
        } else if ((edges & ~levels & CONTROL_UP)) {
            linear.z -= 12.0;}
        if ((edges & levels & CONTROL_DOWN)) {
            linear.z -= 12.0;
        } else if ((edges & ~levels & CONTROL_DOWN)) {
            linear.z += 12.0;}
        if ((edges & levels & CONTROL_FWD)) {
            linear.x += 14.0;
        } else if ((edges & ~levels & CONTROL_FWD)) {
            linear.x -= 14.0;}
        if ((edges & levels & CONTROL_BACK)) {
            linear.x -= 14.0;
        } else if ((edges & ~levels & CONTROL_BACK)) {
            linear.x += 14.0;}
        if ((edges & levels & CONTROL_LEFT)) {
            linear.y += 8.0;
        } else if ((edges & ~levels & CONTROL_LEFT)) {
            linear.y -= 8.0;}
        if ((edges & levels & CONTROL_RIGHT)) {
            linear.y -= 8.0;
        } else if ((edges & ~levels & CONTROL_RIGHT)) {
            linear.y += 8.0;}
        if ((edges & levels & CONTROL_ROT_LEFT)) {
            angular.z += (PI / 180) * 55.0;
            angular.x -= PI * 4;
        } else if ((edges & ~levels & CONTROL_ROT_LEFT)) {
            angular.z -= (PI / 180) * 55.0;
            angular.x += PI * 4;} 
        if ((edges & levels & CONTROL_ROT_RIGHT)) {
            angular.z -= (PI / 180) * 55.0;
            angular.x += PI * 4;
        } else if ((edges & ~levels & CONTROL_ROT_RIGHT)) {
            angular.z += (PI / 180) * 55.0;
            angular.x -= PI * 4;
        }
    }

    timer()
    {
        wingFlapAlpha();
        vector vel = llGetVel();
        float water = llWater(vel * 0.05);
        float ground = llGround(vel * 0.05);
        if (water > ground)  {  // above water
             vector MahPos = llGetPos();
             if (MahPos.z < water+water_offset){
                 llSetVehicleFloatParam(VEHICLE_HOVER_EFFICIENCY, 0.5);
                 llSetVehicleFloatParam(VEHICLE_HOVER_TIMESCALE, 0.1);
                 llSetVehicleFloatParam(VEHICLE_HOVER_HEIGHT, water + water_offset);
             }
             else {
                 llSetVehicleFloatParam(VEHICLE_HOVER_EFFICIENCY, 0.0);
                 llSetVehicleFloatParam(VEHICLE_HOVER_TIMESCALE, 350.0);
             }
        }
        else { // above ground
             llSetVehicleFloatParam(VEHICLE_HOVER_EFFICIENCY, 0.0);
             llSetVehicleFloatParam(VEHICLE_HOVER_TIMESCALE, 350.0);
        }
        
        llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, linear);
        llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular);
    }

    state_exit()
    {
        // we need to release controls and do other cleanup
        llStopSound();
        llReleaseControls();
        llClearCameraParams();
        llStopAnimation(gAnimationName);
    }

    on_rez(integer foo) { state default; }
}
