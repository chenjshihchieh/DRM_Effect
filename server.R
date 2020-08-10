function(input, output, session){
  ##Initializing important variables####
  rv <- reactiveValues(transition = 1,
                       question = 1,
                       recallList = list()
                       )
  
  ##Tester variables
  output$transitionTester <- renderText({rv$transition})
  output$startTester <- renderText({input$start})
  
  ##Page Transition####
  # toListen <- reactive({
  #   list(
  #     input$start,
  #     input$nex
  #   )
  # })
  
  observeEvent(input$prev, {
    if(rv$transition > 1){
      rv$transition <- rv$transition - 1
    }
  })
  
  observeEvent(input$start, {
    rv$transition <- rv$transition + 1
  })
  
  observeEvent(input$nex, {
    rv$transition <- rv$transition + 1
  })
  
  # observeEvent(toListen(), {
  #   ##adding in transition function
  #   rv$transition <- rv$transition + 1
  # })
  
  ##Recall Section####
  
  ##recall Table
  output$recallText <- renderText({
    paste(rv$recallList, collapse = '     ')
    })
  
  observeEvent(input$add, {
    rv$recallList <- c(rv$recallList, input$recallInput)
    updateTextInput(session, 'recallInput', '', '')
  })
  
  
  ##Dynamic UI####
  output$mainUI <- renderUI(
    if(rv$transition == 1){    
      list(
        img(src = 'icon/kpuLogo.jpg'),
        fluidRow(actionButton('start', 'Start'), align = 'center')
      )
      
    }else if(rv$transition == 2){ ##Listening to stimuli
      list(
        h2('You will be listening to an audio clip. Try to remember as many nouns as you can.'),
        br(),
        tags$audio(src = 'SoundClips/DRM_Convo_food.mp3', type = 'audio/mp3', autplay = TRUE, controls = TRUE),
        br(),
        column(6, align = 'center', actionButton('nex', 'Next'))
      )
    }else if(rv$transition == 3){
      ##Recalling as many words as they can
      ##They have 2 minutes to recall  
      list(
        h2('Good work! Please try to recall as many noun as you can. Type in each word below and press the add button or press the "enter" key to add in each word.'),
        br(),
        textInput('recallInput', ''),
        actionButton('add', 'Add'),
        br(),
        h2(textOutput('recallText'))
      )
    }else if(rv$transition == 4){
      ##Distractor task math questions
      ##5 minute interval to answer as many questions as they can
      conditonalPanel()
      
    }else if(rv$transition == 5){
      ##Slider to judge whether they recognize the word (for selected words)
    }
  )
}
