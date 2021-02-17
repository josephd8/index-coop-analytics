library(tidyverse)
library(lubridate)
library(plotly)
library(gridExtra)

dat <- read_csv('projects/retention-analysis/data/DPI_Retention_Base_2021_02_02.csv')
sushi_dat <- read_csv('projects/retention-analysis/data/DPI_Sushiswap_LP_2021_02_02.csv')

# identify contracts / arb bots?

temp <- dat %>% 
  group_by(address, date(ymd_hms(evt_block_minute))) %>% 
  summarize(n_amount = sum(amount), n_tx = n())

contract_addresses <- temp %>%
  filter(n_tx >= 2, n_amount <= 1e-14) %>%
  distinct(address) %>%
  pull(address)

# set up data
# address == 'a386621f99d2b74de33051cd5a5d00967668afdd'

d <- dat %>%
  filter(!(address %in% contract_addresses)) %>%
  mutate(dt = ymd_hms(evt_block_minute)) %>%
  select(address, dt, amount, type, evt_tx_hash)

temp <- dat %>%
  filter(!(address %in% contract_addresses)) %>%
  mutate(dt = ymd_hms(evt_block_minute)) %>%
  select(address, dt, amount, type, evt_tx_hash) %>%
  arrange(address, dt) %>%
  group_by(address) %>%
  summarize(dt,
            date = date(dt),
            amount, 
            running_exposure = cumsum(amount), 
            type, 
            evt_tx_hash,
            exposure_group = case_when(
              max(amount) >= 250 ~ "250+",
              max(amount) >= 50 ~ "50-249",
              max(amount) >= 10 ~ "10-49",
              TRUE ~ "<10"
            ),
            cohort = case_when(
              month(min(dt)) == 9 ~ "sep",
              month(min(dt)) == 10 ~ "oct",
              month(min(dt)) == 11 ~ "nov",
              month(min(dt)) == 12 ~ "dec",
              month(min(dt)) == 1 ~ "jan",
              month(min(dt)) == 2 ~ "feb",
              month(min(dt)) == 3 ~ "mar",
              month(min(dt)) == 4 ~ "apr"
            )
  )

groups <- temp %>% 
  group_by(address) %>% 
  summarize(cohort = min(cohort), group = min(exposure_group))

cntr <- 1
for(t_address in unique(temp$address)) {
  
  min_date <- min(temp %>% filter(address == t_address) %>% pull(date))
  max_date <- lubridate::today(tzone = 'GMT')
  cand <- tibble(address = t_address, date = seq(min_date, max_date, by="days"))
  
  if(cntr == 1){
    
    final <- cand
    cntr <- cntr + 1
    
  } else {
    
    final <- rbind(final, cand)
    
  }
  
}


fin <- final %>%
  left_join(temp %>% group_by(address, date) %>% summarize(amount = sum(amount)), by = c('address', 'date')) %>%
  mutate(amount = ifelse(is.na(amount), 0, amount)) %>%
  group_by(address) %>%
  summarize(date, amount, running_exposure = cumsum(amount), day = 1:n()) %>%
  ungroup %>%
  left_join(groups, by = c('address')) %>%
  mutate(retained = ifelse(running_exposure > 0, 1, 0))

fin$group <- factor(fin$group, levels = c('<10', '10-49', '50-249', '250+'))

sushi_addresses <- sushi_dat %>% 
  group_by(address) %>% 
  summarize(amount = sum(amount)) %>%
  mutate(sushi_lp = case_when(
    amount > 0 ~ 'current',
    amount <= 0 ~ 'ever'
  ))

fin %>%
  left_join(sushi_addresses %>% select(address, sushi_lp), by = c('address')) %>%
  mutate(sushi_lp = case_when(
    is.na(sushi_lp) ~ 'never',
    TRUE ~ sushi_lp
  )) %>%
  group_by(address) %>%
  filter(date == max(date), sushi_lp == 'current') %>%
  ggplot(aes(x = group)) +
  geom_bar(stat = 'count') + 
  theme_bw()


fin %>%
  left_join(sushi_addresses %>% select(address, sushi_lp), by = c('address')) %>%
  mutate(sushi_lp = case_when(
    is.na(sushi_lp) ~ 'never',
    TRUE ~ sushi_lp
  )) %>%
  group_by(address) %>%
  filter(date == max(date), sushi_lp == 'current') %>%
  pull(running_exposure) %>%
  sum()

