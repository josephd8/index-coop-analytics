library(tidyverse)
library(lubridate)
library(plotly)

dat <- read_csv('projects/retention-analysis/data/DPI_Retention_Base_2021_01_18.csv')

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

# dates <- tibble(date = seq(ymd(date(min(t$date))), ymd(date(max(t$date))), by = "weeks"))
# 
# t <- temp %>%
#   select(address) %>% full_join(dates, by = character()) %>% 
#   left_join(temp %>% select(address, date, amount), by = c('address', 'date'))
# 
# t %>% 
#   mutate(amount = ifelse(is.na(amount), 0, amount)) %>%
#   group_by(address) %>%
#   mutate(running_exposure = cumsum(amount)) %>%
#   left_join(temp %>% 
#               group_by(address) %>% 
#               summarize(cohort = min(cohort), group = min(exposure_group)), 
#             by = "address")
#   
#   
# 
# 
# t1 <- t %>% select(address) %>% full_join(dates, by = character()) %>% left_join(t, by = c('address', 'date'))

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
  
# testing plotly

y <- fin %>%
  filter((cohort == 'sep' & day <= sep_include) |
           (cohort == 'oct' & day <= oct_include) |
           (cohort == 'nov' & day <= nov_include) |
           (cohort == 'dec' & day <= dec_include) |
           (cohort == 'jan' & day <= jan_include)
  ) %>%
  group_by(day, cohort) %>%
  summarize(retention = mean(retained))

  ggplotly(ggplot(data = y, aes(x = day, y = retention, color = cohort)) +
  geom_line() +
  theme_bw() +
  xlab("days since initial exposure") + ylab("retention") +
  labs(title = "DPI Retention", 
       subtitle = "Cohorts determined by the month of initial exposure to DPI.", 
       caption = "Source: Dune Analytics", 
       col = "cohort"))

# net DPI retention

#edit this up a bit
fin %>% 
  filter(day <= round(max(day) * .75)) %>%
  ungroup() %>% 
  group_by(day) %>% 
  summarize(amount = sum(amount)) %>%
  summarize(day, amount, 
            running_amount = cumsum(amount), 
            net_retention = cumsum(amount) / first(amount)) %>%
  ggplot(aes(x = day, y = net_retention)) +
  geom_line() +
  theme_bw() +
  xlab("days since initial exposure") + ylab("amount of initial exposure") +
  labs(title = "DPI Unit Retention", 
       subtitle = "Growth in unit exposure aggregated across all addresses ever having DPI exposure.", 
       caption = "Source: Dune Analytics", 
       col = "cohort")
  
  
 #   
#   
# initials <- temp %>% 
#   group_by(address) %>% 
#   filter(row_number() == 1) %>% 
#   select(address, initial_amount = amount, date)
#   
# View(fin)
# 
# x <- fin %>%
#   left_join(initials, by = 'address') %>%
#   filter(initial_amount > 0) %>%
#   group_by(address) %>%
#   # mutate(index = (running_exposure + mean(running_exposure)) / (initial_amount + mean(running_exposure))) %>%
#   mutate(index = (running_exposure) / (initial_amount)) %>%
#   filter((cohort == 'sep' & day <= sep_include) |
#            (cohort == 'oct' & day <= oct_include) |
#            (cohort == 'nov' & day <= nov_include) |
#            (cohort == 'dec' & day <= dec_include) |
#            (cohort == 'jan' & day <= jan_include)
#   ) %>%
#   group_by(day, cohort) %>%
#   summarize(net_retention = mean(index))
# 
# ggplotly(ggplot(data = x, aes(x = day, y = net_retention, color = cohort)) +
#            geom_line() +
#            theme_bw() +
#            xlab("days since initial exposure") + ylab(" net retention") +
#            labs(title = "Net DPI Retention", 
#                 subtitle = "Cohorts determined by the month of initial exposure to DPI.", 
#                 caption = "Source: Dune Analytics", 
#                 col = "cohort"))
# 
# 
# 
# fin %>%
#   left_join(initials, by = 'address') %>%
#   filter(initial_amount > 0) %>%
#   group_by(address) %>%
#   # mutate(index = (running_exposure + mean(running_exposure)) / (initial_amount + mean(running_exposure))) %>%
#   mutate(index = (running_exposure) / (initial_amount)) %>%
#   filter((cohort == 'sep' & day <= sep_include) |
#            (cohort == 'oct' & day <= oct_include) |
#            (cohort == 'nov' & day <= nov_include) |
#            (cohort == 'dec' & day <= dec_include) |
#            (cohort == 'jan' & day <= jan_include)
#   ) %>%
#   filter(day == 10, cohort == 'sep') %>%
#   ggplot(aes(x = index)) + 
#   geom_boxplot()


# DPI retention by exposure group

# edit these up a bit
# <10
fin %>%
  filter((cohort == 'sep' & day <= sep_include) |
           (cohort == 'oct' & day <= oct_include) |
           (cohort == 'nov' & day <= nov_include) |
           (cohort == 'dec' & day <= dec_include) |
           (cohort == 'jan' & day <= jan_include)
  ) %>%
  filter(group == '<10') %>%
  group_by(day, cohort) %>%
  summarize(retention = mean(retained)) %>%
  ggplot(aes(x = day, y = retention, color = cohort)) +
  geom_line() +
  theme_bw() +
  xlab("days since initial exposure") + ylab("retention") +
  labs(title = "DPI Retention | <10 DPI", 
       subtitle = "Cohorts determined by the month of initial exposure to DPI.", 
       caption = "Source: Dune Analytics", 
       col = "cohort")

# 10-49
fin %>%
  filter((cohort == 'sep' & day <= sep_include) |
           (cohort == 'oct' & day <= oct_include) |
           (cohort == 'nov' & day <= nov_include) |
           (cohort == 'dec' & day <= dec_include) |
           (cohort == 'jan' & day <= jan_include)
  ) %>%
  filter(group == '10-49') %>%
  group_by(day, cohort) %>%
  summarize(retention = mean(retained)) %>%
  ggplot(aes(x = day, y = retention, color = cohort)) +
  geom_line() +
  theme_bw() +
  xlab("days since initial exposure") + ylab("retention") +
  labs(title = "DPI Retention | 10-49 DPI", 
       subtitle = "Cohorts determined by the month of initial exposure to DPI.", 
       caption = "Source: Dune Analytics", 
       col = "cohort")

# 50-249
fin %>%
  filter((cohort == 'sep' & day <= sep_include) |
           (cohort == 'oct' & day <= oct_include) |
           (cohort == 'nov' & day <= nov_include) |
           (cohort == 'dec' & day <= dec_include) |
           (cohort == 'jan' & day <= jan_include)
  ) %>%
  filter(group == '50-249') %>%
  group_by(day, cohort) %>%
  summarize(retention = mean(retained)) %>%
  ggplot(aes(x = day, y = retention, color = cohort)) +
  geom_line() +
  theme_bw() +
  xlab("days since initial exposure") + ylab("retention") +
  labs(title = "DPI Retention | 50-249 DPI", 
       subtitle = "Cohorts determined by the month of initial exposure to DPI.", 
       caption = "Source: Dune Analytics", 
       col = "cohort")

# 250+
fin %>%
  filter((cohort == 'sep' & day <= sep_include) |
           (cohort == 'oct' & day <= oct_include) |
           (cohort == 'nov' & day <= nov_include) |
           (cohort == 'dec' & day <= dec_include) |
           (cohort == 'jan' & day <= jan_include)
  ) %>%
  filter(cohort != 'sep') %>%
  filter(group == '250+') %>%
  group_by(day, cohort) %>%
  summarize(retention = mean(retained)) %>%
  ggplot(aes(x = day, y = retention, color = cohort)) +
  geom_line() +
  theme_bw() +
  xlab("days since initial exposure") + ylab("retention") +
  labs(title = "DPI Retention | 250+ DPI", 
       subtitle = "Cohorts determined by the month of initial exposure to DPI.", 
       caption = "Source: Dune Analytics", 
       col = "cohort")

# number of address x exposure

#edit these up a bit
g <- groups %>% 
  group_by(group, cohort) %>% 
  summarize(addresses = n()) 

g$cohort <- factor(g$cohort, levels = rev(c('jan', 'dec', 'nov', 'oct', 'sep')))
g$group <- factor(g$group, levels = c('<10', '10-49', '50-249', '250+'))

g %>%
  ggplot(aes(fill = group, y = addresses, x = cohort)) + 
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_text(aes(label = addresses),
            size = 3,
            vjust = 1.5, 
            position = position_dodge(0.9)) + 
  theme_bw() + 
  xlab("") + ylab("addresses") +
  labs(title = "DPI Holders Growth", 
       caption = "Source: Dune Analytics", 
       fill = 'DPI Exposure')

# g %>%
#   ggplot(aes(fill = group, y = addresses, x = cohort)) + 
#   geom_bar(position = 'stack', stat = 'identity') +
#   theme_bw()

g %>%
  ggplot(aes(fill = group, y = addresses, x = cohort)) + 
  geom_bar(position = 'fill', stat = 'identity') +
  theme_bw() + 
  xlab("") + ylab("% of addresses") +
  labs(title = "DPI Holder Exposure Distribution", 
       caption = "Source: Dune Analytics", 
       fill = 'DPI Exposure')


table(groups$group, groups$cohort)


# DPI Whale Retention

whale <- fin %>%
  filter(group == '250+')

# what is interesting about whales?
# retaining "whale" status
# net retention

whale %>%
  filter(group == '250+' & cohort != 'sep') %>%
  filter((cohort == 'sep' & day <= sep_include) |
           (cohort == 'oct' & day <= oct_include) |
           (cohort == 'nov' & day <= nov_include) |
           (cohort == 'dec' & day <= dec_include) |
           (cohort == 'jan' & day <= jan_include)
  ) %>%
  mutate(whale_retention = ifelse(running_exposure >= 250, 1, 0)) %>%
  group_by(day, cohort) %>%
  summarize(whale = mean(whale_retention)) %>%
  ggplot(aes(x = day, y = whale, color = cohort)) +
  geom_line() +
  theme_bw() +
  xlab("days since initial exposure") + ylab("% of whales retained as whales") +
  labs(title = "DPI Whale Retention", 
       subtitle = "Cohorts determined by the month of initial exposure to DPI.", 
       caption = "Source: Dune Analytics", 
       col = "cohort")


