// Physical On Delink
// by Solo Mornington

// THIS NOTICE MUST REMAIN INTACT:
// Copyright 2010, Solo Mornington
// License: Use freely in any way you want. Modified versions
// may be used in any way. No credit or acknowledgement required.
// Definitive source and updates available here:
// http://github.com/SoloMornington/Solos-Script-Repository
// ** end notice

// this script has minimal responsibilities.
// when the prim containing it is unlinked, and is the only prim in
// the link set, it will wait for some time and then become physical
// and start a process of dying.
// we wait in order to prevent editing from destroying the object.

// the delay on the physics part exists because I wanted to keep prims
// around in my project, so they'd pile up as debris. Modifications could
// include setting the prim to be temp and physical at the same time, and
// thus getting rid of state die.


float gWaitTime = 5.0; // How long after we're delinked?
float gPhysicsTime = 60.0; // How long after we're physical but before llDie?

default
{
	changed(integer change)
	{
		if (change & CHANGED_LINK)
		{
			// we know we were linked or delinked.
			if (llGetObjectPrimCount(llGetKey()) <= 1)
			{
				// we're the only prim in the linkset
				llSetTimerEvent(gWaitTime);
			}
			else
			{
				// we were just linked back in to an object
				// so turn off the timer
				llSetTimerEvent(0.0);
			}
		}
	}
	
	timer()
	{
		// gWaitTime is over... so do the deed.
		state physics;
	}
}

state physics
{
	state_entry()
	{
		// OK, we're delinked and it's time to turn physical.
		// We set a timer...
		llSetTimerEvent(gPhysicsTime);
		// and turn on the gravity.
		llSetStatus(STATUS_PHYSICS, TRUE);
	}
	
	timer()
	{
		state die;
	}
}

state die
{
	state_entry()
	{
		// In this script, we just call llDie, to delete the prim.
		// This could be modified to turn the prim temp, for instance.
		llDie();
	}
}
