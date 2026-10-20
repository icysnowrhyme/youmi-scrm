package com.youlai.boot.module.scrm.controller;

import com.youlai.boot.core.web.PageResult;
import com.youlai.boot.core.web.Result;
import com.youlai.boot.module.scrm.model.form.CampaignForm;
import com.youlai.boot.module.scrm.model.query.CampaignQuery;
import com.youlai.boot.module.scrm.model.vo.CampaignVO;
import com.youlai.boot.module.scrm.service.CampaignService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@Tag(name = "15.营销活动")
@RestController
@RequestMapping("/api/v1/scrm/campaigns")
@RequiredArgsConstructor
public class CampaignController {

    private final CampaignService campaignService;

    @Operation(summary = "活动分页列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('scrm:campaign:list')")
    public PageResult<CampaignVO> getPage(CampaignQuery query) {
        return PageResult.success(campaignService.getPage(query));
    }

    @Operation(summary = "活动详情")
    @GetMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('scrm:campaign:list')")
    public Result<CampaignVO> getDetail(@PathVariable Long id) {
        return Result.success(campaignService.getDetail(id));
    }

    @Operation(summary = "新增活动")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('scrm:campaign:create')")
    public Result<?> saveCampaign(@RequestBody @Valid CampaignForm form) {
        return Result.judge(campaignService.saveCampaign(form));
    }

    @Operation(summary = "修改活动")
    @PutMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('scrm:campaign:update')")
    public Result<?> updateCampaign(@PathVariable Long id, @RequestBody @Valid CampaignForm form) {
        return Result.judge(campaignService.updateCampaign(id, form));
    }

    @Operation(summary = "删除活动")
    @DeleteMapping("/{ids}")
    @PreAuthorize("@ss.hasPerm('scrm:campaign:delete')")
    public Result<?> deleteCampaigns(@PathVariable String ids) {
        return Result.judge(campaignService.deleteCampaigns(ids));
    }
}
