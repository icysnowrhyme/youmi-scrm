package com.youlai.boot.module.scrm.controller;

import com.youlai.boot.core.web.Result;
import com.youlai.boot.module.scrm.model.vo.DashboardVO;
import com.youlai.boot.module.scrm.service.DashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "16.销售看板")
@RestController
@RequestMapping("/api/v1/scrm/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    @Operation(summary = "工作台数据概览")
    @GetMapping
    public Result<DashboardVO> getDashboard(@RequestParam(required = false, defaultValue = "30") Integer days) {
        return Result.success(dashboardService.getDashboard(days));
    }
}
