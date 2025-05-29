class RemoveIndexFromAiAgentAssistants < ActiveRecord::Migration[7.0]
  def change
    remove_index :ai_agent_assistants, [:account_id, :name], if_exists: true
  end
end
