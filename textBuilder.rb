# coding: utf-8

require "natto"

# =======
# 形態素解析
# =======
class NattoParser
  attr_accessor :nm

  def initialize()
    @nm = Natto::MeCab.new
  end

  def parseTextArray(texts)
    words = []
    index = 0

    for text in texts do
      words.push(Array[])
      @nm.parse(text) do |n|
        if n.surface != ""
          words[index].push(n.surface)
        end
      end
      index += 1
    end
    return words
  end
end

# ========
# マルコフ連鎖
# =======
class Marcov
  public
  def marcov(array)
    result = []
    block = []

    block = findBlocks(array,-1)
    begin
      result = connectBlocks(block,result)
      if result == -1
        raise RuntimeError
      end
    rescue RuntimeError
      retry
    end

    #resultの最後が-1になったら終わり
    while result[result.length-1] != -1 do
      block = findBlocks(array,result[result.length-1])
      begin
        result = connectBlocks(block,result)
        if result == -1
          raise RuntimeError
        end
      rescue RuntimeError
        return -1
      end
    end
    return result
  end

  def genMarcovBlock(words)
    array = []

    #最初と最後は-1
    words.unshift(-1)
    words.push(-1)

    #3単語ずつ配列に格納
    for i in 0..words.length-3
      array.push([words[i],words[i+1],words[i+2]])
    end
    return array
  end

  private
  def findBlocks(array,target)
    blocks = []
    for block in array
      if block[0] == target
        blocks.push(block)
      end
    end
    return blocks
  end

  def connectBlocks(array,dist)
    i=0
    begin
      for word in array[rand(array.length)]
        if i != 0
          dist.push(word)
        end
        i += 1
      end
    rescue NoMethodError
      return -1
    else
      return dist
    end
  end
end

# =======
# テキスト化
# =======

def generate_text(bot, screen_name, tweet_num)
  parser = NattoParser.new
  marcov = Marcov.new

  block = []

  tweet = ""
  tweets = bot.get_tweet(screen_name,tweet_num)

  words = parser.parseTextArray(tweets)

  #3単語ブロックをツイート毎の配列に格納
  for word in words
    block.push(marcov.genMarcovBlock(word))
  end

  block = reduce_degree(block)

  #1~140字になるまでマルコフ連鎖
  while tweet.length == 0 or tweet.length > 60 do
    begin
      tweetwords = marcov.marcov(block)
      if tweetwords == -1
        raise RuntimeError
      end
    rescue RuntimeError
      retry
    end
    tweet = words2str(tweetwords)
  end
  return tweet
end

def reduce_degree(array)
  result = []

  array.each do |a|
    a.each do |v|
      result.push(v)
    end
  end
  return result
end

def words2str(words)
  str = ""
  for word in words do
    if word != -1
      str += word
    end
  end
  return str
end
