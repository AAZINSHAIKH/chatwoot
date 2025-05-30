class Captain::Tools::FirecrawlParserJob < ApplicationJob
  queue_as :low

  def perform(topic_id:, payload:)
    assistant = Captain::Topic.find(topic_id)
    metadata = payload[:metadata]

    document = assistant.documents.find_or_initialize_by(
      external_link: metadata['url']
    )

    document.update!(
      content: payload[:markdown],
      name: metadata['title'],
      status: :available
    )
  rescue StandardError => e
    raise "Failed to parse FireCrawl data: #{e.message}"
  end
end
