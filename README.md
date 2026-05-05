# Estimation of Okun's Law – France

An econometric analysis of Okun's Law for France using quarterly data from 1983 Q1 to 2025 Q4 (172 observations). The analysis covers detrending, static and dynamic estimation of Okun's coefficient, structural break testing, asymmetry analysis, and long-run inference via the Delta and Krinsky-Robb methods.

## Data Sources

| Variable | Source | Period | Unit |
|---|---|---|---|
| Real GDP | Eurostat (`namq_10_gdp`, chain-linked volumes, index 2020 = 100, seasonally adjusted) | 1980 Q1 – 2025 Q4 | Index, 2020 = 100 |
| Unemployment rate | OECD (monthly rate averaged to quarters, persons aged 15+, seasonally and calendar adjusted) | 1983 Q1 – 2025 Q4 | % of labour force |

## Key Findings

### 1. Structural Break and Detrending

A structural break was identified in **2008 Q3** (the global financial crisis) and confirmed by Chow tests for both series:

| Variable | F-statistic | p-value |
|---|---|---|
| log(GDP) | 375.81 | < 0.001 |
| Unemployment | 20.47 | < 0.001 |

Cyclical components were extracted using Weber's broken linear trend method. GDP is log-transformed before detrending. The residuals represent the **output gap** ( $y_c$ ) and **cyclical unemployment** ( $u_c$ ).

The broken trend model is compared against an HP filter ( $\lambda = 1600$ ) and a quadratic trend. The Weber approach is preferred as it explicitly accounts for the structural loss of growth momentum after 2008, which the HP filter and quadratic trend fail to capture adequately.

**Estimated trend parameters:**

| Parameter | Interpretation | Estimate |
|---|---|---|
| $\beta_0$ | Initial level of log(GDP) | 4.015 |
| $\beta_1$ | Potential GDP growth rate before 2008 Q3 | 0.5437 % per quarter |
| $\beta_2$ | Change in growth rate after 2008 Q3 | −0.3396 % per quarter |
| $\gamma_0$ | Natural unemployment rate before 2008 Q3 | 9.14 % |
| $\gamma_1$ | Change in natural rate after 2008 Q3 | −0.29 % |

Potential GDP growth fell from 0.54 % per quarter (≈ 2.17 % annually) to 0.20 % per quarter (≈ 0.81 % annually) after the crisis.

### 2. Static Okun's Law – Equation (3)

$$u_c = \alpha \cdot y_c + \varepsilon$$

| Model | Coefficient | Std. error | p-value | $R^2$ |
|---|---|---|---|---|
| Without constant | −0.116 | 0.033 | < 0.001 | 0.066 |
| With constant | −0.116 | 0.033 | < 0.001 | 0.066 |

A 1 % decline in the output gap is associated with a **0.116 pp increase in cyclical unemployment**. The constant is practically zero and statistically insignificant ( $p = 1.000$ ), confirming that detrending centred both variables correctly.

### 3. Structural Stability of Okun's Coefficient

| Test | F-statistic | p-value | Conclusion |
|---|---|---|---|
| Chow structural break test | 0.400 | 0.528 | Stability not rejected |
| Chow predictive test | 1.126 | — | Stability not rejected |

Although the coefficient mildly weakened after the crisis (−0.142 → −0.099), the difference is **not statistically significant**.

### 4. Asymmetry

The static model was extended to test whether the Okun coefficient differs between expansions and recessions:

$$u_c = \alpha^{-} \cdot \mathbf{1}[y_c < 0] \cdot y_c + \alpha^{+} \cdot \mathbf{1}[y_c > 0] \cdot y_c + \varepsilon$$

| Phase | Coefficient | Std. error | p-value |
|---|---|---|---|
| Recession ( $y_c < 0$ ) | −0.029 | 0.041 | 0.475 |
| Boom ( $y_c > 0$ ) | −0.265 | 0.053 | < 0.001 |

Unemployment responds strongly and significantly during economic booms, but is **statistically unresponsive during recessions** — consistent with strong employment-protection institutions in France that prevent layoffs during downturns.

### 5. Dynamic Okun's Law – Equation (7)

$$u_{c,t} = \sum_{i=1}^{k} \phi_i \, u_{c,t-i} + \sum_{i=1}^{k} \alpha_i \, y_{c,t-i} + \varepsilon_t$$

The long-run coefficient is:

$$\alpha^{LR} = \frac{\sum_{i=1}^{k} \alpha_i}{1 - \sum_{i=1}^{k} \phi_i}$$

Information criteria for $k = 1, \ldots, 4$:

| $k$ | AIC | BIC | $\alpha^{LR}$ |
|---|---|---|---|
| 1 | −28.38 | −18.95 | −0.734 |
| 2 | −75.44 | −59.76 | −0.547 |
| **3** | **−84.62** | **−62.71** | **−0.359** |
| 4 | −79.89 | −51.78 | −0.299 |

Both AIC and BIC select **k = 3** as optimal. The long-run Okun coefficient of **−0.359** means a permanent 1 % decline in the output gap leads to a 0.36 pp increase in cyclical unemployment. The model achieves $R^2 = 0.969$.

### 6. Structural Break in the Dynamic Model

The Chow test for the dynamic model (F = 1.665, p = 0.133) does **not** reject stability. Illustrative estimates of pre- and post-break long-run coefficients:

| Model variant | $\alpha^{LR}$ pre-break | $\alpha^{LR}$ post-break |
|---|---|---|
| Variant A – full | −0.251 | −0.441 |
| Variant B – full | −0.219 | −0.388 |

### 7. Standard Errors of Long-Run Coefficients

Standard errors and 95 % confidence intervals estimated via the **Delta method** and **Krinsky-Robb simulation** (10,000 replications, trimmed at 1 %–99 % to handle near-zero denominators in highly autoregressive settings):

| Model | $\alpha^{LR}$ | Delta std | Sim std | Delta 95 % CI | Sim 95 % CI |
|---|---|---|---|---|---|
| k=3, no break | −0.359 | 0.214 | 0.284 | (−0.786; 0.069) | (−1.320; 0.136) |
| Var A pre-break | −0.251 | 0.285 | 0.367 | (−0.822; 0.320) | (−1.290; 0.567) |
| Var A post-break | −0.441 | 0.290 | 0.402 | (−1.022; 0.140) | (−1.761; 0.199) |
| Var B pre-break | −0.219 | 0.410 | 0.997 | (−1.038; 0.600) | (−3.207; 2.402) |
| Var B post-break | −0.388 | 0.229 | 0.359 | (−0.847; 0.070) | (−1.681; 0.128) |

All confidence intervals include zero, indicating that long-run coefficients are **not statistically significant at the 5 % level** — a direct consequence of the high persistence in the unemployment series.

## Summary of Conclusions

- The **2008 Q3 structural break** is confirmed for both GDP and unemployment.
- The **static Okun coefficient (−0.116)** is statistically significant but modest.
- **Strong asymmetry**: the coefficient is −0.265 during booms (significant) and −0.029 during recessions (not significant), likely reflecting French labour market protections.
- The **dynamic model (k = 3)** raises $R^2$ to 0.969 and yields a long-run coefficient of −0.359, substantially larger than the static estimate due to gradual labour market adjustment.
- **Dynamic structural stability is not rejected** (F = 1.665, p = 0.133).
- All long-run confidence intervals include zero, pointing to limited statistical power in long-run inference.

## How to Run

1. Clone the repository or download `Okun_Law_France.R`.
2. Place `gdp.csv` and `unemployment.csv` in the same directory (see Data Sources above for variable definitions).
3. Install required packages:

```r
install.packages(c("readr", "ggplot2", "ggfortify", "patchwork",
                   "dynlm", "tstools", "stargazer",
                   "strucchange", "mFilter", "MASS"))
```

4. Run `Okun_Law_France.R` in R or RStudio.

Output charts are saved as `.png` files in the working directory.

## References

Carcillo, S., Goujard, A., Hijzen, A., & Thewissen, S. (2019). *Assessing recent reforms and policy directions in France: Implementing the OECD Jobs Strategy*. OECD. https://www.oecd.org/content/dam/oecd/en/publications/reports/2019/05/assessing-recent-reforms-and-policy-directions-in-france_73d71921/657a0b54-en.pdf
