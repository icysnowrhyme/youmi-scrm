package com.youlai.boot.module.scrm.controller;

import com.youlai.boot.core.web.Result;
import com.youlai.boot.module.scrm.model.form.CustomerTagForm;
import com.youlai.boot.module.scrm.model.query.CustomerTagQuery;
import com.youlai.boot.module.scrm.model.vo.TagVO;
import com.youlai.boot.module.scrm.service.CustomerTagService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "11.客户标签")
@RestController
@RequestMapping("/api/v1/scrm/tags")
@RequiredArgsConstructor
public class CustomerTagController {

    private final CustomerTagService tagService;

    @Operation(summary = "标签列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('scrm:tag:list')")
    public Result<List<TagVO>> listTags(CustomerTagQuery query) {
        return Result.success(tagService.listTags(query));
    }

    @Operation(summary = "新增标签")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('scrm:tag:create')")
    public Result<?> saveTag(@RequestBody @Valid CustomerTagForm form) {
        return Result.judge(tagService.saveTag(form));
    }

    @Operation(summary = "修改标签")
    @PutMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('scrm:tag:update')")
    public Result<?> updateTag(@PathVariable Long id, @RequestBody @Valid CustomerTagForm form) {
        return Result.judge(tagService.updateTag(id, form));
    }

    @Operation(summary = "删除标签")
    @DeleteMapping("/{ids}")
    @PreAuthorize("@ss.hasPerm('scrm:tag:delete')")
    public Result<?> deleteTags(@PathVariable String ids) {
        return Result.judge(tagService.deleteTags(ids));
    }
}
