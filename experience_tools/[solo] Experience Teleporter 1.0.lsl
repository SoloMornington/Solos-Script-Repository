// Experience-based Teleporter
// by Solo Mornington

// THIS NOTICE MUST REMAIN INTACT:
// Copyright 2018, Solo Mornington
// License: Use freely in any way you want. Modified versions
// may be used in any way. No credit or acknowledgement required.
// Definitive source and updates available here:
// http://github.com/SoloMornington/Solos-Script-Repository
// ** end notice

// This script uses an existing Experience to request permissions to teleport
// an avatar to a destination when they walk into the object containing it.

// Learn about Experience tools here:
// http://wiki.secondlife.com/wiki/Category:Experience_Tools

// It's based on sample code from here:
// http://wiki.secondlife.com/wiki/LlRequestExperiencePermissions

// To use:
// Set up your Experience.
// Rez a prim.
// Set the name of the prim to the hovertext you want.
// Set the description of the prim to the coordinates and facing location you
// want, as two vectors, like this: <128,128,30>&<0,0,0>
// Add this script to the prim inventory.
// Edit the script.
// Check the 'Use Experience' checkbox and set the Experience you prefer.
// Save the script, so that it compiles.
// Walk into the prim. You are teleported!

// Some users might not be familiar with the experience tools. In those cases
// we can teleport them when they sit.

default
{
    state_entry()
    {
        // Put the object name in the hover text.
        llSetText(llGetObjectName(), <1.0,1.0,1.0>, 1.0);
        // Make the prim phantom so the avatar can walk through it.
        llVolumeDetect(TRUE);
        llSitTarget(<0.0,0.0,0.1>, ZERO_ROTATION);
        llSetSitText("Teleport");
        llUnSit(llAvatarOnSitTarget());
    }

    collision_start(integer number_of_collisions)
    {
        integer i;
        for(i=0; i < number_of_collisions; i++)
        {
            llRequestExperiencePermissions(llDetectedKey(i), "");
        }
    }

    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {  // if a link change occurs (sit or unsit)
            key av = llAvatarOnSitTarget();
            if(av != NULL_KEY) {
                llRequestExperiencePermissions(av, "");
            }
        }
    }

    experience_permissions(key target_id)
    {
        string object_desc = llGetObjectDesc();
        // Use & separator because you can't put | in an object description.
        list desc_list = llParseString2List(object_desc, ["&"], []);
        // (vector)llList2String(src, index);
        vector target_vector = (vector)llList2String(desc_list, 0);
        if (target_vector != ZERO_VECTOR) {
            vector target_facing = (vector)llList2String(desc_list, 1);
            llUnSit(llAvatarOnSitTarget());
            llTeleportAgent(target_id, "", target_vector, target_facing);
        }
    }
}
