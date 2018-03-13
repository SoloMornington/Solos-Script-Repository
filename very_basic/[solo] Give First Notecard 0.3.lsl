// [solo] Give First Notecard 0.3

// THIS NOTICE MUST REMAIN INTACT:
// Copyright 2010, Solo Mornington
// License: Use freely in any way you want. Modified versions
// may be used in any way. No credit or acknowledgement required.
// Definitive source and updates available here:
// http://github.com/SoloMornington/Solos-Script-Repository
// ** end notice

// The most complete and correct notecard giver script ever. :-)
// Now there's no excuse for script errors when someone clicks
// for a notecard.

// TO USE: Place this script in an object. Place a notecard in the object.
// When a resident clicks on ('touches') the object, they will be given
// the notecard.

// Please uncheck 'Mono' when you compile. Be nice to everyone on the sim.

// Change the following line to alter the hovertext displayed.

string gHoverText = "Touch for informative notecard.";

default
{
    state_entry()
    {
        // Set up the hover text....
        //llSetText(gHoverText, <1,1,1>, 1.0);
    }

    touch_start(integer total_number)
    {
        // Get the name of the first notecard
        string notecard = llGetInventoryName(INVENTORY_LANDMARK, 0);
        // If the name isn't empty....
        if (notecard != "")
        {
            // loop through all the touch_starts.
            // usually this is extraneous work, but it does matter.
            integer i;
            for (i=0; i < total_number; ++i)
            {
                llGiveInventory(llDetectedKey(i), notecard);
            }
        }
        else
            // There was no notecard, so tell the user.
            llSay(0, "There is no landmark to give. Please contact the owner of this object.");
    }
}
