package com.youlai.boot.module.scrm.service;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youlai.boot.core.exception.BusinessException;
import com.youlai.boot.module.scrm.mapper.CustomerTagMapper;
import com.youlai.boot.module.scrm.mapper.CustomerTagRelMapper;
import com.youlai.boot.module.scrm.model.bo.TagCountBO;
import com.youlai.boot.module.scrm.model.entity.CustomerTag;
import com.youlai.boot.module.scrm.model.entity.CustomerTagRel;
import com.youlai.boot.module.scrm.model.form.CustomerTagForm;
import com.youlai.boot.module.scrm.model.query.CustomerTagQuery;
import com.youlai.boot.module.scrm.model.vo.TagVO;
import com.youlai.boot.security.util.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CustomerTagService extends ServiceImpl<CustomerTagMapper, CustomerTag> {

    private final CustomerTagRelMapper tagRelMapper;

    public List<TagVO> listTags(CustomerTagQuery query) {
        LambdaQueryWrapper<CustomerTag> wrapper = new LambdaQueryWrapper<CustomerTag>()
                .like(StrUtil.isNotBlank(query.getKeyword()), CustomerTag::getName, query.getKeyword())
                .orderByAsc(CustomerTag::getSort)
                .orderByAsc(CustomerTag::getId);
        Map<Long, Long> counts = tagRelMapper.countByTag().stream()
                .collect(Collectors.toMap(TagCountBO::getTagId, TagCountBO::getCount));
        return this.list(wrapper).stream().map(tag -> {
            TagVO vo = new TagVO();
            vo.setId(tag.getId());
            vo.setName(tag.getName());
            vo.setColor(tag.getColor());
            vo.setSort(tag.getSort());
            vo.setCustomerCount(counts.getOrDefault(tag.getId(), 0L));
            return vo;
        }).toList();
    }

    public boolean saveTag(CustomerTagForm form) {
        checkNameUnique(form.getName(), null);
        CustomerTag tag = new CustomerTag();
        tag.setName(form.getName().trim());
        tag.setColor(StrUtil.blankToDefault(form.getColor(), "#409EFF"));
        tag.setSort(form.getSort() == null ? 0 : form.getSort());
        tag.setCreateBy(SecurityUtils.getUserId());
        tag.setUpdateBy(SecurityUtils.getUserId());
        return this.save(tag);
    }

    public boolean updateTag(Long id, CustomerTagForm form) {
        CustomerTag tag = this.getById(id);
        if (tag == null) {
            throw new BusinessException("标签不存在");
        }
        checkNameUnique(form.getName(), id);
        tag.setName(form.getName().trim());
        tag.setColor(StrUtil.blankToDefault(form.getColor(), "#409EFF"));
        tag.setSort(form.getSort() == null ? 0 : form.getSort());
        tag.setUpdateBy(SecurityUtils.getUserId());
        return this.updateById(tag);
    }

    @Transactional(rollbackFor = Exception.class)
    public boolean deleteTags(String ids) {
        List<Long> idList = StrUtil.split(ids, ',').stream().filter(StrUtil::isNotBlank)
                .map(s -> Long.valueOf(s.trim())).toList();
        if (CollUtil.isEmpty(idList)) {
            return false;
        }
        tagRelMapper.delete(new LambdaQueryWrapper<CustomerTagRel>().in(CustomerTagRel::getTagId, idList));
        return this.removeByIds(idList);
    }

    private void checkNameUnique(String name, Long excludeId) {
        boolean exists = this.exists(new LambdaQueryWrapper<CustomerTag>()
                .eq(CustomerTag::getName, name.trim())
                .ne(excludeId != null, CustomerTag::getId, excludeId));
        if (exists) {
            throw new BusinessException("标签名称已存在");
        }
    }
}
