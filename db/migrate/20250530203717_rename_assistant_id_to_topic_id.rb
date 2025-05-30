# db/migrate/20250530203717_rename_assistant_id_to_topic_id.rb
class RenameAssistantIdToTopicId < ActiveRecord::Migration[7.0]
  def change
    # Rename the foreign-key columns
    rename_column :ai_agent_responses,   :assistant_id, :topic_id
    rename_column :ai_agent_documents,   :assistant_id, :topic_id
    rename_column :copilot_threads,      :assistant_id, :topic_id
    rename_column :ai_agent_inboxes,     :ai_agent_id,  :ai_agent_topic_id

    # Rename the two indexes, if they still exist
    if index_exists?(:ai_agent_responses, :assistant_id)
      rename_index :ai_agent_responses,
                   'index_ai_agent_responses_on_assistant_id',
                   'index_ai_agent_responses_on_topic_id'
    end

    return unless index_exists?(:ai_agent_documents, :assistant_id)

    rename_index :ai_agent_documents,
                 'index_ai_agent_documents_on_assistant_id',
                 'index_ai_agent_documents_on_topic_id'
  end
end
