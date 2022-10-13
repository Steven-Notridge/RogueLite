# Created by Steven Notridge
# Some parts are useful for now but whatever.
# Might continue working on this, could be quite fun.

# Main frame.
$Turn = 1

# Stats
$Health = 10
$DMG = 1
$Block = 0


$Deck = @("Smash", "Stab", "Stab", "Stab", "Stab", "Heal")

# Spider details
$Spider = @{
    Name        = "Spider"
    Health      = 10
    Attack      = 1
    Skill1      = "Venom"
    Skill1DMG   = 3
    Block       = 2
}

# Ogre details
$Ogre = @{
    Name        = "Ogre"
    Health      = 15
    Attack      = 1
    Skill1      = "Slam"
    Skill1DMG   = 5
    Block       = 2
}

# Initialise Hand
$Card1 = Get-Random -InputObject $Deck
$Card2 = Get-Random -InputObject $Deck
$Card3 = Get-Random -InputObject $Deck
$Hand = @($Card1, $Card2, $Card3)

# Enemy
$EnemyList = @($Spider, $Ogre)
$Enemy = Get-Random -InputObject $EnemyList
$EnemyAttackList = @($Enemy.Skill1, "Attack", "Attack", "Attack")

Clear-Host

# Prevent Cheating?
# If $Card not in $Deck, continue?

Write-Host "----------------------------------------" -ForegroundColor Yellow
Write-Host "As you walk down a narrow path, you're suddenly met with a foe!"
Start-Sleep 1
Write-Host "You've encountered a wild" $($Enemy.Name)"!"
Write-Host "----------------------------------------" -ForegroundColor Yellow
Do{
    # Reroll Hand.
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

    $Hand = @($Card1, $Card2, $Card3)

    # Turn Stats
    Write-Host "Your HP =" $Health
    Write-Host "$($Enemy.Name)"HP" = $($Enemy.Health)"
    Write-Host "Turn:" $Turn

    # Show Hand
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    Write-Host "Your hand is:" $Hand[0], $Hand[1], $Hand[2] -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    $Choice = Read-Host "Which Card?"
    Write-Host ""

    # Cleanup screen
    Clear-Host

    Write-Host "----------------------------------------" -ForegroundColor Yellow

        If($Hand -match $Choice){
            Switch ($Choice)
            {
                Smash
                {
                    Write-Host "You Smash the enemy, dealing 3 damage!" -ForegroundColor Yellow
                    $Amount = ([int]$Enemy.Health) - 3
                    $Enemy['Health'] = $Amount
                }
                Stab
                {
                    Write-Host "You stab the enemy, dealing 1 damage!" -ForegroundColor Yellow
                    $Amount = ([int]$Enemy.Health) - 1
                    $Enemy['Health'] = $Amount
                }
                Heal
                {
                    Write-Host "You heal yourself!." -ForegroundColor Yellow
                    Write-Host "+3 HP" -ForegroundColor Green
                    $Amount = $Health + 3
                    $Health = $Amount
                }
            }
        }
        
        # Buffer
        Start-Sleep 1
        Write-Host "----------------------------------------" -ForegroundColor Yellow

        # Enemy attack turn
        If($Enemy.Health -gt 0){

            # Simulate players hand situation here.
            $EnemyChoice = Get-Random -InputObject $EnemyAttackList

            # Enemy attacks
            If($EnemyChoice -match "Attack"){
                Write-Host "The" $Enemy.Name "Attacks!" -ForegroundColor Yellow
                $Amount = ([int]$Health) - $($Enemy.Attack)
                $Health = $Amount
                Write-Host "-$($Enemy.Attack) HP" -ForegroundColor Red
            }
            If($EnemyChoice -match $Enemy.Skill1){
                Write-Host "The" $Enemy.Name "uses it's $($Enemy.Skill1) ability!" -ForegroundColor Yellow
                $Amount = ([int]$Health) - $($Enemy.Skill1DMG)
                $Health = $Amount
                Write-Host "-$($Enemy.Skill1DMG) HP" -ForegroundColor Red
            }
        }

        Write-Host "----------------------------------------" -ForegroundColor Yellow

        # Add to Turn counter.
        $TurnAdd = ([int]$Turn) + 1
        $Turn = $TurnAdd

        Start-Sleep 1

        # End game if HP reaches 0
        If($Health -lt 1){
            Write-Host "You DIED!" -ForegroundColor Red
            exit
        }


}
Until($Enemy.Health -lt 1)

Write-Host "You win!" -ForegroundColor Green