<template>
  <div class="ym-page">
    <div class="ym-subtabs">
      <button
        v-for="tab in tabs"
        :key="tab.key"
        type="button"
        :class="['ym-subtab', { active: activeTab === tab.key }]"
        @click="activeTab = tab.key"
      >
        {{ tab.label }}
      </button>
    </div>

    <template v-if="activeTab === 'list'">
      <div class="ym-filter-card">
        <div class="ym-filter-row">
          <div class="ym-filter-field ym-filter-field--wide">
            <span class="ym-filter-label">关键字</span>
            <el-input v-model="query.keyword" clearable placeholder="请输入姓名、客户编码、手机号" @keyup.enter="handleSearch" />
          </div>
          <div class="ym-filter-actions">
            <el-button type="primary" @click="handleSearch">搜索</el-button>
            <el-button @click="handleReset">重置</el-button>
            <button class="ym-advanced" type="button" @click="advanced = !advanced">
              高级搜索
              <el-icon :class="{ 'is-open': advanced }"><ArrowDown /></el-icon>
            </button>
          </div>
        </div>

        <div v-if="advanced" class="ym-filter-row" style="margin-top: 14px">
          <div class="ym-filter-field">
            <span class="ym-filter-label">所属员工</span>
            <el-select v-model="query.ownerId" clearable placeholder="请选择员工">
              <el-option v-for="user in ownerOptions" :key="user.id" :label="user.nickname || user.username" :value="user.id" />
            </el-select>
          </div>
          <div class="ym-filter-field">
            <span class="ym-filter-label">客户来源</span>
            <el-select v-model="query.source" clearable placeholder="请选择来源">
              <el-option v-for="item in YM_SOURCES" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </div>
          <div class="ym-filter-field">
            <span class="ym-filter-label">意向等级</span>
            <el-select v-model="query.level" clearable placeholder="请选择意向">
              <el-option v-for="item in YM_LEVELS" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </div>
          <div class="ym-filter-field">
            <span class="ym-filter-label">添加时间</span>
            <el-date-picker
              v-model="dateRange"
              type="daterange"
              value-format="YYYY-MM-DD"
              range-separator="-"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
            />
          </div>
        </div>
      </div>

      <div class="ym-panel">
        <div class="ym-panel-header">
          <div class="ym-panel-title">客户列表</div>
          <div class="ym-toolbar">
            <el-button plain @click="handleExport">导出</el-button>
            <el-button type="primary" @click="ElMessage.info('暂无需确认的线索')">线索确认</el-button>
            <el-button type="primary" @click="openCreate">新建客户</el-button>
            <el-button type="primary" plain @click="ElMessage.info('请在客户详情中新增待办跟进')">新建待办</el-button>
            <el-dropdown trigger="click" @command="handleBatchCommand">
              <el-button plain>批量操作<el-icon class="el-icon--right"><ArrowDown /></el-icon></el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="delete" :disabled="!selection.length">批量删除</el-dropdown-item>
                  <el-dropdown-item command="export">导出所选</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </div>

        <el-table v-loading="loading" :data="rows" border row-key="id" @selection-change="handleSelectionChange">
          <el-table-column type="selection" width="44" />
          <el-table-column label="客户编码" width="110">
            <template #default="{ row }">{{ ymCustomerCode(row.id) }}</template>
          </el-table-column>
          <el-table-column prop="name" label="姓名" min-width="100" show-overflow-tooltip />
          <el-table-column label="性别" width="70">
            <template #default="{ row }">{{ ymGenderLabel(row.gender) }}</template>
          </el-table-column>
          <el-table-column label="社交关系" width="130">
            <template #default="{ row }">{{ row.wechat || "-" }}</template>
          </el-table-column>
          <el-table-column prop="phone" label="客户电话" width="130" />
          <el-table-column label="来源" width="90">
            <template #default="{ row }">{{ ymSourceLabel(row.source) }}</template>
          </el-table-column>
          <el-table-column label="意向" width="110">
            <template #default="{ row }">
              <el-tag :type="ymLevelTag(row.level)" size="small" effect="plain">
                {{ ymIntentLabel(row.level) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="客户标签" min-width="150">
            <template #default="{ row }">
              <template v-if="row.tags?.length">
                <el-tag
                  v-for="tag in row.tags.slice(0, 2)"
                  :key="tag.id"
                  size="small"
                  effect="plain"
                  :style="{ color: tag.color || '#035cff', borderColor: `${tag.color || '#035cff'}55` }"
                  class="mr4"
                >
                  {{ tag.name }}
                </el-tag>
                <span v-if="row.tags.length > 2" class="ym-muted">+{{ row.tags.length - 2 }}</span>
              </template>
              <span v-else class="ym-muted">-</span>
            </template>
          </el-table-column>
          <el-table-column label="企微标签" width="100">
            <template #default>—</template>
          </el-table-column>
          <el-table-column label="添加时间" width="160">
            <template #default="{ row }">{{ row.createTime || "-" }}</template>
          </el-table-column>
          <el-table-column label="操作" width="160" fixed="right">
            <template #default="{ row }">
              <el-button link type="primary" @click="openDetail(row)">详情</el-button>
              <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
              <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
            </template>
          </el-table-column>
          <template #empty>
            <div class="ym-empty ym-empty--gray">暂无数据</div>
          </template>
        </el-table>

        <div class="ym-list-footer">
          <span class="ym-selected">已选 {{ selection.length }} 条</span>
          <el-pagination
            v-model:current-page="query.pageNum"
            v-model:page-size="query.pageSize"
            :page-sizes="[10, 20, 50]"
            :total="total"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="load"
            @current-change="load"
          />
        </div>
      </div>
    </template>

    <div v-else class="ym-panel" style="margin-top: 0">
      <div class="ym-panel-header">
        <div class="ym-panel-title">{{ activeTab === "black" ? "客户黑名单" : "电话黑名单" }}</div>
        <el-button type="primary" @click="ElMessage.info('演示版暂未开放黑名单维护')">新增</el-button>
      </div>
      <el-table :data="[]" border>
        <el-table-column :label="activeTab === 'black' ? '客户名称' : '电话号码'" min-width="160" />
        <el-table-column label="拉黑原因" min-width="200" />
        <el-table-column label="操作人" width="120" />
        <el-table-column label="加入时间" width="170" />
        <el-table-column label="操作" width="120" />
        <template #empty>
          <div class="ym-empty ym-empty--gray">暂无数据</div>
        </template>
      </el-table>
    </div>

    <CustomerFormDialog v-model="formVisible" mode="customer" :record="editing" @saved="load" />

    <el-drawer v-model="detailVisible" title="客户详情" size="480px">
      <el-descriptions v-if="detail" :column="1" border label-width="110px">
        <el-descriptions-item label="客户编码">{{ ymCustomerCode(detail.id) }}</el-descriptions-item>
        <el-descriptions-item label="姓名">{{ detail.name }}</el-descriptions-item>
        <el-descriptions-item label="性别">{{ ymGenderLabel(detail.gender) }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ detail.phone || "-" }}</el-descriptions-item>
        <el-descriptions-item label="微信号">{{ detail.wechat || "-" }}</el-descriptions-item>
        <el-descriptions-item label="来源">{{ ymSourceLabel(detail.source) }}</el-descriptions-item>
        <el-descriptions-item label="意向">
          <el-tag :type="ymLevelTag(detail.level)" size="small">{{ ymIntentLabel(detail.level) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="客户标签">
          <template v-if="detail.tags?.length">
            <el-tag v-for="tag in detail.tags" :key="tag.id" size="small" class="mr4" effect="plain">
              {{ tag.name }}
            </el-tag>
          </template>
          <span v-else>-</span>
        </el-descriptions-item>
        <el-descriptions-item label="负责人">{{ detail.ownerName || "-" }}</el-descriptions-item>
        <el-descriptions-item label="最近跟进">{{ detail.lastFollowTime || "-" }}</el-descriptions-item>
        <el-descriptions-item label="备注">{{ detail.remark || "-" }}</el-descriptions-item>
        <el-descriptions-item label="添加时间">{{ detail.createTime || "-" }}</el-descriptions-item>
      </el-descriptions>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "YoumiCustomerList" });

import { ElMessage, ElMessageBox } from "element-plus";
import { CustomerAPI } from "@/api/scrm";
import type { CustomerDetail, CustomerItem, CustomerQuery } from "@/api/scrm/types";
import YoumiAPI, { type UserRow } from "@/api/youmi";
import {
  YM_LEVELS,
  YM_SOURCES,
  ymCustomerCode,
  ymGenderLabel,
  ymIntentLabel,
  ymLevelTag,
  ymSourceLabel,
} from "@/youmi/constants";
import CustomerFormDialog from "../components/CustomerFormDialog.vue";

const tabs = [
  { key: "list", label: "客户列表" },
  { key: "black", label: "客户黑名单" },
  { key: "phone", label: "电话黑名单" },
];

const activeTab = ref("list");
const loading = ref(false);
const rows = ref<CustomerItem[]>([]);
const total = ref(0);
const selection = ref<CustomerItem[]>([]);
const advanced = ref(false);
const dateRange = ref<[string, string] | null>(null);
const ownerOptions = ref<UserRow[]>([]);

const query = reactive<CustomerQuery>({
  pageNum: 1,
  pageSize: 10,
  keyword: "",
  level: "",
  source: undefined,
  ownerId: undefined,
  statuses: "2,3",
});

const formVisible = ref(false);
const editing = ref<CustomerItem | null>(null);
const detailVisible = ref(false);
const detail = ref<CustomerDetail | null>(null);

async function loadOwners() {
  if (ownerOptions.value.length) return;
  const result = await YoumiAPI.users({ pageNum: 1, pageSize: 100 });
  ownerOptions.value = result.list;
}

async function load() {
  if (activeTab.value !== "list") return;
  loading.value = true;
  try {
    const params: CustomerQuery = {
      ...query,
      keyword: query.keyword || undefined,
      level: query.level || undefined,
      startDate: dateRange.value?.[0] || undefined,
      endDate: dateRange.value?.[1] || undefined,
    };
    const result = await CustomerAPI.getPage(params);
    rows.value = result.list;
    total.value = result.total;
  } finally {
    loading.value = false;
  }
}

function handleSearch() {
  query.pageNum = 1;
  load();
}

function handleReset() {
  query.keyword = "";
  query.level = "";
  query.source = undefined;
  query.ownerId = undefined;
  query.pageNum = 1;
  dateRange.value = null;
  load();
}

function handleSelectionChange(selectionRows: CustomerItem[]) {
  selection.value = selectionRows;
}

function openCreate() {
  editing.value = null;
  formVisible.value = true;
}

function openEdit(row: any) {
  editing.value = row;
  formVisible.value = true;
}

async function openDetail(row: any) {
  detail.value = null;
  detailVisible.value = true;
  detail.value = await CustomerAPI.getDetail(row.id);
}

async function handleDelete(row: any) {
  await ElMessageBox.confirm(`确定删除客户「${row.name}」吗？`, "删除确认", {
    type: "warning",
    confirmButtonText: "删除",
    cancelButtonText: "取消",
  });
  await CustomerAPI.remove(String(row.id));
  ElMessage.success("删除成功");
  load();
}

function csvCell(value: unknown): string {
  return `"${String(value ?? "").replace(/"/g, '""')}"`;
}

function exportRows(list: CustomerItem[]) {
  const header = ["客户编码", "姓名", "性别", "微信", "手机号", "来源", "意向", "标签", "添加时间"];
  const lines = list.map((row) =>
    [
      ymCustomerCode(row.id),
      row.name,
      ymGenderLabel(row.gender),
      row.wechat || "",
      row.phone || "",
      ymSourceLabel(row.source),
      ymIntentLabel(row.level),
      (row.tags ?? []).map((tag) => tag.name).join("/"),
      row.createTime || "",
    ]
      .map(csvCell)
      .join(",")
  );
  const blob = new Blob([`\uFEFF${header.map(csvCell).join(",")}\n${lines.join("\n")}`], {
    type: "text/csv;charset=utf-8",
  });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = `客户列表_${new Date().toISOString().slice(0, 10)}.csv`;
  link.click();
  URL.revokeObjectURL(link.href);
}

function handleExport() {
  if (!rows.value.length) {
    ElMessage.warning("暂无可导出的数据");
    return;
  }
  exportRows(rows.value);
  ElMessage.success("导出成功");
}

function handleBatchCommand(command: string) {
  if (command === "export") {
    if (!selection.value.length) {
      ElMessage.warning("请先选择客户");
      return;
    }
    exportRows(selection.value);
    return;
  }
  if (command === "delete") {
    if (!selection.value.length) return;
    ElMessageBox.confirm(`确定删除选中的 ${selection.value.length} 个客户吗？`, "批量删除", {
      type: "warning",
      confirmButtonText: "删除",
      cancelButtonText: "取消",
    }).then(async () => {
      await CustomerAPI.remove(selection.value.map((item) => item.id).join(","));
      ElMessage.success("删除成功");
      load();
    });
  }
}

watch(activeTab, (value) => {
  if (value === "list") load();
});

onMounted(() => {
  load();
  loadOwners();
});
</script>

<style scoped>
.ym-advanced {
  display: inline-flex;
  gap: 4px;
  align-items: center;
  padding: 0;
  font-size: 14px;
  color: #035cff;
  cursor: pointer;
  background: transparent;
  border: 0;
}

.ym-advanced .el-icon {
  transition: transform 0.2s;
}

.ym-advanced .el-icon.is-open {
  transform: rotate(180deg);
}

.ym-list-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 16px;
}

.ym-selected {
  font-size: 13px;
  color: #909399;
}

.mr4 {
  margin-right: 4px;
}
</style>
