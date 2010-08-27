// Walk-Thru Play Sound
// by Solo Mornington

// THIS NOTICE MUST REMAIN INTACT:
// Copyright 2010, Solo Mornington
// License: Use freely in any way you want. Modified versions
// may be used in any way. No credit or acknowledgement required.
// Definitive source and updates available here:
// http://github.com/SoloMornington/Solos-Script-Repository
// ** end notice

// This is a dead-simple script. :-)
// It will turn the object phantom and play a sound when an avatar travels through
// the object. This demonstrates the way llVolumeDetect works.

// llVolumeDetect turns the object phantom, and changes the way the collision
// events work. Normally they respond to objects or avatars colliding with the
// sides of an object. With llVolumeDetect set to be true, the events fire
// when an object or avatar is detected within the volume of the scripted object.

// this is a constant to hold the name or UUID of the sound to play
// if you leave it as "", the first sound in inventory
// will be used. Or change it to whichever sound you prefer.
string gSound = "";

default
{
    state_entry()
    {
        if (gSound == "")
        {
            gSound = llGetInventoryName(INVENTORY_SOUND, 0);
        }
        // if there is no sound to play, even after looking in inventory,
        // then we don't want to set up volume detect.
        if (gSound != "")
	        llVolumeDetect(TRUE); // Starts llVolumeDetect, sets object to be phantom
    }
    
    collision_start(integer total_number)
    {
    	
    	// first things first... we have to set up a loop for all the
    	// collisions that could have fired this event.
    	integer i;
    	for (i=0; i < total_number; ++i)
    	{
    		// we only want to play the sound for avatars
    		if (llDetectedType(i) == AGENT)
    		{
    			llPlaySound(gSound, 1.0);
    			// but we also only want to play it once per event.
    			return;
    		}
	    }
    }
}
