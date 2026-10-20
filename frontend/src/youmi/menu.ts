export interface YoumiMenuItem {
  title: string;
  path: string;
  icon: string;
}

export interface YoumiNavSection {
  key: string;
  title: string;
  icon: string;
  path: string;
  items: YoumiMenuItem[];
}

export const youmiNavSections: YoumiNavSection[] = [
  {
    key: "clues",
    title: "线索管理",
    icon: "Search",
    path: "/crm/clues/todo",
    items: [
      { title: "创建线索", path: "/crm/clues/create", icon: "Plus" },
      { title: "待办线索", path: "/crm/clues/todo", icon: "Clock" },
      { title: "管理线索", path: "/crm/clues/manage", icon: "Management" },
      { title: "加粉管理", path: "/crm/clues/fans", icon: "UserFilled" },
      { title: "放弃线索复核", path: "/crm/clues/abandon", icon: "RefreshLeft" },
      { title: "公海线索", path: "/crm/clues/pool", icon: "Ship" },
      { title: "原始进线", path: "/crm/clues/original", icon: "List" },
      { title: "线索属性", path: "/crm/clues/attributes", icon: "Collection" },
      { title: "转化流程", path: "/crm/clues/flow", icon: "Share" },
      { title: "策略设置", path: "/crm/clues/strategy", icon: "SetUp" },
      { title: "公海设置", path: "/crm/clues/pool-settings", icon: "Setting" },
    ],
  },
  {
    key: "customer",
    title: "客户管理",
    icon: "User",
    path: "/crm/customer/list",
    items: [
      { title: "管理客户", path: "/crm/customer/list", icon: "Management" },
      { title: "客户属性", path: "/crm/customer/attributes", icon: "Collection" },
      { title: "客户触达", path: "/crm/customer/reach", icon: "ChatDotRound" },
    ],
  },
  {
    key: "order",
    title: "订单管理",
    icon: "Tickets",
    path: "/crm/order/list",
    items: [
      { title: "订单导入", path: "/crm/order/import", icon: "Upload" },
      { title: "订单列表", path: "/crm/order/list", icon: "Tickets" },
      { title: "待审核", path: "/crm/order/audit", icon: "View" },
      { title: "我的任务", path: "/crm/order/task", icon: "Operation" },
      { title: "打单发货", path: "/crm/order/shipping", icon: "Van" },
      { title: "仓库打单", path: "/crm/order/warehouse-print", icon: "Box" },
      { title: "跟单任务", path: "/crm/order/followup", icon: "DocumentChecked" },
      { title: "待入仓", path: "/crm/order/to-warehouse", icon: "HomeFilled" },
      { title: "记账对账", path: "/crm/order/reconcile", icon: "Money" },
      { title: "售后单管理", path: "/crm/order/after-sale", icon: "RefreshLeft" },
      { title: "已取消", path: "/crm/order/cancelled", icon: "CircleClose" },
      { title: "供应商", path: "/crm/order/supplier", icon: "Shop" },
      { title: "订单属性", path: "/crm/order/attributes", icon: "Collection" },
      { title: "打单发货设置", path: "/crm/order/settings", icon: "Setting" },
      { title: "云店管理", path: "/crm/order/cloud-shop", icon: "Shop" },
      { title: "商品管理", path: "/crm/order/product", icon: "Goods" },
      { title: "仓库管理", path: "/crm/order/warehouse", icon: "OfficeBuilding" },
    ],
  },
  {
    key: "system",
    title: "系统设置",
    icon: "Setting",
    path: "/crm/system/dept",
    items: [
      { title: "设备账号", path: "/crm/system/equipment", icon: "Monitor" },
      { title: "组织架构", path: "/crm/system/dept", icon: "OfficeBuilding" },
      { title: "角色", path: "/crm/system/role", icon: "UserFilled" },
      { title: "员工组", path: "/crm/system/employees-group", icon: "User" },
      { title: "功能模块", path: "/crm/system/module", icon: "Grid" },
      { title: "工作时间", path: "/crm/system/working-time", icon: "Clock" },
      { title: "页面设置", path: "/crm/system/page", icon: "Document" },
      { title: "模板配置", path: "/crm/system/template", icon: "Files" },
      { title: "系统日志", path: "/crm/system/log", icon: "List" },
      { title: "开放平台", path: "/crm/system/open-platform", icon: "Connection" },
    ],
  },
  {
    key: "report",
    title: "统计报表",
    icon: "DataAnalysis",
    path: "/report/performance",
    items: [
      { title: "员工业绩", path: "/report/performance", icon: "Histogram" },
      { title: "员工绩效", path: "/report/meritsrecord", icon: "Medal" },
      { title: "进粉分析", path: "/report/fans", icon: "UserFilled" },
      { title: "工作量报表", path: "/report/workload", icon: "DocumentCopy" },
      { title: "线索报表", path: "/report/clue", icon: "TrendCharts" },
      { title: "流程报表", path: "/report/process", icon: "Share" },
      { title: "通话报表", path: "/report/call", icon: "Phone" },
      { title: "渠道分析", path: "/report/channel", icon: "PieChart" },
      { title: "其他订单报表", path: "/report/other-order", icon: "Tickets" },
      { title: "库存报表", path: "/report/stock", icon: "Box" },
      { title: "后台下载", path: "/report/download", icon: "Download" },
    ],
  },
  {
    key: "gateway",
    title: "数据互通",
    icon: "Connection",
    path: "/gateway/store",
    items: [
      { title: "云店管理", path: "/gateway/store", icon: "Shop" },
      { title: "云仓管理", path: "/gateway/warehouse", icon: "HomeFilled" },
      { title: "商品管理", path: "/gateway/product", icon: "Goods" },
      { title: "平台线索", path: "/gateway/lead", icon: "List" },
    ],
  },
  {
    key: "quality",
    title: "质检管理",
    icon: "View",
    path: "/quality/dashboard",
    items: [
      { title: "质检概览", path: "/quality/dashboard", icon: "DataAnalysis" },
      { title: "质检任务", path: "/quality/task", icon: "DocumentChecked" },
      { title: "质检规则", path: "/quality/rule", icon: "SetUp" },
      { title: "会话质检", path: "/quality/session", icon: "ChatDotRound" },
    ],
  },
];

export const youmiAnnouncements = [
  "会员小程序报名+公众号看课",
  "微信支付商户号的功能更新",
  "小程序防封合规运营建议",
  "推荐使用小程序，规避域名的各种坑",
  "2025-02-28更新内容",
];

export function findSectionByPath(path: string): YoumiNavSection {
  const section = youmiNavSections.find(
    (item) => path === item.path || path.startsWith(`${item.path}/`) || item.items.some((sub) => sub.path === path)
  );
  return section ?? youmiNavSections[0];
}
