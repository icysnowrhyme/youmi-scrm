import type { BaseQueryParams } from "@/api/common";

export interface ScrmTag {
  id: string | number;
  name?: string;
  color?: string;
  sort?: number;
  customerCount?: number;
}

export interface CustomerItem {
  id: string | number;
  name: string;
  shortName?: string;
  phone?: string;
  wechat?: string;
  email?: string;
  gender?: number;
  company?: string;
  position?: string;
  address?: string;
  remark?: string;
  level?: string;
  source?: number;
  status?: number;
  ownerId?: string | number;
  ownerName?: string;
  deptId?: string | number;
  tags?: ScrmTag[];
  lastFollowTime?: string;
  nextFollowTime?: string;
  createTime?: string;
}

export interface CustomerDetail extends CustomerItem {
  wechat?: string;
  email?: string;
  gender?: number;
  position?: string;
  industry?: string;
  address?: string;
  remark?: string;
  creatorName?: string;
}

export interface CustomerForm {
  name: string;
  shortName?: string;
  phone?: string;
  wechat?: string;
  email?: string;
  gender?: number;
  company?: string;
  position?: string;
  industry?: string;
  level?: string;
  source?: number;
  status?: number;
  ownerId?: string | number | null;
  address?: string;
  remark?: string;
  nextFollowTime?: string;
  tagIds?: (string | number)[];
}

export interface CustomerQuery extends BaseQueryParams {
  keyword?: string;
  level?: string;
  status?: number;
  statuses?: string;
  source?: number;
  tagId?: string | number;
  ownerId?: string | number;
  pool?: boolean;
  startDate?: string;
  endDate?: string;
}

export interface CustomerOption {
  id: string | number;
  name: string;
  company?: string;
  phone?: string;
}

export interface TagQuery extends BaseQueryParams {
  keyword?: string;
}

export interface TagForm {
  name: string;
  color?: string;
  sort?: number;
}

export interface FollowUpItem {
  id: string | number;
  customerId: string | number;
  customerName?: string;
  customerCompany?: string;
  type?: number;
  content?: string;
  result?: string;
  nextFollowTime?: string;
  createBy?: string | number;
  creatorName?: string;
  createTime?: string;
}

export interface FollowUpForm {
  customerId?: string | number | null;
  type?: number;
  content: string;
  result?: string;
  nextFollowTime?: string;
}

export interface FollowUpQuery extends BaseQueryParams {
  keyword?: string;
  customerId?: string | number;
  type?: number;
  creatorId?: string | number;
  startDate?: string;
  endDate?: string;
}

export interface OpportunityItem {
  id: string | number;
  customerId: string | number;
  customerName?: string;
  customerCompany?: string;
  name: string;
  amount?: number;
  stage?: number;
  probability?: number;
  expectedCloseDate?: string;
  ownerId?: string | number;
  ownerName?: string;
  remark?: string;
  createTime?: string;
}

export interface OpportunityForm {
  customerId?: string | number | null;
  name: string;
  amount?: number;
  stage?: number;
  probability?: number;
  expectedCloseDate?: string;
  ownerId?: string | number | null;
  remark?: string;
}

export interface OpportunityQuery extends BaseQueryParams {
  keyword?: string;
  customerId?: string | number;
  stage?: number;
  ownerId?: string | number;
}

export interface ContractItem {
  id: string | number;
  contractNo?: string;
  customerId: string | number;
  customerName?: string;
  customerCompany?: string;
  opportunityId?: string | number;
  name: string;
  amount?: number;
  signDate?: string;
  startDate?: string;
  endDate?: string;
  status?: number;
  ownerId?: string | number;
  ownerName?: string;
  remark?: string;
  createTime?: string;
}

export interface ContractForm {
  contractNo?: string;
  customerId?: string | number | null;
  opportunityId?: string | number | null;
  name: string;
  amount?: number;
  signDate?: string;
  startDate?: string;
  endDate?: string;
  status?: number;
  ownerId?: string | number | null;
  remark?: string;
}

export interface ContractQuery extends BaseQueryParams {
  keyword?: string;
  customerId?: string | number;
  status?: number;
  ownerId?: string | number;
}

export interface CampaignItem {
  id: string | number;
  name: string;
  type?: number;
  channel?: string;
  budget?: number;
  startDate?: string;
  endDate?: string;
  status?: number;
  targetCount?: number;
  leadCount?: number;
  ownerId?: string | number;
  ownerName?: string;
  remark?: string;
  createTime?: string;
}

export interface CampaignForm {
  name: string;
  type?: number;
  channel?: string;
  budget?: number;
  startDate?: string;
  endDate?: string;
  status?: number;
  targetCount?: number;
  ownerId?: string | number | null;
  remark?: string;
}

export interface CampaignQuery extends BaseQueryParams {
  keyword?: string;
  status?: number;
  type?: number;
}

export interface TrendPoint {
  date: string;
  count: number;
}

export interface NameValue {
  name?: string;
  value?: number | string;
}

export interface StageStat {
  stage?: number;
  count?: number;
  amount?: number;
}

export interface SalesRank {
  ownerId?: string | number;
  ownerName?: string;
  amount?: number;
}

export interface DashboardData {
  customerTotal: string | number;
  customerNew: string | number;
  poolCount: string | number;
  followUpCount: string | number;
  opportunityAmount: number;
  contractAmount: number;
  winRate: number;
  customerTrend: TrendPoint[];
  followTrend: TrendPoint[];
  sourceStats: NameValue[];
  stageStats: StageStat[];
  recentFollowUps: FollowUpItem[];
  todoCustomers: CustomerItem[];
  salesRanking: SalesRank[];
}
