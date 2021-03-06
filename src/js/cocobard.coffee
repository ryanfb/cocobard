---
---

generate_line = (utterance, utterance_tweets, couplet, line) ->
  if utterance_tweets[utterance]?
    tweet_id = _.sample(utterance_tweets[utterance])
    tweet = 'https://twitter.com/neural_tv/status/' + tweet_id
    console.log utterance_tweets[utterance]
    console.log tweet
    $.ajax "https://publish.twitter.com/oembed?url=#{tweet}&omit_script=true&hide_media=false",
      type: 'GET'
      dataType: 'jsonp'
      error: (jqXHR, textStatus, errorThrown) ->
              console.log "AJAX Error: #{textStatus}"
      success: (tweet_data) ->
        link = $('<a>').attr('href',tweet).attr('target','_blank').attr('class','tweet_link').text(utterance)
        html = $('<div>').attr('class','embedded_tweet').hide().append(tweet_data['html'])
        $("#line_#{couplet}_#{line}").append($('<div>').attr('class','col-xs-12').append(link))
        $("#line_#{couplet}_#{line}").append($('<div>').attr('class','col-xs-12').append(html))
        twttr.widgets.load(document.getElementById("line_#{couplet}_#{line}"))
  else
    $("#line_#{couplet}_#{line}").append($('<div>').attr('class','col-xs-12').append($('<span>').text(utterance)))

generate_couplet = (lines, line_index, utterance_tweets, couplet) ->
  random_line = _.sample(lines)
  last_word = _.last(random_line.split(' '))
  console.log random_line
  console.log last_word
  $.ajax "https://api.datamuse.com/words?rel_rhy=#{last_word}",
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
            console.log "AJAX Error: #{textStatus}"
    success: (data) ->
      all_rhymes = []
      for rhyme_word in data
        if line_index[rhyme_word['word']]?
          rhyming_lines = line_index[rhyme_word['word']]
          # console.log rhyme_word['word']
          # console.log rhyming_lines
          all_rhymes = all_rhymes.concat(rhyming_lines)
      if all_rhymes.length > 0
        generate_line(random_line, utterance_tweets, couplet, 0)
        generate_line(_.sample(all_rhymes), utterance_tweets, couplet, 1)
      else
        console.log "No rhyming lines found in couplet #{couplet}, retrying"
        generate_couplet(lines, line_index, utterance_tweets, couplet)

generate_poem = (lines, utterance_tweets) ->
  console.log 'generate_poem'
  line_index = {}
  for line in lines
    last_word = _.last(line.split(' '))
    unless line_index[last_word]?
      line_index[last_word] = []
    line_index[last_word].push(line)
  console.log "#{Object.keys(line_index).length} unique words"
  for couplet in [0..6]
    console.log "Generating couplet #{couplet}"
    generate_couplet(lines, line_index, utterance_tweets, couplet)

$(document).ready ->
  console.log('ready')
  $('#loadingDiv').hide()
  $(document).ajaxStart -> $('#loadingDiv').show()
  $(document).ajaxStop -> $('#loadingDiv').hide()
  $('#visualize').click ->
    $('.tweet_link').toggle()
    $('.embedded_tweet').toggle()
    $('#visualize').toggleClass('active')
  $.ajax 'data/utterance_tweets.json',
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
            console.log "AJAX Error: #{textStatus}"
    success: (utterance_tweets) ->
      generate_poem(Object.keys(utterance_tweets), utterance_tweets)
