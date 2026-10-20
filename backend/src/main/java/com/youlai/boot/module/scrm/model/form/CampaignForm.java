package com.youlai.boot.module.scrm.model.form;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class CampaignForm {

    @NotBlank(message = "活动名称不能为空")
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
}
