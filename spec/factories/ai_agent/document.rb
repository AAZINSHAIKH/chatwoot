FactoryBot.define do
  factory :ai_agent_document, class: 'AiAgent::Document' do
    name { Faker::File.file_name }
    external_link { Faker::Internet.unique.url }
    content { Faker::Lorem.paragraphs.join("\n\n") }
    association :assistant, factory: :ai_agent_assistant
    association :account
  end
end
