package com.youlai.boot.module.scrm.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.youlai.boot.core.web.PageResult;
import com.youlai.boot.core.web.Result;
import com.youlai.boot.module.scrm.model.form.CustomerAssignForm;
import com.youlai.boot.module.scrm.model.form.CustomerForm;
import com.youlai.boot.module.scrm.model.query.CustomerQuery;
import com.youlai.boot.module.scrm.model.vo.CustomerDetailVO;
import com.youlai.boot.module.scrm.model.vo.CustomerOptionVO;
import com.youlai.boot.module.scrm.model.vo.CustomerPageVO;
import com.youlai.boot.module.scrm.service.CustomerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "10.客户管理")
@RestController
@RequestMapping("/api/v1/scrm/customers")
@RequiredArgsConstructor
public class CustomerController {

    private final CustomerService customerService;

    @Operation(summary = "客户分页列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('scrm:customer:list')")
    public PageResult<CustomerPageVO> getPage(CustomerQuery query) {
        IPage<CustomerPageVO> page = customerService.getPage(query);
        return PageResult.success(page);
    }

    @Operation(summary = "客户公海分页列表")
    @GetMapping("/pool")
    @PreAuthorize("@ss.hasPerm('scrm:customer:list')")
    public PageResult<CustomerPageVO> getPoolPage(CustomerQuery query) {
        return PageResult.success(customerService.getPoolPage(query));
    }

    @Operation(summary = "客户下拉选项")
    @GetMapping("/options")
    public Result<List<CustomerOptionVO>> getOptions(@RequestParam(required = false) String keyword) {
        return Result.success(customerService.listOptions(keyword));
    }

    @Operation(summary = "客户详情")
    @GetMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('scrm:customer:list')")
    public Result<CustomerDetailVO> getDetail(@PathVariable Long id) {
        return Result.success(customerService.getDetail(id));
    }

    @Operation(summary = "新增客户")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('scrm:customer:create')")
    public Result<?> saveCustomer(@RequestBody @Valid CustomerForm form) {
        return Result.judge(customerService.saveCustomer(form));
    }

    @Operation(summary = "修改客户")
    @PutMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('scrm:customer:update')")
    public Result<?> updateCustomer(@PathVariable Long id, @RequestBody @Valid CustomerForm form) {
        return Result.judge(customerService.updateCustomer(id, form));
    }

    @Operation(summary = "删除客户")
    @DeleteMapping("/{ids}")
    @PreAuthorize("@ss.hasPerm('scrm:customer:delete')")
    public Result<?> deleteCustomers(@PathVariable String ids) {
        return Result.judge(customerService.deleteCustomers(ids));
    }

    @Operation(summary = "分配客户负责人")
    @PutMapping("/assign")
    @PreAuthorize("@ss.hasPerm('scrm:customer:assign')")
    public Result<?> assignCustomers(@RequestBody @Valid CustomerAssignForm form) {
        return Result.judge(customerService.assignCustomers(form.getIds(), form.getOwnerId()));
    }

    @Operation(summary = "领取公海客户")
    @PutMapping("/{id}/claim")
    @PreAuthorize("@ss.hasPerm('scrm:customer:claim')")
    public Result<?> claimCustomer(@PathVariable Long id) {
        return Result.judge(customerService.claimCustomer(id));
    }
}
