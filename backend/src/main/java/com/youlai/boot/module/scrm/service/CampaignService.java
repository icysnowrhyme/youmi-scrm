package com.youlai.boot.module.scrm.service;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youlai.boot.core.exception.BusinessException;
import com.youlai.boot.module.scrm.mapper.CampaignMapper;
import com.youlai.boot.module.scrm.model.entity.Campaign;
import com.youlai.boot.module.scrm.model.form.CampaignForm;
import com.youlai.boot.module.scrm.model.query.CampaignQuery;
import com.youlai.boot.module.scrm.model.vo.CampaignVO;
import com.youlai.boot.module.scrm.support.ScrmDataScope;
import com.youlai.boot.security.util.SecurityUtils;
import com.youlai.boot.system.model.entity.User;
import com.youlai.boot.system.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CampaignService extends ServiceImpl<CampaignMapper, Campaign> {

    private final UserService userService;

    public IPage<CampaignVO> getPage(CampaignQuery query) {
        LambdaQueryWrapper<Campaign> wrapper = new LambdaQueryWrapper<>();
        Long scope = ScrmDataScope.scopeOwnerId();
        if (scope != null) {
            wrapper.eq(Campaign::getOwnerId, scope);
        }
        wrapper.like(StrUtil.isNotBlank(query.getKeyword()), Campaign::getName, query.getKeyword())
                .eq(query.getType() != null, Campaign::getType, query.getType())
                .eq(query.getStatus() != null, Campaign::getStatus, query.getStatus())
                .orderByDesc(Campaign::getCreateTime);
        Page<Campaign> page = this.page(new Page<>(query.getPageNum(), query.getPageSize()), wrapper);
        Page<CampaignVO> voPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        voPage.setRecords(toVoList(page.getRecords()));
        return voPage;
    }

    public boolean saveCampaign(CampaignForm form) {
        Campaign entity = BeanUtil.copyProperties(form, Campaign.class);
        Long userId = SecurityUtils.getUserId();
        entity.setOwnerId(ScrmDataScope.canViewAll() && form.getOwnerId() != null ? form.getOwnerId() : userId);
        entity.setStatus(form.getStatus() == null ? 0 : form.getStatus());
        entity.setCreateBy(userId);
        entity.setUpdateBy(userId);
        return this.save(entity);
    }

    public boolean updateCampaign(Long id, CampaignForm form) {
        Campaign entity = getEditable(id);
        BeanUtil.copyProperties(form, entity, "id", "createBy", "createTime", "isDeleted", "ownerId");
        if (!ScrmDataScope.canViewAll()) {
            entity.setOwnerId(SecurityUtils.getUserId());
        } else if (form.getOwnerId() != null) {
            entity.setOwnerId(form.getOwnerId());
        }
        entity.setUpdateBy(SecurityUtils.getUserId());
        return this.updateById(entity);
    }

    public boolean deleteCampaigns(String ids) {
        List<Long> idList = StrUtil.split(ids, ',').stream().filter(StrUtil::isNotBlank)
                .map(s -> Long.valueOf(s.trim())).toList();
        if (CollUtil.isEmpty(idList)) {
            return false;
        }
        idList.forEach(this::getEditable);
        return this.removeByIds(idList);
    }

    public CampaignVO getDetail(Long id) {
        return toVoList(List.of(getEditable(id))).get(0);
    }

    private List<CampaignVO> toVoList(List<Campaign> campaigns) {
        if (CollUtil.isEmpty(campaigns)) {
            return List.of();
        }
        Map<Long, String> owners = userNames(campaigns.stream().map(Campaign::getOwnerId).toList());
        return campaigns.stream().map(c -> {
            CampaignVO vo = BeanUtil.copyProperties(c, CampaignVO.class);
            vo.setOwnerName(c.getOwnerId() == null ? null : owners.get(c.getOwnerId()));
            return vo;
        }).toList();
    }

    private Campaign getEditable(Long id) {
        Campaign campaign = this.getById(id);
        if (campaign == null) {
            throw new BusinessException("活动不存在");
        }
        if (!ScrmDataScope.canViewAll() && !Objects.equals(campaign.getOwnerId(), SecurityUtils.getUserId())) {
            throw new BusinessException("无权操作该活动");
        }
        return campaign;
    }

    private Map<Long, String> userNames(Collection<Long> ids) {
        List<Long> userIds = ids.stream().filter(Objects::nonNull).distinct().toList();
        if (userIds.isEmpty()) {
            return Map.of();
        }
        return userService.listByIds(userIds).stream()
                .collect(Collectors.toMap(User::getId,
                        u -> StrUtil.blankToDefault(u.getNickname(), u.getUsername())));
    }
}
