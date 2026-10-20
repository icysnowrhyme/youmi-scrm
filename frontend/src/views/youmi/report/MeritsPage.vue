<template>
  <div class="ym-page">
    <div class="ym-page-title">员工绩效</div>

    <div class="ym-subtabs">
      <button
        v-for="tab in tabs"
        :key="tab.value"
        type="button"
        :class="['ym-subtab', { active: activeTab === tab.value }]"
        @click="activeTab = tab.value"
      >
        {{ tab.label }}
      </button>
    </div>

    <p class="ym-subtab-desc">
      {{ tabDescription }}
    </p>

    <div class="ym-filter-card">
      <div class="ym-filter-row">
        <div class="ym-filter-field">
          <span class="ym-filter-label">统计时间</span>
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            value-format="YYYY-MM-DD"
            range-separator="-"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            :clearable="false"
          />
        </div>
        <div class="ym-filter-field">
          <span class="ym-filter-label">部门</span>
          <el-select v-model="deptName" clearable placeholder="全部部门" style="width: 220px">
            <el-option v-for="item in deptOptions" :key="item" :label="item" :value="item" />
          </el-select>
        </div>
        <div class="ym-filter-actions">
          <el-button type="primary" @click="load">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
          <el-button plain @click="handleExport">导出</el-button>
        </div>
      </div>
    </div>

    <div class="ym-panel">
      <div class="ym-panel-header">
        <div class="ym-panel-title">{{ activeTab === "receive" ? "签收绩效明细" : "线索转化绩效明细" }}</div>
        <span class="ym-muted">共 {{ filteredRows.length }} 名员工</span>
      </div>

      <el-table v-loading="loading" :data="filteredRows" border stripe>
        <el-table-column label="排名" width="70" align="center">
          <template #default="{ $index }">
            <span :class="['ym-rank', { 'ym-rank--top': $index < 3 }]">{{ $index + 1 }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="userName" label="员工" min-width="130" />
        <el-table-column label="部门" min-width="140">
          <template #default="{ row }">{{ row.deptName || "-" }}</template>
        </el-table-column>

        <template v-if="activeTab === 'receive'">
          <el-table-column prop="customerCount" label="签收客户" width="120" align="center" />
          <el-table-column prop="followCount" label="跟进次数" width="120" align="center" />
          <el-table-column label="人均跟进" width="130" align="center">
            <template #default="{ row }">{{ averageFollow(row) }} 次/客户</template>
          </el-table-column>
          <el-table-column label="日跟进量" width="130" align="center">
            <template #default="{ row }">{{ dailyFollow(row) }} 次</template>
          </el-table-column>
          <el-table-column label="签收质量" min-width="150">
            <template #default="{ row }">
              <el-progress
                :percentage="receiveScore(row)"
                :stroke-width="8"
                :color="progressColor(receiveScore(row))"
              />
            </template>
          </el-table-column>
        </template>

        <template v-else>
          <el-table-column prop="customerCount" label="签收线索" width="120" align="center" />
          <el-table-column prop="orderCount" label="成交订单" width="110" align="center" />
          <el-table-column label="成交金额" width="150" align="right">
            <template #default="{ row }">
              <span class="ym-amount">￥{{ ymMoney(row.orderAmount) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="赢单率" width="120" align="center">
            <template #default="{ row }">
              <span class="ym-rate">{{ row.winRate }}%</span>
            </template>
          </el-table-column>
          <el-table-column label="转化评级" width="120" align="center">
            <template #default="{ row }">
              <el-tag :type="ratingTag(row.winRate)" size="small" effect="plain">
                {{ ratingLabel(row.winRate) }}
              </el-tag>
            </template>
          </el-table-column>
        </template>

        <template #empty>
          <div class="ym-empty ym-empty--gray">暂无数据</div>
        </template>
      </el-table>
    </div>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "YoumiMerits" });

import { ElMessage } from "element-plus";
import YoumiAPI, { type PerformanceRow } from "@/api/youmi";
import { ymMoney } from "@/youmi/constants";

type MeritTab = "receive" | "convert";

const tabs: { label: string; value: MeritTab }[] = [
  { label: "签收绩效", value: "receive" },
  { label: "线索转化绩效", value: "convert" },
];

const activeTab = ref<MeritTab>("receive");
const loading = ref(false);
const rows = ref<PerformanceRow[]>([]);
const deptName = ref<string>();

const formatDate = (date: Date) =>
  `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
const today = new Date();
const dateRange = ref<[string, string]>([
  formatDate(new Date(today.getTime() - 6 * 24 * 60 * 60 * 1000)),
  formatDate(today),
]);

const tabDescription = computed(() =>
  activeTab.value === "receive"
    ? "签收绩效统计员工在周期内签收的客户数量与跟进执行情况，跟进越及时签收质量越高。"
    : "线索转化绩效按员工成交订单与赢单率计算，成交金额取统计周期内新建订单金额。"
);

const deptOptions = computed(() => Array.from(new Set(rows.value.map((row) => row.deptName).filter(Boolean))));

const filteredRows = computed(() =>
  rows.value.filter((row) => !deptName.value || row.deptName === deptName.value)
);

function averageFollow(row: any): string {
  const customers = Number(row.customerCount);
  if (!customers) return "0";
  return (Number(row.followCount) / customers).toFixed(1);
}

function dailyFollow(row: any): string {
  return (Number(row.followCount) / 7).toFixed(1);
}

function receiveScore(row: any): number {
  const score = Number(row.followCount) * 6 + Number(row.customerCount) * 4;
  return Math.min(100, Math.round(score));
}

function progressColor(percentage: number): string {
  if (percentage >= 80) return "#035cff";
  if (percentage >= 50) return "#f5a623";
  return "#f56c6c";
}

function ratingLabel(winRate?: number): string {
  if (!winRate) return "待提升";
  if (winRate >= 50) return "优秀";
  if (winRate >= 30) return "良好";
  return "待提升";
}

function ratingTag(winRate?: number): "success" | "primary" | "info" {
  if (!winRate) return "info";
  if (winRate >= 50) return "success";
  if (winRate >= 30) return "primary";
  return "info";
}

async function load() {
  loading.value = true;
  try {
    rows.value = await YoumiAPI.performance({
      startDate: dateRange.value[0],
      endDate: dateRange.value[1],
    });
  } finally {
    loading.value = false;
  }
}

function handleReset() {
  const now = new Date();
  dateRange.value = [formatDate(new Date(now.getTime() - 6 * 24 * 60 * 60 * 1000)), formatDate(now)];
  deptName.value = undefined;
  load();
}

function handleExport() {
  if (!filteredRows.value.length) {
    ElMessage.warning("暂无可导出的绩效数据");
    return;
  }
  const header =
    activeTab.value === "receive"
      ? ["排名", "员工", "部门", "签收客户", "跟进次数", "人均跟进", "日跟进量"]
      : ["排名", "员工", "部门", "签收线索", "成交订单", "成交金额", "赢单率", "转化评级"];
  const lines = filteredRows.value.map((row, index) => {
    const cells =
      activeTab.value === "receive"
        ? [index + 1, row.userName, row.deptName || "-", row.customerCount, row.followCount, averageFollow(row), dailyFollow(row)]
        : [
            index + 1,
            row.userName,
            row.deptName || "-",
            row.customerCount,
            row.orderCount,
            ymMoney(row.orderAmount),
            `${row.winRate}%`,
            ratingLabel(row.winRate),
          ];
    return cells.map((cell) => `"${String(cell).replace(/"/g, '""')}"`).join(",");
  });
  const blob = new Blob([`\uFEFF${header.join(",")}\n${lines.join("\n")}`], { type: "text/csv;charset=utf-8" });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = `${activeTab.value === "receive" ? "签收绩效" : "线索转化绩效"}_${dateRange.value[0]}_${dateRange.value[1]}.csv`;
  link.click();
  URL.revokeObjectURL(link.href);
}

onMounted(load);
</script>

<style lang="scss" scoped>
.ym-rank {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 22px;
  height: 22px;
  font-size: 12px;
  color: #606266;
  background: #f2f3f5;
  border-radius: 50%;

  &--top {
    color: #fff;
    background: #035cff;
  }
}

.ym-amount {
  font-weight: 500;
  color: #222;
}

.ym-rate {
  color: #035cff;
}
</style>
