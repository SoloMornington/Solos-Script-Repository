vector gScale; // scale of this prim. we store it so we don't have to ask a lot.
float gLargest; // largest dimension
string gTexture;

list gPrimCounts; // populated with vectors, one per non-root prim

particleCloud(integer link, float mag)
{
	// this function makes a cloud of 'dust' for the given linked prim.
	// mag is the amount of time the emitter should produce dust particles.
    float startScale = gLargest * 0.07; // arbitrary constant. adjust for aesthetics.
    llLinkParticleSystem( link, [ 
		PSYS_SRC_TEXTURE, gTexture, 
		PSYS_PART_START_SCALE, <startScale, startScale, 0>,
		PSYS_PART_END_SCALE, <gLargest, gLargest, 0>, 
		PSYS_PART_START_COLOR, <.5,.5,.5>,
		PSYS_PART_END_COLOR, <.1,.1,.1>, 
		PSYS_PART_START_ALPHA, .8,
		PSYS_PART_END_ALPHA, .0,     
		PSYS_SRC_BURST_PART_COUNT, 1, 
		PSYS_SRC_BURST_RATE,  0.2,  
		PSYS_PART_MAX_AGE, 2.0, 
		PSYS_SRC_MAX_AGE, mag,  // <-- mag
		PSYS_SRC_PATTERN, 8,
		PSYS_SRC_ACCEL, <0.0,0.0,.2>,
		PSYS_SRC_BURST_SPEED_MIN, 0.01,   PSYS_SRC_BURST_SPEED_MAX, 0.2, 
		PSYS_SRC_ANGLE_BEGIN,  15*DEG_TO_RAD,
		PSYS_PART_FLAGS, ( 0      
	        | PSYS_PART_INTERP_COLOR_MASK   
	        | PSYS_PART_INTERP_SCALE_MASK   
	        | PSYS_PART_EMISSIVE_MASK   
	        | PSYS_PART_FOLLOW_VELOCITY_MASK
	        | PSYS_PART_WIND_MASK            
	        | PSYS_PART_BOUNCE_MASK
		) ]
	);
}

list moveVel(integer link, vector vel)
{
    // 'dent' the object based on collision velocity
    // move and rotate
    list params = llGetLinkPrimitiveParams(link, [PRIM_POSITION, PRIM_ROTATION]);
    // convert position to local position
    vector p = llList2Vector(params, 0);
    rotation r = llGetRootRotation();
    vector localPos = ((p-llGetPos()) / r);
    // add in the collision velocity..
    localPos += vel * 0.05;
    // work some random magic on the rotation...
    rotation primR = llList2Rot(params, 1) / r; // local rotation
    primR = primR * llAxisAngle2Rot(vel, (llFrand(0.5) - 0.25)); // put some english on it
    // return a list with our new position and rotation.
    return [PRIM_POSITION, localPos, PRIM_ROTATION, primR];
}

initPrims()
{
	// this function fills up gPrimCounts with some initial data
	// we're making a counter that tells how many 'hits' the
	// prim has left before it's delinked.
	// declare some function-scoped variables to save a bit of memory...
    list params;
    vector pos;
    gPrimCounts = []; // clear old data
    integer prims = llGetNumberOfPrims();
    if (prims == 1)
    {
    	// prims will == 1 if there are no child prims
    	// so we can just set this and be on our way.
        gPrimCounts = [3];
    }
    else
    {
        // but if there are more than one prims in link set
        // we loop through and make sure all the prims are really prims
        // (they could be seated avatars), and init them to the number
        // we like.
        integer i;
        for (i = 1; i <= prims; i++)
        {
        	// avatars can't have ZERO_VECTOR size.
            if (llGetAgentSize(llGetLinkKey(i)) == ZERO_VECTOR)
            {
                gPrimCounts += [3];
            }
            else i--;
        }
    }
}

unsitAllAvatars()
{
	// this function lets us unsit any avatar who attempts to sit down
	// on the object.
	integer links = 0;
	while (llGetObjectPrimCount(llGetKey()) < (links = llGetNumberOfPrims())) llUnSit(llGetLinkKey(links));
}

default
{
	// default state is where we ask permission to be able to unlink
	// prims.
    state_entry()
    {
        llRequestPermissions(llGetOwner(), PERMISSION_CHANGE_LINKS);
    }
    
    run_time_permissions(integer perms)
    {
	    if (perms & PERMISSION_CHANGE_LINKS)
			// we got permission to change links, so go to the next step..
			state waiting;
    }
    on_rez(integer foo)
    {llResetScript();}
}

state waiting
{
	// this state is where we wait for the owner to tell us to start
	// denting.
    state_entry()
    {
    	// this could be much more secure.
        llListen(23, "", NULL_KEY, "dent");
    }
    
    listen(integer channel, string name, key id, string message)
    {
    	// get the object details and discover if we have the same owner
    	// this is so an object could start the denting process.
    	list details = llGetObjectDetails(id, [OBJECT_OWNER]);
    	if (llList2Key(details,0) == llGetOwner())
        {
            if (llToLower(message) == "dent")
            {
                state denting;
            }
        }
    }

    on_rez(integer foo)
    {llResetScript();}
}

state denting
{
	// ok, here we go. finally the big show.
	// start letting collisions dent the object.
    state_entry()
    {
    	unsitAllAvatars();
        llSitTarget(<0,0,0.1>, ZERO_ROTATION);
        initPrims();
        gScale = llGetScale();
        gLargest = llVecMag(gScale) * 5.0;
    }

    collision_start(integer collisions)
    {
    	// something ran into the object.
        vector vel;
        float mag;
        integer link;
        integer i;
        // more than one thing can run into the object,
        // so we need to deal with them all.
        for (i=0; i < collisions; i++)
        {
        	// which prim got hit?
            link = llDetectedLinkNumber(i);
            // root prim never dents.
            if (link > 1)
            {
                // We make a list of all the things to update
                // This is why moveVel returns a list rather than
                // setting the parameters itself.
                // Start with the glow params....
                // (if we were really tricky, we'd get the glow params
                // and modify them, but we'll assume no glow on the object)
                list params = [PRIM_GLOW, ALL_SIDES, 0.1];
                vel = llDetectedVel(i);
                mag = llVecMag(vel);
                particleCloud(link, mag * 0.7); // arbitrary constant.
                // add in the move...
                params += moveVel(link, vel);
                // send the glow and move
                // we use the non-fast version so the flash is visible.
                llSetLinkPrimitiveParams(link, params);
                //....and now that that's over, we undo the glow.
                llSetLinkPrimitiveParamsFast(link, [PRIM_GLOW, ALL_SIDES, 0.0]);
                // we precomp an index so we can manipulate our list...
                integer linkListIndex = link-1;
                // how many hits has this prim taken?
                integer hits = llList2Integer(gPrimCounts, linkListIndex);
                if (--hits < 0)
                {
                	// if there aren't any more hits left, we delink.
                	// it's on its own now.... :-)
                    llBreakLink(link);
                    // and delete the prim from our list.
                    gPrimCounts = llDeleteSubList(gPrimCounts, linkListIndex, linkListIndex);
                }
                else
                {
                	// still has some hits left, so we just rebuild the list
                	// with the decremented hit count.
                    gPrimCounts = llListReplaceList(gPrimCounts, [hits], linkListIndex, linkListIndex);
                }
            }
        }
    }
    
    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            // unsit any av that makes themselves comfortable
            unsitAllAvatars();
            // and if we're the last prim after denting and delinking
            // all the others, then die.
            if (llGetObjectPrimCount(llGetKey()) <= 1) llDie();
        }
    }
    on_rez(integer foo)
    {llResetScript();}
}
