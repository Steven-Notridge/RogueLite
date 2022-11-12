v0.3
- Changed `Start-Battle` function and made the original `Do` section into a function. Makes more sense if you look at it. 
- Changed the old `Start-Battle` to `Start-UI`
- Fixed up a few parts of the 'UI' by adding the lines to the end of the attacks etc. 
- Added Magic stat for the player. For now the default value will be 0. 
- Changed the math on the Heal card, to be `3 + Player.Magic`
- Changed the way the enemies attacks are created. They now have a list within their stats. This allows me to change the randomness of their attacks without affecting others. 
- Added a section to reset Ogre's HP if you get him first. Need to fix this part up in a later version along with randomising item drops.

v0.3b
- Removed the 'AttackList' because it was struggling to handle it. It was skipping the Skills and was doing all sorts of random stuff. Now replaced with If statements after choosing the enemy, and changing the attack list inside. This might be worth changing to 'Mob Types' later on and have a more streamlined attack system.

v0.4
- Created `Give-Item`, and added a new magic item from the Ogre.
- Added two more item slots and thought of an item structure.
- Added `Enemy-HPReset`, just another way to clean up the actual battle section a bit more.
- Added `Enemy-AttackList` and used the lesson learnt from `Deal-Hand`, by returning the result and assigning it to a new variable. Again, mostly just to keep the actual battle and stuff clean.
- Added a section under `Give-Item` that will roll for an item. It will be a 60% chance for now.
- Added `MaxHP` Stat for Player. Prevent Player from going above this threshold. Should make space for later items to increase max hp.
- Made space for `MaxHP` in the `Player-Attack`'s `Heal` spell.

v0.5
- Added `Start-Round` that has the `Do Until` stuff inside, also added other parts. I'm hoping this allows me to do more later on. I don't really aim to keep adding more functions as it'll start becoming a nightmare. (Unless I start creating Modules.)
- Changed the Monster skill details. `Skill1` is now replaced with `ATKSkill` and `MGKSkill` has been introduced. I may add `DEFSkill` soon. This should make combat a bit more diverse instead of just slapping away. 
- Had to change details in `Enemy-AttackList` because `-match` was actually giving the Spider the same attack chances as the Ogre. I had initial issues with `-eq`. 
- Broke the Turn counter by making changes to `Start-Round`. I've now made the `Round` and `Turn` variables into a Hashtable under `FightStats`. Seems like the only way to update the integer whilst it's looping etc. 
- The Wolf's buff ability was able to be kept between rounds. I've added the stat reset to the `Enemy-HPReset` function to prevent this happening again. Later had to add another line to reset the `EnemyBuffturns` back to `0` as I apparently didn't add this.
- For enemy buffs, I've added a message to display the duration of the active buffs. 
- Buff limit will be set to 5, it will be displayed as 6 in the `FightStats` hashtable, because I can't work out a current system to not remove 1 at the end of the same turn it's activated. 
- Also added another entry for `EnemyBuffed = $false` under the `FightStats` hashtable, and will change to `$true` after an enemy buffs itself. It's removed once the duration expires.
- If enemy has a buff with 3 or more turns left, then the enemy's card will be rerolled. A message will be displayed on the terminal for this. Again, modifying a value within `FightStats`.
- Added a godmode because I keep dying when I'm trying to test stuff.
- Added a check to see if Player already has an item in slot 1 or 2. This will likely need further changes. This is under the `Give-Item` function.
- Created `Give-Gold` to start building towards a Shop system. More information can be found on the `Shop - Items` md file.
- Added ways to check more details, when choosing a card in hand you can use `details` for match details, `player` for all player stats and `godmode`.
- Colored the Players HP and Enemy HP to green and red. Might remove it, looks a little better than just white. I did make Gold yellow but that looked pretty lame.
- Changed `Give-Item`'s roll values. It could roll a 0 which I think technically makes it out of 11 instead of 10. It now rolls a 1 as a minimum. Dice don't have 0.
- `Give-Item` was broken because of the `If` statements. Previously it was `If ($player.Item1 -eq $false)` but the actual value was `$null`. Remember, `$null` does not mean `$false` or `$true` as it is not a Boolean value. I've now changed this to `-eq $null` but will need further care later on when more items are added and need to be switched out.
- Added `Potions` to the game. For now, `Potion of Healing` exists and is going to be given to the player at the start. The Wolf's buff ability can be pretty ridiculous if it stacks up.
- After adding `details` to the players turn, `enemy` is now an option that reveals the full stats of the current `enemy`. This will also bring up a small bit of info if Players are struggling to beat them. UI is a still a bit messy after this though. I also created a new function for this called `Get-EnemyStats`.
- Since `Potions` were added, I've also added the `Attack` potion and added a new system to buff the player for x turns. Not sure if this will just be from Potions for now, but the buff system has now been added. In order to ensure player buffs don't last forever, I've added new global hashes to the `FightStats` variable. The other stuff regarding player buffs are at the end of the player's attack turn, the same as the `enemy-attack` variable.
- Added a system for Enemies to be able to do DoT. This has been named `Debuff` rather than DoT or anything else. I think I'll save `MGKSkill` for lowering attack/defense or whatever. There's also new tags in `FightStats` that are utilised for the management of this system. I've also added the possibility to stack the DoT, causing more and more damage.
- Fixed a bug where healing to exactly `Player.MaxHP` would fail, causing no heals to occur. There was two `IF` statements, one with `-lt` and one with `-gt`, so that would be either `9` or `11`. If it landed on `10` exactly, it was being skipped even though the calculations were correct.
- Added a new enemy called the `Heloderma`, which utilises the new DoT system by stacking Poison.
- And with the DoT system, I've had to add a cap on the duration and set it to five turns. I've also forced a reroll if the enemy gets the `DebuffSkill` whilst it has a duration of more than 3 turns. I just fought the `Heloderma` and it hit `9 turns` and was doing `4 damage` along with attacking.
- I've had to cap the DoT damage system, it becomes impossible to beat in the early stages. Maybe later with higher tier enemies just change the cap limit on `FightStats.EnemyDebuffStacks`.
