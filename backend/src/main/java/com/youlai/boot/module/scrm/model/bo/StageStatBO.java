package com.youlai.boot.module.scrm.model.bo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class StageStatBO {
    private Integer stage;
    private Long count;
    private BigDecimal amount;
}
