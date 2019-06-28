# coding: utf-8
require "twitter"

class TweetBot
  attr_accessor :client
  attr_accessor :screen_name

  def initialize(screen_name)
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key         =ENV['api_key']
      config.consumer_secret      =ENV['api_secret']
      config.access_token         =ENV['access_token']
      config.access_token_secret  =ENV['access_token_secret']
    end

    @screen_name = screen_name
  end

  def fav(status_id)
    if status_id
      @client.fav(status_id)
    end
  end

  def rts(status_id:nil)
    if status_id
      @client.retweet(status_id)
    end
  end

  def get_follower(user=@screen_name)
    follower = []
    @client.follower_ids(user).each do |id|
      follower.push(id)
    end
    return follower
  end

  def get_friend(user=@screen_name)
    friend = []
    @client.friend_ids(user).each do |id|
      friend.push(id)
    end
    return friend
  end

  def get_tweet(user_name, tweet_count)
    tweets = []

    @client.user_timeline(user_name, {count: tweet_count, exclude:rts}).each do |timeline|
      tweet = @client.status(timeline.id)
      if not tweet.text.include?("RT")
        if  (tweet.source.include?("TweetDeck") or
             tweet.source.include?("Twitter for iPhone") or
             tweet.source.include?("Twitter for iPad") or
             tweet.source.include?("Twitter for Android") or
             tweet.source.include?("Twitter Web Client"))
          tweets.push(tweet2textdata(tweet.text))
        end
      end
    end
    return tweets
  end

  def post(text = "")
    @client.update(text)
  end

  def reply(text = "",twitter_id,status_id)
    rep_text = "@#{twitter_id} #{text}"
    @client.update(rep_text,{:in_reply_to_status_id => status_id})
  end

  def autoReply(bot,tweet_source,tweet_num,user_name,status_id)
    sentence = generate_text(bot, tweet_source, tweet_num)
    reply(sentence,user_name,status_id)
  end

  def ffManage()
    begin
      @client.follow(
        get_follower(@screen_name) - get_friend(@screen_name)
      )
      @client.unfollow(
        get_friend(@screen_name) - get_follower(@screen_name)
      )
    rescue Twitter::Error::Forbidden => error
    end
  end
  
end

def tweet2textdata(text)
  replypattern = /@[\w]+/
  text = text.gsub(replypattern,'')
  text = text.gsub(/#/,'#.')
  textURI = URI.extract(text)

  for uri in textURI do
    text = text.gsub(uri,'')
  end
  return text
end
