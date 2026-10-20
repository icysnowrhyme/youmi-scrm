<template>
  <div class="page">
    <header class="page-head">
      <div>
        <h2>活动管理</h2>
        <p>规划市场活动、追踪获客成本与线索转化效果</p>
      </div>
      <el-button v-has-perm="'scrm:campaign:create'" type="primary" @click="openCreate">
        <el-icon><Plus /></el-icon>
        新建活动
      </el-button>
    </header>

    <section class="panel filter-panel">
      <div class="filter-bar">
        <el-input
          v-model="params.keyword"
          class="filter-bar__keyword"
          clearable
          placeholder="搜索活动名称"
          @clear="handleQuery"
          @keyup.enter="handleQuery"
        >
          <template #prefix><el-icon><Search /></el-icon></template>
        </el-input>
        <el-select v-model="params.type" clearable placeholder="活动类型" style="width: 138px">
          <el-option v-for="item in CAMPAIGN_TYPES" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
        <el-select v-model="params.status" clearable placeholder="活动状态" style="width: 138px">
          <el-option v-for="item in CAMPAIGN_STATUSES" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="handleResetQuery">重置</el-button>
      </div>
    </section>

    <section class="panel">
      <el-table v-loading="loading" :data="list" row-key="id">
        <el-table-column label="活动" min-width="230">
          <template #default="{ row }">
            <div class="campaign-cell">
              <strong>{{ row.name }}</strong>
              <small>{{ row.channel || "未填写渠道" }}</small>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="类型" width="110" align="center">
          <template #default="{ row }">
            <el-tag size="small" effect="plain">{{ optionLabel(CAMPAIGN_TYPES, row.type) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="活动周期" width="210">
          <template #default="{ row }">
            <span class="period">{{ formatDate(row.startDate) }} ~ {{ formatDate(row.endDate) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="预算" width="130" align="right">
          <template #default="{ row }">¥ {{ formatMoney(row.budget) }}</template>
        </el-table-column>
        <el-table-column label="线索目标" width="190">
          <template #default="{ row }">
            <div class="lead-progress">
              <el-progress
                :percentage="leadPercent(row as CampaignItem)"
                :stroke-width="7"
                :status="leadPercent(row as CampaignItem) >= 100 ? 'success' : undefined"
              />
              <small>{{ row.leadCount ?? 0 }} / {{ row.targetCount ?? 0 }}</small>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="optionType(CAMPAIGN_STATUSES, row.status)" size="small">
              {{ optionLabel(CAMPAIGN_STATUSES, row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="负责人" width="110">
          <template #default="{ row }">{{ row.ownerName || "-" }}</template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right" align="center">
          <template #default="{ row }">
            <el-button v-has-perm="'scrm:campaign:update'" link type="primary" @click="openEdit(row as CampaignItem)">
              编辑
            </el-button>
            <el-button v-has-perm="'scrm:campaign:delete'" link type="danger" @click="remove(row as CampaignItem)">
              删除
            </el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无市场活动" :image-size="92" />
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
      :title="editingId ? '编辑活动' : '新建活动'"
      width="640px"
      destroy-on-close
      @closed="formRef?.resetFields()"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="92px">
        <el-form-item label="活动名称" prop="name">
          <el-input v-model="form.name" maxlength="100" placeholder="如：秋季产品发布会" />
        </el-form-item>
        <div class="form-grid">
          <el-form-item label="活动类型">
            <el-select v-model="form.type" style="width: 100%">
              <el-option v-for="item in CAMPAIGN_TYPES" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </el-form-item>
          <el-form-item label="活动渠道">
            <el-input v-model="form.channel" maxlength="50" placeholder="如：视频号 / 线下沙龙" />
          </el-form-item>
          <el-form-item label="活动预算">
            <el-input-number
              v-model="form.budget"
              :min="0"
              :max="99999999"
              :step="1000"
              controls-position="right"
              style="width: 100%"
            />
          </el-form-item>
          <el-form-item label="目标线索">
            <el-input-number
              v-model="form.targetCount"
              :min="0"
              :max="999999"
              controls-position="right"
              style="width: 100%"
            />
          </el-form-item>
          <el-form-item label="活动周期">
            <el-date-picker
              v-model="period"
              type="daterange"
              unlink-panels
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              value-format="YYYY-MM-DD"
              style="width: 100%"
              @change="handlePeriodChange"
            />
          </el-form-item>
          <el-form-item label="活动状态">
            <el-select v-model="form.status" style="width: 100%">
              <el-option v-for="item in CAMPAIGN_STATUSES" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
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
import { CampaignAPI } from "@/api/scrm";
import type { CampaignForm, CampaignItem, CampaignQuery } from "@/api/scrm/types";
import { usePageTable } from "@/composables";
import { formatDate, formatMoney } from "@/utils/format";
import {
  CAMPAIGN_STATUSES,
  CAMPAIGN_TYPES,
  optionLabel,
  optionType,
} from "@/views/scrm/constants";

const initialParams: CampaignQuery = {
  pageNum: 1,
  pageSize: 10,
  keyword: "",
  type: undefined,
  status: undefined,
};

const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
  CampaignItem,
  CampaignQuery
>({
  initialParams,
  request: CampaignAPI.getPage,
});

const dialogVisible = ref(false);
const saving = ref(false);
const editingId = ref<string | number>();
const formRef = ref<FormInstance>();
const period = ref<[string, string] | null>(null);

const form = reactive<CampaignForm>({
  name: "",
  type: 1,
  channel: "",
  budget: 0,
  startDate: "",
  endDate: "",
  status: 0,
  targetCount: 100,
  remark: "",
});

const rules: FormRules = {
  name: [{ required: true, message: "请输入活动名称", trigger: "blur" }],
};

onMounted(fetchData);

function leadPercent(row: CampaignItem) {
  const target = Number(row.targetCount ?? 0);
  if (!target) return 0;
  return Math.min(100, Math.round((Number(row.leadCount ?? 0) / target) * 100));
}

function openCreate() {
  editingId.value = undefined;
  Object.assign(form, {
    name: "",
    type: 1,
    channel: "",
    budget: 0,
    startDate: "",
    endDate: "",
    status: 0,
    targetCount: 100,
    remark: "",
  });
  period.value = null;
  dialogVisible.value = true;
}

function openEdit(row: CampaignItem) {
  editingId.value = row.id;
  Object.assign(form, {
    name: row.name,
    type: row.type ?? 1,
    channel: row.channel ?? "",
    budget: Number(row.budget ?? 0),
    startDate: row.startDate ?? "",
    endDate: row.endDate ?? "",
    status: row.status ?? 0,
    targetCount: row.targetCount ?? 0,
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
      await CampaignAPI.update(editingId.value, form);
      ElMessage.success("活动已更新");
    } else {
      await CampaignAPI.create(form);
      ElMessage.success("活动创建成功");
    }
    dialogVisible.value = false;
    fetchData();
  } finally {
    saving.value = false;
  }
}

async function remove(row: CampaignItem) {
  await ElMessageBox.confirm(`确定删除活动「${row.name}」吗？`, "删除确认", {
    type: "warning",
    confirmButtonText: "删除",
    cancelButtonText: "取消",
  });
  await CampaignAPI.remove(String(row.id));
  ElMessage.success("活动已删除");
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
  width: 260px;
}

.campaign-cell {
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.campaign-cell small {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.period {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.lead-progress {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.lead-progress small {
  color: var(--el-text-color-secondary);
  font-size: 11px;
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
