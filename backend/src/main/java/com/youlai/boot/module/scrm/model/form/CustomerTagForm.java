package com.youlai.boot.module.scrm.model.form;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
@Schema(description = "客户标签表单")
public class CustomerTagForm {

    @NotBlank(message = "标签名称不能为空")
    private String name;

    private String color;
    private Integer sort;
}
