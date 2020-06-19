app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

pidfile "#{shared_dir}/pids/puma.pid"

rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

stdout_redirect "#{shared_dir}/logs/puma.stdout.log", "#{shared_dir}/logs/puma.stderr.log", true
