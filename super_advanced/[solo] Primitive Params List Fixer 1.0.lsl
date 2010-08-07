// Primitive params list fixer
// by Solo Mornington

// This script is meant to demonstrate the two functions:
// castList and typedParamList.

// These two functions can be used to set the type of a list
// so that it can be used by llSetPrimitiveParams (or it's Link
// and Fast cousins)

// The intent is that you'd find use for these functions beyond
// what this script actually does. What does this script do? It
// performs a round-trip test on params data, to show that it works.


list castList(list input, list rules)
{
    // cast all items in input to type dictated by rules
    // rules is a list of integers, as returned by llGetListEntryType
    // any unknown types in rules are cast to string.
    // Inclusion of a 'break' statement in LSL would make this much
    // more convenient. :-)
    
    // Note that this could be modified so that these lists are globals
    // making the whole script much more memory-efficient, since LSL
    // can only pass a list by value.

    list output;
    integer type;
    integer i;
    integer length = llGetListLength(input);
    for (i=0; i<length; i++)
    {
        type = llList2Integer(rules, i);
        if (type == TYPE_INTEGER)
        {
            output += (integer)llList2String(input, i);
            jump next;
        }
        if (type == TYPE_FLOAT)
        {
            output += (float)llList2String(input, i);
            jump next;
        }
        if (type == TYPE_KEY)
        {
            output += (key)llList2String(input, i);
            jump next;
        }
        if (type == TYPE_VECTOR)
        {
            output += (vector)llList2String(input, i);
            jump next;
        }
        if (type == TYPE_ROTATION)
        {
            output += (rotation)llList2String(input, i);
            jump next;
        }
        output += llList2String(input, i);
        @next;
    }
    return output;
}

list typedParamList(list params)
{
    // params is a list of strings (or any type, really)
    // that contains input to llSetPrimitiveParams(),
    // just in the wrong types.
    
    // the output is a correctly-typed list of exactly the same
    // data, just made palateable to the finicky tastes of
    // LSL. Because, you see, LSL is kinda sorta stupid.
    // </gripe>
    
    // Since we know the size and types of data structures
    // related to the various PRIM_TYPEs, we can use that
    // knowledge to make a rule set.
    
    // Then we send params and the rule set off to the castList
    // function, in order to cast the list to the proper types.
    
    // This, of course, consumes a great deal of memory that would
    // probably be better spent some other way.
    
    list rules;
    integer i;
    integer constant;
    integer length = llGetListLength(params);
    while (i<length)
    {
        constant = llList2Integer(params, i++);
        rules += TYPE_INTEGER; // to account for constant
        
        if (constant == PRIM_TYPE)
        {
            constant = llList2Integer(params, i++);
            rules += TYPE_INTEGER;
            
            // start checking for types.....
            if (constant == PRIM_TYPE_SCULPT)
            {
                rules += [TYPE_STRING, TYPE_INTEGER];
                i += 2;
                jump next;
            }
            // ........
            if ((constant == PRIM_TYPE_BOX) ||
                (constant == PRIM_TYPE_CYLINDER) ||
                (constant == PRIM_TYPE_PRISM))
            {
                rules += [TYPE_INTEGER, TYPE_VECTOR, TYPE_FLOAT, TYPE_VECTOR, TYPE_VECTOR, TYPE_VECTOR];
                i += 6;
                jump next;
            }
            // .......
            if ((constant == PRIM_TYPE_TORUS) ||
                (constant == PRIM_TYPE_TUBE) ||
                (constant == PRIM_TYPE_RING))
            {
                rules += [TYPE_INTEGER, TYPE_VECTOR, TYPE_FLOAT, TYPE_VECTOR, TYPE_VECTOR, TYPE_VECTOR, TYPE_VECTOR, TYPE_VECTOR, TYPE_FLOAT, TYPE_FLOAT, TYPE_FLOAT];
                i += 11;
                jump next;
            }
            // ......
            if (constant == PRIM_TYPE_SPHERE)
            {
                rules += [TYPE_INTEGER, TYPE_VECTOR, TYPE_FLOAT, TYPE_VECTOR, TYPE_VECTOR];
                i += 5;
                jump next;
            }
        } // end of PRIM_TYPE
        if ((constant == PRIM_SIZE) ||
            (constant == PRIM_POSITION))
        {
            rules += [TYPE_VECTOR];
            i++;
            jump next;
        } // end of PRIM_SIZE, PRIM_POSITION
        if ((constant == PRIM_MATERIAL) ||
            (constant == PRIM_PHANTOM) ||
            (constant == PRIM_PHYSICS) ||
            (constant == PRIM_TEMP_ON_REZ))
        {
            rules += [TYPE_INTEGER];
            i++;
            jump next;
        }
        if (constant == PRIM_ROTATION)
        {
            rules += [TYPE_ROTATION];
            i++;
            jump next;
        }
        if (constant == PRIM_GLOW)
        {
            rules += [TYPE_INTEGER, TYPE_FLOAT];
            i += 2;
            jump next;
        }
        if (constant == PRIM_TEXTURE)
        {
            rules += [TYPE_INTEGER, TYPE_STRING, TYPE_VECTOR, TYPE_VECTOR, TYPE_FLOAT];
            i += 5;
            jump next;
        }
        if (constant == PRIM_BUMP_SHINY)
        {
            rules += [TYPE_INTEGER, TYPE_INTEGER, TYPE_INTEGER];
            i += 3;
            jump next;
        }
        if (constant == PRIM_COLOR)
        {
            rules += [TYPE_INTEGER, TYPE_VECTOR, TYPE_FLOAT];
            i += 3;
            jump next;
        }
        if (constant == PRIM_POINT_LIGHT)
        {
            rules += [TYPE_INTEGER, TYPE_VECTOR, TYPE_FLOAT, TYPE_FLOAT, TYPE_FLOAT];
            i += 5;
            jump next;
        }
        if ((constant == PRIM_FULLBRIGHT) || (constant == PRIM_TEXGEN))
        {
            rules += [TYPE_INTEGER, TYPE_INTEGER];
            i += 2;
        }
       @next;
    } // end while.
    return castList(params, rules);
}


default
{
    state_entry()
    {
        list params = llGetPrimitiveParams([PRIM_TYPE]);
        string paramString = llDumpList2String([PRIM_TYPE] + params, "|");
        list paramsList = llParseString2List(paramString, ["|"], [""]);
        llSetPrimitiveParams(typedParamList(paramsList));
    }
}
