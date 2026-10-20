package com.youlai.boot.module.scrm.controller;

import com.youlai.boot.core.web.PageResult;
import com.youlai.boot.core.web.Result;
import com.youlai.boot.module.scrm.model.form.OpportunityForm;
import com.youlai.boot.module.scrm.model.query.OpportunityQuery;
import com.youlai.boot.module.scrm.model.vo.OpportunityVO;
import com.youlai.boot.module.scrm.service.OpportunityService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "13.商机管理")
@RestController
@RequestMapping("/api/v1/scrm/opportunities")
@RequiredArgsConstructor
public class OpportunityController {

    private final OpportunityService opportunityService;

    @Operation(summary = "商机分页列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('scrm:opportunity:list')")
    public PageResult<OpportunityVO> getPage(OpportunityQuery query) {
        return PageResult.success(opportunityService.getPage(query));
    }

    @Operation(summary = "商机详情")
    @GetMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('scrm:opportunity:list')")
    public Result<OpportunityVO> getDetail(@PathVariable Long id) {
        return Result.success(opportunityService.getDetail(id));
    }

    @Operation(summary = "客户商机列表")
    @GetMapping("/customer/{customerId}")
    public Result<List<OpportunityVO>> listByCustomer(@PathVariable Long customerId) {
        return Result.success(opportunityService.listByCustomer(customerId));
    }

    @Operation(summary = "新增商机")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('scrm:opportunity:create')")
    public Result<?> saveOpportunity(@RequestBody @Valid OpportunityForm form) {
        return Result.judge(opportunityService.saveOpportunity(form));
    }

    @Operation(summary = "修改商机")
    @PutMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('scrm:opportunity:update')")
    public Result<?> updateOpportunity(@PathVariable Long id, @RequestBody @Valid OpportunityForm form) {
        return Result.judge(opportunityService.updateOpportunity(id, form));
    }

    @Operation(summary = "删除商机")
    @DeleteMapping("/{ids}")
    @PreAuthorize("@ss.hasPerm('scrm:opportunity:delete')")
    public Result<?> deleteOpportunities(@PathVariable String ids) {
        return Result.judge(opportunityService.deleteOpportunities(ids));
    }
}
