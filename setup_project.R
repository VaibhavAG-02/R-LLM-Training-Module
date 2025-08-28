# setup_project.R - Complete project setup script

#' Reproducible R + LLM Training Module Setup Script
#' This script sets up the complete training environment
#' Run this script after cloning the repository

# Clear environment
rm(list = ls())
cat("🚀 Starting R + LLM Training Module Setup...\n\n")

# Function to check if package is installed
check_package <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    return(FALSE)
  }
  return(TRUE)
}

# Function to install missing packages
install_if_missing <- function(packages) {
  missing_packages <- c()

  for (pkg in packages) {
    if (!check_package(pkg)) {
      missing_packages <- c(missing_packages, pkg)
    }
  }

  if (length(missing_packages) > 0) {
    cat("📦 Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
    install.packages(missing_packages, dependencies = TRUE)
  } else {
    cat("✅ All required packages are already installed\n")
  }
}

# Required packages
required_packages <- c(
  "tidyverse",    # Data manipulation and visualization
  "httr2",        # Modern HTTP client for API calls
  "jsonlite",     # JSON data processing
  "gt",           # Grammar of tables
  "quarto",       # Quarto integration
  "DT",           # Interactive data tables
  "usethis",      # R development tools
  "knitr",        # Dynamic report generation
  "rmarkdown",    # R Markdown documents
  "ggplot2",      # Advanced plotting
  "dplyr",        # Data manipulation
  "readr",        # Fast data reading
  "stringr"       # String manipulation
)

# Install missing packages
install_if_missing(required_packages)

# Load essential packages
suppressPackageStartupMessages({
  library(tidyverse)
  library(usethis)
  library(quarto)
})

cat("\n📋 Checking system requirements...\n")

# Check R version
r_version <- R.Version()$version.string
cat("R Version:", r_version, "\n")

if (getRversion() < "4.3.0") {
  warning("⚠️  R version 4.3.0 or higher recommended. Current version:", r_version)
} else {
  cat("✅ R version meets requirements\n")
}

# Check Quarto installation
quarto_version <- tryCatch({
  quarto::quarto_version()
}, error = function(e) {
  return("Not installed")
})

cat("Quarto Version:", quarto_version, "\n")

if (quarto_version == "Not installed") {
  cat("❌ Quarto not found. Please install from https://quarto.org/docs/get-started/\n")
} else {
  cat("✅ Quarto installation detected\n")
}

# Check if running in RStudio
if (Sys.getenv("RSTUDIO") == "1") {
  cat("✅ Running in RStudio environment\n")
} else {
  cat("ℹ️  Not running in RStudio (recommended but not required)\n")
}

cat("\n🔑 Checking API configuration...\n")

# Check API key configuration
api_key <- Sys.getenv("OPENAI_API_KEY")
if (api_key == "") {
  cat("❌ OpenAI API key not found\n")
  cat("📝 To configure your API key:\n")
  cat("   1. Run: usethis::edit_r_environ()\n")
  cat("   2. Add: OPENAI_API_KEY=your-actual-api-key-here\n")
  cat("   3. Restart R session\n")
  cat("   4. Run this setup script again\n\n")
} else {
  cat("✅ OpenAI API key found (", nchar(api_key), " characters)\n")

  # Test API connection
  cat("🔍 Testing API connection...\n")
  tryCatch({
    source("api_helpers.R")
    if (validate_api_setup()) {
      cat("✅ API connection successful!\n")
    }
  }, error = function(e) {
    cat("❌ API test failed:", e$message, "\n")
    cat("💡 Make sure your API key is valid and you have credits\n")
  })
}

cat("\n📁 Checking project files...\n")

# Required files
required_files <- c(
  "api_helpers.R",
  "llm_training_module.qmd", 
  "sample_abstracts.csv",
  "research_study_data.csv",
  "social_media_analysis.csv",
  "README.md",
  "setup_instructions.md"
)

missing_files <- c()
for (file in required_files) {
  if (file.exists(file)) {
    cat("✅", file, "\n")
  } else {
    cat("❌", file, "\n")
    missing_files <- c(missing_files, file)
  }
}

if (length(missing_files) > 0) {
  cat("\n⚠️  Missing files detected. Please ensure all project files are present.\n")
} else {
  cat("\n✅ All required files present\n")
}

cat("\n📊 Loading and validating data files...\n")

# Test data loading
tryCatch({
  abstracts <- read_csv("sample_abstracts.csv", show_col_types = FALSE)
  cat("✅ Research abstracts loaded:", nrow(abstracts), "records\n")
}, error = function(e) {
  cat("❌ Failed to load research abstracts:", e$message, "\n")
})

tryCatch({
  research_data <- read_csv("research_study_data.csv", show_col_types = FALSE)
  cat("✅ Research study data loaded:", nrow(research_data), "records\n")
}, error = function(e) {
  cat("❌ Failed to load research study data:", e$message, "\n")
})

tryCatch({
  social_data <- read_csv("social_media_analysis.csv", show_col_types = FALSE)
  cat("✅ Social media data loaded:", nrow(social_data), "records\n")
}, error = function(e) {
  cat("❌ Failed to load social media data:", e$message, "\n")
})

cat("\n🔧 Creating project configuration...\n")

# Create .gitignore if it doesn't exist
if (!file.exists(".gitignore")) {
  gitignore_content <- "
# R
.Rhistory
.Rdata
.RData
.Ruserdata
*.Rproj

# Quarto
/.quarto/
_site/
outputs/

# Environment variables (IMPORTANT!)
.Renviron
.env

# API keys and secrets  
*.key
secrets/

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Temporary files
*~
.#*
\#*\#
"
  writeLines(gitignore_content, ".gitignore")
  cat("✅ Created .gitignore file\n")
} else {
  cat("✅ .gitignore already exists\n")
}

# Create _quarto.yml if it doesn't exist
if (!file.exists("_quarto.yml")) {
  quarto_config <- "
project:
  title: \"Reproducible R + LLM Training Module\"
  output-dir: outputs

format:
  html:
    theme: cosmo
    toc: true
    toc-depth: 3
    code-fold: show
    code-tools: true
    highlight-style: github
  pdf:
    toc: true
    number-sections: true
    highlight-style: github

execute:
  echo: true
  warning: false
  message: false
  cache: true
"
  writeLines(quarto_config, "_quarto.yml")
  cat("✅ Created Quarto configuration\n")
} else {
  cat("✅ Quarto configuration already exists\n")
}

# Create outputs directory
if (!dir.exists("outputs")) {
  dir.create("outputs")
  cat("✅ Created outputs directory\n")
} else {
  cat("✅ Outputs directory already exists\n")
}

cat("\n🎯 Setup Summary\n")
cat("================\n")

setup_complete <- TRUE

# Final checks
if (length(missing_files) > 0) {
  cat("❌ Missing required files\n")
  setup_complete <- FALSE
}

if (api_key == "") {
  cat("⚠️  API key not configured\n")
  setup_complete <- FALSE
} else {
  cat("✅ API key configured\n")
}

if (quarto_version == "Not installed") {
  cat("❌ Quarto not installed\n") 
  setup_complete <- FALSE
} else {
  cat("✅ Quarto ready\n")
}

cat("✅ Required packages installed\n")
cat("✅ Project structure ready\n")

if (setup_complete) {
  cat("\n🎉 Setup completed successfully!\n")
  cat("\n📚 Next steps:\n")
  cat("   1. Open 'llm_training_module.qmd' in RStudio\n")
  cat("   2. Click 'Render' to start the training\n")
  cat("   3. Follow the interactive modules\n")
  cat("\n💡 Need help? Check 'setup_instructions.md' for detailed guidance\n")
} else {
  cat("\n⚠️  Setup incomplete. Please address the issues above.\n")
}

cat("\n" + "="*50 + "\n")
cat("Setup script completed at:", Sys.time(), "\n")
