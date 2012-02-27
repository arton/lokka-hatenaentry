# codidng: utf-8
require 'open-uri'
require 'cgi'
require 'json'

module Lokka
  module Helpers
    def hatena_entry(uri, count = 10)
      open("http://b.hatena.ne.jp/entry/jsonlite/#{hatenaescape(uri)}") do |json|
        ent = JSON.parse(json.read)
        entry = hash_to_obj(ent, HatenaBMEntry)
        max = entry.count < count ? entry.count : count
        1.upto(max) do |i|
          yield entry, hash_to_obj(ent['bookmarks'][i], HatenaBookmark)
        end
      end
    end

    def hatena_latest_entry(uri)
      open("http://b.hatena.ne.jp/entrylist?sort=eid&url=#{CGI::escape(uri)}") do |http|
        http.read.scan(/href="([^"]+)"\s+class="entry-link"\s+title="([^"]+)"/m) do |href|
          yield href[1], href[0]
        end
      end
    end

    private
    def hatenaescape(uri)
      uri.gsub('#', '%23')
    end
    def hash_to_obj(h, cls)
      cls.new(h)
    end

    class HatenaBMObj
      def initialize(h)
        h.each do |k, v|
          __send__ "#{k}=".to_sym, v
        end
      end
    end
    class HatenaBMEntry < HatenaBMObj
      def initialize(h)
        super
      end
      attr_accessor :title, :url, :entry_url, :screenshot, :eid
      attr_reader :count
      private
      def count=(c)
        @count = c.to_i
      end
      def bookmarks=(bs)
        # drop entries
      end
    end
    class HatenaBookmark < HatenaBMObj
      def initialize(h)
        super
      end
      attr_accessor :comment, :user, :tags
      attr_reader :timestamp
      def timestamp=(s)
        if String === s
          @timestamp = Time.new(*s.split(%r|[/ :]|).map {|e| e.to_i})
        else
          @timestamp = s
        end
      end
    end
  end
end
