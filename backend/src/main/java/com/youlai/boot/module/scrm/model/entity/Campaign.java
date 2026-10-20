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
@TableName("biz_campaign")
public class Campaign extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    private String name;
    private Integer type;
    private String channel;
    private BigDecimal budget;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate startDate;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate endDate;

    private Integer status;
    private Integer targetCount;
    private Integer leadCount;
    private Long ownerId;
    private String remark;
    private Long createBy;
    private Long updateBy;
    private Integer isDeleted;
}
