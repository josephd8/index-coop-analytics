library(tidyverse)
library(lubridate)

dat <- read_csv('projects/retention-analysis/data/DPI_Retention_Base_2021_01_13.csv')

View(dat %>%
  arrange(address, evt_block_minute))

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

dates <- tibble(date = seq(ymd(date(min(t$date))), ymd(date(max(t$date))), by = "weeks"))

t <- temp %>%
  select(address) %>% full_join(dates, by = character()) %>% 
  left_join(temp %>% select(address, date, amount), by = c('address', 'date'))

t %>% 
  mutate(amount = ifelse(is.na(amount), 0, amount)) %>%
  group_by(address) %>%
  mutate(running_exposure = cumsum(amount)) %>%
  left_join(temp %>% 
              group_by(address) %>% 
              summarize(cohort = min(cohort), group = min(exposure_group)), 
            by = "address")
  
  


t1 <- t %>% select(address) %>% full_join(dates, by = character()) %>% left_join(t, by = c('address', 'date'))

cntr <- 1
for(t_address in unique(temp$address)) {

  min_date <- min(temp %>% filter(address == t_address) %>% pull(date))
  max_date <- lubridate::today()
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

View(fin)

# determine which days to include for which months
include_days <- fin %>%
  group_by(cohort) %>%
  summarize(max_day = max(day)) %>%
  mutate(include_days = round(max_day * 0.75))

sep_include <- include_days %>% filter(cohort == 'sep') %>% pull(include_days)
oct_include <- include_days %>% filter(cohort == 'oct') %>% pull(include_days)
nov_include <- include_days %>% filter(cohort == 'nov') %>% pull(include_days)
dec_include <- include_days %>% filter(cohort == 'dec') %>% pull(include_days)
jan_include <- include_days %>% filter(cohort == 'jan') %>% pull(include_days)

fin$cohort <- factor(fin$cohort, levels = c('jan', 'dec', 'nov', 'oct', 'sep'))

fin %>%
  filter((cohort == 'sep' & day <= sep_include) |
           (cohort == 'oct' & day <= oct_include) |
           (cohort == 'nov' & day <= nov_include) |
           (cohort == 'dec' & day <= dec_include) |
           (cohort == 'jan' & day <= jan_include)
         ) %>%
  group_by(day, cohort) %>%
  summarize(retention = mean(retained)) %>%
  ggplot(aes(x = day, y = retention, color = cohort)) +
  geom_line() +
  theme_bw() +
  xlab("days since initial exposure") + ylab("retention") +
  labs(title = "DPI Retention", 
       subtitle = "Cohorts determined by the month of initial exposure to DPI.", 
       caption = "Source: Dune Analytics", 
       col = "cohort")
  

# some things are off
# not getting cohorts right
# need to only include days where 25%+ of the cohort has reached
# re-order the legend


