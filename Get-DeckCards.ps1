function Get-iMtGDecks {
    param (
        [Parameter(Mandatory=$true)]
        [string] $File,
        [switch] $TextOutput
    )
    if ($TextOutput) {
        $decks = (Select-Xml -Path $File -XPath '/plist/array/dict/string' | Select-Object -ExpandProperty Node).'#text';
    } else {
        $decks = (Select-Xml -Path $File -XPath '/plist/array/dict' | Select-Object -ExpandProperty Node);        
    }

    return $decks;
}


function Get-iMtGCardsInDeck {
    param (
        [Parameter(Mandatory=$true)]
        [string] $File,
        [Parameter(Mandatory=$true)]
        [string] $DeckName
    )
    $deckCards = @(); 
    (Get-iMtGDecks -File $File | Where-Object { $_.string -eq $DeckName } ).array.dict | ForEach-Object { $deckCards +=  New-Object psobject -Property @{   $_.key[0] = $_.string[0]; 
                                                                                                                                                $_.key[1] = $_.integer[0] ; 
                                                                                                                                                'card.count' = $_.integer[1] ; 
                                                                                                                                                $_.key[6] = $_.integer[4] ; 
                                                                                                                                                'card.details' = $null} } 
    try {
        $deckCards | ForEach-Object {    $setCode = $_.'card.expansion.code'; 
                                                    $cardNumber = $_.'card.number'; 
                                                    $_.'card.details' = (Invoke-RestMethod -UseBasicParsing -Uri "https://api.magicthegathering.io/v1/cards?set=$setCode&number=$cardNumber").cards }
    }
    catch {
        
    }
    return $deckCards;
}