package com.youlai.boot.module.scrm.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.youlai.boot.common.base.BaseEntity;
import lombok.Getter;
import lombok.Setter;

import java.io.Serial;
import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Setter
@TableName("biz_opportunity")
public class Opportunity extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long customerId;
    private String name;
    private BigDecimal amount;
    private Integer stage;
    private Integer probability;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate expectedCloseDate;

    private Long ownerId;
    private String remark;
    private Long createBy;
    private Long updateBy;
    private Integer isDeleted;
}
