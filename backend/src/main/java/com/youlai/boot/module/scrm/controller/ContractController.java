package com.youlai.boot.module.scrm.controller;

import com.youlai.boot.core.web.PageResult;
import com.youlai.boot.core.web.Result;
import com.youlai.boot.module.scrm.model.form.ContractForm;
import com.youlai.boot.module.scrm.model.query.ContractQuery;
import com.youlai.boot.module.scrm.model.vo.ContractVO;
import com.youlai.boot.module.scrm.service.ContractService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "14.合同管理")
@RestController
@RequestMapping("/api/v1/scrm/contracts")
@RequiredArgsConstructor
public class ContractController {

    private final ContractService contractService;

    @Operation(summary = "合同分页列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('scrm:contract:list')")
    public PageResult<ContractVO> getPage(ContractQuery query) {
        return PageResult.success(contractService.getPage(query));
    }

    @Operation(summary = "合同详情")
    @GetMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('scrm:contract:list')")
    public Result<ContractVO> getDetail(@PathVariable Long id) {
        return Result.success(contractService.getDetail(id));
    }

    @Operation(summary = "客户合同列表")
    @GetMapping("/customer/{customerId}")
    public Result<List<ContractVO>> listByCustomer(@PathVariable Long customerId) {
        return Result.success(contractService.listByCustomer(customerId));
    }

    @Operation(summary = "新增合同")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('scrm:contract:create')")
    public Result<?> saveContract(@RequestBody @Valid ContractForm form) {
        return Result.judge(contractService.saveContract(form));
    }

    @Operation(summary = "修改合同")
    @PutMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('scrm:contract:update')")
    public Result<?> updateContract(@PathVariable Long id, @RequestBody @Valid ContractForm form) {
        return Result.judge(contractService.updateContract(id, form));
    }

    @Operation(summary = "删除合同")
    @DeleteMapping("/{ids}")
    @PreAuthorize("@ss.hasPerm('scrm:contract:delete')")
    public Result<?> deleteContracts(@PathVariable String ids) {
        return Result.judge(contractService.deleteContracts(ids));
    }
}
