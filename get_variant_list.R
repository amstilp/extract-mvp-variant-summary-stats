library(readxl)
library(tidyverse)

x = read_excel("TOUSE_TableS3_BCX3sentinels_5Aug2026.xlsx", skip=2)
dim(x)
head(x)

x = x %>%
    dplyr::filter(!is.na(rsid) & rsid != "" & rsid != "NA") %>%
    select(rsid) %>%
    distinct()
dim(x)

x %>%
    write_tsv("variants.txt", col_names = FALSE)
