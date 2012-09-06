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
# License:
# --------
# Distributed under the [MIT License][MIT].
#
# [MIT]: http://www.opensource.org/licenses/mit-license.php
#

require './plugins/post_filters.rb'

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
    alias_method :old_filter_entries, :filter_entries
    def filter_entries(entries)
      entries = old_filter_entries(entries).reject do |e|
        result = false
        if e =~ Jekyll::BOUND_FILE_MATCHER
          result = true
        end
        result
      end
    end

    alias_method :old_cleanup, :cleanup
    def cleanup
      self.posts.each do |post|
        post.cleanup_bound_files
      end
      old_cleanup
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

end

