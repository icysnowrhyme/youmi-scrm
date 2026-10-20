import request from "@/utils/request";
import type { PageResult } from "@/api/common";

export interface PerformanceRow {
  userId: number;
  userName: string;
  deptName: string;
  customerCount: number;
  followCount: number;
  orderCount: number;
  orderAmount: number;
  winRate: number;
}

export interface DeptNode {
  id: number;
  parentId: number;
  name: string;
  code?: string;
  sort?: number;
  status?: number;
  children?: DeptNode[];
}

export interface UserRow {
  id: number;
  username: string;
  nickname?: string;
  mobile?: string;
  gender?: number;
  email?: string;
  status?: number;
  deptName?: string;
  roleNames?: string;
  createTime?: string;
}

export interface RoleRow {
  id: number;
  name: string;
  code: string;
  status: number;
  sort?: number;
  dataScope?: number;
  dataScopeLabel?: string;
  createTime?: string;
}

export interface PerformanceQuery {
  startDate?: string;
  endDate?: string;
}

const YoumiAPI = {
  performance(params: PerformanceQuery) {
    return request<unknown, PerformanceRow[]>({
      url: "/api/v1/youmi/reports/performance",
      method: "get",
      params,
    });
  },
  depts() {
    return request<unknown, DeptNode[]>({ url: "/api/v1/depts", method: "get" });
  },
  users(params: { pageNum: number; pageSize: number; deptId?: number; keywords?: string }) {
    return request<unknown, PageResult<UserRow>>({
      url: "/api/v1/users",
      method: "get",
      params,
    });
  },
  roles(params: { pageNum: number; pageSize: number }) {
    return request<unknown, PageResult<RoleRow>>({
      url: "/api/v1/roles",
      method: "get",
      params,
    });
  },
};

export default YoumiAPI;
