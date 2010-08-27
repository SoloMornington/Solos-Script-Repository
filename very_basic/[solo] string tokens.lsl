// String Tokens
// by Solo Mornington

// THIS NOTICE MUST REMAIN INTACT:
// Copyright 2010, Solo Mornington
// License: Use freely in any way you want. Modified versions
// may be used in any way. No credit or acknowledgement required.
// Definitive source and updates available here:
// http://github.com/SoloMornington/Solos-Script-Repository
// ** end notice

// Find a 'token' in a string and replace it with a value.

// Easy improvements: Let the user set the token.
// Hard improvements: Case and plural tokens.

string replaceToken(string tokenized, string value)
{
    // see if there's a token to replace
    if ( llSubStringIndex(tokenized, "%") >= 0)
    {
    	// split up the tokenized line into pieces.
        list tokenChunks = llParseStringKeepNulls(tokenized, ["%"], [""]);
        // reassemble the pieces using the new value as 'delimiter.'
        return llDumpList2String(tokenChunks, value);
    }
    // there weren't any tokens, so return the original string.
    return tokenized;
}

default
{
    state_entry()
    {
        llOwnerSay(replaceToken("%, will you be my bestest friend?", llGetOwner()));
    }
}