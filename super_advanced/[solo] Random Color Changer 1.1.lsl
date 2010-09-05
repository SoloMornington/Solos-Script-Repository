// Random Color Changer
// by Solo Mornington

// This script will rapdily change all prims to a random color

// THIS NOTICE MUST REMAIN INTACT:
// Copyright 2010, Solo Mornington
// License: Use freely in any way you want. Modified versions
// may be used in any way. No credit or acknowledgement required.
// Definitive source and updates available here:
// http://github.com/SoloMornington/Solos-Script-Repository
// ** end notice

// This script also illustrates how to do something to every prim in
// an object, even while an avatar is sitting on it.

// I'm filing this under 'super_advanced' because it's really mostly
// something meant to be modified to suit your own goals.

integer gPrimCount; // we keep this number on-hand so we don't have to
					// ask about it every 5th of a second.

vector randomPrimarySecondaryColor()
{
	// we want to generate a bright color, so
	// we'll use rounding and type conversion to
	// generate the individual elements of the vector.
    return
        <(float)llRound(llFrand(1.0)),
        (float)llRound(llFrand(1.0)),
        (float)llRound(llFrand(1.0))>;
}

setRandomColors()
{
	// gPrimCount is the global that tells us how many prims there are
    if (gPrimCount == 1)
    {
        // only one prim to deal with. If there were an 
        // llSetPrimitiveParamsFast function, we'd use it here.
        // But since there isn't, we trick llSetLinkPrimitiveParamsFast
        // into doing our work for us. Specifying LINK_SET means all
        // prims get changed.
        llSetLinkPrimitiveParamsFast(LINK_SET,
            [PRIM_COLOR, ALL_SIDES, randomPrimarySecondaryColor(), 1.0]);
    }
    else
    {
    	// more than one prim, so we loop through all the prims and set
    	// their color.
        integer i;
        for (i=1; i<= gPrimCount; ++i)
        {
        	// set the color for the prim
            llSetLinkPrimitiveParamsFast(i,
                [PRIM_COLOR, ALL_SIDES, randomPrimarySecondaryColor(), 1.0]);
        }
    }
}


default
{
    state_entry()
    {
    	// load up the prim count global...
	    gPrimCount = llGetObjectPrimCount(llGetKey());
	    // set up the timer....
        llSetTimerEvent(0.2);
    }

    timer()
    {
    	// set the random color.
        setRandomColors();
    }
    
    changed(integer what)
    {
    	// whatever changes, we just update gPrimCount
    	// this takes care of relinked objects and when
    	// an av sits down or gets up.
    	// we do this here so we're not doing it every 0.2 second
    	// through the timer event.
	    gPrimCount = llGetObjectPrimCount(llGetKey());
    }
}
