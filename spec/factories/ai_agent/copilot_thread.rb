FactoryBot.define do
  factory :ai_agent_copilot_thread, class: 'CopilotThread' do
    account
    user
    title { Faker::Lorem.sentence }
    assistant { create(:ai_agent_assistant, account: account) }
  end
end
