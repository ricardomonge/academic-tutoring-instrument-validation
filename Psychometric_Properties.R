# =============================================================================
# Load Required Libraries -----------------------------------------------------
# =============================================================================

library(dplyr)         # Data manipulation
library(ggplot2)       # Data visualization
library(readr)         # To read CSV (.csv) files
library(grid)          # Grid graphics
library(gridExtra)     # Arrange multiple grid-based plots
library(labelled)      # Label variables
library(gtsummary)     # Summary tables for publication
library(huxtable)      # Publication-ready tables
library(QuantPsyc)     # Mardia multivariate normality test
library(nortest)       # Univariate normality tests (e.g., Anderson-Darling)
library(purrr)         # Functional programming tools
library(semPlot)       # SEM path diagrams
library(psych)         # Psychometrics, includes ordinal alpha
library(MVN)           # Multivariate normality
library(corrplot)      # Correlation matrix visualization
library(parameters)    # Determine number of factors
library(performance)   # Complement parameters/psych for model checks
library(nFactors)      # Required for parameters (factor analysis)
library(lavaan)        # Confirmatory factor analysis (CFA)
library(see)           # Graphical tools for model diagnostics
library(EGAnet)        # Exploratory Graph Analysis (EGA)
library(semTools)      # Supplementary tools for SEM

# =============================================================================
# Load and Clean Dataset ------------------------------------------------------
# =============================================================================

file_path1 <- "data/data_participants.csv"
df2 <- read_csv(file_path1)

# Discard participants who did not accept the informed consent
df2 <- df2 |>
  dplyr::filter(informed_consent == "Sí")

# Create total score by summing items 16 to 30
df2 <- df2 %>% 
  mutate(total = rowSums(dplyr::select(., 16:30)))

# Remove outliers using Hampel filter
cota_inferior <- median(df2$total) - 3 * mad(df2$total, constant = 1)
cota_superior <- median(df2$total) + 3 * mad(df2$total, constant = 1)
outlier_ind <- which(df2$total < cota_inferior | df2$total > cota_superior)
df2_so <- df2[!(row.names(df2) %in% outlier_ind), ]

# =============================================================================
# Variable Labels and Subsets -------------------------------------------------
# =============================================================================

df2_so <- df2_so |> 
  labelled::set_variable_labels(
    sex = "Sexo",
    age = "Edad",
    campus = "Campus",
    modalidad = "Modalidad",
    regime = "Régimen",
    field_OCDE = "Campo principal OCDE",
    school = "Escuela",
    faculty = "Facultad",
    current_level = "Año cursando",
    unders_and_accept_inst = "¿Cuál fue el grado de comprensión y aceptación de 
                              este instrumento?",
    unders_items = "¿Cuál fue el grado de comprensión de las preguntas?",
    satisfac_instrument = "¿Cuál fue el grado de satisfacción con este 
                          instrumento?"
  )

# Select sociodemographic variables
df2_so_demo <- df2_so |>
  dplyr::select("sex", "age", "modalidad", "field_OCDE", "current_level")

# Summary table for sociodemographic variables
theme_gtsummary_eda(set_theme = TRUE)
tbl_summary(df2_so_demo) %>%
  modify_header(label = "Variable") %>%
  modify_caption("Tabla 1. Caracterización de los participantes") %>%
  as_hux_table()

# Select satisfaction-related variables
df2_so_sat <- df2_so %>%
  dplyr::select("unders_and_accept_inst", "unders_items", "satisfac_instrument")

# Frequency table for satisfaction variables
theme_gtsummary_eda(set_theme = TRUE)
tbl_summary(df2_so_sat) %>%
  modify_header(label = "Variable") %>%
  modify_caption("Tabla 2. Distribución de frecuencias de satisfacción con el 
                 instrumento") %>%
  as_hux_table()

# =============================================================================
# Exploratory and Confirmatory Factor Analysis --------------------------------
# =============================================================================

set.seed(123)
df2_so <- as.data.frame(df2_so)
df2_items <- dplyr::select(df2_so, 16:30)
names(df2_items)

# Split dataset into EFA and CFA samples
N <- nrow(df2_items)
indices <- seq(1, N)
indices_AFE <- sample(indices, floor(0.5 * N))
indices_AFC <- indices[!(indices %in% indices_AFE)]
df2_EFA <- df2_items[indices_AFE, ]
df2_AFC <- df2_items[indices_AFC, ]

knitr::kable(head(df2_EFA), booktabs = TRUE, format = "markdown")
knitr::kable(describe(df2_EFA, type = 3, fast = FALSE), booktabs = TRUE, 
             format = "markdown")
knitr::kable(response.frequencies(df2_EFA), booktabs = TRUE, 
             format = "markdown")

# =============================================================================
# Normality Tests -------------------------------------------------------------
# =============================================================================

mardia_result <- QuantPsyc::mult.norm(df2_EFA)
print(mardia_result$mult.test)

univar_ad <- apply(df2_EFA, 2, ad.test)
resultado_uni <- data.frame(
  Variable = names(univar_ad),
  AD_statistic = sapply(univar_ad, function(x) round(x$statistic, 4)),
  p_value = sapply(univar_ad, function(x) round(x$p.value, 4))
)
knitr::kable(resultado_uni, booktabs = TRUE, format = "markdown",
             caption = "Univariate normality tests using Anderson-Darling")

# =============================================================================
# Assessment of Factorability of the Correlation Matrix -----------------------
# =============================================================================

performance::check_factorstructure(df2_EFA)

salida <- polychoric(df2_EFA, smooth = TRUE)
salida_matriz <- salida$rho

alpha_ordinal <- psych::alpha(salida_matriz, check.keys = TRUE)
intervalo_alpha_ordinal <- psych::alpha.ci(alpha_ordinal[["total"]][["raw_alpha"]], 
                                           495, 15, p.val = .05, digits = 4)
for (i in 1:length(intervalo_alpha_ordinal)) print(intervalo_alpha_ordinal[i])

corrplot(salida_matriz, type = "upper", tl.pos = "tp")
corrplot(salida_matriz, add = TRUE, type = "lower", method = "number",
         col = "black", diag = FALSE, tl.pos = "n", cl.pos = "n", 
         number.cex = 0.9)

# =============================================================================
# Factor Retention Criteria and Factor Number Estimation ----------------------
# =============================================================================

resultado_nfactors <- n_factors(df2_EFA, cor = salida_matriz, 
                                rotation = "varimax",
                                algorithm = "wls", n = 494)
plot(resultado_nfactors)
as.data.frame(resultado_nfactors)
summary(resultado_nfactors)

# =============================================================================
# Exploratory Factor Analysis (EFA) -------------------------------------------
# =============================================================================

df2_EFA <- as.data.frame(lapply(df2_EFA, as.integer))

RDAfactor <- fa(df2_EFA, nfactors = 3, fm = "wls", rotate = "varimax", 
                cor = "poly")
print(RDAfactor, digits = 2, cut = .5, sort = FALSE)

# =============================================================================
# Confirmatory Factor Analysis (CFA) ------------------------------------------
# =============================================================================

tresfactores <- '
F1 =~ A1+A2+A3+A4
F2 =~ E1+E2+E3+E4+E5+E6
F3 =~ C1+C2+C3+C4+C5'

CFAtres <- lavaan::cfa(model = tresfactores, data = df2_AFC, 
                       ordered = names(df2_AFC), estimator = "DWLS", 
                       representation = "LISREL")

fitMeasures(CFAtres, c("chisq", "df", "pvalue", "gfi", "rmsea", "srmr", 
                       "cfi", "tli", "agfi", "pnfi", "ifi"))

semPaths(CFAtres, nCharNodes = 0, intercepts = FALSE, edge.label.cex = 1.3,
         optimizeLatRes = TRUE, groups = "lat", pastel = TRUE, sizeInt = 5,
         edge.color = "black", esize = 5, label.prop = 0, sizeLat = 11, "std", 
         layout = "circle3", exoVar = FALSE)

parameterEstimates(CFAtres, standardized = TRUE) %>% subset(op == "~~" & lhs != rhs)
parameterEstimates(CFAtres, standardized = TRUE) %>% subset(op == "=~")
parameterEstimates(CFAtres, standardized = TRUE) %>% subset(op == "~~" & lhs == rhs & grepl("^i\\d+", lhs))

# =============================================================================
# Convergent Validity (AVE) ---------------------------------------------------
# =============================================================================

cr_results <- semTools::compRelSEM(CFAtres)
ave_results <- semTools::AVE(CFAtres)

cov_std_lv <- standardizedSolution(CFAtres) %>%
  dplyr::filter(op == "~~", lhs != rhs) %>%
  dplyr::select(Factor1 = lhs, Factor2 = rhs, Std_LV_Covariance = est.std)

get_std_lv <- function(f1, f2) {
  val <- cov_std_lv %>%
    dplyr::filter((Factor1 == f1 & Factor2 == f2) | (Factor1 == f2 & Factor2 == f1)) %>%
    dplyr::pull(Std_LV_Covariance)
  if (length(val) == 0) return("-") else return(val)
}

Dimensions <- c("F1", "F2", "F3")

F1 <- c(
  as.numeric(ave_results["F1"]),
  get_std_lv("F1", "F2")^2,
  get_std_lv("F1", "F3")^2
)

F2 <- c("-", as.numeric(ave_results["F2"]),
        get_std_lv("F2", "F3")^2)

F3 <- c("-", "-", as.numeric(ave_results["F3"]))

matrix_VD <- data.frame(Dimensions, F1, F2, F3, stringsAsFactors = FALSE)

matrix_VD[ , 2:4] <- lapply(matrix_VD[ , 2:4], function(col) {
  if (is.numeric(col)) {
    sprintf("%.4f", col)
  } else {
    sapply(col, function(x) {
      if (suppressWarnings(!is.na(as.numeric(x)))) {
        sprintf("%.4f", as.numeric(x))
      } else {
        x
      }
    })
  }
})
print(matrix_VD, right = FALSE, row.names = FALSE)

# =============================================================================
# Composite Reliability (CR) --------------------------------------------------
# =============================================================================

sl <- standardizedSolution(CFAtres) %>%
  filter(op == "=~") %>%
  dplyr::select(lhs, rhs, est.std) %>%
  mutate(re = 1 - est.std^2)
names(sl) <- c("dimensions", "item", "CFE", "Error")

tl <- sl %>%
  arrange(dimensions) %>%
  group_by(dimensions) %>%
  mutate(fc = sum(CFE)^2 / (sum(CFE)^2 + sum(Error)))
tabla_fc <- aggregate(tl[, 5], list(tl$dimensions), mean)
names(tabla_fc) <- c("Factor", "CR")
tabla_fc

# =============================================================================
# Discriminant Validity (HTMT) ------------------------------------------------
# =============================================================================

htmt_manual <- function(cor_matrix, grupos) {
  n <- length(grupos)
  htmt_values <- matrix(NA, n, n)
  rownames(htmt_values) <- colnames(htmt_values) <- names(grupos)
  
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      cor_cross <- cor_matrix[grupos[[i]], grupos[[j]]]
      cor_within_i <- cor_matrix[grupos[[i]], grupos[[i]]]
      cor_within_j <- cor_matrix[grupos[[j]], grupos[[j]]]
      htmt_ij <- mean(abs(cor_cross)) / sqrt(mean(abs(cor_within_i)) * mean(abs(cor_within_j)))
      htmt_values[i, j] <- htmt_ij
      htmt_values[j, i] <- htmt_ij
    }
  }
  return(htmt_values)
}

grupos <- list(
  F1 = c("A1", "A2", "A3", "A4"),
  F2 = c("E1", "E2", "E3", "E4", "E5", "E6"),
  CC = c("C1", "C2", "C3", "C4", "C5")
)

htmt_matrix <- htmt_manual(salida_matriz, grupos)
print(htmt_matrix)

# =============================================================================
# Exploratory Graph Analysis (EGA) -------------------------------------------
# =============================================================================

ega.srce <- EGA(data = df2_EFA, model = "glasso", plot.EGA = TRUE)

df2_EFA_boot <- bootEGA(
  data = df2_EFA,
  seed = 3,
  iter = 500,
  ncores = 4,
  model = "glasso"
)

summary(df2_EFA_boot)

