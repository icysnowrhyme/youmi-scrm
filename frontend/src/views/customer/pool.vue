<template>
  <div class="page">
    <header class="page-head">
      <div>
        <h2>客户公海</h2>
        <p>未被分配的客户会沉淀在这里，销售可主动领取并开始跟进</p>
      </div>
      <div class="pool-count">
        <span>待领取</span>
        <strong>{{ total }}</strong>
      </div>
    </header>

    <section class="pool-banner">
      <div class="pool-banner__icon">
        <el-icon :size="24"><Ship /></el-icon>
      </div>
      <div class="pool-banner__text">
        <strong>公海领取规则</strong>
        <p>领取后客户立即归属当前销售，并自动从公海移除；请优先跟进高意向客户。</p>
      </div>
    </section>

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
      <el-table v-loading="loading" :data="list" row-key="id">
        <el-table-column label="客户" min-width="220">
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
              <span v-if="row.tags.length > 3" class="tag-more">+{{ row.tags.length - 3 }}</span>
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
        <el-table-column label="来源" width="100">
          <template #default="{ row }">{{ optionLabel(CUSTOMER_SOURCES, row.source) }}</template>
        </el-table-column>
        <el-table-column label="公海时间" width="160">
          <template #default="{ row }">{{ formatDateTime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="openDetail(row as CustomerItem)">详情</el-button>
            <el-button v-has-perm="'scrm:customer:claim'" link type="success" @click="claim(row as CustomerItem)">
              领取
            </el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="公海暂无客户" :image-size="92" />
        </template>
      </el-table>

      <Pagination
        v-model:page="params.pageNum"
        v-model:limit="params.pageSize"
        :total="total"
        @pagination="fetchData"
      />
    </section>

    <CustomerDetailDrawer
      v-model="detailVisible"
      :customer-id="currentCustomerId"
      pool-mode
      @updated="fetchData"
    />
  </div>
</template>

<script setup lang="ts">
import { ElMessage, ElMessageBox } from "element-plus";
import { CustomerAPI, TagAPI } from "@/api/scrm";
import type { CustomerItem, CustomerQuery, ScrmTag } from "@/api/scrm/types";
import { usePageTable } from "@/composables";
import { formatDateTime } from "@/utils/format";
import {
  CUSTOMER_LEVELS,
  CUSTOMER_SOURCES,
  optionLabel,
  optionType,
} from "@/views/scrm/constants";
import CustomerDetailDrawer from "@/views/scrm/components/CustomerDetailDrawer.vue";

const initialParams: CustomerQuery = {
  pageNum: 1,
  pageSize: 10,
  keyword: "",
  level: "",
  source: undefined,
  tagId: undefined,
};

const { loading, list, total, params, fetchData, handleQuery, handleResetQuery } = usePageTable<
  CustomerItem,
  CustomerQuery
>({
  initialParams,
  request: CustomerAPI.getPoolPage,
});

const tagList = ref<ScrmTag[]>([]);
const detailVisible = ref(false);
const currentCustomerId = ref<string | number>();

onMounted(async () => {
  fetchData();
  tagList.value = await TagAPI.list();
});

function openDetail(row: CustomerItem) {
  currentCustomerId.value = row.id;
  detailVisible.value = true;
}

async function claim(row: CustomerItem) {
  await ElMessageBox.confirm(
    `确定领取「${row.name}」吗？领取后该客户将归属到你的名下。`,
    "领取客户",
    { type: "info", confirmButtonText: "确认领取", cancelButtonText: "取消" }
  );
  await CustomerAPI.claim(row.id);
  ElMessage.success(`已领取客户「${row.name}」`);
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

.pool-count {
  display: flex;
  align-items: baseline;
  gap: 8px;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.pool-count strong {
  color: var(--el-color-primary);
  font-size: 28px;
  line-height: 1;
}

.pool-banner {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px 20px;
  color: #0f4c81;
  border: 1px solid #c9e4f7;
  border-radius: 14px;
  background: linear-gradient(120deg, #eff8ff, #f5fbff);
}

.pool-banner__icon {
  display: grid;
  width: 44px;
  height: 44px;
  flex: none;
  place-items: center;
  color: #0d6efd;
  border-radius: 12px;
  background: #d8ecff;
}

.pool-banner__text strong {
  font-size: 14px;
}

.pool-banner__text p {
  margin: 4px 0 0;
  color: #4b6b85;
  font-size: 12px;
}

:global(html.dark) .pool-banner {
  color: #cfe8ff;
  border-color: #1e3a5f;
  background: linear-gradient(120deg, #152a3f, #10202f);
}

:global(html.dark) .pool-banner__text p {
  color: #9db6ca;
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
}

.muted {
  color: var(--el-text-color-placeholder);
}

@media (max-width: 900px) {
  .filter-bar__keyword {
    width: 100%;
  }
}
</style>
