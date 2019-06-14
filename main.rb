# coding: utf-8
require "./tweetBot.rb"
require "./textBuilder.rb"

def main()
  bot = TweetBot.new("idonct_ai")
  tweet_source = "idonct" 
  tweet_num = 50

  while 1 do
    bot.ffManage()
    sentence = generate_text(bot, tweet_source, tweet_num)
    bot.post(sentence)
    p "tweet -> " + sentence
    sleep(1200)
  end
end 

main()
