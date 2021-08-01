# Definitions
app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

rails_env = ENV.fetch("RAILS_ENV") { "production" }
workers_count = ENV.fetch("WEB_CONCURRENCY") { 2 }
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }


# Change to match your CPU core count
workers workers_count

# Min and Max threads per worker
threads min_threads_count, max_threads_count

# Socket location
bind "unix://#{shared_dir}/sockets/puma.sock"

# Environment
environment rails_env

# Logging
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Primary PID and state locations
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
activate_control_app

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
end
