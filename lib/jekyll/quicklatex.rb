require 'net/http'
require 'fileutils'
require 'digest'
require 'jekyll/quicklatex/version'

module Jekyll
  module Quicklatex
    class Block < Liquid::Block
      def initialize tag_name, markup, tokens
        super
        init_param
      end

      def render(context)
        @output_dir = context.registers[:site].config['destination']
        snippet = filter_snippet(super)
        url = remote_compile snippet
        "<img src='/#{@saved_dir}#{url}' onerror='this.onerror=null; this.src=\"http://quicklatex.com#{url}\"' />#{super}"
      end

      private

      class Cache
        def initialize
          @cache = {}
          @cache_file = 'latex.cache'
          if File.exist? @cache_file
            File.open(@cache_file, 'r') do |f|
              while line = f.gets
                hash, url = line.split
                @cache[hash] = url
              end
            end
          end
        end

        def fetch(content)
          id = hash_id(content)
          @cache[id]
        end

        def cache(content, url)
          id = hash_id(content)
          @cache[id] = url
          File.open(@cache_file, 'a') do |f|
            f.syswrite("#{id} #{url}\n")
          end
        end

        private

        def hash_id(content)
          Digest::MD5.hexdigest(content)
        end
      end

      def init_param
        @site_uri = URI('http://quicklatex.com/latex3.f')
        @post_param = {
          :fsize => '30px',
          :fcolor => '000000',
          :mode => 0,
          :out => 1,
          :errors => 1,
          :remhost => 'quicklatex.com',
          :rnd => '9.483426365449255'
        }
        @pic_regex = /http.*png/
        @saved_dir = 'assets/latex'
        @cache = Cache.new
      end

      def filter_snippet(snippet)
        # text is html that rendered by highlight
        # strip all html tags
        no_html_tag = snippet.gsub(/<\/?[^>]*>/, "")
          .gsub(/&gt;/, '>')
          .gsub(/&lt;/, '<')

        # strip all comments in latex code snippet
        lines = no_html_tag.lines
        lines.reject do |l|
          # blank line or comments(start with %)
          l =~ /^\s*$/ or l =~ /^\s*%/
        end.join
      end

      def seperate_snippet(snippet)
        lines = snippet.lines
        preamble, formula = lines.partition { |line| line =~ /usepackage/ }

        def join_back(lines)
          lines.join('').gsub(/%/, '%25').gsub(/&/, '%26')
        end

        return {
          :preamble => join_back(preamble),
          :formula => join_back(formula),
        }
      end

      def remote_compile(snippet)
        if url = @cache.fetch(snippet)
          return url
        end

        param = @post_param.merge(seperate_snippet(snippet))

        req = Net::HTTP::Post.new(@site_uri)
        body_raw = param.inject('') do |result, nxt|
          "#{result}&#{nxt[0].to_s}=#{nxt[1].to_s}"
        end
        req.body = body_raw.sub('&', '')

        res = Net::HTTP.start(@site_uri.hostname, @site_uri.port) do |http|
          http.request(req)
        end

        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          pic_uri = URI(res.body[@pic_regex])

          save_path = "#{@saved_dir}#{pic_uri.path}"
          dir = File.dirname(save_path)
          unless File.directory? dir
            FileUtils.mkdir_p dir
          end

          @cache.cache(snippet, pic_uri.path)

          Net::HTTP.start(pic_uri.host) do |http|
            # http get
            resp = http.get(pic_uri.path)
            File.open(save_path, "wb") do |file|
              file.write(resp.body)
            end
          end

          pic_uri.path
        else
          res.value
        end
      end
    end
  end
end

Liquid::Template.register_tag('latex', Jekyll::Quicklatex::Block)
