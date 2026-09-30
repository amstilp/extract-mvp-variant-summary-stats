# Determine the trait mapping to use for matching results.
library(readxl)
library(tidyverse)

x = read_excel("TOUSE_TableS3_BCX3sentinels_5Aug2026.xlsx", skip=2)
dim(x)
head(x)

x = x %>%
    select(Phenotype) %>%
    distinct()
dim(x)
x

mapping = list(
    "BASO" = "Baso_Abs_Mean_INT",
    "EOS" = "Eos_Abs_Mean_INT",
    "HCT" = "HCT_Mean_INT",
    "HGB" = "Hemoglobin_Mean_INT",
    "LYM" = "Lymph_Abs_Mean_INT",
    "MCH" = "MCH_Mean_INT",
    "MCHC" = "MCHC_Mean_INT",
    "MCV" = "MCV_Mean_INT",
    "MONO" = "Mono_Abs_Mean_INT",
    "MPV" = "MPV_Mean_INT",
    "NEU" = "Neut_Abs_Mean_INT",
    "PLT" = "Platelet_Mean_INT",
    "RBC" = "RBC_Mean_INT",
    "RDW" = "RDW_Mean_INT",
    "WBC" = "WBC_Mean_INT"
) %>% enframe(name="trait_bcx", value="trait_mvp") %>% unnest(trait_mvp)

stopifnot(setequal(mapping$trait_bcx, x$Phenotype))

mapping %>%
    write_tsv("mapping.tsv")
