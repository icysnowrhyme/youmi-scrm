<template>
  <div class="ym-page">
    <div class="ym-page-title">云店管理</div>

    <div class="ym-info-alert">
      <el-icon :size="16"><InfoFilled /></el-icon>
      <p>
        云店授权后，平台店铺的订单、商品与库存数据将自动同步至友米SCRM。当前环境尚未配置开放平台应用，
        请先在「开放平台」完成应用创建并获取授权参数。
      </p>
    </div>

    <div class="ym-filter-card">
      <div class="ym-filter-row">
        <div class="ym-filter-field ym-filter-field--wide">
          <span class="ym-filter-label">云店名称</span>
          <el-input v-model="query.name" clearable placeholder="请输入云店名称" />
        </div>
        <div class="ym-filter-field">
          <span class="ym-filter-label">所属平台</span>
          <el-select v-model="query.platform" clearable placeholder="全部平台">
            <el-option v-for="item in platforms" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </div>
        <div class="ym-filter-field">
          <span class="ym-filter-label">授权状态</span>
          <el-select v-model="query.status" clearable placeholder="全部状态">
            <el-option label="已授权" value="authorized" />
            <el-option label="未授权" value="unauthorized" />
          </el-select>
        </div>
        <div class="ym-filter-actions">
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </div>
      </div>
    </div>

    <div class="ym-platform-grid">
      <div v-for="item in platforms" :key="item.value" class="ym-platform-card">
        <div class="ym-platform-card__head">
          <span class="ym-platform-card__logo" :style="{ background: item.color }">{{ item.short }}</span>
          <div>
            <p class="ym-platform-card__name">{{ item.label }}</p>
            <p class="ym-platform-card__desc">{{ item.desc }}</p>
          </div>
        </div>
        <div class="ym-platform-card__foot">
          <el-tag type="info" size="small" effect="plain">未授权</el-tag>
          <el-button link type="primary" @click="handleAuthorize(item.label)">去授权</el-button>
        </div>
      </div>
    </div>

    <div class="ym-panel">
      <div class="ym-panel-header">
        <div class="ym-panel-title">云店列表</div>
        <div class="ym-toolbar">
          <el-button type="primary" @click="handleAuthorize('云店')">新增云店</el-button>
          <el-button plain @click="handleSync">同步数据</el-button>
        </div>
      </div>

      <el-table :data="filteredShops" border>
        <el-table-column prop="name" label="云店名称" min-width="160" />
        <el-table-column prop="platform" label="所属平台" width="140" />
        <el-table-column prop="shopId" label="店铺ID" min-width="160" />
        <el-table-column label="授权状态" width="110">
          <template #default="{ row }">
            <el-tag :type="row.status === 'authorized' ? 'success' : 'info'" size="small" effect="plain">
              {{ row.status === "authorized" ? "已授权" : "未授权" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="syncTime" label="最近同步" width="170" />
        <el-table-column label="操作" width="160">
          <template #default>
            <el-button link type="primary" @click="handleAuthorize('云店')">授权</el-button>
            <el-button link type="primary" @click="handleSync">同步</el-button>
          </template>
        </el-table-column>
        <template #empty>
          <div class="ym-empty ym-empty--gray">暂无已授权的云店，请先完成平台授权</div>
        </template>
      </el-table>
    </div>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "YoumiStore" });

import { ElMessage, ElMessageBox } from "element-plus";

interface CloudShop {
  name: string;
  platform: string;
  shopId: string;
  status: "authorized" | "unauthorized";
  syncTime: string;
}

const platforms = [
  { label: "有赞云店", value: "youzan", short: "赞", color: "#ff6b35", desc: "有赞微商城 / 零售店铺" },
  { label: "微盟云店", value: "weimob", short: "微", color: "#2f7bff", desc: "微盟智慧零售店铺" },
  { label: "抖音小店", value: "douyin", short: "抖", color: "#161823", desc: "抖音电商店铺授权" },
  { label: "快手小店", value: "kuaishou", short: "快", color: "#ff4906", desc: "快手电商店铺授权" },
];

const query = reactive({ name: "", platform: "", status: "" });
const shops = ref<CloudShop[]>([]);

const filteredShops = computed(() =>
  shops.value.filter(
    (item) =>
      (!query.name || item.name.includes(query.name)) &&
      (!query.platform || platforms.find((p) => p.value === query.platform)?.label === item.platform) &&
      (!query.status || item.status === query.status)
  )
);

function handleSearch() {
  ElMessage.info(`已按条件筛选：${filteredShops.value.length} 家云店`);
}

function handleReset() {
  query.name = "";
  query.platform = "";
  query.status = "";
}

async function handleAuthorize(platform: string): Promise<void> {
  await ElMessageBox.alert(
    `${platform}授权需要开放平台的应用 AppKey、AppSecret 以及店铺授权回调地址。演示环境未接入第三方平台，正式环境请在「系统设置 - 开放平台」中配置后重试。`,
    `${platform}授权说明`,
    { confirmButtonText: "我知道了" }
  ).catch(() => undefined);
}

function handleSync() {
  if (!shops.value.length) {
    ElMessage.warning("暂无可同步的云店，请先完成平台授权");
    return;
  }
  ElMessage.success("同步任务已提交");
}
</script>

<style lang="scss" scoped>
.ym-platform-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
  margin-top: 16px;
}

.ym-platform-card {
  padding: 16px;
  background: #fff;
  box-shadow: 0 4px 12px rgb(0 0 0 / 12%);

  &__head {
    display: flex;
    gap: 12px;
    align-items: flex-start;
  }

  &__logo {
    display: inline-flex;
    flex: none;
    align-items: center;
    justify-content: center;
    width: 40px;
    height: 40px;
    font-size: 18px;
    font-weight: 600;
    color: #fff;
    border-radius: 8px;
  }

  &__name {
    margin: 2px 0 4px;
    font-size: 15px;
    font-weight: 600;
    color: #222;
  }

  &__desc {
    margin: 0;
    font-size: 12px;
    color: #909399;
  }

  &__foot {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding-top: 14px;
    margin-top: 14px;
    border-top: 1px solid #f0f0f0;
  }
}

@media (width <= 1400px) {
  .ym-platform-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
