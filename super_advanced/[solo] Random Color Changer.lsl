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
    integer count = llGetObjectPrimCount(llGetKey()); // prims, not counting seated avatars
    if (count == 1)
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
        for (i=0; i< count; i++)
        {
            // we have to exclude seated avatars, since they're treated like
            // any other prim
            if (llGetAgentSize(llGetLinkKey(i)) == ZERO_VECTOR)
            {
            	// note that llGetLinkKey above uses i,
            	// while llSetLinkPrimitiveParamsFast uses i+1.
            	// That's because LSL uses a different offset
            	// for the llSetLink... functions. Exactly why this is
            	// remains a mystery.
                llSetLinkPrimitiveParamsFast(i + 1,
                    [PRIM_COLOR, ALL_SIDES, randomPrimarySecondaryColor(), 1.0]);
            }
        }
    }
}


default
{
    state_entry()
    {
    	// set up the timer....
        llSetTimerEvent(0.2);
    }

    timer()
    {
    	// set the random color.
        setRandomColors();
    }
}
