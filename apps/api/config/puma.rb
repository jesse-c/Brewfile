# frozen_string_literal: true

require "fileutils"

workers Integer(ENV["WEB_CONCURRENCY"] || 2)
threads_count = Integer(ENV["RAILS_MAX_THREADS"] || 5)
threads threads_count, threads_count

port ENV["PORT"] || 3000
environment ENV["RACK_ENV"] || "development"

app_dir = File.expand_path("..", __dir__)

pid_dir = File.join(app_dir, "pids")

FileUtils.mkdir_p(pid_dir)

pidfile File.join(pid_dir, "puma.pid")

preload_app!
