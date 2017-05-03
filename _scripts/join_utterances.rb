#!/usr/bin/env ruby

require 'csv'
require 'json'

MAPPING_FILE = 'utterance_tweets_joined.json'

def normalize_tweet(tweet)
  tweet.chomp.gsub("\n",' ').sub(/ \/cc .*$/,'').sub(/ https.*$/,'').sub(/^RT .*$/,'').strip
end

utterance_tweets = {}

CSV.foreach('tweets.csv', :headers => true) do |row|
  normalized_tweet = normalize_tweet(row['text'])
  unless normalized_tweet.empty?
    utterance_tweets[normalized_tweet] ||= []
    utterance_tweets[normalized_tweet] << row['tweet_id'].to_s
  end
end
File.open(MAPPING_FILE,'w') do |f|
  f.write(utterance_tweets.to_json)
end
