library(httr)
library(tidyverse)
library(lubridate)


symbols <- c('ghst', 'audio', 'axs', 'mana', 'dg', 'meme', 'enj', 'nftx', 'rari', 
             'rfox', 'revv', 'shroom', 'tvk', 'sand', 'uos', 'whale', 'chain', 'fnt', 'gala', 'muse',
             'soul', 'slp', 'abyss')

# symbols_new <- c('soul', 'slp', 'abyss')
# 
# r1 <- GET('https://api.coingecko.com/api/v3/coins/list')
# coins <- content(r1)
# df <- data.frame(matrix(unlist(coins), nrow=length(coins), byrow=TRUE))
# colnames(df) <- c('id', 'symbol', 'name')
# df %>% filter(symbol %in% symbols_new) %>% pull(id)

ids <- c('aavegotchi', 'audius', 'axie-infinity', 'decentraland', 'decentral-games', 'degenerator', 'enjincoin',
         'nftx', 'rarible', 'redfox-labs-2', 'revv', 'shroom-finance', 'terra-virtua-kolect', 'the-sandbox',
         'ultra', 'whale', 'chain-games', 'falcon-token', 'gala', 'muse-2', 'phantasma', 'small-love-potion',
         'the-abyss')

# get all id's
# get all symbols

for(id in ids){
  
  str <- paste0('https://api.coingecko.com/api/v3/coins/', id, '/market_chart?vs_currency=usd&days=max&interval=daily')
  r <- GET(str)
  out <- content(r)
  dates <- date(as.POSIXct(unlist(out$market_caps)[c(TRUE, FALSE)] / 1000, origin = "1970-01-01", tz = "UTC"))
  mcs <- unlist(out$market_caps)[c(FALSE, TRUE)]
  
  temp <- tibble("date" = dates, 
                 "market_cap" = mcs, 
                  "symbol" = symbols[which(id == ids)])
  
  if(id == 'aavegotchi') {
    
    final <- temp
    
  } else {
    
    final <- rbind(final, temp)
    
  }
  
}

t <- final %>% spread(key = symbol, value = market_cap) %>% fill(-date)

t %>% write_csv("mvi_token_market_caps_02_22_2021.csv")

final %>%
  ggplot(aes(x = date, y = market_cap, color = symbol)) +
  geom_line()
