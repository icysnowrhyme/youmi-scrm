package com.youlai.boot.module.scrm.model.form;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CustomerAssignForm {

    @NotBlank(message = "请选择客户")
    private String ids;

    private Long ownerId;
}
