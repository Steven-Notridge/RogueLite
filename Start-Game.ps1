# Created by Steven Notridge
# Some parts are useful for now but whatever.
# Might continue working on this, could be quite fun.

# Main frame.
$Turn = 1
$Clear = Clear-Host

# Stats
$Health = 10
$DMG = 1
$Block = 0


$Deck = @("Smash", "Stab", "Stab", "Stab", "Heal")

# Spider details
$Spider = @{
    Name        = "Spider"
    Health      = 10
    Attack      = 1
    Venom       = 3
    Block       = 2
}

# Initialise Hand
$Card1 = Get-Random -InputObject $Deck
$Card2 = Get-Random -InputObject $Deck
$Card3 = Get-Random -InputObject $Deck
$Hand = @($Card1, $Card2, $Card3)

# Enemy
$Enemy = $Spider


# Prevent Cheating?
# If $Card not in $Deck, continue?

Write-Host "--------------------" -ForegroundColor Yellow
Do{
    # Reroll Hand.
    $Card1 = Get-Random -InputObject $Deck
    $Card2 = Get-Random -InputObject $Deck
    $Card3 = Get-Random -InputObject $Deck
    $Hand = @($Card1, $Card2, $Card3)



    # Turn Stats

    Write-Host "Your HP =" $Health
    Write-Host "$($Enemy.Name)"HP" = $($Enemy.Health)"
    Write-Host "Turn:" $Turn

    # Show Hand
    Write-Host "--------------------" -ForegroundColor Yellow
    Write-Host "Your hand is:" $Hand[0], $Hand[1], $Hand[2] -ForegroundColor Cyan
    Write-Host "--------------------" -ForegroundColor Yellow
    $Choice = Read-Host "Which Card?"
    Write-Host ""

    # Cleanup screen
    Clear-Host

    Write-Host "--------------------" -ForegroundColor Yellow

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
                    Write-Host "You heal yourself 2 damage." -ForegroundColor Green
                    $Amount = $Health + 1
                    $Health = $Amount
                }
            }
        }
        
        Start-Sleep 1

        Write-Host "--------------------"
        # Enemy attack turn
        If($Enemy.Health -gt 1){
            $EnemyChoice = "Attack"

            If($EnemyChoice -match "Attack"){

                Write-Host "The" $Enemy.Name "Attacks!" -ForegroundColor Yellow
                $Amount = ([int]$Health) - 1
                $Health = $Amount
                Write-Host "-1 HP" -ForegroundColor Red
            }
        }
        Write-Host "--------------------" -ForegroundColor Yellow
        # Add to Turn counter.
        $TurnAdd = ([int]$Turn) + 1
        $Turn = $TurnAdd

        
        Start-Sleep 1

        

}
Until($Enemy.Health -lt 1)

Write-Host "You win!" -ForegroundColor Green