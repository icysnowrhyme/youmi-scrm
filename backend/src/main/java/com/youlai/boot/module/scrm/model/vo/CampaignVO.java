package com.youlai.boot.module.scrm.model.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class CampaignVO {

    private Long id;
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
    private String ownerName;
    private String remark;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
