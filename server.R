function(input, output, session){
  ##Initializing important variables####
  rv <- reactiveValues(transition = 1,
                       question = 1,
                       recallList = list(),
                       remainingTime = 120,
                       count = 0,
                       distractorTotalScore = 0,
                       condUnavailable = ''
                       )
  
  countdown <- reactiveTimer(100)
  
  ##Tester variables#### Uncomment when Needed
  # output$transitionTester <- renderText({
  #   paste(c(length(rv$recallList), class(rv$recallList)), collapse = ", ")
  #   })
  # output$startTester <- renderText({
  #   paste(rv$recallList, collapse = ', ')
  # })
  # 
  # output$testing <- renderText({
  #   paste(c(class(input$distractionInput), class(multAns), input$distractorStart), collapse = "  ")
  # })
  # 
  # output$testingTable <- renderTable({
  #   countdown()
  #   return(responseData)
  # })
  ##################
  
  
  
  observeEvent(input$prev, {
    rv$transition <- rv$transition - 1
  })
  
  observeEvent(input$yes, {
    rv$transition <- rv$transition + 1
    removeModal()
  })
  
  output$conditionUnavailable <- renderText(rv$condUnavailable)
  
  observeEvent(input$start, {
    
    if(rv$transition == 1){
      query <<- getQueryString()
      
      if(length(query) > 0){
        if(names(query) == 'condition' & query %in% c(Food, School)){
          if(query %in% Food){
            responseData <<- data.frame(Word = judgList_food, response = rep(NA, length(judgList_food)))
          } else if(query %in% School){
            responseData <<- data.frame(Word = judgList_school, response = rep(NA, length(judgList_school)))
          }
          
          if(query == 'FoodConvYoung'){
            audioFile <<- 'SoundClips/DRM_Convo_food.mp3'
          }else if(query == 'FoodListYoung'){
            audioFile <<- 'SoundClips/DRM_list_food.mp3'
          }else if(query == 'SchoolConvYoung'){
            audioFile <<- 'SoundClips/DRM_Convo_school.mp3'
          }else if(query == 'SchoolListYoung'){
            audioFile <<- 'SoundClips/DRM_list_school.mp3'
          }else if(query == 'FoodConvOld'){
            audioFile <<- 'SoundClips/DRM.convo.food.older.mp3'
          }else if(query == 'FoodListOld'){
            audioFile <<- 'SoundClips/DRM.list.food.older.mp3'
          }else if(query == 'SchoolConvOld'){
            audioFile <<- 'SoundClips/DRM.convo.school.older.mp3'
          }else if(query == 'SchoolListOld'){
            audioFile <<- 'SoundClips/DRM.list.school.older.mp3'
          }
          
          rv$transition <- rv$transition + 1
          rv$condUnavailable <- 'works'
        }
      }else{
        rv$condUnavailable <<- "Condition is not provided. Please adjust the URL for the condition."
      }
    }
  })
  
  observeEvent(input$nex, {
    showModal(modalDialog(
      list(
        h2("Make sure you've listened to the audio clip. Are you ready to advance to the next page?")
      ), 
      title="Ready to move on?",
      footer = tagList(actionButton("yes", "Yes"),
                       modalButton('No')
      )
    ))
  })
  
  
  ##Recall Section####
  #recall Table
  output$recallText <- renderText({
    paste(rv$recallList, collapse = ', ')
    })
  
  observeEvent(input$add, {
    rv$recallList <- c(rv$recallList, input$recallInput)
    updateTextInput(session, 'recallInput', '', '')
  })
  
  #recall Timer
  observeEvent(countdown(), {
    if(rv$transition == 3){
      session$sendCustomMessage("recallFocus", list(NULL))
      
      if(rv$count < 10){
        rv$count <- rv$count + 1 
      } else {
        rv$count <- 0
        rv$remainingTime <- rv$remainingTime - 1
      }
      
      if(rv$remainingTime == 0) {
        rv$transition <- rv$transition + 1
        rv$remainingTime <- 300
      }
      
    }
  })
  
  output$timer <- renderText({
    paste(c('Timer:', rv$remainingTime, 's'), collapse = '')
  })
  
  
  ##Disctractor Section####
  output$distractorInstruction <- renderText('In this task, you will have five minutes to answer as many questions as possible. 
                                             \n Press the start button when you are ready to begin.')
  output$distractorQuestion <- renderText({
    paste(c(multQs1[rv$question], '*', multQs2[rv$question]), collapse = "  ")
  })
  
  observeEvent(input$questionSubmit, {
    if(!is.null(input$distractionInput)&!is.null(input$questionSubmit)){
      if(is.numeric(input$distractionInput)){
        if(input$distractionInput == multAns[rv$question]){
          showNotification('correct', duration = 3)
          rv$distractorTotalScore <- rv$distractorTotalScore + 1
          rv$question <- rv$question+1
        } else {
          showNotification('incorrect', duration = 3)
          rv$question <- rv$question+1
        }
      }else {
        showNotification('not a number', duration = 3)
      }
      
    }
    
    updateNumericInput(session, 'distractionInput', '', '')
  })
  
  
  
  #hiding distractor instruction when start button is pressed
  observeEvent(input$distractorStart, {
    if(input$distractorStart == 1){
      shinyjs::hide('distractorInstruction')
      shinyjs::hide('distractorStart')
    }
    
    session$sendCustomMessage("distractorFocus", list(NULL))
    
  })
  
  #Displaying the score for distractor tasks
  output$distractorScore <- renderText({
    paste(c('Score:', rv$distractorTotalScore), collapse = '  ')
  })
  
  ##recall Timer
  observeEvent(countdown(), {
    if(!is.null(input$distractorStart)){
      if(rv$transition == 4 & input$distractorStart == 1){
        if(rv$count < 10){
          rv$count <- rv$count + 1
        } else {
          rv$count <- 0
          rv$remainingTime <- rv$remainingTime - 1
        }
        
        if(rv$remainingTime == 0) {
          rv$transition <- rv$transition + 1
          rv$remainingTime <- 300
        }
      }
    }
  })
  
  output$distractorTimer <- renderText({
    paste(c('Timer:', rv$remainingTime, 's'), collapse = '')
  })
  
  ##Judgment Task####
  #Hiding judgment start button
  observeEvent(input$judgStart, {
    if(input$judgStart == 1){
      shinyjs::hide('judgStart')
    }
  })
  
  output$judgmentInstruction <- renderText({
    "In this next section, you'll be asked to judge whether or not a word was in the audio clip you heard or not. You'll be responding on a scale of 0 to 100. 0 means that the word was not in the audio clip. 100 means that you are 100% sure that the word was in the audio clip."
  })
  
  output$judgmentWord <- renderText({
    if(is.null(input$judgSubmit)){
      return('')
    }else{
      if(query %in% Food){
        return(judgList_food[input$judgSubmit + 1])
      } else if(query %in% School){
        return(judgList_school[input$judgSubmit + 1])
      }
    }
  })
  
  #Actions to be taken on judgeSubmit button press
  observeEvent(input$judgSubmit,{
    responseData$response[input$judgSubmit] <<- input$judgmentSlider
    updateSliderInput(session, 'judgmentSlider', value = 50)
    
    if(input$judgSubmit == length(responseData$response)){
      rv$transition <- rv$transition +1
    }
  })
  
  
  
  ##Downloading CSV####
  output$downloadButton <- downloadHandler(filename = paste0('response-', Sys.Date(), ".csv"), 
                                           content = function(file){
                                             if(nrow(responseData) < length(rv$recallList)){
                                               diff <- length(rv$recallList) - nrow(responseData)
                                               while(diff > 0){
                                                 responseData <- rbind(responseData, c(NA, NA))
                                                 diff <- diff -1
                                               }
                                               data <- data.frame(responseData, recall = unlist(rv$recallList))
                                               
                                             } else if (nrow(responseData) > length(rv$recallList)){
                                               diff <- nrow(responseData) - length(rv$recallList)
                                               rv$recallList <- c(rv$recallList, rep(NA, diff))
                                               data <- data.frame(responseData, recall = unlist(rv$recallList))
                                             } else {
                                               data <- data.frame(responseData, recall = unlist(rv$recallList))
                                             }
                                             write.csv(data, file, row.names = FALSE)
                                           })
  
  output$voice <- renderText({input$condition})
  
  ##Dynamic UI####
  output$mainUI <- renderUI(
    if(rv$transition == 1){    
      list(
        img(src = 'icon/kpuLogo.jpg'),
        br(),
        h2(textOutput('conditionUnavailable')),
        br(),
        fluidRow(actionButton('start', 'Start'), align = 'center')
      )
      
    }else if(rv$transition == 2){ ##Listening to stimuli
      list(
        # textOutput('voice'),##For test#### uncomment if necessary
        h2('You will be listening to an audio clip. Try to remember as many nouns as you can. You will be asked to recall them later. Press the play button when you are ready.'),
        br(),
        tags$audio(src = audioFile, type = 'audio/mp3', autplay = TRUE, controls = TRUE),
        br(),
        column(12, align = 'center', actionButton('nex', 'Next'))
      )
    }else if(rv$transition == 3){
      ##Recalling as many words as they can
      ##They have 2 minutes to recall  
      list(
        h2('Good work! Please try to recall as many nouns as you can. Type in each word below and press the add button or press the "enter" key to add in each word.'),
        br(),
        h2(textOutput('timer')),
        textInput('recallInput', ''),
        actionButton('add', 'Add'),
        br(),
        h2(textOutput('recallText'))
      )
    }else if(rv$transition == 4){
      ##Distractor task math questions
      ##5 minute interval to answer as many questions as they can
      list(
        # textOutput('testing'),##For test#### uncomment if necessary
        h2(textOutput('distractorInstruction')),
        fluidRow(actionButton('distractorStart', 'Start'), align = 'center'),
        conditionalPanel('input.distractorStart == 1',
                        list(
                          h2(textOutput('distractorScore')), h2('  '), h2(textOutput('distractorTimer')),
                          br(),
                          h2(textOutput('distractorQuestion')),
                          br(),
                          numericInput('distractionInput', '', ''),
                          actionButton('questionSubmit', 'Submit')
                        )
        )
      )
      
    }else if(rv$transition == 5){
      ##Slider to judge whether they recognize the word (for selected words)
      list(
        h2(textOutput('judgmentInstruction')),
        br(),
        fluidRow(actionButton('judgStart', 'Start'), align = 'center'),
        br(),
        conditionalPanel('input.judgStart == 1', {
          list(
            h2(textOutput('judgmentWord')),
            br(),
            sliderInput('judgmentSlider', label = '', min = 0, max = 100, value = 50, step = 1),
            br(),
            fluidRow({
              actionButton('judgSubmit', 'Submit')
            }, align = 'center')
          )
        })#,
        # tableOutput('testingTable')##For test#### uncomment if necessary
      )
    } else {
      list(
        h2("Well done! You've completed all the tasks. Click the button below to download your data."),
        br(),
        downloadButton('downloadButton', 'Download')
      )
    }
  )
}
