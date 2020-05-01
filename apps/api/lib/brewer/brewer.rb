# frozen_string_literal: true

require 'pathname'
require_relative '../homebrew-bundle/lib/bundle/dsl'

# Brewer operates on a collection of Brewfiles, allowing you to list, search,
# and generate new ones.
class Brewer
  EXTENSION = '.brewfile'
  DEFAULT_PATH = Pathname.new('./lib/brewfiles/')

  def initialize
    @brewfiles = load_brewfiles(DEFAULT_PATH)
  end

  def list
    @brewfiles.keys
              .map { |path| strip_ext path.basename }
              .join("\n")
  end

  def search(queries)
    filter(queries)
      .keys
      .map { |path| strip_ext path }
      .join("\n")
  end

  def generate(queries)
    sources = filter(queries)

    names = sources.keys
                   .map { |path| strip_ext path.basename }
                   .join(', ')
                   .strip

    byline = "# brewfile.io\n# Generated from #{names}\n\n"

    sources.map { |_, b| b.entries }
           .flatten
           .sort_by { |a, _b| a.type == :tap ? -1 : 0 }
           .map { |e| entry_to_s(e) }
           .join("\n")
           .strip
           .prepend byline
  end

  private

  def load_brewfiles(root_path)
    @paths = Dir.entries(root_path)
                .select { |e| File.extname(e) == EXTENSION }
                .map { |e| Pathname.new(e) }

    @paths.each_with_object({}) do |path, collection|
      content = root_path
                .join(path)
                .expand_path
                .read

      collection[path] = Bundle::Dsl.new(content)
    end
  end

  def strip_ext(f)
    File.basename(f, File.extname(f))
  end

  def filter(queries)
    @brewfiles.select do |path, _|
      path = strip_ext path.basename.to_s.downcase

      queries.any? { |query| path.include?(query.downcase) }
    end
  end

  def entry_to_s(entry)
    case entry.type
    when :brew
      "brew install #{entry.name} #{entry.options.fetch(:args, []).map { |arg| "--#{arg}" }.join(' ')}"
    when :cask
      "brew cask install #{entry.name} #{entry.options.fetch(:args, []).map { |arg| "--#{arg}" }.join(' ')}"
    when :mac_app_store
      "mas install #{entry.options[:id]}"
    when :tap
      "brew tap #{entry.name} #{entry.options[:clone_target]}"
    else
      raise "unknown entry type: #{entry.type}"
    end
  end
end
