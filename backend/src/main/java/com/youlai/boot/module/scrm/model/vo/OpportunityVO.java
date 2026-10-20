package com.youlai.boot.module.scrm.model.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class OpportunityVO {

    private Long id;
    private Long customerId;
    private String customerName;
    private String customerCompany;
    private String name;
    private BigDecimal amount;
    private Integer stage;
    private Integer probability;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate expectedCloseDate;

    private Long ownerId;
    private String ownerName;
    private String remark;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
