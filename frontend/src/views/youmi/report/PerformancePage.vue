<template>
  <div class="ym-page">
    <div class="ym-page-title">员工业绩</div>

    <div class="ym-subtabs">
      <button type="button" class="ym-subtab active">业绩统计</button>
      <button type="button" class="ym-subtab" @click="goMerits">员工绩效</button>
    </div>

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
          <el-tree-select
            v-model="deptName"
            :data="depts"
            :props="{ label: 'name', children: 'children' }"
            node-key="id"
            check-strictly
            clearable
            placeholder="全部部门"
            style="width: 220px"
          />
        </div>
        <div class="ym-filter-field">
          <span class="ym-filter-label">员工</span>
          <el-select v-model="userName" clearable filterable placeholder="全部员工" style="width: 200px">
            <el-option v-for="item in userOptions" :key="item" :label="item" :value="item" />
          </el-select>
        </div>
        <div class="ym-filter-actions">
          <el-button type="primary" @click="load">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
          <el-button plain @click="handleExport">导出报表</el-button>
        </div>
      </div>
    </div>

    <div class="ym-stat-grid">
      <div v-for="card in statCards" :key="card.label" class="ym-stat-card">
        <div class="ym-stat-card__label">{{ card.label }}</div>
        <div class="ym-stat-card__value">
          {{ card.prefix }}{{ card.value }}<span v-if="card.suffix" class="ym-stat-card__suffix">{{ card.suffix }}</span>
        </div>
        <div class="ym-stat-card__foot">{{ card.foot }}</div>
      </div>
    </div>

    <div class="ym-panel">
      <div class="ym-panel-header">
        <div class="ym-panel-title">成交金额排行</div>
        <span class="ym-muted">
          统计区间：{{ dateRange?.[0] }} 至 {{ dateRange?.[1] }}
        </span>
      </div>
      <div ref="chartRef" class="ym-chart" />
    </div>

    <div class="ym-panel">
      <div class="ym-panel-header">
        <div class="ym-panel-title">员工明细</div>
        <span class="ym-muted">共 {{ filteredRows.length }} 名员工</span>
      </div>

      <el-table v-loading="loading" :data="filteredRows" border stripe>
        <el-table-column label="排名" width="70" align="center">
          <template #default="{ $index }">
            <span :class="['ym-rank', { 'ym-rank--top': $index < 3 }]">{{ $index + 1 }}</span>
          </template>
        </el-table-column>
        <el-table-column label="员工" min-width="130">
          <template #default="{ row }">
            <span class="ym-employee">{{ row.userName }}</span>
          </template>
        </el-table-column>
        <el-table-column label="部门" min-width="130">
          <template #default="{ row }">{{ row.deptName || "-" }}</template>
        </el-table-column>
        <el-table-column prop="customerCount" label="新增客户" width="110" align="center" />
        <el-table-column prop="followCount" label="跟进次数" width="110" align="center" />
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
        <template #empty>
          <div class="ym-empty ym-empty--gray">暂无数据</div>
        </template>
      </el-table>
    </div>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "YoumiPerformance" });

import { ElMessage } from "element-plus";
import * as echarts from "echarts";
import { useRouter } from "vue-router";
import YoumiAPI, { type DeptNode, type PerformanceRow } from "@/api/youmi";
import { ymMoney } from "@/youmi/constants";

const router = useRouter();

const loading = ref(false);
const rows = ref<PerformanceRow[]>([]);
const depts = ref<DeptNode[]>([]);
const deptName = ref<string>();
const userName = ref<string>();

const formatDate = (date: Date) =>
  `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
const today = new Date();
const weekAgo = new Date(today.getTime() - 6 * 24 * 60 * 60 * 1000);
const dateRange = ref<[string, string]>([formatDate(weekAgo), formatDate(today)]);

const filteredRows = computed(() =>
  rows.value.filter(
    (row) =>
      (!deptName.value || row.deptName === deptName.value) &&
      (!userName.value || row.userName === userName.value)
  )
);

const userOptions = computed(() => Array.from(new Set(rows.value.map((row) => row.userName))));

const statCards = computed(() => {
  const source = filteredRows.value;
  const customerCount = source.reduce((sum, row) => sum + Number(row.customerCount ?? 0), 0);
  const followCount = source.reduce((sum, row) => sum + Number(row.followCount ?? 0), 0);
  const orderCount = source.reduce((sum, row) => sum + Number(row.orderCount ?? 0), 0);
  const orderAmount = source.reduce((sum, row) => sum + Number(row.orderAmount ?? 0), 0);
  return [
    { label: "参与统计员工", value: String(source.length), prefix: "", suffix: "人", foot: "按当前筛选条件统计" },
    { label: "新增客户", value: String(customerCount), prefix: "", suffix: "人", foot: "名下客户总数" },
    { label: "跟进次数", value: String(followCount), prefix: "", suffix: "次", foot: "统计区间内跟进记录" },
    { label: "成交订单", value: String(orderCount), prefix: "", suffix: "单", foot: "统计区间内新建订单" },
    { label: "成交金额", value: ymMoney(orderAmount), prefix: "￥", suffix: "", foot: "统计区间内订单金额" },
  ];
});

const chartRef = ref<HTMLDivElement>();
let chart: echarts.ECharts | undefined;

function renderChart() {
  if (!chartRef.value) return;
  chart ??= echarts.init(chartRef.value);
  const top = [...filteredRows.value].sort((a, b) => Number(b.orderAmount ?? 0) - Number(a.orderAmount ?? 0)).slice(0, 8);
  chart.setOption(
    {
      grid: { left: 60, right: 24, top: 20, bottom: 40 },
      tooltip: {
        trigger: "axis",
        axisPointer: { type: "shadow" },
        valueFormatter: (value: unknown) => `￥${ymMoney(value as number)}`,
      },
      xAxis: {
        type: "category",
        data: top.map((row) => row.userName),
        axisLine: { lineStyle: { color: "#dcdfe6" } },
        axisLabel: { color: "#606266" },
      },
      yAxis: {
        type: "value",
        axisLabel: { color: "#909399" },
        splitLine: { lineStyle: { color: "#f0f0f0" } },
      },
      series: [
        {
          type: "bar",
          name: "成交金额",
          data: top.map((row) => Number(row.orderAmount ?? 0)),
          barMaxWidth: 36,
          itemStyle: { color: "#035cff", borderRadius: [2, 2, 0, 0] },
        },
      ],
    },
    true
  );
}

function handleResize() {
  chart?.resize();
}

async function load() {
  loading.value = true;
  try {
    rows.value = await YoumiAPI.performance({
      startDate: dateRange.value[0],
      endDate: dateRange.value[1],
    });
    await nextTick();
    renderChart();
  } finally {
    loading.value = false;
  }
}

function handleReset() {
  const now = new Date();
  dateRange.value = [formatDate(new Date(now.getTime() - 6 * 24 * 60 * 60 * 1000)), formatDate(now)];
  deptName.value = undefined;
  userName.value = undefined;
  load();
}

function goMerits() {
  router.push("/report/meritsrecord");
}

function handleExport() {
  if (!filteredRows.value.length) {
    ElMessage.warning("暂无可导出的业绩数据");
    return;
  }
  const header = ["排名", "员工", "部门", "新增客户", "跟进次数", "成交订单", "成交金额", "赢单率"];
  const lines = filteredRows.value.map((row, index) =>
    [
      index + 1,
      row.userName,
      row.deptName || "-",
      row.customerCount,
      row.followCount,
      row.orderCount,
      ymMoney(row.orderAmount),
      `${row.winRate}%`,
    ]
      .map((cell) => `"${String(cell).replace(/"/g, '""')}"`)
      .join(",")
  );
  const blob = new Blob([`\uFEFF${header.join(",")}\n${lines.join("\n")}`], { type: "text/csv;charset=utf-8" });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = `员工业绩_${dateRange.value[0]}_${dateRange.value[1]}.csv`;
  link.click();
  URL.revokeObjectURL(link.href);
}

watch([deptName, userName], () => {
  nextTick(renderChart);
});

onMounted(async () => {
  depts.value = await YoumiAPI.depts().catch(() => []);
  await load();
  window.addEventListener("resize", handleResize);
});

onBeforeUnmount(() => {
  window.removeEventListener("resize", handleResize);
  chart?.dispose();
});
</script>

<style lang="scss" scoped>
.ym-stat-grid {
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 16px;
  margin-top: 16px;
}

.ym-stat-card {
  padding: 18px 20px;
  background: #fff;
  box-shadow: 0 4px 12px rgb(0 0 0 / 12%);

  &__label {
    font-size: 13px;
    color: #909399;
  }

  &__value {
    margin-top: 10px;
    font-size: 26px;
    font-weight: 600;
    line-height: 1;
    color: #222;
  }

  &__suffix {
    margin-left: 4px;
    font-size: 13px;
    font-weight: 400;
    color: #909399;
  }

  &__foot {
    margin-top: 10px;
    font-size: 12px;
    color: #b0b4bd;
  }
}

.ym-chart {
  width: 100%;
  height: 300px;
}

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

.ym-employee {
  color: #303133;
  font-weight: 500;
}

.ym-amount {
  font-weight: 500;
  color: #222;
}

.ym-rate {
  color: #035cff;
}

@media (width <= 1400px) {
  .ym-stat-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}
</style>
