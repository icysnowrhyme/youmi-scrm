package com.youlai.boot.module.scrm.model.form;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Schema(description = "跟进记录表单")
public class FollowUpForm {

    @NotNull(message = "客户不能为空")
    private Long customerId;

    @NotNull(message = "跟进方式不能为空")
    private Integer type;

    @NotBlank(message = "跟进内容不能为空")
    private String content;

    private String result;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime nextFollowTime;
}
