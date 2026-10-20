package com.youlai.boot.module.scrm.model.form;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class ContractForm {

    private String contractNo;

    @NotNull(message = "客户不能为空")
    private Long customerId;

    private Long opportunityId;

    @NotBlank(message = "合同名称不能为空")
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
}
