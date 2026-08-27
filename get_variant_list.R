library(readxl)
library(tidyverse)

x = read_excel("Novel sentinel variants from BCX3 for MVP replication.xlsx")
dim(x)

x = x %>%
    dplyr::filter(!is.na(rsid) & rsid != "" & rsid != "NA") %>%
    select(rsid) %>%
    distinct()
dim(x)

x %>%
    write_tsv("variants.txt", col_names = FALSE)
