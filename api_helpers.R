# api_helpers.R - Helper functions for LLM API integration

# Load required libraries
suppressPackageStartupMessages({
  library(httr2)
  library(jsonlite)
  library(dplyr)
  library(purrr)
})

#' Setup OpenAI API Configuration
#' 
#' Creates a base request object for OpenAI API calls
#' @param api_key Your OpenAI API key (default: reads from environment)
#' @param base_url Base URL for OpenAI API
#' @return An httr2 request object
setup_openai_api <- function(api_key = Sys.getenv("OPENAI_API_KEY"),
                             base_url = "https://api.openai.com/v1") {
  if (api_key == "") {
    stop("OpenAI API key not found. Please set OPENAI_API_KEY environment variable.")
  }

  request(base_url) |>
    req_headers(
      `Authorization` = paste("Bearer", api_key),
      `Content-Type` = "application/json"
    )
}

#' Call OpenAI Chat Completion API
#' 
#' Makes a request to OpenAI's chat completion endpoint
#' @param prompt The text prompt to send
#' @param model The model to use (default: gpt-3.5-turbo)
#' @param max_tokens Maximum tokens in response
#' @param temperature Creativity parameter (0-1)
#' @return The AI response text
call_openai <- function(prompt, 
                        model = "gpt-3.5-turbo",
                        max_tokens = 1000,
                        temperature = 0.7) {

  base_req <- setup_openai_api()

  body <- list(
    model = model,
    messages = list(
      list(role = "user", content = prompt)
    ),
    max_tokens = max_tokens,
    temperature = temperature
  )

  response <- base_req |>
    req_url_path_append("chat/completions") |>
    req_body_json(body) |>
    req_perform()

  # Extract response content
  resp_body <- response |> resp_body_json()
  return(resp_body$choices[[1]]$message$content)
}

#' Summarize text using LLM
#' 
#' @param text Text to summarize
#' @param max_length Maximum length of summary
#' @return Summary text
summarize_text <- function(text, max_length = 200) {
  prompt <- paste0(
    "Please provide a concise summary of the following text in approximately ",
    max_length, " words:\n\n", text
  )

  call_openai(prompt, max_tokens = max_length * 2)
}

#' Extract topics from text using LLM
#' 
#' @param text Text to analyze
#' @param num_topics Number of topics to extract
#' @return Character vector of topics
extract_topics <- function(text, num_topics = 5) {
  prompt <- paste0(
    "Extract the top ", num_topics, " main topics or themes from the following text. ",
    "Return only the topics as a comma-separated list:\n\n", text
  )

  response <- call_openai(prompt, max_tokens = 200, temperature = 0.3)
  topics <- strsplit(response, ",")[[1]]
  return(trimws(topics))
}

#' Generate documentation for R code using LLM
#' 
#' @param code R code as character string
#' @return Documented code with roxygen2 comments
document_code <- function(code) {
  prompt <- paste0(
    "Add proper roxygen2 documentation to this R function. ",
    "Include @title, @description, @param, @return, and @examples sections:\n\n",
    code
  )

  call_openai(prompt, max_tokens = 800, temperature = 0.3)
}

#' Batch process multiple texts
#' 
#' @param texts Character vector of texts to process
#' @param process_fn Function to apply to each text
#' @param delay Delay between API calls (seconds)
#' @return List of processed results
batch_process <- function(texts, process_fn, delay = 1) {
  results <- vector("list", length(texts))

  for (i in seq_along(texts)) {
    cat("Processing item", i, "of", length(texts), "\n")
    results[[i]] <- process_fn(texts[i])

    # Add delay to respect rate limits
    if (i < length(texts)) {
      Sys.sleep(delay)
    }
  }

  return(results)
}

#' Safe API call wrapper with error handling
#' 
#' @param fn Function to execute
#' @param ... Arguments to pass to function
#' @param max_retries Maximum number of retries
#' @return Function result or error message
safe_api_call <- function(fn, ..., max_retries = 3) {
  for (attempt in 1:max_retries) {
    tryCatch({
      return(fn(...))
    }, error = function(e) {
      if (attempt == max_retries) {
        return(paste("Error after", max_retries, "attempts:", e$message))
      }
      cat("Attempt", attempt, "failed, retrying...\n")
      Sys.sleep(2^attempt)  # Exponential backoff
    })
  }
}

#' Validate API key setup
#' 
#' @return Logical indicating if API is properly configured
validate_api_setup <- function() {
  tryCatch({
    test_response <- call_openai("Hello", max_tokens = 5)
    cat("✅ API setup successful!\n")
    cat("Test response:", test_response, "\n")
    return(TRUE)
  }, error = function(e) {
    cat("❌ API setup failed:", e$message, "\n")
    return(FALSE)
  })
}
