float gTimerBaseValue = 2.0;
float gTimerMargin = 0.5;

float newTimerValue()
{
    float margin = llFrand(gTimerMargin * 2) - gTimerMargin;
    return gTimerBaseValue + margin;
    //return 2.0;
}


vector objectSize()
{
	// since LSL hates us and won't just tell us the outside size of the object
	// we have to do the math ourselves and add it all up.
	integer i;
	vector link_pos;
	vector link_scale;
	
	integer count=llGetNumberOfPrims();
	
	// if there's only one prim, then we don't need to work very hard at all.
	if (count < 1)
	{
		return llList2Vector(llGetPrimitiveParams([PRIM_SIZE]), 0);
	}
	
	// gather some useful info....
	vector rootPos = llGetRootPosition();
	rotation rootRot = llGetRootRotation();
	
	list primPositions; // local positions relative to root, accounting for rotation
	list primScales; // size of each prim.
	
	// first we load up primPositions....
	for(i=1; link<=count; ++i)
	{
	    if (i==1)
	    {
	    	// root prim gets special treatment
	    	primPositions += ZERO_VECTOR;
	    	primScales += [llList2Vector(llGetLinkPrimitiveParams(i,[PRIM_SIZE]),0)];
	    }
	    else
	    {
		    //Get current link prim position and size
		    link_pos=llList2Vector(llGetLinkPrimitiveParams(i,[PRIM_POSITION]),0);        
		    link_scale=llList2Vector(llGetLinkPrimitiveParams(i,[PRIM_SIZE]),0);
		    
		    //Calculate local link prim position
		    primPositions += [(link_pos-rootPos)/rootRot];
		    // store the scale....
		    primScales += [link_scale];
		}
	}
	// now we loop through the prims and compare them to each other
	vector min = 
	vector max;
	count = llGetListLength(primPositions);
	for (i=1; i<count; ++i)
	{
	}
}


setupVehicle()
{
	// this function re-initializes the phyysics and vehicle parameters
	// make it a physical object....
	llSetStatus(STATUS_PHYSICS, TRUE);
	// make it a vehicle....
    llSetVehicleType(VEHICLE_TYPE_BOAT);
    llSetVehicleFlags(VEHICLE_FLAG_HOVER_GLOBAL_HEIGHT);
    llSetVehicleFloatParam(VEHICLE_BUOYANCY, 0.5);
    llSetVehicleFloatParam(VEHICLE_HOVER_EFFICIENCY, 0.7);
    llSetVehicleFloatParam(VEHICLE_HOVER_TIMESCALE, 1.0);
    // we want hover height to be determined by the object bounding box
    // this assumes this script is in the root prim, which is probably a safe
    // assumption. but it's still an assumption.
    list bbox = llGetBoundingBox(llGetKey());
    vector bboxVector = llList2Vector(bbox, 1) - llList2Vector(bbox,0);
    float bboxOffset = bboxVector.z * 0.3;
    llSetVehicleFloatParam(VEHICLE_HOVER_HEIGHT, llWater(llGetPos()) + bboxOffset);
    llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 1.3);
    llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 0.0);
    // the bounding box also helps us 
    llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <5.0,5.0,1.2>);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE, 0.5);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_TIMESCALE, 0.3);
}


default
{
    state_entry()
    {
    	// start the vehicle stuff...
    	setupVehicle();
    	// set a timer for the wind-based impulses
        llSetTimerEvent(newTimerValue());
    }
    
    timer()
    {
        vector windy = llWind(llGetPos());
        windy.y = windy.y * 0.3;
        windy.x = windy.x * 0.3;
        windy.z = windy.z * 0.7;
        llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, windy);
        llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <0.5,0.01,1.0>);
        //llMessageLinked(LINK_SET, 999, (string)llWind(llGetPos()), NULL_KEY);
        llSetTimerEvent(newTimerValue());
    }
    
    changed(integer what)
    {
    	setupVehicle();
    }
}
