<template>
  <div v-loading="loading" class="workbench">
    <section class="hero">
      <div class="hero__content">
        <span class="hero__eyebrow">SCRM · 客户经营工作台</span>
        <h1>{{ greeting }}，{{ userStore.userInfo.nickname || "销售伙伴" }}</h1>
        <p>
          {{ currentDate }} · 未来 7 天有
          <strong>{{ todoCustomers.length }}</strong>
          位客户需要跟进
        </p>
        <div class="hero__actions">
          <el-button type="primary" plain @click="router.push('/customer')">
            <el-icon><Plus /></el-icon>
            新建客户
          </el-button>
          <el-button plain @click="router.push('/sales/follow-up')">
            <el-icon><ChatDotRound /></el-icon>
            记录跟进
          </el-button>
          <el-select v-model="days" class="hero__days" size="default" @change="load">
            <el-option :value="7" label="近 7 天" />
            <el-option :value="30" label="近 30 天" />
            <el-option :value="90" label="近 90 天" />
          </el-select>
        </div>
      </div>
      <div class="hero__aside">
        <div class="hero-stat">
          <span>本月赢单率</span>
          <strong>{{ dashboard?.winRate ?? 0 }}<small>%</small></strong>
        </div>
        <div class="hero-stat">
          <span>客户公海</span>
          <strong>{{ dashboard?.poolCount ?? 0 }}<small> 位</small></strong>
        </div>
        <div class="hero-stat">
          <span>本月签约</span>
          <strong>{{ formatCompactMoney(dashboard?.contractAmount) }}</strong>
        </div>
      </div>
    </section>

    <section class="kpi-grid">
      <article v-for="card in kpiCards" :key="card.label" class="kpi-card">
        <div class="kpi-card__head">
          <span>{{ card.label }}</span>
          <span class="kpi-card__icon" :class="card.tone">
            <el-icon :size="18"><component :is="card.icon" /></el-icon>
          </span>
        </div>
        <strong class="kpi-card__value">{{ card.value }}</strong>
        <div class="kpi-card__foot">{{ card.hint }}</div>
      </article>
    </section>

    <section class="chart-grid">
      <article class="panel panel--wide">
        <header class="panel__head">
          <div>
            <h3>客户与跟进趋势</h3>
            <p>近 {{ days }} 天新增客户与销售跟进频次</p>
          </div>
          <span class="legend">
            <i class="legend__dot legend__dot--blue"></i>新增客户
            <i class="legend__dot legend__dot--cyan"></i>跟进次数
          </span>
        </header>
        <ECharts :options="trendOptions" height="286px" />
      </article>

      <article class="panel">
        <header class="panel__head">
          <div>
            <h3>客户来源</h3>
            <p>客户获取渠道分布</p>
          </div>
        </header>
        <ECharts :options="sourceOptions" height="286px" />
      </article>
    </section>

    <section class="chart-grid chart-grid--balanced">
      <article class="panel">
        <header class="panel__head">
          <div>
            <h3>销售阶段漏斗</h3>
            <p>商机数量与金额分布</p>
          </div>
        </header>
        <div class="funnel">
          <div v-for="stage in stageRows" :key="stage.value" class="funnel__row">
            <span class="funnel__label">{{ stage.label }}</span>
            <div class="funnel__track">
              <div
                class="funnel__bar"
                :style="{ width: `${stage.percent}%`, background: stage.color }"
              >
                <span>{{ stage.count }}</span>
              </div>
            </div>
            <span class="funnel__amount">¥ {{ formatCompactMoney(stage.amount) }}</span>
          </div>
          <el-empty v-if="!stageRows.length" description="暂无商机数据" :image-size="72" />
        </div>
      </article>

      <article class="panel">
        <header class="panel__head">
          <div>
            <h3>本月销售排行</h3>
            <p>按已签约合同金额统计</p>
          </div>
          <el-icon class="panel__trophy"><Trophy /></el-icon>
        </header>
        <div class="ranking">
          <div v-for="(item, index) in dashboard?.salesRanking ?? []" :key="item.ownerId ?? index" class="ranking__row">
            <span :class="['ranking__index', `ranking__index--${index + 1}`]">{{ index + 1 }}</span>
            <div class="ranking__main">
              <div class="ranking__name">
                <strong>{{ item.ownerName || "未分配" }}</strong>
                <span>¥ {{ formatMoney(item.amount) }}</span>
              </div>
              <div class="ranking__track">
                <span :style="{ width: rankPercent(item.amount) + '%' }"></span>
              </div>
            </div>
          </div>
          <el-empty
            v-if="!dashboard?.salesRanking?.length"
            description="本月还没有签约数据"
            :image-size="72"
          />
        </div>
      </article>
    </section>

    <section class="bottom-grid">
      <article class="panel">
        <header class="panel__head">
          <div>
            <h3>待跟进客户</h3>
            <p>按计划跟进时间排序，逾期客户优先处理</p>
          </div>
          <el-button link type="primary" @click="router.push('/customer')">查看全部</el-button>
        </header>
        <div class="todo-list">
          <div v-for="customer in todoCustomers" :key="customer.id" class="todo-item">
            <span class="todo-item__avatar">{{ customer.name?.slice(0, 1) }}</span>
            <div class="todo-item__body">
              <div class="todo-item__title">
                <strong>{{ customer.name }}</strong>
                <el-tag :type="optionType(CUSTOMER_LEVELS, customer.level)" effect="dark" size="small">
                  {{ customer.level || "-" }}
                </el-tag>
              </div>
              <small>{{ customer.company || "未填写公司" }}</small>
            </div>
            <div class="todo-item__side">
              <span :class="['todo-item__time', followTone(customer.nextFollowTime)]">
                {{ formatDateTime(customer.nextFollowTime) }}
              </span>
              <el-button link type="primary" size="small" @click="openFollow(customer)">跟进</el-button>
            </div>
          </div>
          <el-empty v-if="!todoCustomers.length" description="暂无待跟进客户" :image-size="72" />
        </div>
      </article>

      <article class="panel">
        <header class="panel__head">
          <div>
            <h3>最近动态</h3>
            <p>团队最新的客户跟进记录</p>
          </div>
        </header>
        <el-timeline v-if="recentFollowUps.length" class="activity">
          <el-timeline-item
            v-for="item in recentFollowUps"
            :key="item.id"
            :timestamp="formatDateTime(item.createTime)"
            placement="top"
          >
            <div class="activity__head">
              <strong>{{ item.customerName || "-" }}</strong>
              <el-tag size="small" effect="plain">{{ optionLabel(FOLLOW_UP_TYPES, item.type) }}</el-tag>
            </div>
            <p>{{ item.content }}</p>
            <small>{{ item.creatorName || "-" }} · {{ item.result || "持续跟进中" }}</small>
          </el-timeline-item>
        </el-timeline>
        <el-empty v-else description="暂无跟进动态" :image-size="72" />
      </article>
    </section>

    <FollowUpDialog v-model="followVisible" :customer-id="followCustomerId" @saved="load" />
  </div>
</template>

<script setup lang="ts">
import { useRouter } from "vue-router";
import { DashboardAPI } from "@/api/scrm";
import type { CustomerItem, DashboardData } from "@/api/scrm/types";
import { useUserStore } from "@/stores";
import {
  formatCompactMoney,
  formatDateTime,
  formatMoney,
} from "@/utils/format";
import {
  CUSTOMER_LEVELS,
  CUSTOMER_SOURCES,
  FOLLOW_UP_TYPES,
  OPPORTUNITY_STAGES,
  optionLabel,
  optionType,
} from "@/views/scrm/constants";
import FollowUpDialog from "@/views/scrm/components/FollowUpDialog.vue";

const router = useRouter();
const userStore = useUserStore();

const loading = ref(false);
const days = ref(30);
const dashboard = ref<DashboardData>();

const followVisible = ref(false);
const followCustomerId = ref<string | number>();

const currentDate = new Date().toLocaleDateString("zh-CN", {
  year: "numeric",
  month: "long",
  day: "numeric",
  weekday: "long",
});

const greeting = computed(() => {
  const hour = new Date().getHours();
  if (hour < 6) return "夜深了";
  if (hour < 9) return "早上好";
  if (hour < 12) return "上午好";
  if (hour < 14) return "中午好";
  if (hour < 18) return "下午好";
  return "晚上好";
});

const todoCustomers = computed(() => dashboard.value?.todoCustomers ?? []);
const recentFollowUps = computed(() => dashboard.value?.recentFollowUps ?? []);

const kpiCards = computed(() => [
  {
    label: "客户总数",
    value: dashboard.value?.customerTotal ?? "-",
    hint: `本月新增 ${dashboard.value?.customerNew ?? 0} 位客户`,
    icon: "User",
    tone: "tone-blue",
  },
  {
    label: "本月跟进",
    value: dashboard.value?.followUpCount ?? "-",
    hint: "持续跟进是成交的关键",
    icon: "ChatDotRound",
    tone: "tone-cyan",
  },
  {
    label: "在途商机金额",
    value: `¥ ${formatCompactMoney(dashboard.value?.opportunityAmount)}`,
    hint: "未赢单商机金额合计",
    icon: "TrendCharts",
    tone: "tone-amber",
  },
  {
    label: "本月合同金额",
    value: `¥ ${formatCompactMoney(dashboard.value?.contractAmount)}`,
    hint: `赢单率 ${dashboard.value?.winRate ?? 0}%`,
    icon: "Money",
    tone: "tone-green",
  },
]);

const trendOptions = computed(() => {
  const customerTrend = dashboard.value?.customerTrend ?? [];
  const followTrend = dashboard.value?.followTrend ?? [];
  return {
    tooltip: { trigger: "axis" },
    grid: { left: 36, right: 18, top: 24, bottom: 24 },
    xAxis: {
      type: "category",
      boundaryGap: false,
      data: customerTrend.map((item) => item.date.slice(5)),
      axisLine: { lineStyle: { color: "rgba(148, 163, 184, 0.35)" } },
      axisTick: { show: false },
      axisLabel: { color: "#94a3b8", fontSize: 11 },
    },
    yAxis: {
      type: "value",
      minInterval: 1,
      splitLine: { lineStyle: { color: "rgba(148, 163, 184, 0.16)" } },
      axisLabel: { color: "#94a3b8", fontSize: 11 },
    },
    series: [
      {
        name: "新增客户",
        type: "line",
        smooth: true,
        showSymbol: false,
        data: customerTrend.map((item) => item.count),
        lineStyle: { width: 2.5, color: "#2563eb" },
        itemStyle: { color: "#2563eb" },
        areaStyle: {
          color: {
            type: "linear",
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: "rgba(37, 99, 235, 0.22)" },
              { offset: 1, color: "rgba(37, 99, 235, 0.01)" },
            ],
          },
        },
      },
      {
        name: "跟进次数",
        type: "line",
        smooth: true,
        showSymbol: false,
        data: followTrend.map((item) => item.count),
        lineStyle: { width: 2.5, color: "#06b6d4" },
        itemStyle: { color: "#06b6d4" },
        areaStyle: {
          color: {
            type: "linear",
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: "rgba(6, 182, 212, 0.16)" },
              { offset: 1, color: "rgba(6, 182, 212, 0.01)" },
            ],
          },
        },
      },
    ],
  };
});

const sourceOptions = computed(() => {
  const stats = dashboard.value?.sourceStats ?? [];
  return {
    tooltip: { trigger: "item", formatter: "{b}<br/>{c} 位（{d}%）" },
    legend: {
      bottom: 0,
      left: "center",
      icon: "circle",
      itemWidth: 8,
      itemHeight: 8,
      textStyle: { color: "#94a3b8", fontSize: 12 },
    },
    color: ["#2563eb", "#06b6d4", "#f59e0b", "#8b5cf6", "#10b981", "#94a3b8"],
    series: [
      {
        type: "pie",
        radius: ["48%", "70%"],
        center: ["50%", "44%"],
        avoidLabelOverlap: true,
        itemStyle: { borderColor: "rgba(255,255,255,0.85)", borderWidth: 3, borderRadius: 6 },
        label: { show: false },
        emphasis: { label: { show: true, fontSize: 15, fontWeight: 600 } },
        data: stats.map((item) => ({
          name: optionLabel(CUSTOMER_SOURCES, Number(item.name)),
          value: item.value,
        })),
      },
    ],
  };
});

const stageRows = computed(() => {
  const stats = dashboard.value?.stageStats ?? [];
  const max = Math.max(...stats.map((item) => Number(item.count ?? 0)), 1);
  const colors: Record<number, string> = {
    1: "#94a3b8",
    2: "#3b82f6",
    3: "#f59e0b",
    4: "#ef4444",
    5: "#10b981",
    6: "#cbd5e1",
  };
  return stats.map((item) => {
    const count = Number(item.count ?? 0);
    return {
      value: item.stage,
      label: optionLabel(OPPORTUNITY_STAGES, item.stage),
      count,
      amount: item.amount,
      percent: Math.max(10, Math.round((count / max) * 100)),
      color: colors[item.stage ?? 0] ?? "#94a3b8",
    };
  });
});

const rankMax = computed(() =>
  Math.max(...(dashboard.value?.salesRanking ?? []).map((item) => Number(item.amount ?? 0)), 1)
);

onMounted(load);

async function load() {
  loading.value = true;
  try {
    dashboard.value = await DashboardAPI.get(days.value);
  } finally {
    loading.value = false;
  }
}

function rankPercent(amount?: number) {
  return Math.max(6, Math.round((Number(amount ?? 0) / rankMax.value) * 100));
}

function followTone(value?: string) {
  if (!value) return "";
  const time = new Date(value.replace(" ", "T")).getTime();
  if (Number.isNaN(time)) return "";
  const diff = time - Date.now();
  if (diff < 0) return "is-overdue";
  if (diff < 24 * 3600 * 1000) return "is-soon";
  return "";
}

function openFollow(customer: CustomerItem) {
  followCustomerId.value = customer.id;
  followVisible.value = true;
}
</script>

<style scoped>
.workbench {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding-bottom: 8px;
}

.hero {
  position: relative;
  display: flex;
  align-items: stretch;
  justify-content: space-between;
  gap: 24px;
  overflow: hidden;
  padding: 28px 30px;
  color: #f8fbff;
  border-radius: 18px;
  background:
    radial-gradient(circle at 88% 12%, rgba(56, 189, 248, 0.32), transparent 42%),
    radial-gradient(circle at 12% 88%, rgba(99, 102, 241, 0.28), transparent 48%),
    linear-gradient(118deg, #0f2a52 0%, #173f7a 52%, #0e7490 100%);
  box-shadow: 0 18px 40px rgb(15 42 82 / 22%);
}

.hero::after {
  position: absolute;
  top: -60px;
  right: -40px;
  width: 260px;
  height: 260px;
  content: "";
  border: 1px solid rgb(255 255 255 / 14%);
  border-radius: 50%;
}

.hero__content {
  position: relative;
  z-index: 1;
}

.hero__eyebrow {
  display: inline-flex;
  padding: 4px 10px;
  color: #d3ecff;
  font-size: 12px;
  letter-spacing: 0.08em;
  border: 1px solid rgb(255 255 255 / 22%);
  border-radius: 999px;
  background: rgb(255 255 255 / 10%);
}

.hero h1 {
  margin: 14px 0 8px;
  font-size: 26px;
  font-weight: 600;
  letter-spacing: 0.01em;
}

.hero p {
  margin: 0;
  color: #c8dcf3;
  font-size: 13px;
}

.hero p strong {
  color: #fff;
}

.hero__actions {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 22px;
}

.hero__actions :deep(.el-button) {
  color: #eaf5ff;
  border-color: rgb(255 255 255 / 34%);
  background: rgb(255 255 255 / 10%);
}

.hero__actions :deep(.el-button:hover) {
  color: #0f2a52;
  border-color: #fff;
  background: #fff;
}

.hero__days {
  width: 108px;
}

.hero__days :deep(.el-select__wrapper) {
  color: #eaf5ff;
  border: 1px solid rgb(255 255 255 / 34%);
  background: rgb(255 255 255 / 10%);
  box-shadow: none;
}

.hero__aside {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  gap: 28px;
  padding-left: 24px;
  border-left: 1px solid rgb(255 255 255 / 16%);
}

.hero-stat {
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-width: 80px;
}

.hero-stat span {
  color: #b9d2ec;
  font-size: 12px;
}

.hero-stat strong {
  font-size: 24px;
  font-weight: 600;
}

.hero-stat small {
  margin-left: 2px;
  font-size: 12px;
  font-weight: 400;
  opacity: 0.7;
}

.kpi-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
}

.kpi-card {
  padding: 18px 20px;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 16px;
  background: var(--el-bg-color);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.kpi-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 14px 28px rgb(15 23 42 / 7%);
}

.kpi-card__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.kpi-card__icon {
  display: grid;
  width: 34px;
  height: 34px;
  place-items: center;
  border-radius: 10px;
}

.tone-blue {
  color: #2563eb;
  background: #dbeafe;
}

.tone-cyan {
  color: #0891b2;
  background: #cffafe;
}

.tone-amber {
  color: #d97706;
  background: #fef3c7;
}

.tone-green {
  color: #059669;
  background: #d1fae5;
}

.kpi-card__value {
  display: block;
  margin-top: 12px;
  font-size: 28px;
  font-weight: 600;
  letter-spacing: 0.01em;
}

.kpi-card__foot {
  margin-top: 8px;
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.chart-grid {
  display: grid;
  grid-template-columns: minmax(0, 2fr) minmax(0, 1fr);
  gap: 16px;
}

.chart-grid--balanced {
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.bottom-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.25fr) minmax(0, 1fr);
  gap: 16px;
}

.panel {
  padding: 18px 20px;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 16px;
  background: var(--el-bg-color);
}

.panel__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 14px;
}

.panel__head h3 {
  margin: 0;
  font-size: 15px;
}

.panel__head p {
  margin: 5px 0 0;
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.panel__trophy {
  color: #f59e0b;
  font-size: 22px;
}

.legend {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--el-text-color-secondary);
  font-size: 12px;
  white-space: nowrap;
}

.legend__dot {
  width: 7px;
  height: 7px;
  margin-left: 8px;
  border-radius: 50%;
}

.legend__dot--blue {
  background: #2563eb;
}

.legend__dot--cyan {
  background: #06b6d4;
}

.funnel {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.funnel__row {
  display: grid;
  grid-template-columns: 72px minmax(0, 1fr) 92px;
  align-items: center;
  gap: 12px;
}

.funnel__label {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.funnel__track {
  overflow: hidden;
  height: 26px;
  border-radius: 8px;
  background: var(--el-fill-color-lighter);
}

.funnel__bar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  height: 100%;
  min-width: 34px;
  padding: 0 8px;
  color: #fff;
  font-size: 12px;
  font-weight: 600;
  border-radius: 8px;
  transition: width 0.4s ease;
}

.funnel__amount {
  color: var(--el-text-color-secondary);
  font-size: 12px;
  text-align: right;
}

.ranking {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.ranking__row {
  display: flex;
  align-items: center;
  gap: 12px;
}

.ranking__index {
  display: grid;
  width: 24px;
  height: 24px;
  flex: none;
  place-items: center;
  color: var(--el-text-color-secondary);
  font-size: 12px;
  font-weight: 600;
  border-radius: 8px;
  background: var(--el-fill-color-light);
}

.ranking__index--1 {
  color: #92400e;
  background: linear-gradient(135deg, #fde68a, #fbbf24);
}

.ranking__index--2 {
  color: #475569;
  background: linear-gradient(135deg, #e2e8f0, #cbd5e1);
}

.ranking__index--3 {
  color: #9a3412;
  background: linear-gradient(135deg, #fed7aa, #fdba74);
}

.ranking__main {
  flex: 1;
  min-width: 0;
}

.ranking__name {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 6px;
  font-size: 13px;
}

.ranking__name span {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.ranking__track {
  overflow: hidden;
  height: 6px;
  border-radius: 999px;
  background: var(--el-fill-color-lighter);
}

.ranking__track span {
  display: block;
  height: 100%;
  border-radius: 999px;
  background: linear-gradient(90deg, #2563eb, #06b6d4);
}

.todo-list,
.activity {
  display: flex;
  flex-direction: column;
}

.todo-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 11px 0;
  border-bottom: 1px dashed var(--el-border-color-lighter);
}

.todo-item:last-child {
  border-bottom: 0;
}

.todo-item__avatar {
  display: grid;
  width: 34px;
  height: 34px;
  flex: none;
  place-items: center;
  color: var(--el-color-primary);
  font-weight: 600;
  border-radius: 10px;
  background: var(--el-color-primary-light-9);
}

.todo-item__body {
  flex: 1;
  min-width: 0;
}

.todo-item__title {
  display: flex;
  align-items: center;
  gap: 8px;
}

.todo-item__body small {
  display: block;
  margin-top: 2px;
  overflow: hidden;
  color: var(--el-text-color-secondary);
  font-size: 12px;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.todo-item__side {
  display: flex;
  align-items: flex-end;
  flex-direction: column;
  gap: 2px;
}

.todo-item__time {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.todo-item__time.is-overdue {
  color: var(--el-color-danger);
  font-weight: 600;
}

.todo-item__time.is-soon {
  color: var(--el-color-warning);
  font-weight: 600;
}

.activity {
  padding-top: 2px;
}

.activity__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
}

.activity p {
  display: -webkit-box;
  margin: 6px 0;
  overflow: hidden;
  color: var(--el-text-color-regular);
  font-size: 13px;
  line-height: 1.55;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
}

.activity small {
  color: var(--el-text-color-secondary);
  font-size: 11px;
}

@media (max-width: 1180px) {
  .kpi-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .hero {
    flex-direction: column;
  }

  .hero__aside {
    padding-top: 18px;
    padding-left: 0;
    border-top: 1px solid rgb(255 255 255 / 16%);
    border-left: 0;
  }
}

@media (max-width: 960px) {
  .chart-grid,
  .chart-grid--balanced,
  .bottom-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 640px) {
  .kpi-grid {
    grid-template-columns: 1fr;
  }

  .hero {
    padding: 22px;
  }

  .hero__aside {
    flex-wrap: wrap;
    gap: 18px;
  }

  .funnel__row {
    grid-template-columns: 64px minmax(0, 1fr) 74px;
  }
}
</style>
