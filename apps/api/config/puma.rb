# frozen_string_literal: true

require 'fileutils'

on_worker_boot do
end

before_fork do
end

workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

app_dir = File.expand_path('..', __dir__)

shared_dir = File.join(app_dir, "shared")
pid_dir = File.join(app_dir, "pids")
logs_dir = File.join(app_dir, "logs")

FileUtils.mkdir_p(shared_dir)
FileUtils.mkdir_p(pid_dir)
FileUtils.mkdir_p(logs_dir)

pidfile File.join(pid_dir, "puma.pid")

stdout_redirect File.join(logs_dir, "puma.stdout.log"), File.join(logs_dir, "puma.stderr.log"), true

preload_app!
