<template>
  <div class="ym-page">
    <div class="ym-page-title">组织架构</div>

    <div class="ym-filter-card">
      <div class="ym-filter-row">
        <div class="ym-filter-field ym-filter-field--wide">
          <span class="ym-filter-label">员工搜索</span>
          <el-input v-model="query.keywords" clearable placeholder="请输入姓名、账号或手机号" @keyup.enter="handleSearch" />
        </div>
        <div class="ym-filter-field">
          <span class="ym-filter-label">状态</span>
          <el-select v-model="query.status" clearable placeholder="全部状态">
            <el-option label="启用" :value="1" />
            <el-option label="禁用" :value="0" />
          </el-select>
        </div>
        <div class="ym-filter-actions">
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </div>
      </div>
    </div>

    <div class="ym-dept-layout">
      <div class="ym-panel ym-dept-tree">
        <div class="ym-panel-header">
          <div class="ym-panel-title">部门架构</div>
          <span class="ym-muted">{{ deptCount }} 个部门</span>
        </div>

        <button
          type="button"
          :class="['ym-dept-all', { active: !currentDeptId }]"
          @click="selectAll"
        >
          <el-icon><OfficeBuilding /></el-icon>
          <span>全部员工</span>
          <span class="ym-dept-count">{{ allUserCount }}</span>
        </button>

        <el-tree
          ref="treeRef"
          :data="depts"
          :props="{ label: 'name', children: 'children' }"
          node-key="id"
          default-expand-all
          highlight-current
          :expand-on-click-node="false"
          @node-click="handleNodeClick"
        >
          <template #default="{ data }">
            <span class="ym-tree-node">
              <el-icon :size="15"><Folder /></el-icon>
              <span>{{ data.name }}</span>
            </span>
          </template>
        </el-tree>
      </div>

      <div class="ym-panel ym-dept-users">
        <div class="ym-panel-header">
          <div class="ym-panel-title">
            {{ currentDeptName || "全部员工" }}
            <span class="ym-muted">（{{ total }} 人）</span>
          </div>
          <el-button plain size="small" @click="handleExport">导出员工</el-button>
        </div>

        <el-table v-loading="loading" :data="rows" border stripe>
          <el-table-column label="员工" min-width="150">
            <template #default="{ row }">
              <div class="ym-user">
                <span class="ym-avatar">{{ avatarText(row) }}</span>
                <div class="ym-user__meta">
                  <span class="ym-user__name">{{ row.nickname || row.username }}</span>
                  <span class="ym-user__account">{{ row.username }}</span>
                </div>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="手机号" width="130">
            <template #default="{ row }">{{ row.mobile || "-" }}</template>
          </el-table-column>
          <el-table-column label="性别" width="80" align="center">
            <template #default="{ row }">{{ ymGenderLabel(row.gender) }}</template>
          </el-table-column>
          <el-table-column label="部门" min-width="130">
            <template #default="{ row }">{{ row.deptName || "-" }}</template>
          </el-table-column>
          <el-table-column label="角色" min-width="150" show-overflow-tooltip>
            <template #default="{ row }">{{ row.roleNames || "-" }}</template>
          </el-table-column>
          <el-table-column label="状态" width="90" align="center">
            <template #default="{ row }">
              <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small" effect="plain">
                {{ row.status === 1 ? "启用" : "禁用" }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="创建时间" width="150">
            <template #default="{ row }">{{ row.createTime || "-" }}</template>
          </el-table-column>
          <template #empty>
            <div class="ym-empty ym-empty--gray">暂无员工数据</div>
          </template>
        </el-table>

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
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "YoumiDept" });

import { ElMessage, ElTree } from "element-plus";
import YoumiAPI, { type DeptNode, type UserRow } from "@/api/youmi";
import { ymGenderLabel } from "@/youmi/constants";

const treeRef = ref<InstanceType<typeof ElTree>>();
const loading = ref(false);
const depts = ref<DeptNode[]>([]);
const rows = ref<UserRow[]>([]);
const total = ref(0);
const allUserCount = ref(0);
const currentDeptId = ref<number>();
const currentDeptName = ref("");

const query = reactive({
  pageNum: 1,
  pageSize: 10,
  keywords: "",
  status: undefined as number | undefined,
});

const deptCount = computed(() => {
  const count = (nodes: DeptNode[]): number =>
    nodes.reduce((sum, node) => sum + 1 + (node.children ? count(node.children) : 0), 0);
  return count(depts.value);
});

function avatarText(row: any): string {
  return (row.nickname || row.username || "?").slice(0, 1).toUpperCase();
}

async function loadDepts() {
  depts.value = await YoumiAPI.depts();
}

async function load() {
  loading.value = true;
  try {
    const data = await YoumiAPI.users({
      pageNum: query.pageNum,
      pageSize: query.pageSize,
      deptId: currentDeptId.value,
      keywords: query.keywords || undefined,
    });
    rows.value = (data.list ?? []).filter((row) => query.status === undefined || row.status === query.status);
    total.value = Number(data.total ?? 0);
    if (!currentDeptId.value && !query.keywords) {
      allUserCount.value = Number(data.total ?? 0);
    }
  } finally {
    loading.value = false;
  }
}

function handleSearch() {
  query.pageNum = 1;
  load();
}

function handleReset() {
  query.keywords = "";
  query.status = undefined;
  currentDeptId.value = undefined;
  currentDeptName.value = "";
  treeRef.value?.setCurrentKey(undefined);
  handleSearch();
}

function handleNodeClick(data: DeptNode) {
  currentDeptId.value = data.id;
  currentDeptName.value = data.name;
  query.pageNum = 1;
  load();
}

function selectAll() {
  currentDeptId.value = undefined;
  currentDeptName.value = "";
  treeRef.value?.setCurrentKey(undefined);
  query.pageNum = 1;
  load();
}

function handleExport() {
  if (!rows.value.length) {
    ElMessage.warning("暂无可导出的员工数据");
    return;
  }
  const header = ["员工姓名", "账号", "手机号", "性别", "部门", "角色", "状态", "创建时间"];
  const lines = rows.value.map((row) =>
    [
      row.nickname || row.username,
      row.username,
      row.mobile || "-",
      ymGenderLabel(row.gender),
      row.deptName || "-",
      row.roleNames || "-",
      row.status === 1 ? "启用" : "禁用",
      row.createTime || "-",
    ]
      .map((cell) => `"${String(cell).replace(/"/g, '""')}"`)
      .join(",")
  );
  const blob = new Blob([`\uFEFF${header.join(",")}\n${lines.join("\n")}`], { type: "text/csv;charset=utf-8" });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = `员工列表_${new Date().toISOString().slice(0, 10)}.csv`;
  link.click();
  URL.revokeObjectURL(link.href);
}

onMounted(async () => {
  await loadDepts();
  await load();
});
</script>

<style lang="scss" scoped>
.ym-dept-layout {
  display: grid;
  grid-template-columns: 280px minmax(0, 1fr);
  gap: 16px;
  align-items: start;
}

.ym-dept-tree {
  min-height: 620px;
  margin-top: 16px;
}

.ym-dept-users {
  min-width: 0;
  min-height: 620px;

  .el-pagination {
    display: flex;
    justify-content: flex-end;
    margin-top: 16px;
  }
}

.ym-dept-all {
  display: flex;
  gap: 8px;
  align-items: center;
  width: 100%;
  padding: 9px 12px;
  margin-bottom: 6px;
  font-size: 14px;
  color: #303133;
  cursor: pointer;
  background: #f7f8fa;
  border: 0;
  border-radius: 2px;

  &.active {
    color: #035cff;
    background: #e8f0ff;
  }
}

.ym-dept-count {
  margin-left: auto;
  font-size: 12px;
  color: #909399;
}

.ym-tree-node {
  display: inline-flex;
  gap: 6px;
  align-items: center;
  font-size: 14px;
  color: #303133;
}

:deep(.el-tree-node__content) {
  height: 34px;
  border-radius: 2px;
}

:deep(.el-tree-node.is-current > .el-tree-node__content) {
  color: #035cff;
  background: #e8f0ff;
}

.ym-user {
  display: flex;
  gap: 10px;
  align-items: center;

  &__meta {
    display: flex;
    flex-direction: column;
    line-height: 18px;
  }

  &__name {
    font-weight: 500;
    color: #303133;
  }

  &__account {
    font-size: 12px;
    color: #a8abb2;
  }
}

.ym-avatar {
  display: inline-flex;
  flex: none;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  font-size: 13px;
  color: #035cff;
  background: #e8f0ff;
  border-radius: 50%;
}
</style>
