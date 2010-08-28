// Give All Inventory (Except This Script)
// by Solo Mornington

// THIS NOTICE MUST REMAIN INTACT:
// Copyright 2010, Solo Mornington
// License: Use freely in any way you want. Modified versions
// may be used in any way. No credit or acknowledgement required.
// Definitive source and updates available here:
// http://github.com/SoloMornington/Solos-Script-Repository
// ** end notice

// This script gives all the inventory contained in the object
// to whoever touches it. The items will be in a folder with the same
// name as the giver object.
// It is the big brother to the Give First Notecard script in the
// very_basic folder of this repository.
// Give All Inventory is right on the border between very_basic and
// super_advanced, so I opted for super_advanced. :-)

// This string is the text of the hover text. 

string gHoverText = "Touch for some goodies!";

default
{
    state_entry()
    {
        // Set up the hover text....
        llSetText(gHoverText, <1,1,1>, 1.0);
    }

    touch_start(integer total_number)
    {
        // First we want to find out if there's anything to give...
        integer count = llGetInventoryNumber(INVENTORY_ALL);
        // count will be at least 1, because of this script.
        if (count > 1)
        {
            // this is the list of stuff we want to hand over
            list itemsToGive;
            // and this is the name of this script
            string thisScript = llGetScriptName();
            
            // we start getting all the inventory items...
            // this is a fairly standard pattern. Loop through the
            // items, neglect to add the one we don't want. :-)
            string thisItem;
            integer i;
            for (i=0; i<count; ++i)
            {
                // what's the next item?
                thisItem = llGetInventoryName(INVENTORY_ALL, i);
                // is it the script? if not, add it to the list
                if (thisItem != thisScript) itemsToGive += [thisItem];
            }
            // ok we should have a list of stuff to hand out.
            // so we'll set up the name of the folder in the avatar's
            // inventory. We're using the object name, but this
            // could be any string.
            string folderName = llGetObjectName();
            // loop through all the touch_starts.
            // usually this is extraneous work, but it does matter.
            //
            for (i=0; i < total_number; ++i)
            {
            	// give the stuff to the avatar.
            	// we use the object name to specify a folder name
            	// in the user's inventory.
                llGiveInventoryList(llDetectedKey(i), folderName,
                    itemsToGive);
            }
        }
        else
            // There was no notecard, so tell the user.
            llSay(0, "This object has nothing to give you. Please contact its owner.");
    }
}
