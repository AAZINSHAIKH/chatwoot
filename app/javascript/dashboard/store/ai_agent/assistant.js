import AiAgentAssistantAPI from 'dashboard/api/ai_agent/assistant';
import { createStore } from './storeFactory';

export default createStore({
  name: 'AiAgentAssistant',
  API: AiAgentAssistantAPI,
});
