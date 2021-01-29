library(readxl)

library(tidyverse)

path <- "Additional Measures.xlsx"

mad <- path %>%
  excel_sheets() %>%
  set_names() %>%
  map(read_excel,
      path = path)

str(mad)

mad <- path %>%
  excel_sheets() %>%
  set_names() %>%
  map_df(read_excel,
         path = path)

mad

data = mad %>% bind_rows()
