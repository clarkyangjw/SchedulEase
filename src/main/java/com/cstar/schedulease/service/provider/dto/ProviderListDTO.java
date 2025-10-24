package com.cstar.schedulease.service.provider.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProviderListDTO {
    private Long id;
    private String fullName;
    private String description;
    private Boolean isActive;
    private Integer serviceCount;
}
