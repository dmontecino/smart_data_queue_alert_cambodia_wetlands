######################### 
# GET DATA IN THE QUEUE #
#########################

library(httr)
library(jsonlite)
library(dplyr)
library(janitor)
library(purrr)
library(lubridate)
library(stringr)
library(telegram.bot)

# GitHub Actions runs in the project root by default, no need for setwd()

# Open current available data in the queue
response <- GET(
  url = Sys.getenv("API_URL"),  # Changed: Now uses GitHub Secret
  config = authenticate(
    user = Sys.getenv("HEALTH_SMART_CONNECT_USER_NAME"),      # Changed: Now uses GitHub Secret
    password = Sys.getenv("HEALTH_SMART_CONNECT_PASSWORD")   # Changed: Now uses GitHub Secret
  ), 
  timeout(30)
)

if (status_code(response) == 200) {
  data <- content(response, as = "parsed")
  current.data.queue <- map(data, as_tibble) |> bind_rows()
}

current.data.queue <- current.data.queue |> 
  select(name, conservationArea)

# Open previous data in the queue
# Check if file exists first (won't exist on first run)
if (file.exists("past_data_in_queue.csv")) {
  past.data.in.queue <- read.csv("past_data_in_queue.csv")
} else {
  # First run: create empty tibble with same structure
  past.data.in.queue <- current.data.queue |> slice(0)
}

# Find new data
data.in.queue.not.in.previous.runs <- anti_join(
  current.data.queue, 
  past.data.in.queue
)

# If there is new data then send message
if (nrow(data.in.queue.not.in.previous.runs) > 0) {
  
  ###########################
  ## SEND TELEGRAM MESSAGE ##
  ###########################
  
  # Create bot instance
  bot <- Bot(token = Sys.getenv("TELEGRAM_BOT_TOKEN"))
  
  # Send message
  bot$sendMessage(
    chat_id = -4862294843,
    text = "New data collected in wetlands has been delivered in SMART Connect for you to process in SMART Desktop :)"
  )
  
  cat("Sent Telegram notification for", nrow(data.in.queue.not.in.previous.runs), "new records\n")
} else {
  cat("No new data found\n")
}

# Write the current data in the queue to compare in the next round
write.csv(current.data.queue, "past_data_in_queue.csv", row.names = FALSE)

# cat("Script completed successfully\n")