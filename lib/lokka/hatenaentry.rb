require 'open-uri'
require 'json'
module Lokka
  module Helpers
    def hatena_entry(uri, count = 10)
      open("http://b.hatena.ne.jp/entry/json/#{hatenaescape(uri)}") do |json|
        ent = JSON.parse(json.read)
        bmcount = ent['count'].to_i
        max = bmcount < count ? bmcount : count
        1.upto(max) do |i|
          yield i, ent['bookmarks'][i]
        end
      end
    end

    private
    def hatenaescape(uri)
      uri.gsub('#', '%23')
    end
  end
end
