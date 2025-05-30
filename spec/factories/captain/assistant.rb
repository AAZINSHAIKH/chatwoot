FactoryBot.define do
  factory :captain_assistant, class: 'Captain::Topic' do
    sequence(:name) { |n| "Topic #{n}" }
    description { 'Test description' }
    association :account
  end
end
