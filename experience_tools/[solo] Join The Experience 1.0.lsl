string gExperienceName;

default
{
    state_entry()
    {
        list experience = llGetExperienceDetails(NULL_KEY);
        gExperienceName = llList2String(experience, 0);
        llSetText("Touch to join the\n" + gExperienceName + "\nexperience.", <1,1,1>, 1.0);
    }

  touch_start(integer total_number)
  {
      while(total_number--) {
          key agent = llDetectedKey(total_number);
          if (llAgentInExperience(agent)) {
              llRegionSayTo(agent, 0, "You are already part of the " + gExperienceName + " experience.");
          }
          else {
              llRequestExperiencePermissions(agent, "");
          }
      }
  }
}
