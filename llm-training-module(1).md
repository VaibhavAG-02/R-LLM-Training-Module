# Reproducible R + LLM Training Module

---
title: "Reproducible R + LLM Training Module"
author: "Your Name"
date: "`r Sys.Date()`"
format:
  html:
    toc: true
    toc-depth: 3
    code-fold: show
    code-tools: true
    theme: cosmo
    highlight-style: github
  pdf:
    toc: true
    number-sections: true
    highlight-style: github
execute:
  echo: true
  warning: false
  message: false
---

```{r setup, include=FALSE}
# Load required packages
suppressPackageStartupMessages({
  library(httr2)
  library(jsonlite)
  library(tidyverse)
  library(gt)
  library(quarto)
  library(DT)
})

# Source our helper functions
source("api_helpers.R")

# Set global chunk options
knitr::opts_chunk$set(
  echo = TRUE,
  warning = FALSE,
  message = FALSE,
  fig.width = 8,
  fig.height = 6
)
```

## Introduction

This training module demonstrates how to integrate Large Language Models (LLMs) with R for reproducible research workflows. You'll learn to:

1. **Set up secure API access** to LLM services
2. **Build helper functions** for common LLM tasks
3. **Implement text summarization** workflows
4. **Perform topic modeling** with LLM assistance
5. **Auto-generate documentation** for R code
6. **Create reproducible reports** with Quarto

## Prerequisites

Ensure you have the following installed:

- R (≥ 4.3.0)
- RStudio (latest version)
- Quarto (≥ 1.5.0)
- Required R packages: `tidyverse`, `httr2`, `jsonlite`, `gt`, `quarto`
- OpenAI API key (set as environment variable)

## Module 1: Environment Setup

### 1.1 Package Installation

```{r install-packages, eval=FALSE}
# Install required packages if not already installed
required_packages <- c("tidyverse", "httr2", "jsonlite", "gt", "quarto", 
                      "DT", "knitr", "rmarkdown")

new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)
```

### 1.2 API Key Configuration

**Step 1:** Get your OpenAI API key from [OpenAI's platform](https://platform.openai.com/api-keys)

**Step 2:** Set up your `.Renviron` file:

```{r setup-env, eval=FALSE}
# Open .Renviron file for editing
usethis::edit_r_environ()

# Add this line to your .Renviron file:
# OPENAI_API_KEY=your-actual-api-key-here

# Restart R session after saving
.rs.restartR()
```

**Step 3:** Verify your setup:

```{r verify-setup}
# Check if API key is set
api_key_set <- Sys.getenv("OPENAI_API_KEY") != ""
cat("API Key configured:", ifelse(api_key_set, "✅ Yes", "❌ No"), "\n")

if (api_key_set) {
  cat("API key length:", nchar(Sys.getenv("OPENAI_API_KEY")), "characters\n")
} else {
  cat("Please configure your OPENAI_API_KEY environment variable.\n")
}
```

### 1.3 Load Helper Functions

```{r load-helpers}
# Create and source our API helper functions
source("api_helpers.R")

# Validate API setup (uncomment to test)
# validate_api_setup()
```

## Module 2: Text Summarization with LLMs

### 2.1 Basic Text Summarization

```{r text-summarization}
# Sample research abstract for summarization
research_text <- "
Machine learning has revolutionized many fields, including natural language processing, 
computer vision, and bioinformatics. Recent advances in deep learning, particularly 
transformer architectures, have led to significant breakthroughs in language understanding 
and generation. Large language models like GPT and BERT have demonstrated remarkable 
capabilities in various NLP tasks, including text classification, sentiment analysis, 
question answering, and text generation. These models are trained on vast amounts of 
textual data and can capture complex linguistic patterns and semantic relationships. 
However, challenges remain in terms of computational efficiency, interpretability, 
and bias mitigation. Future research directions include developing more efficient 
architectures, improving model interpretability, and ensuring fair and ethical AI systems.
"

# Demonstrate text summarization
cat("Original text length:", nchar(research_text), "characters\n")
cat("Word count:", length(strsplit(research_text, "\\s+")[[1]]), "words\n\n")

# Create a mock summary for demonstration (replace with actual API call)
mock_summary <- "Machine learning, especially transformer models like GPT and BERT, has revolutionized NLP with breakthrough capabilities in text processing. While these large language models excel at various tasks, challenges in efficiency, interpretability, and bias remain key research priorities."

cat("Summary:\n")
cat(mock_summary, "\n\n")
cat("Summary length:", nchar(mock_summary), "characters\n")
cat("Compression ratio:", round(nchar(mock_summary)/nchar(research_text), 2), "\n")
```

### 2.2 Batch Text Processing

```{r batch-processing}
# Multiple research abstracts for batch processing
research_abstracts <- c(
  "Climate change represents one of the most pressing challenges of our time...",
  "Quantum computing promises to revolutionize computation by leveraging quantum mechanics...",
  "CRISPR-Cas9 gene editing technology has transformed biological research...",
  "Renewable energy sources are becoming increasingly important for sustainable development..."
)

# Create a data frame to organize our results
batch_results <- data.frame(
  id = 1:length(research_abstracts),
  original_length = sapply(research_abstracts, nchar),
  word_count = sapply(research_abstracts, function(x) length(strsplit(x, "\\s+")[[1]])),
  topic = c("Climate Science", "Quantum Computing", "Biotechnology", "Renewable Energy"),
  stringsAsFactors = FALSE
)

# Display results in a nice table
batch_results %>%
  gt() %>%
  tab_header(
    title = "Research Abstract Analysis",
    subtitle = "Batch processing results for multiple texts"
  ) %>%
  fmt_number(
    columns = c(original_length, word_count),
    decimals = 0
  ) %>%
  cols_label(
    id = "ID",
    original_length = "Characters",
    word_count = "Words",
    topic = "Research Topic"
  )
```

## Module 3: Topic Modeling with LLM Assistance

### 3.1 Topic Extraction

```{r topic-extraction}
# Sample text for topic modeling
sample_data <- "
The integration of artificial intelligence in healthcare has shown tremendous promise. 
Electronic health records are being leveraged to predict patient outcomes using machine learning algorithms. 
Natural language processing helps extract insights from clinical notes. 
Computer vision assists in medical imaging analysis for early disease detection. 
Telemedicine platforms have expanded access to healthcare services, especially in rural areas. 
Privacy and security concerns remain paramount when handling sensitive patient data. 
Regulatory frameworks are evolving to ensure safe AI deployment in clinical settings.
"

# Mock topic extraction (replace with actual LLM call)
extracted_topics <- c(
  "Artificial Intelligence in Healthcare",
  "Electronic Health Records and Predictive Analytics", 
  "Natural Language Processing for Clinical Data",
  "Computer Vision in Medical Imaging",
  "Telemedicine and Healthcare Access",
  "Data Privacy and Security",
  "Healthcare AI Regulation"
)

# Create topic analysis visualization
topic_df <- data.frame(
  topic = extracted_topics,
  relevance_score = c(0.95, 0.87, 0.82, 0.79, 0.75, 0.71, 0.68),
  category = c("Core AI", "Data Analytics", "NLP", "Computer Vision", 
               "Digital Health", "Security", "Regulation")
)

# Visualize topics
topic_df %>%
  ggplot(aes(x = reorder(topic, relevance_score), y = relevance_score, fill = category)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Extracted Topics by Relevance Score",
    subtitle = "LLM-assisted topic modeling results",
    x = "Topics",
    y = "Relevance Score",
    fill = "Category"
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_text(size = 10),
    plot.title = element_text(size = 14, face = "bold")
  ) +
  scale_fill_viridis_d()
```

### 3.2 Topic Trend Analysis

```{r topic-trends}
# Simulate topic evolution over time
set.seed(42)
time_periods <- 2015:2024
topics <- c("Machine Learning", "Deep Learning", "NLP", "Computer Vision", "Ethics in AI")

trend_data <- expand.grid(
  year = time_periods,
  topic = topics,
  stringsAsFactors = FALSE
) %>%
  mutate(
    mentions = case_when(
      topic == "Machine Learning" ~ 100 + year - 2015 + rnorm(n(), 0, 5),
      topic == "Deep Learning" ~ 20 + (year - 2015)^1.5 + rnorm(n(), 0, 3),
      topic == "NLP" ~ 30 + (year - 2015)^1.2 + rnorm(n(), 0, 4),
      topic == "Computer Vision" ~ 40 + (year - 2015) * 2 + rnorm(n(), 0, 3),
      topic == "Ethics in AI" ~ ifelse(year < 2018, 5, 10 + (year - 2018)^2) + rnorm(n(), 0, 2)
    )
  )

# Visualize topic trends
trend_data %>%
  ggplot(aes(x = year, y = mentions, color = topic)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  labs(
    title = "AI Topic Trends Over Time",
    subtitle = "Simulated research publication mentions",
    x = "Year",
    y = "Number of Mentions",
    color = "Research Topic"
  ) +
  theme_minimal() +
  scale_color_viridis_d() +
  facet_wrap(~topic, scales = "free_y", ncol = 2)
```

## Module 4: Auto-Documentation of R Code

### 4.1 Function Documentation Generator

```{r code-documentation}
# Example R function that needs documentation
sample_function <- "
calculate_statistics <- function(data, column, na_remove = TRUE) {
  if (na_remove) {
    clean_data <- data[!is.na(data[[column]]), ]
  } else {
    clean_data <- data
  }
  
  stats <- list(
    mean = mean(clean_data[[column]], na.rm = na_remove),
    median = median(clean_data[[column]], na.rm = na_remove),
    sd = sd(clean_data[[column]], na.rm = na_remove),
    min = min(clean_data[[column]], na.rm = na_remove),
    max = max(clean_data[[column]], na.rm = na_remove)
  )
  
  return(stats)
}
"

# Mock documented version (in practice, would use LLM)
documented_function <- "
#' Calculate Summary Statistics
#' 
#' Calculates basic descriptive statistics for a numeric column in a data frame.
#' This function computes mean, median, standard deviation, minimum, and maximum values.
#' 
#' @param data A data frame containing the data to analyze
#' @param column Character string specifying the column name to analyze
#' @param na_remove Logical value indicating whether to remove NA values (default: TRUE)
#' 
#' @return A named list containing summary statistics:
#'   \\item{mean}{The arithmetic mean of the column}
#'   \\item{median}{The median value of the column}
#'   \\item{sd}{The standard deviation of the column}
#'   \\item{min}{The minimum value in the column}
#'   \\item{max}{The maximum value in the column}
#' 
#' @examples
#' # Example usage with built-in mtcars dataset
#' stats <- calculate_statistics(mtcars, 'mpg')
#' print(stats)
#' 
#' # Example with missing values
#' test_data <- data.frame(values = c(1, 2, NA, 4, 5))
#' stats_with_na <- calculate_statistics(test_data, 'values', na_remove = TRUE)
#' 
#' @export
calculate_statistics <- function(data, column, na_remove = TRUE) {
  if (na_remove) {
    clean_data <- data[!is.na(data[[column]]), ]
  } else {
    clean_data <- data
  }
  
  stats <- list(
    mean = mean(clean_data[[column]], na.rm = na_remove),
    median = median(clean_data[[column]], na.rm = na_remove),
    sd = sd(clean_data[[column]], na.rm = na_remove),
    min = min(clean_data[[column]], na.rm = na_remove),
    max = max(clean_data[[column]], na.rm = na_remove)
  )
  
  return(stats)
}
"

cat("Generated roxygen2 documentation for R function:\n")
cat("================================================\n")
cat(documented_function)
```

### 4.2 Documentation Quality Assessment

```{r doc-assessment}
# Assess documentation completeness
doc_elements <- c(
  "@title" = "✅ Present",
  "@description" = "✅ Present", 
  "@param (data)" = "✅ Present",
  "@param (column)" = "✅ Present",
  "@param (na_remove)" = "✅ Present",
  "@return" = "✅ Present",
  "@examples" = "✅ Present",
  "@export" = "✅ Present"
)

# Create documentation checklist
doc_checklist <- data.frame(
  element = names(doc_elements),
  status = as.character(doc_elements),
  stringsAsFactors = FALSE
) %>%
  mutate(
    complete = ifelse(grepl("✅", status), TRUE, FALSE),
    description = case_when(
      element == "@title" ~ "Function title provided",
      element == "@description" ~ "Detailed function description",
      element == "@param (data)" ~ "Data parameter documented",
      element == "@param (column)" ~ "Column parameter documented", 
      element == "@param (na_remove)" ~ "na_remove parameter documented",
      element == "@return" ~ "Return value structure described",
      element == "@examples" ~ "Usage examples provided",
      element == "@export" ~ "Export directive included"
    )
  )

# Display checklist
doc_checklist %>%
  select(-complete) %>%
  gt() %>%
  tab_header(
    title = "Documentation Completeness Checklist",
    subtitle = "Roxygen2 documentation elements assessment"
  ) %>%
  cols_label(
    element = "Documentation Element",
    status = "Status",
    description = "Description"
  ) %>%
  text_transform(
    locations = cells_body(columns = status),
    fn = function(x) {
      ifelse(grepl("✅", x), 
             paste0("<span style='color: green; font-weight: bold;'>", x, "</span>"),
             paste0("<span style='color: red; font-weight: bold;'>", x, "</span>"))
    }
  )
```

## Module 5: Reproducible Workflow Example

### 5.1 Complete Analysis Pipeline

```{r complete-pipeline}
# Simulate a complete data analysis workflow
set.seed(123)

# Generate sample research data
research_data <- data.frame(
  participant_id = 1:100,
  treatment_group = sample(c("Control", "Treatment A", "Treatment B"), 100, replace = TRUE),
  pre_score = rnorm(100, 50, 10),
  post_score = rnorm(100, 55, 12),
  age = sample(18:65, 100, replace = TRUE),
  gender = sample(c("Male", "Female", "Other"), 100, replace = TRUE, prob = c(0.45, 0.5, 0.05))
) %>%
  mutate(
    improvement = post_score - pre_score,
    age_group = cut(age, breaks = c(0, 30, 50, 100), labels = c("Young", "Middle", "Older"))
  )

# Display sample data
research_data %>%
  head(10) %>%
  gt() %>%
  tab_header(
    title = "Sample Research Dataset",
    subtitle = "First 10 participants"
  ) %>%
  fmt_number(
    columns = c(pre_score, post_score, improvement),
    decimals = 1
  )
```

### 5.2 Automated Analysis Summary

```{r analysis-summary}
# Generate analysis summary
analysis_summary <- research_data %>%
  group_by(treatment_group) %>%
  summarise(
    n = n(),
    mean_improvement = mean(improvement),
    sd_improvement = sd(improvement),
    median_improvement = median(improvement),
    .groups = 'drop'
  ) %>%
  mutate(
    effect_size = (mean_improvement - mean(research_data$improvement)) / sd(research_data$improvement),
    significance = ifelse(abs(effect_size) > 0.3, "Potentially Significant", "Not Significant")
  )

# Display results
analysis_summary %>%
  gt() %>%
  tab_header(
    title = "Treatment Group Analysis Results",
    subtitle = "Statistical summary by intervention group"
  ) %>%
  fmt_number(
    columns = c(mean_improvement, sd_improvement, median_improvement, effect_size),
    decimals = 2
  ) %>%
  cols_label(
    treatment_group = "Treatment Group",
    n = "N",
    mean_improvement = "Mean Δ",
    sd_improvement = "SD Δ", 
    median_improvement = "Median Δ",
    effect_size = "Effect Size",
    significance = "Significance"
  )
```

### 5.3 Automated Insights Generation

```{r auto-insights}
# Mock LLM-generated insights (replace with actual API call)
research_insights <- list(
  key_findings = c(
    "Treatment B showed the highest mean improvement (2.1 points)",
    "Control group had the most consistent results (lowest SD)",
    "Age group analysis reveals differential treatment effects"
  ),
  recommendations = c(
    "Consider larger sample size for Treatment B validation",
    "Investigate age-related treatment interactions",
    "Monitor long-term treatment sustainability"
  ),
  statistical_notes = c(
    "Effect sizes suggest clinically meaningful differences",
    "Further analysis needed to establish statistical significance",
    "Consider controlling for baseline differences"
  )
)

# Create insights summary
insights_df <- data.frame(
  category = rep(names(research_insights), sapply(research_insights, length)),
  insight = unlist(research_insights),
  row.names = NULL
)

insights_df %>%
  gt(groupname_col = "category") %>%
  tab_header(
    title = "Automated Research Insights",
    subtitle = "LLM-generated analysis interpretation"
  ) %>%
  cols_label(
    insight = "Generated Insight"
  ) %>%
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_row_groups()
  )
```

## Module 6: Workshop Exercises

### Exercise 1: Basic API Integration

**Task:** Set up your API connection and test basic functionality

1. Configure your `.Renviron` file with your API key
2. Test the connection using `validate_api_setup()`
3. Try summarizing a piece of text from your own research

```{r exercise1-template, eval=FALSE}
# Your code here
# 1. Check API key configuration
api_configured <- Sys.getenv("OPENAI_API_KEY") != ""
print(paste("API configured:", api_configured))

# 2. Test connection (uncomment to run)
# validate_api_setup()

# 3. Summarize your own text
my_text <- "Insert your research text here..."
# my_summary <- summarize_text(my_text)
# print(my_summary)
```

### Exercise 2: Topic Analysis Workflow

**Task:** Analyze topics from a collection of research abstracts

1. Collect 3-5 research abstracts from your field
2. Extract topics using the LLM helper functions
3. Create a visualization of the topic distribution

```{r exercise2-template, eval=FALSE}
# Your code here
my_abstracts <- c(
  "Abstract 1 text...",
  "Abstract 2 text...",
  "Abstract 3 text..."
)

# Extract topics for each abstract
# topic_results <- map(my_abstracts, extract_topics)

# Create visualization
# topic_viz_data <- create_topic_visualization_data(topic_results)
# create_topic_plot(topic_viz_data)
```

### Exercise 3: Documentation Enhancement

**Task:** Enhance documentation for one of your R functions

1. Choose an existing R function from your work
2. Use the LLM to generate proper roxygen2 documentation
3. Compare the original and enhanced versions

```{r exercise3-template, eval=FALSE}
# Your code here
my_function <- "
# Insert your R function here
your_function <- function(param1, param2) {
  # function body
  return(result)
}
"

# Generate documentation
# documented_version <- document_code(my_function)
# cat(documented_version)
```

## Module 7: Best Practices and Tips

### 7.1 API Usage Guidelines

```{r best-practices}
best_practices <- data.frame(
  category = c("Security", "Security", "Efficiency", "Efficiency", "Quality", "Quality"),
  practice = c(
    "Store API keys in environment variables",
    "Never commit API keys to version control",
    "Implement rate limiting and retry logic",
    "Use batch processing for multiple requests",
    "Validate and clean LLM outputs",
    "Provide clear, specific prompts"
  ),
  importance = c("Critical", "Critical", "High", "Medium", "High", "Medium")
)

best_practices %>%
  gt(groupname_col = "category") %>%
  tab_header(
    title = "LLM Integration Best Practices",
    subtitle = "Guidelines for safe and effective usage"
  ) %>%
  cols_label(
    practice = "Best Practice",
    importance = "Importance Level"
  ) %>%
  text_transform(
    locations = cells_body(columns = importance),
    fn = function(x) {
      case_when(
        x == "Critical" ~ paste0("<span style='color: red; font-weight: bold;'>", x, "</span>"),
        x == "High" ~ paste0("<span style='color: orange; font-weight: bold;'>", x, "</span>"),
        TRUE ~ paste0("<span style='color: green;'>", x, "</span>")
      )
    }
  )
```

### 7.2 Troubleshooting Guide

```{r troubleshooting}
troubleshooting <- data.frame(
  issue = c(
    "API key not found",
    "Rate limit exceeded", 
    "Empty or error response",
    "Inconsistent output format",
    "High API costs"
  ),
  solution = c(
    "Check .Renviron file and restart R",
    "Implement delays and retry logic",
    "Add error handling and validation",
    "Use more specific prompts",
    "Optimize prompts and use caching"
  ),
  prevention = c(
    "Use usethis::edit_r_environ()",
    "Monitor usage and set limits",
    "Always use try-catch blocks",
    "Test prompts extensively",
    "Budget and monitor API usage"
  )
)

troubleshooting %>%
  gt() %>%
  tab_header(
    title = "Common Issues and Solutions",
    subtitle = "Troubleshooting guide for LLM integration"
  ) %>%
  cols_label(
    issue = "Common Issue",
    solution = "Solution",
    prevention = "Prevention"
  )
```

## Conclusion

This training module has covered:

1. ✅ **Environment Setup** - API keys and package installation
2. ✅ **Helper Functions** - Reusable R functions for LLM integration  
3. ✅ **Text Summarization** - Automated content summarization workflows
4. ✅ **Topic Modeling** - LLM-assisted topic extraction and analysis
5. ✅ **Code Documentation** - Automatic roxygen2 documentation generation
6. ✅ **Reproducible Workflows** - Complete analysis pipelines with LLMs
7. ✅ **Best Practices** - Security, efficiency, and quality guidelines

### Next Steps

1. **Practice** the exercises with your own data and use cases
2. **Explore** advanced LLM capabilities (embeddings, fine-tuning)
3. **Integrate** these tools into your regular research workflows
4. **Share** your experiences and learn from the community

### Resources for Further Learning

- [Quarto Documentation](https://quarto.org/)
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [httr2 Package Guide](https://httr2.r-lib.org/)
- [Reproducible Research with R](https://r4ds.hadley.nz/)

---

**Session Information**

```{r session-info}
sessionInfo()
```