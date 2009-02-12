require 'rubygems'
require 'sinatra'
require 'flickraw'
require 'haml'

# Configure Block.
configure do
  
end

# reset stylesheet
get '/stylesheets/reset.css' do
  header 'Content-Type' => 'text/css; charset=utf-8'
  css :reset
end

# main stylesheet
get '/stylesheets/main.css' do
  header 'Content-Type' => 'text/css; charset=utf-8'
  css :main
end

# homepage
get '/' do
  @photos = flickr_search("tags=\"party\"")['query']['results']['photo']
  
  view :index
end

# posting tags
post '/' do 
  arr = []
  search = []
  params.each do |tag|
    if tag[1] != ""
      arr.push "tags=\"#{tag[1]}\""
      search = arr.join(" OR ")
    end
  end
  
  @photos = flickr_search("#{search}")['query']['results']['photo']
  view :index
end

# colophon
get '/colophon' do
  view :colophon
end


helpers do
  def view(view)
    haml view, :options => {:format => :html4,
                              :attr_wrapper => '"'}
  end
  
  def versioned_stylesheet(stylesheet)
    "/stylesheets/#{stylesheet}.css?" + File.mtime(File.join(Sinatra::Application.public, "stylesheets", "#{stylesheet}.css")).to_i.to_s
  end
  
  def versioned_javascript(js)
    "/javascripts/#{js}.js?" + File.mtime(File.join(Sinatra::Application.public, "javascripts", "#{js}.js")).to_i.to_s
  end
  
  def flickr_url(photo, size = "b")
    "http://farm#{photo['farm']}.static.flickr.com/#{photo['server']}/#{photo['id']}_#{photo['secret']}_#{size}.jpg"
  end
  
  def flickr_search(subject)
     query = "select * from flickr.photos.search where #{subject}"
     base_url = "http://query.yahooapis.com/v1/public/yql"
     url = "#{base_url}?q=#{URI.encode(query)}&format=json"
     puts url
     resp = Net::HTTP.get_response(URI.parse(url))
     data = resp.body

     # we convert the returned JSON data to native Ruby
     # data structure - a hash
     result = JSON.parse(data)

     # if the hash has 'Error' as a key, we raise an error
     if result.has_key? 'Error'
        raise "web service error"
     end
     return result
  end
end


