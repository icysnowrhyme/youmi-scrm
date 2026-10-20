<template>
  <el-select
    v-model="model"
    :disabled="disabled"
    :loading="loading"
    :placeholder="placeholder"
    clearable
    filterable
    remote
    reserve-keyword
    style="width: 100%"
    :remote-method="search"
    @visible-change="handleVisible"
  >
    <el-option v-for="item in options" :key="item.id" :label="item.name" :value="item.id">
      <div class="customer-option">
        <span class="customer-option__name">{{ item.name }}</span>
        <span class="customer-option__meta">{{ item.company || item.phone || "—" }}</span>
      </div>
    </el-option>
  </el-select>
</template>

<script setup lang="ts">
import { CustomerAPI } from "@/api/scrm";
import type { CustomerOption } from "@/api/scrm/types";

withDefaults(
  defineProps<{
    disabled?: boolean;
    placeholder?: string;
  }>(),
  {
    disabled: false,
    placeholder: "搜索客户姓名 / 公司 / 手机号",
  }
);

const model = defineModel<string | number | undefined | null>();

const loading = ref(false);
const options = ref<CustomerOption[]>([]);
let loaded = false;

async function load(keyword?: string) {
  loading.value = true;
  try {
    options.value = await CustomerAPI.getOptions(keyword);
    loaded = true;
  } finally {
    loading.value = false;
  }
}

function search(keyword: string) {
  load(keyword || undefined);
}

function handleVisible(visible: boolean) {
  if (visible && !loaded) {
    load();
  }
}

onMounted(() => {
  if (model.value) {
    load();
  }
});
</script>

<style scoped>
.customer-option {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}

.customer-option__name {
  color: var(--el-text-color-primary);
}

.customer-option__meta {
  color: var(--el-text-color-secondary);
  font-size: 12px;
}
</style>
