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

// UPDATE: v.20 has some basic usability improvements. It imposes a few
// rules for the benefit of anyone who has to maintain a giver kiosk:
// * If you add a script to the object inventory, it will warn you
//   that this is a bad idea.
// * All inventory items will be checked for copy/trans permissions.
//
// The giver script will still give objects even if these checks don't
// pass. Changing the object inventory will cause the checks to be
// performed again.

// This string is the text of the hover text. 

string gHoverText = "Touch for some goodies!";

default
{
	// 'default' is a vague name, so we just switch right over to
	// state 'error check.'
	state_entry()
	{
		state errorCheck;
	}
}

state errorCheck
{
	// state errorCheck is where we make sure the object inventory
	// is reasonably error-free.
	// We don't want to distribute scripts, and we want kiosk
	// items to be copiable and transferrable.
	// This state is fairly linear, so it will all occur in
	// the state_entry event.
	state_entry()
	{
		// first check for scripts
		// we get a count of scrips in this object
        integer count = llGetInventoryNumber(INVENTORY_SCRIPT);
        // there should be one script (this one). any more than that
        // is a bad idea.
        if (count > 1)
        {
            llOwnerSay("It's a terrible idea to distribute scripts through a kiosk. Please remove scripts other than '" + llGetScriptName() + "' and try again. (Copying and pasting a script to a notecard is a reasonable way to work around this.)");
            state vend;
        }
        // next we check for permissions on each item.
        // we're interested in copy and trans, so we'll set up a variable for that
		integer PERM_COPYTRANS = (PERM_COPY | PERM_TRANSFER);
		// some variables we'll need...
        integer ownerPerms;
        string itemName;
        list badPerms;
        integer i;
        // we want to get this script's name, so we can exclue it from
        // the permission check.
        string scriptName = llGetScriptName();
        // how many items in inventory?
        count = llGetInventoryNumber(INVENTORY_ALL);
        // we loop through all the items.
        for (i=0; i<count; ++i)
        {
        	// gather the name of an item...
            itemName = llGetInventoryName(INVENTORY_ALL, i);
            // we don't want to include this script in the check
            if (itemName != scriptName)
            {
            	// ok, we want to find out if the current owner has copy/trans
            	// permissions. so we query for the item, with MASK_OWNER.
                ownerPerms = llGetInventoryPermMask(itemName, MASK_OWNER);
                // ownerPerms now has a bitmap of which perms the owner has.
                // since we want to make sure it has the PERM_COPYTRANS bits,
                // we have to do this rather strange-looking logic:
                if (! ((ownerPerms & PERM_COPYTRANS) == PERM_COPYTRANS))
                {
                	// OK, so this item does not have copy or trans for the
                	// current owner, so we put it in the badPerms list.
                    badPerms += [itemName];
                }
            }
        }
        // we've looped through all the inventory items, and put the 'bad' ones
        // in the badPerms list. Now we tell the user about the bad ones.
        // It's easy to check if there are any bad objects, because if there
        // aren't, badPerms won't have any items in it. so our first question is:
        // how many items in that list?
        count = llGetListLength(badPerms);
        if (count > 0)
        {
	        // more than none, so we have to tell the user.
            llOwnerSay("You do not have copy/trans permission for the following items: " + llDumpList2String(badPerms, ", "));
            state vend;
        }
        // OK so if we made it this far, there's probably nothing wrong with
        // object inventory.
        llOwnerSay("Congratulations. Your vendor does not contain scripts, and all items are copyable and transferrable.");
        state vend;
	}
}

state vend
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
            // There was nothing to give, so tell the user.
            llSay(0, "This object has nothing to give you. Please contact its owner.");
    }
    
    changed(integer what)
    {
    	// changed event happens when... something changes. :-)
    	// in this case we're interested in when the object inventory
    	// changes. The 'what' variable contains a bitmap of whatever
    	// changes caused the event to fire. Since we're only interested
    	// in inventory changes, we do a bitmap check for the change we want:
    	if (what & CHANGED_INVENTORY)
    	{
    		// see http://wiki.secondlife.com/wiki/CHANGED_INVENTORY
    		// for a list of inventory changes this covers (and doesn't cover)
    		// but it's adequate for our uses... so we head off towards
    		// state errorCheck.
    		state errorCheck;
    	}
    }
}
