#!/usr/bin/env ruby

require 'twitter'
require 'json'

MAPPING_FILE = 'utterance_tweets.json'

secrets = JSON.parse(File.read('.secrets.json'))

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = secrets['consumer_key']
  config.consumer_secret     = secrets['consumer_secret']
end

utterance_tweets = {}
if File.exist?(MAPPING_FILE)
  utterance_tweets = JSON.parse(File.read(MAPPING_FILE))
  $stderr.puts "Loaded #{utterance_tweets.keys.length} mappings from #{MAPPING_FILE}"
end

File.foreach("../data/neuraltv-utterances.txt") do |utterance|
  utterance.chomp!
  if utterance_tweets.has_key?(utterance)
    $stderr.puts "skipping: #{utterance}"
  else
    begin
      search_results = client.search("from:neural_tv \"#{utterance}\"")
      if search_results.count > 0
        $stderr.puts utterance
        utterance_tweets[utterance] = search_results.map{|tweet| tweet.id}
        File.open(MAPPING_FILE,'w') do |f|
          f.write(utterance_tweets.to_json)
        end
      end
      sleep 1
    rescue Twitter::Error::TooManyRequests => e
      $stderr.puts e.inspect
      $stderr.puts "Sleeping for 15 minutes..."
      sleep 900
      $stderr.puts "Retrying..."
      retry
    end
  end
end
