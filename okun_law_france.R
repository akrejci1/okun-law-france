# Clear environment
rm(list = ls())
cat("\014")
graphics.off()

# Packages
library(readr)
library(ggplot2)
library(ggfortify)
library(patchwork)
library(dynlm)
library(tstools)
library(stargazer)
library(strucchange)
library(mFilter)
library(MASS)

# 1) Load data ----
gdp_raw <- read_csv("gdp.csv")
gdp <- data.frame(
  time = gdp_raw$TIME_PERIOD,
  GDP  = as.numeric(gdp_raw$OBS_VALUE)
)

une_raw <- read_csv("unemployment.csv")
une <- data.frame(
  time = une_raw$TIME_PERIOD,
  U    = as.numeric(une_raw$OBS_VALUE)
)

# Merge to common sample 1983Q1-2025Q4
my_data <- merge(gdp, une, by = "time")
my_data <- my_data[my_data$time >= "1983-Q1", ]

# Convert to ts object
ts_data <- ts(my_data[, c("GDP","U")], start = c(1983,1), frequency = 4)

# Visualise raw series
p1 <- autoplot(ts_data[,'GDP'], linewidth=1, colour='red') +
  ggtitle("France Real GDP (index 2020=100)") + xlab("") + ylab("Index")
p2 <- autoplot(ts_data[,'U'], linewidth=1, colour='blue') +
  ggtitle("France Unemployment Rate (%)") + xlab("") + ylab("%")

p_raw <- p1 / p2
print(p_raw)
ggsave("01_raw_series.png", plot = p_raw, width = 10, height = 6, dpi = 300)

# 2) Create trend and dummy variable ----
D <- create_dummy_ts(
  end_basic   = c(2025, 4),
  dummy_start = c(2008, 4),
  dummy_end   = NULL,
  sp          = FALSE,
  start_basic = c(1983, 1),
  basic_value = 0,
  dummy_value = 1,
  frequency   = 4
)

Time       <- ts(seq(1:length(D)), start = c(1983,1), frequency = 4)
GDP        <- ts_data[,'GDP']
U          <- ts_data[,'U']
break_date <- window(Time, start = c(2008,3), end = c(2008,3))
Time_2     <- Time - break_date[1]

# 3) Formal structural break tests ----
sctest(log(GDP) ~ Time, type = "Chow", point = break_date)
sctest(U ~ Time,        type = "Chow", point = break_date)

# 4) Output gap - equation (5) ----
data_gdp  <- ts.union(GDP, Time, D, Time_2)
model_gdp <- lm(log(GDP) ~ Time + I(D*Time_2), data = data_gdp)
summary(model_gdp)
yc <- ts(residuals(model_gdp)*100, start = c(1983,1), frequency = 4)

# Plot output gap
p_yc <- autoplot(yc, linewidth=1, colour='black', facets=FALSE) +
  ggtitle("Output Gap - France") + xlab("") + ylab("yc (%)")
print(p_yc)
ggsave("02_output_gap.png", plot = p_yc, width = 10, height = 4, dpi = 300)

# Plot broken trend vs. actual log(GDP)
fitted_gdp <- ts(fitted(model_gdp), start = c(1983,1), frequency = 4)
ts_gdp_comp <- ts.union("Actual" = log(GDP), "Broken trend" = fitted_gdp)

p_gdp_trend <- autoplot(ts_gdp_comp, facets = FALSE, linewidth=1) +
  ggtitle("Actual log(GDP) vs. Broken Trend - France") +
  xlab("") + ylab("log(GDP)") +
  scale_color_manual(values = c("gray50", "blue")) +
  theme(legend.title = element_blank())
print(p_gdp_trend)
ggsave("03_broken_trend.png", plot = p_gdp_trend, width = 10, height = 4, dpi = 300)

# 5) Cyclical unemployment - equation (6) ----
model_u <- lm(U ~ D)
summary(model_u)
uc <- ts(residuals(model_u), start = c(1983,1), frequency = 4)

# Plot cyclical unemployment
p_uc <- autoplot(uc, linewidth=1, colour='black', facets=FALSE) +
  ggtitle("Cyclical Unemployment Rate - France") + xlab("") + ylab("uc (%)")
print(p_uc)
ggsave("04_cyclical_unemployment.png", plot = p_uc, width = 10, height = 4, dpi = 300)

# Plot natural rate of unemployment vs. actual
fitted_u <- ts(fitted(model_u), start = c(1983,1), frequency = 4)
ts_u_comp <- ts.union("Actual" = U, "Natural rate" = fitted_u)

p_u_trend <- autoplot(ts_u_comp, facets = FALSE, linewidth=1) +
  ggtitle("Actual Unemployment vs. Natural Rate - France") +
  xlab("") + ylab("Unemployment (%)") +
  scale_color_manual(values = c("gray50", "red")) +
  theme(legend.title = element_blank())
print(p_u_trend)
ggsave("05_natural_rate.png", plot = p_u_trend, width = 10, height = 4, dpi = 300)

# 6) Comparison of detrending methods ----
# HP filter
hp_filter <- hpfilter(log(GDP), freq = 1600)
yc_hp     <- ts(hp_filter$cycle * 100, start = c(1983,1), frequency = 4)

# Quadratic trend
data_gdp_quad  <- ts.union(GDP, Time)
model_gdp_quad <- lm(log(GDP) ~ Time + I(Time^2), data = data_gdp_quad)
yc_quad        <- ts(residuals(model_gdp_quad)*100, start = c(1983,1), frequency = 4)

# Compare all methods
all_gaps <- ts.union(yc, yc_hp, yc_quad)
colnames(all_gaps) <- c("Weber (broken trend)", "HP filter", "Quadratic trend")

p_gaps <- autoplot(all_gaps, facets = FALSE, linewidth=1) +
  ggtitle("Comparison of Detrending Methods - France") +
  xlab("") + ylab("Output Gap (%)") +
  scale_color_manual(
    values = c("Weber (broken trend)" = "blue",
               "HP filter"            = "black",
               "Quadratic trend"      = "red")
  ) +
  theme(legend.title = element_blank())
print(p_gaps)
ggsave("06_detrending_comparison.png", plot = p_gaps, width = 10, height = 4, dpi = 300)

# 7) Static Okun's Law - equation (3) ----
Okun_1 <- lm(uc ~ yc - 1)
summary(Okun_1)

Okun_2 <- lm(uc ~ yc)
summary(Okun_2)

stargazer(Okun_1, Okun_2, title = "Results of Equation 3 - France",
          dep.var.labels   = c("Cyclical Unemployment"),
          covariate.labels = c("Output Gap", "Constant"),
          align = TRUE, type = "text")

# 8) Structural break test - equation (3') ----
Okun_3 <- lm(uc ~ yc + I(D*yc) - 1)
summary(Okun_3)

# Post-break coefficient and its standard error
a_D     <- coefficients(Okun_3)[1] + coefficients(Okun_3)[2]
Sigma_3 <- vcov(Okun_3)
std_a_D <- sqrt(Sigma_3[1,1] + Sigma_3[2,2] + 2*Sigma_3[1,2])
writeLines(sprintf("Okun coefficient after break (std. error): %.4f (%.4f)\n",
                   a_D, std_a_D))

# Chow test
sctest(uc ~ yc - 1, type = "Chow", point = break_date)

# Chow predictive test
my_ts      <- ts.union(uc, yc)
my_ts_pre  <- window(my_ts, start = c(1983,1), end = c(2008,3))
my_ts_post <- window(my_ts, start = c(2008,4), end = c(2025,4))

Okun_pre <- lm(uc ~ yc - 1, data = my_ts_pre)

n1       <- nrow(my_ts_pre)
n2       <- nrow(my_ts_post)
RSS_full <- sum(residuals(lm(uc ~ yc - 1, data = my_ts))^2)
RSS_pre  <- sum(residuals(Okun_pre)^2)
F_pred   <- ((RSS_full - RSS_pre) / n2) / (RSS_pre / (n1 - 1))
writeLines(sprintf("Chow predictive test: F = %.4f\n", F_pred))

# 9) Asymmetry of Okun's coefficient ----
D_pos     <- ts(as.numeric(yc > 0), start = c(1983,1), frequency = 4)
Okun_asym <- lm(uc ~ I((1-D_pos)*yc) + I(D_pos*yc) - 1)
summary(Okun_asym)

# 10) Dynamic version - information criteria ----
IC_table <- data.frame(k = 1:4, AIC = NA, BIC = NA, a_LR = NA)

for (k in 1:4){
  mod              <- dynlm(uc ~ L(uc, 1:k) + L(yc, 1:k) - 1)
  d                <- coefficients(mod)
  IC_table$AIC[k] <- AIC(mod)
  IC_table$BIC[k] <- BIC(mod)
  IC_table$a_LR[k]<- sum(d[(k+1):(2*k)]) / (1 - sum(d[1:k]))
}
print(IC_table)

# 11) Optimal model k=3 ----
Okun_opt  <- dynlm(uc ~ L(uc, 1:3) + L(yc, 1:3) - 1)
summary(Okun_opt)

delta_opt <- coefficients(Okun_opt)
a_LR_opt  <- sum(delta_opt[4:6]) / (1 - sum(delta_opt[1:3]))
writeLines(sprintf("Long-run Okun coefficient for k=3: %.4f\n", a_LR_opt))

# Parsimonious model k=3
Okun_par  <- dynlm(uc ~ L(uc, 1) + L(uc, 3) + L(yc, 1:2) - 1)
summary(Okun_par)

d_par    <- coefficients(Okun_par)
a_LR_par <- (d_par[3] + d_par[4]) / (1 - d_par[1] - d_par[2])
writeLines(sprintf("Long-run coefficient (parsimonious model): %.4f\n", a_LR_par))

# 12) Equation (7') - structural break in dynamic version ----

# Variant A: break only in yc coefficients
Okun_7a <- dynlm(uc ~ L(uc, 1:3) + L(yc, 1:3) + I(D*L(yc, 1:3)) - 1)
summary(Okun_7a)

d_a          <- coefficients(Okun_7a)
a_LR_pre_a  <- sum(d_a[4:6]) / (1 - sum(d_a[1:3]))
a_LR_post_a <- sum(d_a[4:6] + d_a[7:9]) / (1 - sum(d_a[1:3]))
writeLines(sprintf("Variant A - pre-break: %.4f, post-break: %.4f\n",
                   a_LR_pre_a, a_LR_post_a))

# Variant B: break also in autoregressive terms
Okun_7b <- dynlm(uc ~ L(uc, 1:3) + L(yc, 1:3) +
                   I(D*L(uc, 1:3)) + I(D*L(yc, 1:3)) - 1)
summary(Okun_7b)

d_b          <- coefficients(Okun_7b)
a_LR_pre_b  <- sum(d_b[4:6]) / (1 - sum(d_b[1:3]))
a_LR_post_b <- sum(d_b[4:6] + d_b[10:12]) / (1 - sum(d_b[1:3] + d_b[7:9]))
writeLines(sprintf("Variant B - pre-break: %.4f, post-break: %.4f\n",
                   a_LR_pre_b, a_LR_post_b))

# Chow test for dynamic model
my_ts_dyn <- ts.union(uc, lag(uc,-1), lag(uc,-2), lag(uc,-3),
                      lag(yc,-1), lag(yc,-2), lag(yc,-3))
my_ts_dyn <- na.omit(my_ts_dyn)
colnames(my_ts_dyn) <- c("uc","uc1","uc2","uc3","yc1","yc2","yc3")

sctest(uc ~ uc1 + uc2 + uc3 + yc1 + yc2 + yc3 - 1,
       data = my_ts_dyn, type = "Chow", point = break_date)

# Parsimonious Variant A (p < 0.05)
Okun_7a_par <- dynlm(uc ~ L(uc, 1) + L(uc, 3) + L(yc, 3) +
                       I(D*L(yc, 2)) - 1)
summary(Okun_7a_par)

d_a_par         <- coefficients(Okun_7a_par)
a_LR_pre_a_par  <- d_a_par[3] / (1 - d_a_par[1] - d_a_par[2])
a_LR_post_a_par <- (d_a_par[3] + d_a_par[4]) / (1 - d_a_par[1] - d_a_par[2])
writeLines(sprintf("Parsimonious Variant A - pre: %.4f, post: %.4f\n",
                   a_LR_pre_a_par, a_LR_post_a_par))

# Parsimonious Variant B (p < 0.05)
Okun_7b_par <- dynlm(uc ~ L(uc, 1) + L(yc, 1) + I(D*L(yc, 2)) - 1)
summary(Okun_7b_par)

d_b_par         <- coefficients(Okun_7b_par)
a_LR_pre_b_par  <- d_b_par[2] / (1 - d_b_par[1])
a_LR_post_b_par <- (d_b_par[2] + d_b_par[3]) / (1 - d_b_par[1])
writeLines(sprintf("Parsimonious Variant B - pre: %.4f, post: %.4f\n",
                   a_LR_pre_b_par, a_LR_post_b_par))

# 13) Delta method and Krinsky-Robb simulation ----
compute_aLR_trim <- function(mod, idx_uc, idx_yc, label, MC = 10000){
  d <- coefficients(mod)
  S <- vcov(mod)

  a_LR <- sum(d[idx_yc]) / (1 - sum(d[idx_uc]))

  # Delta method
  G_1 <- sum(d[idx_yc]) / (1 - sum(d[idx_uc]))^2
  G_2 <- 1 / (1 - sum(d[idx_uc]))
  G   <- numeric(length(d))
  G[idx_uc] <- G_1
  G[idx_yc] <- G_2
  a_std <- sqrt(t(G) %*% S %*% G)

  # Fix seed for reproducible simulation results
  set.seed(123)

  # Krinsky-Robb simulation with trimming (1%-99%)
  a_MC <- numeric(MC)
  for (ii in 1:MC){
    pom      <- mvrnorm(1, d, S)
    a_MC[ii] <- sum(pom[idx_yc]) / (1 - sum(pom[idx_uc]))
  }
  a_trim <- a_MC[a_MC > quantile(a_MC, 0.01) &
                   a_MC < quantile(a_MC, 0.99)]

  writeLines(sprintf(
    "%s: a_LR=%.4f | Delta: std=%.4f CI=(%.4f;%.4f) | Sim: std=%.4f CI=(%.4f;%.4f)\n",
    label, a_LR,
    a_std, a_LR - 2*a_std, a_LR + 2*a_std,
    sd(a_trim), quantile(a_MC, 0.025), quantile(a_MC, 0.975)))
}

compute_aLR_trim(Okun_opt, 1:3, 4:6,            "k=3 no break")
compute_aLR_trim(Okun_7a,  1:3, 4:6,            "Var A - pre-break")
compute_aLR_trim(Okun_7a,  1:3, c(4:6, 7:9),    "Var A - post-break")
compute_aLR_trim(Okun_7b,  1:3, 4:6,            "Var B - pre-break")
compute_aLR_trim(Okun_7b,  c(1:3, 7:9), c(4:6, 10:12), "Var B - post-break")
