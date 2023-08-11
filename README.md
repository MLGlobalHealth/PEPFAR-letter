# PEPFAR-letter
Replication code for Cluver et al (2023)


Methods: using UNAIDS 2023 data, we estimate numbers of children newly orphaned by AIDS per year before and after PEPFAR based on a regression model with two predictors and no intercept term: 1-year lagged orphanhood prevalence and new AIDS deaths for ages 15-49. The 1-year lagged orphanhood term accounts for ``aging out'' (children turning 18 and no longer being part of the count of prevalent orphans). The new AIDS deaths term accounts for children newly orphaned; the quantity we care about estimating is the coefficient on this term. Having fit the model, we predict new incident orphans by multiplying this coefficient by the number of AIDS deaths for ages 15-49.
