<template>
  <div class="page">
    <header class="page-head">
      <div>
        <h2>客户列表</h2>
        <p>集中管理客户档案、跟进节奏与成交转化</p>
      </div>
      <div class="page-head__actions">
        <el-button v-has-perm="'scrm:customer:create'" type="primary" @click="openCreate">
          <el-icon><Plus /></el-icon>
          新建客户
        </el-button>
      </div>
    </header>

    <section class="panel filter-panel">
      <div class="filter-bar">
        <el-input
          v-model="params.keyword"
          class="filter-bar__keyword"
          clearable
          placeholder="搜索姓名 / 公司 / 手机号"
          @clear="handleQuery"
          @keyup.enter="handleQuery"
        >
          <template #prefix><el-icon><Search /></el-icon></template>
        </el-input>
        <el-select v-model="params.level" clearable placeholder="客户等级" style="width: 128px">
          <el-option v-for="item in CUSTOMER_LEVELS" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
        <el-select v-model="params.status" clearable placeholder="客户状态" style="width: 128px">
          <el-option v-for="item in CUSTOMER_STATUSES" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
        <el-select v-model="params.source" clearable placeholder="客户来源" style="width: 128px">
          <el-option v-for="item in CUSTOMER_SOURCES" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
        <el-select v-model="params.tagId" clearable placeholder="客户标签" style="width: 138px">
          <el-option v-for="tag in tagList" :key="tag.id" :label="tag.name" :value="tag.id" />
        </el-select>
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="handleResetQuery">重置</el-button>
      </div>
    </section>

    <section class="panel table-panel">
      <div class="table-toolbar">
        <div class="table-toolbar__info">
          共 <strong>{{ total }}</strong> 位客户
          <span v-if="selectedIds.length" class="selection-tip">已选 {{ selectedIds.length }} 位</span>
        </div>
        <div class="table-toolbar__actions">
          <el-button
            v-if="canAssign"
            :disabled="!selectedIds.length"
            plain
            @click="openAssign()"
          >
            批量分配
          </el-button>
          <el-button
            v-has-perm="'scrm:customer:delete'"
            :disabled="!selectedIds.length"
            plain
            type="danger"
            @click="removeSelected"
          >
            批量删除
          </el-button>
        </div>
      </div>

      <el-table
        v-loading="loading"
        :data="list"
        row-key="id"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="44" align="center" />
        <el-table-column label="客户" min-width="210" fixed="left">
          <template #default="{ row }">
            <button class="customer-cell" type="button" @click="openDetail(row as CustomerItem)">
              <span class="customer-cell__avatar">{{ row.name?.slice(0, 1) }}</span>
              <span class="customer-cell__body">
                <strong>{{ row.name }}</strong>
                <small>{{ row.company || "未填写公司" }}</small>
              </span>
            </button>
          </template>
        </el-table-column>
        <el-table-column label="联系方式" min-width="150">
          <template #default="{ row }">
            <div class="stacked">
              <span>{{ row.phone || "-" }}</span>
              <small v-if="row.wechat">微信 {{ row.wechat }}</small>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="标签" min-width="180">
          <template #default="{ row }">
            <div v-if="row.tags?.length" class="tag-row">
              <el-tag
                v-for="tag in row.tags.slice(0, 3)"
                :key="tag.id"
                size="small"
                effect="plain"
                :style="{ color: tag.color, borderColor: tag.color, background: `${tag.color}14` }"
              >
                {{ tag.name }}
              </el-tag>
              <el-tooltip v-if="row.tags.length > 3" :content="row.tags.map((t: ScrmTag) => t.name).join('、')">
                <span class="tag-more">+{{ row.tags.length - 3 }}</span>
              </el-tooltip>
            </div>
            <span v-else class="muted">-</span>
          </template>
        </el-table-column>
        <el-table-column label="等级" width="92" align="center">
          <template #default="{ row }">
            <el-tag :type="optionType(CUSTOMER_LEVELS, row.level)" effect="dark" size="small">
              {{ row.level || "-" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="optionType(CUSTOMER_STATUSES, row.status)" size="small">
              {{ optionLabel(CUSTOMER_STATUSES, row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="来源" width="96">
          <template #default="{ row }">{{ optionLabel(CUSTOMER_SOURCES, row.source) }}</template>
        </el-table-column>
        <el-table-column label="负责人" width="110">
          <template #default="{ row }">
            <span v-if="row.ownerName">{{ row.ownerName }}</span>
            <el-tag v-else type="info" size="small">公海</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="下次跟进" width="150">
          <template #default="{ row }">
            <span :class="['follow-time', followTone(row.nextFollowTime)]">
              {{ formatDateTime(row.nextFollowTime) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" width="150">
          <template #default="{ row }">{{ formatDateTime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="158" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="openDetail(row as CustomerItem)">详情</el-button>
            <el-button link type="primary" @click="openFollow(row as CustomerItem)">跟进</el-button>
            <el-dropdown trigger="click" @command="(command: string) => handleCommand(command, row as CustomerItem)">
              <el-button link type="primary">
                更多<el-icon class="el-icon--right"><ArrowDown /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item v-if="canAssign" command="assign">分配负责人</el-dropdown-item>
                  <el-dropdown-item command="edit">编辑客户</el-dropdown-item>
                  <el-dropdown-item v-has-perm="'scrm:customer:delete'" command="delete" divided>
                    删除客户
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无客户，试试调整筛选条件" :image-size="92" />
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
      v-model="formVisible"
      :title="editingId ? '编辑客户' : '新建客户'"
      width="760px"
      destroy-on-close
      @closed="handleFormClosed"
    >
      <el-form ref="formRef" v-loading="formLoading" :model="form" :rules="rules" label-width="88px">
        <div class="form-grid">
          <el-form-item label="客户姓名" prop="name">
            <el-input v-model="form.name" maxlength="50" placeholder="请输入客户姓名" />
          </el-form-item>
          <el-form-item label="公司名称">
            <el-input v-model="form.company" maxlength="100" placeholder="请输入公司名称" />
          </el-form-item>
          <el-form-item label="手机号" prop="phone">
            <el-input v-model="form.phone" maxlength="20" placeholder="请输入手机号" />
          </el-form-item>
          <el-form-item label="微信号">
            <el-input v-model="form.wechat" maxlength="50" placeholder="请输入微信号" />
          </el-form-item>
          <el-form-item label="邮箱" prop="email">
            <el-input v-model="form.email" maxlength="100" placeholder="请输入邮箱" />
          </el-form-item>
          <el-form-item label="职位">
            <el-input v-model="form.position" maxlength="50" placeholder="如：采购总监" />
          </el-form-item>
          <el-form-item label="所属行业">
            <el-input v-model="form.industry" maxlength="50" placeholder="如：企业服务" />
          </el-form-item>
          <el-form-item label="客户等级">
            <el-select v-model="form.level" style="width: 100%">
              <el-option v-for="item in CUSTOMER_LEVELS" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </el-form-item>
          <el-form-item label="客户来源">
            <el-select v-model="form.source" style="width: 100%">
              <el-option v-for="item in CUSTOMER_SOURCES" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </el-form-item>
          <el-form-item label="客户状态">
            <el-select v-model="form.status" style="width: 100%">
              <el-option v-for="item in CUSTOMER_STATUSES" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </el-form-item>
          <el-form-item label="下次跟进">
            <el-date-picker
              v-model="form.nextFollowTime"
              type="datetime"
              value-format="YYYY-MM-DD HH:mm:ss"
              placeholder="选择跟进时间"
              style="width: 100%"
            />
          </el-form-item>
          <el-form-item label="客户标签">
            <el-select v-model="form.tagIds" multiple collapse-tags collapse-tags-tooltip style="width: 100%">
              <el-option v-for="tag in tagList" :key="tag.id" :label="tag.name" :value="tag.id" />
            </el-select>
          </el-form-item>
          <el-form-item class="form-grid__full" label="地址">
            <el-input v-model="form.address" maxlength="200" placeholder="请输入客户地址" />
          </el-form-item>
          <el-form-item class="form-grid__full" label="备注">
            <el-input v-model="form.remark" :rows="3" maxlength="500" show-word-limit type="textarea" />
          </el-form-item>
        </div>
      </el-form>
      <template #footer>
        <el-button @click="formVisible = false">取消</el-button>
        <el-button :loading="saving" type="primary" @click="submitForm">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="assignVisible" title="分配客户" width="440px">
      <p class="assign-tip">
        已选择 <strong>{{ assignTargets.length }}</strong> 位客户，选择新的负责人；留空则移入客户公海。
      </p>
      <el-select v-model="assignOwnerId" clearable filterable placeholder="选择负责人" style="width: 100%">
        <el-option v-for="user in userOptions" :key="user.value" :label="user.label" :value="user.value" />
      </el-select>
      <template #footer>
        <el-button @click="assignVisible = false">取消</el-button>
        <el-button :loading="assigning" type="primary" @click="submitAssign">确认分配</el-button>
      </template>
    </el-dialog>

    <CustomerDetailDrawer
      v-model="detailVisible"
      :customer-id="currentCustomerId"
      @updated="fetchData"
    />

    <FollowUpDialog
      v-model="followVisible"
      :customer-id="followCustomer?.id"
      :customer-name="followCustomer?.name"
      @saved="handleFollowSaved"
    />
  </div>
</template>

<script setup lang="ts">
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from "element-plus";
import { CustomerAPI, TagAPI } from "@/api/scrm";
import type {
  CustomerForm,
  CustomerItem,
  CustomerQuery,
  ScrmTag,
} from "@/api/scrm/types";
import UserAPI from "@/api/system/user";
import type { OptionItem } from "@/api/common";
import { usePageTable } from "@/composables";
import { hasPerm } from "@/utils/auth";
import { formatDateTime } from "@/utils/format";
import {
  CUSTOMER_LEVELS,
  CUSTOMER_SOURCES,
  CUSTOMER_STATUSES,
  optionLabel,
  optionType,
} from "@/views/scrm/constants";
import CustomerDetailDrawer from "@/views/scrm/components/CustomerDetailDrawer.vue";
import FollowUpDialog from "@/views/scrm/components/FollowUpDialog.vue";

const initialParams: CustomerQuery = {
  pageNum: 1,
  pageSize: 10,
  keyword: "",
  level: "",
  status: undefined,
  source: undefined,
  tagId: undefined,
};

const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
  CustomerItem,
  CustomerQuery
>({
  initialParams,
  request: CustomerAPI.getPage,
});

const tagList = ref<ScrmTag[]>([]);
const userOptions = ref<OptionItem[]>([]);
const canAssign = computed(() => hasPerm("scrm:customer:assign"));

const selection = ref<CustomerItem[]>([]);
const selectedIds = computed(() => selection.value.map((item) => item.id));

const formVisible = ref(false);
const formLoading = ref(false);
const saving = ref(false);
const editingId = ref<string | number>();
const formRef = ref<FormInstance>();

const form = reactive<CustomerForm>({
  name: "",
  shortName: "",
  phone: "",
  wechat: "",
  email: "",
  company: "",
  position: "",
  industry: "",
  level: "C",
  source: 6,
  status: 1,
  address: "",
  remark: "",
  nextFollowTime: "",
  tagIds: [],
});

const rules: FormRules = {
  name: [{ required: true, message: "请输入客户姓名", trigger: "blur" }],
  phone: [{ pattern: /^1[3-9]\d{9}$/, message: "手机号格式不正确", trigger: "blur" }],
  email: [{ type: "email", message: "邮箱格式不正确", trigger: "blur" }],
};

const detailVisible = ref(false);
const currentCustomerId = ref<string | number>();

const followVisible = ref(false);
const followCustomer = ref<CustomerItem>();

const assignVisible = ref(false);
const assignTargets = ref<CustomerItem[]>([]);
const assignOwnerId = ref<string | number | null>(null);
const assigning = ref(false);

onMounted(async () => {
  fetchData();
  tagList.value = await TagAPI.list();
  if (canAssign.value) {
    userOptions.value = await UserAPI.getOptions();
  }
});

function handleSelectionChange(rows: CustomerItem[]) {
  selection.value = rows;
}

function followTone(value?: string) {
  if (!value) return "";
  const time = new Date(value.replace(" ", "T")).getTime();
  if (Number.isNaN(time)) return "";
  const diff = time - Date.now();
  if (diff < 0) return "is-overdue";
  if (diff < 24 * 3600 * 1000) return "is-soon";
  return "";
}

function openCreate() {
  editingId.value = undefined;
  Object.assign(form, {
    name: "",
    shortName: "",
    phone: "",
    wechat: "",
    email: "",
    company: "",
    position: "",
    industry: "",
    level: "C",
    source: 6,
    status: 1,
    address: "",
    remark: "",
    nextFollowTime: "",
    tagIds: [],
  });
  formVisible.value = true;
}

async function openEdit(row: CustomerItem) {
  editingId.value = row.id;
  formVisible.value = true;
  formLoading.value = true;
  try {
    const detail = await CustomerAPI.getDetail(row.id);
    Object.assign(form, {
      name: detail.name,
      shortName: detail.shortName ?? "",
      phone: detail.phone ?? "",
      wechat: detail.wechat ?? "",
      email: detail.email ?? "",
      company: detail.company ?? "",
      position: detail.position ?? "",
      industry: detail.industry ?? "",
      level: detail.level ?? "C",
      source: detail.source ?? 6,
      status: detail.status ?? 1,
      address: detail.address ?? "",
      remark: detail.remark ?? "",
      nextFollowTime: detail.nextFollowTime ?? "",
      tagIds: detail.tags?.map((tag) => tag.id!) ?? [],
    });
  } finally {
    formLoading.value = false;
  }
}

async function submitForm() {
  const valid = await formRef.value?.validate().catch(() => false);
  if (!valid) return;
  saving.value = true;
  try {
    if (editingId.value) {
      await CustomerAPI.update(editingId.value, form);
      ElMessage.success("客户信息已更新");
    } else {
      await CustomerAPI.create(form);
      ElMessage.success("客户创建成功");
    }
    formVisible.value = false;
    fetchData();
  } finally {
    saving.value = false;
  }
}

function handleFormClosed() {
  formRef.value?.resetFields();
}

function openDetail(row: CustomerItem) {
  currentCustomerId.value = row.id;
  detailVisible.value = true;
}

function openFollow(row: CustomerItem) {
  followCustomer.value = row;
  followVisible.value = true;
}

function handleFollowSaved() {
  fetchData();
}

function openAssign(rows?: CustomerItem[]) {
  assignTargets.value = rows?.length ? rows : selection.value;
  if (!assignTargets.value.length) {
    ElMessage.warning("请先选择客户");
    return;
  }
  assignOwnerId.value = null;
  assignVisible.value = true;
}

async function submitAssign() {
  assigning.value = true;
  try {
    await CustomerAPI.assign(
      assignTargets.value.map((item) => item.id).join(","),
      assignOwnerId.value ?? null
    );
    ElMessage.success(assignOwnerId.value ? "客户分配成功" : "客户已移入公海");
    assignVisible.value = false;
    fetchData();
  } finally {
    assigning.value = false;
  }
}

function handleCommand(command: string, row: CustomerItem) {
  if (command === "edit") openEdit(row);
  else if (command === "assign") openAssign([row]);
  else if (command === "delete") removeRows([row]);
}

async function removeRows(rows: CustomerItem[]) {
  if (!rows.length) return;
  await ElMessageBox.confirm(
    `确定删除选中的 ${rows.length} 位客户吗？删除后不可恢复。`,
    "删除确认",
    { type: "warning", confirmButtonText: "删除", cancelButtonText: "取消" }
  );
  await CustomerAPI.remove(rows.map((item) => item.id).join(","));
  ElMessage.success("客户已删除");
  fetchData();
}

function removeSelected() {
  removeRows(selection.value);
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

.table-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 12px;
}

.table-toolbar__info {
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.table-toolbar__info strong {
  color: var(--el-text-color-primary);
  font-size: 16px;
}

.selection-tip {
  margin-left: 10px;
  padding: 2px 8px;
  color: var(--el-color-primary);
  border-radius: 10px;
  background: var(--el-color-primary-light-9);
}

.table-toolbar__actions {
  display: flex;
  gap: 8px;
}

.customer-cell {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 0;
  color: inherit;
  text-align: left;
  border: 0;
  background: none;
  cursor: pointer;
}

.customer-cell__avatar {
  display: grid;
  width: 34px;
  height: 34px;
  flex: none;
  place-items: center;
  color: var(--el-color-primary);
  font-weight: 600;
  border-radius: 10px;
  background: var(--el-color-primary-light-9);
}

.customer-cell__body {
  display: flex;
  flex-direction: column;
  gap: 2px;
  min-width: 0;
}

.customer-cell__body strong {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.customer-cell__body small,
.stacked small {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.customer-cell:hover strong {
  color: var(--el-color-primary);
}

.stacked {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.tag-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 4px;
}

.tag-more {
  color: var(--el-text-color-secondary);
  font-size: 12px;
  cursor: default;
}

.muted {
  color: var(--el-text-color-placeholder);
}

.follow-time.is-overdue {
  color: var(--el-color-danger);
  font-weight: 600;
}

.follow-time.is-soon {
  color: var(--el-color-warning);
  font-weight: 600;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0 20px;
}

.form-grid__full {
  grid-column: span 2;
}

.assign-tip {
  margin: 0 0 14px;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

@media (max-width: 900px) {
  .form-grid {
    grid-template-columns: 1fr;
  }

  .form-grid__full {
    grid-column: span 1;
  }

  .filter-bar__keyword {
    width: 100%;
  }
}
</style>
