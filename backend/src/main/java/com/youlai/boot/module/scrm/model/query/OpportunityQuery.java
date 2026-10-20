package com.youlai.boot.module.scrm.model.query;

import com.youlai.boot.common.base.BaseQuery;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class OpportunityQuery extends BaseQuery {

    private String keyword;
    private Long customerId;
    private Integer stage;
    private Long ownerId;
}
