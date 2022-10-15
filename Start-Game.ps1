# Created by Steven Notridge
# Some parts are useful for now but whatever.
# Might continue working on this, could be quite fun.
# V0.3

# Main frame.
$Turn = 1
$Round = 1
$Item = @()

function Enemy-Attack {
    # Enemy attack turn
    If($Enemy.Health -gt 0){

        # Simulate players hand situation here.
        $EnemyChoice = Get-Random -InputObject $EnemyAttackList

        # Enemy attacks
        If($EnemyChoice -match "Attack"){
            Write-Host "The" $Enemy.Name "Attacks!" -ForegroundColor Yellow
            $Amount = ([int]$Player.Health) - $($Enemy.Attack)
            ([int]$Player.Health) = $Amount
            Write-Host "-$($Enemy.Attack) HP" -ForegroundColor Red
            Write-Host "----------------------------------------" -ForegroundColor Yellow
        }
        If($EnemyChoice -match $Enemy.Skill1){
            Write-Host "The" $Enemy.Name "uses it's $($Enemy.Skill1) ability!" -ForegroundColor Yellow
            $Amount = ([int]$Player.Health) - $($Enemy.Skill1DMG)
            ([int]$Player.Health) = $Amount
            Write-Host "-$($Enemy.Skill1DMG) HP" -ForegroundColor Red
            Write-Host "----------------------------------------" -ForegroundColor Yellow
        }
    }

}

function Start-UI {

    # Turn Stats
    Write-Host "Your HP =" $($Player.Health)
    Write-Host "$($Enemy.Name)"HP" = $($Enemy.Health)"
    Write-Host "Turn:" $Turn
    Write-Host "Round:" $Round

    # Show Hand
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    Write-Host "Your hand is:" $Hand[0], $Hand[1], $Hand[2] -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Yellow

}

function Player-Attack {

    If($Hand -match $Choice){
        Switch ($Choice)
        {
            Smash
            {
                $Smash = 3 * $Player.Attack
                $Amount = ([int]$Enemy.Health) - $Smash
                Write-Host "You Smash the enemy, dealing $($Smash) damage!" -ForegroundColor Yellow
                $Enemy['Health'] = $Amount
                Write-Host "----------------------------------------" -ForegroundColor Yellow
            }
            Stab
            {
                Write-Host "You stab the enemy, dealing $($Player.Attack) damage!" -ForegroundColor Yellow
                $Amount = ([int]$Enemy.Health) - $($Player.Attack)
                $Enemy['Health'] = $Amount
                Write-Host "----------------------------------------" -ForegroundColor Yellow
            }
            Heal
            {
                Write-Host "You heal yourself!." -ForegroundColor Yellow
                $HealCalc = 3 + ([int]$Player.Magic)
                Write-Host "+$($HealCalc) HP" -ForegroundColor Green
                $Amount = ([int]$Player.Health) + $HealCalc
                ([int]$Player.Health) = $Amount
                Write-Host "----------------------------------------" -ForegroundColor Yellow
            }
        }
    }
}

function Deal-Hand {

    # Reroll Hand.
    $Hand = @()
    $Card1 = Get-Random -InputObject $Deck
    $Card2 = Get-Random -InputObject $Deck
    $Card3 = Get-Random -InputObject $Deck

        # Check hand for duplicate heals.
        If($Card1 -eq "Heal"){

            # Check Card2 
            If($Card2 -eq "Heal"){
                Do{
                    Write-Host "SYSTEM: Rerolling Card 2 because Card 1 was a heal." -ForegroundColor Blue
                    Write-Host "----------------------------------------" -ForegroundColor Yellow
                $Card2 = Get-Random -InputObject $Deck
                }
                Until($Card2 -ne "Heal")
            }

            # Check Card3
            If($Card3 -eq "Heal"){
                    Do{
                        Write-Host "SYSTEM: Rerolling Card 3 because Card 1 was a heal." -ForegroundColor Blue
                        Write-Host "----------------------------------------" -ForegroundColor Yellow
                    $Card3 = Get-Random -InputObject $Deck
                    }
                    Until($Card3 -ne "Heal")
            }
        }
            # Check if Card2 is heal
            If($Card2 -eq "Heal"){
                # Only check Card3 because it would have to successfully pass Card1 check.
                If($Card3 -eq "Heal"){
                    Do{
                        Write-Host "SYSTEM: Rerolling Card 3 because Card 2 was a heal." -ForegroundColor Blue
                        Write-Host "----------------------------------------" -ForegroundColor Yellow
                    $Card3 = Get-Random -InputObject $Deck
                    }
                    Until($Card3 -ne "Heal")
                }
            }
            # Check if Card3 is heal
            If($Card3 -eq "Heal"){
                # Only check Card2 because it would have to successfully pass Card1 check.
                If($Card2 -eq "Heal"){
                    Do{
                        Write-Host "SYSTEM: Rerolling Card 2 because Card 3 was a heal." -ForegroundColor Blue
                        Write-Host "----------------------------------------" -ForegroundColor Yellow
                    $Card3 = Get-Random -InputObject $Deck
                    }
                    Until($Card3 -ne "Heal")
                }
            }

    # Deal fixed hand.
    $Hand = @($Card1, $Card2, $Card3)

    # Return result to outside of the Array.
    return $Hand
}

function Start-RealBattle{

    # Sort Hand
    $Hand = Deal-Hand

    # Display UI
    Start-UI

    # Player chooses a card.
    $Choice = Read-Host "Which Card?"

    # Cleanup screen
    Clear-Host

    # UI
    Write-Host "----------------------------------------" -ForegroundColor Yellow

    # Player Attack phase
    Player-Attack
    
    # Buffer
    Start-Sleep 1

    # Enemy attacking phase
    Enemy-Attack

    # Add to Turn counter.
    $TurnAdd = ([int]$Turn) + 1
    $Turn = $TurnAdd

    Start-Sleep 1

    # End game if HP reaches 0
    If($Player.Health -lt 1){
        Write-Host "You DIED!" -ForegroundColor Red
        exit
    }
}

$Player = @{
    Name        = "Player"
    Health      = 10
    Magic       = 0
    Attack      = 1
    Defence     = 0
    Item1       = $null
}

$Deck = @("Smash", "Stab", "Stab", "Stab", "Stab", "Heal")

# Spider details
$Spider = @{
    Name        = "Spider"
    Health      = 10
    Attack      = 1
    Skill1      = "Venom"
    Skill1DMG   = 3
    Block       = 2
    AttackList  = "Attack", "Attack", "Attack", $Spider.Skill1
    Dead        = $false
}

# Ogre details
$Ogre = @{
    Name        = "Ogre"
    Health      = 15
    Attack      = 1
    Skill1      = "Slam"
    Skill1DMG   = 4
    Block       = 2
    AttackList  = "Attack", "Attack", "Attack", $Ogre.Skill1, "Attack"
    Dead        = $false

}


# Enemy
$EnemyList = @($Spider, $Ogre)
$Enemy = Get-Random -InputObject $EnemyList
# $EnemyAttackList = @($Enemy.Skill1, "Attack", "Attack", "Attack")

If($Enemy -match $Ogre){

    $EnemyAttackList = $Ogre.AttackList

}

If($Enemy -match $Spider){

    $EnemyAttackList = $Spider.AttackList

}

Clear-Host

Write-Host "----------------------------------------" -ForegroundColor Yellow
Write-Host "As you walk down a narrow path, you're suddenly met with a foe!"
Write-Host "You've encountered a wild" $($Enemy.Name)"!"
Write-Host "----------------------------------------" -ForegroundColor Yellow
Start-Sleep 1

Do{

Start-RealBattle

}
Until($Enemy.Health -lt 1)

Write-Host "You win!" -ForegroundColor Green

# Add to Round counter.
$RoundAdd = ([int]$Round) + 1
$Round = $RoundAdd
$Enemy.Dead = $true

# Give-PlayerItem

Start-Sleep 1

If($enemy.dead -eq $true){

    if($enemy.Name -match "Spider"){
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
        Write-Host "----------------------------------------" -ForegroundColor Yellow

        # Add to inventory
        $Item1 += $SpiderFang
        $Amount = ([int]$Player.Attack) + 1
        ([int]$Player.Attack) = $Amount

        # Reset mob hp.
        $Spider.Health = 10
    }

    If($enemy.Name -match "Ogre"){
        # Reset mob hp.
        $Ogre.Health = 15


    }

}
Start-Sleep 1

Write-Host "The" $Enemy.Name "lies dead on the floor infront of you." -ForegroundColor Yellow
Start-Sleep 1
Write-Host "Stepping over the foul creature, you make your way further down the path."
Start-Sleep 1
Write-Host "But to no surprise, another monster attacks!"

$Enemy.Death = $false

$Enemy = Get-Random -InputObject $EnemyList

Start-Sleep 1
Write-Host "You've encountered a wild" $($Enemy.Name)"!"
Write-Host "----------------------------------------" -ForegroundColor Yellow
Start-Sleep 3

# fight 2
Do{

Start-RealBattle

}
Until($Enemy.Health -lt 1)

Write-Host "You win!" -ForegroundColor Green

# Add to Round counter.
$RoundAdd = ([int]$Round) + 1
$Round = $RoundAdd

$Enemy.Dead = $true
