<template>
  <div class="ym-page">
    <div class="ym-page-title">{{ pageTitle }}</div>

    <div class="ym-filter-card">
      <div class="ym-filter-row">
        <div class="ym-filter-field ym-filter-field--wide">
          <span class="ym-filter-label">关键字</span>
          <el-input v-model="query.keyword" clearable placeholder="请输入订单编号、客户名称或订单名称" @keyup.enter="handleSearch" />
        </div>
        <div v-if="!isAudit" class="ym-filter-field">
          <span class="ym-filter-label">订单状态</span>
          <el-select v-model="query.status" clearable placeholder="请选择订单状态">
            <el-option v-for="item in YM_ORDER_STATUSES" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </div>
        <div class="ym-filter-field">
          <span class="ym-filter-label">下单时间</span>
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            value-format="YYYY-MM-DD"
            range-separator="-"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
          />
        </div>
        <div class="ym-filter-actions">
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </div>
      </div>
    </div>

    <div class="ym-panel">
      <div class="ym-panel-header">
        <div class="ym-panel-title">{{ isAudit ? "待审核订单" : "订单列表" }}</div>
        <div class="ym-toolbar">
          <el-button type="primary" @click="openCreate">新建订单</el-button>
          <el-button plain @click="handleExport">导出订单</el-button>
          <el-button v-if="isAudit" plain :disabled="selection.length === 0" @click="handleBatchAudit">
            批量审核
          </el-button>
        </div>
      </div>

      <el-table v-loading="loading" :data="rows" border row-key="id" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="44" />
        <el-table-column label="订单编号" min-width="160">
          <template #default="{ row }">
            <span class="ym-order-no">{{ row.contractNo || `O${String(row.id).padStart(8, "0")}` }}</span>
          </template>
        </el-table-column>
        <el-table-column label="客户名称" min-width="140" show-overflow-tooltip>
          <template #default="{ row }">{{ row.customerName || "-" }}</template>
        </el-table-column>
        <el-table-column prop="name" label="订单名称" min-width="160" show-overflow-tooltip />
        <el-table-column label="订单金额" width="130" align="right">
          <template #default="{ row }">￥{{ ymMoney(row.amount) }}</template>
        </el-table-column>
        <el-table-column label="下单时间" width="150">
          <template #default="{ row }">{{ row.signDate || row.createTime || "-" }}</template>
        </el-table-column>
        <el-table-column label="归属员工" width="120">
          <template #default="{ row }">{{ row.ownerName || "-" }}</template>
        </el-table-column>
        <el-table-column label="订单状态" width="110">
          <template #default="{ row }">
            <el-tag :type="ymOrderStatus(row.status).type" size="small" effect="plain">
              {{ ymOrderStatus(row.status).label }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openDetail(row)">详情</el-button>
            <template v-if="isAudit">
              <el-button link type="primary" @click="handleAudit(row, 2)">通过</el-button>
              <el-button link type="danger" @click="handleAudit(row, 4)">驳回</el-button>
            </template>
            <template v-else>
              <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
              <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
            </template>
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

    <el-dialog v-model="formVisible" :title="formTitle" width="620px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="96px">
        <el-form-item label="订单名称" prop="name">
          <el-input v-model="form.name" maxlength="60" placeholder="请输入订单名称" />
        </el-form-item>
        <el-form-item label="客户" prop="customerId">
          <el-select v-model="form.customerId" filterable clearable placeholder="请选择客户" style="width: 100%">
            <el-option
              v-for="item in customerOptions"
              :key="item.id"
              :label="item.company ? `${item.name}（${item.company}）` : item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <div class="ym-form-row">
          <el-form-item label="订单金额" prop="amount">
            <el-input-number v-model="form.amount" :min="0" :precision="2" :controls="false" placeholder="0.00" style="width: 100%" />
          </el-form-item>
          <el-form-item label="订单状态" prop="status">
            <el-select v-model="form.status" placeholder="请选择" style="width: 100%">
              <el-option v-for="item in YM_ORDER_STATUSES" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </el-form-item>
        </div>
        <div class="ym-form-row">
          <el-form-item label="下单日期">
            <el-date-picker v-model="form.signDate" type="date" value-format="YYYY-MM-DD" placeholder="请选择日期" style="width: 100%" />
          </el-form-item>
          <el-form-item label="交付日期">
            <el-date-picker v-model="form.endDate" type="date" value-format="YYYY-MM-DD" placeholder="请选择日期" style="width: 100%" />
          </el-form-item>
        </div>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="3" maxlength="200" show-word-limit placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="formVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <el-drawer v-model="detailVisible" title="订单详情" size="480px">
      <el-descriptions v-if="detail" :column="1" border label-width="100px">
        <el-descriptions-item label="订单编号">{{ detail.contractNo || `O${String(detail.id).padStart(8, "0")}` }}</el-descriptions-item>
        <el-descriptions-item label="订单名称">{{ detail.name }}</el-descriptions-item>
        <el-descriptions-item label="客户名称">{{ detail.customerName || "-" }}</el-descriptions-item>
        <el-descriptions-item label="订单金额">￥{{ ymMoney(detail.amount) }}</el-descriptions-item>
        <el-descriptions-item label="订单状态">
          <el-tag :type="ymOrderStatus(detail.status).type" size="small" effect="plain">
            {{ ymOrderStatus(detail.status).label }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="下单日期">{{ detail.signDate || "-" }}</el-descriptions-item>
        <el-descriptions-item label="开始日期">{{ detail.startDate || "-" }}</el-descriptions-item>
        <el-descriptions-item label="结束日期">{{ detail.endDate || "-" }}</el-descriptions-item>
        <el-descriptions-item label="归属员工">{{ detail.ownerName || "-" }}</el-descriptions-item>
        <el-descriptions-item label="备注">{{ detail.remark || "-" }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ detail.createTime || "-" }}</el-descriptions-item>
      </el-descriptions>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "YoumiOrderList" });

import { ElMessage, ElMessageBox } from "element-plus";
import type { FormInstance, FormRules } from "element-plus";
import { useRoute } from "vue-router";
import { ContractAPI, CustomerAPI } from "@/api/scrm";
import type { ContractForm, ContractItem, CustomerOption } from "@/api/scrm/types";
import { YM_ORDER_STATUSES, ymMoney, ymOrderStatus } from "@/youmi/constants";

const route = useRoute();

const pageTitle = computed(() => (route.meta.title as string) || "订单列表");
const isAudit = computed(() => route.meta.audit === true);

const loading = ref(false);
const saving = ref(false);
const rows = ref<ContractItem[]>([]);
const total = ref(0);
const selection = ref<ContractItem[]>([]);
const dateRange = ref<[string, string] | null>(null);
const customerOptions = ref<CustomerOption[]>([]);

const query = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: "",
  status: undefined as number | undefined,
});

const formVisible = ref(false);
const formRef = ref<FormInstance>();
const editingId = ref<string | number>();
const form = reactive<ContractForm>({
  name: "",
  customerId: null,
  amount: 0,
  signDate: "",
  startDate: "",
  endDate: "",
  status: 1,
  remark: "",
});

const rules: FormRules = {
  name: [{ required: true, message: "请输入订单名称", trigger: "blur" }],
  customerId: [{ required: true, message: "请选择客户", trigger: "change" }],
};

const formTitle = computed(() => (editingId.value ? "编辑订单" : "新建订单"));

const detailVisible = ref(false);
const detail = ref<ContractItem>();

async function load() {
  loading.value = true;
  try {
    const data = await ContractAPI.getPage({
      pageNum: query.pageNum,
      pageSize: query.pageSize,
      keyword: query.keyword || undefined,
      status: isAudit.value ? 1 : query.status,
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
  query.keyword = "";
  query.status = undefined;
  dateRange.value = null;
  handleSearch();
}

function handleSelectionChange(list: ContractItem[]) {
  selection.value = list;
}

async function loadCustomerOptions() {
  if (customerOptions.value.length) return;
  customerOptions.value = await CustomerAPI.getOptions();
}

function resetForm() {
  editingId.value = undefined;
  Object.assign(form, {
    name: "",
    customerId: null,
    amount: 0,
    signDate: "",
    startDate: "",
    endDate: "",
    status: 1,
    remark: "",
  });
}

async function openCreate() {
  resetForm();
  await loadCustomerOptions();
  formVisible.value = true;
}

async function openEdit(row: any) {
  resetForm();
  await loadCustomerOptions();
  editingId.value = row.id;
  Object.assign(form, {
    name: row.name,
    customerId: row.customerId,
    amount: Number(row.amount ?? 0),
    signDate: row.signDate || "",
    startDate: row.startDate || "",
    endDate: row.endDate || "",
    status: row.status ?? 1,
    remark: row.remark || "",
  });
  formVisible.value = true;
}

function openDetail(row: any) {
  detail.value = row;
  detailVisible.value = true;
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
      await ContractAPI.update(editingId.value, { ...form });
    } else {
      await ContractAPI.create({ ...form });
    }
    ElMessage.success(editingId.value ? "订单已更新" : "订单已创建");
    formVisible.value = false;
    load();
  } finally {
    saving.value = false;
  }
}

async function handleAudit(row: any, status: number) {
  const action = status === 2 ? "通过" : "驳回";
  try {
    await ElMessageBox.confirm(`确定${action}订单「${row.name}」吗？`, "审核确认", {
      type: "warning",
      confirmButtonText: "确定",
      cancelButtonText: "取消",
    });
  } catch {
    return;
  }
  await ContractAPI.update(row.id, {
    customerId: row.customerId,
    name: row.name,
    amount: Number(row.amount ?? 0),
    signDate: row.signDate,
    startDate: row.startDate,
    endDate: row.endDate,
    status,
    ownerId: row.ownerId,
    remark: row.remark,
  });
  ElMessage.success(`订单已${action}`);
  load();
}

async function handleBatchAudit() {
  if (!selection.value.length) return;
  try {
    await ElMessageBox.confirm(`确定通过选中的 ${selection.value.length} 个订单吗？`, "批量审核", {
      type: "warning",
      confirmButtonText: "确定",
      cancelButtonText: "取消",
    });
  } catch {
    return;
  }
  for (const row of selection.value) {
    await ContractAPI.update(row.id, {
      customerId: row.customerId,
      name: row.name,
      amount: Number(row.amount ?? 0),
      signDate: row.signDate,
      startDate: row.startDate,
      endDate: row.endDate,
      status: 2,
      ownerId: row.ownerId,
      remark: row.remark,
    });
  }
  ElMessage.success("所选订单已审核通过");
  load();
}

async function handleDelete(row: any) {
  try {
    await ElMessageBox.confirm(`确定删除订单「${row.name}」吗？`, "提示", {
      type: "warning",
      confirmButtonText: "删除",
      cancelButtonText: "取消",
    });
  } catch {
    return;
  }
  await ContractAPI.remove(String(row.id));
  ElMessage.success("已删除");
  load();
}

function handleExport() {
  if (!rows.value.length) {
    ElMessage.warning("暂无可导出的订单数据");
    return;
  }
  const header = ["订单编号", "客户名称", "订单名称", "订单金额", "下单时间", "归属员工", "订单状态"];
  const lines = rows.value.map((row) =>
    [
      row.contractNo || `O${String(row.id).padStart(8, "0")}`,
      row.customerName || "-",
      row.name,
      ymMoney(row.amount),
      row.signDate || row.createTime || "-",
      row.ownerName || "-",
      ymOrderStatus(row.status).label,
    ]
      .map((cell) => `"${String(cell).replace(/"/g, '""')}"`)
      .join(",")
  );
  const blob = new Blob([`\uFEFF${header.join(",")}\n${lines.join("\n")}`], { type: "text/csv;charset=utf-8" });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = `订单列表_${new Date().toISOString().slice(0, 10)}.csv`;
  link.click();
  URL.revokeObjectURL(link.href);
}

onMounted(load);
</script>

<style lang="scss" scoped>
.ym-order-no {
  font-family: Consolas, Monaco, monospace;
  color: #035cff;
}

.ym-form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0 16px;
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
</style>
