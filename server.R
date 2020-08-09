function(input, output){
  
  output$mainUI <- renderUI(
    if(rv$transition == 1){    
      list(
        img(src = 'icon/kpuLogo.jpg'),
        br(),
        actionButton('start', 'Start', align = 'center')
      )
      
    }else if(rv$transition == 2){ ##Listening to stimuli
      list(
        h2('You will be listening to an audio clip. Try to remember as many nouns as you can.'),
        br(),
        tags$audio(src = 'SoundClips/DRM_Convo_food.mp3', type = 'audio/mp3', autplay = TRUE, controls = TRUE)
      )
    }else if(rv$transition == 3){ 
      
    }else if(rv$transition == 4){
      ##Recalling as many words as they can
      ##They have 2 minutes to recall  
      list(
        
      )
    }else if(rv$transition == 5){
      ##Distractor task math questions
      ##5 minute interval to answer as many questions as they can
    }else if(rv$transition == 6){
      ##Slider to judge whether they recognize the word (for selected words)
    }
  )
}
