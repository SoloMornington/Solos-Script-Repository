// Preload Slideshow
// by
// Solo Mornington

// v.1.0

// What this does is cover all sides of a prim with all the textures
// in inventory and rotates through them. This means you can set all
// the sides to black except one for a slideshow, and all the textures
// will be preloaded. Alternately, you could use it to preload textures
// in an environment of some sort.

list gTextures; // list of texures in prim inventory
integer gTexturePointer = 0; // which of gTextures is the texture for the 0th face?

load_gTextures()
{
    // load all the textures into gTextures
    gTextures = [];
    integer i;
    integer count = llGetInventoryNumber(INVENTORY_TEXTURE);
    for (i=0; i<count; ++i)
    {
        gTextures += [llGetInventoryName(INVENTORY_TEXTURE, i)];
    }
    // if there weren't any textures in inventory, use a blank texture
    if (count < 1) gTextures = [TEXTURE_BLANK];
}

applyFaceTextures()
{
	// given a list of texture names of arbitrary length,
	// and an arbitrary number of faces,
	// apply the textures to the faces.
	// repeat the textures if there are fewer than the number of faces
	// use the texture indexed by gTexturePointer as the 0th face
    integer i;
    integer faceCount = llGetNumberOfSides();
    integer textureCount = llGetListLength(gTextures);
    list params;
    integer currentTexture = gTexturePointer;
    for (i=0; i<faceCount; ++i)
    {
        params += [ PRIM_TEXTURE, i, llList2String(gTextures, currentTexture++),
            <1,1,0>, ZERO_VECTOR, 0.0];
        if (currentTexture >= textureCount) currentTexture = 0;
    }
    llSetLinkPrimitiveParamsFast(LINK_THIS, params);
    if (++gTexturePointer >= textureCount) gTexturePointer = 0;
}

default
{
    state_entry()
    {
    	// first initialize the texture list
        load_gTextures();
        // next paint the textures on all the sides
        applyFaceTextures();
        // finally set up the timer interval.
        llSetTimerEvent(23.0);
    }
    
    changed(integer what)
    {
    	// in the changed event, the user could have edited the object
    	// which would change the number of sides, or added items to
    	// inventory, which might change the number of textures.
    	// so we just deal with all those concerns this way:
    	// reload the textures
        load_gTextures();
        // figure out if gTexturePointer is too big, and points to
        // a non-existent item in the gTextures list
        integer textureCount = llGetListLength(gTextures);
        if (gTexturePointer >= textureCount) gTexturePointer = textureCount - 1;
        // apply the new textures.
        applyFaceTextures();
    }
    
    timer()
    {
    	// paint the sides with the textures.
        applyFaceTextures();
    }
}


