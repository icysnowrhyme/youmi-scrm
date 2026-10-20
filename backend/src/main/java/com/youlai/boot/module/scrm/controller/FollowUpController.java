package com.youlai.boot.module.scrm.controller;

import com.youlai.boot.core.web.PageResult;
import com.youlai.boot.core.web.Result;
import com.youlai.boot.module.scrm.model.form.FollowUpForm;
import com.youlai.boot.module.scrm.model.query.FollowUpQuery;
import com.youlai.boot.module.scrm.model.vo.FollowUpVO;
import com.youlai.boot.module.scrm.service.FollowUpService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "12.跟进记录")
@RestController
@RequestMapping("/api/v1/scrm/follow-ups")
@RequiredArgsConstructor
public class FollowUpController {

    private final FollowUpService followUpService;

    @Operation(summary = "跟进记录分页列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('scrm:follow-up:list')")
    public PageResult<FollowUpVO> getPage(FollowUpQuery query) {
        return PageResult.success(followUpService.getPage(query));
    }

    @Operation(summary = "客户跟进记录")
    @GetMapping("/customer/{customerId}")
    @PreAuthorize("@ss.hasPerm('scrm:follow-up:list')")
    public Result<List<FollowUpVO>> listByCustomer(@PathVariable Long customerId) {
        return Result.success(followUpService.listByCustomer(customerId));
    }

    @Operation(summary = "新增跟进记录")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('scrm:follow-up:create')")
    public Result<?> saveFollowUp(@RequestBody @Valid FollowUpForm form) {
        return Result.judge(followUpService.saveFollowUp(form));
    }

    @Operation(summary = "修改跟进记录")
    @PutMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('scrm:follow-up:update')")
    public Result<?> updateFollowUp(@PathVariable Long id, @RequestBody @Valid FollowUpForm form) {
        return Result.judge(followUpService.updateFollowUp(id, form));
    }

    @Operation(summary = "删除跟进记录")
    @DeleteMapping("/{ids}")
    @PreAuthorize("@ss.hasPerm('scrm:follow-up:delete')")
    public Result<?> deleteFollowUps(@PathVariable String ids) {
        return Result.judge(followUpService.deleteFollowUps(ids));
    }
}
