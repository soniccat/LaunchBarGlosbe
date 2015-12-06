require 'net/http'
require 'net/https'
require 'json'

class GlosbeTranslateCommand

  attr_accessor :from, :to, :phrase, :translates
  def initialize(from, to, phrase)
    @from = from
    @to = to
    @phrase = phrase
  end

  def run
    #File.open("../../../outputQuizlet", "at") {|f| f.write("\n");f.write(curlCommand())}
    #https://glosbe.com/gapi/translate?from=ru&dest=eng&format=json&phrase=кот&pretty=true
    command = "https://glosbe.com/gapi/translate?from=" + from + "&dest=" + to + "&phrase=" + phrase + "&format=json"

    uri = URI(URI::encode(command))

    res = nil
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new(uri)
      res = http.request request

      if res.code.to_i.between?(200,299)
        res = res.body
        @translates = handleBody(res)
      end
    end

    # File.open("../../../outputQuizlet", "at") do |f|
    # f.write("\n");
    #
    # if (res.is_a?(Net::HTTPResponse))
    # f.write(res.code)
    # f.write(res.body)
    #
    # elsif (res.is_a?(String))
    # f.write(res)
    # end
    # end

    return translates != nil
  end

  def handleBody(body)
    data = JSON.load body
    if (data['result'] == 'ok')
      return handleTuc(data['tuc'])
    end
  end

  def handleTuc(tuc)
    phrases = []
    tuc.each { |v|
      phrase = parsePhrase(v)
      if (phrase)
        phrases += [phrase]
      end
    }

    return phrases
  end

  def parsePhrase(v)
    phrase = GlosbePhrase.new()

    phraseDict = v['phrase']
    if (phraseDict)
      phrase.phrase = phraseDict['text']
    end

    meanings = []
    meaningArray = v['meanings']
    if (meaningArray != nil)
      meaningArray.each { |m|
        meanings += [m['text']]
      }
    end

    phrase.meanings = meanings
    if (!phrase.isValid)
      phrase = nil
    end

    return phrase
  end
end

class GlosbePhrase
  attr_accessor :phrase, :meanings

  def isValid()
    return phrase != nil && meanings != nil
  end
end

#command = GlosbeTranslateCommand.new("ru","en","кот")
#p command.run
#p command.translates
