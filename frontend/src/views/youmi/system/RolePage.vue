<template>
  <div class="ym-page">
    <div class="ym-page-title">角色</div>

    <div class="ym-filter-card">
      <div class="ym-filter-row">
        <div class="ym-filter-field ym-filter-field--wide">
          <span class="ym-filter-label">角色名称</span>
          <el-input v-model="query.keywords" clearable placeholder="请输入角色名称或角色编码" @keyup.enter="handleSearch" />
        </div>
        <div class="ym-filter-actions">
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </div>
      </div>
    </div>

    <div class="ym-panel">
      <div class="ym-panel-header">
        <div class="ym-panel-title">角色列表</div>
        <div class="ym-toolbar">
          <el-button type="primary" @click="openCreate">新建角色</el-button>
          <el-button plain @click="handleRefresh">刷新</el-button>
        </div>
      </div>

      <el-table v-loading="loading" :data="rows" border row-key="id">
        <el-table-column prop="name" label="角色名称" min-width="160" />
        <el-table-column prop="code" label="角色编码" min-width="160">
          <template #default="{ row }">
            <span class="ym-code">{{ row.code }}</span>
          </template>
        </el-table-column>
        <el-table-column label="数据权限" min-width="180">
          <template #default="{ row }">{{ row.dataScopeLabel || dataScopeLabel(row.dataScope) }}</template>
        </el-table-column>
        <el-table-column prop="sort" label="排序" width="90" align="center" />
        <el-table-column label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small" effect="plain">
              {{ row.status === 1 ? "启用" : "禁用" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="更新时间" width="170">
          <template #default="{ row }">{{ formatTime(row.updateTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
            <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
        <template #empty>
          <div class="ym-empty ym-empty--gray">暂无数据</div>
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

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="560px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="96px">
        <el-form-item label="角色名称" prop="name">
          <el-input v-model="form.name" maxlength="30" placeholder="请输入角色名称" />
        </el-form-item>
        <el-form-item label="角色编码" prop="code">
          <el-input v-model="form.code" maxlength="40" :disabled="!!editingId" placeholder="例如 sales_manager" />
        </el-form-item>
        <el-form-item label="数据权限" prop="dataScope">
          <el-select v-model="form.dataScope" style="width: 100%">
            <el-option v-for="item in dataScopes" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <div class="ym-form-row">
          <el-form-item label="排序" prop="sort">
            <el-input-number v-model="form.sort" :min="0" :max="999" style="width: 100%" />
          </el-form-item>
          <el-form-item label="状态" prop="status">
            <el-radio-group v-model="form.status">
              <el-radio :value="1">启用</el-radio>
              <el-radio :value="0">禁用</el-radio>
            </el-radio-group>
          </el-form-item>
        </div>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="3" maxlength="200" show-word-limit />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "YoumiRole" });

import { ElMessage, ElMessageBox } from "element-plus";
import type { FormInstance, FormRules } from "element-plus";
import RoleAPI from "@/api/system/role";
import type { RoleForm, RoleItem } from "@/api/system/role";

const dataScopes = [
  { label: "全部数据", value: 1 },
  { label: "本部门及以下数据", value: 2 },
  { label: "本部门数据", value: 3 },
  { label: "本人数据", value: 4 },
  { label: "自定义数据", value: 5 },
];

const loading = ref(false);
const saving = ref(false);
const rows = ref<RoleItem[]>([]);
const total = ref(0);
const query = reactive({ pageNum: 1, pageSize: 10, keywords: "" });

const dialogVisible = ref(false);
const formRef = ref<FormInstance>();
const editingId = ref<string>();
const form = reactive<RoleForm>({
  name: "",
  code: "",
  sort: 1,
  status: 1,
  dataScope: 1,
  remark: "",
});

const rules: FormRules = {
  name: [{ required: true, message: "请输入角色名称", trigger: "blur" }],
  code: [{ required: true, message: "请输入角色编码", trigger: "blur" }],
  dataScope: [{ required: true, message: "请选择数据权限", trigger: "change" }],
};

const dialogTitle = computed(() => (editingId.value ? "编辑角色" : "新建角色"));

function dataScopeLabel(value?: number): string {
  return dataScopes.find((item) => item.value === value)?.label ?? "-";
}

function formatTime(value?: Date | string): string {
  if (!value) return "-";
  return String(value).replace("T", " ").slice(0, 19);
}

async function load() {
  loading.value = true;
  try {
    const data = await RoleAPI.getPage({
      pageNum: query.pageNum,
      pageSize: query.pageSize,
      keywords: query.keywords || undefined,
    });
    rows.value = data.list ?? [];
    total.value = Number(data.total ?? 0);
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
  handleSearch();
}

function handleRefresh() {
  load();
}

function resetForm() {
  editingId.value = undefined;
  Object.assign(form, { name: "", code: "", sort: 1, status: 1, dataScope: 1, remark: "" });
}

function openCreate() {
  resetForm();
  dialogVisible.value = true;
}

function openEdit(row: RoleItem) {
  resetForm();
  editingId.value = row.id;
  Object.assign(form, {
    name: row.name,
    code: row.code,
    sort: row.sort ?? 1,
    status: row.status ?? 1,
    dataScope: row.dataScope ?? 1,
    remark: "",
  });
  dialogVisible.value = true;
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().then(
    () => true,
    () => false
  );
  if (!valid) return;

  saving.value = true;
  try {
    if (editingId.value) {
      await RoleAPI.update(editingId.value, { ...form, id: editingId.value });
      ElMessage.success("角色已更新");
    } else {
      await RoleAPI.create({ ...form });
      ElMessage.success("角色已创建");
    }
    dialogVisible.value = false;
    load();
  } finally {
    saving.value = false;
  }
}

async function handleDelete(row: RoleItem) {
  try {
    await ElMessageBox.confirm(`确定删除角色「${row.name}」吗？`, "提示", {
      type: "warning",
      confirmButtonText: "删除",
      cancelButtonText: "取消",
    });
  } catch {
    return;
  }
  await RoleAPI.deleteByIds(String(row.id));
  ElMessage.success("已删除");
  load();
}

onMounted(load);
</script>

<style lang="scss" scoped>
.ym-code {
  padding: 2px 6px;
  font-family: Consolas, Monaco, monospace;
  font-size: 13px;
  color: #035cff;
  background: #f4f8ff;
  border-radius: 2px;
}

.ym-form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0 16px;
}
</style>
