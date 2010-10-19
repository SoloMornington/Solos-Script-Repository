// Donation Box Script
// by Solo Mornington

// THIS NOTICE MUST REMAIN INTACT:
// Copyright 2010, Solo Mornington
// License: Use freely in any way you want. Modified versions
// may be used in any way. No credit or acknowledgement required.
// Definitive source and updates available here:
// http://github.com/SoloMornington/Solos-Script-Repository
// ** end notice

// This script sits in an object and thanks people for donating. It also
// shows a running tally of recent donations below an arbitrary point.
// You set the topmost amount, and tweak the hovertext display if you'd like,
// and let the money roll on in.

// The justification for the limited top amount is that if the collection box
// sits too long without being manually reset, the number will get large
// and no one will feel compelled to give.

// We start with some globals...

integer gMaxDonations = 2000; // an arbitrary top end for total collected display.

integer gTotalDonations = 21; // the amount we've collected recently.
                                // we cheat a little and start at 21.

setText(integer amount)
{
    // this function makes it easier to uniformly set the hover text from
    // two different places in code.
    llSetText("Last donation: L$" + (string)amount + "\nRecent donations: L$" + (string)gTotalDonations, <1.0,1.0,1.0>, 1.0);
}

default
{
    state_entry()
    {
        // when we start up, we want to see the hover text.
        setText(gTotalDonations);
    }
    
    money(key giver, integer amount)
    {
        // the money event happens whenever anyone pays the object.
        // it tells us who gave the money, and how much.
        // we can thank them by speaking out loud into chat.
        // (an obvious modification would be to IM them with thanks, instead of
        // announcing in public chat.)
        // if you don't want the donation box to talk, comment out
        // the following line:
        llSay(0, "Thank you, " + llKey2Name(giver) + " for your donation!");
        // add the amount to the total
        gTotalDonations += amount;
        // show the donation in the hovertext
        setText(amount);
        // when we add the amount to the total, up there, the total
        // could go above the maximum. However, if we cap the total back to 0,
        // or limit the total shown, then the donor might be a bit disappointed
        // that their donation didn't count to the total.
        // thus, we cap the maximum after the display. The next donors'
        // donation will show a less shocking reduction in total.
        if (gTotalDonations >= gMaxDonations) gTotalDonations = 0;
    }
    
    on_rez(integer foo)
    {
        // on_rez happens when a scripted object is rezzed from inventory
        // and in our case, this means we should reset the totals
        // and display this new information.
        gTotalDonations = 21;
        setText(gTotalDonations);
    }
}
