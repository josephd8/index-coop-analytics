library(httr)
library(tidyverse)
library(lubridate)


symbols <- c('ghst', 'audio', 'axs', 'mana', 'dg', 'meme', 'enj', 'nftx', 'rari', 
             'rfox', 'revv', 'shroom', 'tvk', 'sand', 'uos', 'whale', 'chain', 'fnt', 'gala', 'muse',
             'soul', 'slp', 'abyss', 'waxp', 'chz')

# symbols_new <- c('waxp')
# 
# r1 <- GET('https://api.coingecko.com/api/v3/coins/list')
# coins <- content(r1)
# df <- data.frame(matrix(unlist(coins), nrow=length(coins), byrow=TRUE))
# colnames(df) <- c('id', 'symbol', 'name')
# df %>% filter(symbol %in% symbols_new) %>% pull(id)

ids <- c('aavegotchi', 'audius', 'axie-infinity', 'decentraland', 'decentral-games', 'degenerator', 'enjincoin',
         'nftx', 'rarible', 'redfox-labs-2', 'revv', 'shroom-finance', 'terra-virtua-kolect', 'the-sandbox',
         'ultra', 'whale', 'chain-games', 'falcon-token', 'gala', 'muse-2', 'phantasma', 'small-love-potion',
         'the-abyss', 'wax', 'chiliz')

# get all id's
# get all symbols

for(id in ids){
  
  str_s <- paste0('https://api.coingecko.com/api/v3/coins/', id)
  r_s <- GET(str_s)
  out_s <- content(r_s)
  supply <- out_s$market_data$total_supply
  
  str <- paste0('https://api.coingecko.com/api/v3/coins/', id, '/market_chart?vs_currency=usd&days=max&interval=daily')
  r <- GET(str)
  out <- content(r)
  dates <- date(as.POSIXct(unlist(out$market_caps)[c(TRUE, FALSE)] / 1000, origin = "1970-01-01", tz = "UTC"))
  prices <- unlist(out$prices)[c(FALSE, TRUE)]
  fully <- prices * supply
  mcs <- unlist(out$market_caps)[c(FALSE, TRUE)]
  perc_supply <- mcs / fully
  perc_supply <- ifelse(perc_supply > 1, 0, perc_supply)
  
  temp <- tibble("date" = dates, 
                 "market_cap" = mcs, 
                 "fully_diluted" = fully,
                 "percent_supply" = perc_supply,
                 "symbol" = symbols[which(id == ids)])
  
  
  # if(id == 'waxe') {
  #   
  #   str <- paste0('https://api.coingecko.com/api/v3/coins/', id, '/market_chart?vs_currency=usd&days=max&interval=daily')
  #   r <- GET(str)
  #   out <- content(r)
  #   dates <- date(as.POSIXct(unlist(out$market_caps)[c(TRUE, FALSE)] / 1000, origin = "1970-01-01", tz = "UTC"))
  #   prices <- unlist(out$prices)[c(FALSE, TRUE)]
  #   mcs <- prices * 3700000
  #   s
  #   temp <- tibble("date" = dates, 
  #                  "market_cap" = mcs, 
  #                  "symbol" = symbols[which(id == ids)])
  #   
  # } else {
  # 
  #   str <- paste0('https://api.coingecko.com/api/v3/coins/', id, '/market_chart?vs_currency=usd&days=max&interval=daily')
  #   r <- GET(str)
  #   out <- content(r)
  #   dates <- date(as.POSIXct(unlist(out$market_caps)[c(TRUE, FALSE)] / 1000, origin = "1970-01-01", tz = "UTC"))
  #   mcs <- unlist(out$market_caps)[c(FALSE, TRUE)]
  #   
  #   temp <- tibble("date" = dates, 
  #                  "market_cap" = mcs, 
  #                  "symbol" = symbols[which(id == ids)])
  # 
  # }
  
  if(id == 'aavegotchi') {
    
    final <- temp
    
  } else {
    
    final <- rbind(final, temp)
    
  }
  
}

t <- final %>% 
  select(date, symbol, market_cap) %>% 
  spread(key = symbol, value = market_cap) %>% 
  fill(-date)

p <- final %>% 
  select(date, symbol, percent_supply) %>%
  spread(key = symbol, value = percent_supply) %>% 
  fill(-date)

f <- final %>%
  select(date, symbol, fully_diluted) %>%
  spread(key = symbol, value = fully_diluted) %>%
  fill(-date)

t %>% write_csv("mvi_token_market_caps_03_20_2021.csv")
p %>% write_csv("mvi_token_percent_supply_03_20_2021.csv")
f %>% write_csv("mvi_token_fully_diluted_03_20_2021.csv")

final %>%
  ggplot(aes(x = date, y = market_cap, color = symbol)) +
  geom_line()
