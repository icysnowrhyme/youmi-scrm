package com.youlai.boot.module.scrm.model.bo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class SalesRankBO {
    private Long ownerId;
    private BigDecimal amount;
}
