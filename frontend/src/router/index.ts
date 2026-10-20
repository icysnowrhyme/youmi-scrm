import type { App } from "vue";
import { createRouter, createWebHashHistory, type RouteRecordRaw } from "vue-router";

export const Layout = () => import("@/layouts/index.vue");

const PlaceholderPage = () => import("@/views/youmi/PlaceholderPage.vue");
const LeadList = () => import("@/views/youmi/lead/LeadList.vue");
const CustomerList = () => import("@/views/youmi/customer/CustomerList.vue");
const OrderList = () => import("@/views/youmi/order/OrderList.vue");
const PerformancePage = () => import("@/views/youmi/report/PerformancePage.vue");
const MeritsPage = () => import("@/views/youmi/report/MeritsPage.vue");
const DeptPage = () => import("@/views/youmi/system/DeptPage.vue");
const RolePage = () => import("@/views/youmi/system/RolePage.vue");
const StorePage = () => import("@/views/youmi/gateway/StorePage.vue");

const reportPlaceholders: RouteRecordRaw[] = [
  ["/report/fans", "进粉分析"],
  ["/report/workload", "工作量报表"],
  ["/report/clue", "线索报表"],
  ["/report/process", "流程报表"],
  ["/report/call", "通话报表"],
  ["/report/channel", "渠道分析"],
  ["/report/other-order", "其他订单报表"],
  ["/report/stock", "库存报表"],
  ["/report/download", "后台下载"],
].map(([path, title]) => ({
  path,
  component: PlaceholderPage,
  meta: { title, kind: "report" },
}));

const cluePlaceholders: RouteRecordRaw[] = [
  ["/crm/clues/fans", "加粉管理"],
  ["/crm/clues/abandon", "放弃线索复核"],
  ["/crm/clues/attributes", "线索属性"],
  ["/crm/clues/flow", "转化流程"],
  ["/crm/clues/strategy", "策略设置"],
  ["/crm/clues/pool-settings", "公海设置"],
].map(([path, title]) => ({
  path,
  component: PlaceholderPage,
  meta: { title },
}));

const orderPlaceholders: RouteRecordRaw[] = [
  ["/crm/order/import", "订单导入"],
  ["/crm/order/task", "我的任务"],
  ["/crm/order/shipping", "打单发货"],
  ["/crm/order/warehouse-print", "仓库打单"],
  ["/crm/order/followup", "跟单任务"],
  ["/crm/order/to-warehouse", "待入仓"],
  ["/crm/order/reconcile", "记账对账"],
  ["/crm/order/after-sale", "售后单管理"],
  ["/crm/order/cancelled", "已取消"],
  ["/crm/order/supplier", "供应商"],
  ["/crm/order/attributes", "订单属性"],
  ["/crm/order/settings", "打单发货设置"],
  ["/crm/order/cloud-shop", "云店管理"],
  ["/crm/order/product", "商品管理"],
  ["/crm/order/warehouse", "仓库管理"],
].map(([path, title]) => ({
  path,
  component: PlaceholderPage,
  meta: { title },
}));

const systemPlaceholders: RouteRecordRaw[] = [
  ["/crm/system/equipment", "设备账号"],
  ["/crm/system/employees-group", "员工组"],
  ["/crm/system/module", "功能模块"],
  ["/crm/system/working-time", "工作时间"],
  ["/crm/system/page", "页面设置"],
  ["/crm/system/template", "模板配置"],
  ["/crm/system/log", "系统日志"],
  ["/crm/system/open-platform", "开放平台"],
].map(([path, title]) => ({
  path,
  component: PlaceholderPage,
  meta: { title },
}));

const gatewayPlaceholders: RouteRecordRaw[] = [
  ["/gateway/warehouse", "云仓管理"],
  ["/gateway/product", "商品管理"],
  ["/gateway/lead", "平台线索"],
].map(([path, title]) => ({
  path,
  component: PlaceholderPage,
  meta: { title },
}));

const qualityPlaceholders: RouteRecordRaw[] = [
  ["/quality/dashboard", "质检概览"],
  ["/quality/task", "质检任务"],
  ["/quality/rule", "质检规则"],
  ["/quality/session", "会话质检"],
].map(([path, title]) => ({
  path,
  component: PlaceholderPage,
  meta: { title },
}));

export const constantRoutes: RouteRecordRaw[] = [
  {
    path: "/login",
    component: () => import("@/views/login/index.vue"),
    meta: { hidden: true, title: "登录" },
  },
  {
    path: "/",
    name: "/",
    component: Layout,
    redirect: "/report/performance",
    children: [
      {
        path: "/report/performance",
        alias: "/report/performance/statistics",
        name: "YoumiPerformance",
        component: PerformancePage,
        meta: { title: "员工业绩" },
      },
      {
        path: "/report/meritsrecord",
        name: "YoumiMerits",
        component: MeritsPage,
        meta: { title: "员工绩效" },
      },
      ...reportPlaceholders,
      {
        path: "/crm/clues/create",
        name: "YoumiClueCreate",
        component: LeadList,
        meta: { title: "创建线索", scope: "create", createMode: true },
      },
      {
        path: "/crm/clues/todo",
        name: "YoumiClueTodo",
        component: LeadList,
        meta: { title: "待办线索", scope: "todo" },
      },
      {
        path: "/crm/clues/manage",
        name: "YoumiClueManage",
        component: LeadList,
        meta: { title: "管理线索", scope: "manage" },
      },
      {
        path: "/crm/clues/pool",
        name: "YoumiCluePool",
        component: LeadList,
        meta: { title: "公海线索", scope: "pool" },
      },
      {
        path: "/crm/clues/original",
        name: "YoumiClueOriginal",
        component: LeadList,
        meta: { title: "原始进线", scope: "original" },
      },
      ...cluePlaceholders,
      {
        path: "/crm/customer/list",
        name: "YoumiCustomerList",
        component: CustomerList,
        meta: { title: "管理客户" },
      },
      {
        path: "/crm/customer/attributes",
        component: PlaceholderPage,
        meta: { title: "客户属性" },
      },
      {
        path: "/crm/customer/reach",
        component: PlaceholderPage,
        meta: { title: "客户触达" },
      },
      {
        path: "/crm/order/list",
        name: "YoumiOrderList",
        component: OrderList,
        meta: { title: "订单列表" },
      },
      {
        path: "/crm/order/audit",
        name: "YoumiOrderAudit",
        component: OrderList,
        meta: { title: "待审核", audit: true },
      },
      ...orderPlaceholders,
      {
        path: "/crm/system/dept",
        name: "YoumiDept",
        component: DeptPage,
        meta: { title: "组织架构" },
      },
      {
        path: "/crm/system/role",
        name: "YoumiRole",
        component: RolePage,
        meta: { title: "角色" },
      },
      ...systemPlaceholders,
      {
        path: "/gateway/store",
        name: "YoumiStore",
        component: StorePage,
        meta: { title: "云店管理" },
      },
      ...gatewayPlaceholders,
      ...qualityPlaceholders,
      {
        path: "/404",
        component: () => import("@/views/error/404.vue"),
        meta: { hidden: true },
      },
    ],
  },
  {
    path: "/:pathMatch(.*)*",
    redirect: "/404",
  },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes: constantRoutes,
  scrollBehavior: () => ({ left: 0, top: 0 }),
});

export function setupRouter(app: App<Element>) {
  app.use(router);
}

export default router;
