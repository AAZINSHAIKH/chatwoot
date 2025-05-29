class AddConfigToAiAgentAssistant < ActiveRecord::Migration[7.0]
  def change
    add_column :ai_agent_assistants, :config, :jsonb, default: {}, null: false
  end
end
