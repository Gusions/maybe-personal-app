require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Maybe
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # This fork ships only in Italian: UI, mail e modelli parlano esclusivamente italiano.
    # Nota: NON restringiamo `config.i18n.available_locales` qui, perché alcuni
    # componenti (es. Money::Formatting) usano deliberatamente altri simboli di
    # locale (:nl, :pt, :en...) per convenzioni di formattazione numerica,
    # indipendenti dalla lingua dell'interfaccia. Il vincolo "solo italiano" per
    # la UI è applicato a livello di modello (vedi Family#locale).
    config.i18n.default_locale = :it
    config.i18n.fallbacks = true

    config.app_mode = (ENV["SELF_HOSTED"] == "true" || ENV["SELF_HOSTING_ENABLED"] == "true" ? "self_hosted" : "managed").inquiry

    # Self hosters can optionally set their own encryption keys if they want to use ActiveRecord encryption.
    if Rails.application.credentials.active_record_encryption.present?
      config.active_record.encryption = Rails.application.credentials.active_record_encryption
    end

    config.view_component.preview_controller = "LookbooksController"
    config.lookbook.preview_display_options = {
      theme: [ "light", "dark" ] # available in view as params[:theme]
    }

    # Enable Rack::Attack middleware for API rate limiting
    config.middleware.use Rack::Attack
  end
end
