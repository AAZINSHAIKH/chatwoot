<script setup>
import { computed, onMounted, ref, nextTick } from 'vue';
import { useMapGetter, useStore } from 'dashboard/composables/store';
import { FEATURE_FLAGS } from 'dashboard/featureFlags';

import DeleteDialog from 'dashboard/components-next/ai_agent/pageComponents/DeleteDialog.vue';
import DocumentCard from 'dashboard/components-next/ai_agent/assistant/DocumentCard.vue';
import PageLayout from 'dashboard/components-next/ai_agent/PageLayout.vue';
import AiAgentPaywall from 'dashboard/components-next/ai_agent/pageComponents/Paywall.vue';
import RelatedResponses from 'dashboard/components-next/ai_agent/pageComponents/document/RelatedResponses.vue';
import CreateDocumentDialog from 'dashboard/components-next/ai_agent/pageComponents/document/CreateDocumentDialog.vue';
import AssistantSelector from 'dashboard/components-next/ai_agent/pageComponents/AssistantSelector.vue';
import DocumentPageEmptyState from 'dashboard/components-next/ai_agent/pageComponents/emptyStates/DocumentPageEmptyState.vue';
import FeatureSpotlightPopover from 'dashboard/components-next/feature-spotlight/FeatureSpotlightPopover.vue';
import LimitBanner from 'dashboard/components-next/ai_agent/pageComponents/document/LimitBanner.vue';

const store = useStore();

const uiFlags = useMapGetter('ai_agentDocuments/getUIFlags');
const documents = useMapGetter('ai_agentDocuments/getRecords');
const assistants = useMapGetter('ai_agentAssistants/getRecords');
const isFetching = computed(() => uiFlags.value.fetchingList);
const documentsMeta = useMapGetter('ai_agentDocuments/getMeta');
const selectedAssistant = ref('all');

const selectedDocument = ref(null);
const deleteDocumentDialog = ref(null);

const handleDelete = () => {
  deleteDocumentDialog.value.dialogRef.open();
};

const showRelatedResponses = ref(false);
const showCreateDialog = ref(false);
const createDocumentDialog = ref(null);
const relationQuestionDialog = ref(null);

const shouldShowAssistantSelector = computed(() => {
  if (assistants.value.length === 0) return false;

  return !isFetching.value;
});

const handleShowRelatedDocument = () => {
  showRelatedResponses.value = true;
  nextTick(() => relationQuestionDialog.value.dialogRef.open());
};
const handleCreateDocument = () => {
  showCreateDialog.value = true;
  nextTick(() => createDocumentDialog.value.dialogRef.open());
};

const handleRelatedResponseClose = () => {
  showRelatedResponses.value = false;
};

const handleCreateDialogClose = () => {
  showCreateDialog.value = false;
};

const handleAction = ({ action, id }) => {
  selectedDocument.value = documents.value.find(
    ai_agentDocument => id === ai_agentDocument.id
  );

  nextTick(() => {
    if (action === 'delete') {
      handleDelete();
    } else if (action === 'viewRelatedQuestions') {
      handleShowRelatedDocument();
    }
  });
};

const fetchDocuments = (page = 1) => {
  const filterParams = { page };

  if (selectedAssistant.value !== 'all') {
    filterParams.assistantId = selectedAssistant.value;
  }
  store.dispatch('ai_agentDocuments/get', filterParams);
};

const handleAssistantFilterChange = assistant => {
  selectedAssistant.value = assistant;
  fetchDocuments();
};

const onPageChange = page => fetchDocuments(page);

const onDeleteSuccess = () => {
  if (documents.value?.length === 0 && documentsMeta.value?.page > 1) {
    onPageChange(documentsMeta.value.page - 1);
  }
};

onMounted(() => {
  if (!assistants.value.length) {
    store.dispatch('ai_agentAssistants/get');
  }
  fetchDocuments();
});
</script>

<template>
  <PageLayout
    :header-title="$t('AI_AGENT.DOCUMENTS.HEADER')"
    :button-label="$t('AI_AGENT.DOCUMENTS.ADD_NEW')"
    :button-policy="['administrator']"
    :total-count="documentsMeta.totalCount"
    :current-page="documentsMeta.page"
    :show-pagination-footer="!isFetching && !!documents.length"
    :is-fetching="isFetching"
    :is-empty="!documents.length"
    :feature-flag="FEATURE_FLAGS.AI_AGENT"
    @update:current-page="onPageChange"
    @click="handleCreateDocument"
  >
    <template #knowMore>
      <FeatureSpotlightPopover
        :button-label="$t('AI_AGENT.HEADER_KNOW_MORE')"
        :title="$t('AI_AGENT.DOCUMENTS.EMPTY_STATE.FEATURE_SPOTLIGHT.TITLE')"
        :note="$t('AI_AGENT.DOCUMENTS.EMPTY_STATE.FEATURE_SPOTLIGHT.NOTE')"
        fallback-thumbnail="/assets/images/dashboard/ai_agent/document-popover-light.svg"
        fallback-thumbnail-dark="/assets/images/dashboard/ai_agent/document-popover-dark.svg"
        learn-more-url="https://chwt.app/ai_agent-document"
      />
    </template>

    <template #emptyState>
      <DocumentPageEmptyState @click="handleCreateDocument" />
    </template>

    <template #paywall>
      <AiAgentPaywall />
    </template>

    <template #controls>
      <div v-if="shouldShowAssistantSelector" class="mb-4 -mt-3 flex gap-3">
        <AssistantSelector
          :assistant-id="selectedAssistant"
          @update="handleAssistantFilterChange"
        />
      </div>
    </template>

    <template #body>
      <LimitBanner class="mb-5" />

      <div class="flex flex-col gap-4">
        <DocumentCard
          v-for="doc in documents"
          :id="doc.id"
          :key="doc.id"
          :name="doc.name || doc.external_link"
          :external-link="doc.external_link"
          :assistant="doc.assistant"
          :created-at="doc.created_at"
          @action="handleAction"
        />
      </div>
    </template>

    <RelatedResponses
      v-if="showRelatedResponses"
      ref="relationQuestionDialog"
      :ai_agent-document="selectedDocument"
      @close="handleRelatedResponseClose"
    />
    <CreateDocumentDialog
      v-if="showCreateDialog"
      ref="createDocumentDialog"
      @close="handleCreateDialogClose"
    />
    <DeleteDialog
      v-if="selectedDocument"
      ref="deleteDocumentDialog"
      :entity="selectedDocument"
      type="Documents"
      @delete-success="onDeleteSuccess"
    />
  </PageLayout>
</template>
