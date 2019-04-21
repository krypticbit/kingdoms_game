local function format_news_item(n)
   return "[" .. os.date("%x %X", n.time) .. "] " .. n.content .. "\n"
end

function kingdoms.add_news(news)
   local uid = kingdoms.news.uid
   kingdoms.news.news[uid] = {content = news, time = os.time()}
   kingdoms.news.uid = uid + 1
   kingdoms.helpers.save()
end

function kingdoms.get_news(maxamt)
   local news = ""
   if maxamt == nil then -- Get all news
      local uid = 1
      local n
      while true do
         n = kingdoms.news.news[uid]
         if n == nil then -- Reached the end
            return news
         end
         news = news .. format_news_item(n)
         uid = uid + 1
      end
   else -- Get the `maxamt` most recent articles
      local uid = kingdoms.news.uid - 1
      local n
      while uid >= kingdoms.news.uid - maxamt do
         n = kingdoms.news.news[uid]
         news = news .. format_news_item(n)
         uid = uid - 1
      end
      return news
   end
end
