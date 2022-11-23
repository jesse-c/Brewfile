# frozen_string_literal: true

on_worker_boot do
end

before_fork do
end

workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

port        ENV['PORT']     || 9292
environment ENV['RACK_ENV'] || 'development'

app_dir = File.expand_path('..', __dir__)
shared_dir = "#{app_dir}/shared"

pidfile "#{shared_dir}/pids/puma.pid"

stdout_redirect "#{shared_dir}/logs/puma.stdout.log", "#{shared_dir}/logs/puma.stderr.log", true

preload_app!
