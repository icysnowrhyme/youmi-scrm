package com.youlai.boot.module.scrm.model.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class FollowUpVO {

    private Long id;
    private Long customerId;
    private String customerName;
    private String customerCompany;
    private Integer type;
    private String content;
    private String result;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime nextFollowTime;

    private Long createBy;
    private String creatorName;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
