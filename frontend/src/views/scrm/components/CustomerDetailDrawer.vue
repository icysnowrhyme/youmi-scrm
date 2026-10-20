<template>
  <el-drawer v-model="visible" :with-header="false" size="680px" destroy-on-close>
    <div v-loading="loading" class="detail">
      <template v-if="detail">
        <header class="detail__header">
          <div class="detail__avatar">{{ initials }}</div>
          <div class="detail__identity">
            <div class="detail__name-row">
              <h2>{{ detail.name }}</h2>
              <el-tag :type="optionType(CUSTOMER_LEVELS, detail.level)" effect="dark" size="small">
                {{ optionLabel(CUSTOMER_LEVELS, detail.level) }}
              </el-tag>
              <el-tag :type="optionType(CUSTOMER_STATUSES, detail.status)" effect="plain" size="small">
                {{ optionLabel(CUSTOMER_STATUSES, detail.status) }}
              </el-tag>
            </div>
            <p>{{ detail.company || "暂未填写公司" }}<span v-if="detail.position"> · {{ detail.position }}</span></p>
          </div>
          <el-button class="detail__close" circle text @click="visible = false">
            <el-icon><Close /></el-icon>
          </el-button>
        </header>

        <div class="detail__stats">
          <div>
            <span>商机金额</span>
            <strong>¥ {{ formatCompactMoney(opportunityAmount) }}</strong>
          </div>
          <div>
            <span>合同金额</span>
            <strong>¥ {{ formatCompactMoney(contractAmount) }}</strong>
          </div>
          <div>
            <span>跟进次数</span>
            <strong>{{ followUps.length }}</strong>
          </div>
          <div>
            <span>负责销售</span>
            <strong>{{ detail.ownerName || "公海未分配" }}</strong>
          </div>
        </div>

        <section class="detail__section">
          <div class="detail__section-title">客户信息</div>
          <el-descriptions :column="2" size="small">
            <el-descriptions-item label="联系电话">{{ detail.phone || "-" }}</el-descriptions-item>
            <el-descriptions-item label="微信">{{ detail.wechat || "-" }}</el-descriptions-item>
            <el-descriptions-item label="邮箱">{{ detail.email || "-" }}</el-descriptions-item>
            <el-descriptions-item label="来源">{{ optionLabel(CUSTOMER_SOURCES, detail.source) }}</el-descriptions-item>
            <el-descriptions-item label="行业">{{ detail.industry || "-" }}</el-descriptions-item>
            <el-descriptions-item label="创建人">{{ detail.creatorName || "-" }}</el-descriptions-item>
            <el-descriptions-item label="最近跟进">{{ formatDateTime(detail.lastFollowTime) }}</el-descriptions-item>
            <el-descriptions-item label="下次跟进">{{ formatDateTime(detail.nextFollowTime) }}</el-descriptions-item>
            <el-descriptions-item :span="2" label="地址">{{ detail.address || "-" }}</el-descriptions-item>
            <el-descriptions-item :span="2" label="备注">{{ detail.remark || "-" }}</el-descriptions-item>
          </el-descriptions>
          <div v-if="detail.tags?.length" class="detail__tags">
            <el-tag
              v-for="tag in detail.tags"
              :key="tag.id"
              :style="{ color: tag.color, borderColor: tag.color, background: `${tag.color}14` }"
              effect="plain"
            >
              {{ tag.name }}
            </el-tag>
          </div>
        </section>

        <el-tabs v-model="activeTab" class="detail__tabs">
          <el-tab-pane :label="`跟进记录 ${followUps.length}`" name="follow">
            <template #label>
              <span class="tab-label">跟进记录 <em>{{ followUps.length }}</em></span>
            </template>
            <div v-if="!poolMode" class="tab-actions">
              <el-button type="primary" plain size="small" @click="followDialog = true">
                <el-icon><ChatDotRound /></el-icon>
                记录跟进
              </el-button>
            </div>
            <el-timeline v-if="followUps.length" class="follow-timeline">
              <el-timeline-item
                v-for="item in followUps"
                :key="item.id"
                :timestamp="formatDateTime(item.createTime)"
                placement="top"
                :type="optionType(FOLLOW_UP_TYPES, item.type) === 'info' ? 'primary' : (optionType(FOLLOW_UP_TYPES, item.type) as any)"
              >
                <div class="follow-card">
                  <div class="follow-card__head">
                    <el-tag size="small" effect="plain">{{ optionLabel(FOLLOW_UP_TYPES, item.type) }}</el-tag>
                    <span>{{ item.creatorName }}</span>
                  </div>
                  <p class="follow-card__content">{{ item.content }}</p>
                  <p v-if="item.result" class="follow-card__result">结果：{{ item.result }}</p>
                  <p v-if="item.nextFollowTime" class="follow-card__next">
                    下次跟进：{{ formatDateTime(item.nextFollowTime) }}
                  </p>
                </div>
              </el-timeline-item>
            </el-timeline>
            <el-empty v-else description="还没有跟进记录" :image-size="80" />
          </el-tab-pane>

          <el-tab-pane name="opportunity">
            <template #label>
              <span class="tab-label">商机 <em>{{ opportunities.length }}</em></span>
            </template>
            <div v-if="opportunities.length" class="mini-list">
              <div v-for="item in opportunities" :key="item.id" class="mini-card">
                <div class="mini-card__main">
                  <strong>{{ item.name }}</strong>
                  <span>{{ optionLabel(OPPORTUNITY_STAGES, item.stage) }}</span>
                </div>
                <div class="mini-card__meta">
                  <span>¥ {{ formatCompactMoney(item.amount) }}</span>
                  <span>预计成交 {{ formatDate(item.expectedCloseDate) }}</span>
                </div>
                <el-progress :percentage="item.probability ?? 0" :stroke-width="6" />
              </div>
            </div>
            <el-empty v-else description="暂无关联商机" :image-size="80" />
          </el-tab-pane>

          <el-tab-pane name="contract">
            <template #label>
              <span class="tab-label">合同 <em>{{ contracts.length }}</em></span>
            </template>
            <div v-if="contracts.length" class="mini-list">
              <div v-for="item in contracts" :key="item.id" class="mini-card">
                <div class="mini-card__main">
                  <strong>{{ item.name }}</strong>
                  <el-tag size="small" :type="optionType(CONTRACT_STATUSES, item.status)">
                    {{ optionLabel(CONTRACT_STATUSES, item.status) }}
                  </el-tag>
                </div>
                <div class="mini-card__meta">
                  <span>¥ {{ formatMoney(item.amount) }}</span>
                  <span>{{ item.contractNo }}</span>
                </div>
                <div class="mini-card__meta">
                  <span>签署 {{ formatDate(item.signDate) }}</span>
                  <span>{{ formatDate(item.startDate) }} ~ {{ formatDate(item.endDate) }}</span>
                </div>
              </div>
            </div>
            <el-empty v-else description="暂无关联合同" :image-size="80" />
          </el-tab-pane>
        </el-tabs>
      </template>
    </div>

    <FollowUpDialog
      v-if="detail"
      v-model="followDialog"
      :customer-id="detail.id"
      :customer-name="detail.name"
      @saved="loadAll"
    />
  </el-drawer>
</template>

<script setup lang="ts">
import { ContractAPI, CustomerAPI, FollowUpAPI, OpportunityAPI } from "@/api/scrm";
import type { ContractItem, CustomerDetail, FollowUpItem, OpportunityItem } from "@/api/scrm/types";
import { formatCompactMoney, formatDate, formatDateTime, formatMoney } from "@/utils/format";
import {
  CONTRACT_STATUSES,
  CUSTOMER_LEVELS,
  CUSTOMER_SOURCES,
  CUSTOMER_STATUSES,
  FOLLOW_UP_TYPES,
  OPPORTUNITY_STAGES,
  optionLabel,
  optionType,
} from "../constants";
import FollowUpDialog from "./FollowUpDialog.vue";

const props = defineProps<{
  customerId?: string | number;
  poolMode?: boolean;
}>();

const emit = defineEmits<{ updated: [] }>();

const visible = defineModel<boolean>({ default: false });

const loading = ref(false);
const detail = ref<CustomerDetail>();
const followUps = ref<FollowUpItem[]>([]);
const opportunities = ref<OpportunityItem[]>([]);
const contracts = ref<ContractItem[]>([]);
const activeTab = ref("follow");
const followDialog = ref(false);

const initials = computed(() => (detail.value?.name || "客").slice(0, 1));
const opportunityAmount = computed(() =>
  opportunities.value.filter((item) => item.stage !== 6).reduce((sum, item) => sum + Number(item.amount || 0), 0)
);
const contractAmount = computed(() =>
  contracts.value
    .filter((item) => item.status === 2 || item.status === 3)
    .reduce((sum, item) => sum + Number(item.amount || 0), 0)
);

watch(
  () => visible.value,
  (open) => {
    if (open) {
      activeTab.value = "follow";
      loadAll();
    }
  },
  { immediate: true }
);

async function loadAll() {
  if (!props.customerId) return;
  loading.value = true;
  try {
    const [customer, follows, opps, contractList] = await Promise.all([
      CustomerAPI.getDetail(props.customerId),
      FollowUpAPI.listByCustomer(props.customerId),
      OpportunityAPI.listByCustomer(props.customerId),
      ContractAPI.listByCustomer(props.customerId),
    ]);
    detail.value = customer;
    followUps.value = follows;
    opportunities.value = opps;
    contracts.value = contractList;
    emit("updated");
  } finally {
    loading.value = false;
  }
}
</script>

<style scoped>
.detail {
  min-height: 200px;
  padding: 4px 4px 24px;
}

.detail__header {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 8px 4px 20px;
}

.detail__avatar {
  display: grid;
  width: 56px;
  height: 56px;
  flex: none;
  place-items: center;
  color: #fff;
  font-size: 24px;
  font-weight: 600;
  border-radius: 16px;
  background: linear-gradient(135deg, #2563eb, #06b6d4);
}

.detail__identity {
  flex: 1;
  min-width: 0;
}

.detail__identity p {
  margin: 6px 0 0;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.detail__name-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
}

.detail__name-row h2 {
  margin: 0;
  font-size: 20px;
}

.detail__close {
  align-self: flex-start;
}

.detail__stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 20px;
}

.detail__stats div {
  display: flex;
  padding: 12px 14px;
  flex-direction: column;
  gap: 6px;
  border-radius: 12px;
  background: var(--el-fill-color-lighter);
}

.detail__stats span {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.detail__stats strong {
  font-size: 16px;
}

.detail__section {
  padding: 16px 18px;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 14px;
}

.detail__section-title {
  margin-bottom: 12px;
  font-weight: 600;
}

.detail__tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 12px;
}

.detail__tabs {
  margin-top: 18px;
}

.tab-label em {
  margin-left: 4px;
  padding: 0 6px;
  color: var(--el-text-color-secondary);
  font-size: 12px;
  font-style: normal;
  border-radius: 8px;
  background: var(--el-fill-color);
}

.tab-actions {
  margin-bottom: 14px;
}

.follow-timeline {
  padding-left: 4px;
}

.follow-card {
  padding: 12px 14px;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 12px;
  background: var(--el-bg-color);
}

.follow-card__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.follow-card__content {
  margin: 8px 0 0;
  color: var(--el-text-color-primary);
  line-height: 1.6;
}

.follow-card__result,
.follow-card__next {
  margin: 6px 0 0;
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.mini-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.mini-card {
  display: flex;
  padding: 14px;
  flex-direction: column;
  gap: 10px;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 12px;
}

.mini-card__main,
.mini-card__meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.mini-card__main span {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.mini-card__meta {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

@media (max-width: 720px) {
  .detail__stats {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
