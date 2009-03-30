require 'rubygems'
require 'sinatra'
require 'flickraw' # Not actually using flickr - just the JSON and NET constants... gotta be a better way!
require 'haml'

# homepage
get '/' do
  @tags = "party, band"
  @photos = flickr_search(@tags.split(","))
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
    plain_tags, user_tags = tag_sorting(tags)

    user_tag_IDs = []
    user_tags.each do |tag|
      tag = tag.split(":")
      yql_query("select href from html where url=\"http://flickr.com/photos/#{tag[0]}/tags/#{tag[1]}\" and xpath=\'//span[@class=\"photo_container pc_t\"]/a[@href]\'")['query']['results']['a'].each do |id|
        user_tag_IDs.push id['href'].gsub(/\/photos\/.+\/(.+)\//, '\1')
      end
    end
    
    result = yql_query("SELECT * FROM flickr.photos.sizes WHERE label=\"Large\" AND photo_id IN (SELECT id FROM flickr.photos.search WHERE #{plain_tags.map {|t| "tags = '#{t}'"}.join(" OR ")})")
    
    result.merge!(yql_query("SELECT * FROM flickr.photos.sizes WHERE (#{user_tag_IDs.map {|t| "photo_id = '#{t}'"}.join(" OR ")}) AND label=\"Large\""))
    
    raise "web service error" if result.has_key? 'Error'
    return result['query']['results']['size']
  end
  
  def tag_sorting(tags)
    plain_tags = []
    user_tags = []
    tags.each do |tag|
      if tag[/:/]
        user_tags.push tag
      else
        plain_tags.push tag
      end
    end
    return plain_tags, user_tags
  end
  
  def yql_query(query_string)
    url = "http://query.yahooapis.com/v1/public/yql?q=#{URI.encode(query_string)}&format=json"
    JSON.parse(Net::HTTP.get_response(URI.parse(url)).body)
  end
end

