<template>
  <div class="page">
    <header class="page-head">
      <div>
        <h2>商机管理</h2>
        <p>梳理销售漏斗，聚焦高价值、高概率的成交机会</p>
      </div>
      <el-button v-has-perm="'scrm:opportunity:create'" type="primary" @click="openCreate">
        <el-icon><Plus /></el-icon>
        新建商机
      </el-button>
    </header>

    <section class="pipeline">
      <button
        v-for="stage in OPPORTUNITY_STAGES"
        :key="stage.value"
        type="button"
        :class="['pipeline__item', 'pipeline__item--' + stage.value, { 'is-active': params.stage === stage.value }]"
        @click="filterStage(stage.value as number)"
      >
        <strong>{{ String(stage.value).padStart(2, "0") }}</strong>
        <span>{{ stage.label }}</span>
      </button>
    </section>

    <section class="panel filter-panel">
      <div class="filter-bar">
        <el-input
          v-model="params.keyword"
          class="filter-bar__keyword"
          clearable
          placeholder="搜索商机 / 客户"
          @clear="handleQuery"
          @keyup.enter="handleQuery"
        >
          <template #prefix><el-icon><Search /></el-icon></template>
        </el-input>
        <el-select v-model="params.stage" clearable placeholder="商机阶段" style="width: 138px">
          <el-option v-for="item in OPPORTUNITY_STAGES" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="handleResetQuery">重置</el-button>
      </div>
    </section>

    <section class="panel">
      <el-table v-loading="loading" :data="list" row-key="id">
        <el-table-column label="商机" min-width="230">
          <template #default="{ row }">
            <div class="opportunity-cell">
              <strong>{{ row.name }}</strong>
              <small>{{ row.customerName || "-" }}<span v-if="row.customerCompany"> · {{ row.customerCompany }}</span></small>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="金额" width="130" align="right">
          <template #default="{ row }">
            <span class="amount">¥ {{ formatMoney(row.amount) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="阶段" width="110" align="center">
          <template #default="{ row }">
            <el-tag :type="optionType(OPPORTUNITY_STAGES, row.stage)" size="small">
              {{ optionLabel(OPPORTUNITY_STAGES, row.stage) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="赢单概率" width="160">
          <template #default="{ row }">
            <div class="probability">
              <el-progress
                :percentage="row.probability ?? 0"
                :stroke-width="7"
                :status="row.stage === 5 ? 'success' : row.stage === 6 ? 'exception' : undefined"
              />
            </div>
          </template>
        </el-table-column>
        <el-table-column label="预计成交" width="120">
          <template #default="{ row }">{{ formatDate(row.expectedCloseDate) }}</template>
        </el-table-column>
        <el-table-column label="负责人" width="110">
          <template #default="{ row }">{{ row.ownerName || "-" }}</template>
        </el-table-column>
        <el-table-column label="创建时间" width="150">
          <template #default="{ row }">{{ formatDateTime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right" align="center">
          <template #default="{ row }">
            <el-button v-has-perm="'scrm:opportunity:update'" link type="primary" @click="openEdit(row as OpportunityItem)">
              编辑
            </el-button>
            <el-button v-has-perm="'scrm:opportunity:delete'" link type="danger" @click="remove(row as OpportunityItem)">
              删除
            </el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无商机" :image-size="92" />
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
      :title="editingId ? '编辑商机' : '新建商机'"
      width="600px"
      destroy-on-close
      @closed="formRef?.resetFields()"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="92px">
        <el-form-item label="关联客户" prop="customerId">
          <CustomerSelect v-model="form.customerId" :disabled="Boolean(editingId)" />
        </el-form-item>
        <el-form-item label="商机名称" prop="name">
          <el-input v-model="form.name" maxlength="100" placeholder="如：2026 年度采购合作" />
        </el-form-item>
        <div class="form-grid">
          <el-form-item label="商机金额" prop="amount">
            <el-input-number v-model="form.amount" :min="0" :max="999999999" :step="1000" controls-position="right" style="width: 100%" />
          </el-form-item>
          <el-form-item label="预计成交">
            <el-date-picker
              v-model="form.expectedCloseDate"
              type="date"
              value-format="YYYY-MM-DD"
              placeholder="选择日期"
              style="width: 100%"
            />
          </el-form-item>
          <el-form-item label="销售阶段">
            <el-select v-model="form.stage" style="width: 100%" @change="handleStageChange">
              <el-option v-for="item in OPPORTUNITY_STAGES" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </el-form-item>
          <el-form-item label="赢单概率">
            <el-slider v-model="form.probability" :min="0" :max="100" :step="5" show-input />
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
import { OpportunityAPI } from "@/api/scrm";
import type { OpportunityForm, OpportunityItem, OpportunityQuery } from "@/api/scrm/types";
import { usePageTable } from "@/composables";
import { formatDate, formatDateTime, formatMoney } from "@/utils/format";
import {
  OPPORTUNITY_STAGES,
  optionLabel,
  optionType,
} from "@/views/scrm/constants";
import CustomerSelect from "@/views/scrm/components/CustomerSelect.vue";

const initialParams: OpportunityQuery = {
  pageNum: 1,
  pageSize: 10,
  keyword: "",
  stage: undefined,
};

const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
  OpportunityItem,
  OpportunityQuery
>({
  initialParams,
  request: OpportunityAPI.getPage,
});

const dialogVisible = ref(false);
const saving = ref(false);
const editingId = ref<string | number>();
const formRef = ref<FormInstance>();

const form = reactive<OpportunityForm>({
  customerId: null,
  name: "",
  amount: 0,
  stage: 1,
  probability: 10,
  expectedCloseDate: "",
  remark: "",
});

const rules: FormRules = {
  customerId: [{ required: true, message: "请选择关联客户", trigger: "change" }],
  name: [{ required: true, message: "请输入商机名称", trigger: "blur" }],
  amount: [{ required: true, message: "请输入商机金额", trigger: "blur" }],
};

onMounted(fetchData);

function filterStage(stage: number) {
  params.stage = params.stage === stage ? undefined : stage;
  handleQuery();
}

function openCreate() {
  editingId.value = undefined;
  Object.assign(form, {
    customerId: null,
    name: "",
    amount: 0,
    stage: 1,
    probability: 10,
    expectedCloseDate: "",
    remark: "",
  });
  dialogVisible.value = true;
}

function openEdit(row: OpportunityItem) {
  editingId.value = row.id;
  Object.assign(form, {
    customerId: row.customerId,
    name: row.name,
    amount: Number(row.amount ?? 0),
    stage: row.stage ?? 1,
    probability: row.probability ?? 0,
    expectedCloseDate: row.expectedCloseDate ?? "",
    remark: row.remark ?? "",
  });
  dialogVisible.value = true;
}

function handleStageChange(stage: number) {
  if (stage === 5) form.probability = 100;
  else if (stage === 6) form.probability = 0;
}

async function submit() {
  const valid = await formRef.value?.validate().catch(() => false);
  if (!valid) return;
  saving.value = true;
  try {
    if (editingId.value) {
      await OpportunityAPI.update(editingId.value, form);
      ElMessage.success("商机已更新");
    } else {
      await OpportunityAPI.create(form);
      ElMessage.success("商机创建成功");
    }
    dialogVisible.value = false;
    fetchData();
  } finally {
    saving.value = false;
  }
}

async function remove(row: OpportunityItem) {
  await ElMessageBox.confirm(`确定删除商机「${row.name}」吗？`, "删除确认", {
    type: "warning",
    confirmButtonText: "删除",
    cancelButtonText: "取消",
  });
  await OpportunityAPI.remove(String(row.id));
  ElMessage.success("商机已删除");
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

.pipeline {
  display: grid;
  grid-template-columns: repeat(6, minmax(0, 1fr));
  gap: 10px;
}

.pipeline__item {
  display: flex;
  padding: 12px 14px;
  flex-direction: column;
  gap: 4px;
  text-align: left;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 12px;
  background: var(--el-bg-color);
  cursor: pointer;
  transition: border-color 0.2s ease, transform 0.2s ease;
}

.pipeline__item span {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.pipeline__item strong {
  color: var(--el-text-color-primary);
  font-size: 13px;
  font-weight: 600;
}

.pipeline__item:hover,
.pipeline__item.is-active {
  border-color: var(--el-color-primary);
  transform: translateY(-1px);
}

.pipeline__item.is-active {
  background: var(--el-color-primary-light-9);
}

.pipeline__item--1 strong { color: #64748b; }
.pipeline__item--2 strong { color: #3b82f6; }
.pipeline__item--3 strong { color: #f59e0b; }
.pipeline__item--4 strong { color: #ef4444; }
.pipeline__item--5 strong { color: #10b981; }
.pipeline__item--6 strong { color: #94a3b8; }

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
  width: 260px;
}

.opportunity-cell {
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.opportunity-cell small {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.amount {
  color: var(--el-text-color-primary);
  font-weight: 600;
}

.probability :deep(.el-progress__text) {
  min-width: 36px;
  font-size: 12px !important;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0 18px;
}

@media (max-width: 1000px) {
  .pipeline {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 700px) {
  .pipeline {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .form-grid {
    grid-template-columns: 1fr;
  }

  .filter-bar__keyword {
    width: 100%;
  }
}
</style>
