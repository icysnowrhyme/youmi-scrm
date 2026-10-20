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
@TableName("biz_contract")
public class Contract extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    private String contractNo;
    private Long customerId;
    private Long opportunityId;
    private String name;
    private BigDecimal amount;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate signDate;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate startDate;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate endDate;

    private Integer status;
    private Long ownerId;
    private String remark;
    private Long createBy;
    private Long updateBy;
    private Integer isDeleted;
}
