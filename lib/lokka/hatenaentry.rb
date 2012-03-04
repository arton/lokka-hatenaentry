# codidng: utf-8
require 'open-uri'
require 'cgi'
require 'json'

module Lokka
  module Helpers
    #
    # === Summary
    # Enumerate bookmarks for sprcified uri
    #
    # hatena_entry(uri, count = 10) do |entry, bm|
    #   do something
    # end
    #
    # === Arguments
    # +uri+::
    #  uri for the bookmarks
    # +count+::
    #  stop enumerate while it reaches this value. (default = 10)
    # +entry_info+::
    #  block variable for the entry.
    #   see http://developer.hatena.ne.jp/ja/documents/bookmark/apis/getinfo
    # +bm+::
    #  block variable for the bookmark of the entry.
    #
    # === example
    # info = nil
    # hatena_entry('http://lokka.org/') do |ent, bm|
    #   unless info
    #     info = "total bookmarks = #{ent.count} for #{ent.title}"
    #   end
    #   puts "#{bm.user} bookmard at #{bm.timestamp}"
    # end
    #
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

    #
    # === Summary
    # Enumerate latest bookmark for the site
    #
    # hatena_latest_entry(uri, option = {}) do |title, uri| end
    #
    # === Arguments
    # +uri+::
    # uri for the bookmark entry
    # +option+::
    # hash of the options.
    #  :count => enumerate entry while it reaches this value. (default = 20)
    #  :sort => type of sort. it must be one of { :hot, :count, :eid }
    #                                                      (default = eid)
    #  :threshold => only valid if :sort => :hot   (default = 5)
    #
    # === Example
    # hatena_latest_entry('http://lokka.org/', :sort => :eid, :count => 1) do |title, uri|
    #   puts "the latest bookmark is <a href=\"#{uri}\">#{title}</a>";
    # end
    #
    def hatena_latest_entry(uri, option = {})
      count = option[:count] || 20
      sort = (option[:sort] || 'eid').to_s
      if sort == 'hot'
        sort = "hot&threshold=#{option[:threshold] || 5}"
      end
      open("http://b.hatena.ne.jp/entrylist?sort=#{sort}&url=#{CGI::escape(uri)}") do |http|
        current = 0
        http.read.scan(/href="([^"]+)"\s+class="entry-link"\s+title="([^"]+)"/m) do |href|
          yield href[1], href[0]
          current += 1
          break if current == count
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
