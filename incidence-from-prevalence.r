library(data.table)
library(here)
library(tidyverse)

africa = c("Equatorial Guinea","Mauritius","Zambia","Senegal","Côte d'Ivoire","Eswatini","Congo","Gambia","Ethiopia","Chad","Sudan","Namibia","Somalia","Central African Republic","Niger","Guinea-Bissau","Guinea","Mauritania","Cameroon","Uganda","Democratic Republic of the Congo","Togo","Angola","Kenya","Gabon","Botswana","Burkina Faso","Djibouti","Malawi","Mozambique","Benin","Mali","Madagascar","Ghana","South Sudan","Lesotho","United Republic of Tanzania","Burundi","Zimbabwe","Sao Tome and Principe","Nigeria","Liberia","Comoros","Eritrea","Sierra Leone","Rwanda","Cabo Verde","Seychelles","South Africa")
process = function(row) {
  row = as.numeric(gsub(" ","",row))
  row = row[seq(2, length(row), 4)]
  row[is.na(row)] = 0
  return(row)
}

deaths = fread(here("data/AIDS-related deaths_AIDS-related deaths - Adults (15-49)_Population_ All adults (15-49) 2022.csv"))
deaths = deaths %>% filter(V1 %in% africa)
africa_deaths = rep(0,33)
for(i in 1:nrow(deaths)) {
  africa_deaths = africa_deaths + process(deaths[i,])
}


aids = fread(here("data/_AIDS orphans (0-17) 2022.csv"))
aids = aids %>% filter(V1 %in% africa)
africa_orphans = rep(0,33)
for(i in 1:nrow(aids)) {
  africa_orphans = africa_orphans + process(aids[i,])
}

# ---------------------- Setup and run linear models --------------------------- 
data = data.frame(year=1990:2022,
                  africa_deaths=africa_deaths, 
                  africa_orphans=africa_orphans)

# Append lagged orphan counts
data$africa_lagged_orphans = c(NA,data$africa_orphans[1:(nrow(data)-1)])
plot(data$year,data$africa_deaths,ty="l",ylab="AIDS deaths",xlab="source: UNAIDS",main="Africa")

# fit and check models
fit_africa = lm(africa_orphans ~ -1 + africa_lagged_orphans + africa_deaths, data=data)
summary(fit_africa)

# --------------- Export fitted incidence alongside prevalence -----------------

# Calculate incidence as the coefficient for deaths times number of deaths
data$africa_inc = data$africa_deaths * coef(fit_africa)[grepl(".*deaths", names(coef(fit_africa)))]
# equivalently:
# ylinear = predict(fit_africa,data.frame(africa_lagged_orphans=0,africa_deaths=data$africa_deaths))


africa_data = data %>%
  select(year, deaths=africa_deaths, orphans_prev=africa_orphans, orphans_inc=africa_inc) 

write.csv(africa_data, here("data/aids_orphanhood_2022.csv"))
