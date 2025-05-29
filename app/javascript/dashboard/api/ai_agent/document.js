/* global axios */
import ApiClient from '../ApiClient';

class AiAgentDocument extends ApiClient {
  constructor() {
    super('ai_agent/documents', { accountScoped: true });
  }

  get({ page = 1, searchKey, assistantId } = {}) {
    return axios.get(this.url, {
      params: {
        page,
        searchKey,
        assistant_id: assistantId,
      },
    });
  }
}

export default new AiAgentDocument();
