library(dplyr)

data = data_3_ %>% select(Pathway, `Suspected Virus`) %>% na.omit() %>% mutate(id = row_number())

set.seed(1988)
out2 <- data %>%
  group_by(Pathway, `Suspected Virus`) %>%
  sample_n(100, replace = T)


table(out2$Pathway, out2$`Suspected Virus`)
