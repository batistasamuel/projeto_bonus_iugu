require "sidekiq/web"
require "sidekiq/cron/web"
require "securerandom"


Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == "projetobonus" && password == Rails.application.credentials.dig(:sidekiq, :password)
  end

  File.open(".session.key", "w") {|f| f.write(SecureRandom.hex(32)) }
  Sidekiq::Web.use Rack::Session::Cookie, secret: File.read(".session.key"), same_site: true, max_age: 86400

  mount Sidekiq::Web => "/sidekiq"
end
