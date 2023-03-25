# Created by Steven Notridge
# Some parts are useful for now but whatever.
# Might continue working on this, could be quite fun.
# V0.5b

# Main frame.
$FightStats = @{
    Turn               = 0
    Round              = 1
    EnemyBuffTurns     = 0
    BuffLimit          = 6
    EnemyBuffed        = $false
    EnemyDebuffStacks  = 0
    PlayerBuffed       = $false
    PlayerBuffTurns    = 0
    PlayerPotionActive = $false
    PlayerDebuff       = $false
    PlayerDebuffTurns  = 0
}
function Enemy-Attack {
    # Enemy attack turn
    If ($Enemy.Health -gt 0) {

        # Simulate players hand situation here.
        $EnemyChoice = Get-Random -InputObject $EnemyAttackList

        # Enemy Buff Cap reroll
        If ($EnemyChoice -eq $Enemy.MGKSkill) {
            # Check if buff is currently active. If more than 3 turns, skip?
            If ([int]$FightStats.EnemyBuffTurns -gt 3) {
                Write-Host "SYSTEM: Enemy card rerolled, buff is more than 3 turns." -ForegroundColor Blue
                Write-Host "----------------------------------------" -ForegroundColor Yellow
                # Should reroll card.
                do {
                    $EnemyChoice = Get-Random -InputObject $EnemyAttackList
                } until (
                    $EnemyChoice -ne $Enemy.MGKSkill
                )
            }
        }
        If ($EnemyChoice -eq $Enemy.DebuffSkill) {
            # Check if debuff is currently active. If more than 3 turns, skip?
            If ([int]$FightStats.PlayerDebuffTurns -gt 3) {
                Write-Host "SYSTEM: Enemy card rerolled, debuff is more than 3 turns." -ForegroundColor Blue
                Write-Host "----------------------------------------" -ForegroundColor Yellow
                # Should reroll card.
                do {
                    $EnemyChoice = Get-Random -InputObject $EnemyAttackList
                } until (
                    $EnemyChoice -ne $Enemy.DebuffSkill
                )
            }
            # Check if stacks are more than 3.
            If ([int]$FightStats.EnemyDebuffStacks -gt 3) {
                Write-Host "SYSTEM: Enemy card rerolled, debuff stacks have reached the cap." -ForegroundColor Blue
                Write-Host "----------------------------------------" -ForegroundColor Yellow
                # Should reroll card.
                do {
                    $EnemyChoice = Get-Random -InputObject $EnemyAttackList
                } until (
                    $EnemyChoice -ne $Enemy.DebuffSkill
                )
            }
        }

        # Enemy attacks
        If ($EnemyChoice -eq "Attack") {
            Write-Host "The" $Enemy.Name "Attacks!" -ForegroundColor Yellow
            $Amount = ([int]$Player.Health) - $($Enemy.Attack)
            ([int]$Player.Health) = $Amount
            Write-Host "-$($Enemy.Attack) HP" -ForegroundColor Red
            Write-Host "----------------------------------------" -ForegroundColor Yellow
        }

        If ($EnemyChoice -eq $Enemy.ATKSkill) {
            Write-Host "The" $Enemy.Name "uses their $($Enemy.ATKSkill) ability!" -ForegroundColor Yellow
            $Amount = ([int]$Player.Health) - $($Enemy.ATKSkillDMG)
            ([int]$Player.Health) = $Amount
            Write-Host "-$($Enemy.ATKSkillDMG) HP" -ForegroundColor Red
            Write-Host "----------------------------------------" -ForegroundColor Yellow
        }

        If ($EnemyChoice -eq $Enemy.MGKSkill) {
            Write-Host "The" $Enemy.Name "uses their" $Enemy.MGKSkill "ability!" -ForegroundColor Yellow
            # Check if it's a buff or attack. Might change later for DEFSkill.
            If ($Enemy.MGKBuff -eq $true) {
                # Set attack buff duration
                Write-Host "This skill buffs $($Enemy.Name) for $($Enemy.BuffTime) turns! Adding $($Enemy.MGKBuffAMT) to their Attack!"
                $Amount = ([int]$Enemy.Attack) + $($Enemy.MGKBuffAMT)
                ([int]$Enemy.Attack) = $Amount
                # Set buff duration
                # Temporarily adding an extra 1 at the end, I can't figure out the right way to keep this at the right duration without adding more if statements.
                $enemyBuffTurnAMT = ([int]$FightStats.EnemyBuffTurns) + $($Enemy.BuffTime) + 1
                $FightStats.EnemyBuffTurns = $enemyBuffTurnAMT
                Write-Host "----------------------------------------" -ForegroundColor Yellow
                # Check to see if the duration exceeds the buff limit. Reset to 6 if so.
                If ([int]$FightStats.EnemyBuffTurns -gt 6) {
                    Write-Host "SYSTEM: Enemy buff duration has exceeded five turns. This will be forced back down to 5 turns as a limitation." -ForegroundColor Blue
                    $FightStats.EnemyBuffTurns = 6
                }
                $FightStats.EnemyBuffed = $true
            }

            if ($Enemy.MGKBuff -eq $false) {
                # Currently no MGKSkillDMG in game. Keeping incase something comes later.
                $Amount = ([int]$Player.Health) - $($Enemy.MGKSkillDMG)
                ([int]$Player.Health) = $Amount
                Write-Host "-$($Enemy.MGKSkillDMG) HP" -ForegroundColor Red
                Write-Host "----------------------------------------" -ForegroundColor Yellow
            }
            # End of MGK Skill
        }

        # Enemy Buff Skill
        If ($FightStats.EnemyBuffed -eq $true) {
            # Reduce one turn at end of enemy turn.
            If ($FightStats.EnemyBuffTurns -gt 0) {
                # Get current duration then -1
                $enemyBuffTurnAMT = ([int]$FightStats.EnemyBuffTurns) - 1
                $FightStats.EnemyBuffTurns = $enemyBuffTurnAMT
                Write-Host "SYSTEM: $($Enemy.Name)'s ability, $($Enemy.MGKSkill), has $($FightStats.EnemyBuffTurns) turns left." -ForegroundColor Blue
                Write-Host "----------------------------------------" -ForegroundColor Yellow
            }

            If ($FightStats.EnemyBuffTurns -lt 1) {
                # Reset attack stat if buff expires.
                $enemy.attack = 1
                Write-Host "$($Enemy.Name)'s ability, $($Enemy.MGKSkill), has expired. Attack stat has been reset to $($Enemy.Attack)"
                $FightStats.EnemyBuffed = $false
            }
        }

        # Initialise Debuff Skill
        If ($EnemyChoice -eq $Enemy.DebuffSkill) {
            # Debuff Cap (6 because it'll activate this turn.)
            If ($FightStats.PlayerDebuffTurns -gt 6) {
                Write-Host "SYSTEM: Player debuff duration has exceeded five turns. This will be forced back down to 5 turns as a limitation." -ForegroundColor Blue
                $FightStats.EnemyBuffTurns = 6
            }
            Write-Host "The" $Enemy.Name "uses it's $($Enemy.DebuffSkill) ability! It'll last for $($Enemy.DebuffDUR) turns." -ForegroundColor Yellow
            # Config FightStats
            $FightStats.PlayerDebuff = $true
            $DebuffDuration = $FightStats.PlayerDebuffTurns + $($Enemy.DebuffDUR)
            $FightStats.PlayerDebuffTurns = $DebuffDuration
            $StackAdd = $FightStats.EnemyDebuffStacks + $Enemy.DebuffDMG
            $FightStats.EnemyDebuffStacks = $StackAdd
            Write-Host "----------------------------------------" -ForegroundColor Yellow
        }
        
        # Config for DoT's
        If ($FightStats.PlayerDebuff -eq $true) {
            # Debuff Active
            If ($FightStats.PlayerDebuffTurns -gt 0) {
                $PlayerDebuffAMT = ([int]$FightStats.PlayerDebuffTurns) - 1
                $FightStats.PlayerDebuffTurns = $PlayerDebuffAMT
                # Do the damage
                $Amount = ([int]$Player.Health) - $($FightStats.EnemyDebuffStacks)
                ([int]$Player.Health) = $Amount
                Write-Host "-$($FightStats.EnemyDebuffStacks) HP from $($Enemy.DebuffSkill)." -ForegroundColor Red
                Write-Host "SYSTEM: $($Enemy.DebuffSkill) has $($FightStats.PlayerDebuffTurns) turns left." -ForegroundColor Blue
                Write-Host "SYSTEM: $($Enemy.DebuffSkill) has $($FightStats.EnemyDebuffStacks) stacks." -ForegroundColor Blue
                Write-Host "----------------------------------------" -ForegroundColor Yellow
                
            }
            # Debuff Deactivated (Still activates after doing the IF statement above)
            If ($FightStats.PlayerDebuffTurns -lt 1) {
                $FightStats.PlayerDebuff = 0
                $FightStats.EnemyDebuffStacks = 0
                $FightStats.PlayerDebuff = $false
                Write-Host "SYSTEM: $($Enemy.DebuffSkill) has expired." -ForegroundColor Blue
                Write-Host "----------------------------------------" -ForegroundColor Yellow
            }
        }
    }
}

function Start-UI {

    $TurnAdd = ([int]$FightStats.Turn) + 1
    $FightStats.Turn = $TurnAdd

    # Turn Stats
    $HPMessage = Write-Host "Your HP" -ForegroundColor Green -NoNewline
    Write-Host $($HPMessage) "=" $($Player.Health)
    $EnemyHPMSG = Write-Host "$($Enemy.Name) HP" -ForegroundColor Red -NoNewline
    Write-Host $($EnemyHPMSG) "=" $($Enemy.Health)
    Write-Host "Turn:" $FightStats.Turn
    Write-Host "Round:" $FightStats.Round
    Write-Host "Gold:" $($Player.Gold)

    # Show Hand
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    Write-Host "Your hand is:" $Hand[0], $Hand[1], $Hand[2] -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Yellow

}

function Start-Shop {
    param(
        [string]$ShopTier
    )

    # Import the WinForms module
    Add-Type -AssemblyName System.Windows.Forms

    # Define the initial amount of gold and equipped items
    $gold = 100
    $equippedItems = @()

    # Create a new form object
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Select an item"
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.Size = New-Object System.Drawing.Size(500, 300)

    # Create a label object to display instructions
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 10)
    $label.Size = New-Object System.Drawing.Size(200, 20)
    $label.Text = "Please select an item:"
    $form.Controls.Add($label)

    # Create a list box object to display selectable items
    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10, 30)
    $listBox.Size = New-Object System.Drawing.Size(200, 100)
    $form.Controls.Add($listBox)

    # Create a label object to display the current amount of gold
    $goldLabel = New-Object System.Windows.Forms.Label
    $goldLabel.Location = New-Object System.Drawing.Point(10, 140)
    $goldLabel.Size = New-Object System.Drawing.Size(200, 20)
    $goldLabel.Text = "Gold: $($gold)"
    $form.Controls.Add($goldLabel)

    # Create a list box object to display equipped items
    $equippedListBox = New-Object System.Windows.Forms.ListBox
    $equippedListBox.Location = New-Object System.Drawing.Point(220, 30)
    $equippedListBox.Size = New-Object System.Drawing.Size(200, 100)
    $form.Controls.Add($equippedListBox)

    # Create a label object to display the currently equipped items
    $equippedLabel = New-Object System.Windows.Forms.Label
    $equippedLabel.Location = New-Object System.Drawing.Point(220, 10)
    $equippedLabel.Size = New-Object System.Drawing.Size(200, 20)
    $equippedLabel.Text = "Equipped items:"
    $form.Controls.Add($equippedLabel)

    # Define the items with their prices and properties
    $items = @(
        [PSCustomObject]@{ Name = "Item 1"; Price = 10.99; Type = "Weapon" }
        [PSCustomObject]@{ Name = "Item 2"; Price = 240.99; Type = "Armor" }
        [PSCustomObject]@{ Name = "Item 3"; Price = 5.99; Type = "Consumable" }
    )

    # Add the items to the list box
    foreach ($item in $items) {
        $listBox.Items.Add("$($item.Name) - $($item.Price) gold - $($item.Type)")
    }

    # Create an OK button to close the form
    $button = New-Object System.Windows.Forms.Button
    $button.Location = New-Object System.Drawing.Point(70, 170)
    $button.Size = New-Object System.Drawing.Size(75, 23)
    $button.Text = "Buy"
    $button.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $button
    $form.Controls.Add($button)

    # Create an Exit button to close the form
    $Exitbutton = New-Object System.Windows.Forms.Button
    $Exitbutton.Location = New-Object System.Drawing.Point(280, 170)
    $Exitbutton.Size = New-Object System.Drawing.Size(75, 23)
    $Exitbutton.Text = "Exit"
    $Exitbutton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.AcceptButton = $Exitbutton
    $form.Controls.Add($Exitbutton)

    # Show the form and wait for the user to select an item
    $result = $form.ShowDialog()


    # Repeat window until user buys or leaves.
    Do {
        # Check if the user clicked OK and get the selected item
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            $selectedIndex = $listBox.SelectedIndex
            $selectedItem = $items[$selectedIndex]
            if ($selectedItem.Price -le $gold) {
                $gold -= $selectedItem.Price
                Write-Host "You purchased $($selectedItem.Name) for $($selectedItem.Price) gold."
                Write-Host "You now have $($gold) gold remaining."
                $ShopFinish = $true
            } 
            if ($selectedItem.Price -gt $gold) {
                Write-Host "You do not have enough gold to purchase $($selectedItem.Name)."
                # Display an error message popup
                [System.Windows.Forms.MessageBox]::Show("You do not have enough gold to purchase $($selectedItem.Name).", "Insufficient Funds", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                $form.ShowDialog()
                $ShopFinish = $false
            }
        }
    } until (
        $ShopFinish -eq $true
    )

    Write-Host "You leave the shop."

    # Update the gold label
    $goldLabel.Text = "Gold: $($gold)"

    # Dispose of the form object
    $form.Dispose()

}

function Restart-UI {
    # Like the Start-UI function, except it shouldn't affect the Turns

    # Clearing screen
    Clear-Host

    Write-Host "----------------------------------------" -ForegroundColor Yellow
    # Turn Stats
    $HPMessage = Write-Host "Your HP" -ForegroundColor Green -NoNewline
    Write-Host $($HPMessage) "=" $($Player.Health)
    $EnemyHPMSG = Write-Host "$($Enemy.Name) HP" -ForegroundColor Red -NoNewline
    Write-Host $($EnemyHPMSG) "=" $($Enemy.Health)
    Write-Host "Turn:" $FightStats.Turn
    Write-Host "Round:" $FightStats.Round
    Write-Host "Gold:" $($Player.Gold)

    # Show Hand
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    Write-Host "Your hand is:" $Hand[0], $Hand[1], $Hand[2] -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Yellow

}

function Player-Attack {

    If ($Hand -match $Choice) {
        Switch ($Choice) {
            Smash {
                $Smash = 3 * $Player.Attack
                $Amount = ([int]$Enemy.Health) - $Smash
                Write-Host "You Smash the enemy, dealing $($Smash) damage!" -ForegroundColor Yellow
                $Enemy['Health'] = $Amount
                Write-Host "----------------------------------------" -ForegroundColor Yellow
            }
            Stab {
                Write-Host "You stab the enemy, dealing $($Player.Attack) damage!" -ForegroundColor Yellow
                $Amount = ([int]$Enemy.Health) - $($Player.Attack)
                $Enemy['Health'] = $Amount
                Write-Host "----------------------------------------" -ForegroundColor Yellow
            }
            Heal {
                # Initial Message and calculation
                Write-Host "You heal yourself!" -ForegroundColor Yellow
                $HealCalc = 3 + ([int]$Player.Magic)
                $Amount = ([int]$Player.Health) + $HealCalc

                # Max HP Check
                # If HP is less than Max
                if ($Amount -lt $Player.MaxHP) {
                    ([int]$Player.Health) = $Amount
                    Write-Host "+$($HealCalc) HP (Total = $([int]$Player.Health))" -ForegroundColor Green
                }
                # If HP is exactly Max
                If ($Amount -eq $Player.MaxHP) {
                    ([int]$Player.Health) = $Amount
                    Write-Host "+$($HealCalc) HP (Total = $([int]$Player.Health))" -ForegroundColor Green
                }
                # If HP is more than Max
                if ($Amount -gt $Player.MaxHP) {
                    Write-Host "SYSTEM: Cannot heal above" $Player.MaxHP "(Max HP)" -ForegroundColor Blue
                    ([int]$Player.Health) = ([int]$Player.MaxHP)
                    Write-Host "HP has been fully restored! (Total = $([int]$Player.Health))" -ForegroundColor Green
                }
                Write-Host "----------------------------------------" -ForegroundColor Yellow
            }
        }
    }

    # Stuff for Player Buffs
    If ($FightStats.PlayerBuffed -eq $true) {
        # Reduce one turn at end of enemy turn.
        If ($FightStats.PlayerBuffTurns -gt 0) {
            # Get current duration then -1
            $PlayerBuffTurnAMT = ([int]$FightStats.PlayerBuffTurns) - 1
            $FightStats.PlayerBuffTurns = $PlayerBuffTurnAMT
            Write-Host "SYSTEM: $($Player.Name)'s buff has $($FightStats.PlayerBuffTurns) turns left." -ForegroundColor Blue
            Write-Host "----------------------------------------" -ForegroundColor Yellow
        }

        # Reset Global Player Stuff
        If ($FightStats.PlayerBuffTurns -lt 1) {
            # Reset attack stat if buff expires.
            $Player.Attack = $Player.PrebuffATK
            Write-Host "Player's buff has expired. Attack stat has been reset to $($Player.PrebuffATK)"
            $FightStats.PlayerBuffed = $false
        }
    }
    return $PlayerATK
}

function Deal-Hand {

    # Reroll Hand.
    $Hand = @()
    $Card1 = Get-Random -InputObject $Deck
    $Card2 = Get-Random -InputObject $Deck
    $Card3 = Get-Random -InputObject $Deck

    # Check hand for duplicate heals.
    If ($Card1 -eq "Heal") {

        # Check Card2 
        If ($Card2 -eq "Heal") {
            Do {
                Write-Host "SYSTEM: Rerolling Card 2 because Card 1 was a heal." -ForegroundColor Blue
                Write-Host "----------------------------------------" -ForegroundColor Yellow
                $Card2 = Get-Random -InputObject $Deck
            }
            Until($Card2 -ne "Heal")
        }

        # Check Card3
        If ($Card3 -eq "Heal") {
            Do {
                Write-Host "SYSTEM: Rerolling Card 3 because Card 1 was a heal." -ForegroundColor Blue
                Write-Host "----------------------------------------" -ForegroundColor Yellow
                $Card3 = Get-Random -InputObject $Deck
            }
            Until($Card3 -ne "Heal")
        }
    }
    # Check if Card2 is heal
    If ($Card2 -eq "Heal") {
        # Only check Card3 because it would have to successfully pass Card1 check.
        If ($Card3 -eq "Heal") {
            Do {
                Write-Host "SYSTEM: Rerolling Card 3 because Card 2 was a heal." -ForegroundColor Blue
                Write-Host "----------------------------------------" -ForegroundColor Yellow
                $Card3 = Get-Random -InputObject $Deck
            }
            Until($Card3 -ne "Heal")
        }
    }
    # Check if Card3 is heal
    If ($Card3 -eq "Heal") {
        # Only check Card2 because it would have to successfully pass Card1 check.
        If ($Card2 -eq "Heal") {
            Do {
                Write-Host "SYSTEM: Rerolling Card 2 because Card 3 was a heal." -ForegroundColor Blue
                Write-Host "----------------------------------------" -ForegroundColor Yellow
                $Card3 = Get-Random -InputObject $Deck
            }
            Until($Card3 -ne "Heal")
        }
    }

    # Deal fixed hand.
    $Hand = @($Card1, $Card2, $Card3)

    # Insult player's RNG.
    If ($Card1 -match "Stab") {
        if ($Card2 -match "Stab") {
            if ($Card3 -match "Stab") {
                Write-Host "SYSTEM: Snake Eyes..." -ForegroundColor Blue
                Write-Host "----------------------------------------" -ForegroundColor Yellow
            }
        }
    }

    # Return result to outside of the Array.
    return $Hand
}

function Use-Potion {

    # Healing Potion
    If ($Player.Potion -eq "Healing") {
        ([int]$Player.Health) = ([int]$Player.MaxHP)
        Write-Host "HP has been fully restored! (Total = $([int]$Player.Health))" -ForegroundColor Green
        $Player.PotionEQP = $false
        $Player.Potion = $null
    }

    # Attack Potion
    If ($Player.Potion -eq "Attack") {
        ([int]$Player.Attack) = ([int]$Player.Attack) + 2
        Write-Host "Your Attack stat has been buffed for 2 turns! (Total = $([int]$Player.Attack))" -ForegroundColor Green
        $Player.PotionEQP = $false
        $Player.Potion = $null
        $FightStats.PlayerPotionActive = $true
        $FightStats.PlayerBuffed = $true
        $FightStats.PlayerBuffTurns = 2
    }
}

function Get-GameHelp {
    # Load the Windows Forms assembly
    Add-Type -AssemblyName System.Windows.Forms

    # Create a form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Command Help List"
    $form.Size = New-Object System.Drawing.Size(500, 300)
    $form.StartPosition = "CenterScreen"

    # Create a list box with some subjects
    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Items.AddRange(@("Details", "Player", "Enemy"))
    $listBox.Location = New-Object System.Drawing.Point(20, 20)
    $form.Controls.Add($listBox)

    # Create a text box to display help information
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Multiline = $true
    $textBox.ReadOnly = $true
    $textBox.ScrollBars = "Vertical"
    $textBox.Size = New-Object System.Drawing.Size(300, 200)
    $textBox.Location = New-Object System.Drawing.Point(150, 20)
    $form.Controls.Add($textBox)

    # Create a hashtable to store help information
    $helpInfo = @{
        "Details" = "You can use this command to get more details about the current fight that's occuring."
        "Player"  = "This displays information about your Character."
        "Enemy"   = "This displays information about the enemy you are fighting."
    }

    # Add an event handler to the list box to display help information for the selected subject
    $listBox.Add_SelectedIndexChanged({
            $selectedSubject = $listBox.SelectedItem.ToString()
            $textBox.Text = $helpInfo[$selectedSubject]
        })

    # Show the form
    $form.ShowDialog() | Out-Null

}

function Start-Battle {

    # Sort Hand
    $Hand = Deal-Hand

    # Display UI
    Start-UI

    # Player chooses a card.
    do {
        
        $Choice = Read-Host "Which Card?"

        # Maybe I should do anoter Do Until here? do $Choice until $Choice -eq $Hand?
        If ($Choice -eq "details") {
            Write-Host "Details below."
            # $FightStats | % { [PSCustomObject]$_ } 

            Read-Host "Continue?"
            Restart-UI
            # $Choice = Read-Host "Which Card?"
        }

        If ($Choice -eq "player") {
            Write-Host "Player Details below."
            Write-Host "----------------------------------------" -ForegroundColor Yellow
            # $Player | Select-Object Name, Health, MaxHp, Attack, Magic, Defence, Gold, Item1, Item2, Item3, Potion
            $Player | % { [PSCustomObject]$_ } | Sort-Object -Property Name | Format-Table Name, Level, Health, MaxHp, Attack, Magic, Defence, Gold, Experience -Autosize
            $PlayerItems = $Player | Select-Object Item1, Item2, Item3, Potion
            $PlayerItems | Out-String
            Write-Host "----------------------------------------" -ForegroundColor Yellow
            $Player.Stats | % { [PSCustomObject]$_ } | Sort-Object -Property Stats | Format-Table Name, Amount -Autosize
            Write-Host "----------------------------------------" -ForegroundColor Yellow
        
            Read-Host "Continue?"
            Restart-UI
            # $Choice = Read-Host "Which Card?"
        }

        If ($Choice -eq "godmode") {
            Write-Host "god mode enabled."
            $Player.Health = 999
            $Player.MaxHP = 999

            # Read-Host "Continue?"
            # $Choice = Read-Host "Which Card?"
        }

        If ($Choice -eq "enemy") {
            Write-Host "Enemy Details below."
            Write-Host "----------------------------------------" -ForegroundColor Yellow
            Get-EnemyStats
            Write-Host "----------------------------------------" -ForegroundColor Yellow
            Read-Host "Continue?"
            Restart-UI
            # $Choice = Read-Host "Which Card?"
        }

        If ($Choice -eq "help") {
            Get-GameHelp
        }

        If ($Choice -eq "Potion") {
            If ($Player.PotionEQP -eq $true) {
                $PotChoice = Read-Host "Do you want to use your Potion of $($Player.Potion)?"

                If ($PotChoice -match "[yY]") {
                    Use-Potion
                    # $Choice = Read-Host "Which Card?"
                }
                If ($PotChoice -match "[nN]") {
                    # $Choice = Read-Host "Which Card?"
                }
            }
            Else {
                Write-Host "You don't have any potions..."
                # Read-Host "Continue?"
                # $Choice = Read-Host "Which Card?"
            }

        }
        # Just repeat it until player actually plays something correct.
        # If($Hand -notmatch $Choice){
        #     Write-Host "Incorrect card." -ForegroundColor Red
        #     $Choice = Read-Host "Which Card?"
        # }

        # Doesn't work properly.
        If ([bool]$Choice -eq $false) {
            Write-Host "You must choose a card."
            Read-Host "Continue?"
            Restart-UI
        }

    }
    
    until (
        $Hand -match $Choice
    )

    # Cleanup screen
    Clear-Host

    # UI
    Write-Host "----------------------------------------" -ForegroundColor Yellow

    # Player Attack phase
    Player-Attack | Tee-Object -Variable PlayATK
    
    # Buffer
    Start-Sleep 1

    # Enemy attacking phase
    $EnemyAttack = Enemy-Attack

    Start-Sleep 1

    # End game if HP reaches 0
    If ($Player.Health -lt 1) {
        Write-Host "You DIED!" -ForegroundColor Red
        exit
    }
}

function Give-Item {
    (
        # Parameter help description
        [Parameter()][String]$Item
    )
    If ($enemy.dead -eq $true) {

        # TODO:
        # Need to add a check for Item1/2 -eq $true and see if Player wants to swap.

        # Roll for the item.
        $Roll = Get-Random -Minimum 1 -Maximum 10
        Write-Host "----------------------------------------" -ForegroundColor Yellow
        Write-Host "You attempt to roll for an item. You need 5 or higher to get one." -ForegroundColor Cyan
    
        If ($Roll -gt 4) {
            Write-Host "You rolled: $Roll!" -ForegroundColor Green

            # Spider's Item
            if ($enemy.Name -eq "Spider") {
                if ($Player.Item1 -eq $null) {
                    # Item Stats
                    $SpiderFang = @{
                        Name    = "Spider Fang"
                        Attack  = "1"
                        Details = "Spider Fang adds an additional +1 to the Players Attack."
                    }
                    # UI Stuff
                    Write-Host "----------------------------------------" -ForegroundColor Yellow
                    Write-Host "You rip out one of the spiders fangs and decide to use it as a weapon!"
                    Start-Sleep 1
                    Write-Host "Spider Fang obtained!" -ForegroundColor Green
                    Start-Sleep 1
                    Write-Host "$($SpiderFang.Details)" -ForegroundColor Cyan

                    # Add to inventory
                    $Player.Item1 += $SpiderFang
                    $Amount = ([int]$Player.Attack) + 1
                    ([int]$Player.Attack) = $Amount

                    # Changing Prebuff Attack incase of Potion use or something else. (Not sure about this now?)
                    $Amount = ([int]$Player.PreBuffATK) + 1
                    ([int]$Player.PrebuffATK) = $Amount
                }
            }
            # End Spider Fang

            # Ogre's Eyes
            if ($enemy.Name -eq "Ogre") {
                if ($Player.Item2 -eq $null) {
                    # Item Stats
                    $OgreEye = @{
                        Name    = "Ogre's Eye"
                        Magic   = 1
                        Details = "Ogre's eye increases Players Magic by +1." 
                    }

                    # UI Stuff
                    Write-Host "----------------------------------------" -ForegroundColor Yellow
                    $Blood = Write-Host "blood" -ForegroundColor Red
                    Write-Host "You rip out one of the Ogre's eyes with your bare hands, as $blood covers your hands."
                    Start-Sleep 1
                    Write-Host "As you hold it within the palm of your hand, you feel a strange sensation flow within you."
                    Write-Host "You tie some string around it, and hang it from your waist."
                    Start-Sleep 2
                    Write-Host "Ogre's Eye obtained!" -ForegroundColor Green
                    Start-Sleep 1
                    Write-Host "$($OgreEye.Details)" -ForegroundColor Cyan

                    # Add to inventory
                    $Player.Item2 += $OgreEye
                    $Amount = ([int]$Player.Magic) + 1
                    ([int]$Player.Magic) = $Amount
                }
                # End Ogre's Eyes
            }
        }
        else {
            Write-Host "You rolled: $Roll" -ForegroundColor Cyan
        }
        # End of roll If statement.
        Write-Host "----------------------------------------" -ForegroundColor Yellow
    }
    If ($enemy.dead -eq $false) {
        If ($Item -match "Spider Fang") {
            Write-Host "Spider Fang obtained!"
            Write-Host "DEBUG: Apply stats."
            # Add to inventory
            $Player.Item1 += $SpiderFang
            $Amount = ([int]$Player.Attack) + 1
            ([int]$Player.PrebuffATK) = $Amount
        }
    }
}

function Give-Gold {
    If ($enemy.dead -eq $true) {

        # Lowtier Gold drop
        if ($LowTierEnemyNames -contains $($Enemy.Name)) {
            $Gold = Get-Random -Minimum 50 -Maximum 150
            $GoldAdd = ([int]$Player.Gold) + $Gold
            Write-Host "You have gained $($Gold) Gold for killing the $($Enemy.Name)!" -ForegroundColor Yellow
            $Player.Gold = $GoldAdd
        }
    }
}

function Enemy-AttackList {

    If ($Enemy -eq $Ogre) {
        $EnemyAttackList = @($Enemy.ATKSkill, "Attack", "Attack", "Attack", "Attack")
        return $EnemyAttackList
    }
    
    If ($Enemy -eq $Spider) {
        $EnemyAttackList = @($Enemy.ATKSkill, "Attack", "Attack", "Attack")
        return $EnemyAttackList
    }

    If ($Enemy -eq $Wolf) {
        # Normal Attack list
        # EnemyAttackList = @("$($Enemy.MGKSkill)", "Attack", "Attack", "Attack")

        # Test Buff List
        $EnemyAttackList = @("$($Enemy.MGKSkill)", "Attack")
        return $EnemyAttackList
    }

    If ($Enemy -eq $Heloderma) {
        $EnemyAttackList = @($Enemy.DebuffSkill, "Attack", "Attack")
        return $EnemyAttackList
    }

}

function Enemy-HPReset {
    # Reset Global variables
    $FightStats.EnemyBuffed = $false
    $FightStats.EnemyBuffTurns = 0

    If ($enemy.Name -eq "Spider") {
        # Reset mob hp.
        $Spider.Health = 10
    }
    
    If ($enemy.Name -eq "Ogre") {
        # Reset mob hp.
        $Ogre.Health = 15
    }

    If ($enemy.Name -eq "Wolf") {
        # Reset mob hp.
        $Wolf.Health = 10
        $Wolf.Attack = 1
    }

    If ($Enemy.Name -eq "Heloderma") {
        # Reset mob hp.
        $Heloderma.Health = 12
    }
}

function Start-Round {
    Do {
        Start-Battle
    }
    Until($Enemy.Health -lt 1)
    Write-Host "You win!" -ForegroundColor Green

    # Add to Round counter.
    $RoundAdd = ([int]$FightStats.Round) + 1
    $FightStats.Round = $RoundAdd
    $Enemy.Dead = $true

    Write-Host "The" $Enemy.Name "lies dead on the floor infront of you." -ForegroundColor Yellow
    Start-Sleep 1

    If ($enemy.dead -eq $true) {

        # Roll for an item after killing mob.
        Give-Item
        
        # Give the Player gold.
        Give-Gold

        Read-Host "Press any key to continue"

        # HP Resets
        Enemy-HPReset

        # Reset the players debuff stacks, like poison etc.
        $FightStats.PlayerDebuff = 0
        $FightStats.EnemyDebuffStacks = 0
        $FightStats.PlayerDebuff = $false
        $FightStats.PlayerDebuffTurns = 0
        $Enemy.DebuffDuration = 0

        # Turn counter reset
        ([int]$FightStats.Turn) = 0

    }
}

function Get-EnemyStats {
    $EnemyDetails = @()

    If ([bool]$enemy.MGKSkill -eq $false) {
        $EnemyMGKSkill = "N/A"
        $EnemyBuffAMT = "N/A"
        $EnemyMGKBufftime = "N/A"
    }
    If ([bool]$enemy.MGKSkill -eq $true) {
        $EnemyMGKSkill = $Enemy.MGKSkill
        $EnemyBuffAMT = $Enemy.MGKBuffAMT
        $EnemyMGKBuffTime = $Enemy.Bufftime
    }
    If ([bool]$Enemy.ATKSkill -eq $false) {
        $EnemyATKSkill = "N/A"
        $EnemyATKSkillDMG = "N/A"
    }
    If ([bool]$Enemy.ATKSkill -eq $true) {
        $EnemyATKSkill = $Enemy.ATKSkill
        $EnemyATKSkillDMG = $Enemy.ATKSkillDMG
    }
    If ([bool]$Enemy.DebuffSkill -eq $true) {
        $EnemyDebuffSkill = $Enemy.DebuffSkill
        $EnemyDebuffDuration = $Enemy.DebuffDUR
        $EnemyDebuffDMG = $Enemy.DebuffDMG
    }
    If ([bool]$Enemy.DebuffSkill -eq $false) {
        $EnemyDebuffSkill = "N/A"
        $EnemyDebuffDuration = "N/A"
        $EnemyDebuffDMG = "N/A"
    }

    $EnemyDetails += New-Object -Type PSObject -Property @{
        Name           = $Enemy.Name
        Health         = $Enemy.Health
        Attack         = $Enemy.Attack
        AttackSkill    = $EnemyATKSkill
        ATKSkillDMG    = $EnemyATKSkillDMG
        MGKSkill       = $EnemyMGKSkill
        MGKBuffAMT     = $EnemyBuffAMT
        BuffTime       = $EnemyMGKBufftime
        DebuffSkill    = $EnemyDebuffSkill
        DebuffDuration = $EnemyDebuffDuration
        DebuffDMG      = $EnemyDebuffDMG
        Block          = $Enemy.Block
        Info           = $Enemy.Details
    }
    $EnemyDetails = $EnemyDetails | Select-Object Name, Health, Attack, AttackSkill, ATKSkillDMG, MGKSkill, MGKBuffAMT, BuffTime, DebuffSkill, DebuffDuration, DebuffDMG, Block, Info
    return $EnemyDetails | Out-String
}

# function Start-Shop2{
#     # IDK how to deal with the gold costs of items yet.

#     # may need to remove this
#     Clear-Host

#     # UI
#     Write-Host "----------------------------------------" -ForegroundColor Yellow
#     Write-Host "The shopkeeper is an old man with a disgustingly large wart on the right side of his nose, a smell of cigarettes and filth pollute the air around you."
#     Write-Host """Would you like to buy anything?""" -ForegroundColor Yellow
#     Write-Host "He asks, as he shows off what teeth he has left with an uncomfortable smile."
#     Write-Host "----------------------------------------" -ForegroundColor Yellow

#     # Reroll Shop.
#     $ShopHand = @()
#     $Shop1 = Get-Random -InputObject $Shop
#     $Shop2 = Get-Random -InputObject $Shop
#     $Shop3 = Get-Random -InputObject $Shop
#     $ShopHand = ($Shop1, $Shop2, $Shop3)

#     Write-Host "Gold:" $($Player.Gold)
#     # Show Hand
#     Write-Host "----------------------------------------" -ForegroundColor Yellow
#     Write-Host "The shopkeep has:" $ShopHand[0], $ShopHand[1], $ShopHand[2] -ForegroundColor Cyan
#     Write-Host "----------------------------------------" -ForegroundColor Yellow

#     Write-Host "INFO: You can type the name of the item if you'd like to buy it, or Exit to leave the shop."
#     $Choice = Read-Host "Choice"

#     If($ShopHand -contains $Choice){
#         Write-Host "You inquire about the $Choice with the Shopkeeper..."
#     }

#     If($Choice -match "Exit"){
#         return
#     }
# }

function Level-Up {

    # Give XP for enemy dying, though this might be useful to just add to the Enemy-HPReset function.
    If ($Enemy.Dead -eq $true) {
        If ($Enemy.Tier -eq "Low") {
            $XP = Get-Random -Minimum 50 -Maximum 100
            $Amount = $XP + $Player.Experience
            $Player.Experience = $Amount
        }
        If ($enemy.Tier -eq "Mid") {
            $XP = Get-Random -Minimum 125 -Maximum 250
            $Amount = $XP + $Player.Experience
            $Player.Experience = $Amount
        }
        If ($Enemy.Tier -eq "High") {
            $XP = Get-Random -Minimum 300 -Maximum 500
            $Amount = $XP + $Player.Experience
            $Player.Experience = $Amount
        }
    }

    # Level up if threshold reached and reset to zero.
}

# Player setup
$Player = @{
    Name       = "Player"
    Health     = 10
    MaxHP      = 10
    Magic      = 0
    PrebuffATK = 1
    Attack     = 1
    Defence    = 0
    Item1      = $null
    Item2      = $null
    Item3      = $null
    PotionEQP  = $true
    Potion     = "Attack"
    Gold       = 0
    Experience = 0
    Level      = 1
    Stats      = @( @{Name = "Strength"; Amount = 1 },
        @{Name = "Magic"; Amount = 1 },
        @{Name = "Defence"; Amount = 1 } 
    )
}

$Deck = @("Smash", "Stab", "Stab", "Stab", "Stab", "Heal")

$Shop = @("Potion of Healing", "Potion of Attack", "Spider Fang", "Ogre Eye", "Golems Blessing")

# Spider details
$Spider = @{
    Name        = "Spider"
    Health      = 10
    Attack      = 1
    ATKSkill    = "Venom"
    ATKSkillDMG = 3
    Block       = 2
    Dead        = $false
    Tier        = "Low"
    Details     = "The Spider is a pretty standard foe, don't let it catch you off guard with low health as Venom can quickly dispose of your HP pool if it gets lucky rolls."
}

# Wolf details
$Wolf = @{
    Name       = "Wolf"
    Health     = 10
    Attack     = 1
    MGKSkill   = "Howl"
    MGKBuff    = $true
    MGKBuffAMT = 1
    BuffTime   = 3
    Block      = 2
    Dead       = $false
    Tier       = "Low"
    Details    = "The Wolf shouldn't be underestimated. Kill it quick before it starts building up it's stacks from Howl. The attack buff only wears off if the buff duration ends."
}

# Heloderma details
$Heloderma = @{
    Name        = "Heloderma"
    Health      = 12
    Attack      = 1
    DebuffSkill = "Poison"
    DebuffDMG   = 1
    DebuffDUR   = 3
    Block       = 2
    Dead        = $false
    Tier        = "Low"
    Details     = "Watch out for their poison debuff, the amount can stack ontop of itself and cause severe damage. Hit hard or get faded."
}

# Ogre details
$Ogre = @{
    Name        = "Ogre"
    Health      = 15
    Attack      = 1
    ATKSkill    = "Slam"
    ATKSKILLDMG = 4
    Block       = 2
    Dead        = $false
    Tier        = "Mid"
    Details     = "The Ogre hits hard and can be tedious to kill with bad rolls. Don't underestimate spamming your heal when you can and be prepared to play the long game."
}

# Enemy related variables
# $LowTierEnemyNames = @("Spider", "Wolf", "Heloderma")
# $LowTierEnemyList = @($Spider, $Wolf, $Heloderma)

# Testing enemy related variables
$LowTierEnemyNames = @("Heloderma")
$LowTierEnemyList = @($Heloderma)

# Fighting
Do {
    If ($Round -lt 3) {
        # Enemy Setup
        $Enemy = Get-Random -InputObject $LowTierEnemyList 
        $EnemyAttackList = Enemy-AttackList
        
        # Clear UI. This happens after user starts the game.
        Clear-Host

        # Short Intro
        Write-Host "----------------------------------------" -ForegroundColor Yellow
        Write-Host "As you walk down a narrow path, you're suddenly met with a foe!"
        Write-Host "You've encountered a wild" $($Enemy.Name)"!"
        Write-Host "----------------------------------------" -ForegroundColor Yellow
        Start-Sleep 1

        # Player vs Enemy time
        Start-Round

        Start-Sleep 1
            
    }
}
Until($Round -gt 3)

Write-Host "Stepping over the foul creature, you make your way further down the path."
Start-Sleep 1
Write-Host "But to no surprise, another monster attacks!"

$Enemy.Death = $false

$Enemy = Get-Random -InputObject $EnemyList

Start-Sleep 1
Write-Host "You've encountered a wild" $($Enemy.Name)"!"
Write-Host "----------------------------------------" -ForegroundColor Yellow
Start-Sleep 3

# Player vs Enemy time 2
Start-Round

Write-Host "You win!" -ForegroundColor Green

# Add to Round counter.
$RoundAdd = ([int]$Round) + 1
$Round = $RoundAdd

$Enemy.Dead = $true
