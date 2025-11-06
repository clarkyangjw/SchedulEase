package com.cstar.schedulease.service.provider.dto;

import com.cstar.schedulease.service.services.dto.ServiceDTO;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ProviderDTO {
    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private Long id;

    @NotBlank(message = "First name is required", groups = Create.class)
    @Size(min = 1, max = 100, message = "First name must be between 1 and 100 characters")
    private String firstName;

    @NotBlank(message = "Last name is required", groups = Create.class)
    @Size(min = 1, max = 100, message = "Last name must be between 1 and 100 characters")
    private String lastName;

    @Size(max = 5000, message = "Description must not exceed 5000 characters")
    private String description;

    private List<Integer> availability;

    private Boolean isActive;

    // For input: service IDs to associate with the provider
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private List<Long> serviceIds;

    // For output: full service details
    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private List<ServiceDTO> services;

    public interface Create {}
    public interface Update {}
}
