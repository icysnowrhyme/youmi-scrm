package com.youlai.boot.module.scrm.model.form;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class OpportunityForm {

    @NotNull(message = "客户不能为空")
    private Long customerId;

    @NotBlank(message = "商机名称不能为空")
    private String name;

    private BigDecimal amount;
    private Integer stage;
    private Integer probability;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate expectedCloseDate;

    private Long ownerId;
    private String remark;
}
