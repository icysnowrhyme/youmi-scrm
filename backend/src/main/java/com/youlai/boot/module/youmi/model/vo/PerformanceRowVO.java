package com.youlai.boot.module.youmi.model.vo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class PerformanceRowVO {

    private Long userId;
    private String userName;
    private String deptName;
    private Long customerCount;
    private Long followCount;
    private Long orderCount;
    private BigDecimal orderAmount;
    private Integer winRate;
}
