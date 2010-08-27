// Solo's Simple Multi-Pay Script 1.0.

// THIS NOTICE MUST REMAIN INTACT:
// Copyright 2010, Solo Mornington
// License: Use freely in any way you want. Modified versions
// may be used in any way. No credit or acknowledgement required.
// Definitive source and updates available here:
// http://github.com/SoloMornington/Solos-Script-Repository
// ** end notice

// A super-simple multi-pay script.

// This script assumes all payees get an equal amount.
// The object owner wins the spoils of division remainers.

// Configuration details follow license...

// -----------------------------------------------------

// source for this license:
// http://poidmahovlich.blogspot.com/2008/05/betlog-hax-licence-20080504a.html

//----------------------------------
// ---LICENCE START---
// This script may only be distributed/used under these conditions:
//
// - The original SecondLife permissions must be retained.
// [Generally this will mean Modify/Copy/Transfer .. full perms.]
//
// - It is NOT *SOLD* BY ITSELF, UNMODIFIED.
// [Modifying the 'CONFIGURATION' sections alone does NOT constitute 
// signficant odification.]
//
// 1] If you do NOT significantly modify the script's 'CORE CODE':
// - This licence information must not be removed or altered.
// - The original script is used so as to:
// a] Retain the original creator name in its properties.
// a] Retain the original script name.
// [Do not just copy and paste it into a new script that shows you as the creator.]
//
// 2] If you DO significantly modify the script's 'CORE CODE':
// - It must be clear in the notecard/script/description (a prominent place)
//   of any item using it that:
// a) This script was used.
// b) The original author's name.
// c) Any credits from the original script are passed through.
// e.g. 'CREDIT: script name by BETLOG Hax, with credits to: '.
//
// This is essentially a Lesser GPL licence:
// http://creativecommons.org/licenses/LGPL/2.1/
// With some specific additions to reflect it's SecondLife/LSL origins.
// ---LICENCE END---
//----------------------------------

// CONFIGURATION.....

// Modify the following values to configure the script.

// First, the price of the item:

integer gItemPrice = 23;

// Second, the list of payees, as UUID keys.

list gPayeeKeys = [ 
    // your keys here, separated with commas...
    "6d286553-59ae-409a-887d-ee75df67b834" // c'mon.. give a cut to poor Solo. :-)
    ];

// Don't know how to get a UUID for an avatar?
// Here's how.
// Create a cube.
// Edit it, look in the Contents tab.
// Create a new script.
// Replace the text of the new script with the following line of code:

// default{touch_start(integer i){llSay(0, (string)llDetectedKey(0));}}

// Be sure the code is not commented (remove the // at the beginning)
// Click save. Now the cube will say the UUID of anyone who touches it.

// .....END CONFIGURATION

default
{
    state_entry()
    {
        state debitPermission;
    }
}

state debitPermission
{
    state_entry()
    {
        llInstantMessage(llGetOwner(), "This script requires that you give it permission to take your money. This is for refunds in case the purchaser pays the wrong amount. You have 30 seconds to give this permission.");
        // start the countdown timer....
        llSetTimerEvent(30.0);
        llRequestPermissions(llGetOwner(), PERMISSION_DEBIT);
    }

    state_exit()
    {
        // stop the timer
        llSetTimerEvent(0.0);
    }

    run_time_permissions(integer perms)
    {
        if (perms & PERMISSION_DEBIT)
        {
            // yay we can debit!
            state acceptPayment;
        }
        else
        {
            // oops... no debit.
            state deadMachine;
        }
    }
    
    timer()
    {
        // oops... no debit.
        state deadMachine;
    }
    on_rez(integer f){llResetScript();}
}

state acceptPayment
{
    state_entry()
    {
        // we want one quick pay button with the item price:
        llSetPayPrice(PAY_HIDE, [gItemPrice, PAY_HIDE, PAY_HIDE, PAY_HIDE]);
    }
    
    money(key id, integer amount)
    {
        // first things first: compare the amount to the price
        // if they're different do a refund. this could be mondified to
        // give change, but something would be really wrong for this
        // error to occur, so we'll just do a straight-up refund.
        if (amount != gItemPrice)
        {
            llInstantMessage(id, "The amount you paid was incorrect. It will be refunded. Please try again.");
            llGiveMoney(id, amount);
            // since this should never happen, we IM the owner.
            llInstantMessage(llGetOwner(), "Refunded money to " + llKey2Name(id) + " due to incorrect payment amount.");
        }
        else
        {
            // ok, amount is good. Now we divide the amount between payees.
            integer i;
            integer payeeCount = llGetListLength(gPayeeKeys);
            integer amountEach = gItemPrice / (payeeCount + 1); // add one for the object owner
            for (i=0; i < payeeCount; i++)
            {
                llGiveMoney(llList2Key(gPayeeKeys,i), amountEach);
            }
        }
    }
    on_rez(integer f){llResetScript();}
}


state deadMachine
{
    state_entry()
    {
        llInstantMessage(llGetOwner(), "You have not given the Multi-Payout script permission to take your money. In order to try again, you must reset this script. Edit the object containing it, and select Tools -> Reset Scripts In Selection.");
    }
    on_rez(integer f){llResetScript();}
}
