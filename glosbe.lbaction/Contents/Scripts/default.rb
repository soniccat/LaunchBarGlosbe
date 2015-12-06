require 'uri'
require "base64"
require 'json'
require 'time'
require './glosbe.rb'

def actionItems()
  return []
end

def handleLaunch()
  return actionItems()
end

def translate(from, to, word)
  command = GlosbeTranslateCommand.new(from, to, word)
  command.run
  if (command.run && command.translates.count > 0)
    return glosbeTranslatesToItems(command.translates)
  else
    return [emptyResultItem]
  end
end

def glosbeTranslatesToItems(translates)
  resultItems = []
  translates.each do |v|
    resultItems += [phraseItem(v)]

    v.meanings.each { |m|
      resultItems += [meaningItem(m)]
    }
  end

  return resultItems
end

# ==== getting items

def emptyResultItem
  item = {}
  item['title'] = 'Result is empty'
  return item
end

def phraseItem(translate)
  item = {}
  item['title'] = translate.phrase
  return item
end

def meaningItem(meaning)
  item = {}
  item['title'] = "* " + meaning
  return item
end


# ====

def handleArgs(arg)
  act = arg['_act']
  items = []
  
  if act == 'launch' 
    items = handleLaunch()
  
  elsif act == "translate"
    word = arg['_word']
    wordLang = detectLang(word)
    toLang = wordLang == "ru" ? "eng" : "ru"
    items = translate(wordLang, toLang, word)
    
  else 
    item = {}
    item['title'] = "Unknown Command: " + act
    item['action'] = "default.rb"
    item['actionReturnsItems'] = true
    
    items.push(item)
  end
  
  return items
end

def detectLang(word)
  lang = "eng"
  if word =~ /[абвгдеёжзийклмнопрстуфхцчшщъыьэюя]/
    lang = "ru"
  end

  return lang
end

items = []
if ARGV.length > 0
  items = handleArgs({'_act'=>'translate', '_word'=>ARGV[0].downcase})
else 
  items = handleArgs({'_act'=>'launch'})
end

#puts handleArgs({'_act'=>'translate', '_word'=>"коasdfaт"})
puts items.to_json
