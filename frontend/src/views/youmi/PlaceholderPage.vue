<template>
  <div class="ym-page">
    <div class="ym-page-title">{{ title }}</div>

    <div class="ym-filter-card">
      <div class="ym-filter-row">
        <div class="ym-filter-field ym-filter-field--wide">
          <span class="ym-filter-label">关键字</span>
          <el-input placeholder="请输入关键字" clearable disabled />
        </div>
        <div class="ym-filter-field">
          <span class="ym-filter-label">创建时间</span>
          <el-date-picker type="daterange" range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期" disabled />
        </div>
        <div class="ym-filter-actions">
          <el-button type="primary" disabled>搜索</el-button>
          <el-button disabled>重置</el-button>
        </div>
      </div>
    </div>

    <div class="ym-panel">
      <div class="ym-placeholder">
        <el-icon :size="46"><Tools /></el-icon>
        <p class="ym-placeholder__title">{{ title }}</p>
        <p class="ym-placeholder__desc">
          当前账号暂无「{{ title }}」的查看权限，或该模块尚未完成配置。
        </p>
        <el-button type="primary" plain @click="goBack">返回员工业绩</el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "YoumiPlaceholder" });

import { useRoute, useRouter } from "vue-router";

const route = useRoute();
const router = useRouter();

const title = computed(() => (route.meta.title as string) || "功能模块");

function goBack(): void {
  router.push("/report/performance");
}
</script>

<style lang="scss" scoped>
.ym-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 420px;
  color: #c0c4cc;

  &__title {
    margin: 18px 0 6px;
    font-size: 16px;
    font-weight: 500;
    color: #303133;
  }

  &__desc {
    margin: 0 0 20px;
    font-size: 13px;
    color: #909399;
  }
}
</style>
