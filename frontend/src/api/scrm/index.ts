import request from "@/utils/request";
import type { PageResult } from "@/api/common";
import type {
  CampaignForm,
  CampaignItem,
  CampaignQuery,
  ContractForm,
  ContractItem,
  ContractQuery,
  CustomerDetail,
  CustomerForm,
  CustomerItem,
  CustomerOption,
  CustomerQuery,
  DashboardData,
  FollowUpForm,
  FollowUpItem,
  FollowUpQuery,
  OpportunityForm,
  OpportunityItem,
  OpportunityQuery,
  ScrmTag,
  TagForm,
  TagQuery,
} from "./types";

const SCRM = "/api/v1/scrm";

const CustomerAPI = {
  getPage(params: CustomerQuery) {
    return request<unknown, PageResult<CustomerItem>>({ url: `${SCRM}/customers`, method: "get", params });
  },
  getPoolPage(params: CustomerQuery) {
    return request<unknown, PageResult<CustomerItem>>({
      url: `${SCRM}/customers/pool`,
      method: "get",
      params,
    });
  },
  getOptions(keyword?: string) {
    return request<unknown, CustomerOption[]>({
      url: `${SCRM}/customers/options`,
      method: "get",
      params: { keyword },
    });
  },
  getDetail(id: string | number) {
    return request<unknown, CustomerDetail>({ url: `${SCRM}/customers/${id}`, method: "get" });
  },
  create(data: CustomerForm) {
    return request({ url: `${SCRM}/customers`, method: "post", data });
  },
  update(id: string | number, data: CustomerForm) {
    return request({ url: `${SCRM}/customers/${id}`, method: "put", data });
  },
  remove(ids: string) {
    return request({ url: `${SCRM}/customers/${ids}`, method: "delete" });
  },
  assign(ids: string, ownerId: string | number | null) {
    return request({ url: `${SCRM}/customers/assign`, method: "put", data: { ids, ownerId } });
  },
  claim(id: string | number) {
    return request({ url: `${SCRM}/customers/${id}/claim`, method: "put" });
  },
};

const TagAPI = {
  list(params?: TagQuery) {
    return request<unknown, ScrmTag[]>({ url: `${SCRM}/tags`, method: "get", params });
  },
  create(data: TagForm) {
    return request({ url: `${SCRM}/tags`, method: "post", data });
  },
  update(id: string | number, data: TagForm) {
    return request({ url: `${SCRM}/tags/${id}`, method: "put", data });
  },
  remove(ids: string) {
    return request({ url: `${SCRM}/tags/${ids}`, method: "delete" });
  },
};

const FollowUpAPI = {
  getPage(params: FollowUpQuery) {
    return request<unknown, PageResult<FollowUpItem>>({
      url: `${SCRM}/follow-ups`,
      method: "get",
      params,
    });
  },
  listByCustomer(customerId: string | number) {
    return request<unknown, FollowUpItem[]>({
      url: `${SCRM}/follow-ups/customer/${customerId}`,
      method: "get",
    });
  },
  create(data: FollowUpForm) {
    return request({ url: `${SCRM}/follow-ups`, method: "post", data });
  },
  update(id: string | number, data: FollowUpForm) {
    return request({ url: `${SCRM}/follow-ups/${id}`, method: "put", data });
  },
  remove(ids: string) {
    return request({ url: `${SCRM}/follow-ups/${ids}`, method: "delete" });
  },
};

const OpportunityAPI = {
  getPage(params: OpportunityQuery) {
    return request<unknown, PageResult<OpportunityItem>>({
      url: `${SCRM}/opportunities`,
      method: "get",
      params,
    });
  },
  listByCustomer(customerId: string | number) {
    return request<unknown, OpportunityItem[]>({
      url: `${SCRM}/opportunities/customer/${customerId}`,
      method: "get",
    });
  },
  create(data: OpportunityForm) {
    return request({ url: `${SCRM}/opportunities`, method: "post", data });
  },
  update(id: string | number, data: OpportunityForm) {
    return request({ url: `${SCRM}/opportunities/${id}`, method: "put", data });
  },
  remove(ids: string) {
    return request({ url: `${SCRM}/opportunities/${ids}`, method: "delete" });
  },
};

const ContractAPI = {
  getPage(params: ContractQuery) {
    return request<unknown, PageResult<ContractItem>>({
      url: `${SCRM}/contracts`,
      method: "get",
      params,
    });
  },
  listByCustomer(customerId: string | number) {
    return request<unknown, ContractItem[]>({
      url: `${SCRM}/contracts/customer/${customerId}`,
      method: "get",
    });
  },
  create(data: ContractForm) {
    return request({ url: `${SCRM}/contracts`, method: "post", data });
  },
  update(id: string | number, data: ContractForm) {
    return request({ url: `${SCRM}/contracts/${id}`, method: "put", data });
  },
  remove(ids: string) {
    return request({ url: `${SCRM}/contracts/${ids}`, method: "delete" });
  },
};

const CampaignAPI = {
  getPage(params: CampaignQuery) {
    return request<unknown, PageResult<CampaignItem>>({
      url: `${SCRM}/campaigns`,
      method: "get",
      params,
    });
  },
  create(data: CampaignForm) {
    return request({ url: `${SCRM}/campaigns`, method: "post", data });
  },
  update(id: string | number, data: CampaignForm) {
    return request({ url: `${SCRM}/campaigns/${id}`, method: "put", data });
  },
  remove(ids: string) {
    return request({ url: `${SCRM}/campaigns/${ids}`, method: "delete" });
  },
};

const DashboardAPI = {
  get(days = 30) {
    return request<unknown, DashboardData>({
      url: `${SCRM}/dashboard`,
      method: "get",
      params: { days },
    });
  },
};

export {
  CampaignAPI,
  ContractAPI,
  CustomerAPI,
  DashboardAPI,
  FollowUpAPI,
  OpportunityAPI,
  TagAPI,
};
