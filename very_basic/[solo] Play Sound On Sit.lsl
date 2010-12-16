// Play Sound On Sit
// by Solo Mornington

// THIS NOTICE MUST REMAIN INTACT:
// Copyright 2010, Solo Mornington
// License: Use freely in any way you want. Modified versions
// may be used in any way. No credit or acknowledgement required.
// Definitive source and updates available here:
// http://github.com/SoloMornington/Solos-Script-Repository
// ** end notice

// This script will play a sound whenever anyone sits on the object.
// It can be easily modified to do something else whenever anyone sits.

integer gAvCount = 0;

avSat()
{
	// this function is the callback function that gets called
	// whenever a new av sits on the object.
	// You can change this. For now, however, it's a fart sound:
	llLoopSound("900bdb8a-a208-1c9b-c08e-c67016bf3069", 1.0);
}

avUnsat()
{
	// this function is the callback that gets called
	// whenever an av gets up off the object.
	llStopSound();
}

default
{
    state_entry()
    {
        // store the current number of avs sitting on the object.
        // llGetNumberOfPrims() returns the number of linked items, including
        // seated avatars. llGetObjectPrimCount() includes only prims. Thus
        // the difference between them is the number of seated avatars.
        gAvCount = llGetNumberOfPrims() - llGetObjectPrimCount(llGetKey());
    }
    
    changed(integer what)
    {
        if (what & CHANGED_LINK)
        {
            // either the owner edited the object, or an av got up or sat down
            // figure out the av count... see state_entry for explanation.
            integer currentAvCount = llGetNumberOfPrims() - llGetObjectPrimCount(llGetKey());
            if (currentAvCount > gAvCount)
            {
            	// the number of seated avatars has increased, so
            	// we want to do something. we'll use this callback function
            	// for modularity.
            	avSat();
            }
            else if (currentAvCount < gAvCount)
            {
            	// the number of seated avatars has decreased
            	// so we want to do something. we'll use the callback for
            	// unseated avatars....
            	avUnsat();
            }
            // regardless of whether we did the callback function,
            // we can update the global av count. this is easier
            // and probably quicker than figuring out if the new number is
            // different from the global one.
            gAvCount = currentAvCount;
        }
    }
}
