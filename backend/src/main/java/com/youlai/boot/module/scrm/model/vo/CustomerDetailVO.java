package com.youlai.boot.module.scrm.model.vo;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class CustomerDetailVO extends CustomerPageVO {

    private String wechat;
    private String email;
    private Integer gender;
    private String position;
    private String industry;
    private String address;
    private String remark;
    private Long createBy;
    private String creatorName;
}
