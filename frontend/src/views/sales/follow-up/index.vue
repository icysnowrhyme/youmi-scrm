<template>
  <div class="page">
    <header class="page-head">
      <div>
        <h2>跟进记录</h2>
        <p>记录每一次沟通，让销售过程可追溯、可复盘</p>
      </div>
      <el-button v-has-perm="'scrm:follow-up:create'" type="primary" @click="openCreate">
        <el-icon><Plus /></el-icon>
        新增跟进
      </el-button>
    </header>

    <section class="panel filter-panel">
      <div class="filter-bar">
        <el-input
          v-model="params.keyword"
          class="filter-bar__keyword"
          clearable
          placeholder="搜索跟进内容 / 结果"
          @clear="handleQuery"
          @keyup.enter="handleQuery"
        >
          <template #prefix><el-icon><Search /></el-icon></template>
        </el-input>
        <CustomerSelect v-model="params.customerId" class="filter-customer" />
        <el-select v-model="params.type" clearable placeholder="跟进方式" style="width: 128px">
          <el-option v-for="item in FOLLOW_UP_TYPES" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          unlink-panels
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          value-format="YYYY-MM-DD"
          style="width: 250px"
          @change="handleDateChange"
        />
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="resetFilters">重置</el-button>
      </div>
    </section>

    <section class="panel">
      <el-table v-loading="loading" :data="list" row-key="id">
        <el-table-column label="客户" min-width="190">
          <template #default="{ row }">
            <button class="customer-link" type="button" @click="openCustomer(row.customerId)">
              <strong>{{ row.customerName || "-" }}</strong>
              <small>{{ row.customerCompany || "—" }}</small>
            </button>
          </template>
        </el-table-column>
        <el-table-column label="方式" width="88" align="center">
          <template #default="{ row }">
            <el-tag :type="optionType(FOLLOW_UP_TYPES, row.type)" size="small">
              {{ optionLabel(FOLLOW_UP_TYPES, row.type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="跟进内容" min-width="280" show-overflow-tooltip>
          <template #default="{ row }">{{ row.content }}</template>
        </el-table-column>
        <el-table-column label="跟进结果" min-width="160" show-overflow-tooltip>
          <template #default="{ row }">{{ row.result || "-" }}</template>
        </el-table-column>
        <el-table-column label="下次跟进" width="150">
          <template #default="{ row }">{{ formatDateTime(row.nextFollowTime) }}</template>
        </el-table-column>
        <el-table-column label="跟进人" width="100">
          <template #default="{ row }">{{ row.creatorName || "-" }}</template>
        </el-table-column>
        <el-table-column label="跟进时间" width="150">
          <template #default="{ row }">{{ formatDateTime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right" align="center">
          <template #default="{ row }">
            <el-button v-has-perm="'scrm:follow-up:update'" link type="primary" @click="openEdit(row as FollowUpItem)">
              编辑
            </el-button>
            <el-button v-has-perm="'scrm:follow-up:delete'" link type="danger" @click="remove(row as FollowUpItem)">
              删除
            </el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无跟进记录" :image-size="92" />
        </template>
      </el-table>

      <Pagination
        v-model:page="params.pageNum"
        v-model:limit="params.pageSize"
        :total="total"
        @pagination="fetchData"
      />
    </section>

    <FollowUpDialog v-model="dialogVisible" :edit-data="editing" @saved="fetchData" />

    <CustomerDetailDrawer
      v-model="detailVisible"
      :customer-id="detailCustomerId"
    />
  </div>
</template>

<script setup lang="ts">
import { ElMessage, ElMessageBox } from "element-plus";
import { FollowUpAPI } from "@/api/scrm";
import type { FollowUpItem, FollowUpQuery } from "@/api/scrm/types";
import { usePageTable } from "@/composables";
import { formatDateTime } from "@/utils/format";
import {
  FOLLOW_UP_TYPES,
  optionLabel,
  optionType,
} from "@/views/scrm/constants";
import CustomerSelect from "@/views/scrm/components/CustomerSelect.vue";
import CustomerDetailDrawer from "@/views/scrm/components/CustomerDetailDrawer.vue";
import FollowUpDialog from "@/views/scrm/components/FollowUpDialog.vue";

const initialParams: FollowUpQuery = {
  pageNum: 1,
  pageSize: 10,
  keyword: "",
  customerId: undefined,
  type: undefined,
  startDate: "",
  endDate: "",
};

const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
  FollowUpItem,
  FollowUpQuery
>({
  initialParams,
  request: FollowUpAPI.getPage,
});

const dateRange = ref<[string, string] | null>(null);
const dialogVisible = ref(false);
const editing = ref<FollowUpItem | null>(null);
const detailVisible = ref(false);
const detailCustomerId = ref<string | number>();

onMounted(fetchData);

function handleDateChange(value: [string, string] | null) {
  params.startDate = value?.[0] ?? "";
  params.endDate = value?.[1] ?? "";
  handleQuery();
}

function resetFilters() {
  dateRange.value = null;
  handleResetQuery();
}

function openCreate() {
  editing.value = null;
  dialogVisible.value = true;
}

function openEdit(row: FollowUpItem) {
  editing.value = row;
  dialogVisible.value = true;
}

async function remove(row: FollowUpItem) {
  await ElMessageBox.confirm("确定删除这条跟进记录吗？", "删除确认", {
    type: "warning",
    confirmButtonText: "删除",
    cancelButtonText: "取消",
  });
  await FollowUpAPI.remove(String(row.id));
  ElMessage.success("跟进记录已删除");
  fetchData();
}

function openCustomer(customerId: string | number) {
  detailCustomerId.value = customerId;
  detailVisible.value = true;
}
</script>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.page-head {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 16px;
}

.page-head h2 {
  margin: 0;
  font-size: 22px;
}

.page-head p {
  margin: 6px 0 0;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.panel {
  padding: 16px 18px;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 14px;
  background: var(--el-bg-color);
}

.filter-bar {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
}

.filter-bar__keyword {
  width: 230px;
}

.filter-customer {
  width: 210px;
}

.customer-link {
  display: flex;
  padding: 0;
  flex-direction: column;
  gap: 2px;
  color: inherit;
  text-align: left;
  border: 0;
  background: none;
  cursor: pointer;
}

.customer-link small {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.customer-link:hover strong {
  color: var(--el-color-primary);
}

@media (max-width: 900px) {
  .filter-bar__keyword,
  .filter-customer {
    width: 100%;
  }
}
</style>
