require 'rubygems'
require 'sinatra'
require 'flickraw'
require 'haml'

# homepage
get '/' do
  @photos = flickr_search(["party"])
  view :index
end

# posting tags
post '/' do 
  @tags = params[:tags]
  @photos = flickr_search(@tags.split(","))
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
  
  def flickr_search(tags)
     query = "select * from flickr.photos.search where #{tags.map {|t| "tags = '#{t}'"}.join(" OR ")}"
     url = "http://query.yahooapis.com/v1/public/yql?q=#{URI.encode(query)}&format=json"
     result = JSON.parse(Net::HTTP.get_response(URI.parse(url)).body)

     raise "web service error" if result.has_key? 'Error'
     
     return result['query']['results']['photo']
  end
end


