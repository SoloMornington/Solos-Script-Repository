float gTimerBaseValue = 2.0;
float gTimerMargin = 0.5;

float newTimerValue()
{
    float margin = llFrand(gTimerMargin * 2) - gTimerMargin;
    return gTimerBaseValue + margin;
    //return 2.0;
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
    // the bounding box is a very imprecise way to get the outside dimensions
    // of an object. But we'll use this because it's easy, not because it's
    // right.
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
