schedule_file = "config/schedule.yml"
redis_url = ENV.fetch("REDIS_URL") { Rails.application.credentials.dig(:redis, :url) }

Redis.exists_returns_integer = false

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

# if File.exist?(schedule_file) && Sidekiq.server?
#   Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
# end