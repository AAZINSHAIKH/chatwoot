FactoryBot.define do
  factory :ai_agent_inbox, class: 'AiAgentInbox' do
    association :ai_agent_assistant, factory: :ai_agent_assistant
    association :inbox
  end
end
