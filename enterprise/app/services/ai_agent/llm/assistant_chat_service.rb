require 'openai'

class AiAgent::Llm::AssistantChatService < Llm::BaseOpenAiService
  include AiAgent::ChatHelper

  def initialize(assistant: nil)
    super()

    @assistant = assistant
    @messages = [system_message]
    @response = ''
    register_tools
  end

  def generate_response(input, previous_messages = [], role = 'user')
    @messages += previous_messages
    @messages << { role: role, content: input } if input.present?
    request_chat_completion
  end

  private

  def register_tools
    @tool_registry = AiAgent::ToolRegistryService.new(@assistant, user: nil)
    @tool_registry.register_tool(AiAgent::Tools::SearchDocumentationService)
  end

  def system_message
    {
      role: 'system',
      content: AiAgent::Llm::SystemPromptsService.assistant_response_generator(@assistant.name, @assistant.config['product_name'], @assistant.config)
    }
  end

  def persist_message(message, message_type = 'assistant')
    # No need to implement
  end
end
