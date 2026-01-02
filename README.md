# Data, Python and R Scripts for the Validation of the Academic Tutoring Perception Scale (ATPS) in Chilean University Students

This repository contains Python and R scripts, along with anonymized datasets, used in the development and psychometric validation of the **Academic Tutoring Perception Scale (ATPS)** for higher education students in Chile.

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.16789795.svg)](https://doi.org/10.5281/zenodo.16789795)
---

## Repository Structure

```
├── data/                              # Contains anonymized datasets
│   ├── data_Aiken_Tutoring.csv        # Expert ratings for Aiken’s V analysis
│   ├── data_participants.csv          # Survey data from university students
│   └── demo_judges.csv                # Demographic data of expert judges
├── aiken_v_analysis.ipynb             # Content validity analysis using Aiken’s V (Python)
├── Psychometric_Properties.R          # EFA and CFA analysis (R)
├── README.md                          # Project overview and documentation
```

---

## Description of Scripts

- `aiken_v_analysis.ipynb`: Computes Aiken’s V coefficient and confidence intervals to assess content validity of items, based on expert ratings.
- `Psychometric_Properties.R`: Conducts exploratory factor analysis (EFA), confirmatory factor analysis (CFA), and computes psychometric indicators such as reliability.

---

## Data Overview

| File                      | Description                                                                 |
|---------------------------|-----------------------------------------------------------------------------|
| `data_Aiken_Tutoring.csv` | Expert item ratings for Aiken’s V content validity analysis.               |
| `data_participants.csv`   | Full anonymized dataset from university students who completed the ATPS.   |
| `demo_judges.csv`         | Sociodemographic information of the expert judges.                         |

All datasets are fully anonymized and comply with ethical and institutional research guidelines.

---

## Requirements

To reproduce the analyses, ensure you have the following:

### Python (for content validity)
- `pandas`
- `matplotlib`
- `tabulate`

Install using:

```bash
pip install pandas matplotlib tabulate
```

### R (for factor analysis)
```r
install.packages(c(
  "tidyverse", "readxl", "gtsummary", "lavaan", "psych",
  "nFactors", "semTools", "EGAnet", "corrplot"
))
```

---

## How to Reproduce the Analyses

1. Clone or download this repository.
2. Place the `/data` folder in your working directory.
3. Run the following scripts in order:

   1. `aiken_v_analysis.ipynb` (Python): analyzes content validity.
   2. `Psychometric_Properties.R` (R): conducts EFA, CFA, and reliability analysis.

---

## Authors and Affiliations

- **Bárbara Díaz-Torres**¹  
- **Ricardo Monge-Rogel**²³ *(Corresponding author: rmonge@udla.cl)*  
- **Mauricio Gallardo-Caballero**⁴  
- **Celeste Reyes-Pastrian**²  

¹ Facultad de Educación, Universidad de Las Américas, Santiago, Chile  
² Instituto de Matemática, Física y Estadística, Universidad de Las Américas, Santiago, Chile  
³ Grupo de Investigación en Educación STEM, Universidad de Las Américas, Santiago, Chile  
⁴ Vicerrectoría Académica, Universidad de Las Américas, Santiago, Chile

---

## Data Provenance and Ethical Compliance

The datasets in this repository were collected as part of a research project aimed at the Development and Psychometric Validation of the Academic Tutoring Perception Scale (ATPS) for higher education students in Chile.

All participants were university students who voluntarily completed the instrument and provided informed consent for the use of their data for academic research purposes. Data collection adhered to institutional ethical guidelines for research involving human subjects.

All data are fully anonymized and provided solely for academic transparency and replication.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Citation

If you use this repository or its contents, please cite the corresponding article:

**APA:**

> Díaz-Torres, B., Monge-Rogel, R., Gallardo-Caballero, M., & Reyes-Pastrián, C. (2025). Data, Python and R Scripts for the Validation of the Academic Tutoring Perception Scale (ATPS) in Chilean University Students (v0.0.1) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.16789795

**BibTeX:**

```bibtex
@dataset{diaz_torres_2025_16789795,
  author       = {Díaz-Torres, Bárbara and
                  Monge-Rogel, Ricardo and
                  Gallardo-Caballero, Mauricio and
                  Reyes-Pastrián, Celeste},
  title        = {Data, Python and R Scripts for the Validation of
                   the Academic Tutoring Perception Scale (ATPS) in
                   Chilean University Students
                  },
  month        = aug,
  year         = 2025,
  publisher    = {Zenodo},
  version      = {v0.0.1},
  doi          = {10.5281/zenodo.16789795},
  url          = {https://doi.org/10.5281/zenodo.16789795},
}
```
