# frozen_string_literal: true

require "pathname"
require_relative "../homebrew-bundle/lib/bundle/dsl"

# Brewer operates on a collection of Brewfiles, allowing you to list, search,
# and generate new ones.
class Brewer
  EXTENSION = ".brewfile"
  DEFAULT_PATH = Pathname.new("./lib/brewfiles/")

  def initialize
    @brewfiles = load_brewfiles(DEFAULT_PATH)
  end

  def present(brewfiles, format = "text")
    case format
    when "json"
      require "json"
      brewfiles.to_json
    else
      brewfiles.join("\n")
    end
  end

  def list
    @brewfiles.keys
              .map { |path| strip_ext path.basename }
              .sort
  end

  def search(queries)
    filter(queries)
      .keys
      .map { |path| strip_ext path }
      .sort
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def generate(queries)
    sources = match(queries)

    names = sources.keys
                   .map { |path| strip_ext path.basename }
                   .sort
                   .join(", ")
                   .strip

    byline = ["# brewfile.io", "# Generated from #{names}", ""]

    brewfiles = sources.map { |_, b| b.entries }
                       .flatten
                       .map { |e| entry_to_s(e).strip }
                       .sort

    byline + brewfiles
  end

  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

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

  def strip_ext(file)
    File.basename(file, File.extname(file))
  end

  def filter(queries)
    @brewfiles.select do |path, _|
      path = strip_ext path.basename.to_s.downcase

      queries.any? { |query| path.include?(query.downcase) }
    end
  end

  def match(queries)
    @brewfiles.select do |path, _|
      path = strip_ext path.basename.to_s.downcase

      queries.any? { |query| path == query.downcase }
    end
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def entry_to_s(entry)
    case entry.type
    when :brew
      "brew install #{entry.name} #{entry.options.fetch(:args, []).map { |arg| "--#{arg}" }.join(" ")}"
    when :cask
      "brew cask install #{entry.name} #{entry.options.fetch(:args, []).map { |arg| "--#{arg}" }.join(" ")}"
    when :mac_app_store
      "mas install #{entry.options[:id]}"
    when :tap
      "brew tap #{entry.name} #{entry.options[:clone_target]}"
    else
      raise "unknown entry type: #{entry.type}"
    end
  end

  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
