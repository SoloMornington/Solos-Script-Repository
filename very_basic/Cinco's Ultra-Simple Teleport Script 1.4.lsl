// Cinco's Teleporter 1.3
// 
// a very basic teleporter script by Cinco Pizzicato, totally ripped and mangled from
// Teleporter Script  v 3.0 by Asira Sakai
//
// also uses WarpPos, which you should already know about if you do any LSL coding.
// http://lslwiki.net/lslwiki/wakka.php?wakka=LibraryWarpPos
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

// 4) This script really should be compiled as Mono, so warpPos
// doesn't cause a heap error.

vector gHomeVector; // where I should go back; updated every teleport

warpPos(vector pos)
{
    // by Riden Blaisdale, source: http://lslwiki.net/lslwiki/wakka.php?wakka=LibraryWarpPos
    list rules;
    integer num = llRound(llVecDist(llGetPos(),pos)/10)+1;
    integer x;
    for(x=0; x<num; ++x) rules=(rules=[])+rules+[PRIM_POSITION,pos];
    llSetPrimitiveParams(rules);
}

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
                    warpPos(targetVector);  // teleport to selected coordinates
                    llUnSit(llAvatarOnSitTarget()); // unsit him
                    warpPos(gHomeVector);  // teleport back to old position
                    llSetStatus(STATUS_PHANTOM,FALSE);
                }
                else llOwnerSay("Bad, bad vector.");
            }
            // if someone links the object, we reset the script.
            else llResetScript();
        }
    }
}
