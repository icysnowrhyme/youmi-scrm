type TagType = "primary" | "success" | "warning" | "info" | "danger";

export interface SelectOption {
  label: string;
  value: number | string;
  type?: TagType;
  color?: string;
}

export const CUSTOMER_LEVELS: SelectOption[] = [
  { label: "A 类 · 重点", value: "A", type: "danger" },
  { label: "B 类 · 意向", value: "B", type: "warning" },
  { label: "C 类 · 普通", value: "C", type: "primary" },
  { label: "D 类 · 观察", value: "D", type: "info" },
];

export const CUSTOMER_SOURCES: SelectOption[] = [
  { label: "官网", value: 1 },
  { label: "转介绍", value: 2 },
  { label: "活动", value: 3 },
  { label: "广告", value: 4 },
  { label: "主动开发", value: 5 },
  { label: "其他", value: 6 },
];

export const CUSTOMER_STATUSES: SelectOption[] = [
  { label: "潜在客户", value: 1, type: "info" },
  { label: "跟进中", value: 2, type: "primary" },
  { label: "已成交", value: 3, type: "success" },
  { label: "已流失", value: 4, type: "danger" },
];

export const FOLLOW_UP_TYPES: SelectOption[] = [
  { label: "电话", value: 1, type: "primary" },
  { label: "微信", value: 2, type: "success" },
  { label: "拜访", value: 3, type: "warning" },
  { label: "邮件", value: 4, type: "info" },
  { label: "其他", value: 5, type: "info" },
];

export const OPPORTUNITY_STAGES: SelectOption[] = [
  { label: "初步接洽", value: 1, type: "info" },
  { label: "需求确认", value: 2, type: "primary" },
  { label: "方案报价", value: 3, type: "warning" },
  { label: "商务谈判", value: 4, type: "danger" },
  { label: "赢单", value: 5, type: "success" },
  { label: "输单", value: 6, type: "info" },
];

export const CONTRACT_STATUSES: SelectOption[] = [
  { label: "草稿", value: 1, type: "info" },
  { label: "执行中", value: 2, type: "primary" },
  { label: "已完成", value: 3, type: "success" },
  { label: "已终止", value: 4, type: "danger" },
];

export const CAMPAIGN_TYPES: SelectOption[] = [
  { label: "线上活动", value: 1 },
  { label: "线下活动", value: 2 },
  { label: "广告投放", value: 3 },
  { label: "内容营销", value: 4 },
];

export const CAMPAIGN_STATUSES: SelectOption[] = [
  { label: "未开始", value: 0, type: "info" },
  { label: "进行中", value: 1, type: "primary" },
  { label: "已结束", value: 2, type: "success" },
];

export const TAG_COLORS = [
  "#3B82F6",
  "#10B981",
  "#F59E0B",
  "#EF4444",
  "#8B5CF6",
  "#06B6D4",
  "#EC4899",
  "#64748B",
];

export function findOption(options: SelectOption[], value?: number | string | null): SelectOption | undefined {
  if (value === undefined || value === null || value === "") return undefined;
  return options.find((item) => String(item.value) === String(value));
}

export function optionLabel(options: SelectOption[], value?: number | string | null): string {
  return findOption(options, value)?.label ?? "-";
}

export function optionType(options: SelectOption[], value?: number | string | null): TagType {
  return findOption(options, value)?.type ?? "info";
}
