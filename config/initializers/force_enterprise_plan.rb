# frozen_string_literal: true

# Force enterprise plan and quota via code

Rails.application.config.to_prepare do
  begin
    plan_config = InstallationConfig.find_or_initialize_by(name: 'INSTALLATION_PRICING_PLAN')
    plan_config.value = 'enterprise'
    plan_config.locked = true
    plan_config.save!

    qty_config = InstallationConfig.find_or_initialize_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY')
    qty_config.value = 1000
    qty_config.locked = true
    qty_config.save!
  rescue StandardError => e
    Rails.logger.error("Failed to enforce enterprise plan: #{e.message}")
  end

  # Ensure application code always reads the forced values
  class << ChatwootHub
    def pricing_plan
      'enterprise'
    end

    def pricing_plan_quantity
      1000
    end
  end
end


