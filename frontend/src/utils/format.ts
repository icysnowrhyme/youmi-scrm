// 数据格式化相关工具函数

/**
 * 格式化增长率
 * 保留两位小数，去掉末尾的 0，取绝对值
 *
 * @param growthRate 增长率（小数形式，如 0.15 表示 15%）
 * @returns 格式化后的增长率字符串
 *
 * @example
 * ```ts
 * formatGrowthRate(0.1234);  // "12.34%"
 * formatGrowthRate(0.1000);  // "10%"
 * formatGrowthRate(0);       // "-"
 * formatGrowthRate(-0.05);   // "5%"（取绝对值）
 * ```
 */
export function formatGrowthRate(growthRate: number): string {
  if (growthRate === 0) {
    return "-";
  }

  const formattedRate = Math.abs(growthRate * 100)
    .toFixed(2)
    .replace(/\.?0+$/, "");

  return formattedRate + "%";
}

/**
 * 格式化日期时间，兼容后端返回的 ISO 字符串
 */
export function formatDateTime(value?: string | null): string {
  if (!value) return "-";
  return value.replace("T", " ").slice(0, 16);
}

/**
 * 仅格式化日期部分
 */
export function formatDate(value?: string | null): string {
  if (!value) return "-";
  return value.slice(0, 10);
}

/**
 * 金额千分位展示，默认取整
 */
export function formatMoney(value?: number | string | null, digits = 0): string {
  const num = Number(value ?? 0);
  if (Number.isNaN(num)) return "-";
  return num.toLocaleString("zh-CN", {
    minimumFractionDigits: digits,
    maximumFractionDigits: digits,
  });
}

/**
 * 金额紧凑展示（万 / 亿）
 */
export function formatCompactMoney(value?: number | string | null): string {
  const num = Number(value ?? 0);
  if (Number.isNaN(num) || num === 0) return "0";
  if (Math.abs(num) >= 100_000_000) return `${(num / 100_000_000).toFixed(2)} 亿`;
  if (Math.abs(num) >= 10_000) return `${(num / 10_000).toFixed(1)} 万`;
  return formatMoney(num);
}
