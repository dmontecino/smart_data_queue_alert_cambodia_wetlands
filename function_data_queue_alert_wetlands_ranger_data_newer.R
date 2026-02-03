
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
  
 setwd("Users/DMontecino/OneDrive - Wildlife Conservation Society/SMART/REPORTS/CAMBODIA/WETLANDS_RANGERS/DATA_QUEUE_ALERT/") 
 
  #open current available data in the queue
  response<- GET(url = "https://wcshealth.smartconservationtools.org/server/api/dataqueue/items", 
                 config = authenticate(user = Sys.getenv("EXAMPLE_CONNECT_USERNAME"),
                                       password = Sys.getenv("EXAMPLE_CONNECT_PASSWORD")), timeout(30))
  
  if (status_code(response) == 200) {
    data <- content(response, as = "parsed")
    current.data.queue<-map(data, as_tibble) |> bind_rows()}
    
  current.data.queue <-
    current.data.queue |> 
      select(name, conservationArea) #|> 
      # mutate(date = date(mdy_hms(str_extract(name, "\\w+ \\d+, \\d+, \\d+:\\d+:\\d+ [AP]M"))))
  # current.data.queue<-current.data.queue[120:142,]
  
  #open previous data in the queue
  past.data.in.queue<-read.csv("past_data_in_queue.csv")
  # past.data.in.queue<-past.data.in.queue[-c(120:142),]
  # past.data.in.queue<-as_tibble(past.data.in.queue)
  # past.data.in.queue$date<-as.Date(past.data.in.queue$date)
        
  #todays date
  # todays.date<-Sys.Date()
    
  # current.data.queue.today<-current.data.queue |> filter(date == todays.date)
  # past.data.in.queue.today<-past.data.in.queue |> filter(date == todays.date)
  
    # does the stored data of queued data has data from today?
    # if(any(past.data.in.queue$date == todays.date)==TRUE){
      
      data.in.queue.not.in.previous.runs <- anti_join(current.data.queue, 
                                                      past.data.in.queue)  
      
      # if there is new data then send message
      if(nrow(data.in.queue.not.in.previous.runs)>0){
        
      ################
      ## SEND EMAIL ##
      ################
      
      # library(gmailr)
      #  
      # # Setup Gmail API credentials first
      # gm_auth_configure(path = "path/to/credentials.json")
      # gm_auth()
      # 
      # # Create and send email
      # email <- gm_mime() |>
      #   gm_to("recipient@example.com") |>
      #   gm_from("sender@example.com") |>
      #   gm_subject("Test from R") |>
      #   gm_text_body("This is a test email")
      # 
      # gm_send_message(email)
      
      ###########################
      ## SEND TELEGRAM MESSAGE ##
      ###########################
      
      # t.me/Health_Data_Notifier_bot
      
      # Create bot instance
      bot <- Bot(token = Sys.getenv("TELEGRAM_BOT_TOKEN"))
      
      # updates <- bot$getUpdates()
      # chat_id <- updates[[10]]$from_chat_id()
      
      # Send message
      bot$sendMessage(
        chat_id = -4862294843,
        text = "New data collected in wetlands has been delivered in SMART Connect for you to process in SMART Desktop :)")
      }
      
  #> write the current data in the queue to compare in the next 
  #> round with the data in the queue at time t
write.csv(current.data.queue, "past_data_in_queue.csv", row.names = F)
 
# resetting the working directory to the home directory
setwd("~")     
    # }

