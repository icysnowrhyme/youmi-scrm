<template>
  <el-dialog
    v-model="visible"
    :title="isEdit ? '编辑跟进记录' : '新增跟进'"
    width="560px"
    destroy-on-close
    @closed="handleClosed"
  >
    <el-form ref="formRef" :model="form" :rules="rules" label-width="96px">
      <el-form-item v-if="!customerId" label="客户" prop="customerId">
        <CustomerSelect v-model="form.customerId" />
      </el-form-item>
      <el-form-item label="跟进方式" prop="type">
        <el-radio-group v-model="form.type">
          <el-radio-button v-for="item in FOLLOW_UP_TYPES" :key="item.value" :value="item.value">
            {{ item.label }}
          </el-radio-button>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="跟进内容" prop="content">
        <el-input v-model="form.content" :rows="4" maxlength="500" show-word-limit type="textarea" />
      </el-form-item>
      <el-form-item label="跟进结果">
        <el-input v-model="form.result" maxlength="200" placeholder="如：客户认可方案，等待报价" />
      </el-form-item>
      <el-form-item label="下次跟进">
        <el-date-picker
          v-model="form.nextFollowTime"
          type="datetime"
          placeholder="选择下次跟进时间"
          value-format="YYYY-MM-DD HH:mm:ss"
          style="width: 100%"
        />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="visible = false">取消</el-button>
      <el-button :loading="saving" type="primary" @click="submit">保存</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ElMessage, type FormInstance, type FormRules } from "element-plus";
import { FollowUpAPI } from "@/api/scrm";
import type { FollowUpForm, FollowUpItem } from "@/api/scrm/types";
import { FOLLOW_UP_TYPES } from "../constants";
import CustomerSelect from "./CustomerSelect.vue";

const props = defineProps<{
  customerId?: string | number;
  customerName?: string;
  editData?: FollowUpItem | null;
}>();

const emit = defineEmits<{ saved: [] }>();

const visible = defineModel<boolean>({ default: false });

const formRef = ref<FormInstance>();
const saving = ref(false);
const isEdit = computed(() => Boolean(props.editData?.id));

const form = reactive<FollowUpForm>({
  customerId: null,
  type: 1,
  content: "",
  result: "",
  nextFollowTime: "",
});

const rules: FormRules = {
  customerId: [{ required: true, message: "请选择客户", trigger: "change" }],
  type: [{ required: true, message: "请选择跟进方式", trigger: "change" }],
  content: [
    { required: true, message: "请填写跟进内容", trigger: "blur" },
    { min: 2, message: "跟进内容至少 2 个字", trigger: "blur" },
  ],
};

watch(
  () => visible.value,
  (open) => {
    if (!open) return;
    form.customerId = props.customerId ?? null;
    form.type = props.editData?.type ?? 1;
    form.content = props.editData?.content ?? "";
    form.result = props.editData?.result ?? "";
    form.nextFollowTime = props.editData?.nextFollowTime ?? "";
  },
  { immediate: true }
);

async function submit() {
  const valid = await formRef.value?.validate().catch(() => false);
  if (!valid) return;
  saving.value = true;
  try {
    if (props.editData?.id) {
      await FollowUpAPI.update(props.editData.id, form);
      ElMessage.success("跟进记录已更新");
    } else {
      await FollowUpAPI.create(form);
      ElMessage.success("跟进已记录");
    }
    visible.value = false;
    emit("saved");
  } finally {
    saving.value = false;
  }
}

function handleClosed() {
  formRef.value?.resetFields();
}
</script>
