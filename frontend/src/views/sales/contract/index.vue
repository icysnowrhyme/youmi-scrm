<template>
  <div class="page">
    <header class="page-head">
      <div>
        <h2>合同管理</h2>
        <p>管理签约、执行与回款节点，沉淀客户成交资产</p>
      </div>
      <el-button v-has-perm="'scrm:contract:create'" type="primary" @click="openCreate">
        <el-icon><Plus /></el-icon>
        新建合同
      </el-button>
    </header>

    <section class="panel filter-panel">
      <div class="filter-bar">
        <el-input
          v-model="params.keyword"
          class="filter-bar__keyword"
          clearable
          placeholder="搜索合同名称 / 编号 / 客户"
          @clear="handleQuery"
          @keyup.enter="handleQuery"
        >
          <template #prefix><el-icon><Search /></el-icon></template>
        </el-input>
        <el-select v-model="params.status" clearable placeholder="合同状态" style="width: 138px">
          <el-option v-for="item in CONTRACT_STATUSES" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="handleResetQuery">重置</el-button>
      </div>
    </section>

    <section class="panel">
      <el-table v-loading="loading" :data="list" row-key="id">
        <el-table-column label="合同" min-width="240">
          <template #default="{ row }">
            <div class="contract-cell">
              <strong>{{ row.name }}</strong>
              <small>{{ row.contractNo || "—" }}</small>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="客户" min-width="170">
          <template #default="{ row }">
            <div class="contract-cell">
              <span>{{ row.customerName || "-" }}</span>
              <small>{{ row.customerCompany || "—" }}</small>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="合同金额" width="150" align="right">
          <template #default="{ row }">
            <span :class="['amount', { 'is-active': row.status === 2 || row.status === 3 }]">
              ¥ {{ formatMoney(row.amount) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="optionType(CONTRACT_STATUSES, row.status)" size="small">
              {{ optionLabel(CONTRACT_STATUSES, row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="签署日期" width="120">
          <template #default="{ row }">{{ formatDate(row.signDate) }}</template>
        </el-table-column>
        <el-table-column label="合同期限" width="210">
          <template #default="{ row }">
            <span class="period">{{ formatDate(row.startDate) }} ~ {{ formatDate(row.endDate) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="负责人" width="110">
          <template #default="{ row }">{{ row.ownerName || "-" }}</template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right" align="center">
          <template #default="{ row }">
            <el-button v-has-perm="'scrm:contract:update'" link type="primary" @click="openEdit(row as ContractItem)">
              编辑
            </el-button>
            <el-button v-has-perm="'scrm:contract:delete'" link type="danger" @click="remove(row as ContractItem)">
              删除
            </el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无合同" :image-size="92" />
        </template>
      </el-table>

      <Pagination
        v-model:page="params.pageNum"
        v-model:limit="params.pageSize"
        :total="total"
        @pagination="fetchData"
      />
    </section>

    <el-dialog
      v-model="dialogVisible"
      :title="editingId ? '编辑合同' : '新建合同'"
      width="640px"
      destroy-on-close
      @closed="formRef?.resetFields()"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="94px">
        <el-form-item label="关联客户" prop="customerId">
          <CustomerSelect v-model="form.customerId" :disabled="Boolean(editingId)" />
        </el-form-item>
        <el-form-item label="合同名称" prop="name">
          <el-input v-model="form.name" maxlength="100" placeholder="如：年度软件服务合同" />
        </el-form-item>
        <div class="form-grid">
          <el-form-item label="合同金额" prop="amount">
            <el-input-number
              v-model="form.amount"
              :min="0"
              :max="999999999"
              :step="1000"
              controls-position="right"
              style="width: 100%"
            />
          </el-form-item>
          <el-form-item label="合同状态">
            <el-select v-model="form.status" style="width: 100%">
              <el-option v-for="item in CONTRACT_STATUSES" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </el-form-item>
          <el-form-item label="签署日期">
            <el-date-picker
              v-model="form.signDate"
              type="date"
              value-format="YYYY-MM-DD"
              placeholder="选择签署日期"
              style="width: 100%"
            />
          </el-form-item>
          <el-form-item label="合同期限">
            <el-date-picker
              v-model="period"
              type="daterange"
              unlink-panels
              range-separator="至"
              start-placeholder="生效日期"
              end-placeholder="到期日期"
              value-format="YYYY-MM-DD"
              style="width: 100%"
              @change="handlePeriodChange"
            />
          </el-form-item>
        </div>
        <el-form-item label="备注">
          <el-input v-model="form.remark" :rows="3" maxlength="500" show-word-limit type="textarea" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button :loading="saving" type="primary" @click="submit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from "element-plus";
import { ContractAPI } from "@/api/scrm";
import type { ContractForm, ContractItem, ContractQuery } from "@/api/scrm/types";
import { usePageTable } from "@/composables";
import { formatDate, formatMoney } from "@/utils/format";
import {
  CONTRACT_STATUSES,
  optionLabel,
  optionType,
} from "@/views/scrm/constants";
import CustomerSelect from "@/views/scrm/components/CustomerSelect.vue";

const initialParams: ContractQuery = {
  pageNum: 1,
  pageSize: 10,
  keyword: "",
  status: undefined,
};

const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
  ContractItem,
  ContractQuery
>({
  initialParams,
  request: ContractAPI.getPage,
});

const dialogVisible = ref(false);
const saving = ref(false);
const editingId = ref<string | number>();
const formRef = ref<FormInstance>();
const period = ref<[string, string] | null>(null);

const form = reactive<ContractForm>({
  customerId: null,
  name: "",
  amount: 0,
  signDate: "",
  startDate: "",
  endDate: "",
  status: 1,
  remark: "",
});

const rules: FormRules = {
  customerId: [{ required: true, message: "请选择关联客户", trigger: "change" }],
  name: [{ required: true, message: "请输入合同名称", trigger: "blur" }],
  amount: [{ required: true, message: "请输入合同金额", trigger: "blur" }],
};

onMounted(fetchData);

function openCreate() {
  editingId.value = undefined;
  Object.assign(form, {
    customerId: null,
    name: "",
    amount: 0,
    signDate: "",
    startDate: "",
    endDate: "",
    status: 1,
    remark: "",
  });
  period.value = null;
  dialogVisible.value = true;
}

function openEdit(row: ContractItem) {
  editingId.value = row.id;
  Object.assign(form, {
    customerId: row.customerId,
    name: row.name,
    amount: Number(row.amount ?? 0),
    signDate: row.signDate ?? "",
    startDate: row.startDate ?? "",
    endDate: row.endDate ?? "",
    status: row.status ?? 1,
    remark: row.remark ?? "",
  });
  period.value = row.startDate && row.endDate ? [row.startDate, row.endDate] : null;
  dialogVisible.value = true;
}

function handlePeriodChange(value: [string, string] | null) {
  form.startDate = value?.[0] ?? "";
  form.endDate = value?.[1] ?? "";
}

async function submit() {
  const valid = await formRef.value?.validate().catch(() => false);
  if (!valid) return;
  saving.value = true;
  try {
    if (editingId.value) {
      await ContractAPI.update(editingId.value, form);
      ElMessage.success("合同已更新");
    } else {
      await ContractAPI.create(form);
      ElMessage.success("合同创建成功");
    }
    dialogVisible.value = false;
    fetchData();
  } finally {
    saving.value = false;
  }
}

async function remove(row: ContractItem) {
  await ElMessageBox.confirm(`确定删除合同「${row.name}」吗？`, "删除确认", {
    type: "warning",
    confirmButtonText: "删除",
    cancelButtonText: "取消",
  });
  await ContractAPI.remove(String(row.id));
  ElMessage.success("合同已删除");
  fetchData();
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
  width: 280px;
}

.contract-cell {
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.contract-cell small {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.amount {
  color: var(--el-text-color-regular);
  font-weight: 600;
}

.amount.is-active {
  color: var(--el-color-success);
}

.period {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0 18px;
}

@media (max-width: 760px) {
  .form-grid {
    grid-template-columns: 1fr;
  }

  .filter-bar__keyword {
    width: 100%;
  }
}
</style>
