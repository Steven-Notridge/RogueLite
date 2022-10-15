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