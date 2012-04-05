// Cinco's Teleporter 1.3
// 

// THIS NOTICE MUST REMAIN INTACT:
// Copyright 2010, Cinco Pizzicato
// License: Use freely in any way you want. Modified versions
// may be used in any way. No credit or acknowledgement required.
// Definitive source and updates available here:
// http://github.com/SoloMornington/Solos-Script-Repository
// ** end notice

// a very basic teleporter script by Cinco Pizzicato, totally ripped and mangled from
// Teleporter Script  v 3.0 by Asira Sakai
//
// no notecards, no hard-coding. HOW TO:

// 1) The name of the prim will be it's hover text.

// 2) The description of the prim will be the destination vector.
// you can find the text to put in the description by rezzing a cube
// where you want to end up. Put this script into it:
//
// default{state_entry(){llOwnerSay((string)llGetPos());}}
//
// then copy the chat text you see into the teleport prim's description.

// 3) You'll probably need to make another prim for the return voyage.

// updates for v.2.0: Now using the new llSetRegionPos() function.
// http://wiki.secondlife.com/wiki/LlSetRegionPos

vector gHomeVector; // where I should go back; updated every teleport

default
{
    state_entry()
    {
        // basic init stuff
        // put the object name in the hover text
        llSetText(llGetObjectName(), <1.0,1.0,1.0>, 1.0);
        // set a sit target... we have to do this to trigger
        // a changed event
        llSitTarget(<0.0,0.0,0.1>, ZERO_ROTATION);
        // and a nice sit text, which is completely ignored by viewer 2.
        llSetSitText("Teleport");
        // make sure no one's sitting.....
        llUnSit(llAvatarOnSitTarget()); 
    }

    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {  // if a link change occurs (sit or unsit)
            if(llAvatarOnSitTarget() != NULL_KEY)
            {
                vector targetVector = (vector)llGetObjectDesc(); // where are we headed?
                if (targetVector != ZERO_VECTOR)
                {
                    llSetStatus(STATUS_PHANTOM,TRUE);
                    gHomeVector = llGetPos();  // record current position for return
                    if (llSetRegionPos(targetVector))
                    {
                    	// the teleporter moved to the target
	                    llUnSit(llAvatarOnSitTarget()); // unsit him
	                    llSetRegionPos(gHomeVector);  // teleport back to old position
                    }
                    else
                    {
                    	// teleporter didn't go where it should have.
	                    llUnSit(llAvatarOnSitTarget()); // unsit him
		                llOwnerSay("This teleporter was unable to move to the destination.");
                    }
                    llSetStatus(STATUS_PHANTOM,FALSE);
                }
                else llOwnerSay("This teleporter has a bad destination in its description.");
            }
            // if someone links the object, we reset the script.
            else llResetScript();
        }
    }
}
