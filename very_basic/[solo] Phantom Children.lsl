// Phantom Children
// by Solo Mornington
//
// Based on the hard work of these people: 
// http://wiki.secondlife.com/wiki/Phantom_Child
// Particularly ninjafoo Ng.
//
// This script is a generalized phantom-child-prim-setter.
// Currently, it sets all prims with 'phantom' in their
// description as phantom. All other prims are non-phantom.
//
// It can be easily modified by changing the shouldSetThisPhantom()
// function to reflect whatever logic you want. For instance
// if you wanted it to change only scultpy prims to phantom,
// then your function might look like this:
//
// integer shouldSetThisPhantom(integer linknumber)
// {
//	list params = llGetLinkPrimitiveParams(linknumber, [PRIM_TYPE]);
//	return PRIM_TYPE_SCULPT == llList2Integer(params, 0);
// }
//

list PRIM_PHANTOM_HACK = [
	PRIM_FLEXIBLE, 1, 0, 0.0, 0.0, 0.0, 0.0, <0,0,0>,
	PRIM_FLEXIBLE, 0, 0, 0.0, 0.0, 0.0, 0.0, <0,0,0>
	];

integer shouldSetThisPhantom(integer linknumber)
{
	// This is a callback function to setAllPhantom().
	// Return TRUE to have linknumber set phantom, FALSE otherwise.
	// This function is factored out so that you can put your own
	// logic into it. Re-use the rest of the script and just change
	// this part for different phantom-prim scenarios.
	list params = llGetLinkPrimitiveParams(linknumber, [PRIM_DESC]);
	return llStringTrim(llList2String(params, 0), STRING_TRIM) == "phantom";
}

setAllPhantom()
{
	// We have to use llSetStatus to set all of the prims non-phantom
	// and then only set the phantom ones on the loop.
	// This could potentially be mean to anyone who's using
	// the object at the time.
	llSetStatus(STATUS_PHANTOM, FALSE);
	// Get the total prim count.
	// llGetObjectPrimCount() avoids seated avatars
	integer prims = llGetObjectPrimCount(llGetKey());
	// We don't want to change the root prim, and if
	// there are no child prims then there's nothing else to do.
	if (prims < 2) return;
	integer i;
	list params;
	// LSL has a stupid way of referring to root and child prims.
	// If there's only one prim, then the lowest link number is
	// 0, but if there are more, it's 1.
	for (i=1; i<=prims; ++i)
	{
		if (shouldSetThisPhantom(i))
		{
			params = llGetLinkPrimitiveParams(i,[PRIM_TYPE]);
			llSetLinkPrimitiveParamsFast(i,
				[PRIM_TYPE, PRIM_TYPE_BOX, PRIM_HOLE_DEFAULT, <0,1,0>, 0, <0,0,0>, <1,1,0>, <0,0,0>]
				+ PRIM_PHANTOM_HACK
				+ [PRIM_TYPE] + params
				);
		}
	}
}

default
{
	// Just a few events where we want to do this process.
	// state_entry, when the sim restarts, and when the
	// user links in a new prim. Ideally, we'd have an
	// event for when the user changes the descriptions,
	// but that's not available to us.
	state_entry()
	{
		setAllPhantom();
	}
	
	changed (integer what){
		if ((CHANGED_REGION_START & what) ||
			(CHANGED_LINK & what))
		{
			setAllPhantom();
		}
	}
}
