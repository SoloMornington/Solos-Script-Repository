// Object Die
// by Solo Mornington

// This is the simplest script in the universe.
// However, it requires careful use.
// It will destroy any object that contains it.
// That is to say, if you put this script in an object,
// that object will be destroyed.
// It won't be in Trash or Lost and Found, it will be well and truly
// GONE.

// Uses for this script:
// Destroying a megaprim you can't seem to edit through the viewer.
// Destroying any object over which you have mod rights.
// Being evil.
// Being good.

default
{
	state_entry()
	{
		llDie();
	}
}
