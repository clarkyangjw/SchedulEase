package com.cstar.schedulease.service.appointment.dto;

import com.cstar.schedulease.common.enums.AppointmentStatus;
import com.cstar.schedulease.service.client.dto.ClientDTO;
import com.cstar.schedulease.service.provider.dto.ProviderDTO;
import com.cstar.schedulease.service.services.dto.ServiceDTO;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AppointmentDTO {
    
    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private Long id;

    @NotNull(message = "Client ID is required", groups = Create.class)
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private Long clientId;

    @NotNull(message = "Provider ID is required", groups = Create.class)
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private Long providerId;

    @NotNull(message = "Service ID is required", groups = Create.class)
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private Long serviceId;

    @NotNull(message = "Start time is required", groups = Create.class)
    private Long startTime;

    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private Integer duration;

    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private Long endTime;

    @NotNull(message = "Status is required", groups = Update.class)
    private AppointmentStatus status;

    private String notes;

    private String cancellationReason;

    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private ClientDTO client;

    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private ProviderDTO provider;

    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private ServiceDTO service;

    public interface Create {}
    public interface Update {}
}

