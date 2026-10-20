package com.youlai.boot.module.scrm.model.query;

import com.youlai.boot.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
@Schema(description = "客户查询对象")
public class CustomerQuery extends BaseQuery {

    @Schema(description = "关键词（姓名/公司/手机号）")
    private String keyword;

    private String level;
    private Integer status;
    private String statuses;
    private Integer source;
    private Long ownerId;
    private Long tagId;

    @Schema(description = "是否公海客户")
    private Boolean pool;

    @Schema(description = "创建开始日期")
    private String startDate;

    @Schema(description = "创建结束日期")
    private String endDate;
}
