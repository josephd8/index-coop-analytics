library(httr)
library(tidyverse)
library(lubridate)

# DeFi (to be used as an example)
r <- GET('https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&category=decentralized_finance_defi')

coins <- content(r)

for(i in 1:length(coins)) {
  
  coin <- coins[[i]]
  
  temp <- tibble("id" = ifelse(is.null(coin$id), 'NA', coin$id),
                 "symbol" = ifelse(is.null(coin$symbol), 'NA', coin$symbol),
                 "market_cap" = ifelse(is.null(coin$market_cap), 'NA', coin$market_cap),
                 "fdv" = ifelse(is.null(coin$fully_diluted_valuation), 'NA', coin$fully_diluted_valuation),
                 "total_volume" = ifelse(is.null(coin$total_volume), 'NA', coin$total_volume),
                 "circ_supply" = ifelse(is.null(coin$circulating_supply), 'NA', coin$circulating_supply),
                 "max_supply" = ifelse(is.null(coin$max_supply), 'NA', coin$max_supply))
  
  if(i == 1) {
    
    final <- temp
    
  } else {
    
    final <- rbind(final, temp)
    
  }
  
}

View(final)
