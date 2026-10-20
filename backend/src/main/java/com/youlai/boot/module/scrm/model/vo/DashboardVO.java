package com.youlai.boot.module.scrm.model.vo;

import com.youlai.boot.module.scrm.model.bo.NameValueBO;
import com.youlai.boot.module.scrm.model.bo.StageStatBO;
import com.youlai.boot.module.scrm.model.bo.TrendPointBO;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class DashboardVO {

    private Long customerTotal;
    private Long customerNew;
    private Long poolCount;
    private Long followUpCount;
    private BigDecimal opportunityAmount;
    private BigDecimal contractAmount;
    private Integer winRate;

    private List<TrendPointBO> customerTrend;
    private List<TrendPointBO> followTrend;
    private List<NameValueBO> sourceStats;
    private List<StageStatBO> stageStats;
    private List<FollowUpVO> recentFollowUps;
    private List<FollowUpVO> todoFollowUps;
    private List<CustomerPageVO> todoCustomers;
    private List<SalesRankVO> salesRanking;
}
