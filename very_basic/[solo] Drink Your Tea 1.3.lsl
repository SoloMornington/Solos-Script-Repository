// Drink Your Tea
// by Solo Mornington

// Based on a script called Drink by Francis Chung
// Gutted and gussied-up by Solo Mornington in June, 2008
// If you improve this, please let me know how. :-)

// This is basically a tiny, limited animation overrider.

// IMPROVEMENTS: Will not sip while doing things you wouldn't sip during, such as
// moving around (either flying or walking), typing, etc.

// I use gVariableName as a coding convention for global variables.
// It makes them instantly recognizeable.

// Here's a global list of animation states we are concerned with:

list gReplaceTheseAnimations = ["Sitting", "Sitting on Ground", "Standing", "Hovering"];

default
{
    state_entry()
    {
    	// first things first: we ask for permission to trigger animations
    	// and also permission to take controls.
    	// we ask for controls because if we don't register a control,
    	// this script will stop working in no-script areas.
        llRequestPermissions(llGetOwner(),PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS);
    }

    run_time_permissions(integer parm)
    {
    	// it's pretty much a given than we'll get the permissions that we want,
    	// but this code makes it clear what we're doing:
        if(parm & PERMISSION_TRIGGER_ANIMATION)
        {
			// we got permission to trigger animations, so we start the 'drinking' animation
			// and set the timer event which will play the 'sipping' animation.
			llSetTimerEvent(23.0);
			llStartAnimation("drink");
        }
        if (parm & PERMISSION_TAKE_CONTROLS)
        {
            // we only want to take control so the script keeps working in no-script areas.
            // so we don't accept anything and pass on everything
            llTakeControls(CONTROL_ML_LBUTTON, FALSE, TRUE);
        }
    }

    on_rez(integer st)
    {
    	// when the object is rezzed, we want to be sure to reset our permissions
    	// and ask for them again, so the proper animations will be playing.
        llResetScript();
    }

    changed(integer c)
    {
    	// changed is fired for a lot of different reasons, all of them
    	// good reasons to reset this script. If we were filtering any out
    	// we'd be sure and include CHANGED_TELEPORT, because the sim we'd TPd
    	// to wouldn't know what animations to be playing.
    	llResetScript();
	}

    attach(key id)
    {
    	// when the object is detached, this is our last chance to stop
    	// the holding-a-cup animation.
        llStopAnimation("drink");
    }
    
    timer()
    {
    	// The timer event is where we play the 'sipping' animation.
    	// But we don't always want to play it, because sometimes
    	// the av might be in situations where no one would take a
    	// sip of anything, like falling or typing.
        // We want to rule out all the possibilities that we can
        // using llGetAgentInfo(), because bitwise math is very quick.
        integer agentInfo = llGetAgentInfo(llGetPermissionsKey());

        // check for walking, typing, crouching and (away)...
        if (agentInfo & (AGENT_WALKING | 
                        AGENT_TYPING | 
                        AGENT_CROUCHING |
                        AGENT_AWAY )) return;
        // check for falling, jumping, or being launched through the air
        if ((agentInfo & AGENT_IN_AIR) && !(agentInfo & AGENT_FLYING)) return;

        // get the current animation state
        // we cast this as a list so it's easier to compare
        list animationState = [llGetAnimation(llGetPermissionsKey())];

        // If the current animation state is in our list, then we're good.
        // This type of list manipulation is a very common LSL coding pattern.
        if (llListFindList(gReplaceTheseAnimations, animationState) != -1)
        {
            llStartAnimation("sipping sl");
        }
    }
}
