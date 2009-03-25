require 'rubygems'
require 'sinatra'
require 'flickraw' # Not actually using flickr - just the JSON and NET constants... gotta be a better way!
require 'haml'

# homepage
get '/' do
  @tags = ["party, band"]
  @photos = flickr_search(@tags)
  view :index
end

# posting tags
post '/' do 
  @tags = params[:tags]
  @photos = flickr_search(@tags.split(","))
  view :index
end

# getting tags from permanent urls
get '/:tags' do 
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
    haml view, :options => {:format => :html5,
                              :attr_wrapper => '"'}
  end
  
  def versioned_stylesheet(stylesheet)
    "/stylesheets/#{stylesheet}.css?" + File.mtime(File.join(Sinatra::Application.public, "stylesheets", "#{stylesheet}.css")).to_i.to_s
  end
  
  def versioned_javascript(js)
    "/javascripts/#{js}.js?" + File.mtime(File.join(Sinatra::Application.public, "javascripts", "#{js}.js")).to_i.to_s
  end
  
  def flickr_search(tags)
    query = "SELECT * FROM flickr.photos.sizes WHERE label=\"Large\" AND photo_id IN (SELECT id FROM flickr.photos.search WHERE #{tags.map {|t| "tags = '#{t}'"}.join(" OR ")})"
    url = "http://query.yahooapis.com/v1/public/yql?q=#{URI.encode(query)}&format=json"
    result = JSON.parse(Net::HTTP.get_response(URI.parse(url)).body)

    raise "web service error" if result.has_key? 'Error'
     
    return result['query']['results']['size']
  end
end

