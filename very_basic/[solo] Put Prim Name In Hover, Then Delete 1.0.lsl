// Put Prim Name In Hovertext Then Delete
// by Solo Mornington

// THIS NOTICE MUST REMAIN INTACT:
// Copyright 2010, Solo Mornington
// License: Use freely in any way you want. Modified versions
// may be used in any way. No credit or acknowledgement required.
// Definitive source and updates available here:
// http://github.com/SoloMornington/Solos-Script-Repository
// ** end notice

// This script puts the name of the object into the object's hovertext
// and then deletes itself.

// This is primarily so you can drag the script out of inventory
// and drop it into a prim, in order to set the hovertext to the
// prim name.

// This follows a common LSL coding pattern: doing something and then
// deleting the script.

// This technique can be very useful for a number of different applications.
// For instance, see the related Die Prim script. Or if you want an object
// to chat its rotation, so you can copy/paste it somewhere.

default
{
    state_entry()
    {
        llSetText(llGetObjectName(), <1,1,1>, 1.0);
        llRemoveInventory(llGetScriptName()); // delete this script
    }
}
