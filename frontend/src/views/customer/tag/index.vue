<template>
  <div class="page">
    <header class="page-head">
      <div>
        <h2>客户标签</h2>
        <p>用标签给客户分层分类，支撑筛选、营销与精细化运营</p>
      </div>
      <div class="page-head__actions">
        <el-input
          v-model="keyword"
          clearable
          placeholder="搜索标签"
          style="width: 200px"
          @clear="loadTags"
          @keyup.enter="loadTags"
        >
          <template #prefix><el-icon><Search /></el-icon></template>
        </el-input>
        <el-button v-has-perm="'scrm:tag:create'" type="primary" @click="openCreate">
          <el-icon><Plus /></el-icon>
          新建标签
        </el-button>
      </div>
    </header>

    <section v-loading="loading" class="tag-grid">
      <div v-for="tag in tags" :key="tag.id" class="tag-card">
        <div class="tag-card__bar" :style="{ background: tag.color }"></div>
        <div class="tag-card__body">
          <div class="tag-card__title">
            <span class="tag-card__dot" :style="{ background: tag.color }"></span>
            <strong>{{ tag.name }}</strong>
          </div>
          <p class="tag-card__count">
            <span>{{ tag.customerCount ?? 0 }}</span> 位客户
          </p>
          <div class="tag-card__actions">
            <el-button v-has-perm="'scrm:tag:update'" link type="primary" @click="openEdit(tag)">
              编辑
            </el-button>
            <el-button v-has-perm="'scrm:tag:delete'" link type="danger" @click="removeTag(tag)">
              删除
            </el-button>
          </div>
        </div>
      </div>

      <button
        v-has-perm="'scrm:tag:create'"
        class="tag-card tag-card--create"
        type="button"
        @click="openCreate"
      >
        <el-icon :size="22"><Plus /></el-icon>
        <span>新建标签</span>
      </button>

      <el-empty
        v-if="!loading && !tags.length"
        class="tag-empty"
        description="还没有标签，先创建一个吧"
        :image-size="90"
      />
    </section>

    <el-dialog
      v-model="dialogVisible"
      :title="editingId ? '编辑标签' : '新建标签'"
      width="440px"
      destroy-on-close
      @closed="formRef?.resetFields()"
    >
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="标签名称" prop="name">
          <el-input v-model="form.name" maxlength="20" placeholder="如：高意向 / 老客户" show-word-limit />
        </el-form-item>
        <el-form-item label="标签颜色">
          <div class="color-picker">
            <button
              v-for="color in TAG_COLORS"
              :key="color"
              type="button"
              :class="['color-dot', { 'is-active': form.color === color }]"
              :style="{ background: color }"
              @click="form.color = color"
            />
            <el-color-picker v-model="form.color" size="small" />
          </div>
        </el-form-item>
        <el-form-item label="显示排序">
          <el-input-number v-model="form.sort" :min="0" :max="999" controls-position="right" />
        </el-form-item>
        <el-form-item label="效果预览">
          <el-tag
            effect="plain"
            :style="{
              color: form.color,
              borderColor: form.color,
              background: `${form.color}14`,
            }"
          >
            {{ form.name || "标签名称" }}
          </el-tag>
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
import { TagAPI } from "@/api/scrm";
import type { ScrmTag, TagForm } from "@/api/scrm/types";
import { TAG_COLORS } from "@/views/scrm/constants";

const loading = ref(false);
const saving = ref(false);
const tags = ref<ScrmTag[]>([]);
const keyword = ref("");

const dialogVisible = ref(false);
const editingId = ref<string | number>();
const formRef = ref<FormInstance>();

const form = reactive<TagForm>({
  name: "",
  color: TAG_COLORS[0],
  sort: 0,
});

const rules: FormRules = {
  name: [{ required: true, message: "请输入标签名称", trigger: "blur" }],
};

onMounted(loadTags);

async function loadTags() {
  loading.value = true;
  try {
    tags.value = await TagAPI.list({
      pageNum: 1,
      pageSize: 200,
      keyword: keyword.value,
    });
  } finally {
    loading.value = false;
  }
}

function openCreate() {
  editingId.value = undefined;
  Object.assign(form, { name: "", color: TAG_COLORS[Math.floor(Math.random() * TAG_COLORS.length)], sort: tags.value.length });
  dialogVisible.value = true;
}

function openEdit(tag: ScrmTag) {
  editingId.value = tag.id;
  Object.assign(form, {
    name: tag.name,
    color: tag.color || TAG_COLORS[0],
    sort: tag.sort ?? 0,
  });
  dialogVisible.value = true;
}

async function submit() {
  const valid = await formRef.value?.validate().catch(() => false);
  if (!valid) return;
  saving.value = true;
  try {
    if (editingId.value) {
      await TagAPI.update(editingId.value, form);
      ElMessage.success("标签已更新");
    } else {
      await TagAPI.create(form);
      ElMessage.success("标签创建成功");
    }
    dialogVisible.value = false;
    loadTags();
  } finally {
    saving.value = false;
  }
}

async function removeTag(tag: ScrmTag) {
  await ElMessageBox.confirm(
    `删除标签「${tag.name}」后，客户与该标签的关联也会一并移除，是否继续？`,
    "删除标签",
    { type: "warning", confirmButtonText: "删除", cancelButtonText: "取消" }
  );
  await TagAPI.remove(String(tag.id));
  ElMessage.success("标签已删除");
  loadTags();
}
</script>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  gap: 18px;
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

.page-head__actions {
  display: flex;
  gap: 10px;
}

.tag-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 16px;
  min-height: 160px;
}

.tag-card {
  position: relative;
  overflow: hidden;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 14px;
  background: var(--el-bg-color);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.tag-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 24px rgb(15 23 42 / 8%);
}

.tag-card__bar {
  height: 4px;
}

.tag-card__body {
  padding: 16px 18px 14px;
}

.tag-card__title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 15px;
}

.tag-card__dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.tag-card__count {
  margin: 10px 0 14px;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.tag-card__count span {
  color: var(--el-text-color-primary);
  font-size: 22px;
  font-weight: 600;
}

.tag-card__actions {
  display: flex;
  gap: 4px;
  opacity: 0;
  transition: opacity 0.2s ease;
}

.tag-card:hover .tag-card__actions {
  opacity: 1;
}

.tag-card--create {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-direction: column;
  gap: 10px;
  min-height: 150px;
  color: var(--el-text-color-secondary);
  font-size: 14px;
  border-style: dashed;
  cursor: pointer;
  background: transparent;
}

.tag-card--create:hover {
  color: var(--el-color-primary);
  border-color: var(--el-color-primary);
}

.tag-empty {
  grid-column: 1 / -1;
}

.color-picker {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
}

.color-dot {
  width: 22px;
  height: 22px;
  border: 2px solid transparent;
  border-radius: 50%;
  cursor: pointer;
}

.color-dot.is-active {
  border-color: var(--el-text-color-primary);
  box-shadow: 0 0 0 3px var(--el-fill-color);
}

@media (max-width: 760px) {
  .page-head {
    align-items: flex-start;
    flex-direction: column;
  }
}
</style>
