<template>
  <el-dialog
    v-model="visible"
    :title="isEdit ? '编辑客户资料' : mode === 'lead' ? '新建线索' : '新建客户'"
    width="580px"
    destroy-on-close
    @closed="handleClosed"
  >
    <el-form ref="formRef" :model="form" :rules="rules" label-width="92px" class="ym-customer-form">
      <el-row :gutter="16">
        <el-col :span="12">
          <el-form-item label="姓名" prop="name">
            <el-input v-model.trim="form.name" placeholder="请输入姓名" maxlength="30" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="手机号" prop="phone">
            <el-input v-model.trim="form.phone" placeholder="请输入手机号" maxlength="20" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-row :gutter="16">
        <el-col :span="12">
          <el-form-item label="微信号">
            <el-input v-model.trim="form.wechat" placeholder="请输入微信号" maxlength="50" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="性别">
            <el-select v-model="form.gender" clearable placeholder="请选择">
              <el-option label="男" :value="1" />
              <el-option label="女" :value="2" />
              <el-option label="未知" :value="0" />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>

      <el-row :gutter="16">
        <el-col :span="12">
          <el-form-item label="意向等级">
            <el-select v-model="form.level" placeholder="请选择">
              <el-option v-for="item in YM_LEVELS" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="客户来源">
            <el-select v-model="form.source" placeholder="请选择">
              <el-option v-for="item in YM_SOURCES" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>

      <el-form-item label="状态">
        <el-select v-model="form.status" placeholder="请选择">
          <el-option
            v-for="item in YM_CUSTOMER_STATUSES"
            :key="item.value"
            :label="item.label"
            :value="item.value"
          />
        </el-select>
      </el-form-item>

      <el-form-item label="客户标签">
        <el-select v-model="form.tagIds" multiple clearable placeholder="请选择标签" class="w-full">
          <el-option v-for="tag in tags" :key="tag.id" :label="tag.name" :value="tag.id">
            <span class="ym-tag-option">
              <i :style="{ background: tag.color || '#035cff' }" />
              {{ tag.name }}
            </span>
          </el-option>
        </el-select>
      </el-form-item>

      <el-form-item label="备注">
        <el-input v-model="form.remark" type="textarea" :rows="3" maxlength="300" show-word-limit placeholder="补充说明" />
      </el-form-item>
    </el-form>

    <template #footer>
      <el-button @click="visible = false">取消</el-button>
      <el-button type="primary" :loading="submitting" @click="handleSubmit">保存</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ElMessage } from "element-plus";
import type { FormInstance, FormRules } from "element-plus";
import { CustomerAPI, TagAPI } from "@/api/scrm";
import type { CustomerForm, CustomerItem, ScrmTag } from "@/api/scrm/types";
import { YM_CUSTOMER_STATUSES, YM_LEVELS, YM_SOURCES } from "@/youmi/constants";

const props = withDefaults(
  defineProps<{
    modelValue: boolean;
    mode?: "lead" | "customer";
    record?: CustomerItem | null;
  }>(),
  {
    mode: "customer",
    record: null,
  }
);

const emit = defineEmits<{
  "update:modelValue": [value: boolean];
  saved: [];
}>();

const visible = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emit("update:modelValue", value),
});

const formRef = ref<FormInstance>();
const tags = ref<ScrmTag[]>([]);
const submitting = ref(false);
const isEdit = computed(() => Boolean(props.record?.id));

const defaultForm = (): CustomerForm => ({
  name: "",
  phone: "",
  wechat: "",
  gender: 0,
  level: "B",
  source: 1,
  status: props.mode === "lead" ? 1 : 2,
  remark: "",
  tagIds: [],
});

const form = ref<CustomerForm>(defaultForm());

const rules: FormRules = {
  name: [{ required: true, message: "请输入姓名", trigger: "blur" }],
  phone: [{ pattern: /^1\d{10}$/, message: "手机号格式不正确", trigger: "blur" }],
};

async function loadTags() {
  if (tags.value.length) return;
  try {
    tags.value = await TagAPI.list({ pageNum: 1, pageSize: 100 });
  } catch {
    tags.value = [];
  }
}

async function initForm() {
  await loadTags();
  if (!props.record?.id) {
    form.value = defaultForm();
    return;
  }
  try {
    const detail = await CustomerAPI.getDetail(props.record.id);
    form.value = {
      name: detail.name ?? "",
      phone: detail.phone ?? "",
      wechat: detail.wechat ?? "",
      gender: detail.gender ?? 0,
      level: detail.level ?? "B",
      source: detail.source ?? 1,
      status: detail.status ?? 2,
      remark: detail.remark ?? "",
      tagIds: (detail.tags ?? []).map((tag) => tag.id),
    };
  } catch {
    form.value = {
      ...defaultForm(),
      name: props.record.name,
      phone: props.record.phone,
      level: props.record.level,
      source: props.record.source,
      status: props.record.status,
      tagIds: (props.record.tags ?? []).map((tag) => tag.id),
    };
  }
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().then(
    () => true,
    () => false
  );
  if (!valid) return;

  submitting.value = true;
  try {
    if (isEdit.value && props.record?.id) {
      await CustomerAPI.update(props.record.id, form.value);
      ElMessage.success("保存成功");
    } else {
      await CustomerAPI.create(form.value);
      ElMessage.success(props.mode === "lead" ? "线索创建成功" : "客户创建成功");
    }
    visible.value = false;
    emit("saved");
  } finally {
    submitting.value = false;
  }
}

function handleClosed() {
  formRef.value?.clearValidate();
  form.value = defaultForm();
}

watch(
  () => props.modelValue,
  (value) => {
    if (value) initForm();
  }
);
</script>

<style scoped>
.ym-customer-form :deep(.el-select) {
  width: 100%;
}

.ym-tag-option {
  display: inline-flex;
  gap: 6px;
  align-items: center;
}

.ym-tag-option i {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}
</style>
