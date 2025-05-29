import { computed } from 'vue';
import { useStore } from 'dashboard/composables/store.js';
import { useAccount } from 'dashboard/composables/useAccount';
import { useCamelCase } from 'dashboard/composables/useTransformKeys';
import { FEATURE_FLAGS } from 'dashboard/featureFlags';

export function useAiAgent() {
  const store = useStore();
  const { isCloudFeatureEnabled, currentAccount } = useAccount();

  const ai_agentEnabled = computed(() => {
    return isCloudFeatureEnabled(FEATURE_FLAGS.AI_AGENT);
  });

  const ai_agentLimits = computed(() => {
    return currentAccount.value?.limits?.ai_agent;
  });

  const documentLimits = computed(() => {
    if (ai_agentLimits.value?.documents) {
      return useCamelCase(ai_agentLimits.value.documents);
    }

    return null;
  });

  const responseLimits = computed(() => {
    if (ai_agentLimits.value?.responses) {
      return useCamelCase(ai_agentLimits.value.responses);
    }

    return null;
  });

  const fetchLimits = () => {
    store.dispatch('accounts/limits');
  };

  return {
    ai_agentEnabled,
    ai_agentLimits,
    documentLimits,
    responseLimits,
    fetchLimits,
  };
}
