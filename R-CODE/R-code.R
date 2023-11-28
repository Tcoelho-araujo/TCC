rm(list = ls())


options(scipen = 999)



library(plm)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(forecast)
library(tsDyn)
library(readxl)
library(stargazer)
library(gplots)
library(readr)

##Data treatment

FBASE <- read_csv("BASE_FINAL2.csv")


BASE <- FBASE %>%
  mutate(lGDP = log(GDP),
         lpop = log(Population),
         lfor = log(Forest_area),
         lare = log(Land_area),
         cell = Mobile_cell,
         lexp = log(Exports),
         limp = log(Imports),
         lco2 = log(CO2_GDP)) 

#filtering datasets

EU_NA <- BASE %>%
  filter(lpi_regions == 'North America' | lpi_regions == 'Europe and Central Asia') 

rest <- BASE %>% 
  filter(lpi_regions == 'Asia and Pacific' | lpi_regions == 'Latin America and the Caribbean')


#test regression

test <- lm(Shannon_index ~ f_assinadas + lGDP + lexp + limp  + lco2 + lpop + cell + lfor + lare 
           + v2x_polyarchy + v2x_libdem + v2x_partidem,
           data = BASE)
summary(test)



##regression (no weight)

s_full <- plm(Shannon_index ~ f_assinadas + lGDP + lexp + limp  + lco2 + lpop + cell + lfor + lare 
              + v2x_polyarchy + v2x_libdem + v2x_partidem,
              data = BASE,index = c("Country_Code", "Time"),
              model = "within",effect = "twoways")

euna <- plm(Shannon_index ~ f_assinadas + lGDP + lexp + limp  + lco2 + lpop + cell + lfor + lare 
            + v2x_polyarchy + v2x_libdem + v2x_partidem,
            data = EU_NA,index = c("Country_Code", "Time"),
            model = "within",effect = "twoways")

res <- plm(Shannon_index ~ f_assinadas + lGDP + lexp + limp  + lco2 + lpop + cell + lfor + lare 
           + v2x_polyarchy + v2x_libdem + v2x_partidem,
           data = rest,index = c("Country_Code", "Time"),
           model = "within",effect = "twoways")


##Regression (weight)


full <- plm(Shannon_index ~ f_assinadas + lGDP + lexp + limp  + lco2 + lpop + cell + lfor + lare 
              + v2x_polyarchy + v2x_libdem + v2x_partidem,
              data = BASE,index = c("Country_Code", "Time"),
              model = "within",effect = "twoways", weights = BASE$`Living Planet index`)

eunap <- plm(Shannon_index ~ f_assinadas + lGDP + lexp + limp  + lco2 + lpop + cell + lfor + lare 
              + v2x_polyarchy + v2x_libdem + v2x_partidem,
              data = EU_NA,index = c("Country_Code", "Time"),
              model = "within",effect = "twoways", weights = EU_NA$`Living Planet index`)

resp <- plm(Shannon_index ~ f_assinadas + lGDP + lexp + limp  + lco2 + lpop + cell + lfor + lare 
            + v2x_polyarchy + v2x_libdem + v2x_partidem,
            data = rest,index = c("Country_Code", "Time"),
            model = "within",effect = "twoways")


stargazer(s_full,euna,res)
stargazer(full,eunap,resp)


## Regression for further discussion
vs_full <- plm(f_assinadas ~ lGDP + lexp + limp  + lco2 + lpop + cell + lfor + lare 
               + v2x_polyarchy + v2x_libdem + v2x_partidem,
               data = BASE,index = c("Country_Code", "Time"),
               model = "within",effect = "twoways")
summary(vs_full)


stargazer(vs_full)
