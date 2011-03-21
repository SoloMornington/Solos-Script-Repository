// Scrub All Bling
// by Solo Mornington

// This script will remove particle systems from all linked prims.

// THIS NOTICE MUST REMAIN INTACT:
// Copyright 2011, Solo Mornington
// License: Use freely in any way you want. Modified versions
// may be used in any way. No credit or acknowledgement required.
// Definitive source and updates available here:
// http://github.com/SoloMornington/Solos-Script-Repository
// ** end notice

// HOW TO:

// Put this script into an object, and it will cause all particle systems
// in all linked prims to stop.

// First we make a function that will reset the particle systems
// of all prims.
killAllParticles()
{
	// primCount tells us how many prims there are
	integer primCount = llGetObjectPrimCount(llGetKey());
    if (primCount == 1)
    {
        // Only one prim to deal with, and that prim is the one we're in.
        // So therefore we can just call llParticleSystem().
        llParticleSystem([]);
    }
    else
    {
    	// more than one prim, so we loop through all the prims and 
    	// scrub the particles.
        integer i;
        for (i=1; i<= primCount; ++i)
        {
        	// scrub the particles...
            llLinkParticleSystem(i, []);
        }
    }
}

// Now we address when to scrub the particles.
default
{
    state_entry()
    {
    	// Clearly we want to scrub the particles on state_entry...
    	killAllParticles();
    }
}
