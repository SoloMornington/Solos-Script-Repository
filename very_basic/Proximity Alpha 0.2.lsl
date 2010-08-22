// Proximity Alpha
// by Cinco Pizzicato

// A sensor that changes the alpha transparency of an object.

// Change this number to a new distance to tweak the behavior:
float gSensorDistance = 5.0;

// don't change anything below here, unless you know what you're doing,
// and if yo do, and it works better, please let me know. :-) --Cinco Pizzicato

float gAlpha = 0.0;

default
{
    state_entry()
    {
        // First, set up the sensor repeat
        llSensorRepeat("",NULL_KEY,AGENT,gSensorDistance,PI, 1.0);
        // ...and set the alpha 
        llSetLinkAlpha(LINK_SET, gAlpha, ALL_SIDES);
    }

    sensor(integer num_detected)
    {
        // Start by getting my position
        vector myPos = llGetPos();
        // and the position of the nearest avatar
        vector targetPos = llDetectedPos(0);
        // how far to the avatar?
        float targetDistance = llVecDist(myPos, targetPos);
        // Use this to calculate the alpha
        gAlpha = 1.0 - (targetDistance / gSensorDistance);
        // ...and set it.
        llSetLinkAlpha(LINK_SET, gAlpha, ALL_SIDES);
    }
    
    no_sensor()
    {
        // there's no av nerarby, so...
        // ... if the alpha isn't already 0...
        if (gAlpha != 0.0)
        {
            // ... set it to 0.
            gAlpha = 0.0;
            llSetLinkAlpha(LINK_SET, gAlpha, ALL_SIDES);
        }
    }
}
