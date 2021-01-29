library(readxl)
library(dplyr)

pop <- read_excel("C:/Temp/Population/SAPE22DT2-mid-2019-lsoa-syoa-estimates-unformatted.xlsx", 
                    sheet = "Mid-2019 Persons", skip = 3)


df = filter(pop, grepl('Harrogate|Selby|Hambleton|Scarborough|Craven|Ryedale|Richmondshire', `LSOA Name`))


