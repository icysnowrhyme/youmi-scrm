package com.youlai.boot.module.scrm.model.form;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Schema(description = "客户表单")
public class CustomerForm {

    @Schema(description = "客户姓名")
    @NotBlank(message = "客户姓名不能为空")
    private String name;

    private String shortName;
    private String phone;
    private String wechat;
    private String email;
    private Integer gender;
    private String company;
    private String position;
    private String industry;
    private String level;
    private Integer source;
    private Integer status;
    private Long ownerId;
    private String address;
    private String remark;

    @Schema(description = "下次跟进时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime nextFollowTime;

    @Schema(description = "标签ID集合")
    private List<Long> tagIds;
}
