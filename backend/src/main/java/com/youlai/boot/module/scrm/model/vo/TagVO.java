package com.youlai.boot.module.scrm.model.vo;

import lombok.Data;

@Data
public class TagVO {
    private Long id;
    private String name;
    private String color;
    private Integer sort;
    private Long customerCount;
}
