// Read A Notecard
// by Solo Mornington

// THIS NOTICE MUST REMAIN INTACT:
// Copyright 2012, Solo Mornington
// License: Use freely in any way you want. Modified versions
// may be used in any way. No credit or acknowledgement required.
// Definitive source and updates available here:
// http://github.com/SoloMornington/Solos-Script-Repository
// ** end notice

// This is a script that demonstrates how to read a notecard.

// All it does is read the notecard and say each line aloud.

// There are a few things to keep in mind when trying to read a notecard in LSL:

// 1) The Empty Notecard Bug: There is a bug/feature of SL that says
// that you can make a new notecard in your avatar's inventory, save
// it without any text, and then drag it into the inventory of an object.
// LSL inventory functions can learn the name of this notecard, so you
// would think that it exists. But it doesn't, really. When you try
// to read it, LSL will throw an error. Here is a JIRA about it:
// https://jira.secondlife.com/browse/SVC-5293

// 2) Design Patterns: There are many contexts in which you'd want to
// read a notecard. In some circumstances you'd need to read the
// notecard while something else is happening. In other circumstances
// you'd want to read a notecard *before* something else happens, as
// with a configuration notecard. These are design decisions that
// need to be made. This script demonstrates how to read a notecard
// as its own state in the script, as you might for a configuration script,
// because this will give a simpler illustration that can be adapted
// for other contexts.

// GLOBAL VARIABLES: (I mark them with g at the start)
// Since notecards are read line-by-line in an event, we have to
// keep track of which line we're reading, and which notecard we want
// to read.
string gNotecardName;
integer gNotecardLine;

// Because the process of reading a notecard is asynchronous,
// you have to keep a 'key' of your request. This gives you
// something to check to see which request you're getting
// an answer for.
key gNotecardQuery;

// This will store the contents of the notecard.
// We could make this a big string, but it's
// easier for some purposes to store it
// as a list.
list gNotecardContents;


// Since we're just demonstrating how to read a notecard, we'll have a
// vestitial default state. It won't do much of anything other than
// start the process.

default
{
    state_entry()
    {
        state readNotecard;
    }
}

state readNotecard
{
    state_entry()
    {
        // To start, we'll get the name of the first notecard
        // and determine that it's not empty.
        // We'll make an error condition so we know if we've succeeded.
        integer goodNotecard = FALSE;
        // Zero out some variables...
        gNotecardLine = 0;
        gNotecardContents = [];
        gNotecardName = llGetInventoryName(INVENTORY_NOTECARD, 0);
        if (gNotecardName != "")
        {
            // There is a named notecard, but does it have a UUID?
            // See http://wiki.secondlife.com/wiki/LlGetNotecardLine#Caveats
            if (llGetInventoryKey(gNotecardName) != NULL_KEY)
            {
                goodNotecard = TRUE;
            }
        }
        // If it's a bad notecard, then die.
        if (!goodNotecard) state die;
        // OK, so we have a good notecard and we can start reading it.
        // llGetNotecardLine() asks SL to get the line of text from
        // the notecard, but it doesn't return it. Instead, since it
        // might take some time (relatively speaking), the text will
        // be returned in the dataserver event.
        // The ++ operator uses the current value of the variable, and
        // then increments it. This lets us use one line of code to read
        // one line of text. Isn't that nice? :-)
        gNotecardQuery = llGetNotecardLine(gNotecardName, gNotecardLine++);
    }

    dataserver(key query, string data)
    {
        // Here's where our query variable comes back into play.
        // We check to see if it's the notecard query that the system
        // is telling us about. For this simple script it doesn't matter
        // too much, but in a more complex script there might be other
        // queries happening, other than our single one. So it's
        // good practice to check.
        if (query == gNotecardQuery)
        {
            // When there aren't any more lines to read from the notecard,
            // LSL will send back an EOF (end-of-file).
            if (data != EOF)
            {
                // Data isn't an EOF, so we have something to add to the
                // results list.
                gNotecardContents += [data];
                // And now we can fetch the next line of text.
                gNotecardQuery = llGetNotecardLine(gNotecardName, gNotecardLine++);
            }
            else // data is EOF
            {
                // All done.
                state success;
            }
            
        }
    }
}

state success
{
    state_entry()
    {
        // The idea is that we only get to this state when we've read the notecard.
        // So now we tell the user what we got.
        llSay(0, "I read the notecard: " + gNotecardName + ". It is " +
            (string)gNotecardLine + " lines long.");
        llSay(0, "Here's what the notecard said:\n" +
            llDumpList2String(gNotecardContents, "\n"));
        llSay(0, "Touch this object to read the notecard again.");
    }
    
    touch_start(integer foo)
    {
        state default;
    }

    changed(integer what)
    {
        // If the inventory changes, go back to state default
        // and try again.
        if (what & CHANGED_INVENTORY) state default;
    }
}

state die
{
    // We get to state die if there's no notecard, or if there's some other
    // problem we can't otherwise solve.
    state_entry()
    {
        llOwnerSay("This script has died. Try putting a notecard in the object's inventory to make it live again.");
    }
    
    changed(integer what)
    {
        // If the inventory changes, go back to state default
        // and try again.
        if (what & CHANGED_INVENTORY) state default;
    }
}
