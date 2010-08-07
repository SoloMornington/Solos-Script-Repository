// Thrower
// by Solo Mornington

// This script is in memory of the late lamented Brooklyn is Watching project.

// This script allows the user to throw items. The items are in the object
// inventory. The script cycles through all items. The items will have to
// be physical, and should be temp, so they won't make the whole place
// terrible and cluttered with physical junk that no one really wants. :-)

// After throwing, the thrower object disappears and the 'holding' animation
// stops. After a few seconds, it reappears. This gives the impression of
// having actually thrown the object.

// The script needs two animations, named here:

string gHoldingAnimation = "bombhold";
string gThrowingAnimation = "bombthrow";

integer gCurrentObject = -1;

do_throw()
{
	// This function does the actual rezzing of the projectile.
	// The math here is taken out of Ben Linden's Popgun object from
	// the Library.
    rotation rot = llGetRot();
    vector fwd = llRot2Fwd(rot);
    vector pos = llGetPos();
    pos = pos + fwd;
    pos.z += 0.75;                  //  Correct to eye point
    fwd = fwd * 15.0;
    
    ++gCurrentObject;
    if (gCurrentObject >= llGetInventoryNumber(INVENTORY_OBJECT))
        gCurrentObject = 0;
    string projectile = llGetInventoryName(INVENTORY_OBJECT, gCurrentObject);
    llRezObject(projectile, pos, fwd, rot, 2); 
}

default
{
    // get started with the permissions.
    state_entry()
    {
        llRequestPermissions(llGetOwner(),  PERMISSION_TRIGGER_ANIMATION |
            PERMISSION_TAKE_CONTROLS | PERMISSION_ATTACH);
    }
    
    run_time_permissions(integer permissions)
    {
        if (permissions > 0)
        {
        	// OK, we have permission, so take over the mouselook button click
            llTakeControls(CONTROL_ML_LBUTTON, TRUE, FALSE);
            if (!llGetAttached())
            {
            	// ...and if we're not attached, try to attach to the avatar's
            	// right hand.
                llAttachToAvatar(ATTACH_RHAND);
            }
            else
            {
            	// all is well so go to 'holding.'
                state holding;
            }
        }
    }

    attach(key attachedAgent)
    {
        if (attachedAgent != NULL_KEY)
        {
        	// if we were able to attach to the avatar, go to 'holding.'
            state holding;
        }
    }
    
    on_rez(integer foo)
    { llResetScript(); }
}

state holding
{
    // standing around ready to throw
    
    state_entry()
    {
        // if we're in this state we have permissions
        // we've taken controls
        // and the object is attached
        // so show the 'holding' animation.
        llStartAnimation(gHoldingAnimation);
    }
    
    control(key name, integer levels, integer edges) 
    {
    	// this inelegant code tells us whether the user pressed
    	// the mouselook button.
        if (  ((edges & CONTROL_ML_LBUTTON) == CONTROL_ML_LBUTTON)
            &&((levels & CONTROL_ML_LBUTTON) == CONTROL_ML_LBUTTON) )
        {
            {
	            // and they did press the mouselook button, so it's
	            // time for 'throwing.'
	            state throwing;
            }
        }
    }
    
    state_exit()
    {
    	// any time we leave this state we should stop the holding anim.
        llStopAnimation(gHoldingAnimation);
    }

    on_rez(integer foo)
    { state default; }
}

state throwing
{
    // doing the actual throw
    
    state_entry()
    {
    	// show the 'throwing' animation
        llStartAnimation(gThrowingAnimation);
        // let the arm do the throw before rezzing. adjust as needed.
        llSetTimerEvent(0.25);
        // you can preload a sound here, so it's ready when the
        // projectile needs it
        //llPreloadSound("2e3fa950-4e09-1741-a826-54366c9b65a1");
    }
    
    timer()
    {
        // rez projectile...
        do_throw();
        // hide the object in hand
        llSetLinkAlpha(LINK_SET, 0.0, ALL_SIDES);
        // stop for a while.
        state snooze;
    }
    
    on_rez(integer foo)
    { state default; }
}

state snooze
{
    // the time between the end of the throw and
    // when the next ornament appears in av's hand
    state_entry()
    {
    	// stop the throwing animation
        llStopAnimation(gThrowingAnimation);
        llSetTimerEvent(2.0);
    }
    timer()
    {
    	// ok, reload....
        llSetLinkAlpha(LINK_SET, 1.0, ALL_SIDES);
        // and go back to 'holding.'
        state holding;
    }
}
