# encoding: utf-8

# Title: File Binder for Octopress
# Authors: Code Ass http://aycabta.github.com/
# Description: Attach some images or other files to the entry
#
# Usege:
# ------
# If you wrote a entry in "source/_posts/YYYY-DD-MM-title-of-a-entiry.markdown",
# you can attach the files that are given the name of
# "source/_posts/YYYY-DD-MM-title-of-a-entiry_filename-of-image.png" for example.
# The attached file puts out into the same directory of the entry by the name of "filename-of-image.png",
# in this case it is "public/blog/YYYY/DD/MM/title-of-a-entry/filename-of-image.png".
# You can refer the file from the entry by img or others tags.
#
# Support customized permalink in _config.yml that is different from "/blog/:year/:month/:day/:title/".
#
# License:
# --------
# Distributed under the [MIT License][MIT].
#
# [MIT]: http://www.opensource.org/licenses/mit-license.php
#

require './plugins/post_filters.rb'
require './plugins/image_tag.rb'

module Jekyll
  BOUND_FILE_MATCHER = /^(.+\/)*(\d+-\d+-\d+)-(.*)_(.*)(\.[^.]+)$/

  class Post
    attr_accessor :base

    def self.valid?(name)
      if name =~ MATCHER
        result = true
        if name =~ Jekyll::BOUND_FILE_MATCHER
          result = false
        end
      else
        result = false
      end
      result
    end

    def cleanup_bound_files
      m, cats, date, slug, ext = *name.match(Post::MATCHER)
      find_filename = [cats, date, '-', slug, '_*'].join
      Dir[File.join(site.source, '_posts', find_filename)].each do |f|
        if f =~ Jekyll::BOUND_FILE_MATCHER
          dest_dir = File.dirname(destination(site.dest))
          dest_filename = $4 + $5
          dest_path = File.join(dest_dir, dest_filename)
          FileUtils.rm_f(dest_path)
        end
      end
    end
  end

  class Site
    attr_accessor :me

    alias_method :old_filter_entries_for_file_binder, :filter_entries
    def filter_entries(entries)
      entries = old_filter_entries_for_file_binder(entries).reject do |e|
        result = false
        if e =~ Jekyll::BOUND_FILE_MATCHER
          result = true
        end
        result
      end
    end

    alias_method :old_cleanup_for_file_binder, :cleanup
    def cleanup
      self.posts.each do |post|
        post.cleanup_bound_files
      end
      old_cleanup_for_file_binder
    end
  end

  module Convertible
    alias_method :old_do_layout_for_file_binder, :do_layout
    def do_layout(payload, layouts)
      self.site.me = self
      old_do_layout_for_file_binder(payload, layouts)
    end
  end

  class FileBinder < PostFilter
    def post_write(post)
      m, cats, date, slug, ext = *post.name.match(Post::MATCHER)
      find_filename = [cats, date, '-', slug, '_*'].join
      Dir[File.join(post.site.source, '_posts', find_filename)].each do |f|
        if f =~ Jekyll::BOUND_FILE_MATCHER
          src_path = f
          dest_dir = File.dirname(post.destination(post.site.dest))
          dest_filename = $4 + $5
          dest_path = File.join(dest_dir, dest_filename)
          FileUtils.cp(src_path, dest_path)
        end
      end
    end
  end

  class ImageTag
    alias_method :old_render_for_file_binder, :render
    def render(context)
      if @img['src'] =~ /^\.\/(.*)$/
        me = context.registers[:site].me
        if me.class == Jekyll::Post
          if ENV.has_key?('OCTOPRESS_ENV') && ENV['OCTOPRESS_ENV'] == 'preview'
            url = 'http://localhost:4000/'
          else
            url = context.registers[:site].config['url']
          end
          url = url[-1] == '/' ? url[0..-2] : url
          @img['src'] = url + me.url + $1
        end
      end
      old_render_for_file_binder(context)
rescue Exception => e
  p e.to_s
  p e.backtrace
end
    end
  end

end

