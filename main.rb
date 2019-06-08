# coding: utf-8
require "./tweetBot.rb"
require "./textBuilder.rb"

def main()
  bot = TweetBot.new("idonct_ai")
  tweet_source = "idonct" 
  tweet_num = 50

  t1 = Thread.new do
    p "Start Auto Tweet"
    while 1 do
      sentence = generate_text(bot, tweet_source, tweet_num)
      bot.post(sentence)
      p "tweet -> " + sentence
      sleep(300)
    end
  end 

  t2 = Thread.new do
    while 1 do
      bot.ffManage()
      sleep(300)
    end
  end 

  t1.join
  t2.join
end

main()
