---
---

generate_couplet = (lines, line_index, couplet) ->
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
        span_0 = $('<div>').attr('class','col-xs-12').append($('<span>').text(random_line))
        span_1 = $('<div>').attr('class','col-xs-12').append($('<span>').text(_.sample(all_rhymes)))
        $("#line_#{couplet}_0").append(span_0)
        $("#line_#{couplet}_1").append(span_1)
      else
        console.log "No rhyming lines found in couplet #{couplet}, retrying"
        generate_couplet(lines, line_index, couplet)

generate_poem = (lines) ->
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
    generate_couplet(lines, line_index, couplet)

$(document).ready ->
  console.log('ready')
  $('#loadingDiv').hide()
  $(document).ajaxStart -> $('#loadingDiv').show()
  $(document).ajaxStop -> $('#loadingDiv').hide()
  $.ajax 'data/neuraltv-utterances.txt',
    type: 'GET'
    dataType: 'text'
    error: (jqXHR, textStatus, errorThrown) ->
            console.log "AJAX Error: #{textStatus}"
    success: (data) ->
      generate_poem(data.split("\n"))
