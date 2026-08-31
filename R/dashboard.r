---
title: "APP.R"
format: html
rumtime:shiny 
---

## Introduction:

In today’s world of accelerating climate change, volatile fossil fuel markets, and global commitments to net-zero emissions, understanding which countries are leading the transition to renewable energy and which are still dependent on fossil fuels is become critically important. Energy systems are no longer only a matter of economic growth but are central to climate mitigation, energy security, and long-term sustainability.

Although international climate accords have been signed and the development of renewable energy technologies has been quite fast, the transition to clean energy has not been the same in every country. A few countries have quickly increased their solar, wind, hydroelectric, and nuclear power capacities, thus diminishing their use of coal, oil, and gas. On the other hand, some countries’ heavy reliance on fossil fuels is a result of factors such as their economic structure, the type and amount of resources available to them, or restrictions in their policy. The varying situations of the countries affect not just their emissions amounts but also the whole planet's climate.

The uneven transition sets the foundation for the selection of Theme 3: Renewable Energy Leaders vs Fossil Fuel–Dependent Countries. This topic gives the opportunity to structurally compare the countries in terms of their power source diversity, fossil fuel reliance, and renewable energy uptake besides just the emissions. Dashboard focuses on both renewable leadership and fossil fuel reliance, thereby revealing if the expansion of renewables is coupled with a significant fall in fossil fuel consumption. This method is crucial in spotting and tracing structural energy transitions and hence understanding the diverse progress on the path to decarbonisation across different nations.

```{r}
# ==========================
# LIBRARIES
# ==========================

library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(tidyr)
library(plotly)
library(readxl)
library(dplyr)


```

## Methodology:   Data Cleaning and Preparation Process

### 1. Data Source and Initial Import

The dataset used for this dashboard is sourced from **Our World in Data (OWID)**, specifically the *OWID Energy Dataset*, which gives us country-level information on energy production, consumption, electricity generation, and emissions.

The data was imported into R using the `readxl` package, ensuring that the original structure and variable formats were preserved during import.

```{r}
OWID_data <- read_excel("owid-energy-data original.xlsx")

```

## Years selected : (1996–2024)

The time frame of 1996–2024 was mainly considered for this analysis. This period reflects the world’s energy transition, as it covers the modern phase of the transition with the growth of renewables and changes in the use of fossil fuels. The years preceding 1996 were omitted because there was little and inconsistent reporting on energy consumption by different countries, which could make it difficult to compare them. Thus, limiting the analysis to this timeframe allows for more dependable time-series trends, and still, it provides enough width for the countries comparison to be significant.

### Indicator Selection (Variable Filtering)

Theme 3 was chosen as the theme: Renewable energy leaders vs Fossil Fuel-Dependent countries. , a targeted subset of indicators was selected to capture contrasts between clean-energy frontrunners and fossil-reliant economies.

```{r}
OWID_data <- OWID_data %>%
  select(
    country,
    year,
    iso_code,
    population,
    gdp,
    carbon_intensity_elec,
    coal_consumption,
    coal_electricity,
    coal_production,
    coal_share_elec,
    electricity_demand,
    electricity_generation,
    energy_per_capita,
    energy_per_gdp,
    fossil_energy_per_capita,
    fossil_fuel_consumption,
    fossil_share_elec,
    fossil_share_energy,
    gas_consumption,
    gas_electricity,
    gas_production,
    greenhouse_gas_emissions,
    hydro_electricity,
    hydro_share_elec,
    low_carbon_share_elec,
    low_carbon_share_energy,
    nuclear_electricity,
    nuclear_share_elec,
    nuclear_share_energy,
    oil_consumption,
    oil_electricity,
    oil_production,
    oil_share_elec,
    per_capita_electricity,
    primary_energy_consumption,
    renewables_energy_per_capita,
    renewables_share_elec,
    renewables_share_energy,
    solar_electricity,
    solar_share_elec,
    wind_consumption,
    wind_electricity,
    wind_share_elec
  )
# str(OWID_data)
# colnames(OWID_data)
# summary(OWID_data) #to check if R id reading the data correctly

OWID_data <- OWID_data %>%
  filter(!is.na(iso_code),
         nchar(iso_code) == 3)  #to get only country wise analysis
OWID_data <- OWID_data %>%
  filter(year > 1995 & year <= 2024) #to get data from 1996 to 2024

colSums(is.na(OWID_data))
write.csv(OWID_data, "final_energy_analysis_data.csv", row.names = FALSE) #final working datasheet
#=========================================================================================================================

```

## Indicators Used:

The chosen indicators serve the purpose of differentiating the countries that are renewable energy leaders from those that are fossil fuel-dependent ones by considering the structure of the energy system and its environmental outcomes. The fossil fuel variables (coal, oil, and gas consumption along with their shares in electricity) reflect the degree of fossil fuel reliance, while the renewable and low-carbon indicators (solar, wind, hydro, and nuclear, plus their shares) point out the countries that have technically diversified their energy mix. Share-based indicators take precedence over absolute measures so that a meaningful comparison can be made among countries with different sizes. Energy intensity and per-capita variables are used to control for the effects of population and economic scale respectively, thus avoiding misleading comparisons based solely on country size. Lastly, carbon intensity and greenhouse gas emissions are the means through which energy composition is connected to climate outcomes, thereby enabling the evaluation of whether the growth of renewables leads to less emissions. In combination, these indicators form a logical, country-based structure for assessing the various energy transition pathways that are not equal in today's global context.\

-   **Identifiers & Scale Controls**:\
    `country`, `year`, `iso_code`, `population`, `gdp`

-   **Fossil Fuel Dependence**:\
    `coal_consumption`, `coal_electricity`, `coal_production`, `coal_share_elec`,\
    `oil_consumption`, `oil_electricity`, `oil_production`, `oil_share_elec`,\
    `gas_consumption`, `gas_electricity`, `gas_production`,\
    `fossil_fuel_consumption`, `fossil_share_elec`, `fossil_share_energy`

-   **Renewable & Low-Carbon Energy**:\
    `solar_electricity`, `solar_share_elec`,\
    `wind_consumption`, `wind_electricity`, `wind_share_elec`,\
    `hydro_electricity`, `hydro_share_elec`,\
    `nuclear_electricity`, `nuclear_share_elec`, `nuclear_share_energy`,\
    `renewables_energy_per_capita`, `renewables_share_elec`, `renewables_share_energy`,\
    `low_carbon_share_elec`, `low_carbon_share_energy`

-   **Energy Use & Intensity**:\
    `electricity_generation`, `electricity_demand`, `primary_energy_consumption`,\
    `energy_per_capita`, `energy_per_gdp`, `per_capita_electricity`

-   **Environmental Impact**:\
    `carbon_intensity_elec`, `greenhouse_gas_emissions`

# DASHBOARD CODE:

```{r}
# ==========================
# DESIGN TOKENS (GLOBAL)
# ==========================
PRIMARY_BLUE    <- "#2563EB"
NEUTRAL_GREY    <- "#6B7280"
LIGHT_GREY      <- "#E5E7EB"
BACKGROUND      <- "#F7F9FB"
CARD_WHITE      <- "#FFFFFF"
INSIGHT_GREEN   <- "#047857"
REFERENCE_AMBER <- "#F59E0B"

# ==========================
# UI
# ==========================

ui <- fluidPage(
  theme = bs_theme(
    version = 5,
    bootswatch = NULL,
    bg = BACKGROUND,
    fg = "#111827",
    primary = PRIMARY_BLUE,
    secondary = NEUTRAL_GREY,
    base_font = font_google("Inter"),
    heading_font = font_google("Inter"),
    border_radius = 0.75
  ),
  tags$style(HTML("
    body { background-color: #F7F9FB; }

    .sidebar {
      background-color: #FFFFFF;
      border-radius: 16px;
      padding: 18px;
      box-shadow: 0 8px 24px rgba(0,0,0,0.06);
    }

    .card {
      background-color: #FFFFFF;
      border-radius: 18px;
      border: none;
      box-shadow: 0 10px 30px rgba(0,0,0,0.06);
    }
     .nav-tabs .nav-link {
      color: #6B7280;
      font-weight: 500;
    }

    .nav-tabs .nav-link.active {
      color: #2563EB;
      border-bottom: 3px solid #2563EB;
      background-color: transparent;
    }
  ")),
  
  # ---- Header ----
  div(
    style = "padding: 15px 5px;",
    h2("Renewable Energy Leaders vs Fossil Fuel–Dependent Countries"),
    p(
      "Comparing electricity transition pathways, energy mix, and economic capacity across countries",
      style = "color:#6B7280;"
    )
  ),
  
  # ---- Tabs ----
  tabsetPanel(
    
    # ==========================
    # INTRODUCTION / OVERVIEW
    # ==========================
    tabPanel(
      "Overview",
      
      fluidRow(
        
        # ---- Main Introduction Card ----
        column(
          12,
          
          card(
            style = "
          background-color:#FFFFFF;
          border-radius:18px;
          box-shadow:0 10px 30px rgba(0,0,0,0.06);
          padding:20px;",
            
            h3(
              "Renewable Energy Leaders vs Fossil Fuel–Dependent Countries",
              style = "color:#2563EB;font-weight:700;"
            ),
            
            p(
              "This dashboard examines how countries differ in their electricity transition pathways, 
           comparing renewable energy leaders with countries that remain heavily dependent on fossil fuels.",
              style = "color:#6B7280;font-size:16px;"
            ),
            
            p(
              "Using country-level data from Our World in Data (OWID), the dashboard tracks changes in electricity mix, 
           renewable adoption, fossil fuel dependence, carbon intensity, and economic capacity over time.",
              style = "color:#6B7280;font-size:16px;"
            )
          )
        )
      ),
      
      br(),
      
      fluidRow(
        
        # ---- What This Dashboard Shows ----
        column(
          6,
          
          card(
            style = "
          background-color:#ECFDF5;
          border-left:6px solid #047857;
          border-radius:16px;
          padding:18px;",
            
            h4(
              "What This Dashboard Shows",
              style = "color:#047857;font-weight:600;"
            ),
            
            tags$ul(
              tags$li("How renewable and fossil electricity shares evolve over time"),
              tags$li("Cross-country differences in electricity mix and carbon intensity"),
              tags$li("The composition of electricity generation by fuel type"),
              tags$li("Global geographic patterns in renewable leadership"),
              tags$li("The relationship between economic capacity and renewable adoption"),
              tags$li("How fast countries are transitioning over a 10-year period")
            )
          )
        ),
        
        # ---- How to Use the Dashboard ----
        column(
          6,
          
          card(
            style = "
          background-color:#FFFFFF;
          border-radius:16px;
          box-shadow:0 8px 24px rgba(0,0,0,0.05);
          padding:18px;",
            
            h4(
              "How to Use This Dashboard",
              style = "color:#2563EB;font-weight:600;"
            ),
            
            tags$ol(
              tags$li("Start with the Time Series panel to explore country-specific trends."),
              tags$li("Use Cross-Country Comparison to identify renewable leaders and laggards."),
              tags$li("Explore the Composition panel to understand electricity mix structure."),
              tags$li("Use the Map panel to visualise global patterns."),
              tags$li("Compare GDP and renewable share to assess economic capacity."),
              tags$li("End with Transition Speed to see how quickly systems are changing.")
            )
          )
        )
      ),
      
      br(),
      
      fluidRow(
        
        # ---- Data & Indicators ----
        column(
          12,
          
          card(
            style = "
          background-color:#FFFFFF;
          border-radius:16px;
          box-shadow:0 8px 24px rgba(0,0,0,0.05);
          padding:18px;",
            
            h4(
              "Data Source & Indicators",
              style = "color:#2563EB;font-weight:600;"
            ),
            
            p(
              "All indicators are sourced from Our World in Data (OWID). 
           The analysis uses electricity-specific indicators such as renewable electricity share, 
           fossil fuel share, carbon intensity, electricity generation by source, GDP, population, 
           and per-capita measures.",
              style = "color:#6B7280;"
            ),
            
            p(
              "The unit of analysis is the country, and all available countries in the dataset are included 
           wherever data is available.",
              style = "color:#6B7280;"
            )
          )
        )
      )
    ),
  
    # ==========================
    # PANEL 1: TIME SERIES
    # ==========================
    tabPanel("Time Series",
             
             sidebarLayout(
               sidebarPanel(
                 width = 3,
                 # Country selector
                 h5("Country & Indicator"),
                 selectInput(
                   "country_ts",
                   "Select Country",
                   choices  = sort(unique(OWID_data$country)),
                   selected = "India"
                 ),
                 
                 # Indicator selector
                 selectInput(
                   "indicator_ts",
                   "Select Indicator",
                   choices = c(
                     "Renewables Share (Electricity)" = "renewables_share_elec",
                     "Fossil Share (Electricity)"     = "fossil_share_elec",
                     "Carbon Intensity (Electricity)" = "carbon_intensity_elec"
                   )
                 ),
                 
                 hr(),
                 
                 h5("Time Controls"),
                 
                 sliderInput(
                   "year_ts",
                   "Year Range",
                   min   = min(OWID_data$year, na.rm = TRUE),
                   max   = max(OWID_data$year, na.rm = TRUE),
                   value = c(2000, 2022),
                   sep   = ""
                 ),
                 
                 # New options
                 checkboxInput("show_smooth", "Add Trend Smoother", TRUE),
                 checkboxInput("ref_2020", "Reference Line at 2020", FALSE)
               ),
               mainPanel(
                 
                 card(
                   card_header(style="color:#2563EB;font-weight:600;",
                               "Electricity Transition Pathway Over Time"),
                   plotOutput("ts_plot", height = "420px")
                 ),
                 
                 card(
                   style = "
              background-color:#ECFDF5;
              border-left:6px solid #047857;
              border-radius:16px;
              padding:14px;",
                   card_header(style="color:#047857;font-weight:600;",
                               "Key Insight"),
                   textOutput("ts_insight")
                 )
               )       
             )
    ),
    
    # ==========================
    # PANEL 2: CROSS COUNTRY
    # ==========================
    tabPanel(
      "Cross-Country Comparison",
      
      sidebarLayout(
        sidebarPanel(
          width = 3,
          
          selectInput(
            "year_cc",
            "Select Year",
            choices = sort(unique(OWID_data$year)),
            selected = 2019
          ),
          
          radioButtons(
            "simple_graph",
            "Choose Comparison",
            choices = c(
              "Renewables vs Fossil Share" = "rf",
              "Renewables vs Carbon Intensity" = "rc",
              "Top Countries by Renewable Share" = "bar"
            )
          )
        ),
        mainPanel(
          
          card(
            card_header(style="color:#2563EB;font-weight:600;",
                        "Cross-Country Comparison"),
            plotOutput("simple_cc_plot", height = "420px")
          ),
          
          card(
            style="background-color:#ECFDF5;border-left:6px solid #047857;",
            card_header(style="color:#047857;font-weight:600;",
                        "Interpretation"),
            textOutput("simple_cc_text")
          )
        )  
 
      )
    ),
  
    
    # ==========================
    # PANEL 3: MIX
    # ==========================
    tabPanel("Composition / Mix",
             
             sidebarLayout(
               
               sidebarPanel(
                 width = 3,
                 
                 selectInput(
                   "country_mix",
                   "Select Country for Mix",
                   choices = sort(unique(OWID_data$country)),
                   selected = "India"
                 ),
                 
                 selectInput(
                   "year_mix",
                   "Select Year",
                   choices = sort(unique(OWID_data$year)),
                   selected = 2019
                 )
               ),
               
               mainPanel(
                 
                 card(
                   card_header(
                     style = "color:#2563EB;font-weight:600;",
                     "Electricity Mix by Fuel Type"
                   ),
                   plotlyOutput("mix_plot_simple", height = "420px")
                 ),
                 
                 card(
                   style = "
          background-color:#ECFDF5;
          border-left:6px solid #047857;
          border-radius:16px;
          padding:14px;",
                   card_header(
                     style = "color:#047857;font-weight:600;",
                     "Interpretation"
                   ),
                   htmlOutput("mix_interpret")
                 )
               )
             )
    ),
    
    # ==========================
    # PANEL 4: MAP
    # ==========================
    tabPanel("Map Panel",
             
             sidebarLayout(
               
               sidebarPanel(
                 width = 3,
                 
                 selectInput(
                   "map_year",
                   "Select Year",
                   choices = sort(unique(OWID_data$year)),
                   selected = 2019
                 ),
                 
                 selectInput(
                   "map_indicator",
                   "Indicator",
                   choices = c(
                     "Renewable Share of Electricity (%)" = "renewables_share_elec",
                     "Fossil Fuel Share of Electricity (%)" = "fossil_share_elec"
                   ),
                   selected = "renewables_share_elec"
                 ),
                 helpText("Map continues the story of how electricity mix differs between Renewable Leaders and Fossil Fuel–Dependent countries.")
               ),
               
               mainPanel(
                 
                 card(
                   card_header(
                     style = "color:#2563EB;font-weight:600;",
                     "Global Electricity Mix"
                   ),
                   plotlyOutput("energy_map_simple", height = "460px")
                 ),
                 
                 card(
                   style = "
          background-color:#ECFDF5;
          border-left:6px solid #047857;
          border-radius:16px;
          padding:14px;",
                   card_header(
                     style = "color:#047857;font-weight:600;",
                     "How to Read This Map"
                   ),
                   htmlOutput("map_reading")
                 )
               )         
          )
    ),
    # ------------------------------------------
    # PANEL 5: Renewable Adoption vs GDP
    # Shows economic capacity vs renewable generation
    # ------------------------------------------
    tabPanel("GDP vs Renewable Share",
             
             sidebarLayout(
               
               sidebarPanel(
                 width = 3,
                 
                 # Users can pick several countries to compare economic angle
                 selectInput(
                   inputId = "year_gdp",
                   label   = "Select Year",
                   choices = sort(unique(OWID_data$year)),
                   selected = 2019
                 ),
                 
                 sliderInput(
                   inputId = "gdp_range",
                   label   = "GDP Range",
                   min = min(OWID_data$gdp, na.rm = TRUE),
                   max = max(OWID_data$gdp, na.rm = TRUE),
                   value = range(OWID_data$gdp, na.rm = TRUE)
                   )
                 ),
               mainPanel(
                 
                 card(
                   card_header(
                     style = "color:#2563EB;font-weight:600;",
                     "Economic Capacity vs Renewable Leadership"
                   ),
                   plotlyOutput("gdp_renew_scatter", height = "420px")
                 ),
                 
                 card(
                   style = "
          background-color:#ECFDF5;
          border-left:6px solid #047857;
          border-radius:16px;
          padding:14px;",
                   card_header(
                     style = "color:#047857;font-weight:600;",
                     "Interpretation"
                   ),
                   htmlOutput("gdp_renew_interpret")
                 )
               )
             )
    )
 )
)


# ==========================
# SERVER
# ==========================

server <- function(input, output, session) {
  energy_theme <- function() {
    theme_minimal(base_size = 14) +
      theme(
        plot.background  = element_rect(fill = BACKGROUND, color = NA),
        panel.background = element_rect(fill = CARD_WHITE),
        panel.grid.major = element_line(color = LIGHT_GREY),
        panel.grid.minor = element_blank(),
        axis.text        = element_text(color = NEUTRAL_GREY),
        axis.title       = element_text(color = "#111827", face = "bold"),
        plot.title       = element_text(color = PRIMARY_BLUE, face = "bold", size = 16),
        plot.subtitle    = element_text(color = NEUTRAL_GREY),
        legend.position  = "bottom",
        legend.title     = element_text(face = "bold")
      )
  }
  
  # -------- TIME SERIES --------
  ts_data <- reactive({
    
    req(input$country_ts, input$indicator_ts, input$year_ts)
    
    data <- OWID_data %>%
      filter(
        country == input$country_ts,
        year >= input$year_ts[1],
        year <= input$year_ts[2]
      ) %>%
      select(
        year,
        value = all_of(input$indicator_ts)
      ) %>%
      drop_na()
    
    validate(
      need(nrow(data) > 3, "Not enough observations for selected range.")
    )
    
    data
  })
  
  # ---------- Dynamic Labels ----------
  label_lookup <- reactive({
    named <- c(
      renewables_share_elec = "Renewable Share (%)",
      fossil_share_elec     = "Fossil Share (%)",
      carbon_intensity_elec = "Carbon Intensity (gCO2/kWh)"
    )
    named[input$indicator_ts]
  })
  
  # ---------- Render Plot ----------
  output$ts_plot <- renderPlot({
    
    req(ts_data())
    
    trend <- data.frame(
      year  = ts_data()$year,
      value = predict(loess(value ~ year, data = ts_data()))
    )
    
    ggplot() +
      
      # ----- OBSERVED PATHWAY (DATASET VALUES) -----
    geom_line(
      data = ts_data(),
      aes(x = year, y = value, color = "Observed Data"),
      linewidth = 1.4
    ) +
      
      geom_point(
        data = ts_data(),
        aes(x = year, y = value, color = "Observed Data"),
        size = 2.5
      ) +
      
      # ----- ESTIMATED TREND -----
    { if(input$show_smooth)
      geom_line(
        data = trend,
        aes(x = year, y = value, color = "Estimated Trend"),
        linewidth = 1.2
      )
    } +
      
      labs(
        title = paste("Electricity Mix Transition in", input$country_ts),
        
        subtitle = paste(
          "Indicator:",
          gsub("_"," ", input$indicator_ts),
          "| Emissions per unit explained via electricity mix"
        ),
        
        x = "Year",
        y = "Value"
      ) +
      
      scale_color_manual(
        name = "Legend",
        values = c(
          "Observed Data"   = "black",
          "Estimated Trend" = "blue"
        )
      ) +
      
      energy_theme()
    
  })
  # ---------- Insight Text ----------
  output$ts_insight <- renderText({
    
    d <- ts_data()
    
    paste0(
      "Average for period: ",
      round(mean(d$value), 2), ". ",
      "Latest year (", max(d$year), "): ",
      round(d$value[d$year == max(d$year)], 2), "."
    )
  })
  
  # ---------- Analytical Narrative ----------
  output$ts_insight <- renderText({
    
    d <- ts_data()
    
    
    if (input$indicator_ts == "renewables_share_elec") {
      ifelse(
        tail(d$value, 1) > 40,
        "This country belongs to the renewable energy leader group.",
        "This country follows a fossil-dependent electricity pathway."
      )
      
    } else if (input$indicator_ts == "fossil_share_elec") {
      
      "High fossil share indicates continued dependence on coal, oil, or gas."
      
    } else {
      
      "Carbon intensity reflects emissions per unit of electricity generated."
    }
  })
  
  
  # PANEL 2
  # -------- CROSS COUNTRY --------
  
  output$simple_cc_plot <- renderPlot({
    req(input$year_cc, input$simple_graph)
    
    data <- OWID_data %>% filter(year == input$year_cc)%>%
      drop_na(renewables_share_elec,
              fossil_share_elec,
              carbon_intensity_elec)
    
    # CASE 1: Renewables vs Fossil
    if (input$simple_graph == "rf") {
      ggplot(data, aes(renewables_share_elec, fossil_share_elec)) +
        geom_point(
          aes(color = "Country Positions (Observed)"),
          size = 3
        ) +
        geom_vline(
          aes(color = "50% Reference Threshold"),
          xintercept = 50,
          linetype = "dashed"
        ) +
        
        geom_hline(
          aes(color = "50% Reference Threshold"),
          yintercept = 50,
          linetype = "dashed"
        ) +
        
        labs(
          title = "Renewable Electricity Share vs Fossil Fuel Share",
          x = "Renewable Share of Electricity (%)",
          y = "Fossil Fuel Share of Electricity (%)"
        ) +
        scale_color_manual(
          name = "Legend",
          values = c(
            "Country Positions (Observed)" = "black",
            "50% Reference Threshold"       = "darkorange"
          )
        ) +
        energy_theme()
      
      # CASE 2: Renewables vs Carbon Intensity
    } else if (input$simple_graph == "rc") {
      
      ggplot(data,
             aes(x = renewables_share_elec,
                 y = carbon_intensity_elec)) +
        geom_point(
          aes(color = "Country Positions (Observed)"),
          size = 3
        ) +
        labs(
          title = "Renewable Share vs Carbon Intensity of Electricity",
          x = "Renewable Share of Electricity (%)",
          y = "Carbon Intensity (gCO2 per kWh)"
        ) +
        scale_color_manual(
          name = "Legend",
          values = c(
            "Country Positions (Observed)" = "black"
          )
        ) +
        energy_theme()
      
      # CASE 3: Top Renewable Leaders
    } else {
      
      top10 <- data %>%
        arrange(desc(renewables_share_elec)) %>%
        slice_head(n = 10)
      
      ggplot(top10,
             aes(reorder(country, renewables_share_elec),
                 renewables_share_elec)) +
        geom_col(
          aes(fill = "Renewable Share (Observed)"),
          alpha = 0.9
        ) +
        coord_flip() +
        labs(
          title = "Top 10 Renewable Electricity Leaders",
          subtitle = paste(
            "Identifying Clean-Energy Frontrunners | Year:",
            input$year_cc
          ),
          x = "Country",
          y = "Renewable Share (%)"
        ) +
        scale_fill_manual(
          name = "Legend",
          values = c(
            "Renewable Share (Observed)" = "black"
          )
        ) +
        energy_theme()
    }
  })
  
  output$simple_cc_text <- renderText({
    "Cross-country differences highlight clear contrasts between renewable leaders and fossil-dependent economies."
  })
  
  # ======================================================
  # PANEL 3: ELECTRICITY MIX
  # ======================================================
  
  
  mix_data_simple <- reactive({
    
    req(input$country_mix, input$year_mix)
    
    OWID_data %>%
      filter(
        country == input$country_mix,
        year == as.numeric(input$year_mix)
      ) %>%
      
      select(
        coal  = coal_share_elec,
        nuclear = nuclear_share_elec,
        oil   = oil_share_elec,
        solar = solar_share_elec,
        wind  = wind_share_elec,
        hydro = hydro_share_elec
      ) %>%
      
      pivot_longer(
        cols = everything(),
        names_to = "fuel",
        values_to = "share"
      ) %>%
      
      drop_na()
  })
  
  output$mix_plot_simple <- renderPlotly({
    
    req(mix_data_simple())
    
    p <- ggplot(mix_data_simple(), aes(fuel, share)) +
      geom_col(fill = PRIMARY_BLUE, alpha = 0.85) +
      labs(
        title = paste("Electricity Mix —", input$country_mix, "|", input$year_mix),
        x = "Fuel Type",
        y = "Share (%)"
      ) +
      energy_theme()
    
    ggplotly(p, tooltip = c("fuel","share"))
  })
  
  # -------- INTERPRETATION PANEL --------
  
  output$mix_interpret <- renderUI({
    
    d <- mix_data_simple()
    req(d)
    
    # Find largest fuel
    top_fuel <- d %>%
      arrange(desc(share)) %>%
      slice_head(n=1)
    
    HTML(
      paste0(
        "<h4><b>Reading</b></h4>",
        
        "<p>1. The bar shows <b>electricity mix</b>: how much coal, gas, oil, solar, wind, and hydro contribute.</p>",
        
        "<p>2. Largest component in ",
        input$year_mix,
        " is <b>", top_fuel$fuel,
        "</b> with ",
        round(top_fuel$share,1),
        "% share.</p>",
        
        "<p>3. This explains the previous scatter position — a high coal/gas share ",
        "keeps carbon intensity high and reflects emissions by fuel type.</p>"
      )
    )
  })
  
  output$mix_interpret <- renderUI({
    HTML("<p>The electricity mix reveals structural dependence on specific fuels.</p>")
  })
  
  
  # ======================================================
  # PANEL 4: MAP
  # ======================================================
  
  map_data <- reactive({
    req(input$map_year, input$map_indicator)
    
    OWID_data %>%
      filter(
        year == as.numeric(input$map_year)
      ) %>%
      drop_na(iso_code, all_of(input$map_indicator))
    
  })
  # -------- RENDER MAP --------
  output$energy_map_simple <- renderPlotly({
    
    req(map_data())
    
    # dynamic label
    sub_lab <- ifelse(
      input$map_indicator == "renewables_share_elec",
      "Renewable Share (%)",
      "Fossil Fuel Share (%)"
    )
    
    plot_ly(
      data = map_data(),
      
      locations = ~iso_code,
      locationmode = "ISO-3",
      
      z = ~.data[[input$map_indicator]],
      
      type = "choropleth",
      
      text = ~paste0(
        "<b>", country, "</b>",
        "<br>Year: ", input$map_year,
        "<br>", sub_lab, ": ",
        round(.data[[input$map_indicator]],1), "%"
      ),
      
      colorbar = list(title = sub_lab)
      
    ) %>%
      
      layout(
        
        title = list(
          text = "Global differences in electricity mix: Renewable Energy Leaders vs Fossil Fuel–Dependent Countries",
          x = 0.02,
          font = list(size = 18)
        ),
        
        annotations = list(
          list(
            x = 0.02,
            y = 1.02,
            xref = "paper",
            yref = "paper",
            text = paste(
              gsub("_", " ", input$map_indicator),
              "| Year:", input$map_year
            ),
            showarrow = FALSE,
            align = "left",
            font = list(size = 13, color = "gray40")
          )
        ),
        
        geo = list(
          showframe = FALSE,
          projection = list(type = "natural earth")
        )
      )
    
    
  })
  # -------- INTERPRETATION --------
  output$map_reading <- renderUI({
    
    d <- map_data()
    req(d)
    
    top_country <- d %>% arrange(desc(.data[[input$map_indicator]])) %>% slice_head(n=1)
    
    HTML(
      paste0(
        "<h4><b>What the Map Shows:</b></h4>",
        
        "<p>1. The map uses a <b>basic indicator</b> (renewables or fossil share) to display the electricity mix geographically.</p>",
        
        "<p>2. Highest value in this view is <b>",
        top_country$country,
        "</b>.</p>",
        
        "<p>3. Areas with high fossil share explain the clusters of Fossil Fuel–Dependent countries seen in the previous scatter, ",
        "where carbon intensity and emissions by fuel type were higher.</p>"
      )
    )
  })
  
  # ==========================================================
  # PANEL 5 – GDP vs Renewable Share with CLEAR LEGEND
  # ==========================================================
  gdp_renew_data <- reactive({
    
    req(input$year_gdp, input$gdp_range)
    
    OWID_data %>%
      
      # continue the story using same indicator renewables_share_elec
      filter(
        year == as.numeric(input$year_gdp),
        
        gdp >= input$gdp_range[1],
        gdp <= input$gdp_range[2]
      ) %>%
      
      drop_na(gdp, renewables_share_elec)
    
  })
  
  # ------------------------------------------------------
  # RENDER SIMPLE SCATTER WITH PLOTLY
  # ------------------------------------------------------
  
  output$gdp_renew_scatter <- renderPlotly({
    
    validate(
      need(nrow(gdp_renew_data()) > 0,
           "No observations in selected GDP / year range.")
    )
    # ----- STORY LOGIC -----
    # This scatter adds the ECONOMIC ANGLE to previous charts:
    # Earlier scatter showed Renewable Leaders vs Fossil Dependent using shares.
    # This one checks whether GDP and scale (population) explain that pattern.
    
    # Build ggplot object using only basic variables
    p <- ggplot(
      gdp_renew_data(),
      aes(gdp, renewables_share_elec, size = population)
    ) +
      # ----- OBSERVED COUNTRY POSITIONS -----
    geom_point(
      aes(color = "Observed Country Values",
          size  = population),
      alpha = 0.75
    ) +
      # ----- ESTIMATED ECONOMIC RELATIONSHIP -----
    geom_smooth(
      aes(color = "Estimated GDP–Renewable Path"),
      se = FALSE,
      linewidth = 1.3
    ) +
      
      labs(
        title = "Renewable Adoption vs Economic Capacity",
        subtitle = paste(
          "Nuance Panel: GDP Range & Population Scale | Year:",
          input$year_cc,
          "| Continues narrative of electricity mix and emissions by fuel type"
        ),
        x = "GDP (constant 2015 USD from OWID)",
        y = "Renewable Share of Electricity (%)"
      ) +
      # ----- MANUAL LEGEND DEFINITION -----
    scale_color_manual(
      name = "Legend — What Each Element Represents",
      values = c(
        "Observed Country Values"      = "black",
        "Estimated GDP–Renewable Path" = "blue"
      )
    ) +
      scale_size_continuous(
        name   = "Population (bubble size = scale effect)",
        labels = scales::comma,
        range  = c(2, 11)
      ) +
      energy_theme()
    
    ggplotly(p, tooltip = c("country", "gdp", "renewables_share_elec"))
  })
  
  # ------------------------------------------------------
  # INTERPRETATION NARRATIVE (Marks Booster)
  # ------------------------------------------------------
  
  output$gdp_renew_interpret <- renderUI({
    
    d <- gdp_renew_data()
    req(d)
    
    HTML(
      paste0(
        "<h4><b>What this map shows:</b></h4>",
        
        "<p>1. The map and scatter earlier compared Renewable Leaders with Fossil Fuel–Dependent countries using the same indicator.</p>",
        
        "<p>2. This panel explains that <b>high GDP countries can still remain fossil dependent</b> if electricity mix is dominated by coal, oil, or gas.</p>",
        
        "<p>3. Countries with moderate GDP but strong solar, wind, and hydro expansion ",
        "have emerged as <b>clean-energy frontrunners</b>, confirming differences in renewable generation and fossil fuel use.</p>"
      )
    )
    
  })
  
}

shinyApp(ui, server)

```

### Electricity Mix Transition Over Time

**(Time-Series Line Chart with Trend Line)**

This graph shows how the selected energy indicator evolves over time for the chosen country. It allows users to assess whether renewable growth is sustained and whether the transition away from fossil fuels is gradual or structurally significant.

### Renewable Electricity Share vs Fossil Fuel Share

**(Cross-Country Scatter Plot)**

This scatter plot compares countries for a selected year, highlighting the inverse relationship between renewable and fossil fuel shares of electricity. It clearly distinguishes renewable energy leaders from fossil fuel–dependent countries.

### Electricity Mix 

**(Bar Chart / Composition Plot)**

This bar chart presents the electricity mix by fuel type for the selected country and year. It helps identify the dominant energy sources and assess the balance between fossil fuels and renewables within the electricity system.

### Global Electricity Mix

**(Choropleth World Map)**

This map visualises cross-country variation in the selected electricity indicator for a given year. It reveals regional patterns in renewable adoption and fossil fuel dependence, providing geographic context to cross-country comparisons.

### Renewable Adoption vs Economic Capacity

**(Bubble Scatter Plot with Trend Line)**

This graph examines the relationship between renewable electricity share and economic capacity across countries. It shows that higher GDP does not necessarily correspond to higher renewable adoption, highlighting the role of policy and energy structure beyond income levels.

# Conclusion

The dashboard acts as a mediator that integrates all the four aspects -- renewables, traditional power, energy intensity, and emissions. The global energy transition being uneven is a major point of the analysis which has mixed time-series trends, crosscountry comparisons, and maps of energy and geography. The results indicate that the winner in the renewable energy race is not only the one who has the largest capacity but also the one who decreases the use of fossil fuels and the associated CO2 emissions the most. All in all, the dashboard is a user-friendly and systematically backed tool for revealing the differences among countries concerning their energy transition pathways and the areas where fossil fuels still hold the strongest grip.

Submitted by :

Anjali Arya

Mery Geordy

Riya Rao

Yeshashwini K.
