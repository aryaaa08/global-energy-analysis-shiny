# Renewable Energy Leaders vs Fossil Fuel–Dependent Countries

An interactive R Shiny dashboard comparing global electricity transition pathways — contrasting countries leading the shift to renewables against those still heavily reliant on fossil fuels.

## 🚀 Live Dashboard

### [Launch the Interactive Shiny Application](https://group1rassingment.shinyapps.io/Grp1_Assignment/)

## Overview

Understanding which countries are leading the transition to renewable energy — and which remain dependent on fossil fuels — is central to climate mitigation, energy security, and long-term sustainability. While international climate accords and renewable technologies have advanced, the pace of transition varies sharply across countries due to differences in economic structure, resource endowment, and policy.

This dashboard (Theme 3: *Renewable Energy Leaders vs Fossil Fuel–Dependent Countries*) structurally compares countries on power-source diversity, fossil fuel reliance, and renewable uptake — going beyond emissions alone to reveal whether renewable expansion is actually coupled with a decline in fossil fuel consumption.

## Data Source

- **Dataset:** [Our World in Data (OWID) Energy Dataset](https://ourworldindata.org/energy) — country-level data on energy production, consumption, electricity generation, and emissions.
- **Time frame:** 1996–2024. Pre-1996 data was excluded due to inconsistent and sparse country-level reporting, which would have compromised comparability.
- **Unit of analysis:** Country (filtered to valid 3-character ISO codes only, to exclude aggregates/regions).

## R Packages Used

| Package | Purpose |
|---|---|
| `shiny` | Core interactive web app framework |
| `bslib` | Bootstrap 5 theming (`bs_theme`) for custom fonts, colors, and layout |
| `dplyr` | Data wrangling — filtering, selecting, mutating |
| `ggplot2` | Static plots (time series, scatter plots, bar charts) |
| `tidyr` | Reshaping data (`pivot_longer`, `drop_na`) |
| `plotly` | Interactive plots and choropleth map (`ggplotly`, `plot_ly`) |
| `readxl` | Reading the raw `.xlsx` OWID dataset |

## Data Cleaning & Preparation

1. **Import:** Raw data read from `owid-energy-data original.xlsx` using `read_excel()`.
2. **Variable selection:** Reduced to ~40 relevant indicators using `select()` — covering identifiers, fossil fuel metrics, renewable/low-carbon metrics, energy intensity, and environmental impact (see full list below).
3. **Row filtering:**
   - `filter(!is.na(iso_code), nchar(iso_code) == 3)` — keeps only actual countries, drops regional/aggregate rows.
   - `filter(year > 1995 & year <= 2024)` — restricts to the 1996–2024 study window.
4. **Missing value check:** `colSums(is.na(OWID_data))` used to inspect completeness.
5. **Export:** Cleaned data written out as `final_energy_analysis_data.csv` for downstream use.

### Indicators Retained

- **Identifiers & scale controls:** `country`, `year`, `iso_code`, `population`, `gdp`
- **Fossil fuel dependence:** `coal_consumption`, `coal_electricity`, `coal_production`, `coal_share_elec`, `oil_consumption`, `oil_electricity`, `oil_production`, `oil_share_elec`, `gas_consumption`, `gas_electricity`, `gas_production`, `fossil_fuel_consumption`, `fossil_share_elec`, `fossil_share_energy`
- **Renewable & low-carbon energy:** `solar_electricity`, `solar_share_elec`, `wind_consumption`, `wind_electricity`, `wind_share_elec`, `hydro_electricity`, `hydro_share_elec`, `nuclear_electricity`, `nuclear_share_elec`, `nuclear_share_energy`, `renewables_energy_per_capita`, `renewables_share_elec`, `renewables_share_energy`, `low_carbon_share_elec`, `low_carbon_share_energy`
- **Energy use & intensity:** `electricity_generation`, `electricity_demand`, `primary_energy_consumption`, `energy_per_capita`, `energy_per_gdp`, `per_capita_electricity`
- **Environmental impact:** `carbon_intensity_elec`, `greenhouse_gas_emissions`

Share-based indicators were prioritized over absolute values to allow fair comparison across countries of different sizes, while per-capita and intensity variables control for population and economic scale.

## App Structure

The app follows a standard Shiny `ui` / `server` pattern with a **6-tab layout** (`tabsetPanel`):

### 1. Overview
Static intro cards explaining the dashboard's purpose, what it shows, how to navigate it, and its data sources — built with `bslib::card()` components and custom CSS styling.

### 2. Time Series
- **Inputs:** `selectInput` (country, indicator), `sliderInput` (year range), `checkboxInput` (trend smoother, 2020 reference line)
- **Reactive:** `ts_data()` — filters by country/year range, selects the chosen indicator, drops NAs
- **Output:** `renderPlot()` — `ggplot2` line + point chart, with an optional `loess()`-based trend smoother overlaid
- **Insight text:** `renderText()` dynamically classifies a country as a "renewable leader" or "fossil-dependent" based on the latest renewable share value (>40% threshold)

### 3. Cross-Country Comparison
- **Inputs:** `selectInput` (year), `radioButtons` (chart type: renewables vs fossil / renewables vs carbon intensity / top-10 bar chart)
- **Output:** `renderPlot()` — a single reactive plot with three branches depending on user selection, including `geom_vline`/`geom_hline` reference thresholds at 50% and a `slice_head(n = 10)` ranking for the "Top Renewable Leaders" bar chart

### 4. Composition / Mix
- **Reactive:** `mix_data_simple()` — filters by country/year, selects fuel-share columns, reshapes wide-to-long with `pivot_longer()`
- **Output:** `renderPlotly()` — bar chart of electricity mix by fuel type (coal, oil, gas, nuclear, solar, wind, hydro), converted to interactive with `ggplotly()`
- **Interpretation:** `renderUI()` dynamically identifies the dominant fuel type using `arrange(desc(share))` + `slice_head(n = 1)`

### 5. Map Panel
- **Reactive:** `map_data()` — filters by year, drops missing ISO codes/indicator values
- **Output:** `renderPlotly()` — `plot_ly(type = "choropleth")` world map using `locationmode = "ISO-3"`, toggle between renewable share and fossil share
- **Interpretation:** `renderUI()` surfaces the top-ranked country for the selected indicator/year

### 6. GDP vs Renewable Share
- **Inputs:** `selectInput` (year), `sliderInput` (GDP range)
- **Reactive:** `gdp_renew_data()` — filters by year and GDP range, drops NAs on GDP/renewable share
- **Output:** `renderPlotly()` — bubble scatter (`geom_point` sized by `population`) with a `geom_smooth()` trend line, converted via `ggplotly()`
- **Interpretation:** `renderUI()` explains that GDP alone doesn't determine renewable adoption

## Styling / Design

- Custom `bs_theme()` (Bootstrap 5) with the Inter Google Font, a blue/grey palette, and rounded corners (`border_radius = 0.75`)
- Consistent design tokens defined globally: `PRIMARY_BLUE`, `NEUTRAL_GREY`, `LIGHT_GREY`, `BACKGROUND`, `CARD_WHITE`, `INSIGHT_GREEN`, `REFERENCE_AMBER`
- A shared `energy_theme()` function wraps `theme_minimal()` for consistent `ggplot2` styling (fonts, colors, legend position) across every static chart
- Custom CSS injected via `tags$style(HTML(...))` for card shadows, sidebar styling, and active-tab highlighting

## Key Findings

- The energy transition is **uneven** — renewable growth does not always translate into proportionally reduced fossil fuel use.
- The strongest performers are not simply the countries with the largest renewable *capacity*, but those most successfully **reducing fossil fuel consumption and associated emissions** alongside it.
- **High GDP does not guarantee high renewable adoption** — several moderate-GDP countries with strong solar/wind/hydro investment have emerged as clean-energy frontrunners, showing that policy and energy structure matter more than income level alone.


## Running the Dashboard Locally

```r
# Install required packages
install.packages(c("shiny", "bslib", "dplyr", "ggplot2", "tidyr", "plotly", "readxl"))

# Run the app
shiny::runApp("R/app.R")
```

## License

This project is licensed under the [Apache License 2.0](LICENSE).
